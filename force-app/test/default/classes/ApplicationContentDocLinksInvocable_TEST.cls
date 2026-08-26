/**
 * Created by nguy0092 on 8/26/2026.
 */

@IsTest
private class ApplicationContentDocLinksInvocable_TEST {

    @testSetup
    static void testSetup() {
        Application_Control__c appControl = new Application_Control__c(
                Application_Start_Status__c = Application_Control__c.Application_Start_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Active__c = true,
                Allow_Cancel_From__c = Application_Control__c.Allow_Cancel_From__c.getDescribe().getPicklistValues()[0].getValue(),
                Allow_Withdraw_From__c = Application_Control__c.Allow_Withdraw_From__c.getDescribe().getPicklistValues()[0].getValue(),
                Allow_Submit_From__c = Application_Control__c.Allow_Submit_From__c.getDescribe().getPicklistValues()[0].getValue(),
                Cancel_Status__c = Application_Control__c.Cancel_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Default__c = true,
                URL_Parameter__c = 'st',
                Submit_Status__c = Application_Control__c.Submit_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Withdraw_Status__c = Application_Control__c.Withdraw_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Documents_To_Display_Keywords__c = 'DFC_AdmissionLetter|Admission Letter;UGFR_AdmissionLetter|Admission Letter'
        );
        insert appControl;

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact student = new Contact(FirstName = 'Test', LastName = 'Student', Email = 'teststudent@example.com');
        insert student;

        hed__Term__c hedTerm = new hed__Term__c(Name = 'Fall 2025', hed__Account__c = acc.Id);
        insert hedTerm;

        // Term_Start_Date__c in the future so it qualifies as "current" for the invocable's query
        Academic_Term__c term = new Academic_Term__c(
                Name = 'Fall 2025',
                Term__c = hedTerm.Id,
                Academic_Year_Code__c = '2025',
                Term_Start_Date__c = Date.today().addDays(30)
        );
        insert term;

        Program__c program = new Program__c(
                Name = 'Test Program',
                Program_Name_on_Application__c = 'Test Program',
                Academic_Level__c = 'U'
        );
        insert program;

        Application__c app = new Application__c(
                Contact__c = student.Id,
                Application_Control__c = appControl.Id,
                Intended_Term_of_Entry__c = term.Id,
                Intended_Program__c = program.Id,
                Application_Status__c = 'Admit'
        );
        insert app;

        // Matching document title - should be updated to AllUsers
        insert new ContentVersion(
                Title = 'DFC_AdmissionLetter Test Doc',
                PathOnClient = 'DFC_AdmissionLetter Test Doc.pdf',
                VersionData = Blob.valueOf('test'),
                FirstPublishLocationId = app.Id
        );

        // Non-matching document title - should remain InternalUsers
        insert new ContentVersion(
                Title = 'Unrelated Document',
                PathOnClient = 'Unrelated Document.pdf',
                VersionData = Blob.valueOf('test'),
                FirstPublishLocationId = app.Id
        );

        // Set both links to InternalUsers so we can verify only the matching one flips to AllUsers
        List<ContentDocumentLink> links = [SELECT Id, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :app.Id];
        for (ContentDocumentLink cdl : links) {
            cdl.Visibility = 'InternalUsers';
        }
        update links;
    }

    @isTest
    static void testInvocable_HappyPath_UpdatesMatchingDocumentVisibility() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        ApplicationContentDocumentLinksInvocable.contentDocumentLinks();
        Test.stopTest();

        Map<String, String> titleToVisibility = new Map<String, String>();
        for (ContentDocumentLink cdl : [
                SELECT Visibility, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :app.Id
        ]) {
            titleToVisibility.put(cdl.ContentDocument.Title, cdl.Visibility);
        }

        System.assertEquals('AllUsers', titleToVisibility.get('DFC_AdmissionLetter Test Doc'),
                'Matching document title should be updated to AllUsers');
        System.assertEquals('InternalUsers', titleToVisibility.get('Unrelated Document'),
                'Non-matching document title should remain InternalUsers');
    }

    @isTest
    static void testInvocable_NoCurrentAcademicTerm_DoesNothing() {
        // Remove terms so no current/future term is found
        delete [SELECT Id FROM Academic_Term__c];

        Test.startTest();
        ApplicationContentDocumentLinksInvocable.contentDocumentLinks();
        Test.stopTest();

        Integer jobCount = [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE ApexClass.Name IN ('ApplicationContentDocumentLinksBatch1', 'ApplicationContentDocumentLinksBatch2')
        ];
        System.assertEquals(0, jobCount, 'No batch should be enqueued when there is no current academic year');
    }

    @isTest
    static void testInvocable_SkipsWhenBatchAlreadyRunning() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        // Kick off Batch1 so an AsyncApexJob is left in a running state before stopTest flushes it
        Database.executeBatch(new ApplicationContentDocumentLinksBatch1('2025'), 200);
        // Invocable should see the running job and skip enqueueing a duplicate
        ApplicationContentDocumentLinksInvocable.contentDocumentLinks();
        Test.stopTest();

        // The document should still be updated once (from the single Batch1/Batch2 chain that did run)
        List<ContentDocumentLink> updatedLinks = [
                SELECT Visibility
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :app.Id
                AND Visibility = 'AllUsers'
        ];
        System.assertEquals(1, updatedLinks.size(), 'Only the originally enqueued batch chain should have run');
    }

    @isTest
    static void testBatch1_BuildsApplicationDocumentTitlesMapAndChainsBatch2() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        Database.executeBatch(new ApplicationContentDocumentLinksBatch1('2025'), 200);
        Test.stopTest();

        ContentDocumentLink cdl = [
                SELECT Visibility, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :app.Id
                AND ContentDocument.Title = 'DFC_AdmissionLetter Test Doc'
                LIMIT 1
        ];
        System.assertEquals('AllUsers', cdl.Visibility, 'Batch1 should chain into Batch2 and update visibility');
    }

    @isTest
    static void testBatch2_EmptyKeywordSet_NoOpQueryLocator() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Map<Id, Set<String>> applicationDocumentTitlesMap = new Map<Id, Set<String>>{
                app.Id => new Set<String>()
        };

        Test.startTest();
        Database.executeBatch(new ApplicationContentDocumentLinksBatch2(applicationDocumentTitlesMap), 200);
        Test.stopTest();

        // Nothing should be updated since there are no keywords to match against
        List<ContentDocumentLink> updatedLinks = [
                SELECT Id
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :app.Id
                AND Visibility = 'AllUsers'
        ];
        System.assertEquals(0, updatedLinks.size(), 'No documents should be updated with an empty keyword set');
    }

    @isTest
    static void testBatch2_DirectExecution_UpdatesMatchingLinksOnly() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Map<Id, Set<String>> applicationDocumentTitlesMap = new Map<Id, Set<String>>{
                app.Id => new Set<String>{ 'DFC_AdmissionLetter' }
        };

        Test.startTest();
        Database.executeBatch(new ApplicationContentDocumentLinksBatch2(applicationDocumentTitlesMap), 200);
        Test.stopTest();

        Map<String, String> titleToVisibility = new Map<String, String>();
        for (ContentDocumentLink cdl : [
                SELECT Visibility, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :app.Id
        ]) {
            titleToVisibility.put(cdl.ContentDocument.Title, cdl.Visibility);
        }

        System.assertEquals('AllUsers', titleToVisibility.get('DFC_AdmissionLetter Test Doc'));
        System.assertEquals('InternalUsers', titleToVisibility.get('Unrelated Document'));
    }

}