/**
 * @last modified on  : 08-08-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
@isTest
public class ApplicationPortal_TEST {
    @testSetup
    public static void testSetup(){
        Application_Control__c appControl = new Application_Control__c(
            Application_Start_Status__c=Application_Control__c.Application_Start_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Active__c=true,
            Allow_Cancel_From__c=Application_Control__c.Allow_Cancel_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Allow_Withdraw_From__c=Application_Control__c.Allow_Withdraw_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Allow_Submit_From__c=Application_Control__c.Allow_Submit_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Cancel_Status__c=Application_Control__c.Cancel_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Default__c=true,
            URL_Parameter__c ='st',
            Submit_Status__c=Application_Control__c.Submit_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Withdraw_Status__c=Application_Control__c.Withdraw_Status__c.getDescribe().getPicklistValues()[0].getValue()
        );
        insert appControl;
        
        Contact student = new Contact(
            FirstName = 'TestFirst', 
            LastName='TestStudent', 
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
    }
    public static TestMethod void loadApps(){
        Contact student = [Select Id from Contact limit 1];

        PageReference pr = Page.ApplicationPortal;
        pr.getParameters().put('contactId', student.Id);
        Test.setCurrentPage(pr);
        ApplicationPortal ap = new ApplicationPortal();
        Test.startTest();
        ap.applicationPortalInit();
        Test.stopTest();
        System.assertEquals(1, ap.applicationsByIds.size());
    }
}