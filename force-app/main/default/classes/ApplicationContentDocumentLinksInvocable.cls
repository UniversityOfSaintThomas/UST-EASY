/**
 * Created by nguy0092 on 10/20/2025.
 * Uses batch classes ApplicationContentDocumentLinksBatch1 and ApplicationContentDocumentLinksBatch2
 */

public without sharing class ApplicationContentDocumentLinksInvocable {

    @InvocableMethod(Label='Admissions Application ContentDocumentLink Visibility Settings Update' Description='Finds ContentDocumentLinks by matching LinkedEntityId to Application Id and updates Visibility to AllUsers')
    public static void contentDocumentLinks() {

        List<AggregateResult> currentTerm = [
                SELECT MIN(Academic_Year_Code__c) Academic_Year
                FROM Academic_Term__c
                WHERE (Current_Term__c = TRUE
                OR Term_Start_Date__c >= TODAY)
        ];

        if (!currentTerm.isEmpty() && currentTerm[0].get('Academic_Year') != null) {
            String currentAcademicYear = (String) currentTerm[0].get('Academic_Year');
            System.debug(currentTerm);
            System.debug(currentAcademicYear);

            Integer running = [
                    SELECT COUNT()
                    FROM AsyncApexJob
                    WHERE ApexClass.Name IN ('ApplicationContentDocumentLinksBatch1', 'ApplicationContentDocumentLinksBatch2')
                    AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
            ];

            if (running == 0) {
                Database.executeBatch(new ApplicationContentDocumentLinksBatch1(currentAcademicYear), 200);
            } else {
                System.debug('ContentDocumentLinkAppDocsInvocable: Batch already running, skipping execution.');
            }
        } else {
            System.debug('No Academic Year found. Process did not continue');
        }

    }

}