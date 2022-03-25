/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/23/2021.
 */


public with sharing class ApplicationChecklistComponentController {

    public Application__c app { get; set; }
    public EASYApplicationInfo appInfoParam { get; set; }

    public ApplicationChecklistComponentController() {
    }

    public List<RequirementWrapper> getChecklistItems() {
        if (String.isNotBlank(appInfoParam.contactId) && String.isNotBlank(appInfoParam.appId)) {
            app = [
                    SELECT Id, Name, Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name,
                            Intended_Term_of_Entry__r.Term_Status_Type__c, Application_Status__c, Application_Control__c, Citizenship__c,
                            Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c
                    FROM Application__c
                    WHERE Id = :appInfoParam.appId
                    ORDER BY Name
            ];
           return checklistHelper.checklistRequirements(app, appInfoParam.contactId, appInfoParam.appControlId);
        }
        return null;

    }
}