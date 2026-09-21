/**
 * Unit tests for ApplicationReCaptcha.cls (ECRMSF-5511 / ECRMSF-5529). Covers the
 * graceful-degradation contract: every failure mode must return an Unavailable/Error status with
 * a null score, never throw, and only a genuinely successful, fully-parsed response may return
 * STATUS_SCORED with a real score.
 */
@isTest
private class ApplicationReCaptcha_TEST {

    /**
     * @description Simple HttpCalloutMock that returns a fixed status code and body, used to
     * simulate every reCAPTCHA siteverify response shape under test without making a real callout.
     */
    private class StaticResponseMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        StaticResponseMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }

    @TestSetup
    static void setupSettings() {
        // Application_Setting__c has two required fields unrelated to reCAPTCHA
        // (Community_Profile_Ids__c, Permission_Set_Id__c) that must be populated on any record
        // saved in a test context - getOrgDefaults() returns a blank in-memory record here (test
        // contexts never see real org data without SeeAllData=true, which must never be used),
        // so those fields need dummy values purely to satisfy the required-field validation.
        Application_Setting__c settings = Application_Setting__c.getOrgDefaults();
        settings.Community_Profile_Ids__c = '00eQL0000000000AAA';
        settings.Permission_Set_Id__c = '0PSQL0000000000AAA';
        settings.reCAPTCHA_Secret_Key__c = 'test-secret-key';
        settings.reCAPTCHA_Endpoint__c = 'https://www.google.com/recaptcha/api/siteverify';
        upsert settings;
    }

    @isTest
    static void blankTokenReturnsUnavailable() {
        ApplicationReCaptcha.ReCaptchaResult result = ApplicationReCaptcha.isReCAPTCHAValid('');

        Assert.isNull(result.score, 'Score must be null when no token was provided.');
        Assert.areEqual(ApplicationReCaptcha.STATUS_UNAVAILABLE, result.status, 'A blank token must resolve to Unavailable, never Error.');
        Assert.isNotNull(result.errorDetail, 'A diagnostic error detail should be present for debugging.');
    }

    @isTest
    static void nullTokenReturnsUnavailable() {
        ApplicationReCaptcha.ReCaptchaResult result = ApplicationReCaptcha.isReCAPTCHAValid(null);

        Assert.isNull(result.score, 'Score must be null when no token was provided.');
        Assert.areEqual(ApplicationReCaptcha.STATUS_UNAVAILABLE, result.status, 'A null token must resolve to Unavailable, never Error.');
    }

    @isTest
    static void missingConfigReturnsUnavailable() {
        Application_Setting__c settings = Application_Setting__c.getOrgDefaults();
        settings.reCAPTCHA_Secret_Key__c = null;
        settings.reCAPTCHA_Endpoint__c = null;
        upsert settings;

        ApplicationReCaptcha.ReCaptchaResult result = ApplicationReCaptcha.isReCAPTCHAValid('some-token');

        Assert.isNull(result.score, 'Score must be null when reCAPTCHA is not configured.');
        Assert.areEqual(ApplicationReCaptcha.STATUS_UNAVAILABLE, result.status, 'Missing configuration must resolve to Unavailable, never Error.');
    }

    @isTest
    static void successfulScoredResponseReturnsScored() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(200, '{"success":true,"score":0.9,"action":"login"}'));

        Test.startTest();
        ApplicationReCaptcha.ReCaptchaResult result = ApplicationReCaptcha.isReCAPTCHAValid('valid-token');
        Test.stopTest();

        Assert.areEqual(ApplicationReCaptcha.STATUS_SCORED, result.status, 'A well-formed successful response must resolve to Scored.');
        Assert.areEqual(0.9, result.score, 'The parsed score must match the response body.');
        Assert.isNull(result.errorDetail, 'A successful scored result should have no error detail.');
    }

    @isTest
    static void unsuccessfulResponseReturnsUnavailableNotError() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(200, '{"success":false,"error-codes":["invalid-input-response"]}'));

        Test.startTest();
        ApplicationReCaptcha.ReCaptchaResult result = ApplicationReCaptcha.isReCAPTCHAValid('bad-token');
        Test.stopTest();

        Assert.isNull(result.score, 'Score must be null when Google reports success=false.');
        Assert.areEqual(ApplicationReCaptcha.STATUS_UNAVAILABLE, result.status, 'success=false must resolve to Unavailable, not Error - we cannot reliably distinguish invalid token from quota exhaustion.');
    }

    @isTest
    static void missingScoreInSuccessfulResponseReturnsUnavailable() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(200, '{"success":true,"action":"login"}'));

        Test.startTest();
        ApplicationReCaptcha.ReCaptchaResult result = ApplicationReCaptcha.isReCAPTCHAValid('valid-token');
        Test.stopTest();

        Assert.isNull(result.score, 'Score must be null when the response omits a score field.');
        Assert.areEqual(ApplicationReCaptcha.STATUS_UNAVAILABLE, result.status, 'A missing score field must resolve to Unavailable.');
    }

    @isTest
    static void non200HttpStatusReturnsUnavailable() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(503, 'Service Unavailable'));

        Test.startTest();
        ApplicationReCaptcha.ReCaptchaResult result = ApplicationReCaptcha.isReCAPTCHAValid('some-token');
        Test.stopTest();

        Assert.isNull(result.score, 'Score must be null on a non-200 HTTP response.');
        Assert.areEqual(ApplicationReCaptcha.STATUS_UNAVAILABLE, result.status, 'A non-200 response (e.g. quota exhaustion) must resolve to Unavailable, never Error.');
        Assert.isTrue(result.errorDetail.contains('503'), 'The diagnostic detail should mention the HTTP status code encountered.');
    }

    @isTest
    static void malformedJsonResponseReturnsUnavailable() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(200, 'not valid json{{{'));

        Test.startTest();
        ApplicationReCaptcha.ReCaptchaResult result = ApplicationReCaptcha.isReCAPTCHAValid('some-token');
        Test.stopTest();

        Assert.isNull(result.score, 'Score must be null when the response body cannot be parsed.');
        Assert.areEqual(ApplicationReCaptcha.STATUS_UNAVAILABLE, result.status, 'A parsing failure must be caught and resolved to Unavailable, never thrown.');
    }

    @isTest
    static void recaptchaSettingsWrapperExposesOnlyPublicFields() {
        ApplicationReCaptcha.RecaptchaSettings settings = new ApplicationReCaptcha.RecaptchaSettings('site-key-123', 'https://www.google.com/recaptcha/api.js');

        Assert.areEqual('site-key-123', settings.publicKey, 'The public key must be exposed as provided.');
        Assert.areEqual('https://www.google.com/recaptcha/api.js', settings.apiUrl, 'The API URL must be exposed as provided.');
    }
}
