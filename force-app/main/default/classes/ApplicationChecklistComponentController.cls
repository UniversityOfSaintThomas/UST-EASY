/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/23/2021.
 */


public with sharing class ApplicationChecklistComponentController {

    public Id appId { get; set; }
    public Id contactId { get; set; }
    public Application__c app { get; set; }
    public Application_Control__c appControl { get; set; }
    public Id currentApp { get; set; }

    public ApplicationChecklistComponentController() {

    }

    public List<RequirementWrapper> getChecklistItems() {
        contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        if (UserInfo.getUserType().equals('Standard')) {
            contactId = Id.valueOf(ApexPages.currentPage().getParameters().get('contactId'));
        }
        if (contactId != null) {
            app = [
                    SELECT Id, Name,Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name,
                            Intended_Term_of_Entry__r.Term_Status_Type__c, Application_Status__c, Application_Control__c, Citizenship__c,
                            Generic_Filter_1__c,Generic_Filter_2__c,Generic_Filter_3__c,Generic_Filter_4__c
                    FROM Application__c
                    WHERE Id = :appId
                    ORDER BY Name
            ];

            return checklistHelper.checklistRequirements(app, contactId, appControl);
        }
        return null;

    }
}