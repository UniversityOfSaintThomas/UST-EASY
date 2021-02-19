/*******************************************************************************
@description This controller is used to display a list of applications available to the contact
@author Huron Consulting Group

Revision (s): 
*******************************************************************************/
public class ApplicationPortal {

    public Id contactId {get;set;}
    public List<Application__c> apps {get;set;}
    public Application_Control__c appControl{
        get{
            if(appControl == null){
                appControl = ApplicationUtilities.getApplicationControls(ApexPages.currentPage().getParameters().get('at'));
            }
            return appControl;
        }set;
    }

    public ApplicationPortal() {
        contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        if (UserInfo.getUserType().equals('Standard')) {
            contactId = Id.valueOf(ApexPages.currentPage().getParameters().get('contactId'));
        }
        if(contactId != null){
            apps = [
                    SELECT Id, Name,Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name, Intended_Term_of_Entry__r.Term_Status_Type__c, Application_Status__c
                    FROM Application__c
                    WHERE Contact__c = :contactId AND Intended_Term_of_Entry__r.Term_Status_Type__c = 'FUTURE'
                    ORDER BY Name];

        }
    }
}