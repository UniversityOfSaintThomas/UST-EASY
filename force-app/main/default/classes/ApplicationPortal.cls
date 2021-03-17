/*******************************************************************************
@description This controller is used to display a list of applications available to the contact
@author Huron Consulting Group

Revision (s): 
*******************************************************************************/
public class ApplicationPortal {

    public Id contactId { get; set; }
    public Map<Id, Application__c> applicationsByIds { get; set; }
    public List<Id> applicationOrder { get; set; }
    public List<RequirementWrapper> rList { get; set; }
    public List<Application__c> applicationsByOrder { get; set; }
    public Application__c currentApp {get;set;}

    public Application_Control__c appControl {
        get {
            if (appControl == null) {
                appControl = ApplicationUtilities.getApplicationControls(ApexPages.currentPage().getParameters().get('at'));
            }
            return appControl;
        }
        set;
    }

    public ApplicationPortal() {
        contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        if (UserInfo.getUserType().equals('Standard')) {
            contactId = Id.valueOf(ApexPages.currentPage().getParameters().get('contactId'));
        }
        if (contactId != null) {
            applicationsByOrder = [
                    SELECT Id, Name,Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name,
                            Intended_Term_of_Entry__r.Term_Status_Type__c, Application_Status__c, Application_Control__c, Citizenship__c,
                            Generic_Filter_1__c,Generic_Filter_2__c,Generic_Filter_3__c,Generic_Filter_4__c
                    FROM Application__c
                    WHERE Contact__c = :contactId AND Intended_Term_of_Entry__r.Term_Status_Type__c = 'FUTURE'
                    ORDER BY Name
            ];

            currentApp = applicationsByOrder[0];
            //rList = checklistHelper.checklistRequirements(currentApp, contactId, appControl);

            //system.debug(JSON.serializePretty(rList));

        }
    }
}