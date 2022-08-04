/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/3/2022.
 * Last Modified By: nicole.b@digitalmass.com 08/04/2022
 */


@IsTest
public class checklistHelper_TEST {

    @TestSetup
    public static void setup(){
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

        Contact student = new Contact(FirstName = 'TestFirst', LastName = 'TestStudent', Email = 'testfirst@teststudent.com');
        insert student;

        Application__c app = new Application__c(
            Contact__c = student.Id, 
            Application_Status__c = Application__c.Application_Status__c.getDescribe().getPicklistValues()[0].getValue()
        );
        insert app;

        Map<String, Id> rtMapRI = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Requirement_Item__c']) {
            rtMapRI.put(rt.DeveloperName, rt.Id);
        }

        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }

        Requirement__c req1 = new Requirement__c(
            Active__c = true, 
            Name = 'Test Req 1', 
            Application_Control__c = appControl.Id,
            Show_on_Application_Creation__c = false,
            Internal_Only__c = true
        );
        Requirement__c req2 = new Requirement__c(
            Active__c = true, 
            Name = 'Test Req 2', 
            Application_Control__c = appControl.Id,
            Show_on_Application_Creation__c = false,
            Internal_Only__c = true
        );
        insert new List<Requirement__c>{req1, req2};

        Requirement_Item__c riQG = new Requirement_Item__c(
            Requirement__c = req1.Id, 
            Name = 'Test RI QG', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Question_Group'), 
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
            Internal_Only__c = true
        );
        Requirement_Item__c riDU = new Requirement_Item__c(
            Requirement__c = req1.Id, 
            Name = 'Test RI DU', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Document_Upload'), 
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
            Internal_Only__c = true
        );
        Requirement_Item__c riRO = new Requirement_Item__c(
            Requirement__c = req1.Id, 
            Name = 'Test RI RO', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Related_Object'),
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
            Internal_Only__c = true
        );
        Requirement_Item__c riQG2 = new Requirement_Item__c(
            Requirement__c = req2.Id, 
            Name = 'Test RI QG', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Question_Group'), 
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
            Internal_Only__c = true
        );
        Requirement_Item__c riDU2 = new Requirement_Item__c(
            Requirement__c = req2.Id, 
            Name = 'Test RI DU', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Document_Upload'), 
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
            Internal_Only__c = true
        );
        Requirement_Item__c riRO2 = new Requirement_Item__c(
            Requirement__c = req2.Id, 
            Name = 'Test RI RO', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Related_Object'),
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
            Internal_Only__c = true
        );
        insert new List<Requirement_Item__c>{riQG, riDU, riRO, riQG2, riDU2, riRO2};

        Question__c q1 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test', Label__c = 'Test', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q2 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test2', Label__c = 'Test2', Requirement_Item__c = riQG2.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q3 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test3', Label__c = 'Test3', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q4 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Picklist'), Picklist_Values__c = 'test1\ntest2\ntest3', Name = 'Test', Label__c = 'Test', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q5 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test', Label__c = 'Test', Contact_Field__c = 'FirstName', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q6 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Address'), Name = 'Test', Label__c = 'Test', Contact_Field__c = 'MailingAddress', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        Question__c q7 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Picklist'), Picklist_Values__c = Application__c.Student_Type__c.getDescribe().getPicklistValues()[0].getValue(), Name = 'Test', Label__c = 'Test', Application_Field__c = 'Student_Type__c', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
        insert new List<Question__c>{q1, q2, q3, q4, q5, q6, q7};

        Requirement_Response__c rrQG = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riQG.Id);
        Requirement_Response__c rrDU = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riDU.Id, HasDocument__c = true);
        Requirement_Response__c rrRO = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riRO.Id, Has_Child_Requirement__c = true);
        insert new List<Requirement_Response__c>{rrQG, rrDU, rrRO};
    }

    @IsTest
    public static void testChecklistRequirements() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        List<Requirement__c> reqs = [
            SELECT Id, 
                Internal_Only__c, 
                Internal_Only_Show_on_Checklist__c, 
                Display_on_Checklist__c,
                Name,
                Active__c
            FROM Requirement__c
        ];
        List<Requirement_Item__c> reqItems = [
            SELECT Id,
                Internal_Only__c,
                Requirement__c,
                Active__c,
                Name,
                RecordTypeId,
                Allow_Text_Entry__c,
                Allow_Supporting_Documentation_Upload__c,
                Internal_Only_Show_on_Checklist__c,
                Display_on_Checklist__c
            FROM Requirement_Item__c
        ];
        Map<Id, Map<Id, RequirementItemWrapper>> reqIdToRequirementItemWrapperMap = new Map<Id, Map<Id, RequirementItemWrapper>>();
        for (Requirement_Item__c reqItem : reqItems) {
            RequirementItemWrapper reqItemWrapper = new RequirementItemWrapper(reqItem);
            if (reqIdToRequirementItemWrapperMap.get(reqItem.Requirement__c) != null) {
                reqIdToRequirementItemWrapperMap.get(reqItem.Requirement__c).put(reqItem.Id, reqItemWrapper);
            } else {
                Map<Id, RequirementItemWrapper> reqItemWrapperMap = new Map<Id, RequirementItemWrapper>();
                reqItemWrapperMap.put(reqItem.Id, reqItemWrapper);
                reqIdToRequirementItemWrapperMap.put(reqItem.Requirement__c, reqItemWrapperMap);
            }
        }
        List<RequirementWrapper> reqWrappers = new List<RequirementWrapper>();
        for (Requirement__c req : reqs) {
            RequirementWrapper reqWrapper = new RequirementWrapper(req);
            reqWrapper.reqItemMap = reqIdToRequirementItemWrapperMap.get(req.Id);
            reqWrapper.viewed = false;
            reqWrappers.add(reqWrapper);
        }

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appId = app.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;

        Test.startTest();
        List<RequirementWrapper> returnedReqs = checklistHelper.checklistRequirements(app, appInfo);
        Test.stopTest();

        System.assertEquals(String.valueOf(reqWrappers), String.valueOf(returnedReqs));

    }
}