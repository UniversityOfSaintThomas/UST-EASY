/*******************************************************************************
@description This controller is used to display a list of applications available to the contact
@author Huron Consulting Group

Revision (s): 
*******************************************************************************/
public class ApplicationPortal {

    public Id contactId { get; set; }
    public Map<Id, Application__c> applicationsByIds { get; set; }
    public Map<id, Application_Control__c> applicationControlsByIds { get; set; }
    public List<Id> applicationOrder { get; set; }
    public List<RequirementWrapper> rList { get; set; }
    public Application__c currentApp { get; set; }

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
        if (String.isNotBlank(contactId)) {
            applicationsByIds = new Map<Id, Application__c>([
                    SELECT Id, Application_Control__c, Application_Control__r.Id
                    FROM Application__c
                    WHERE Contact__c = :contactId
                    //TODO: reinstate FUTURE in this query
                    //AND Intended_Term_of_Entry__r.Term_Status_Type__c = 'FUTURE'
                    ORDER BY Name
            ]);

            //currentApp = applicationsByOrder[0];
            //rList = checklistHelper.checklistRequirements(currentApp, contactId, appControl);

            //system.debug(JSON.serializePretty(rList));

        }
    }
}