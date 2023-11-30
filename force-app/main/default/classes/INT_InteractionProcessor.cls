/*****************************************
* File: INT_InteractionProcessor
* Author: Sierra-Cedar
* Description: Processes new Interaction__c records by inserting/converting Leads, upserting Opportunities,
* updating Contacts, upserting Affiliations, and upserting CampaignMembers
 *
******************************************/
public class INT_InteractionProcessor {
    private final List<Interaction__c> dupeInteractions = new List<Interaction__c>();
    private final List<Lead> leadsToDelete = new List<Lead>();
    private final List<Opportunity> opportunitiesToUpsert = new List<Opportunity>();
    final Map<String, Id> oppKeyToContactMap = new Map<String, Id>();
    private final Map<Id, Lead> interactionIdToLead = new Map<Id, Lead>();
    private Map<Id, Interaction__c> interactionMap = new Map<Id, Interaction__c>();
    private final Map<Id, Interaction__c> leadIdToInteractionMap = new Map<Id, Interaction__c>();
    private final Set<Id> contactIds = new Set<Id>();
    private final Set<Id> existingLeadIds = new Set<Id>();

    private INT_InteractionMappingService intMappingService {
        get {
            if (intMappingService == null) {
                intMappingService = new INT_InteractionMappingService();
            }

            return intMappingService;
        }

        set;
    }

    private Map<String, Id> campaignIdMap {
        get {
            if (campaignIdMap == null) {
                campaignIdMap = new Map<String, Id>();
                Set<String> referenceIds = new Set<String>();

                for (SObject interaction : Trigger.new) {
                    if (interaction.get('Campaign_Key__c') != null) {
                        referenceIds.add(String.valueOf(interaction.get('Campaign_Key__c')));
                    }

                    if (interaction.get('Additional_Campaign_Key__c') != null) {
                        referenceIds.add(String.valueOf(interaction.get('Additional_Campaign_Key__c')));
                    }
                }

                for (Campaign aCampaign : [
                        SELECT Id, Campaign_Key__c
                        FROM Campaign
                        WHERE (Campaign_Key__c IN :referenceIds OR Id IN :referenceIds)
                ]) {
                    campaignIdMap.put(aCampaign.Campaign_Key__c, aCampaign.Id);
                }
            }

            return campaignIdMap;
        }

        set;
    }

    private Map<String, CampaignMember> campaignMemberMap {
        get {
            if (campaignMemberMap == null) {
                campaignMemberMap = new Map<String, CampaignMember>();
                List<Interaction_Mapping__c> interactionMappings = intMappingService.intMappingMap.get('CampaignMember');
                List<String> additionalFields = new List<String>{
                        ', Campaign.Campaign_Key__c', ', Lead_Contact_ID__c', ', CampaignId'
                };
                List<CampaignMember> campaignMembers = (List<CampaignMember>) queryForSObjectMappedFields(interactionMappings, 'CampaignMember', contactIds, additionalFields, 'WHERE ContactId IN :SObjectIds');
                System.debug('&&& campaignMembers: ' + campaignMembers);
                // Loop through current Campaign Members and build campaignMemberMap
                for (CampaignMember cm : campaignMembers) {
                    if (!String.isEmpty(cm.Campaign.Campaign_Key__c)) {
                        campaignMemberMap.put(String.valueOf(cm.Lead_Contact_ID__c + '.' + cm.Campaign.Campaign_Key__c), cm);
                    } else {
                        campaignMemberMap.put(String.valueOf(cm.Lead_Contact_ID__c + '.' + cm.CampaignId), cm);
                    }
                }
            }

            return campaignMemberMap;
        }

        set;
    }

    // Grab Lead conversion master label.
    private LeadStatus convertStatus {
        get {
            if (convertStatus == null) {
                convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
            }

            return convertStatus;
        }

        set;
    }

    // Populate a Map of Existing Leads to map fields to new Interactions.
    private Map<Id, Lead> existingLeadMap {
        get {
            if (existingLeadMap == null
                    && !existingLeadIds.isEmpty()
                    && intMappingService.intMappingMap != null
                    && intMappingService.intMappingMap.containsKey('Interaction__c')
            ) {
                String soqlString = 'SELECT Id';

                for (Interaction_Mapping__c mapping : intMappingService.intMappingMap.get('Interaction__c')) {
                    soqlString += ', ' + mapping.Source_Field_API_Name__c;
                }

                soqlString = soqlString.removeEnd(',').trim();
                soqlString += ' FROM Lead WHERE Id IN :existingLeadIds';
                existingLeadMap = new Map<Id, Lead>((List<Lead>) Database.query(soqlString));
            } else if (existingLeadMap == null) {
                existingLeadMap = new Map<Id, Lead>();
            }

            return existingLeadMap;
        }

        set;
    }

    private Map<String, OpportunityStage> oppStageMap {
        get {
            List<OpportunityStage> stages = [SELECT ApiName, DefaultProbability, ForecastCategoryName FROM OpportunityStage];
            Map<String, OpportunityStage> oppStageMap = new Map<String, OpportunityStage>();
            for (OpportunityStage stage : stages) {
                oppStageMap.put(stage.ApiName, stage);
            }
            return oppStageMap;
        }
        set;
    }

