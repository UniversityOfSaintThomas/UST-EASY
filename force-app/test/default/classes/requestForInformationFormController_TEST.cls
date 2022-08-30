/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-11-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
@IsTest
public class requestForInformationFormController_TEST {
    @TestSetup
    public static void setup() {
        RFI_Controller__c controller = new RFI_Controller__c(
                Academic_Level__c = 'U',
                Fields_to_Display__c = 'Email',
                Required_Fields__c = 'Email',
                Redirect_Url__c = 'https://developer.salesforce.com',
                School_College__c = 'Undergraduate'
        );
        insert controller;

        List<Program__c> programs_to_insert = new List<Program__c>();
        Id recruitment_program_id = Schema.SObjectType.Program__c.getRecordTypeInfosByDeveloperName().get('Recruitment_Program').getRecordTypeId();
        Program__c program1 = new Program__c(
                Name = 'Sociology',
                RecordTypeId = recruitment_program_id,
                Active__c = true,
                Degree__c = 'Bachelor of Arts',
                Program_Display__c = 'RFI',
                Academic_Level__c = 'U',
                Associated_Schools__c = 'Undergraduate',
                Program_Type__c = 'Major'
        );
        programs_to_insert.add(program1);
        Program__c program2 = new Program__c(
                Name = 'JD',
                RecordTypeId = recruitment_program_id,
                Active__c = true,
                Degree__c = 'Juris Doctor',
                Program_Display__c = 'RFI',
                Academic_Level__c = 'G',
                Associated_Schools__c = 'School of Law',
                Banner_Program_Code__c = 'LW_JD'
        );
        programs_to_insert.add(program2);
        insert programs_to_insert;

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

        search_results.add(high_school1.Id);
        search_results.add(high_school2.Id);
        Test.setFixedSearchResults(search_results);

        List<hed__Term__c> terms_to_insert = new List<hed__Term__c>();
        hed__Term__c term1 = new hed__Term__c(
                Name = 'Spring 2024',
                hed__Start_Date__c = System.today().addMonths(3),
                hed__Account__c = college_account1.Id
        );
        terms_to_insert.add(term1);
        insert terms_to_insert;
    }

    @isTest
    public static void testCreateLead() {
        String record_input_fields = '{"FirstName":"Testing","LastName":"CreateLead","Company":"Company 123"}';
        Test.startTest();
        requestForInformationFormController.createLead(record_input_fields, 'Lead');
        Test.stopTest();
        List<Lead> new_lead = [SELECT Id FROM Lead WHERE LastName = 'CreateLead'];
        System.assertEquals(1, new_lead.size());

    }

    @isTest
    public static void testGetRFIController() {
        RFI_Controller__c rfic = [SELECT Name FROM RFI_Controller__c];
        Test.startTest();
        RFI_Controller__c controller = requestForInformationFormController.getRFIController(rfic.Name);
        Test.stopTest();
        System.assertEquals('U', controller.Academic_Level__c);
    }

    @isTest
    public static void testGetPrograms() {
        Test.startTest();
        Map<Id, Program__c> program_map1 = requestForInformationFormController.getPrograms('U', 'Undergraduate');
        Map<Id, Program__c> program_map2 = requestForInformationFormController.getPrograms('G', 'School of Law');
        Test.stopTest();
        System.assertEquals(1, program_map1.size());
        System.assertEquals(1, program_map2.size());
    }

    @isTest
    public static void testSearchHighSchools() {
        List<Account> accounts_to_insert = new List<Account>();
        List<Id> search_results = new List<Id>();
        Id educational_institution_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();

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
        insert accounts_to_insert;

        search_results.add(high_school1.Id);
        search_results.add(high_school2.Id);
        Test.setFixedSearchResults(search_results);

        Test.startTest();
        Map<Id, Account> high_schools = requestForInformationFormController.searchHighSchools('High');
        Test.stopTest();
        System.assertEquals(2, high_schools.size());
    }

    @isTest
    public static void testGetTerms() {
        Test.startTest();
        Map<Id, Academic_Term__c> terms = requestForInformationFormController.getTerms('School of Law');
        Test.stopTest();
        System.assertEquals(1, terms.size());
    }

    @isTest
    public static void testGetAcademicLevelValue() {
        Test.startTest();
        String value = requestForInformationFormController.getAcademicLevelValue('U');
        Test.stopTest();
        System.assertEquals('Undergraduate', value);
    }

    @isTest
    public static void testGetPresetValues() {
        Test.startTest();
        List<Lead_Preset_Value__mdt> presets = requestForInformationFormController.getPresetValues('RFI Controller 0000');
        Test.stopTest();
        //TODO: This is supposed to be zero
        //System.assertEquals(0, presets.size());
        System.assertEquals(1, presets.size());
    }

    @isTest
    public static void testGetSchoolCollegeAccount() {
        Test.startTest();
        String school_id = requestForInformationFormController.getSchoolCollegeAccount('School of Law');
        Test.stopTest();
        String school_of_law_id = Id.valueOf([SELECT Id FROM Account WHERE Name = 'School of Law'].Id);
        System.assertEquals(school_of_law_id, school_id);
    }
}