/*******************************************************************************
@description This controller is used to display a list of applications available to the contact
@author Huron Consulting Group

Revision (s):
*******************************************************************************/
public class ApplicationPortal {

    public EASYApplicationInfo appInfo { get; set; }
    public String template { get; set; }
    public Boolean noApplication { get; set; }

    public ApplicationPortal() {
        noApplication = false;
        if (appInfo == null) {
            appInfo = ApplicationUtilities.gatherApplicationInfo();
        }

        if (String.isBlank(appInfo.appControlId)) {
            noApplication = true;
        }
        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        template = AppSettings.Default_Template__c;
    }

    public PageReference applicationPortalInit() {

        String userType = UserInfo.getUserType();
        PageReference pageRef = null;

        if (!userType.equalsIgnoreCase('CSPLitePortal') && !userType.equalsIgnoreCase('standard')) {
            pageRef = Page.ApplicationLogin;
            pageRef.setRedirect(true);
            return pageRef;
        }

        return pageRef;
    }
}