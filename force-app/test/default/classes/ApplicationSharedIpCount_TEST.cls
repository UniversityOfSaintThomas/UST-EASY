/**
 * Unit tests for ApplicationSharedIpCount.cls (ECRMSF-5511 / ECRMSF-5529, task 15). Covers the
 * pure aggregate calculation (countDistinctContactsForIp) and the full update path
 * (updateSharedIpCount), including the critical Submission-only scoping rule (Login-type rows
 * on the same IP must never inflate the count) and the trailing-30-day window boundary.
 */
@isTest
private class ApplicationSharedIpCount_TEST {

    @TestSetup
    static void setupData() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contacts.add(new Contact(FirstName = 'Test' + i, LastName = 'SharedIpCount' + i, Email = 'test.sharedip' + i + '@example.com'));
        }
        insert contacts;

        List<Application__c> applications = new List<Application__c>();
        for (Contact con : contacts) {
            applications.add(new Application__c(Contact__c = con.Id));
        }
        insert applications;
    }

    @isTest
    static void countReturnsZeroForBlankIp() {
        Integer count = ApplicationSharedIpCount.countDistinctContactsForIp('');
        Assert.areEqual(0, count, 'A blank IP address must return a count of 0 without querying.');
    }

    @isTest
    static void countReturnsZeroForNullIp() {
        Integer count = ApplicationSharedIpCount.countDistinctContactsForIp(null);
        Assert.areEqual(0, count, 'A null IP address must return a count of 0 without querying.');
    }

    @isTest
    static void countReturnsZeroWhenNoMatchingRowsExist() {
        Integer count = ApplicationSharedIpCount.countDistinctContactsForIp('203.0.113.1');
        Assert.areEqual(0, count, 'An IP with no Application_Login__c rows at all must return a count of 0.');
    }

    @isTest
    static void countReflectsDistinctContactsSharingIp() {
        List<Contact> contacts = [SELECT Id FROM Contact ORDER BY LastName LIMIT 3];
        List<Application__c> applications = [SELECT Id, Contact__c FROM Application__c ORDER BY CreatedDate LIMIT 3];
        String sharedIp = '198.51.100.10';

        List<Application_Login__c> logs = new List<Application_Login__c>();
        for (Integer i = 0; i < 2; i++) {
            logs.add(new Application_Login__c(
                    Contact__c = contacts[i].Id,
                    Application__c = applications[i].Id,
                    Event_Type__c = 'Submission',
                    ReCAPTCHA_Score_Status__c = 'Unavailable',
                    IP_Address__c = sharedIp
            ));
        }
        insert logs;

        Integer count = ApplicationSharedIpCount.countDistinctContactsForIp(sharedIp);
        Assert.areEqual(2, count, 'The count must reflect the number of DISTINCT Contacts sharing the IP across Submission events.');
    }

    @isTest
    static void countDoesNotDoubleCountSameContactMultipleSubmissions() {
        Contact con = [SELECT Id FROM Contact ORDER BY LastName LIMIT 1];
        Application__c app = [SELECT Id FROM Application__c WHERE Contact__c = :con.Id LIMIT 1];
        String sharedIp = '198.51.100.20';

        insert new List<Application_Login__c>{
                new Application_Login__c(Contact__c = con.Id, Application__c = app.Id, Event_Type__c = 'Submission', ReCAPTCHA_Score_Status__c = 'Unavailable', IP_Address__c = sharedIp),
                new Application_Login__c(Contact__c = con.Id, Application__c = app.Id, Event_Type__c = 'Submission', ReCAPTCHA_Score_Status__c = 'Unavailable', IP_Address__c = sharedIp)
        };

        Integer count = ApplicationSharedIpCount.countDistinctContactsForIp(sharedIp);
        Assert.areEqual(1, count, 'The same Contact submitting twice from the same IP must count once, not twice - this is a COUNT_DISTINCT(Contact__c), not a row count.');
    }

    @isTest
    static void countExcludesLoginAndRegistrationEventTypes() {
        List<Contact> contacts = [SELECT Id FROM Contact ORDER BY LastName LIMIT 2];
        List<Application__c> applications = [SELECT Id, Contact__c FROM Application__c ORDER BY CreatedDate LIMIT 2];
        String sharedIp = '198.51.100.30';

        insert new List<Application_Login__c>{
                new Application_Login__c(Contact__c = contacts[0].Id, Application__c = applications[0].Id, Event_Type__c = 'Login', ReCAPTCHA_Score_Status__c = 'Unavailable', IP_Address__c = sharedIp),
                new Application_Login__c(Contact__c = contacts[1].Id, Application__c = applications[1].Id, Event_Type__c = 'Registration', ReCAPTCHA_Score_Status__c = 'Unavailable', IP_Address__c = sharedIp)
        };

        Integer count = ApplicationSharedIpCount.countDistinctContactsForIp(sharedIp);
        Assert.areEqual(0, count, 'Login and Registration events on the same IP must NOT be counted - this aggregate is deliberately scoped to Submission events only, matching the "compare against submission IP only" design decision.');
    }

    @isTest
    static void countExcludesRowsOlderThan30Days() {
        Contact con = [SELECT Id FROM Contact ORDER BY LastName LIMIT 1];
        Application__c app = [SELECT Id FROM Application__c WHERE Contact__c = :con.Id LIMIT 1];
        String sharedIp = '198.51.100.40';

        Application_Login__c oldLog = new Application_Login__c(
                Contact__c = con.Id,
                Application__c = app.Id,
                Event_Type__c = 'Submission',
                ReCAPTCHA_Score_Status__c = 'Unavailable',
                IP_Address__c = sharedIp
        );
        insert oldLog;

        // CreatedDate cannot be set on insert, so backdate it via a direct update - this is a
        // well-known test-only technique (does not work outside test context on most objects).
        Test.setCreatedDate(oldLog.Id, DateTime.now().addDays(-31));

        Integer count = ApplicationSharedIpCount.countDistinctContactsForIp(sharedIp);
        Assert.areEqual(0, count, 'A Submission event older than 30 days must be excluded from the trailing-30-day count.');
    }

    @isTest
    static void updateSharedIpCountWritesToApplicationField() {
        List<Contact> contacts = [SELECT Id FROM Contact ORDER BY LastName LIMIT 2];
        List<Application__c> applications = [SELECT Id, Contact__c FROM Application__c ORDER BY CreatedDate LIMIT 2];
        String sharedIp = '198.51.100.50';

        insert new List<Application_Login__c>{
                new Application_Login__c(Contact__c = contacts[0].Id, Application__c = applications[0].Id, Event_Type__c = 'Submission', ReCAPTCHA_Score_Status__c = 'Unavailable', IP_Address__c = sharedIp),
                new Application_Login__c(Contact__c = contacts[1].Id, Application__c = applications[1].Id, Event_Type__c = 'Submission', ReCAPTCHA_Score_Status__c = 'Unavailable', IP_Address__c = sharedIp)
        };

        Test.startTest();
        ApplicationSharedIpCount.updateSharedIpCount(applications[0].Id, sharedIp);
        Test.stopTest();

        Application__c updated = [SELECT Shared_IP_User_Count_30Day__c FROM Application__c WHERE Id = :applications[0].Id];
        Assert.areEqual(2, updated.Shared_IP_User_Count_30Day__c, 'updateSharedIpCount must write the aggregate result to Shared_IP_User_Count_30Day__c on the given Application__c.');
    }

    @isTest
    static void updateSharedIpCountNoOpsOnBlankApplicationId() {
        // Must not throw when applicationId is null - this is a graceful no-op per the method's
        // documented contract.
        Test.startTest();
        ApplicationSharedIpCount.updateSharedIpCount(null, '198.51.100.60');
        Test.stopTest();
        // No assertion needed beyond "did not throw" - reaching this line proves the no-op worked.
    }

    @isTest
    static void updateSharedIpCountNoOpsOnBlankIp() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        ApplicationSharedIpCount.updateSharedIpCount(app.Id, null);
        Test.stopTest();

        Application__c unchanged = [SELECT Shared_IP_User_Count_30Day__c FROM Application__c WHERE Id = :app.Id];
        Assert.isNull(unchanged.Shared_IP_User_Count_30Day__c, 'A blank IP address must result in a no-op - the Application__c field must remain untouched.');
    }
}
