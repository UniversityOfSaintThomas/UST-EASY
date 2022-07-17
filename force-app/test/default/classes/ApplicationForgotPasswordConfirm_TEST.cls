/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 7/17/2022.
 */


@IsTest
private class ApplicationForgotPasswordConfirm_TEST {
    @IsTest
    static void checkTemplate() {
        Application_Setting__c settings = new Application_Setting__c();
        settings.Default_Template__c = 'testTemplate';
        settings.Community_Profile_Ids__c = 'TEST';
        settings.Permission_Set_Id__c = 'TEST';
        insert settings;

        Test.startTest();
        ApplicationForgotPasswordConfirmCtrl ctrl = new ApplicationForgotPasswordConfirmCtrl();
        System.assertEquals(ctrl.template, 'testTemplate');
        Test.stopTest();

    }
}