@IsTest
public class ApplicationAdminView_TEST {
    @TestSetup
    public static void testSetup() {
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
        Account acc = new Account(Name = 'NewAcc');
        insert acc;
        Contact student = new Contact(LastName = 'TestStudent');
        insert student;
        Application__c app = new Application__c(Contact__c = student.Id, Application_Control__c = appControl.Id);
        insert app;

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

        Requirement__c req = new Requirement__c(Application_Control__c = appControl.Id, Active__c = true, Name = 'Test Req');
        insert req;
        Requirement_Item__c riQG = new Requirement_Item__c(Requirement__c = req.Id, Name = 'Test RI', Active__c = true, RecordTypeId = rtMapRI.get('Question_Group'), Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        Requirement_Item__c riDU = new Requirement_Item__c(Requirement__c = req.Id, Name = 'Test RI', Active__c = true, RecordTypeId = rtMapRI.get('Document_Upload'), Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        Requirement_Item__c riRO = new Requirement_Item__c(Requirement__c = req.Id, Name = 'Test RI', Active__c = true, RecordTypeId = rtMapRI.get('Related_Object'), Related_List_Object__c = 'Application__c', Related_List_Object_Master__c = 'Contact', Related_List_Object_Master_Field__c = 'Contact__c', Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        insert new List<Requirement_Item__c>{
                riQG, riDU, riRO
        };

        Requirement__c req2 = new Requirement__c(Application_Control__c = appControl.Id, Active__c = true, Name = 'Test Req 2', Requirement_Integration_External_Id__c = ApplicationUtilities.getUUID());
        insert req2;
        Requirement_Item__c riQG2 = new Requirement_Item__c(Requirement__c = req2.Id, Name = 'Test RI', Active__c = true, RecordTypeId = rtMapRI.get('Question_Group'), Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        insert riQG2;

        Question__c q1 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test', Label__c = 'Test', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q2 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test2', Label__c = 'Test2', Requirement_Item__c = riQG2.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q3 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test3', Label__c = 'Test3', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q4 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Picklist'), Picklist_Values__c = 'test1\ntest2\ntest3', Name = 'Test', Label__c = 'Test', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q5 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test', Label__c = 'Test', Contact_Field__c = 'FirstName', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q6 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Address'), Name = 'Test', Label__c = 'Test', Contact_Field__c = 'MailingAddress', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q7 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Picklist'), Picklist_Values__c = Application__c.Student_Type__c.getDescribe().getPicklistValues()[0].getValue(), Name = 'Test', Label__c = 'Test', Application_Field__c = 'Student_Type__c', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        insert new List<Question__c>{
                q1, q2, q3, q4, q5, q6, q7
        };

        Question_Dependency__c qd1 = new Question_Dependency__c(Question__c = q1.Id, Controlling_Question__c = q2.Id, Value__c = 'Test', RecordTypeId = rtMapQD.get('Picklist'), Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        Question_Dependency__c qd2 = new Question_Dependency__c(Question__c = q1.Id, Controlling_Question__c = q3.Id, Value__c = 'Test;Test2;Test3', RecordTypeId = rtMapQD.get('Multi_Select_Picklist'), Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        insert new List<Question_Dependency__c>{
                qd1, qd2
        };


        Requirement_Response__c rrQG = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riQG.Id);
        Requirement_Response__c rrDU = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riDU.Id, HasDocument__c = true);
        Requirement_Response__c rrRO = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riRO.Id, Has_Child_Requirement__c = true);
        insert new List<Requirement_Response__c>{
                rrQG, rrDU, rrRO
        };
        insert new Question_Response__c(Requirement_Response__c = rrQG.Id, Question__c = q2.Id);
    }

    @IsTest
    public static void appReview() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Requirement_Item__c ri = [SELECT Id FROM Requirement_Item__c LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req'];

        PageReference pr = Page.ApplicationAdminView;
        pr.getParameters().put('contactId', student.Id);
        pr.getParameters().put('applicationId', app.Id);
        pr.getParameters().put('at', 'st');
        Test.setCurrentPage(pr);
        ApplicationAdminView ar = new ApplicationAdminView();
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.requirementId = req.Id;
        appInfo.isExternalUser = true;
        appInfo.at = 'st';
        ar.appInfo = appInfo;
        ar.applicationId = app.Id;
        ar.contactId = student.Id;
        ar.app = app;
        ar.init();
        ar.arLst[0].newResponses = new List<Requirement_Response__c>{
                new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = ri.Id)
        };
        ar.submit();
        List<Requirement_Response__c> responses = [SELECT Id FROM Requirement_Response__c];
        // submit should insert above requirement response, 3 already inserted in setup
        System.assertEquals(4, responses.size());
    }
}