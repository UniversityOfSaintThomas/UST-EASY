public with sharing class ApplicationForgotPasswordController {

    public String username { get; set; }
    public String template { get; set; }

    public ApplicationForgotPasswordController() {
        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        template = AppSettings.Default_Template__c;
    }

    public PageReference ApplicationForgotPassword() {
        boolean success = Site.forgotPassword(username);
        PageReference pr = Page.ApplicationForgotPasswordConfirm;
        pr.setRedirect(true);

        if (success) {
            return pr;
        }
        return null;
    }


}