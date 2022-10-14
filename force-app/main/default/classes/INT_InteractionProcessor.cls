/*****************************************
* File: INT_InteractionProcessor
* Author: Sierra-Cedar
* Description: Processes new Interaction__c records by inserting/converting Leads, upserting Opportunities,
* updating Contacts, upserting Affiliations, and upserting CampaignMembers
******************************************/
public class INT_InteractionProcessor {
    private List<Interaction__c> dupeInteractions = new List<Interaction__c>();
    private List<Lead> leadsToDelete = new List<Lead>();
    private List<Opportunity> opportunitiesToUpsert = new List<Opportunity>();
    private Map<Id, Lead> interactionIdToLead = new Map<Id, Lead>();
    private Map<Id, Interaction__c> interactionMap = new Map<Id, Interaction__c>();
    private Map<Id, Interaction__c> leadIdToInteractionMap = new Map<Id, Interaction__c>();
    private Set<Id> contactIds = new Set<Id>();
    private Set<Id> existingLeadIds = new Set<Id>();

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

                // Loop through current Campaign Members and build campaignMemberMap
                for (CampaignMember cm : [
                        SELECT Status, CampaignId, Campaign.Campaign_Key__c, Lead_Contact_ID__c
                        FROM CampaignMember
                        WHERE ContactId IN :contactIds
                ]) {
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

    /**
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
        for (String leadId : leadIdToInteractionMap.keySet()) {
            Lead leadToUpdate = new Lead(Id = leadId);
            intMappingService.applyDataToSObject(leadIdToInteractionMap.get(leadId), leadToUpdate);
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

    /**
     * @description Main method for processing new Interaction__c records.
     * @param interactionsToProcess, the List of new Interaction__c objects to process.
     */
    public void processInteractions(List<Interaction__c> newInteractions) {
        List<Contact> contactsToUpdate = new List<Contact>();
        List<hed__Affiliation__c> affiliationsToUpsert = new List<hed__Affiliation__c>();

        // Run duplicate pre-processing
        List<Interaction__c> interactionsToProcess = duplicatePreProcessing(newInteractions);

        // Set up Interaction Map for reference during processing.
        interactionMap = new Map<Id, Interaction__c>(interactionsToProcess);

        // Create Leads from new Interactions records.
        List<Database.LeadConvert> newLeads = insertLeadsFromInteractions(interactionsToProcess);

        // Attempt initial conversion of leads.
        List<Database.LeadConvert> possibleLeadsToReconvert = convertLeads(newLeads);

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
        if (opportunitiesToUpsert.size() > 0) {
            logPossibleErrors(Database.upsert(opportunitiesToUpsert, false));
        }

        // Finally, associate referenced Opportunity and set Interaction_Status__c after processing and flag if errored.
        for (Interaction__c interaction : interactionsToProcess) {
            if (!String.isEmpty(interaction.Contact__c)) {
                Contact newCont = new Contact(Id = interaction.Contact__c);
                intMappingService.applyDataToSObject(interaction, newCont);
                contactsToUpdate.add(newCont);
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
        if (Interactions_PreProcessing__c.getAll().values() != null) {
            for (Interactions_PreProcessing__c ipp : Interactions_PreProcessing__c.getAll().values()) {
                if (!ipp.Active__c) return interactions;
            }
        }

        Map<String, Interaction__c> filteredMap = new Map<String, Interaction__c>();

        for (Interaction__c interaction : interactions) {
            String filterKey = interaction.First_Name__c + interaction.Last_Name__c + interaction.Email__c;
            if (!filteredMap.containsKey(filterKey)) {
                filteredMap.put(filterKey, interaction);
            } else {
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
                    Company = interaction.Last_Name__c + ', ' + interaction.First_Name__c
            );

            interactionIdToLead.put(interaction.Id, newLead);
            intMappingService.applyDataToSObject(interaction, newLead);
        }

        leadConverts.addAll(insertLeads(interactionIdToLead.values(), interactions));

        return leadConverts;
    }

    /**
     * @description Inserts a collection of Leads. If there are failures, log issues to Interaction Audit Status.
     * @param leads, a List of Lead objects to insert.
     * @return leadsToConvert, a List of Database.LeadConvert records to convert.
     */
    private List<Database.LeadConvert> insertLeads(List<Lead> leadsToInsert, List<Interaction__c> interactions) {
        Integer leadIndex = 0;
        Database.SaveResult[] srlist = Database.insert(leadsToInsert, false); // Insert Leads
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();

        for (Database.SaveResult sr : srlist)  {
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
                                    leadIdToInteractionMap.put(interaction.Lead__c,interaction);
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

    /**
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
        Database.LeadConvertResult[] leadConvertResults = Database.convertLead(leadsToConvert, false); // Convert Leads

        List<Map<Id, String>> termsAndPrograms = getTermsAndProgramNames(leadConvertResults);
        Map<Id, String> leadIdToTermNameMap = termsAndPrograms[0];
        Map<Id, String> leadIdToProgramNameMap = termsAndPrograms[1];
        Map<String, Opportunity> oppNameMap = getMatchingOpportunities(leadConvertResults, leadIdToTermNameMap, leadIdToProgramNameMap);

        for (Database.LeadConvertResult lcr : leadConvertResults) {
            Interaction__c interaction = (leadIdToInteractionMap.containsKey(lcr.getLeadId())) ? leadIdToInteractionMap.get(lcr.getLeadId()) : null;

            if (lcr.isSuccess()) {
                // Add Contact Id to set to be updated from its Interaction record.
                interaction.Contact__c = lcr.getContactId();
                contactIds.add(lcr.getContactId());

                // If we had an existing Lead in SF, copy the values to the Interaction based upon the custom mdt.
                if (existingLeadMap.containsKey(lcr.getLeadId())) {
                    intMappingService.applyDataToInteraction(existingLeadMap.get(lcr.getLeadId()), interaction);
                }

                // Create new Opportunity for upsert if Opportunity Key is populated.
                if (!String.isEmpty(interaction.Opportunity_Key__c)) {
                    Opportunity newOppty = new Opportunity();
                    String lastName = interaction.Last_Name__c;
                    String termName = '';
                    String programName = '';
                    if (leadIdToTermNameMap.get(lcr.getLeadId()) != null) {
                        termName = leadIdToTermNameMap.get(lcr.getLeadId());
                    }
                    if (leadIdToProgramNameMap.get(lcr.getLeadId()) != null) {
                        programName = leadIdToProgramNameMap.get(lcr.getLeadId());
                    }
                    // check if opportunity already exists
                    if (!oppNameMap.isEmpty()) {
                        if (oppNameMap.keySet().contains(lastName + '|' + termName + '|' + programName)) {
                            newOppty = oppNameMap.get(String.valueOf(lastName + '|' + termName + '|' + programName));
                        } else if (oppNameMap.keySet().contains(lastName + '|' + termName + '|')) {
                            newOppty = oppNameMap.get(String.valueOf(lastName + '|' + termName + '|'));
                        } else if (oppNameMap.keySet().contains(lastName + '||' + programName)) {
                            newOppty = oppNameMap.get(String.valueOf(lastName + '||' + programName));
                        } else if (oppNameMap.keySet().contains(lastName + '||')) {
                            newOppty = oppNameMap.get(String.valueOf(lastName + '||'));
                        }
                    }
                    System.debug('%%% newOppty: ' + newOppty);
                    newOppty.Name = determineOpportunityName(newOppty.Name, lastName, termName, programName);
                    newOppty.CloseDate = System.today();
                    newOppty.StageName = interaction.Opportunity_Stage__c;
                    newOppty.Opportunity_Key__c = lcr.getContactId() + interaction.Opportunity_Key__c;
                    newOppty.AccountId = lcr.getAccountId();
                    System.debug('%%% newOppty assignments: ' + newOppty);
                    intMappingService.applyDataToSObject(interaction, newOppty);
                    interaction.Opportunity__r = newOppty;
                    opportunitiesToUpsert.add(newOppty);
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
        Map<Id, hed__Term__c> terms = new Map<Id, hed__Term__c>([SELECT Id, Name FROM hed__Term__c WHERE Id IN: leadIdToTermIdMap.values()]);
        Map<Id, String> leadIdToTermNameMap = new Map<Id, String>();
        for (Id leadId : leadIdToTermIdMap.keySet()) {
            hed__Term__c term = terms.get(leadIdToTermIdMap.get(leadId));
            leadIdToTermNameMap.put(leadId, term.Name);
        }

        // get academic program names related to interactions
        Map<Id, Program__c> programs = new Map<Id, Program__c>([SELECT Id, Program_Name_on_Application__c FROM Program__c WHERE Id IN: leadIdToProgramIdMap.values()]);
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

    private Map<String, Opportunity> getMatchingOpportunities(Database.LeadConvertResult[] leadConvertResults, Map<Id, String> leadIdToTermNameMap, Map<Id, String> leadIdToProgramNameMap) {

        // get related opportunities
        Map<String, String> oppNamesToQuery = new Map<String, String>(); // using map to avoid duplicate values
        for (Database.LeadConvertResult lcr : leadConvertResults) {
            Interaction__c interaction = (leadIdToInteractionMap.containsKey(lcr.getLeadId())) ? leadIdToInteractionMap.get(lcr.getLeadId()) : null;
            String lastName = interaction.Last_Name__c;
            String termName = '';
            String programName = '';
            if (leadIdToTermNameMap.get(lcr.getLeadId()) != null) {
                termName = leadIdToTermNameMap.get(lcr.getLeadId());
            }
            if (leadIdToProgramNameMap.get(lcr.getLeadId()) != null) {
                programName = leadIdToProgramNameMap.get(lcr.getLeadId());
            }
            oppNamesToQuery.put(lastName + '||', '');
            oppNamesToQuery.put(lastName + '|' + termName + '|', '');
            oppNamesToQuery.put(lastName + '||' + programName, '');
            oppNamesToQuery.put(lastName + '|' + termName + '|' + programName, '');
        }
        System.debug('%%% oppNamesToQuery: ' + oppNamesToQuery);
        List<Opportunity> existingOpps = [SELECT Id, Name FROM Opportunity WHERE Name IN: oppNamesToQuery.keySet()];
        Map<String, Opportunity> oppNameMap = new Map<String, Opportunity>();
        for (Opportunity opp : existingOpps) {
            oppNameMap.put(opp.Name, opp);
            List<String> splitName = opp.Name.split('\\|');
            oppNameMap.put(splitName[0] + '||', opp);
        }
        System.debug('%%% oppNameMap: ' + oppNameMap);
        return oppNameMap;
    }

    private String determineOpportunityName(String currentOppName, String lastName, String termName, String programName) {
        String potentialOppName = lastName + '|' + termName + '|' + programName;
        if (String.isBlank(currentOppName)) {
            return potentialOppName;
        } else {
            List<String> splitCurrentOppName = currentOppName.split('\\|');
            List<String> splitPotentialOppName = potentialOppName.split('\\|');
            switch on splitCurrentOppName.size() {
                when 1 { // only last name populated on opportunity
                    return potentialOppName;
                }
                when 2 { // last name and term populated on opportunity
                    if (splitPotentialOppName.size() == 3) {
                        return currentOppName + splitPotentialOppName[2];
                    } else {
                        return currentOppName;
                    }
                }
                when 3 { // last name, term, and program populated OR last name and program
                    if (String.isBlank(splitCurrentOppName[1])) { // no term populated
                        if (splitPotentialOppName.size() == 1) {
                            return currentOppName;
                        } else if (splitPotentialOppName.size() == 2) {
                            return splitCurrentOppName[0] + '|' + splitPotentialOppName[1] + '|' + splitCurrentOppName[2];
                        } else if (splitPotentialOppName.size() == 3) {
                            if (String.isBlank(splitPotentialOppName[1])) {
                                return currentOppName;
                            } else {
                                return splitCurrentOppName[0] + '|' + splitPotentialOppName[1] + '|' + splitCurrentOppName[2];
                            }
                        }
                    } else { // all values are populated
                        return currentOppName;
                    }
                }
                when else {
                    return currentOppName;
                }
            }
        }
        return currentOppName;
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

    /**
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