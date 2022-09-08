/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 9/1/2022.
 */


public with sharing class EASYContactMatching {

    private class matchingWrapper {
        private Id appId { get; set; }
        private Id interactionId { get; set; }
        private String duplicateRule { get; set; }
        private String matchingRules { get; set; }
        private String matchingMethod { get; set; }
        private String multipleMatchBehavior { get; set; }
        private String noMatchBehaviour { get; set; }
    }

    private static void matchContactsByDuplicateRule(List<Interaction__c> newInteractions) {

        Map<Id, Id> appInteractionMap = new Map<Id, Id>();
        Map<Id, matchingWrapper> interactionAppsWithMatching = new Map<Id, matchingWrapper>();

        for (Interaction__c interaction : newInteractions) {
            appInteractionMap.put(interaction.Admissions_Application__c, interaction.Id);
        }

        if (Schema.SObjectType.Application_Control__c.isAccessible()) {
            for (Application__c application : [
                    SELECT Id,
                            Application_Control__r.Contact_Creation_Duplicate_Rule__c,
                            Application_Control__r.Contact_Matching_Rules__c,
                            Application_Control__r.Custom_Metadata_Contact_Matching_Method__c,
                            Application_Control__r.Contact_Matching_Multiple_Match_Behavior__c,
                            Application_Control__r.Contact_Matching_No_Match_Behavior__c
                    FROM Application__c
                    WHERE Id IN :appInteractionMap.keySet()
            ]) {
                if (application.Application_Control__r.Contact_Matching_Rules__c.equalsIgnoreCase('Use Salesforce Duplicate Rule')) {
                    matchingWrapper mWrapper = new matchingWrapper();
                    mWrapper.appId = application.Id;
                    mWrapper.interactionId = appInteractionMap.get(application.Id);
                    mWrapper.duplicateRule = application.Application_Control__r.Contact_Creation_Duplicate_Rule__c.replaceAll(' ', '_');
                    mWrapper.matchingRules = application.Application_Control__r.Contact_Matching_Rules__c;
                    mWrapper.matchingMethod = application.Application_Control__r.Custom_Metadata_Contact_Matching_Method__c;
                    mWrapper.multipleMatchBehavior = application.Application_Control__r.Contact_Matching_Multiple_Match_Behavior__c;
                    mWrapper.noMatchBehaviour = application.Application_Control__r.Contact_Matching_No_Match_Behavior__c;
                    interactionAppsWithMatching.put(mWrapper.interactionId, mWrapper);
                }
            }
        }

        if (interactionAppsWithMatching.size() > 0) {
            // Find out which Registrations need new Contacts, creates them,
            // and matches with existing Contacts whenever possible as defined by existing Duplicate Rules
            for (Interaction__c interaction : newInteractions) {
                if (interactionAppsWithMatching.containsKey(interaction.Id)) {
                    matchingWrapper mWrapper = interactionAppsWithMatching.get(interaction.Id);
                    Contact c = makeContact(interaction, mWrapper.matchingMethod);
                    List<Datacloud.FindDuplicatesResult> results = new List<Datacloud.FindDuplicatesResult>();
                    doCRUD crud = new doCRUD();

                    try { // Datacloud.FindDuplicates returns an error if no matching rules are active
                        List<Contact> cons = new List<Contact>();
                        cons.add(c);
                        results = crud.findDuplicateContacts(cons);
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                    }

                    List<Contact> matchContacts = new List<Contact>();
                    if (results.size() > 0) {
                        for (Datacloud.DuplicateResult dr : results[0].getDuplicateResults()) {
                            if (mWrapper.duplicateRule == dr.getDuplicateRule()) {
                                for (Datacloud.MatchResult mr : dr.getMatchResults()) {
                                    for (Datacloud.MatchRecord mRecord : mr.getMatchRecords()) {
                                        try {
                                            Contact con = (Contact) mRecord.getRecord();
                                            matchContacts.add(con);
                                        } catch (Exception e) {
                                            System.debug(e);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if (!matchContacts.isEmpty()) {
                        List<Id> foundIds = new List<Id>();
                        for (Contact con : matchContacts) {
                            foundIds.add(con.Id);
                        }
                        matchContacts = crud.findContacts(foundIds);
                    }

                    String matchLog = '';

                    if (matchContacts == null || matchContacts.isEmpty()) { // SOQL queries return null instead of empty lists
                        if (mWrapper.noMatchBehaviour == 'Create Contact') {
                            for (EASY_Contact_Matching_Mapping__mdt mapping : [
                                    SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                                    FROM EASY_Contact_Matching_Mapping__mdt
                                    WHERE Contact_Matching_Method__c = :mWrapper.matchingMethod
                                    AND Matching_Only__c = TRUE
                            ]) {
                                c.put(mapping.Contact_Field_API_Name__c, null);
                            }
                            crud.addRecord(c);
                            //interaction.New_Contact_Created__c = true;
                            interaction.Contact__c = c.Id;
                            matchLog += matchingLog(interaction, new List<Contact>(), 'Match not found using Duplicate Rule <em>' + mWrapper.matchingMethod + '</em></div>', 'New contact created!', true);
                        } else {
                            matchLog += matchingLog(null, new List<Contact>(), 'Match not found using Duplicate Rule <em>' + mWrapper.matchingMethod + '</em>', 'Contact creation skipped based on "Contact Matching Skip Contact Creation" field value on Summit Events object', false);
                        }
                    } else if (matchContacts.size() == 1) {
                        interaction.Contact__c = matchContacts[0].Id;
                        //interaction.New_Contact_Created__c = false;
                        matchLog += matchingLog(interaction, new List<Contact>(), 'Match found using Salesforce Duplicate Rule <em>' + mWrapper.matchingMethod.replaceAll('_', ' ') + '</em>', '', false);
                    } else {
                        if (mWrapper.multipleMatchBehavior == 'Skip matching') {
                            matchLog += matchingLog(null, matchContacts, 'Multiple matches found using Salesforce Duplicate Rule <em>' + mWrapper.matchingMethod.replaceAll('_', ' ') + '</em>, Contact matching skipped based on "Contact Matching Multiple Match Behavior" field value on Summit Events object', '', false);
                        } else if (mWrapper.multipleMatchBehavior == 'Match with most recently modified') {
                            matchLog += matchingLog(null, matchContacts, 'Multiple matches found using Salesforce Duplicate Rule <em>' + mWrapper.matchingMethod.replaceAll('_', ' ') + '</em>, Most recently modified Contact was selected based on "Contact Matching Multiple Match Behavior" field value on Summit Events object', '', true);
                            interaction.Contact__c = matchContacts[0].Id;
                        }
                    }
                    //   interaction.Matching_Log__c = matchLog;
                }

            }
        }
    }

    private static String matchingLog(Interaction__c interaction, List<Contact> foundContacts, String heading1, String heading2, Boolean isNew) {
        String mOut = '';
        if (String.isNotBlank(heading1)) {
            mOut += '<div class="slds-text-heading_small slds-m-vertical_medium">' + heading1 + '</div>';
        }
        if (String.isNotBlank(heading2)) {
            mOut += '<div class="slds-text-heading_small slds-m-vertical_medium">' + heading2 + '</div>';
        }
        if (interaction != null || foundContacts.size() > 0) {
            mOut += '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1">';
            mOut += '<thead><tr class="slds-line-height_reset">';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Email">Email</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Zip">Zip</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Action">Action</div></th>';
            mOut += '</tr></thead>';
            mOut += '<tbody>';
            if (interaction != null) {
                mOut += matchingRow(interaction.Id, interaction.Last_Name__c, interaction.First_Name__c, interaction.Email__c, interaction.Mailing_Postal_Code__c, (isNew ? 'Created' : 'Matched'));
            }
            Boolean isFirst = isNew;
            for (Contact con : foundContacts) {
                mOut += matchingRow(con.Id, con.LastName, con.FirstName, con.Email, con.MailingPostalCode, isFirst ? 'Selected' : 'Skipped');
                isFirst = false;
            }
            mOut += '</tbody></table>';
        }
        return mOut;
    }

    private static String matchingRow(String ContactId, String LastName, String FirstName, String Email, String Zip, String Action) {
        String matchRow = '';
        matchRow += '<tr class="slds-hint-parent">';
        matchRow += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + LastName + '</a></div></td>';
        matchRow += '<td data-label="First Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + FirstName + '</a></div></td>';
        matchRow += '<td data-label="Email"><div class="slds-truncate">' + (String.isNotBlank(Email) ? Email : '') + '</div></td>';
        matchRow += '<td data-label="Zip"><div class="slds-truncate">' + (String.isNotBlank(Zip) ? Zip : '') + '</div></td>';
        matchRow += '<td data-label="Action"><div class="slds-truncate"> ' + (String.isNotBlank(Action) ? Action : '') + ' </div></td>';
        matchRow += '</tr>';
        return matchRow;
    }

    private static Contact makeContact(Interaction__c interaction, String matchingMethod) {
        Contact c = new Contact();
        c.FirstName = interaction.First_Name__c;
        c.LastName = interaction.Last_Name__c;
        c.Email = interaction.Email__c;
        c.Birthdate = interaction.Birthdate__c;

        c.MailingStreet = interaction.Mailing_Street__c;
        c.MailingCity = interaction.Mailing_City__c;
        c.MailingState = interaction.Mailing_State__c;
        c.MailingPostalCode = interaction.Mailing_Postal_Code__c;
        c.MailingCountry = interaction.Mailing_Country__c;

        c.Phone = interaction.Home_Phone__c;
        c.MobilePhone = interaction.Mobile_Phone__c;

        SObjectType r = ((SObject) (Type.forName('Schema.Contact').newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();

        if (Schema.SObjectType.EASY_Contact_Matching_Mapping__mdt.isAccessible()) {
            for (EASY_Contact_Matching_Mapping__mdt mapping : [
                    SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                    FROM EASY_Contact_Matching_Mapping__mdt
                    WHERE Contact_Matching_Method__c = :matchingMethod
                    AND Source_Object__c = 'Interaction__c'
                    AND Source_Type__c = 'Field'
            ]) {
                Schema.DisplayType fieldType = d.fields.getMap().get(mapping.Contact_Field_API_Name__c).getDescribe().getType();

                if (fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY) {
                    c.put(mapping.Contact_Field_API_Name__c, Double.valueOf(interaction.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                    c.put(mapping.Contact_Field_API_Name__c, Boolean.valueOf(interaction.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.DATE) {
                    c.put(mapping.Contact_Field_API_Name__c, Date.valueOf(interaction.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.DATETIME) {
                    c.put(mapping.Contact_Field_API_Name__c, Datetime.valueOf(interaction.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.INTEGER) {
                    c.put(mapping.Contact_Field_API_Name__c, Integer.valueOf(interaction.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.PERCENT) {
                    c.put(mapping.Contact_Field_API_Name__c, Double.valueOf(interaction.get(mapping.Source_Value__c)) / 100);
                } else {
                    c.put(mapping.Contact_Field_API_Name__c, interaction.get(mapping.Source_Value__c));
                }
            }

            for (EASY_Contact_Matching_Mapping__mdt mapping : [
                    SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                    FROM EASY_Contact_Matching_Mapping__mdt
                    WHERE Contact_Matching_Method__c = :matchingMethod
                    AND Source_Type__c = 'Hardcoded'
            ]) {
                Schema.DisplayType fieldType = d.fields.getMap().get(mapping.Contact_Field_API_Name__c).getDescribe().getType();

                if (fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY) {
                    c.put(mapping.Contact_Field_API_Name__c, Double.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                    c.put(mapping.Contact_Field_API_Name__c, Boolean.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.DATE) {
                    c.put(mapping.Contact_Field_API_Name__c, Date.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.DATETIME) {
                    c.put(mapping.Contact_Field_API_Name__c, Datetime.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.INTEGER) {
                    c.put(mapping.Contact_Field_API_Name__c, Integer.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.PERCENT) {
                    c.put(mapping.Contact_Field_API_Name__c, Double.valueOf(mapping.Source_Value__c) / 100);
                } else {
                    c.put(mapping.Contact_Field_API_Name__c, mapping.Source_Value__c);
                }
            }
        }

        return c;
    }

    private without sharing class doCRUD {

        public List<Contact> findContacts(List<Id> foundIds) {
            List<Contact> contactsFound = [
                    SELECT Id, LastName, FirstName, Email, MailingPostalCode
                    FROM Contact
                    WHERE Id IN :foundIds
                    ORDER BY LastModifiedDate DESC
            ];
            return contactsFound;
        }

        public SObject addRecord(SObject recordToAdd) {
            try {
                upsert recordToAdd;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
            return recordToAdd;
        }

        public List<Datacloud.FindDuplicatesResult> findDuplicateContacts(List<Contact> cons) {
            return Datacloud.FindDuplicates.findDuplicates(cons);
        }

    }
}