    /*
     * @description Inserts Leads only from new Interaction__c records.
     * @param interactionsToProcess, the List of new Interaction__c objects to process.
     */
    public void processLeads(List<Interaction__c> newInteractions) {
        // Run duplicate pre-processing
        List<Interaction__c> interactionsToProcess = duplicatePreProcessing(newInteractions);

        // Set up Interaction Map for reference during processing.
        interactionMap = new Map<Id, Interaction__c>(interactionsToProcess);

        // Insert Leads from the new Interaction records.
        List<Database.LeadConvert> newLeads = insertLeadsFromInteractions(interactionsToProcess);

        // Apply Interaction Mappings to all Leads
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Interaction_Mapping__c> interactionMappings = intMappingService.intMappingMap.get('Lead');
        System.debug('&&& leadIdToInteractionMap: ' + leadIdToInteractionMap);
        List<Lead> leadsMappedFields = (List<Lead>) queryForSObjectMappedFields(interactionMappings, 'Lead', leadIdToInteractionMap.keySet(), new List<String>(), 'WHERE Id IN :SObjectIds');
        System.debug('&&& leadsMappedFields: ' + leadsMappedFields);
        for (Lead leadToUpdate : leadsMappedFields) {
            intMappingService.applyDataToSObject(leadIdToInteractionMap.get(leadToUpdate.Id), leadToUpdate);
            leadsToUpdate.add(leadToUpdate);
        }

        // Update Leads with data from the mapping service.
        if (leadsToUpdate.size() > 0) {
            logPossibleErrors(Database.update(leadsToUpdate, false));
        }

        // Create CampaignMembers to upsert from the Leads inserted if they have the proper Campaign Keys
        List<CampaignMember> campaignMembersToUpsert = createCampaignMembersFromLeads(true);

        // Upsert Campaign Members from Leads
        if (campaignMembersToUpsert.size() > 0) {
            logPossibleErrors(Database.upsert(campaignMembersToUpsert, CampaignMember.Campaign_Member_Key__c, false));
        }

        // Finally set Interaction_Status__c after processing and flag if errored.
        for (Interaction__c interaction : interactionsToProcess) {
            interaction.Interaction_Status__c = (!String.isEmpty(interaction.Audit_Reason__c)) ? 'Audit Required' : 'Imported';
        }

        // Add any duplicates found and update the Interactions with new Status from processing.
        interactionsToProcess.addAll(dupeInteractions);
        logPossibleErrors(Database.update(interactionsToProcess, false));
    }

    /*
     * @description Main method for processing new Interaction__c records.
     * @param interactionsToProcess, the List of new Interaction__c objects to process.
     */
    public void processInteractions(List<Interaction__c> newInteractions) {
        List<Contact> contactsToUpdate = new List<Contact>();
        List<hed__Affiliation__c> affiliationsToUpsert = new List<hed__Affiliation__c>();

        // Run duplicate pre-processing
        List<Interaction__c> interactionsToProcess = duplicatePreProcessing(newInteractions);
        System.debug('&&& interactionsToProcess: ' + interactionsToProcess);

        // Set up Interaction Map for reference during processing.
        interactionMap = new Map<Id, Interaction__c>(interactionsToProcess);

        // Create Leads from new Interactions records.
        List<Database.LeadConvert> newLeads = insertLeadsFromInteractions(interactionsToProcess);
        System.debug('&&& newLeads: ' + newLeads);

        // Attempt initial conversion of leads.
        List<Database.LeadConvert> possibleLeadsToReconvert = convertLeads(newLeads);
        System.debug('&&& possibleLeadsToReconvert: ' + possibleLeadsToReconvert);

        // Reconvert Leads with matched Contacts if duplicate errors.
        if (possibleLeadsToReconvert.size() > 0) {
            convertLeads(possibleLeadsToReconvert);
        }

        // Create CampaignMembers to upsert from the Leads inserted if they have the proper Campaign Keys
        List<CampaignMember> campaignMembersToUpsert = createCampaignMembersFromLeads(false);

        // Upsert Campaign Members from Leads
        if (campaignMembersToUpsert.size() > 0) {
            logPossibleErrors(Database.upsert(campaignMembersToUpsert, CampaignMember.Campaign_Member_Key__c, false));
        }

        // Upsert associated Opportunities using Opportunity_Key__c as the lookup Id.
        System.debug('&&& opportunitiesToUpsert: ' + opportunitiesToUpsert);
        if (opportunitiesToUpsert.size() > 0) {
            logPossibleErrors(Database.upsert(opportunitiesToUpsert, false));
        }

        Set<Id> contactIdsToQuery = new Set<Id>();
        for (Interaction__c interactionToProcess : interactionsToProcess) {
            if (!String.isEmpty(interactionToProcess.Contact__c)) {
                contactIdsToQuery.add(interactionToProcess.Contact__c);
            }
        }
        List<Interaction_Mapping__c> interactionMappings = intMappingService.intMappingMap.get('Contact');
        Map<Id, Contact> contactMappedFields = new Map<Id, Contact>((List<Contact>) queryForSObjectMappedFields(interactionMappings, 'Contact', contactIdsToQuery, new List<String>(), 'WHERE Id IN :SObjectIds'));
        System.debug('&&& contactMappedFields: ' + contactMappedFields);

        List<OpportunityContactRole> oppContactRolestoInsert = new List<OpportunityContactRole>();
        for (Opportunity opp : opportunitiesToUpsert) {
            if (oppKeyToContactMap.get(opp.Opportunity_Key__c) != null) {
                Id contactId = oppKeyToContactMap.get(opp.Opportunity_Key__c);
                OpportunityContactRole oppContactRole = new OpportunityContactRole(ContactId = contactId, OpportunityId = opp.Id, Role = 'Opportunity Contact', IsPrimary = true);
                oppContactRolestoInsert.add(oppContactRole);
            }
        }
        if (oppContactRolestoInsert.size() > 0) {
            insert oppContactRolestoInsert;
        }

        // Finally, associate referenced Opportunity and set Interaction_Status__c after processing and flag if errored.
        for (Interaction__c interaction : interactionsToProcess) {
            if (!String.isEmpty(interaction.Contact__c)) {
                Contact newCont = contactMappedFields.get(interaction.Contact__c);
                if (newCont != null) {
                    intMappingService.applyDataToSObject(interaction, newCont);
                    contactsToUpdate.add(newCont);
                }
            }

            if (interaction.Affiliation_Key__c != null) {
                affiliationsToUpsert.add(createUpsertAffilFromInteraction(interaction));
            }

            // Set the new referenced Opportunity's Id on the Interaction__c lookup field.
            if (interaction.Opportunity__r != null) {
                interaction.Opportunity__c = interaction.Opportunity__r.Id;
                interaction.Opportunity__r = null;
            }

            // Check for Interactions that have Opportunity Keys, but no Opportunity associated, flag them.
            if ((interaction.Opportunity_Key__c != null) && (interaction.Opportunity__c == null)) {
                String error = ' Reason: Interaction has an Opportunity Key, but could not find ' +
                        'associated Opportunity in the system. Please verify that the Opportunity Key is valid.';
                interaction.Audit_Reason__c += error;
            }

            interaction.Interaction_Status__c = (!String.isEmpty(interaction.Audit_Reason__c)) ? 'Audit Required' : 'Imported';
        }

        // Update Contacts
        if (contactsToUpdate.size() > 0) {
            logPossibleErrors(Database.update(contactsToUpdate, false));
        }

        // Upsert Affiliations using the Upsert_Key__c
        if (affiliationsToUpsert.size() > 0) {
            logPossibleErrors(Database.upsert(affiliationsToUpsert, hed__Affiliation__c.Upsert_Key__c, false));
        }

        // Add any duplicates found and update the Interactions with new Status from processing.
        interactionsToProcess.addAll(dupeInteractions);
        logPossibleErrors(Database.update(interactionsToProcess, false));

        // Cleanup converted Leads.
        System.debug('&&& leadsToDelete: ' + leadsToDelete);
        if (leadsToDelete.size() > 0) {
            Database.delete(leadsToDelete, false);
        }
    }

