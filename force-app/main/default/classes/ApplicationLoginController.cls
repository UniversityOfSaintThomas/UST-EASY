global with sharing class ApplicationLoginController {

    global String username { get; set; }
    global String password { get; set; }
    public String template { get; set; }

    global PageReference login() {

        String startUrl = System.currentPageReference().getParameters().get('startURL');

        //String startUrl = 'apex/ApplicationPortal';
        return Site.login(username, password, startUrl);

    }

    global ApplicationLoginController() {
        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        template = AppSettings.Default_Template__c;
    }

    public PageReference checkIfLoggedIn() {
        String userType = UserInfo.getUserType();
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        PageReference pageRef = null;
        if (userType.equalsIgnoreCase('CSPLitePortal')) {
            if (String.isNotBlank(startUrl)) {
                pageRef = new PageReference(Site.getPathPrefix() + '/' + EncodingUtil.urlEncode(startUrl, 'UTF-8'));
            } else {
                pageRef = Page.ApplicationPortal;
            }
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }

}