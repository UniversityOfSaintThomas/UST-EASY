/**
 * @last modified on  : 08-08-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
@isTest
public class BatchApplicationArchiver_TEST {
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
        
        Account acc = new Account(Name='NewAcc');
        insert acc;
        
        Contact student = new Contact(FirstName = 'TestFirst', LastName='TestStudent', Email = 'testfirst@teststudent.com');
        insert student;

        Id inquiryRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Inquiry_Opportunity').getRecordTypeId();
        Opportunity newOpp = new Opportunity(RecordTypeId = inquiryRT, Name = 'TestStudent|Test 2022|Test Program', AccountId = acc.Id, Contact__c = student.Id, StageName = 'Suspect', CloseDate = System.today());
        insert newOpp;

        hed__Term__c hedTerm = new hed__Term__c(Name = 'Test 2022', hed__Account__c = acc.Id);
        insert hedTerm;

        Academic_Term__c term = new Academic_Term__c(Name = 'Test 2022', Term__c = hedTerm.Id);
        insert term;

        Program__c program = new Program__c(Name = 'Test Program', Program_Name_on_Application__c = 'Test Program');
        insert program;

        Application__c app = new Application__c(Contact__c = student.Id, Application_Control__c = appControl.Id, Intended_Term_of_Entry__c = term.Id, Intended_Program__c = program.Id, Application_Status__c = 'Started App');
        insert app;

        insert new Application_Review__c(Application__c = app.Id);
        Test.setCreatedDate(app.Id,Date.today().addYears(-3));
        Map<String,Id> rtMap = new Map<String,Id>();
        for(RecordType rt : [Select Id,DeveloperName from RecordType where sObjectType = 'Requirement_Item__c']){
            rtMap.put(rt.DeveloperName,rt.Id);
        }

        Requirement__c req = new Requirement__c(Active__c = true,Name='Test Req',Application_Control__c=appControl.Id);
        insert req;
        Requirement_Item__c riQG = new Requirement_Item__c(Requirement__c=req.Id,Name='Test RI',Active__c = true,RecordTypeId=rtMap.get('Question_Group'));
        insert riQG;
        Question__c q = new Question__c(Requirement_Item__c=riQG.Id);
        insert q;

        Requirement_Response__c rr = new Requirement_Response__c(Application__c=app.Id,Requirement_Item__c=riQG.Id);
        insert rr;
        insert new Question_Response__c(Requirement_Response__c=rr.Id,Question__c=q.Id);

    }
    public static TestMethod void standardTest(){
        Application__c app = [Select Id from Application__c limit 1];
        Test.startTest();
            Database.executeBatch(new BatchApplicationArchiver());
        Test.stopTest();
        System.assertEquals(1,[Select count() from ContentDocumentLink Where LinkedEntityId = :app.Id]);
        System.assertEquals(0,[Select count() from Requirement_Response__c]);
        System.assertEquals(0,[Select count() from Question_Response__c]);
        System.assertEquals(0,[Select count() from Application_Review__c]);
    }
}