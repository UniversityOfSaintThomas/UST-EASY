@IsTest
private class EASYAppHeaderController_TEST {

    @TestSetup
    static void setup() {
        Contact con = new Contact(
                LastName = 'Applicant',
                FirstName = 'Test',
                MailingCity = 'St. Paul'
        );
        insert con;

        Application_Control__c appControl = new Application_Control__c(
                Name = 'Undergraduate 2026',
                Active__c = true,
                Application_Start_Status__c = 'Started App'
        );
        insert appControl;

        Application__c app = new Application__c(
                Contact__c = con.Id,
                Application_Control__c = appControl.Id,
                Application_Status__c = 'Submitted App'
        );
        insert app;
    }

    // ── Positive ────────────────────────────────────────────────────────────

    @IsTest
    static void getHeaderData_returnsPopulatedHeader() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        EASYAppHeaderController.AppHeaderData result = EASYAppHeaderController.getHeaderData(app.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('Applicant, Test', result.contactName);
        System.assertEquals('Submitted App', result.appStatus);
        System.assertEquals('St. Paul', result.cityState);
        System.assertEquals('Test Applicant', result.legalName);
        System.assertEquals(UserInfo.getName(), result.ownerName, 'The application owner is shown');
        System.assertEquals('Citizenship', result.citizenshipLabel);
    }

    @IsTest
    static void getHeaderData_preferredName_replacesTheLegalFirstNameAndKeepsTheLegalNameAvailable() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        con.Preferred_First_Name__c = 'Tess';
        update con;
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        EASYAppHeaderController.AppHeaderData result = EASYAppHeaderController.getHeaderData(app.Id);
        Test.stopTest();

        System.assertEquals('Applicant, Tess', result.contactName);
        System.assertEquals('Test Applicant', result.legalName);
    }

    @IsTest
    static void getHeaderData_citizenship_isReturnedAsEntered() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        List<Schema.PicklistEntry> choices = Application__c.Citizenship__c.getDescribe().getPicklistValues();
        app.Citizenship__c = choices[0].getValue();
        update app;

        Test.startTest();
        EASYAppHeaderController.AppHeaderData result = EASYAppHeaderController.getHeaderData(app.Id);
        Test.stopTest();

        System.assertEquals(choices[0].getValue(), result.citizenship);
    }

    @IsTest
    static void getHeaderData_institution_usesTheApplicationFieldThenTheFlaggedEducationHistory() {
        Account school = new Account(Name = 'Sample College');
        Account other = new Account(Name = 'Other School');
        insert new List<Account>{school, other};
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        insert new hed__Education_History__c(
                hed__Contact__c = con.Id, hed__Account__c = school.Id, Primary_Bachelor_Institution__c = true
        );
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        EASYAppHeaderController.AppHeaderData fromHistory = EASYAppHeaderController.getHeaderData(app.Id);
        app.High_School_or_College__c = other.Id;
        update app;
        EASYAppHeaderController.AppHeaderData fromApplication = EASYAppHeaderController.getHeaderData(app.Id);
        Test.stopTest();

        System.assertEquals('Sample College', fromHistory.institutionName, 'Falls back to the flagged education history');
        System.assertEquals('Other School', fromApplication.institutionName, 'The application field wins when it is set');
    }

    // ── Negative ────────────────────────────────────────────────────────────

    @IsTest
    static void getHeaderData_blankAppId_returnsNull() {
        Test.startTest();
        EASYAppHeaderController.AppHeaderData result = EASYAppHeaderController.getHeaderData(null);
        Test.stopTest();

        System.assertEquals(null, result);
    }

    @IsTest
    static void getHeaderData_unknownAppId_returnsNull() {
        Test.startTest();
        EASYAppHeaderController.AppHeaderData result = EASYAppHeaderController.getHeaderData(
                '001000000000000AAA'
        );
        Test.stopTest();

        System.assertEquals(null, result);
    }

    // ── Bulk ────────────────────────────────────────────────────────────────

    @IsTest
    static void getHeaderData_multipleApplications_eachResolvesIndependently() {
        Contact con2 = new Contact(LastName = 'SecondApplicant', FirstName = 'Two');
        insert con2;
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Application__c app2 = new Application__c(
                Contact__c = con2.Id,
                Application_Control__c = appControl.Id,
                Application_Status__c = 'Admit'
        );
        insert app2;
        Application__c app1 = [SELECT Id FROM Application__c WHERE Id != :app2.Id LIMIT 1];

        Test.startTest();
        EASYAppHeaderController.AppHeaderData result1 = EASYAppHeaderController.getHeaderData(app1.Id);
        EASYAppHeaderController.AppHeaderData result2 = EASYAppHeaderController.getHeaderData(app2.Id);
        Test.stopTest();

        System.assertEquals('Submitted App', result1.appStatus);
        System.assertEquals('Admit', result2.appStatus);
        System.assertEquals('Applicant, Test', result1.contactName);
        System.assertEquals('SecondApplicant, Two', result2.contactName);
    }
}