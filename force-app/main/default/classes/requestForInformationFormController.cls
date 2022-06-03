public with sharing class requestForInformationFormController {

    @AuraEnabled(cacheable=true)
    public static RFI_Controller__c getRFIController(String rfi_controller_name){
        try {
            RFI_Controller__c rfi_controller = [
                SELECT 
                    Applicant_Type__c, 
                    Fields_to_Display__c 
                FROM RFI_Controller__c 
                WHERE Name =: rfi_controller_name
            ];
            return rfi_controller;
        } catch (Exception e) {
            throw new AuraHandledException(rfi_controller_name + ' not found: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAcademicPrograms() {
        return new List<String>();
    }
}
