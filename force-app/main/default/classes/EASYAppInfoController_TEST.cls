@IsTest
private class EASYAppInfoController_TEST {

    @TestSetup
    static void setup() {
        Contact con = new Contact(LastName = 'Applicant');
        insert con;

        Application_Control__c appControl = new Application_Control__c(
                Name = 'Undergraduate 2026',
                Active__c = true,
                Application_Start_Status__c = 'Started App'
        );
        insert appControl;

        Application__c appWithTest = new Application__c(
                Contact__c = con.Id,
                Application_Control__c = appControl.Id,
                Generic_Filter_3__c = 'Apply With Standardized Test',
                Highest_ACT_Composite__c = 28
        );
        insert appWithTest;

        Application__c appWithoutTest = new Application__c(
                Contact__c = con.Id,
                Application_Control__c = appControl.Id,
                Generic_Filter_3__c = 'Apply Without Standardized Test'
        );
        insert appWithoutTest;
    }

    // ── Positive ────────────────────────────────────────────────────────────

    @IsTest
    static void upsertAppReviewData_testScorePath_createsTestScoreRecord() {
        Application__c app = [
                SELECT Id FROM Application__c WHERE Generic_Filter_3__c = 'Apply With Standardized Test' LIMIT 1
        ];
        Id testScoreRtId = [
                SELECT Id FROM RecordType WHERE SobjectType = 'Application_Review__c' AND DeveloperName = 'Test_Score'
        ].Id;

        Test.startTest();
        Application_Review__c result = EASYAppInfoController.upsertAppReviewData(app.Id);
        Test.stopTest();

        System.assertNotEquals(null, result.Id);
        System.assertEquals(app.Id, result.Application__c);
        System.assertEquals(testScoreRtId, result.RecordTypeId);
        System.assertEquals(28, result.Highest_ACT_Composite__c);
    }

    @IsTest
    static void upsertAppReviewData_testOptionalPath_createsTestOptionalRecord() {
        Application__c app = [
                SELECT Id FROM Application__c WHERE Generic_Filter_3__c = 'Apply Without Standardized Test' LIMIT 1
        ];
        Id testOptionalRtId = [
                SELECT Id FROM RecordType WHERE SobjectType = 'Application_Review__c' AND DeveloperName = 'Test_Optional'
        ].Id;

        Test.startTest();
        Application_Review__c result = EASYAppInfoController.upsertAppReviewData(app.Id);
        Test.stopTest();

        System.assertEquals(testOptionalRtId, result.RecordTypeId);
    }

    @IsTest
    static void upsertAppReviewData_calledTwice_updatesSameRecord() {
        Application__c app = [
                SELECT Id FROM Application__c WHERE Generic_Filter_3__c = 'Apply With Standardized Test' LIMIT 1
        ];

        Test.startTest();
        Application_Review__c first = EASYAppInfoController.upsertAppReviewData(app.Id);
        Application_Review__c second = EASYAppInfoController.upsertAppReviewData(app.Id);
        Test.stopTest();

        System.assertEquals(first.Id, second.Id, 'Second call should update the same review record, not create a new one');
        System.assertEquals(1, [SELECT COUNT() FROM Application_Review__c WHERE Application__c = :app.Id]);
    }

    // ── Negative ────────────────────────────────────────────────────────────

    @IsTest
    static void upsertAppReviewData_blankAppId_returnsUnsavedRecord() {
        Test.startTest();
        Application_Review__c result = EASYAppInfoController.upsertAppReviewData(null);
        Test.stopTest();

        System.assertEquals(null, result.Id);
    }

    @IsTest
    static void upsertAppReviewData_unknownAppId_returnsUnsavedRecord() {
        Test.startTest();
        Application_Review__c result = EASYAppInfoController.upsertAppReviewData('001000000000000AAA');
        Test.stopTest();

        System.assertEquals(null, result.Id);
    }

    // ── Bulk ────────────────────────────────────────────────────────────────

    @IsTest
    static void upsertAppReviewData_multipleApplications_eachGetsOwnReviewRecord() {
        List<Application__c> apps = [SELECT Id FROM Application__c];
        System.assertEquals(2, apps.size());

        Test.startTest();
        Application_Review__c result1 = EASYAppInfoController.upsertAppReviewData(apps[0].Id);
        Application_Review__c result2 = EASYAppInfoController.upsertAppReviewData(apps[1].Id);
        Test.stopTest();

        System.assertNotEquals(result1.Id, result2.Id);
        System.assertEquals(2, [SELECT COUNT() FROM Application_Review__c]);
    }

    // -- getSummarySections ---------------------------------------------------------------------------------

    private static List<String> everyOption() {
        List<String> options = new List<String>();
        for (Schema.PicklistEntry entry : Application_Control__c.Review_Summary_Sections__c.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                options.add(entry.getValue());
            }
        }
        return options;
    }

    @IsTest
    static void getSummarySections_nothingSelected_returnsEveryOption() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        List<String> sections = EASYAppInfoController.getSummarySections(app.Id);
        Test.stopTest();

        System.assertEquals(everyOption(), sections, 'A blank setting should show every section');
        System.assert(sections.size() >= 4, 'The field should offer at least the four summary sections');
    }

    @IsTest
    static void getSummarySections_someSelected_returnsOnlyThose() {
        List<String> options = everyOption();
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        appControl.Review_Summary_Sections__c = options[0] + ';' + options[2];
        update appControl;
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        List<String> sections = EASYAppInfoController.getSummarySections(app.Id);
        Test.stopTest();

        System.assertEquals(new List<String>{ options[0], options[2] }, sections);
    }

    @IsTest
    static void getSummarySections_unknownApplication_returnsEveryOption() {
        Test.startTest();
        List<String> sections = EASYAppInfoController.getSummarySections(null);
        Test.stopTest();

        System.assertEquals(everyOption(), sections);
    }
}