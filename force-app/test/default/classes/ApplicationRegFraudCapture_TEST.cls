/**
 * Unit tests for the fraud-monitoring additions to ApplicationRegistration.cls (ECRMSF-5511 /
 * ECRMSF-5529, task 6).
 *
 * Named distinctly from "ApplicationRegistration_TEST" to avoid a real naming collision
 * discovered during this session's test-writing pass: a pre-existing, unrelated
 * ApplicationRegistration_TEST class already exists in this org (part of the original EASY
 * codebase, never retrieved into local source) - deploying a same-named class would have
 * silently clobbered that existing test coverage.
 *
 * IMPORTANT SCOPE NOTE: this class does NOT (and cannot) unit-test submit()'s call site that
 * dispatches logRegistrationAttemptAsync(). submit() contains PRE-EXISTING (not written as part
 * of this fraud-monitoring feature) test-bypass logic - `if (!Test.isRunningTest() &&
 * pass.equals(passConfirm))` - that skips Site.createExternalUser() (and therefore the fraud
 * capture call immediately after it) entirely whenever Test.isRunningTest() is true. This makes
 * that specific call site structurally unreachable from any Apex unit test, regardless of how
 * thoroughly the rest of submit()'s preconditions are set up. This is a pre-existing limitation
 * of this codebase's architecture, not something introduced by the fraud-monitoring feature.
 *
 * The actual registration-to-fraud-capture wiring was instead verified via extensive live manual
 * testing in the scratch org during development (see docs/fraud-monitoring-recaptcha-ip-geo.md's
 * task 6 write-up for the full verification record, including the discovery and fix of the
 * callout-after-DML bug). This test class instead directly covers logRegistrationAttemptAsync()
 * itself - the @future method that contains 100% of the fraud-monitoring logic - which is public
 * static and fully callable/testable independent of submit()'s surrounding architecture.
 */
@isTest
private class ApplicationRegFraudCapture_TEST {

