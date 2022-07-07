/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/23/2021.
 */


public with sharing class ApplicationChecklistComponentController {

    public Id nextRequirementId { get; set; }
    public String nextAt { get; set; }
    public String nextAppId { get; set; }
    public Id nextContactId { get; set; }
    public EASYApplicationInfo appInfoParam { get; set; }
    public ApplicationChecklistComponentController() {

    }

    public PageReference goToRequirement() {
        //set the cookie with current appInfo and new requirement;
        EASYApplicationInfo nextAppInfo;

        if (appInfoParam.at != nextAt) {
            nextAppInfo = ApplicationUtilities.setApplicationInfo(nextAt, nextAppId, nextContactId);
        } else {
            nextAppInfo = appInfoParam;
        }

        if (nextAppInfo.appId != nextAppId) {
            nextAppInfo.appId = nextAppId;
        }

        nextAppInfo.requirementId = nextRequirementId;

        ApplicationUtilities.createEncryptedCookie(JSON.serialize(nextAppInfo));

        PageReference requirementPage = Page.ApplicationRequirement;
//        requirementPage.getParameters().put('applicationId', nextAppInfo.appId);
//        requirementPage.getParameters().put('contactId', nextAppInfo.contactId);
        requirementPage.getParameters().put('at', nextAppInfo.at);
        requirementPage.getParameters().put('requirementId', nextRequirementId);
        requirementPage.setRedirect(true);
        return requirementPage;
    }

}