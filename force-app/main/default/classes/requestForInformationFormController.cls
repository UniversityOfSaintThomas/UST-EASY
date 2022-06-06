public without sharing class requestForInformationFormController {

    @AuraEnabled(cacheable=true)
    public static RFI_Controller__c getRFIController(String rfi_controller_name){
        try {
            System.debug('name: ' + rfi_controller_name);
            RFI_Controller__c rfi_controller = [
                SELECT 
                    Id,
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
    public static List<String> getAcademicPrograms(String academic_level) {
        return new List<String>();
    }
}
