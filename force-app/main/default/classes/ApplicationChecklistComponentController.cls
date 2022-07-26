/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/23/2021.
 */


public with sharing class ApplicationChecklistComponentController {

    public Id nextRequirementId { get; set; }
    public String nextAt { get; set; }
    public String nextAppId { get; set; }
    public Id nextContactId { get; set; }
    public EASYApplicationInfo appInfoParam { get; set; }
    public Id submitAppId { get; set; }
    public String submitAppStatus { get; set; }

    public ApplicationChecklistComponentController() {

    }

    public PageReference goToRequirement() {
        //set the cookie with current appInfo and new requirement;
        EASYApplicationInfo nextAppInfo = appInfoParam;
        Application_Control__c appControl = null;
        Application__c app = null;

        //next at != previous at
        if (nextAt != appInfoParam.at) {
            appControl = ApplicationUtilities.getApplicationControls(nextAt);
        }

        if (nextAppId != appInfoParam.appId) {
            app = ApplicationUtilities.getApplicationInfo(nextAppId, nextContactId);
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

        nextAppInfo.requirementId = nextRequirementId;

        ApplicationUtilities.createEncryptedCookie(JSON.serialize(nextAppInfo));

        PageReference requirementPage = Page.ApplicationRequirement;
        requirementPage.getParameters().put('at', nextAppInfo.at);
        requirementPage.getParameters().put('requirementId', nextRequirementId);
        requirementPage.setRedirect(true);
        return requirementPage;
    }

    public PageReference finalSubmitApp() {
        PageReference pr = Page.ApplicationPortal;
        try {
            update new Application__c(Id = submitAppId, Application_Status__c = submitAppStatus);
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        return pr;
    }

}