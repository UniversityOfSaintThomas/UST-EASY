/*******************************************************************************
@description This controller is used to display a list of applications available to the contact
@author Huron Consulting Group

Revision (s): 
*******************************************************************************/
public class ApplicationPortal {

    public Id contactId { get; set; }
    public Map<Id, Application__c> applicationsByIds { get; set; }
    public Map<Id, Map<Id, RequirementWrapper>> applicationRequirementMap { get; set; }

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
            applicationsByIds = new Map<Id, Application__c>([
                    SELECT Id, Name,Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name,
                            Intended_Term_of_Entry__r.Term_Status_Type__c, Application_Status__c, Application_Control__c, Citizenship__c,
                            Generic_Filter_1__c,Generic_Filter_2__c,Generic_Filter_3__c,Generic_Filter_4__c
                    FROM Application__c
                    WHERE Contact__c = :contactId AND Intended_Term_of_Entry__r.Term_Status_Type__c = 'FUTURE'
                    ORDER BY Name
            ]);

            Map<Id, List<Id>> controlApplicationIds = new Map<Id, List<Id>>();
            for (Application__c appsIn : applicationsByIds.values()) {
                if (controlApplicationIds.containsKey(appsIn.Application_Control__c)) {
                    List<Id> appIdIn = controlApplicationIds.get(appsIn.Application_Control__c);
                    appIdIn.add(appsIn.id);
                    controlApplicationIds.put(appsIn.Application_Control__c, appIdIn);
                } else {
                    controlApplicationIds.put(appsIn.Application_Control__c, new List<Id>{
                            appsIn.id
                    });
                }
            }

            Set<Id> reqIds = new Set<Id>();

            List<Requirement__c> applicationsAndRequirements = [
                    SELECT Id, Internal_Only__c, Internal_Only_Show_on_Checklist__c, Display_on_Checklist__c, Name, Label__c, Active__c,
                            Intended_Program__c, Application_Status__c, Applicant_Type__c, Citizenship__c, Degree_Type__c, Delivery_Type__c,
                            Residency__c, School_College__c, Student_Type__c, Generic_Filter_1__c, Generic_Filter_2__c,
                            Generic_Filter_3__c, Generic_Filter_4__c, Application_Control__c, Display_Order__c
                    FROM Requirement__c
                    WHERE Application_Control__c IN :controlApplicationIds.keySet()
                    AND Active__c = :true
                    AND Show_on_Application_Creation__c = FALSE
                    ORDER BY Display_Order__c ASC NULLS LAST
            ];


            applicationRequirementMap = new Map<Id, Map<Id, RequirementWrapper>>();
            for (Requirement__c r : applicationsAndRequirements) {
                for (Id appId : controlApplicationIds.get(r.Application_Control__c)) {
                    Application__c currentApp = applicationsByIds.get(appId);
                    if (ApplicationFilter.filter(currentApp, r)) {
                        reqIds.add(r.Id);
                        Map<Id, RequirementWrapper> reqMap = new Map<Id, RequirementWrapper>();
                        RequirementWrapper newReg = new RequirementWrapper(r);
                        reqMap.put(r.Id, newReg);
                        if (applicationRequirementMap.containsKey(appId)) {
                            applicationRequirementMap.get(appId).put(r.Id, newReg);
                        } else {
                            applicationRequirementMap.put(appId, new Map<Id, RequirementWrapper>{
                                    r.Id => newReg
                            });
                        }

                    }
                }
            }
        }
    }
}