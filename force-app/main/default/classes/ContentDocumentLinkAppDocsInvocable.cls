/**
 * Created by nguy0092 on 10/20/2025.
 */

public with sharing class ContentDocumentLinkAppDocsInvocable {

    @InvocableMethod(Label='ContentDocumentLink Application Documents Visibility Settings Update' Description='Finds ContentDocumentLinks by matching LinkedEntityId to Application Id and updates Visibility to AllUsers')
    public static void contentDocumentLinks() {
        List<ContentDocumentLink> updateContentDocumentLinks = new List<ContentDocumentLink>();

        List<AggregateResult> currentTerm = [
                SELECT MIN(Academic_Year_Code__c) Academic_Year
                FROM Academic_Term__c
                WHERE Current_Term__c = TRUE
                OR Term_End_Date__c >= TODAY
        ];

        String currentAcademicYear = '2099'; //Default if no terms found

        if (currentTerm.size() > 0) {
            currentAcademicYear = (String) currentTerm[0].get('Academic_Year');
        }

        System.debug(currentTerm);
        System.debug(currentAcademicYear);

        //USE THIS WAY FOR MASS ACTION SCHEDULER BECAUSE OTHER WAY HAS LIMITS ON HOW MANY IDs IN WHERE IN CLAUSE SO WON'T GET ALL RECORDS
        List<ContentDocumentLink> linkDocumentFiles = [
                SELECT Id,
                        ContentDocumentId,
                        ContentDocument.Title,
                        ShareType,
                        Visibility,
                        LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocument.Title LIKE '%AdmissionLetter%'
                AND Visibility = 'InternalUsers'
                AND LinkedEntityId IN (
                        SELECT Id
                        FROM Application__c
                        WHERE Application_Status__c IN ('Admit', 'Confirmed')
                        AND Intended_Term_of_Entry__r.Academic_Year_Code__c >= :currentAcademicYear
                        AND Intended_Program__r.Academic_Level__c = 'U'
                )
        ];

        for(ContentDocumentLink cdl :linkDocumentFiles) {

            if(cdl.Visibility == 'InternalUsers') {
                ContentDocumentLink updateCdl = new ContentDocumentLink();
                updateCdl.Id = cdl.Id;
                updateCdl.Visibility = 'AllUsers';
                updateContentDocumentLinks.add(updateCdl);
            }
        }

        System.debug(linkDocumentFiles.size());

        if(updateContentDocumentLinks.size() > 0) {
            try {
                update updateContentDocumentLinks;
            } catch (DmlException e) {
                System.debug('updateContentDocumentLinks error: '+e);
            }
        }
    }

}