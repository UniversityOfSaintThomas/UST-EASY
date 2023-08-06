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
    public Boolean noApplication { get; set; }

    public ApplicationPortal() {
        noApplication = false;
        if (appInfo == null) {
            appInfo = ApplicationUtilities.gatherApplicationInfo();
        }
        System.debug(JSON.serializePretty(appInfo));

        if (String.isBlank(appInfo.appControlId)) {
            noApplication = true;
        }
        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        template = AppSettings.Default_Template__c;
    }

    public PageReference applicationPortalInit() {

        String userType = UserInfo.getUserType();
        PageReference pageRef = null;

        if (userType.equalsIgnoreCase('CSPLitePortal') || userType.equalsIgnoreCase('standard')) {
            appInfo = ApplicationUtilities.gatherApplicationInfo();
            appInfoMapByAppId = new Map<Id, EASYApplicationInfo>();
            checklistsByAppIds = new Map<Id, List<RequirementWrapper>>();
            Id contactId = appInfo.contactId;

            if (String.isNotBlank(contactId)) {
                //Get Application Controls for all apps
                appControlsByAppIds = new Map<Id, Application_Control__c>([
                        SELECT Id, Hide_Term_Program__c, Application_Start_Status__c, Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c,
                                Cancel_Status__c, Submit_Status__c, Withdraw_Status__c, URL_Parameter__c, Default__c, Academic_Level__c,
                                School_College__c, Degree_Levels__c, Template__c, Confirm_Status__c, Allow_Confirm_From__c
                        FROM Application_Control__c
                        WHERE Id IN (
                                SELECT Application_Control__c
                                FROM Application__c
                                WHERE Contact__r.Id = :contactId
                                AND Application_Status__c != 'Wrong App'
                                AND (NOT (Application_Status__c = 'Withdrawn' AND Application_Substatus__c = 'Wrong App'))
                                AND (NOT (Application_Status__c = 'Withdrawn' AND Application_Substatus__c = 'Multiple App'))
                        )
                ]);

                List<Id> appControlIdsList = new List<Id>(appControlsByAppIds.keySet());
                String appFields = ApplicationHelper.getAllItemApplicationFieldsByAppControlId(appControlIdsList);

                String query = 'SELECT ' + appFields + ' FROM Application__c WHERE Contact__c = \'' + contactId + '\'';
                query += ' AND Application_Status__c != \'Wrong Application\'';
                query += ' AND (NOT(Application_Status__c = \'Withdrawn\' AND Application_Substatus__c = \'Wrong App\'))';
                query += ' AND (NOT(Application_Status__c = \'Withdrawn\' AND Application_Substatus__c = \'Multiple App\'))';
                //+ '\' AND Application_Control__r.Id IN :appControlIdsList';

                applicationsByIds = new Map<Id, Application__c>((List<Application__c>) Database.query(query));
                applicationMapSize = applicationsByIds.size();
                System.debug(applicationMapSize);

                //Get application controls
                Set<Id> appControlIds = new Set<Id>();
                for (Application__c app : applicationsByIds.values()) {
                    appControlIds.add(app.Application_Control__c);
                }



                for (Application__c app : applicationsByIds.values()) {
                    System.debug(JSON.serializePretty(app.Application_Control__c));
                    System.debug(JSON.serializePretty(app));
                    EASYApplicationInfo newAppInfo = ApplicationUtilities.setApplicationInfo(appControlsByAppIds.get(app.Application_Control__c), app);
                    List<RequirementWrapper> checklist = checklistHelper.checklistRequirements(app, newAppInfo);
                    Boolean allowSubmit = checklistHelper.allowSubmit(checklist, appInfo);
                    Boolean allowConfirm = checklistHelper.allowConfirm(checklist, appInfo);
                    newAppInfo.allowSubmit = allowSubmit;
                    newAppInfo.allowConfirm = allowConfirm;
                    appInfoMapByAppId.put(app.Id, newAppInfo);
                    checklistsByAppIds.put(app.Id, checklist);
                }
            }
        } else {
            pageRef = Page.ApplicationLogin;
            pageRef.setRedirect(true);
            return pageRef;
        }

        return pageRef;
    }
}