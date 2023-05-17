/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/8/2023.
 */


@IsTest
private class ReusableLookupController_TEST {
    @TestSetup
    public static void setup() {
        List<Account> accounts_to_insert = new List<Account>();
        List<Id> search_results = new List<Id>();
        Id educational_institution_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
        Id administrative_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();
        Account high_school1 = new Account(
                Name = 'Test High School',
                RecordTypeId = educational_institution_id,
                Type = 'High School'
        );
        accounts_to_insert.add(high_school1);
        Account high_school2 = new Account(
                Name = 'New High School',
                RecordTypeId = educational_institution_id,
                Type = 'High School'
        );
        accounts_to_insert.add(high_school2);
        Account college_account1 = new Account(
                Name = 'School of Law',
                RecordTypeId = administrative_id,
                Banner_Key__c = 'STVCOLL-LAW'
        );
        accounts_to_insert.add(college_account1);
        Account college_account2 = new Account(
                Name = 'Undergraduate',
                RecordTypeId = administrative_id,
                Banner_Key__c = 'STVCOLL-UG'
        );
        accounts_to_insert.add(college_account2);
        insert accounts_to_insert;
    }

    @IsTest
    static void testBehavior() {

        ReusableLookupController.SearchWrapper search = new ReusableLookupController.SearchWrapper();
        search.objectApiName = 'Account';
        search.fieldApiName = 'Name';
        search.otherFieldApiName = 'BillingCity,BillingState';
        search.searchString = 'Test High';
        search.selectedRecordId = '';
        search.parentRecordId = '';
        search.parentFieldApiName = '';
        search.recordTypeName = 'Educational Institution';
        search.type = 'High School';

        List<ReusableLookupController.ResultWrapper> results = ReusableLookupController.fetchRecords(search);
        Test.startTest();
        System.assertEquals(results[0].mainField, 'Test High School');
        Test.stopTest();

    }
}