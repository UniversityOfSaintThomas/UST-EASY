public without sharing class requestForInformationFormController {

    @AuraEnabled(cacheable=true)
    public static RFI_Controller__c getRFIController(String rfi_controller_name){
        try {
            return [
                SELECT
                    Applicant_Type__c, 
                    Academic_Level__c,
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
}
