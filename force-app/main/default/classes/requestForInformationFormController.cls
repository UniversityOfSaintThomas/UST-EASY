public with sharing class requestForInformationFormController {

    @AuraEnabled(cacheable=true)
    public static List<String> getAcademicPrograms() {
        return new List<String>();
    }
}
