/**
 * Unit tests for ApplicationLoginController.cls (ECRMSF-5511 / ECRMSF-5529, task 7). Site.login()
 * cannot be invoked from a standard Apex test context (it requires a live Experience Cloud site
 * request), so these tests exercise logLoginAttempt() directly via its @TestVisible marker -
 * the fraud-monitoring logic itself has no dependency on Site.login() having actually run; it
 * only reads whether login succeeded as a boolean parameter. login() itself (the thin wrapper
 * around Site.login()) is therefore not covered here and remains covered only by live manual
 * testing in the scratch org, as documented in docs/fraud-monitoring-recaptcha-ip-geo.md.
 */
@isTest
private class ApplicationLoginFraudCapture_TEST {

    @TestSetup
    static void setupData() {
        Application_Setting__c settings = Application_Setting__c.getOrgDefaults();
        settings.Community_Profile_Ids__c = '00eQL0000000000AAA';
        settings.Permission_Set_Id__c = '0PSQL0000000000AAA';
        settings.reCAPTCHA_Secret_Key__c = 'test-secret-key';
        settings.reCAPTCHA_Endpoint__c = 'https://www.google.com/recaptcha/api/siteverify';
        upsert settings;

        Account acc = new Account(Name = 'Test LoginController Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'LoginController', Email = 'test.logincontroller@example.com', AccountId = acc.Id);
        insert con;

        // A named User with a ContactId requires a genuine portal-capable profile - an internal
        // profile like System Administrator is rejected with "only portal users can be
        // associated to a contact." Customer Community Login User is a real (non-Guest) license
        // that supports this, and requires the Contact to belong to an Account.
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User testUser = new User(
                FirstName = 'Test',
                LastName = 'LoginControllerUser',
                Email = 'test.logincontrolleruser@example.com',
                Username = 'test.logincontrolleruser@example.com.uniquetest',
                Alias = 'tlcuser',
                TimeZoneSidKey = 'America/Chicago',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = portalProfile.Id,
                ContactId = con.Id
        );
        insert testUser;

        Academic_Term__c term = new Academic_Term__c(Name = 'Test Fall Term', Term_Start_Date__c = Date.today().addMonths(-1));
        insert term;

        Application_Control__c activeControl = new Application_Control__c(
                Name = 'Test Active Control',
                Application_Start_Status__c = 'Started App',
                Active__c = true,
                Current_Student_Application__c = true
        );
        Application_Control__c inactiveControl = new Application_Control__c(
                Name = 'Test Inactive Control',
                Application_Start_Status__c = 'Started App',
                Active__c = false,
                Current_Student_Application__c = true
        );
        insert new List<Application_Control__c>{ activeControl, inactiveControl };

        Application__c activeApp = new Application__c(
                Contact__c = con.Id,
                Application_Control__c = activeControl.Id,
                Intended_Term_of_Entry__c = term.Id,
                Application_Status__c = 'Started App'
        );
        Application__c withdrawnApp = new Application__c(
                Contact__c = con.Id,
                Application_Control__c = activeControl.Id,
                Intended_Term_of_Entry__c = term.Id,
                Application_Status__c = 'Withdrawn'
        );
        Application__c inactiveControlApp = new Application__c(
                Contact__c = con.Id,
                Application_Control__c = inactiveControl.Id,
                Intended_Term_of_Entry__c = term.Id,
                Application_Status__c = 'Started App'
        );
        insert new List<Application__c>{ activeApp, withdrawnApp, inactiveControlApp };
    }

    private class RecaptchaMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success":true,"score":0.85}');
            return res;
        }
    }

    private static ApplicationLoginController buildController(String username, String recaptchaResponse, String clientEnvJson) {
        Test.setCurrentPageReference(new PageReference('/Admissions/ApplicationLogin'));
        System.currentPageReference().getHeaders().put('User-Agent', 'Mozilla/5.0 Test Agent');
        System.currentPageReference().getHeaders().put('Referer', 'https://example.com/referer');

        ApplicationLoginController controller = new ApplicationLoginController();
        controller.username = username;
        controller.recaptchaResponse = recaptchaResponse;
        controller.clientEnvJson = clientEnvJson;
        return controller;
    }

    @isTest
    static void successfulLoginCreatesOneLogPerActiveApplication() {
        Test.setMock(HttpCalloutMock.class, new RecaptchaMock());
        ApplicationLoginController controller = buildController(
                'test.logincontrolleruser@example.com.uniquetest',
                'valid-token',
                '{"timeZone":"America/Chicago"}'
        );

        Test.startTest();
        controller.logLoginAttempt(true);
        Test.stopTest();

        List<Application_Login__c> logs = [
                SELECT Event_Type__c, ReCAPTCHA_Score__c, ReCAPTCHA_Score_Status__c, IP_Address__c, Browser__c, Client_Env_JSON__c
                FROM Application_Login__c
                WHERE Event_Type__c = 'Login'
        ];

        Assert.areEqual(1, logs.size(), 'Only the ONE active, non-withdrawn Application under the ACTIVE control should get a Login record - the withdrawn app and the app under the inactive control must both be excluded.');
        Assert.areEqual(0.85, logs[0].ReCAPTCHA_Score__c, 'The scored reCAPTCHA result must be captured on the Login record.');
        Assert.areEqual('Scored', logs[0].ReCAPTCHA_Score_Status__c, 'A successful mocked callout must resolve to Scored.');
    }

    @isTest
    static void failedLoginStillCreatesLogRecordWithoutGeolocation() {
        Test.setMock(HttpCalloutMock.class, new RecaptchaMock());
        ApplicationLoginController controller = buildController(
                'test.logincontrolleruser@example.com.uniquetest',
                'valid-token',
                null
        );

        Test.startTest();
        controller.logLoginAttempt(false);
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Geolocation__c FROM Application_Login__c WHERE Event_Type__c = 'Login'];
        Assert.areEqual(1, logs.size(), 'A failed login must still produce a fraud-monitoring record - repeated failures are themselves a signal worth capturing.');
        Assert.isNull(logs[0].Geolocation__c, 'A failed login must never attempt (or succeed at) a LoginHistory/LoginGeo lookup, since no LoginHistory row exists for a failed attempt.');
    }

    @isTest
    static void unknownUsernameIsSilentlySkipped() {
        ApplicationLoginController controller = buildController('does.not.exist@example.com.uniquetest', 'valid-token', null);

        Test.startTest();
        controller.logLoginAttempt(true);
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c];
        Assert.areEqual(0, logs.size(), 'A username with no matching User/Contact must be silently skipped - no record inserted, no exception thrown.');
    }

    @isTest
    static void blankUsernameIsSilentlySkipped() {
        ApplicationLoginController controller = buildController('', 'valid-token', null);

        Test.startTest();
        controller.logLoginAttempt(true);
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c];
        Assert.areEqual(0, logs.size(), 'A blank username must be silently skipped - no record inserted, no exception thrown.');
    }

    @isTest
    static void contactWithNoActiveApplicationsProducesNoRecords() {
        Account accWithNoApps = new Account(Name = 'NoApps Test Account');
        insert accWithNoApps;

        Contact conWithNoApps = new Contact(FirstName = 'NoApps', LastName = 'Test', Email = 'test.noapps@example.com', AccountId = accWithNoApps.Id);
        insert conWithNoApps;

        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User userWithNoApps = new User(
                FirstName = 'NoApps',
                LastName = 'TestUser',
                Email = 'test.noappsuser@example.com',
                Username = 'test.noappsuser@example.com.uniquetest',
                Alias = 'noappsu',
                TimeZoneSidKey = 'America/Chicago',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = portalProfile.Id,
                ContactId = conWithNoApps.Id
        );
        insert userWithNoApps;

        ApplicationLoginController controller = buildController('test.noappsuser@example.com.uniquetest', 'valid-token', null);

        Test.startTest();
        controller.logLoginAttempt(true);
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c WHERE Contact__c = :conWithNoApps.Id];
        Assert.areEqual(0, logs.size(), 'A Contact with zero active applications must produce zero Application_Login__c records - there is nothing to attach the audit row to.');
    }

    @isTest
    static void reCaptchaFailureStillCapturesLoginWithUnavailableStatus() {
        // No mock set - Test.isRunningTest() blocks all real callouts by default, so
        // ApplicationReCaptcha.isReCAPTCHAValid will hit a CalloutException internally and
        // gracefully degrade to Unavailable, exactly like a real quota-exhaustion scenario.
        ApplicationLoginController controller = buildController(
                'test.logincontrolleruser@example.com.uniquetest',
                'valid-token',
                null
        );

        Test.startTest();
        controller.logLoginAttempt(true);
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT ReCAPTCHA_Score_Status__c, ReCAPTCHA_Score__c FROM Application_Login__c WHERE Event_Type__c = 'Login'];
        Assert.areEqual(1, logs.size(), 'A Login record must still be captured even when the reCAPTCHA callout itself fails.');
        Assert.areEqual('Unavailable', logs[0].ReCAPTCHA_Score_Status__c, 'A callout failure must gracefully degrade to Unavailable, never block the login capture.');
        Assert.isNull(logs[0].ReCAPTCHA_Score__c, 'The score must be null when Unavailable.');
    }

    @isTest
    static void controllerConstructorLoadsRecaptchaSettings() {
        Application_Setting__c settings = Application_Setting__c.getOrgDefaults();
        settings.Community_Profile_Ids__c = '00eQL0000000000AAA';
        settings.Permission_Set_Id__c = '0PSQL0000000000AAA';
        settings.reCAPTCHA_Site_Key__c = 'test-site-key';
        settings.reCAPTCHA_Library_Url__c = 'https://www.google.com/recaptcha/api.js';
        upsert settings;

        Test.startTest();
        ApplicationLoginController controller = new ApplicationLoginController();
        Test.stopTest();

        Assert.isTrue(controller.recaptchaEnabled, 'recaptchaEnabled must be true when both the site key and library URL are configured.');
        Assert.areEqual('test-site-key', controller.recaptcha.publicKey, 'The RecaptchaSettings wrapper must expose the configured public key.');
    }

    @isTest
    static void checkIfLoggedInRedirectsPortalUsersAway() {
        Test.setCurrentPageReference(new PageReference('/Admissions/ApplicationLogin'));
        ApplicationLoginController controller = new ApplicationLoginController();

        Test.startTest();
        PageReference result = controller.checkIfLoggedIn();
        Test.stopTest();

        // The running test user is not a CSPLitePortal user type, so this should return null
        // (no redirect) - this exercises the non-portal branch of the method.
        Assert.isNull(result, 'A non-portal-user context must not trigger a redirect.');
    }
}
