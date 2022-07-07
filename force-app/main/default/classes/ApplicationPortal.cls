/*******************************************************************************
@description This controller is used to display a list of applications available to the contact
@author Huron Consulting Group

Revision (s): 
*******************************************************************************/
public class ApplicationPortal {

    public Map<Id, Application__c> applicationsByIds { get; set; }
    public Integer applicationMapSize { get; set; }
    public Map<Id, Application_Control__c> appControlsByAppIds { get; set; }
    public Map<Id, List<RequirementWrapper>> checklistsByAppIds { get; set; }
    public EASYApplicationInfo appInfo { get; set; }
    public Map<Id, EASYApplicationInfo> appInfoMapByAppId { get; set; }
    public String template { get; set; }

    public ApplicationPortal() {
        if (appInfo == null) {
            appInfo = ApplicationUtilities.gatherApplicationInfo();
        }
        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        template = AppSettings.Default_Template__c;
    }

    public void applicationPortalInit() {
        appInfo = ApplicationUtilities.gatherApplicationInfo();
        appInfoMapByAppId = new Map<Id, EASYApplicationInfo>();
        checklistsByAppIds = new Map<Id, List<RequirementWrapper>>();
        Id contactId = appInfo.contactId;
        if (String.isNotBlank(contactId)) {
            //Get Application Controls for all apps
            appControlsByAppIds = new Map<Id, Application_Control__c>([
                    SELECT Id, Hide_Term_Program__c, Application_Start_Status__c, Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c,
                            Cancel_Status__c, Submit_Status__c, Withdraw_Status__c, URL_Parameter__c, Default__c, Academic_Level__c,
                            School_College__c, Degree_Levels__c, Template__c
                    FROM Application_Control__c
                    WHERE Id IN (
                            SELECT Application_Control__c
                            FROM Application__c
                            WHERE Contact__r.Id = :contactId
                    )
            ]);

            List<Id> appControlIdsList = new List<Id>(appControlsByAppIds.keySet());
            String appFields = ApplicationHelper.getAllItemApplicationFieldsByAppControlId(appControlIdsList);

            String query = 'SELECT ' + appFields + ' FROM Application__c WHERE Contact__c = \'' + contactId + '\''; //+ '\' AND Application_Control__r.Id IN :appControlIdsList';

            applicationsByIds = new Map<Id, Application__c>((List<Application__c>) Database.query(query));
            applicationMapSize = applicationsByIds.size();

            for (Application__c app : applicationsByIds.values()) {
                EASYApplicationInfo newAppInfo = ApplicationUtilities.setApplicationInfo(appControlsByAppIds.get(app.Application_Control__c), app);
                appInfoMapByAppId.put(app.Id, newAppInfo);
                List<RequirementWrapper> checklist = checklistHelper.checklistRequirements(app, newAppInfo);
                checklistsByAppIds.put(app.Id, checklist);
            }
        }
    }

}