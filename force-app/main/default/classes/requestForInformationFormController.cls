public without sharing class requestForInformationFormController {

    @AuraEnabled(cacheable=true)
    public static RFI_Controller__c getRFIController(String rfi_controller_name){
        try {
            System.debug('name: ' + rfi_controller_name);
            RFI_Controller__c rfi_controller = [
                SELECT
                    Applicant_Type__c, 
                    Fields_to_Display__c 
                FROM RFI_Controller__c 
                WHERE Name =: rfi_controller_name
                LIMIT 1
            ];
            return rfi_controller;
        } catch (Exception e) {
            throw new AuraHandledException(rfi_controller_name + ' not found: ' + e.getMessage());
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
    public static List<String> getAcademicTerms() {
        try {
            Date today = System.today();
            List<Academic_Term__c> terms = [
                SELECT
                    Name
                FROM Academic_Term__c
                WHERE End_Application_Date__c >=: today
            ];

            List<String> term_names = new List<String>();
            for (Academic_Term__c term : terms) {
                term_names.add(term.Name);
            }
            return term_names;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving academic programs: ' + e.getMessage());
        }
    }
}