    /**
     * @description Does basic pre-processing for duplicates of the Interactions in the import. If it finds a possible
     * duplicate, it removes it from the import and flags it for future processing.
     * @param interactions, the List of new Interaction__c records.
     * @return the List of filtered Interaction__c records for processing.
     */
    private List<Interaction__c> duplicatePreProcessing(List<Interaction__c> interactions) {
        // If the custom setting is turned off, return the List and do not run any pre-processing for duplicates.
        System.debug('duplicate processing happening');
        System.debug(Interactions_PreProcessing__c.getAll().values());
        if (Interactions_PreProcessing__c.getAll().values() != null) {
            for (Interactions_PreProcessing__c ipp : Interactions_PreProcessing__c.getAll().values()) {
                System.debug(ipp);
                if (!ipp.Active__c) {
                    System.debug('Interaction skipped');
                    return interactions;
                }
            }
        }
        System.debug('Interaction active');

        Map<String, Interaction__c> filteredMap = new Map<String, Interaction__c>();

        for (Interaction__c interaction : interactions) {
            String filterKey = interaction.First_Name__c + interaction.Last_Name__c + interaction.Email__c;

            if (!filteredMap.containsKey(filterKey)) {
                filteredMap.put(filterKey, interaction);
            } else {
                System.debug('filterKey: ' + filterKey + ', interaction: ' + JSON.serializePretty(interaction));
                interaction.Interaction_Status__c = 'Audit Required';
                String error = ' Reason: this Interaction was not processed because it is a possible ' +
                        'duplicate of - ' + filteredMap.get(filterKey).Id + ': ' + filteredMap.get(filterKey).First_Name__c +
                        ' ' + filteredMap.get(filterKey).Last_Name__c + ' ' + filteredMap.get(filterKey).Email__c;
                interaction.Audit_Reason__c = error;
                dupeInteractions.add(interaction);
            }
        }

        return filteredMap.values();
    }

