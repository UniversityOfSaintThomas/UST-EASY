/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/3/2022.
 * Last Modified By: nicole.b@digitalmass.com 08/04/2022
 */


@IsTest
public class ApplicationChecklistComponentCtrl_TEST {

    @TestSetup
    public static void setup() {
        Application_Control__c appControl = new Application_Control__c(
                Application_Start_Status__c = Application_Control__c.Application_Start_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Active__c = true,
                Allow_Cancel_From__c = Application_Control__c.Allow_Cancel_From__c.getDescribe().getPicklistValues()[0].getValue(),
                Allow_Withdraw_From__c = Application_Control__c.Allow_Withdraw_From__c.getDescribe().getPicklistValues()[0].getValue(),
                Allow_Submit_From__c = Application_Control__c.Allow_Submit_From__c.getDescribe().getPicklistValues()[0].getValue(),
                Cancel_Status__c = Application_Control__c.Cancel_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Default__c = true,
                URL_Parameter__c = 'st',
                Submit_Status__c = Application_Control__c.Submit_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Withdraw_Status__c = Application_Control__c.Withdraw_Status__c.getDescribe().getPicklistValues()[0].getValue()
        );
        insert appControl;

        Contact student = new Contact(
            FirstName = 'TestFirst', 
            LastName = 'TestStudent', 
            Email = 'testfirst@teststudent.com'
        );
        insert student;

        Account acc = new Account(
            Name = 'Test Account', 
            hed__Primary_Contact__c = student.Id
        );
        insert acc;

        Id inquiryRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Inquiry_Opportunity').getRecordTypeId();
        Opportunity newOpp = new Opportunity(
            RecordTypeId = inquiryRT,
            Name = 'TestStudent|Test 2022|Test Program', 
            AccountId = acc.Id, 
            Contact__c = student.Id, 
            StageName = 'Suspect', 
            CloseDate = System.today()
        );
        insert newOpp;

        hed__Term__c hedTerm = new hed__Term__c(
            Name = 'Test 2022', 
            hed__Account__c = acc.Id
        );
        insert hedTerm;

        Academic_Term__c term = new Academic_Term__c(
            Name = 'Test 2022', 
            Term__c = hedTerm.Id
        );
        insert term;

        Program__c program = new Program__c(
            Name = 'Test Program', 
            Program_Name_on_Application__c = 'Test Program'
        );
        insert program;

        Application__c app = new Application__c(
            Contact__c = student.Id, 
            Application_Control__c = appControl.Id, 
            Intended_Term_of_Entry__c = term.Id, 
            Intended_Program__c = program.Id, 
            Application_Status__c = 'Started App'
        );
        insert app;

        Requirement__c req = new Requirement__c(
                Active__c = true,
                Name = 'Test Req',
                Application_Control__c = appControl.Id
        );
        insert req;
    }

    @IsTest
    public static void testGoToRequirement() {
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Application__c app = [SELECT Id, Contact__c FROM Application__c LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c LIMIT 1];

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appControlId = appControl.Id;
        appInfo.contactId = app.Contact__c;
        appInfo.at = 'teststring';

        ApplicationChecklistComponentController controller = new ApplicationChecklistComponentController();
        controller.appInfoParam = appInfo;
        controller.nextAppId = app.Id;
        controller.nextRequirementId = req.Id;
        controller.nextAt = 'teststring';

        PageReference requirementPage = Page.ApplicationRequirement;
        PageReference portalPage = Page.ApplicationPortal;
        requirementPage.getParameters().put('at', appInfo.at);
        requirementPage.getParameters().put('requirementId', controller.nextRequirementId);
        requirementPage.setRedirect(true);

        Test.startTest();
        PageReference returnPage = controller.goToRequirement();

        PageReference submitPage = controller.finalSubmitApp();

        Test.stopTest();

        System.assertEquals(submitPage, null);

        System.assertEquals(requirementPage.getUrl(), returnPage.getUrl());

    }
}