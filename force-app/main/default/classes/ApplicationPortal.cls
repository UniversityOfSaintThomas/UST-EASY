/*******************************************************************************
@description This controller is used to display a list of applications available to the contact
@author Huron Consulting Group

Revision (s): 
*******************************************************************************/
public class ApplicationPortal {

    public Map<Id, Application__c> applicationsByIds { get; set; }
    public Map<Id, Application_Control__c> appControlsByAppIds { get; set; }
    public Map<Id, List<RequirementWrapper>> checklistsByAppIds { get; set; }
    public EASYApplicationInfo appInfo { get; set; }
    public Map<Id, EASYApplicationInfo> appInfoMapByAppId { get; set; }
    public String template { get; set; }

    public ApplicationPortal() {
        if (appInfo == null) {
            appInfo = ApplicationUtilities.gatherApplicationInfo();
        }
    }

    public void init() {
        appInfo = ApplicationUtilities.gatherApplicationInfo();
        appInfoMapByAppId = new Map<Id, EASYApplicationInfo>();

        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        template = AppSettings.Default_Template__c;

        if (String.isNotBlank(appInfo.contactId)) {
            //Get all the applications contact has
            applicationsByIds = new Map<Id, Application__c>([
                    SELECT Id, Intended_Program__c, Intended_Term_of_Entry__c, Intended_Program__r.Name,
                            Intended_Program__r.Program_Name_on_Application__c, Application_Control__c, Contact__c, Application_Status__c,
                            Citizenship__c
                    FROM Application__c
                    WHERE Contact__c = :appInfo.contactId
                    //TODO: reinstate FUTURE in this query
                    //AND Intended_Term_of_Entry__r.Term_Status_Type__c = 'FUTURE'
                    ORDER BY Name
            ]);

            if (applicationsByIds.keySet().size() > 0) {
                // add all applications controls that appear in applications to set
                Set<Id> appControlIds = new Set<Id>();
                for (Application__c app : applicationsByIds.values()) {
                    appControlIds.add(app.Application_Control__c);
                }
                List<Id> appControlIdsList = new List<Id>(appControlIds);

                //Get Application Controls for all apps
                appControlsByAppIds = new Map<Id, Application_Control__c>([
                        SELECT Id, Hide_Term_Program__c, Application_Start_Status__c, Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c,
                                Arrow_Color__c, Button_Color__c, Button_Text_Color__c, Cancel_Status__c, Line_Color__c, Link_Color__c, Logo_Static_Resource__c,
                                Logo_Static_Resource_Path__c, Submit_Status__c, Withdraw_Status__c, Text_Color__c, URL_Parameter__c, Default__c, Academic_Level__c,
                                School_College__c, Degree_Levels__c, Template__c
                        FROM Application_Control__c
                        WHERE Id IN :appControlIdsList
                ]);

                for (Application__c app : applicationsByIds.values()) {
                    EASYApplicationInfo newAppInfo = ApplicationUtilities.setApplicationInfo(appControlsByAppIds.get(app.Application_Control__c), app);
                    appInfoMapByAppId.put(app.Id, newAppInfo);
                    checklistsByAppIds.put(app.Id, checklistHelper.checklistRequirements(app, newAppInfo));
                }
            }

        }
    }
}