    /**
     * @description Kick off the Interactions process by creating Leads to convert.
     * @param interactions, the list of new Interaction__c objects to insert Leads from.
     * @return leadConverts, the Lead Convert records to convert.
     */
    private List<Database.LeadConvert> insertLeadsFromInteractions(List<Interaction__c> interactions) {
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        List<Contact> newCons = new List<Contact>();

        // Associate Campaigns and create new Leads from Interaction records.
        for (Interaction__c interaction : interactions) {
            // Set Campaign__c on Interaction
            if (!String.isEmpty(interaction.Campaign_Key__c)
                    && campaignIdMap.containsKey(interaction.Campaign_Key__c)
            ) {
                interaction.Campaign__c = campaignIdMap.get(interaction.Campaign_Key__c);
            }

            // Set Additional_Campaign__c on Interaction.
            if (!String.isEmpty(interaction.Additional_Campaign_Key__c)
                    && campaignIdMap.containsKey(interaction.Additional_Campaign_Key__c)
            ) {
                interaction.Additional_Campaign__c = campaignIdMap.get(interaction.Additional_Campaign_Key__c);
            }

            Lead newLead = new Lead(
                    FirstName = interaction.First_Name__c,
                    LastName = interaction.Last_Name__c,
                    Company = interaction.Last_Name__c + ', ' + interaction.First_Name__c,
                    OwnerId = interaction.OwnerId
            );

            interactionIdToLead.put(interaction.Id, newLead);
            intMappingService.applyDataToSObject(interaction, newLead);

            Contact newCon = new Contact(
                    FirstName = newLead.FirstName,
                    LastName = newLead.LastName,
                    MailingStreet = newLead.Street,
                    MailingCity = newLead.City,
                    MailingState = newLead.State,
                    MailingCountry = newLead.Country,
                    MailingPostalCode = newLead.PostalCode,
                    Email = newLead.Email,
                    Fax = newLead.Fax,
                    MobilePhone = newLead.MobilePhone,
                    Phone = newLead.Phone,
                    Title = newLead.Title
            );

            intMappingService.applyDataToSObject(interaction, newCon);
            newCons.add(newCon);
        }

        // Break list into list of lists with maximum size of 50 because of duplicate find limits
        List<List<Contact>> newConsList = new List<List<Contact>>{
                new List<Contact>()
        };
        for (Contact c : newCons) {
            if (newConsList[newConsList.size() - 1].size() == 50) {
                newConsList.add(new List<Contact>());
            }
            newConsList[newConsList.size() - 1].add(c);
        }

        // Look for duplicates and add ID if one exists
        Integer interactionsIndex = 0;
        for (List<Contact> cons : newConsList) {

            List<Datacloud.FindDuplicatesResult> results = Datacloud.FindDuplicates.findDuplicates(cons);

            for (Integer i = 0; i < cons.size(); i++) {
                if (interactions[interactionsIndex].Lead_Only__c == false) {
                    for (Datacloud.DuplicateResult result : results[i].getDuplicateResults()) {
                        for (Datacloud.MatchResult matchResult : result.getMatchResults()) {
                            if (matchResult.getEntityType() == 'Contact' && !matchResult.getMatchRecords().isEmpty()) {
                                interactions[interactionsIndex].Contact__c = matchResult.getMatchRecords()[0].getRecord().Id;
                                break;
                            }
                        }

                        if (interactions[interactionsIndex].Contact__c != null) {
                            break;
                        }
                    }
                }

                interactionsIndex++;
            }
        }

        leadConverts.addAll(insertLeads(interactionIdToLead.values(), interactions));

        return leadConverts;
    }

    /*
     * @description Inserts a collection of Leads. If there are failures, log issues to Interaction Audit Status.
     * @param leads, a List of Lead objects to insert.
     * @return leadsToConvert, a List of Database.LeadConvert records to convert.
     */
    private List<Database.LeadConvert> insertLeads(List<Lead> leadsToInsert, List<Interaction__c> interactions) {
        Integer leadIndex = 0;
        Database.SaveResult[] srlist = Database.insert(leadsToInsert, false); // Insert Leads
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();

        for (Database.SaveResult sr : srlist) {
            Interaction__c interaction = interactions[leadIndex];

            if (sr.isSuccess()) { // Check if insert was a success
                // On success, prepare to convert inserted lead.
                Id leadId = sr.getId();
                leadsToConvert.add(createLeadConvert(interactionMap.get(interaction.Id), leadId, true));
                interaction.Lead__c = leadId; // Copy new Lead Id to the Interaction__c record.
                if (!interaction.Lead_Only__c) leadsToDelete.add(new Lead(Id = leadId)); // Newly created leads will be deleted
            } else {
                /**
                 * If there are errors, loop through them and either log the error on the Interaction.
                 * or see if there's a duplicate and use that instead.
                 */
                for (Database.Error error : sr.getErrors()) {
                    if (error.getStatusCode() == StatusCode.DUPLICATES_DETECTED) {
                        Database.DuplicateError dupErrorError = (Database.DuplicateError) error;

                        for (Datacloud.MatchResult matchResult : dupErrorError.getDuplicateResult().getMatchResults()) {
                            for (Datacloud.MatchRecord match : matchResult.getMatchRecords()) {
                                // Grab matched record to use instead of the new one.
                                interaction.Lead__c = match.getRecord().Id;

                                // Add existing Lead Ids to List to query for data to copy to the Interaction later.
                                existingLeadIds.add(match.getRecord().Id);

                                if (interaction.Lead_Only__c == true) {
                                    leadIdToInteractionMap.put(interaction.Lead__c, interaction);
                                } else {
                                    // The matched Lead doesn't exist in the current transaction, so add it to List to convert.
                                    if (leadIdToInteractionMap.get(match.getRecord().Id) == null) {
                                        leadsToConvert.add(createLeadConvert(interaction, match.getRecord().Id, true));
                                    }
                                }
                            }
                        }
                    } else { // Catch-all for all other errors
                        interaction.Audit_Reason__c += ' Reason: Error during Lead insert - ' + error.getMessage() + '.';
                        System.debug('Error during Lead insert - ' + error.getMessage() + '.');
                    }
                }
            }

            leadIndex++;
        }

        return leadsToConvert;
    }

    /*
     * @description Creates a Database.LeadConvert Object from supplied Interaction record.
     * @param interaction, the Interaction__c to create Database.LeadConvert from.
     * @param leadId, the Id of the Lead to convert.
     * @param createOppty, whether or not to create an Opportunity from the Database.LeadConvert.
     */
    private Database.LeadConvert createLeadConvert(Interaction__c interaction, String leadId, Boolean createOppty) {
        // Prepare to convert matching lead
        leadIdToInteractionMap.put(leadId, interaction);
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(leadId);
        leadConvert.setConvertedStatus(convertStatus.MasterLabel);
        leadConvert.setContactId(interaction.Contact__c);
        leadConvert.setAccountId(interaction.Contact_Account_ID__c);
        leadConvert.setDoNotCreateOpportunity(createOppty);

        return leadConvert;
    }

