/**
 * Unit tests for ApplicationTriggerHandler.cls and ApplicationTrigger.trigger (ECRMSF-5511 /
 * ECRMSF-5529, tasks 19/21). Covers the submission-detection logic (status change matching the
 * Application_Control__r.Submit_Status__c configured value), the sparse-update re-query
 * requirement, the graceful handling of a missing Visualforce request context (this is the
 * normal case in a unit test - there is no VF page being rendered), and the full async capture
 * path via logSubmissionAttemptAsync.
 */
@isTest
private class ApplicationTriggerHandler_TEST {

    private class GeolocationMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success","city":"Minneapolis","regionName":"Minnesota","country":"United States"}');
            return res;
        }
    }

    @TestSetup
    static void setupData() {
        Contact con = new Contact(FirstName = 'Test', LastName = 'TriggerHandler', Email = 'test.triggerhandler@example.com');
        insert con;

        Application_Control__c controlWithSubmitStatus = new Application_Control__c(
                Name = 'Test Control With Submit Status',
                Application_Start_Status__c = 'Started App',
                Submit_Status__c = 'Submitted App'
        );
        Application_Control__c controlWithoutSubmitStatus = new Application_Control__c(
                Name = 'Test Control Without Submit Status',
                Application_Start_Status__c = 'Started App'
        );
        insert new List<Application_Control__c>{ controlWithSubmitStatus, controlWithoutSubmitStatus };

        Application__c appWithControl = new Application__c(
                Contact__c = con.Id,
                Application_Control__c = controlWithSubmitStatus.Id,
                Application_Status__c = 'Started App'
        );
        Application__c appWithoutControl = new Application__c(
                Contact__c = con.Id,
                Application_Status__c = 'Started App'
        );
        Application__c appWithControlNoSubmitStatus = new Application__c(
                Contact__c = con.Id,
                Application_Control__c = controlWithoutSubmitStatus.Id,
                Application_Status__c = 'Started App'
        );
        insert new List<Application__c>{ appWithControl, appWithoutControl, appWithControlNoSubmitStatus };
    }

    @isTest
    static void statusChangeMatchingSubmitStatusDispatchesAsyncCapture() {
        Test.setMock(HttpCalloutMock.class, new GeolocationMock());
        Application__c app = [SELECT Id FROM Application__c WHERE Application_Control__r.Submit_Status__c = 'Submitted App' LIMIT 1];

        Test.startTest();
        update new Application__c(Id = app.Id, Application_Status__c = 'Submitted App');
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id, Event_Type__c, Application__c FROM Application_Login__c WHERE Application__c = :app.Id AND Event_Type__c = 'Submission'];
        Assert.areEqual(1, logs.size(), 'A status change to the configured Submit_Status__c value must dispatch exactly one Submission-type Application_Login__c record via the async future method.');
    }

    @isTest
    static void statusChangeNotMatchingSubmitStatusDoesNotDispatch() {
        Application__c app = [SELECT Id FROM Application__c WHERE Application_Control__r.Submit_Status__c = 'Submitted App' LIMIT 1];

        Test.startTest();
        update new Application__c(Id = app.Id, Application_Status__c = 'Complete App');
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c WHERE Application__c = :app.Id];
        Assert.areEqual(0, logs.size(), 'A status change to a value OTHER than the configured Submit_Status__c must not dispatch any capture.');
    }

    @isTest
    static void applicationWithoutControlIsSkipped() {
        Application__c app = [SELECT Id FROM Application__c WHERE Application_Control__c = null LIMIT 1];

        Test.startTest();
        update new Application__c(Id = app.Id, Application_Status__c = 'Submitted App');
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c WHERE Application__c = :app.Id];
        Assert.areEqual(0, logs.size(), 'An Application__c with no Application_Control__c at all must be skipped entirely - there is no configured submit status to match against.');
    }

    @isTest
    static void applicationWithControlButNoSubmitStatusIsSkipped() {
        Application__c app = [
                SELECT Id
                FROM Application__c
                WHERE Application_Control__c != null
                AND Application_Control__r.Submit_Status__c = null
                LIMIT 1
        ];

        Test.startTest();
        update new Application__c(Id = app.Id, Application_Status__c = 'Submitted App');
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c WHERE Application__c = :app.Id];
        Assert.areEqual(0, logs.size(), 'An Application_Control__c with a blank Submit_Status__c must be skipped - there is nothing to compare against.');
    }

    @isTest
    static void noStatusChangeDoesNotDispatch() {
        Application__c app = [SELECT Id, Application_Status__c FROM Application__c WHERE Application_Control__r.Submit_Status__c = 'Submitted App' LIMIT 1];

        Test.startTest();
        // Update a different, unrelated field so the trigger fires but Application_Status__c
        // does not actually change value.
        update new Application__c(Id = app.Id, Application_Status__c = app.Application_Status__c);
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c WHERE Application__c = :app.Id];
        Assert.areEqual(0, logs.size(), 'If Application_Status__c does not actually change value, no capture should be dispatched, even if the trigger fires.');
    }

    @isTest
    static void sparseUpdateStillCorrectlyReQueriesRequiredFields() {
        // This is the core sparse-update correctness test: the update DML below ONLY sets Id and
        // Application_Status__c, mirroring exactly what the three real call sites
        // (ApplicationRequirement.cls, ApplicationChecklist.cls,
        // ApplicationChecklistComponentController.cls) do. If the trigger handler incorrectly
        // relied on Trigger.new for Contact__c/Application_Control__r instead of re-querying,
        // this test would fail because those fields would be null on the sparse sObject.
        Application__c app = [SELECT Id FROM Application__c WHERE Application_Control__r.Submit_Status__c = 'Submitted App' LIMIT 1];

        Test.startTest();
        update new Application__c(Id = app.Id, Application_Status__c = 'Submitted App');
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id, Contact__c FROM Application_Login__c WHERE Application__c = :app.Id];
        Assert.areEqual(1, logs.size(), 'The sparse update must still correctly re-query Contact__c and Application_Control__r.Submit_Status__c and dispatch the capture.');
        Assert.isNotNull(logs[0].Contact__c, 'The captured Application_Login__c must have a real Contact__c populated, proving the re-query worked.');
    }

    @isTest
    static void logSubmissionAttemptAsyncGracefullyHandlesMissingHeadersAndProducesUnavailableRecaptcha() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new GeolocationMock());

        Test.startTest();
        ApplicationTriggerHandler.logSubmissionAttemptAsync(con.Id, app.Id, '24.152.140.219', 'Mozilla/5.0 Test', 'https://example.com/submit');
        Test.stopTest();

        Application_Login__c log = [
                SELECT Event_Type__c, ReCAPTCHA_Score_Status__c, ReCAPTCHA_Score__c, Geolocation__c, IP_Address__c, User_Agent_Raw__c
                FROM Application_Login__c
                WHERE Application__c = :app.Id AND Contact__c = :con.Id
                LIMIT 1
        ];

        Assert.areEqual('Submission', log.Event_Type__c, 'The dispatched record must be typed Submission.');
        Assert.areEqual('Unavailable', log.ReCAPTCHA_Score_Status__c, 'With no reCAPTCHA token available for Submission events, the status must gracefully degrade to Unavailable, never Error.');
        Assert.isNull(log.ReCAPTCHA_Score__c, 'The score must be null when Unavailable.');
        Assert.areEqual('Minneapolis, Minnesota, United States', log.Geolocation__c, 'The geolocation lookup must still succeed using the passed-in IP address.');
        Assert.areEqual('24.152.140.219', log.IP_Address__c, 'The IP address passed in must be stored as-is.');
    }

    @isTest
    static void logSubmissionAttemptAsyncNoOpsOnNullContactId() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        ApplicationTriggerHandler.logSubmissionAttemptAsync(null, app.Id, '24.152.140.219', 'Mozilla/5.0 Test', null);
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c WHERE Application__c = :app.Id];
        Assert.areEqual(0, logs.size(), 'A null Contact Id must result in a no-op - no Application_Login__c record should be created.');
    }

    @isTest
    static void logSubmissionAttemptAsyncNoOpsOnNullApplicationId() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        ApplicationTriggerHandler.logSubmissionAttemptAsync(con.Id, null, '24.152.140.219', 'Mozilla/5.0 Test', null);
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c WHERE Contact__c = :con.Id];
        Assert.areEqual(0, logs.size(), 'A null Application Id must result in a no-op - no Application_Login__c record should be created.');
    }

    @isTest
    static void bulkStatusChangeDispatchesOnePerQualifyingApplication() {
        // Bulk-safety test: create additional qualifying Applications and update them all in one
        // DML statement, confirming the trigger handler processes a full batch correctly rather
        // than only handling a single record.
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Application_Control__c control = [SELECT Id FROM Application_Control__c WHERE Submit_Status__c = 'Submitted App' LIMIT 1];

        List<Application__c> moreApps = new List<Application__c>();
        for (Integer i = 0; i < 3; i++) {
            moreApps.add(new Application__c(Contact__c = con.Id, Application_Control__c = control.Id, Application_Status__c = 'Started App'));
        }
        insert moreApps;

        Test.setMock(HttpCalloutMock.class, new GeolocationMock());

        List<Application__c> toUpdate = new List<Application__c>();
        for (Application__c app : moreApps) {
            toUpdate.add(new Application__c(Id = app.Id, Application_Status__c = 'Submitted App'));
        }

        Test.startTest();
        update toUpdate;
        Test.stopTest();

        List<Application_Login__c> logs = [SELECT Id FROM Application_Login__c WHERE Application__c IN :moreApps AND Event_Type__c = 'Submission'];
        Assert.areEqual(3, logs.size(), 'A bulk update of 3 qualifying Applications must dispatch exactly 3 Submission captures, one per Application.');
    }
}
