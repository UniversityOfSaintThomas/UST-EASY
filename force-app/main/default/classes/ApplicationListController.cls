/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 9/14/2022.
 */


public with sharing class ApplicationListController {
    public EASYApplicationInfo appInfoParam { get; set; }
    public String nextAt { get; set; }
    public Id nextAppId { get; set; }
    public Integer appAmount { get; set; }
    public String currentPageParam { get; set; }

    public ApplicationListController() {

    }

    public List<Application__c> getAllApplications() {
        List<Application__c> allApplications = [
                SELECT Id, Application_Control__r.Active__c, Application_Status__c, Intended_Term_of_Entry__r.Name, Intended_Program__r.Name,
                        Intended_Program_College_of_Interest__c, Intended_Program_Applicant_Type__c, Intended_Program_Application_Control__c,
                        Application_Control__r.URL_Parameter__c, Contact__c, Intended_Term_of_Entry__r.Term_10th_Day__c, Degree_Type__c, CreatedDate,
                        Application_Control__r.School_College__c, Intended_Program_Name_on_Application__c, Applicant_Type__c, Intended_Program__r.Degree__c,
                        Intended_Program__r.Degree_Type__c, Prior_Term_Application__c, Intended_Program__r.Academic_Level__c
                FROM Application__c
                WHERE Contact__c = :appInfoParam.contactId
                AND Application_Control__r.Active__c = TRUE
                AND (Intended_Term_of_Entry__r.Term_10th_Day__c >= TODAY OR Intended_Term_of_Entry__r.Term_10th_Day__c = NULL)
                AND Application_Status__c != 'Wrong App'
                AND Application_Status__c != 'Withdrawn'
        ];

        if (currentPageParam.equalsIgnoreCase('applicationhome')) {
            List<Application__c> newAppList = new List<Application__c>();
            for (Application__c app : allApplications) {
                if (app.Id == appInfoParam.appId) {
                    newAppList.add(app);
                }
                allApplications = newAppList;
            }
        }
        
        appAmount = allApplications.size();
        return allApplications;
    }

    public PageReference goToHome() {
        EASYApplicationInfo nextAppInfo = new EASYApplicationInfo();
        Application_Control__c appControl = null;
        Application__c app = null;

        if (nextAt != appInfoParam.at) {
            appControl = ApplicationUtilities.getApplicationControls(nextAt);
        }

        if (nextAppId != appInfoParam.appId) {
            app = ApplicationUtilities.getApplicationInfo(nextAppId, appInfoParam.contactId);
        }

        if (app != null && appControl != null) {
            nextAppInfo = ApplicationUtilities.setApplicationInfo(appControl, app);
        } else if (app != null) {
            nextAppInfo = ApplicationUtilities.setApplicationInfo(appInfoParam, app);
        } else if (appControl != null) {
            nextAppInfo = ApplicationUtilities.flattenAppControl(appControl, appInfoParam);
        } else {
            nextAppInfo = appInfoParam;
        }

        nextAppInfo.requirementId = null;

        ApplicationUtilities.createEncryptedCookie(JSON.serialize(nextAppInfo));

        PageReference navigateToPage = Page.ApplicationHome;

        navigateToPage.getParameters().put('at', nextAppInfo.at);
        // navigateToPage.getParameters().put('requirementId', nextRequirementId);
        navigateToPage.setRedirect(true);

        return navigateToPage;
    }
}