    private class RecaptchaAndGeoMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            if (req.getEndpoint().contains('recaptcha')) {
                res.setBody('{"success":true,"score":0.9}');
            } else {
                res.setBody('{"status":"success","city":"Minneapolis","regionName":"Minnesota","country":"United States"}');
            }
            return res;
        }
    }

    private class NonSuccessResponseMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(503);
            res.setBody('Service Unavailable');
            return res;
        }
    }

    @TestSetup
    static void setupData() {
        Application_Setting__c settings = Application_Setting__c.getOrgDefaults();
        settings.Community_Profile_Ids__c = '00eQL0000000000AAA';
        settings.Permission_Set_Id__c = '0PSQL0000000000AAA';
        settings.reCAPTCHA_Secret_Key__c = 'test-secret-key';
        settings.reCAPTCHA_Endpoint__c = 'https://www.google.com/recaptcha/api/siteverify';
        upsert settings;

        Contact con = new Contact(FirstName = 'Test', LastName = 'RegistrationFraud', Email = 'test.registrationfraud@example.com');
        insert con;

        Application__c app = new Application__c(Contact__c = con.Id, Application_Status__c = 'Started App');
        insert app;
    }

    @isTest
    static void logRegistrationAttemptAsyncCapturesFullSignalSetOnSuccess() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new RecaptchaAndGeoMock());

        Test.startTest();
        ApplicationRegistration.logRegistrationAttemptAsync(
                con.Id,
                app.Id,
                'valid-recaptcha-token',
                '24.152.140.219',
                'Mozilla/5.0 Test Agent',
                'https://example.com/register',
                '{"timeZone":"America/Chicago","userAgentJs":"Mozilla/5.0 Test Agent"}'
        );
        Test.stopTest();

        Application_Login__c log = [
                SELECT Event_Type__c, ReCAPTCHA_Score__c, ReCAPTCHA_Score_Status__c, ReCAPTCHA_Error_Detail__c,
                        IP_Address__c, Geolocation__c, User_Agent_Raw__c, Client_Env_JSON__c, Contact__c, Application__c
                FROM Application_Login__c
                WHERE Contact__c = :con.Id AND Application__c = :app.Id
                LIMIT 1
        ];

        Assert.areEqual('Registration', log.Event_Type__c, 'The dispatched record must be typed Registration.');
        Assert.areEqual(0.9, log.ReCAPTCHA_Score__c, 'A successfully mocked reCAPTCHA callout must populate the real score.');
        Assert.areEqual('Scored', log.ReCAPTCHA_Score_Status__c, 'A successful callout must resolve to Scored.');
        Assert.isNull(log.ReCAPTCHA_Error_Detail__c, 'A successful scored result should have no error detail.');
        Assert.areEqual('24.152.140.219', log.IP_Address__c, 'The passed-in IP address must be stored as-is.');
        Assert.areEqual('Minneapolis, Minnesota, United States', log.Geolocation__c, 'The geolocation lookup (via ApplicationGeolocation, since there is no LoginHistory row at registration time) must succeed using the mocked response.');
        Assert.areEqual('Mozilla/5.0 Test Agent', log.User_Agent_Raw__c, 'The raw User-Agent must be stored as-is.');

        Map<String, Object> envJson = (Map<String, Object>) JSON.deserializeUntyped(log.Client_Env_JSON__c);
        Assert.areEqual('https://example.com/register', envJson.get('referer'), 'The Referer header must be merged into the stored Client_Env_JSON__c blob.');
        Assert.areEqual(false, envJson.get('userAgentMismatch'), 'A matching client/server User-Agent must result in userAgentMismatch = false in the merged blob.');
    }

    @isTest
    static void logRegistrationAttemptAsyncGracefullyDegradesWithNoRecaptchaTokenOrIp() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        ApplicationRegistration.logRegistrationAttemptAsync(con.Id, app.Id, null, null, null, null, null);
        Test.stopTest();

        Application_Login__c log = [
                SELECT ReCAPTCHA_Score_Status__c, ReCAPTCHA_Score__c, ReCAPTCHA_Error_Detail__c, IP_Address__c, Geolocation__c
                FROM Application_Login__c
                WHERE Contact__c = :con.Id AND Application__c = :app.Id
                LIMIT 1
        ];

        Assert.areEqual('Unavailable', log.ReCAPTCHA_Score_Status__c, 'With no token provided, reCAPTCHA must gracefully degrade to Unavailable, never Error, never blocking the capture.');
        Assert.isNull(log.ReCAPTCHA_Score__c, 'The score must be null when Unavailable.');
        Assert.isNotNull(log.ReCAPTCHA_Error_Detail__c, 'A diagnostic error detail must be present to explain why the score is Unavailable.');
        Assert.isNull(log.IP_Address__c, 'A null IP address must be stored as null, not an empty string or error.');
        Assert.isNull(log.Geolocation__c, 'With no IP address to look up, geolocation must be null - the graceful-degradation contract, not an exception.');
    }

    @isTest
    static void logRegistrationAttemptAsyncNoOpsOnNullContactId() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        ApplicationRegistration.logRegistrationAttemptAsync(null, app.Id, 'token', '24.152.140.219', 'UA', null, null);
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c WHERE Application__c = :app.Id];
        Assert.areEqual(0, logs.size(), 'A null Contact Id must result in a no-op - no Application_Login__c record should be created for a registration event with no identifiable Contact.');
    }

    @isTest
    static void logRegistrationAttemptAsyncNoOpsOnNullApplicationId() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        ApplicationRegistration.logRegistrationAttemptAsync(con.Id, null, 'token', '24.152.140.219', 'UA', null, null);
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c WHERE Contact__c = :con.Id];
        Assert.areEqual(0, logs.size(), 'A null Application Id must result in a no-op - there is nothing to scope the audit record to.');
    }

    @isTest
    static void logRegistrationAttemptAsyncNeverExceedsFieldLengthForErrorDetail() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new NonSuccessResponseMock());

        Test.startTest();
        ApplicationRegistration.logRegistrationAttemptAsync(con.Id, app.Id, 'some-token', '24.152.140.219', 'UA', null, null);
        Test.stopTest();

        Application_Login__c log = [SELECT ReCAPTCHA_Error_Detail__c FROM Application_Login__c WHERE Contact__c = :con.Id AND Application__c = :app.Id LIMIT 1];
        Assert.isNotNull(log.ReCAPTCHA_Error_Detail__c, 'A non-200 HTTP response must produce a diagnostic error detail.');
        Assert.isTrue(log.ReCAPTCHA_Error_Detail__c.length() <= 255, 'ReCAPTCHA_Error_Detail__c must never exceed the field length of 255 characters - the truncate() helper must always guard this, defensively, even for messages that are currently well within the limit.');
    }
}
