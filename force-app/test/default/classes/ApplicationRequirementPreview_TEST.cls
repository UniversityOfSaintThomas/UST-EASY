/**
 * @last modified on  : 08-08-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
@IsTest
public class ApplicationRequirementPreview_TEST {
    @TestSetup
    public static void testSetup() {
        Account acc = new Account(Name = 'NewAcc');
        insert acc;
        
        Contact student = new Contact(
            FirstName = 'TestFirst', 
            LastName = 'TestStudent', 
            Email = 'testfirst@teststudent.com'
        );
        insert student;

        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }

        Map<String, Id> rtMapQD = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question_Dependency__c']) {
            rtMapQD.put(rt.DeveloperName, rt.Id);
        }

        Map<String, Id> rtMapRI = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Requirement_Item__c']) {
            rtMapRI.put(rt.DeveloperName, rt.Id);
        }

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
            Application_Control__c = appControl.Id,
            Active__c = true, 
            Name = 'Test Req', 
            Requirement_Integration_External_Id__c = ApplicationUtilities.getUUID(), 
            Internal_Only__c = true
        );
        insert req;
        Requirement_Item__c riQG = new Requirement_Item__c(
            Requirement__c = req.Id, 
            Name = 'Test RI', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Question_Group'), 
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(), 
            Internal_Only__c = true
        );
        Requirement_Item__c riDU = new Requirement_Item__c(
            Requirement__c = req.Id, 
            Name = 'Test RI', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Document_Upload'), 
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        Requirement_Item__c riRO = new Requirement_Item__c(
            Requirement__c = req.Id, 
            Name = 'Test RI', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Related_Object'), 
            Related_List_Object__c = 'Application__c', 
            Related_List_Object_Master__c = 'Contact', 
            Related_List_Object_Master_Field__c = 'Contact__c', 
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        insert new List<Requirement_Item__c>{
                riQG, riDU, riRO
        };

        Requirement__c req2 = new Requirement__c(
            Application_Control__c = appControl.Id, 
            Active__c = true, 
            Name = 'Test Req 2', 
            Requirement_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        insert req2;
        Requirement_Item__c riQG2 = new Requirement_Item__c(
            Requirement__c = req2.Id, 
            Name = 'Test RI', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Question_Group'), 
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        insert riQG2;

        Question__c q1 = new Question__c(
            Active__c = true, 
            RecordTypeId = rtMap.get('Text'), 
            Name = 'Test', 
            Label__c = 'Test', 
            Requirement_Item__c = riQG.Id, 
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        Question__c q2 = new Question__c(
            Active__c = true, 
            RecordTypeId = rtMap.get('Text'), 
            Name = 'Test2', 
            Label__c = 'Test2', 
            Requirement_Item__c = riQG2.Id, 
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        Question__c q3 = new Question__c(
            Active__c = true, 
            RecordTypeId = rtMap.get('Text'), 
            Name = 'Test3', 
            Label__c = 'Test3', 
            Requirement_Item__c = riQG.Id, 
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        insert new List<Question__c>{
                q1, q2, q3
        };

        Question_Dependency__c qd1 = new Question_Dependency__c(
            Question__c = q1.Id, 
            Controlling_Question__c = q2.Id, 
            Value__c = 'Test', 
            Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        Question_Dependency__c qd2 = new Question_Dependency__c(
            Question__c = q1.Id, 
            Controlling_Question__c = q3.Id, 
            Value__c = 'Test;Test2;Test3', 
            RecordTypeId = rtMapQD.get('Multi_Select_Picklist'), 
            Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        insert new List<Question_Dependency__c>{
                qd1, qd2
        };


        Requirement_Response__c rrQG = new Requirement_Response__c(
            Application__c = app.Id, 
            Requirement_Item__c = riQG.Id
        );
        Requirement_Response__c rrDU = new Requirement_Response__c(
            Application__c = app.Id, 
            Requirement_Item__c = riDU.Id, 
            HasDocument__c = true
        );
        Requirement_Response__c rrRO = new Requirement_Response__c(
            Application__c = app.Id, 
            Requirement_Item__c = riRO.Id, 
            Has_Child_Requirement__c = true
        );
        insert new List<Requirement_Response__c>{
                rrQG, rrDU, rrRO
        };
        insert new Question_Response__c(
            Requirement_Response__c = rrQG.Id, 
            Question__c = q2.Id
        );
    }

    @IsTest
    public static void appPreview() {
        Requirement__c req = [SELECT Id, Application_Control__r.Id FROM Requirement__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        PageReference pr = Page.ApplicationRequirementPreview;
        pr.getParameters().put('at', 'st');
        pr.getParameters().put('requirementId', req.Id);
        pr.getParameters().put('applicationId', req.Application_Control__r.Id);
        pr.getParameters().put('contactId', student.Id);
        Test.setCurrentPage(pr);

        ApplicationRequirementPreview arp = new ApplicationRequirementPreview();
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.requirementId = req.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;
        arp.appInfo = appInfo;
        arp.appControl = appControl;
        arp.reqs = new List<Requirement__c>{req};
        arp.contactId = student.Id;
        arp.applicationId = app.Id;

        Test.startTest();
        arp.init();
        Test.stopTest();

        System.assertEquals(2, arp.questionHolderMap.size());

    }
}