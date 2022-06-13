public without sharing class requestForInformationFormController {

    @AuraEnabled(cacheable=true)
    public static RFI_Controller__c getRFIController(String rfi_controller_name){
        try {
            return [
                SELECT
                    Academic_Level__c,
                    Applicant_Status__c,
                    Fields_to_Display__c
                FROM RFI_Controller__c 
                WHERE Name =: rfi_controller_name
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving RFI Controller: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, Program__c> getAcademicPrograms(String academic_level) {
        try {
            Id recruitment_record_type_id = Schema.SObjectType.Program__c.getRecordTypeInfosByDeveloperName().get('Recruitment_Program').getRecordTypeId();
            Map<Id, Program__c> programs = new Map<Id, Program__c>([
                SELECT
                    Name
                FROM Program__c
                WHERE RecordTypeId =: recruitment_record_type_id
                AND Academic_Level__c =: academic_level
                AND Program_Display__c INCLUDES ('RFI')
                AND Active__c = true
                AND (Program_Type__c = 'Major'
                    OR Program_Type__c = 'Pre-Professional')
            ]);
            return programs;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving academic programs: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, hed__Term__c> getAcademicTerms() {
        try {
            Date today = System.today();
            Map<Id, hed__Term__c> terms = new Map<Id, hed__Term__c>([
                SELECT
                    Id,
                    Name
                FROM hed__Term__c
                WHERE End_Application_Date__c >=: today
            ]);
            return terms;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving academic programs: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<Id, Account> searchHighSchools(String search_term){
        try {
            Map<Id, Account> high_school_map = new Map<Id, Account>();
                Id educational_record_type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
                List<List<Account>> high_schools = [FIND :search_term IN NAME FIELDS RETURNING Account(Id, Name WHERE RecordTypeId =: educational_record_type ORDER BY Name)];
                for (List<Account> account_list : high_schools) {
                    for (Account high_school : account_list) {
                        high_school_map.put(high_school.Id, high_school);
                    }
                }
            return high_school_map;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getAcademicLevelValue(String api_name){
        try {
            String level = '';
            Schema.DescribeFieldResult describe_result = RFI_Controller__c.Academic_Level__c.getDescribe();
            List<Schema.PicklistEntry> values = describe_result.getPicklistValues();
            for(Schema.PicklistEntry value : values) {
                if (value.getValue() == api_name) {
                    return value.getLabel();
                }
            }
            return level;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
