/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 7/17/2022.
 */


public with sharing class ApplicationForgotPasswordConfirmCtrl {
    public String template { get; set; }

    public ApplicationForgotPasswordConfirmCtrl() {
        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        template = AppSettings.Default_Template__c;
    }

}