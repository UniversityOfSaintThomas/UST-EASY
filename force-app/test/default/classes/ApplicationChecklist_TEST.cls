@IsTest
public class ApplicationChecklist_TEST {
//    @TestSetup
//    public static void testSetup() {
//        Application_Control__c appControl = new Application_Control__c(
//                Application_Start_Status__c = Application_Control__c.Application_Start_Status__c.getDescribe().getPicklistValues()[0].getValue(),
//                Active__c = true,
//                Allow_Cancel_From__c = Application_Control__c.Allow_Cancel_From__c.getDescribe().getPicklistValues()[0].getValue(),
//                Allow_Withdraw_From__c = Application_Control__c.Allow_Withdraw_From__c.getDescribe().getPicklistValues()[0].getValue(),
//                Allow_Submit_From__c = Application_Control__c.Allow_Submit_From__c.getDescribe().getPicklistValues()[0].getValue(),
//                Cancel_Status__c = Application_Control__c.Cancel_Status__c.getDescribe().getPicklistValues()[0].getValue(),
//                Default__c = true,
//                URL_Parameter__c = 'st',
//                Submit_Status__c = Application_Control__c.Submit_Status__c.getDescribe().getPicklistValues()[0].getValue(),
//                Withdraw_Status__c = Application_Control__c.Withdraw_Status__c.getDescribe().getPicklistValues()[0].getValue()
//        );
//        insert appControl;
//
//        Contact student = new Contact(LastName = 'TestStudent');
//        insert student;
//        Application__c app = new Application__c(Contact__c = student.Id, Application_Status__c = Application__c.Application_Status__c.getDescribe().getPicklistValues()[0].getValue());
//        insert app;
//
//        Map<String, Id> rtMap = new Map<String, Id>();
//        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Requirement_Item__c']) {
//            rtMap.put(rt.DeveloperName, rt.Id);
//        }
//
//        Requirement__c req = new Requirement__c(Active__c = true, Name = 'Test Req', Application_Control__c = appControl.Id);
//        insert req;
//        Requirement_Item__c riQG = new Requirement_Item__c(Requirement__c = req.Id, Name = 'Test RI QG', Active__c = true, RecordTypeId = rtMap.get('Question_Group'), Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
//        Requirement_Item__c riDU = new Requirement_Item__c(Requirement__c = req.Id, Name = 'Test RI DU', Active__c = true, RecordTypeId = rtMap.get('Document_Upload'), Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
//        Requirement_Item__c riRO = new Requirement_Item__c(Requirement__c = req.Id, Name = 'Test RI RO', Active__c = true, RecordTypeId = rtMap.get('Related_Object'), Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
//        insert new List<Requirement_Item__c>{
//                riQG, riDU, riRO
//        };
//    }
//    @IsTest
//    public static void checkSuccesses() {
//        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
//        Contact student = [SELECT Id FROM Contact LIMIT 1];
//
//        Map<String, Id> riMap = new Map<String, Id>();
//        for (Requirement_Item__c ri : [SELECT Id,RecordType.DeveloperName FROM Requirement_Item__c]) {
//            riMap.put(ri.RecordType.DeveloperName, ri.Id);
//        }
//
//        Requirement_Response__c rrQG = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Question_Group'), Viewed__c = true);
//        Requirement_Response__c rrDU = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Document_Upload'), Viewed__c = true, ValueTextEntry__c = 'TEST');
//        Requirement_Response__c rrRO = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Related_Object'), Viewed__c = true, Has_Child_Requirement__c = true);
//        insert new List<Requirement_Response__c>{
//                rrQG, rrDU, rrRO
//        };
//        insert new Question_Response__c(Requirement_Response__c = rrQG.Id);
//
//        PageReference pr = Page.ApplicationChecklist;
//        pr.getParameters().put('contactId', student.Id);
//        pr.getParameters().put('applicationId', app.Id);
//        Test.setCurrentPage(pr);
//        ApplicationChecklist ac = new ApplicationChecklist();
//        ac.init();
//        for (RequirementWrapper rw : ac.reqMap.values()) {
//            System.assertEquals(rw.reqStatus, true);
//        }
//    }
//    @IsTest
//    public static void checkFailures() {
//        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
//        Contact student = [SELECT Id FROM Contact LIMIT 1];
//
//        Map<String, Id> riMap = new Map<String, Id>();
//        for (Requirement_Item__c ri : [SELECT Id,RecordType.DeveloperName FROM Requirement_Item__c]) {
//            riMap.put(ri.RecordType.DeveloperName, ri.Id);
//        }
//
//        Requirement_Response__c rrQG = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Question_Group'));
//        Requirement_Response__c rrDU = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Document_Upload'), HasDocument__c = false);
//        Requirement_Response__c rrRO = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Related_Object'), Has_Child_Requirement__c = false);
//        insert new List<Requirement_Response__c>{
//                rrQG, rrDU, rrRO
//        };
//        insert new Question_Response__c(Requirement_Response__c = rrQG.Id, IsRequired__c = true, IsShown__c = true);
//
//        PageReference pr = Page.ApplicationChecklist;
//        pr.getParameters().put('contactId', student.Id);
//        pr.getParameters().put('applicationId', app.Id);
//        Test.setCurrentPage(pr);
//        ApplicationChecklist ac = new ApplicationChecklist();
//        ac.init();
//        for (RequirementWrapper rw : ac.reqMap.values()) {
//            System.assertEquals(rw.reqStatus, false);
//        }
//    }
//    @IsTest
//    public static void submitApp() {
//        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
//        Contact student = [SELECT Id FROM Contact LIMIT 1];
//        Application_Control__c appControl = [SELECT Id,Withdraw_Status__c,Cancel_Status__c,Submit_Status__c FROM Application_Control__c];
//        Map<String, Id> riMap = new Map<String, Id>();
//        for (Requirement_Item__c ri : [SELECT Id,RecordType.DeveloperName FROM Requirement_Item__c]) {
//            riMap.put(ri.RecordType.DeveloperName, ri.Id);
//        }
//
//        Requirement_Response__c rrQG = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Question_Group'));
//        Requirement_Response__c rrDU = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Document_Upload'), ValueTextEntry__c = 'TEST');
//        Requirement_Response__c rrRO = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Related_Object'), Has_Child_Requirement__c = true);
//        insert new List<Requirement_Response__c>{
//                rrQG, rrDU, rrRO
//        };
//        insert new Question_Response__c(Requirement_Response__c = rrQG.Id);
//
//        PageReference pr = Page.ApplicationChecklist;
//        pr.getParameters().put('contactId', student.Id);
//        pr.getParameters().put('applicationId', app.Id);
//        pr.getParameters().put('at', 'st');
//        Test.setCurrentPage(pr);
//        ApplicationChecklist ac = new ApplicationChecklist();
//        ac.init();
//        ac.submit();
//        app = [SELECT Id, Application_Status__c FROM Application__c WHERE Id = :app.Id LIMIT 1];
//        System.assertEquals(app.Application_Status__c, appControl.Submit_Status__c);
//        Test.startTest();
//        ac.init();
//        ac.withdrawApp();
//        app = [SELECT Id, Application_Status__c FROM Application__c WHERE Id = :app.Id LIMIT 1];
//        System.assertEquals(app.Application_Status__c, appControl.Withdraw_Status__c);
//        Test.stopTest();
//    }
//    @IsTest
//    public static void cancelApp() {
//        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
//        Contact student = [SELECT Id FROM Contact LIMIT 1];
//        Application_Control__c appControl = [SELECT Id,Withdraw_Status__c,Cancel_Status__c,Submit_Status__c FROM Application_Control__c];
//        Map<String, Id> riMap = new Map<String, Id>();
//        for (Requirement_Item__c ri : [SELECT Id,RecordType.DeveloperName FROM Requirement_Item__c]) {
//            riMap.put(ri.RecordType.DeveloperName, ri.Id);
//        }
//
//        Requirement_Response__c rrQG = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Question_Group'));
//        Requirement_Response__c rrDU = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Document_Upload'), ValueTextEntry__c = 'TEST');
//        Requirement_Response__c rrRO = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Related_Object'), Has_Child_Requirement__c = true);
//        insert new List<Requirement_Response__c>{
//                rrQG, rrDU, rrRO
//        };
//        insert new Question_Response__c(Requirement_Response__c = rrQG.Id);
//
//        PageReference pr = Page.ApplicationChecklist;
//        pr.getParameters().put('contactId', student.Id);
//        pr.getParameters().put('applicationId', app.Id);
//        pr.getParameters().put('at', 'st');
//        Test.setCurrentPage(pr);
//        ApplicationChecklist ac = new ApplicationChecklist();
//        ac.init();
//        ac.cancelApp();
//        app = [SELECT Id, Application_Status__c FROM Application__c WHERE Id = :app.Id LIMIT 1];
//        System.assertEquals(app.Application_Status__c, appControl.Cancel_Status__c);
//    }
    @IsTest
    public static void testInit() {
        ApplicationChecklist appChecklist = new ApplicationChecklist();
        appChecklist.init();
    }
}