    /**
     * @description Converts Leads, returns any Database.LeadConvert errors found to be reconverted later.
     * @param leadsToConvert, the List of Lead records to convert.
     * @return leadsToReconvert, a List of possible Database.LeadConvert error records to try and reconvert.
     */
    private List<Database.LeadConvert> convertLeads(List<Database.LeadConvert> leadsToConvert) {
        List<Database.LeadConvert> leadsToReconvert = new List<Database.LeadConvert>();

        // Get set of all lead converts where contact has been specified but not account
        Set<Id> contactIdsMissingAccount = new Set<Id>();
        for (Database.LeadConvert lc : leadsToConvert) {
            if (lc.getContactId() != null && lc.getAccountId() == null) {
                contactIdsMissingAccount.add(lc.getContactId());
            }
        }

        // Query for contact's account and set it on lead convert
        if (!contactIdsMissingAccount.isEmpty()) {
            Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :contactIdsMissingAccount]);
            for (Database.LeadConvert lc : leadsToConvert) {
                if (lc.getContactId() != null && lc.getAccountId() == null && contacts.containsKey(lc.getContactId())) {
                    lc.setAccountId(contacts.get(lc.getContactId()).AccountId);
                }
            }
        }

        Database.LeadConvertResult[] leadConvertResults = Database.convertLead(leadsToConvert, false); // Convert Leads

        List<Map<Id, String>> termsAndPrograms = getTermsAndProgramNames(leadConvertResults);
        Map<Id, String> leadIdToTermNameMap = termsAndPrograms[0];
        Map<Id, String> leadIdToProgramNameMap = termsAndPrograms[1];
        Map<String, List<Opportunity>> contactOppMap = getContactsOpportunities(leadConvertResults);
        System.debug('&&& leadConvertResults: ' + leadConvertResults);

        for (Database.LeadConvertResult lcr : leadConvertResults) {
            Interaction__c interaction = (leadIdToInteractionMap.containsKey(lcr.getLeadId())) ? leadIdToInteractionMap.get(lcr.getLeadId()) : null;

            if (lcr.isSuccess()) {
                // Add Contact Id to set to be updated from its Interaction record.
                interaction.Contact__c = lcr.getContactId();
                String contactLastName = interaction.Contact__r.lastName;
                String txtTermName = interaction.Start_Term_ERX__c;
                String intendTermName = interaction.Intended_Start_Term__r.Name;
                String hedTermName = interaction.Term__r.Name;

                contactIds.add(lcr.getContactId());

                // If we had an existing Lead in SF, copy the values to the Interaction based upon the custom mdt.
                if (existingLeadMap.containsKey(lcr.getLeadId())) {
                    intMappingService.applyDataToInteraction(existingLeadMap.get(lcr.getLeadId()), interaction);
                }

                // Create new Opportunity for upsert if Opportunity Key is populated.
                System.debug('&&& interaction: ' + interaction);
                System.debug(' && !String.isEmpty(interaction.Opportunity_Key__c): ' + !String.isEmpty(interaction.Opportunity_Key__c));
                if (!String.isEmpty(interaction.Opportunity_Key__c)) {
                    String lastName = interaction.Last_Name__c;
                    String lastNameCleaned = lastName.replaceAll('\'', '');
                    String termName = '';
                    String programName = '';
                    if (leadIdToTermNameMap.get(lcr.getLeadId()) != null) {
                        termName = leadIdToTermNameMap.get(lcr.getLeadId());
                    }
                    if (leadIdToProgramNameMap.get(lcr.getLeadId()) != null) {
                        programName = leadIdToProgramNameMap.get(lcr.getLeadId());
                    }

                    List<Opportunity> matchingOpps = new List<Opportunity>();
                    // check for matching opportunitiesc
                    if (contactOppMap.get(interaction.Contact__c) != null) {
                        Pattern matchingPattern;
                        if (!String.isBlank(termName) && !String.isBlank(programName)) {
                            // matches: any opps without program and term information, or opportunities with exact program and term
                            matchingPattern = Pattern.compile('(?i)^(?:' + lastNameCleaned + ')\\|(?:' + termName + ')*\\|(?:' + programName + ')*$');
                        } else if (String.isBlank(termName) && !String.isBlank(programName)) {
                            // matches: any opportunities without program information, or opportunities with exact program
                            matchingPattern = Pattern.compile('(?i)^(?:' + lastNameCleaned + ')\\|.*\\|(?:' + programName + ')*$');
                        } else if (!String.isBlank(termName) && String.isBlank(programName)) {
                            // matches: any opportunities without term information, or opportunities  with exact term
                            matchingPattern = Pattern.compile('(?i)^(?:' + lastNameCleaned + ')\\|(?:' + termName + ')*\\|.*$');
                        } else if (String.isBlank(termName) && String.isBlank(programName)) {
                            // matches: any opportunities with or without term or program information
                            matchingPattern = Pattern.compile('(?i)^(?:' + lastNameCleaned + ')\\|.*\\|.*$');
                        }

                        System.debug('Matching Pattern: ' + matchingPattern);
                        for (Opportunity opp : contactOppMap.get(interaction.Contact__c)) {
                            System.debug('Cleaned Opportunity Name: ' + opp.Name.replaceAll('\'', ''));
                            Matcher oppMatch = matchingPattern.matcher(opp.Name.replaceAll('\'', ''));
                            System.debug('Matched: ' + oppMatch.matches());
                            if (oppMatch.matches()) {
                                if (matchingOpps.size() > 0) {
                                    if (matchingOpps[0].Probability < opp.Probability) {
                                        matchingOpps[0] = opp;
                                    }
                                } else {
                                    matchingOpps.add(opp);
                                }
                            }
                        }
                    }

                    System.debug(JSON.serializePretty(matchingOpps));

                    if (matchingOpps.isEmpty()) {
                        Opportunity newOppty = new Opportunity();
                        intMappingService.applyDataToSObject(interaction, newOppty);
                        System.debug('&&& newOppty: ' + newOppty);
                        newOppty.CloseDate = System.today();
                        newOppty.StageName = interaction.Opportunity_Stage__c;
                        newOppty.Opportunity_Key__c = lcr.getContactId() + interaction.Opportunity_Key__c;
                        newOppty.AccountId = lcr.getAccountId();
                        newOppty.Name = determineOpportunityName('', lastName, termName, programName, contactLastName, txtTermName, intendTermName, hedTermName);
                        interaction.Opportunity__r = newOppty;
                        opportunitiesToUpsert.add(newOppty);
                        oppKeyToContactMap.put(newOppty.Opportunity_Key__c, interaction.Contact__c);
                    } else {
                        for (Opportunity matchingOpp : matchingOpps) {
                            String oppName = matchingOpp.Name;
                            String oppStageName = determineOpportunityStage(interaction.Opportunity_Stage__c, matchingOpp.StageName);
                            Id inqoppRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Inquiry Opportunity').getRecordTypeId();
                            Id appoppRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Applicant Opportunity').getRecordTypeId();

                            List<String> inqOppStageList = new List<String>();
                            inqOppStageList.add('Suspect');
                            inqOppStageList.add('Moderately Suspect');
                            inqOppStageList.add('Inquiry');
                            inqOppStageList.add('Engaged');
                            inqOppStageList.add('No Longer Interested');

                            matchingOpp.CloseDate = System.today();
                            // matchingOpp.StageName = determineOpportunityStage(interaction.Opportunity_Stage__c, matchingOpp.StageName);
                            matchingOpp.StageName = oppStageName;
                            matchingOpp.AccountId = lcr.getAccountId();
                            matchingOpp.Name = determineOpportunityName(oppName, lastName, termName, programName, contactLastName, txtTermName, intendTermName, hedTermName);
                            interaction.Opportunity_Stage__c = matchingOpp.StageName;
                            interaction.Opportunity__r = matchingOpp;
                            //interaction.Opportunity_Record_Type__c = matchingOpp.RecordTypeId;

                            if (inqOppStageList.contains(oppStageName)) {
                                interaction.Opportunity_Record_Type__c = inqoppRTID;
                            } else {
                                interaction.Opportunity_Record_Type__c = appoppRTID;
                            }

                            intMappingService.applyDataToSObject(interaction, matchingOpp);
                            opportunitiesToUpsert.add(matchingOpp);
                        }
                    }
                }
            } else {
                // Find all of the errors for Lead conversion.
                for (Database.Error error : lcr.getErrors()) {
                    if (error.getStatusCode() == StatusCode.DUPLICATES_DETECTED) {
                        Database.DuplicateError dupError = (Database.DuplicateError) error;

                        for (Datacloud.MatchResult matchResult : dupError.getDuplicateResult().getMatchResults()) {
                            Contact matchedContact;

                            for (Datacloud.MatchRecord match : matchResult.getMatchRecords()) {
                                // We want to use the oldest matched record, it will be the source Contact.
                                Contact compareContact = (Contact) match.getRecord();
                                if (matchedContact == null || (compareContact.CreatedDate < matchedContact.CreatedDate)) {
                                    matchedContact = new Contact();
                                    matchedContact = compareContact;
                                }
                            }

                            // Build new Lead convert with matching records.
                            if (matchedContact != null) { // NPE handling
                                Database.LeadConvert leadConvert = new Database.LeadConvert();
                                leadConvert.setConvertedStatus(convertStatus.MasterLabel);
                                leadConvert.setLeadId(lcr.getLeadId());
                                leadConvert.setContactId(matchedContact.Id);
                                leadConvert.setAccountId(matchedContact.AccountId);
                                leadConvert.setDoNotCreateOpportunity(true);
                                leadsToReconvert.add(leadConvert);
                            }
                        }
                    } else {
                        interaction.Audit_Reason__c += ' Reason: Error during Lead conversion - ' + error.getMessage() + '.';
                        System.debug('Error during Lead conversion - ' + error.getMessage() + '.');
                    }
                }
            }
        }

        return leadsToReconvert;
    }

    private List<Map<Id, String>> getTermsAndProgramNames(Database.LeadConvertResult[] leadConvertResults) {
        // get Term__c and Academic_Program__c ids related to interaction
        Map<Id, Id> leadIdToTermIdMap = new Map<Id, Id>();
        Map<Id, Id> leadIdToProgramIdMap = new Map<Id, Id>();
        for (Database.LeadConvertResult lcr : leadConvertResults) {
            Interaction__c interaction = (leadIdToInteractionMap.containsKey(lcr.getLeadId())) ? leadIdToInteractionMap.get(lcr.getLeadId()) : null;
            if (interaction.Term__c != null) {
                leadIdToTermIdMap.put(lcr.getLeadId(), interaction.Term__c);
            }
            if (interaction.Academic_Program__c != null) {
                leadIdToProgramIdMap.put(lcr.getLeadId(), interaction.Academic_Program__c);
            }
        }

        // get term names related to interactions
        Map<Id, hed__Term__c> terms = new Map<Id, hed__Term__c>([SELECT Id, Name FROM hed__Term__c WHERE Id IN :leadIdToTermIdMap.values()]);
        Map<Id, String> leadIdToTermNameMap = new Map<Id, String>();
        for (Id leadId : leadIdToTermIdMap.keySet()) {
            hed__Term__c term = terms.get(leadIdToTermIdMap.get(leadId));
            leadIdToTermNameMap.put(leadId, term.Name);
        }

        // get academic program names related to interactions
        Map<Id, Program__c> programs = new Map<Id, Program__c>([SELECT Id, Program_Name_on_Application__c FROM Program__c WHERE Id IN :leadIdToProgramIdMap.values()]);
        Map<Id, String> leadIdToProgramNameMap = new Map<Id, String>();
        for (Id leadId : leadIdToProgramIdMap.keySet()) {
            Program__c program = programs.get(leadIdToProgramIdMap.get(leadId));
            leadIdToProgramNameMap.put(leadId, program.Program_Name_on_Application__c);
        }
        List<Map<Id, String>> termsAndPrograms = new List<Map<Id, String>>();
        termsAndPrograms.add(leadIdToTermNameMap);
        termsAndPrograms.add(leadIdToProgramNameMap);
        return termsAndPrograms;
    }

    private Map<String, List<Opportunity>> getContactsOpportunities(Database.LeadConvertResult[] leadConvertResults) {
        // get related opportunities
        Set<Id> contactIds = new Set<Id>();
        for (Database.LeadConvertResult lcr : leadConvertResults) {
            Interaction__c interaction = (leadIdToInteractionMap.containsKey(lcr.getLeadId())) ? leadIdToInteractionMap.get(lcr.getLeadId()) : null;
            String lastName = interaction.Last_Name__c;
            contactIds.add(lcr.getContactId());
        }

        List<Interaction_Mapping__c> interactionMappings = intMappingService.intMappingMap.get('Opportunity');
        List<String> additionalFields = new List<String>{
                ', Name', ', Contact__c', ', Opportunity_Key__c', ', Probability', ', RecordTypeId'
        };
        List<Opportunity> existingOpps = (List<Opportunity>) queryForSObjectMappedFields(interactionMappings, 'Opportunity', contactIds, additionalFields, 'WHERE Contact__c IN :SObjectIds');
        System.debug('&&& existingOpps: ' + existingOpps);

        Map<String, List<Opportunity>> contactOppMap = new Map<String, List<Opportunity>>();
        for (Opportunity opp : existingOpps) {
            if (contactOppMap.get(opp.Contact__c) != null) {
                contactOppMap.get(opp.Contact__c).add(opp);
            } else {
                List<Opportunity> oppList = new List<Opportunity>();
                oppList.add(opp);
                contactOppMap.put(opp.Contact__c, oppList);
            }
        }
        return contactOppMap;
    }

    private String determineOpportunityName(String currentOppName, String lastName, String termName, String programName, String contactLastName, String txtTermName, String intendTermName, String hedTermName) {
        // System.debug('current Opp Name: ' + currentOppName + ', last Name: ' + lastName + ', term Name: ' + termName + ', program Name: ' + programName + ', contact Last Name: ' + contactLastName);

        if (currentOppName != null) {
            List<String> currentOppNameSplit = currentOppName.split('\\|');
            //System.debug('split: ' + currentOppNameSplit);

            //Use contact last name first
            if (String.isNotBlank(contactLastName)) {
                lastName = contactLastName;
            } else if (String.isNotBlank(currentOppNameSplit[0])) {
                lastName = currentOppNameSplit[0];
            }

            //Use Term__c then Intended_Start_Term__c then Start_Term_ERX__c
            if (String.isNotBlank(hedTermName)) {
                termName = hedTermName;
            } else if (String.isNotBlank(intendTermName)) {
                termName = intendTermName;
            } else if (String.isNotBlank(txtTermName)) {
                termName = txtTermName;
            }

            switch on currentOppNameSplit.size() {
                when 2 {
                    //  System.debug('switch 2');
                    if (String.isBlank(termName) && String.isNotBlank(currentOppNameSplit[1])) {
                        termName = currentOppNameSplit[1];
                    }
                    return lastName + '|' + currentOppNameSplit[1] + '|' + programName;
                }
                when 3 {
                    // System.debug('switch 3');
                    if (String.isBlank(termName) && String.isNotBlank(currentOppNameSplit[1])) {
                        termName = currentOppNameSplit[1];
                    }
                    if (String.isBlank(programName) && String.isNotBlank(currentOppNameSplit[2])) {
                        programName = currentOppNameSplit[2];
                    }

                    //return lastName + '|' + termName + '|' + programName;
//                    if (String.isEmpty(currentOppNameSplit[1])) {
//                        return lastName + '|' + termName + '|' + programName;
//                    } else {
//                        return currentOppName;
//                    }
                }
            }
        }
        String newOpportunityName = lastName + '|' + termName + '|' + programName;
        System.debug(newOpportunityName);
        return newOpportunityName;

    }

    private String determineOpportunityStage(String newStageName, String previousStageName) {
        OpportunityStage newStage = oppStageMap.get(newStageName);
        OpportunityStage previousStage = oppStageMap.get(previousStageName);
        System.debug('new stage (' + newStageName + '): ' + newStage.DefaultProbability + ', previous stage: (' + previousStageName + '): ' + previousStage.DefaultProbability);
        if (newStage.DefaultProbability >= previousStage.DefaultProbability) {
            System.debug('new stage assigned');
            return newStageName;
        } else if (newStage.ForecastCategoryName == 'Omitted') {
            System.debug('new stage assigned');
            return newStageName;
        } else {
            System.debug('previous stage assigned');
            return previousStageName;
        }
    }


    private static List<SObject> queryForSObjectMappedFields(List<Interaction_Mapping__c> interactionMappings, String SObjectName, Set<Id> SObjectIds, List<String> additionalFields, String whereClause) {
        String queryString = 'SELECT Id, ';
        if (interactionMappings != null) {
            for (Interaction_Mapping__c interactionMapping : interactionMappings) {
                if (interactionMapping != null && interactionMapping.Target_Field_API_Name__c != null) {
                    queryString += interactionMapping.Target_Field_API_Name__c + ', ';
                }
            }
        }
        queryString = queryString.removeEnd(', ');
        if (!additionalFields.isEmpty()) {
            for (String field : additionalFields) {
                if (!queryString.contains(field)) {
                    queryString += field;
                }
            }
        }
        queryString += ' FROM ' + SObjectName + ' ' + whereClause;
        return Database.query(queryString);
    }

    /**
     * @description Creates a new Affiliation record for upsert from the data on the Interaction__c. provided.
     * @param interaction, the Interaction__c record to copy data from.
     * @return newAffil, the Affiliation__c record for upsert.
     */
    private hed__Affiliation__c createUpsertAffilFromInteraction(Interaction__c interaction) {
        hed__Affiliation__c newAffil = new hed__Affiliation__c();

        intMappingService.applyDataToSObject(interaction, newAffil);
        newAffil.Upsert_Key__c = interaction.Contact__c + interaction.Affiliation_Key__c;

        return newAffil;
    }

    /**
     * @description Creates a List of CampaignMember records to upsert from the Leads that have been inserted.
     * @return campaignMembersToUpsert, the List of CampaignMember records to upsert.
     */
    private List<CampaignMember> createCampaignMembersFromLeads(Boolean leadOnly) {
        List<CampaignMember> campaignMembersToUpsert = new List<CampaignMember>();

        for (String leadId : leadIdToInteractionMap.keySet()) {
            if (!String.isEmpty(leadIdToInteractionMap.get(leadId).Campaign_Member_Status__c)
                    && !String.isEmpty(leadIdToInteractionMap.get(leadId).Campaign_Key__c)
            ) {
                campaignMembersToUpsert.add(createUpsertCMFromInteraction(leadIdToInteractionMap.get(leadId), false, leadOnly));
            }

            // Create a CampaignMember to Upsert for the Additional_Campaign_Key__c if it is populated.
            if (!String.isEmpty(leadIdToInteractionMap.get(leadId).Additional_Campaign_Key__c)
                    && !String.isEmpty(leadIdToInteractionMap.get(leadId).Additional_Campaign_Member_Status__c)
                    && !String.isEmpty(leadIdToInteractionMap.get(leadId).Lead__c)
            ) {
                campaignMembersToUpsert.add(createUpsertCMFromInteraction(leadIdToInteractionMap.get(leadId), true, leadOnly));
            }
        }

        return campaignMembersToUpsert;
    }

    /*
     * @description Creates a new CampaignMember record for upsert from the data on the Interaction__c provided.
     * @param interaction, the Interaction__c record to copy data from.
     * @param additionalCampaign, a bool telling the method to use Campaign or Additional Campaign fields on the Interaction__c.
     * @return memberToUpsert, the CampaignMember to upsert.
     */
    private CampaignMember createUpsertCMFromInteraction(Interaction__c interaction, Boolean additionalCampaign, Boolean leadOnly) {
        CampaignMember memberToUpsert;
        String leadOrContactId = (leadOnly) ? interaction.Lead__c : interaction.Contact__c;
        String campaignKey = (!additionalCampaign) ? interaction.Campaign_Key__c : interaction.Additional_Campaign_Key__c;
        String campaignMemberStatus = (!additionalCampaign) ? interaction.Campaign_Member_Status__c : interaction.Additional_Campaign_Member_Status__c;
        String campaignMemberKey = String.valueOf(leadOrContactId + '.' + campaignKey);

        if (campaignMemberMap.containsKey(campaignMemberKey)) {
            memberToUpsert = campaignMemberMap.get(campaignMemberKey);
            memberToUpsert.Campaign_Member_Key__c = leadOrContactId + '.' + campaignIdMap.get(campaignKey);
        } else {
            memberToUpsert = new CampaignMember(
                    CampaignId = campaignIdMap.get(campaignKey),
                    Campaign_Member_Key__c = leadOrContactId + '.' + campaignIdMap.get(campaignKey)
            );

            if (leadOnly) {
                memberToUpsert.LeadId = interaction.Lead__c;
            } else {
                memberToUpsert.ContactId = interaction.Contact__c;
            }
        }

        memberToUpsert.Status = campaignMemberStatus;
        intMappingService.applyDataToSObject(interaction, memberToUpsert);

        return memberToUpsert;
    }

    /**
     * @description Debugs SaveResult errors if they happen.
     * @param saveResults, the Database.SaveResult List to check.
     */
    private static void logPossibleErrors(Database.SaveResult[] saveResults) {
        for (Database.SaveResult result : saveResults) {
            if (!result.isSuccess()) {
                System.debug('Save Result Error: ' + result.getErrors() + ' ' + result.getId());
            }
        }
    }

    /**
     * @description Debugs UpsertResult errors if they happen.
     * @param saveResults, the Database.UpsertResult List to check.
     */
    private static void logPossibleErrors(Database.UpsertResult[] saveResults) {
        for (Database.UpsertResult result : saveResults) {
            if (!result.isSuccess()) {
                System.debug('Upsert Error: ' + result.getErrors() + ' ' + result.getId());
            }
        }
    }
}