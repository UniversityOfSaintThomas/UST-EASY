/**
 * @last modified on  : 08-08-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
@IsTest
public class ApplicationRequirement_TEST {
    @TestSetup
    public static void setupData() {
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

        Account acc = new Account(Name = 'NewAcc1234324234');
        insert acc;

        Contact student = new Contact(
                FirstName = 'TestFirst',
                LastName = 'TestStudent',
                Email = 'testfirst@teststudent.com'
        );
        insert student;

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
                Label__c = 'Test Req',
                Application_Control__c = appControl.Id,
                Internal_Only__c = true,
                Show_on_Application_Creation__c = false
        );
        Requirement__c req2 = new Requirement__c(
                Active__c = true,
                Name = 'Test Req 2',
                Label__c = 'Test Req 2',
                Application_Control__c = appControl.Id,
                Internal_Only__c = true,
                Show_on_Application_Creation__c = false
        );
        insert new List<Requirement__c>{
                req, req2
        };

        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Requirement_Item__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }

        Requirement_Item__c riQG = new Requirement_Item__c(
                Requirement__c = req.Id,
                Name = 'Test RI Question Group',
                Active__c = true,
                RecordTypeId = rtMap.get('Question_Group'),
                Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
                Internal_Only__c = true
        );
        Requirement_Item__c riDU = new Requirement_Item__c(
                Requirement__c = req.Id,
                Name = 'Test RI',
                Active__c = true,
                Allow_Text_Entry__c = true,
                RecordTypeId = rtMap.get('Document_Upload'),
                Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
                Internal_Only__c = true
        );
        Requirement_Item__c riRO = new Requirement_Item__c(
                Requirement__c = req.Id,
                Name = 'Test RI',
                Active__c = true,
                RecordTypeId = rtMap.get('Related_Object'),
                Related_List_Object__c = 'Application__c',
                Related_List_Object_Master__c = 'Contact',
                Related_List_Object_Master_Field__c = 'Contact__c',
                Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
                Internal_Only__c = true
        );
        insert new List<Requirement_Item__c>{
                riQG, riDU, riRO
        };

    }

    @isTest
    public static void testGetNextReqId() {

        PageReference pageRef = Page.ApplicationRequirement;
        Test.setCurrentPage(pageRef);

        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req' LIMIT 1];
        Requirement__c req2 = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req 2' LIMIT 1];

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.requirementId = req.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;

        ApplicationRequirement appReq = new ApplicationRequirement();
        appReq.items = [SELECT Id FROM Requirement_Item__c];
        appReq.appInfo = appInfo;
        appReq.showSuccess = false;
        appReq.applicationRequirementInit();

        Test.startTest();
        Id nextReqId = appReq.nextReqId;
        Test.stopTest();

        System.assertEquals(req2.Id, nextReqId);
    }

    @isTest
    public static void testGetPrevReqId() {

        PageReference pageRef = Page.ApplicationRequirement;
        Test.setCurrentPage(pageRef);

        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req' LIMIT 1];
        Requirement__c req2 = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req 2' LIMIT 1];

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.requirementId = req2.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;

        ApplicationRequirement appReq = new ApplicationRequirement();
        appReq.items = [SELECT Id FROM Requirement_Item__c];
        appReq.appInfo = appInfo;
        appReq.applicationRequirementInit();

        Test.startTest();
        Id prevReqId = appReq.prevReqId;
        Test.stopTest();

        System.assertEquals(req.Id, prevReqId);
    }

    @isTest
    public static void testThreeParamConstructor() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req' LIMIT 1];

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.requirementId = req.Id;

        Test.startTest();
        ApplicationRequirement appReq = new ApplicationRequirement(req.Id, app, true);
        test.stopTest();

        System.assertEquals(app, appReq.app);
        appInfo.isExternalUser = true;
        //TODO: Fix this
        //System.assertEquals(String.valueOf(appInfo), String.valueOf(appReq.appInfo));
    }

    @isTest
    public static void testSevenParamConstructor() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req' LIMIT 1];
        Requirement__c req2 = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req 2' LIMIT 1];

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.requirementId = req2.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;

        List<Requirement_Item__c> reqItems = [SELECT Id FROM Requirement_Item__c];
        List<Requirement_Response__c> reqResponses = [SELECT Id FROM Requirement_Response__c];
        List<Question_Response__c> questionResponses = [SELECT Id FROM Question_Response__c];
        List<Question_Dependency__c> questionDependencies = [SELECT Id FROM Question_Dependency__c];

        Test.startTest();
        ApplicationRequirement appReq = new ApplicationRequirement(
                student.Id, app.Id, req.Id, reqItems, reqResponses, questionResponses, questionDependencies
        );
        Test.stopTest();

        System.assertEquals(true, appReq.preventUpdates);
    }

    @isTest
    public static void testApplicationRequirementInit() {
        Application__c app = [SELECT Id, Application_Status__c, Application_Substatus__c FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req' LIMIT 1];
        Requirement__c req2 = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req 2' LIMIT 1];

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.requirementId = req2.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;

        ApplicationRequirement appReq = new ApplicationRequirement();
        appReq.items = [SELECT Id FROM Requirement_Item__c];
        appReq.appInfo = appInfo;
        ApplicationRequirement appReq2 = new ApplicationRequirement();

        PageReference pageRef = Page.ApplicationRequirement;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        appReq.applicationRequirementInit();
       // PageReference reference = appReq2.applicationRequirementInit();
        Test.stopTest();

        PageReference portalPage = Page.ApplicationPortal;
        System.assertEquals(student.Id, appReq.con.Id);
        //System.assertEquals(String.valueOf(portalPage), String.valueOf(reference));
    }

    @isTest
    public static void testApplicationRequirementInitWithQuestionDependencies() {
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Application__c app = [SELECT Id, Application_Status__c FROM Application__c WHERE Contact__c = :student.Id LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req' LIMIT 1];
        Requirement__c req2 = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req 2' LIMIT 1];
        Requirement_Item__c riQG = [SELECT Id FROM Requirement_Item__c WHERE Name = 'Test RI Question Group'];

        Map<String, Id> rtMapQ = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
            rtMapQ.put(rt.DeveloperName, rt.Id);
        }

        Map<String, Id> rtMapQD = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Question_Dependency__c']) {
            rtMapQD.put(rt.DeveloperName, rt.Id);
        }

        Question__c q1 = new Question__c(
                Active__c = true,
                RecordTypeId = rtMapQ.get('Text'),
                Name = 'Test',
                Label__c = 'Test',
                Requirement_Item__c = riQG.Id,
                Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        Question__c q2 = new Question__c(
                Active__c = true,
                RecordTypeId = rtMapQ.get('Text'),
                Name = 'Test2',
                Label__c = 'Test2',
                Requirement_Item__c = riQG.Id,
                Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        Question__c q3 = new Question__c(
                Active__c = true,
                RecordTypeId = rtMapQ.get('Text'),
                Name = 'Test3',
                Label__c = 'Test3',
                Requirement_Item__c = riQG.Id,
                Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        Question__c q4 = new Question__c(
                Active__c = true,
                RecordTypeId = rtMapQ.get('Text'),
                Name = 'Test4',
                Label__c = 'Test4',
                Requirement_Item__c = riQG.Id,
                Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        Question__c q5 = new Question__c(
                Active__c = true,
                RecordTypeId = rtMapQ.get('Text'),
                Name = 'Test5',
                Label__c = 'Test5',
                Requirement_Item__c = riQG.Id,
                Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        insert new List<Question__c>{
                q1, q2, q3, q4, q5
        };

        Question_Dependency__c qd1 = new Question_Dependency__c(
                Question__c = q1.Id,
                Controlling_Question__c = q2.Id,
                Value__c = 'Test',
                RecordTypeId = rtMapQD.get('Picklist'),
                Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        Question_Dependency__c qd2 = new Question_Dependency__c(
                Question__c = q1.Id,
                Controlling_Question__c = q3.Id,
                Value__c = 'Test;Test2;Test3',
                RecordTypeId = rtMapQD.get('Multi_Select_Picklist'),
                Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        Question_Dependency__c qd3 = new Question_Dependency__c(
                Question__c = q4.Id,
                Controlling_Question__c = q5.Id,
                Value__c = 'Test',
                RecordTypeId = rtMapQD.get('Picklist'),
                Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        Question_Dependency__c qd4 = new Question_Dependency__c(
                Question__c = q4.Id,
                Controlling_Question__c = q5.Id,
                Value__c = 'Test',
                RecordTypeId = rtMapQD.get('Picklist'),
                Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        insert new List<Question_Dependency__c>{
                qd1, qd2, qd3, qd4
        };

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.requirementId = req.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;

        ApplicationRequirement appReq = new ApplicationRequirement();
        appReq.items = [SELECT Id FROM Requirement_Item__c];
        appReq.appInfo = appInfo;

        PageReference pageRef = Page.ApplicationRequirement;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        appReq.applicationRequirementInit();
        Test.stopTest();

        List<Requirement_Response__c> reqResponses = [SELECT Id FROM Requirement_Response__c WHERE Application__c = :app.Id];
        System.assertEquals(3, reqResponses.size());
    }

    @IsTest
    public static void testLookupSearch() {
        Test.startTest();
        insert new Account(Name = 'Example Account');
        Test.stopTest();
        List<SObject> results = ApplicationRequirement.lookupSearch('Account', null, 'Name', 'Example');
        System.assertEquals(1, results.size());
    }

    @IsTest
    public static void standardTest() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id, Submit_Status__c FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];

        Requirement__c req = [SELECT Id FROM Requirement__c LIMIT 1];

        Map<String, Id> riMap = new Map<String, Id>();
        for (Requirement_Item__c ri : [SELECT Id, RecordType.DeveloperName FROM Requirement_Item__c]) {
            riMap.put(ri.RecordType.DeveloperName, ri.Id);
        }

        Requirement_Response__c rrQG = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Question_Group'));
        Requirement_Response__c rrDU = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Document_Upload'), HasDocument__c = true);
        Requirement_Response__c rrRO = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Related_Object'), Has_Child_Requirement__c = true);
        insert new List<Requirement_Response__c>{
                rrQG, rrDU, rrRO
        };
        insert new Question_Response__c(Requirement_Response__c = rrQG.Id);

        ContentVersion cv = new ContentVersion(Title = 'Test', PathOnClient = 'Test', VersionData = Blob.valueOf('test'));
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        insert new ContentDocumentLink(LinkedEntityId = rrDU.Id, ContentDocumentId = cv.ContentDocumentId, Visibility = 'AllUsers', ShareType = 'I');

        PageReference pr = Page.ApplicationRequirement;
        pr.getParameters().put('contactId', student.Id);
        pr.getParameters().put('applicationId', app.Id);
        pr.getParameters().put('requirementId', req.Id);
        Test.setCurrentPage(pr);
        ApplicationRequirement ac = new ApplicationRequirement();
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.requirementId = req.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;
        ac.appInfo = appInfo;
        ac.applicationRequirementInit();
        System.assertEquals(ac.title, 'Test Req');

        ac.redirectPage = 'something';
        PageReference pr1 = ac.submit();
        System.assertEquals(Page.ApplicationRequirement.getUrl() + '?requirementId=' + req.Id, pr1.getUrl());

        ac.redirectPage = 'submit';
        ac.allowSubmit = true;
        ac.app = app;
        ac.appControl = appControl;
        PageReference pr2 = ac.submit();
        PageReference expected = Page.ApplicationRequirement;
        expected.getParameters().put('requirementId', req.Id);
        System.assertEquals(expected.getUrl(), pr2.getUrl());

        ac.redirectPage = 'checklist';
        PageReference expectedPortal = Page.ApplicationPortal;
        expectedPortal.getParameters().put('requirementId', req.Id);
        PageReference pr3 = ac.submit();
        System.assertEquals(expectedPortal.getUrl(), pr3.getUrl());

    }

    @IsTest
    public static void testDocumentUpload() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];

        Requirement__c req = [SELECT Id FROM Requirement__c LIMIT 1];

        Map<String, Id> riMap = new Map<String, Id>();
        for (Requirement_Item__c ri : [SELECT Id, RecordType.DeveloperName FROM Requirement_Item__c]) {
            riMap.put(ri.RecordType.DeveloperName, ri.Id);
        }

        Requirement_Response__c rrDU = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Document_Upload'));
        insert new List<Requirement_Response__c>{
                rrDU
        };

        PageReference pr = Page.ApplicationRequirement;
        pr.getParameters().put('contactId', student.Id);
        pr.getParameters().put('applicationId', app.Id);
        pr.getParameters().put('requirementId', req.Id);
        Test.setCurrentPage(pr);

        ApplicationRequirement ac = new ApplicationRequirement();
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.requirementId = req.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;

        ac.appInfo = appInfo;
        ac.items = [SELECT Id FROM Requirement_Item__c];

        Test.startTest();
        ac.applicationRequirementInit();
        System.assertEquals('Test Req', ac.Title);
        for (ApplicationQuestionGroup agq : ac.section.groups) {
            if (agq.documentUpload == true) {
                agq.att.Title = 'Test';
                agq.att.VersionData = Blob.valueOf('test');
            }
        }
        ac.submit();
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :rrDU.Id]);

        ac = new ApplicationRequirement();
        ac.appInfo = appInfo;
        ac.items = [SELECT Id FROM Requirement_Item__c];
        ac.applicationRequirementInit();
        for (ApplicationQuestionGroup agq : ac.section.groups) {
            if (agq.documentUpload == true) {
                agq.response.ValueTextEntry__c = 'Test';
            }
        }
        ac.submit();
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :rrDU.Id]);
        System.assertEquals('Test', [SELECT Id, ValueTextEntry__c FROM Requirement_Response__c WHERE Id = :rrDU.Id].ValueTextEntry__c);
    }

    @IsTest
    public static void testExternal() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c LIMIT 1];
        Requirement_Item__c riQG = [SELECT Id FROM Requirement_Item__c WHERE Name = 'Test RI Question Group'];

        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }

        Question__c q = new Question__c(
                RecordTypeId = rtMap.get('Email'),
                External_Email_Field__c = true,
                Name = 'Email',
                Label__c = 'Email',
                Requirement_Item__c = riQG.Id,
                Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        insert q;
        Requirement_Response__c rrDU = new Requirement_Response__c(
                Application__c = app.Id,
                Requirement_Item__c = riQG.Id,
                Hashcode__c = '1234'
        );
        insert rrDU;

        PageReference pr = Page.ApplicationRequirement;
        pr.getParameters().put('contactId', student.Id);
        pr.getParameters().put('applicationId', app.Id);
        pr.getParameters().put('requirementId', req.Id);
        Test.setCurrentPage(pr);
        ApplicationRequirement ac = new ApplicationRequirement();
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.requirementId = req.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;
        ac.appInfo = appInfo;
        ac.applicationRequirementInit();
        for (ApplicationQuestionGroup agq : ac.section.groups) {
            if (agq.documentUpload == true) {
                System.assertEquals(null, agq.questions);
            }
        }
        appInfo.submitStatus = 'Submitted App';
        ac.appInfo = appInfo;
        ac.finalSubmitApp();
        Application__c submittedApp = [SELECT Application_Status__c FROM Application__c WHERE Id = :app.Id LIMIT 1];
        System.assertEquals('Submitted App', submittedApp.Application_Status__c);
    }

    @IsTest
    public static void testHandleRecommendations() {
        List<Recommendation__c> recommendation_before = [SELECT Id FROM Recommendation__c LIMIT 1];
        System.assertEquals(0, recommendation_before.size());

        Application_Control__c app_control = [SELECT Id FROM Application_Control__c LIMIT 1];
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Requirement__c recommendation_requirement = new Requirement__c(
                Application_Control__c = app_control.Id,
                Name = 'Letter of Recommendation',
                Active__c = true
        );
        insert recommendation_requirement;

        Id question_group_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Question_Group').getRecordTypeId();
        Requirement_Item__c request_recommendation_ri = new Requirement_Item__c(
                Requirement__c = recommendation_requirement.Id,
                RecordTypeId = question_group_RT,
                Active__c = true,
                Name = 'Request Recommendation',
                Related_List_Object__c = 'Recommendation__c'
        );
        insert request_recommendation_ri;

        Id email_RT = Schema.SObjectType.Question__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        Question__c request_question = new Question__c(
                Requirement_Item__c = request_recommendation_ri.Id,
                RecordTypeId = email_RT,
                Active__c = true,
                Name = 'Recommender Email',
                Related_Object_Field__c = 'Rec_Email__c',
                External_Email_Field__c = true
        );
        insert request_question;

        Requirement_Response__c request_rr = new Requirement_Response__c(
                Requirement_Item__c = request_recommendation_ri.Id,
                Application__c = app.Id,
                External_Email__c = 'testrecommender@test.com'
        );
        insert request_rr;

        Question_Response__c question_response = new Question_Response__c(
                Requirement_Response__c = request_rr.Id,
                ValueEmail__c = 'testrecommender@test.com',
                Question__c = request_question.Id,
                Application__c = app.Id,
                IsPopulated__c = true
        );
        insert question_response;

        Map<Id, Requirement_Response__c> rr_map = new Map<Id, Requirement_Response__c>();
        rr_map.put(request_rr.Id, request_rr);

        Map<Id, Id> requirement_item_ids_of_external_email_rrs = new Map<Id, Id>();
        requirement_item_ids_of_external_email_rrs.put(request_recommendation_ri.Id, request_rr.Id);

        Test.startTest();
        ApplicationRequirement.handleRecommendations(rr_map, requirement_item_ids_of_external_email_rrs);
        Test.stopTest();

        List<Recommendation__c> recommendation = [SELECT Id FROM Recommendation__c LIMIT 1];
        System.assertEquals(1, recommendation.size());
    }

    @IsTest
    public static void testDeletePreviousFile() {

        Application__c a = new Application__c();

        insert a;

        Requirement_Response__c r = new Requirement_Response__c (Application__c = a.Id,
                Original_Uploaded_Document_File_Name__c = 'Hello',
                Saved_Uploaded_Document_File_Name__c = 'World');

        insert r;

        Supporting_Document__c s = new Supporting_Document__c();

        insert s;

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Content Version Name',
                PathOnClient = 'Content Version Name.pdf',
                VersionData = Blob.valueOf('data'),
                Origin = 'C'
        );

        insert contentVersion;

        ContentDocument cd = [
                SELECT Id
                FROM ContentDocument
                WHERE LatestPublishedVersionId = :contentVersion.Id
        ];

        ContentDocumentLink requirementResponseLink = new ContentDocumentLink(
                ContentDocumentId = cd.Id,
                LinkedEntityId = r.Id,
                ShareType = 'V'
        );

        insert requirementResponseLink;

        ContentDocumentLink supportingDocumentLink = new ContentDocumentLink(
                ContentDocumentId = cd.Id,
                LinkedEntityId = s.Id,
                ShareType = 'V'
        );

        insert supportingDocumentLink;

        ApplicationRequirement ar = new ApplicationRequirement();

        ar.contentDocId = cd.Id;
        ar.reqResponseId = r.Id;

        Test.startTest();
        ar.deletePreviousFile();
        Test.stopTest();

        List<ContentDocument> cdDeleted = [
                SELECT Id
                FROM ContentDocument
                WHERE Id = :cd.Id
        ];

        System.assertEquals(0, cdDeleted.size());
    }

    // @IsTest
    // public static void testRelatedObject() {
    //     Application__c app = [SELECT Id FROM Application__c LIMIT 1];
    //     Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
    //     Contact student = [SELECT Id FROM Contact LIMIT 1];
    //     Requirement__c req = [SELECT Id FROM Requirement__c LIMIT 1];

    //     Map<String, Id> rtMap = new Map<String, Id>();
    //     for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
    //         rtMap.put(rt.DeveloperName, rt.Id);
    //     }

    //     Map<String, Id> riMap = new Map<String, Id>();
    //     for (Requirement_Item__c ri : [SELECT Id,RecordType.DeveloperName FROM Requirement_Item__c]) {
    //         riMap.put(ri.RecordType.DeveloperName, ri.Id);
    //     }
    //     Question__c q1 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Reference'), Related_Object_Field__c = 'Intended_Program__c', Lookup_Object__c = 'Program__c', Requirement_Item__c = riMap.get('Related_Object'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     Question__c q2 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Checkbox'), Related_Object_Field__c = 'User_Created__c', Hardcoded_Value__c = 'true', Requirement_Item__c = riMap.get('Related_Object'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     Question__c q3 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Related_Object_Field__c = 'Intended_Program__c', New_Reference_Field__c = true, Requirement_Item__c = riMap.get('Related_Object'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     insert new List<Question__c>{
    //             q1, q2, q3
    //     };

    //     Requirement_Response__c rrRO = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Related_Object'), Has_Child_Requirement__c = true);
    //     insert new List<Requirement_Response__c>{
    //             rrRO
    //     };

    //     PageReference pr = Page.ApplicationRequirement;
    //     pr.getParameters().put('contactId', student.Id);
    //     pr.getParameters().put('applicationId', app.Id);
    //     pr.getParameters().put('requirementId', req.Id);
    //     Test.setCurrentPage(pr);
    //     ApplicationRequirement ac = new ApplicationRequirement();
    //     EASYApplicationInfo appInfo = new EASYApplicationInfo();
    //     appInfo.appId = app.Id;
    //     appInfo.contactId = student.Id;
    //     appInfo.requirementId = req.Id;
    //     appInfo.appControlId = appControl.Id;
    //     appInfo.isExternalUser = true;
    //     ac.appInfo = appInfo;
    //     ac.applicationRequirementInit();
    //     System.assertEquals(ac.title, 'Test Req');
    //     for (ApplicationQuestionGroup agq : ac.section.groups) {
    //         agq.documentUpload = false;
    //         if (agq.relatedObject == true) {
    //             agq.newRow();
    //             Map<ApplicationQuestion, Boolean> showQuestions = agq.relatedObjects[0].showQuestions;
    //             agq.selectedRelatedId = 'new0';
    //             agq.enableEditMode();
    //             agq.selectedRelatedId = 'new0';
    //             agq.enableConfirmMode();
    //             agq.selectedRelatedId = 'new0';
    //             agq.enableViewMode();
    //             agq.selectedRelatedId = 'new0';
    //             agq.newRow();
    //             agq.selectedRelatedId = 'new1';
    //             agq.enableEditMode();
    //             Map<String, ApplicationQuestionGroup.SObjectWrapper> relatedObjectsMap = agq.relatedObjectsMap;
    //             ApplicationQuestionGroup.SObjectWrapper objWrapper = relatedObjectsMap.get('new1');
    //             SObject obj = objWrapper.obj;
    //             obj.put('Contact__c', [SELECT Id FROM Contact LIMIT 1].Id);
    //             agq.selectedRelatedId = 'new1';
    //             agq.enableConfirmMode();
    //             agq.selectedRelatedId = 'new1';
    //             agq.enableEditMode();
    //             agq.newReferenceObjectSelectedWrapperName = 'Test Program';
    //             agq.createNewReferenceObject();
    //             agq.newReferenceObjectSelectedWrapper = 'new1';
    //             agq.addNewReferenceObject();
    //             agq.selectedRelatedId = 'new1';
    //             agq.enableViewMode();
    //             agq.selectedRelatedId = 'new1';
    //             agq.relatedUpload();
    //             agq.enableDeleteMode();
    //             agq.setCreatingNewRelatedRecord();
    //         }
    //     }
    //     ac.submit();
    // }

    // @IsTest
    // public static void testMisc() {
    //     Application__c app = [SELECT Id FROM Application__c LIMIT 1];
    //     Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
    //     Contact student = [SELECT Id FROM Contact LIMIT 1];

    //     Requirement__c req = [SELECT Id FROM Requirement__c LIMIT 1];

    //     Map<String, Id> riMap = new Map<String, Id>();
    //     for (Requirement_Item__c ri : [SELECT Id,RecordType.DeveloperName FROM Requirement_Item__c]) {
    //         riMap.put(ri.RecordType.DeveloperName, ri.Id);
    //     }
    //     Map<String, Id> rtMap = new Map<String, Id>();
    //     for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
    //         rtMap.put(rt.DeveloperName, rt.Id);
    //     }
    //     Question__c q1 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test', Label__c = 'Test', Requirement_Item__c = riMap.get('Question_Group'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     insert q1;
    //     PageReference pr = Page.ApplicationRequirement;
    //     pr.getParameters().put('contactId', student.Id);
    //     pr.getParameters().put('applicationId', app.Id);
    //     pr.getParameters().put('requirementId', req.Id);
    //     Test.setCurrentPage(pr);
    //     ApplicationRequirement ac = new ApplicationRequirement();
    //     EASYApplicationInfo appInfo = new EASYApplicationInfo();
    //     appInfo.appId = app.Id;
    //     appInfo.contactId = student.Id;
    //     appInfo.requirementId = req.Id;
    //     appInfo.appControlId = appControl.Id;
    //     appInfo.isExternalUser = true;
    //     ac.appInfo = appInfo;
    //     ac.applicationRequirementInit();
    //     for (ApplicationQuestionGroup agq : ac.section.groups) {
    //         if (agq.questionGroup == true) {
    //             String inst = agq.instructions;
    //             Boolean edit = agq.isEditable;
    //             agq.questions[0].getDatetimeValue();
    //             agq.questions[0].setDatetimeValue(Datetime.now());
    //             agq.questions[0].getDateValue();
    //             agq.questions[0].setDateValue(Date.today());
    //             agq.questions[0].getMultiPicklistValues();
    //             agq.questions[0].setMultiPicklistValues(new List<String>{
    //                     't1', 't2', 't3'
    //             });
    //         }
    //     }
    //     ApplicationQuestionGroup aqg = new ApplicationQuestionGroup((SObject) (new Account()));
    //     ApplicationQuestionGroup.MultiPicklistWrapper mpw = new ApplicationQuestionGroup.MultiPicklistWrapper(new Requirement__c(Student_Type__c = Requirement__c.Student_Type__c.getDescribe().getPicklistValues()[0].getValue()), 'Student_Type__c');
    //     mpw.getMultiPicklistValues();
    //     mpw.setMultiPicklistValues(new List<String>{
    //             Requirement__c.Student_Type__c.getDescribe().getPicklistValues()[0].getValue()
    //     });
    // }
    // @IsTest
    // public static void testDependentQuestions() {
    //     Application__c app = [SELECT Id FROM Application__c LIMIT 1];
    //     Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
    //     Contact student = [SELECT Id FROM Contact LIMIT 1];

    //     Requirement__c req = [SELECT Id FROM Requirement__c LIMIT 1];

    //     Map<String, Id> rtMap = new Map<String, Id>();
    //     for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
    //         rtMap.put(rt.DeveloperName, rt.Id);
    //     }
    //     Map<String, Id> rtMapQD = new Map<String, Id>();
    //     for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question_Dependency__c']) {
    //         rtMapQD.put(rt.DeveloperName, rt.Id);
    //     }
    //     Map<String, Id> rtMapRI = new Map<String, Id>();
    //     for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Requirement_Item__c']) {
    //         rtMapRI.put(rt.DeveloperName, rt.Id);
    //     }
    //     Map<String, Id> riMap = new Map<String, Id>();
    //     for (Requirement_Item__c ri : [SELECT Id,RecordType.DeveloperName FROM Requirement_Item__c]) {
    //         riMap.put(ri.RecordType.DeveloperName, ri.Id);
    //     }
    //     Requirement__c req2 = new Requirement__c(Application_Control__c = [SELECT Id FROM Application_Control__c LIMIT 1].Id, Active__c = true, Name = 'Test Req 2');
    //     insert req2;
    //     Requirement_Item__c riQG2 = new Requirement_Item__c(Requirement__c = req2.Id, Name = 'Test RI', Active__c = true, RecordTypeId = rtMapRI.get('Question_Group'), Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
    //     insert riQG2;
    //     Question__c q1 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test', Label__c = 'Test', Requirement_Item__c = riMap.get('Question_Group'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     Question__c q2 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test2', Label__c = 'Test2', Requirement_Item__c = riQG2.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     Question__c q3 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test3', Label__c = 'Test3', Requirement_Item__c = riMap.get('Question_Group'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     Question__c q4 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test4', Label__c = 'Test4', Requirement_Item__c = riMap.get('Question_Group'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     Question__c q5 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test5', Label__c = 'Test5', Requirement_Item__c = riMap.get('Question_Group'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     insert new List<Question__c>{
    //             q1, q2, q3, q4, q5
    //     };

    //     Question_Dependency__c qd1 = new Question_Dependency__c(Question__c = q1.Id, Controlling_Question__c = q2.Id, Value__c = 'Test', RecordTypeId = rtMapQD.get('Picklist'), Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
    //     Question_Dependency__c qd2 = new Question_Dependency__c(Question__c = q1.Id, Controlling_Question__c = q3.Id, Value__c = 'Test;Test2;Test3', RecordTypeId = rtMapQD.get('Multi_Select_Picklist'), Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
    //     Question_Dependency__c qd3 = new Question_Dependency__c(Question__c = q4.Id, Controlling_Question__c = q5.Id, Value__c = 'Test', RecordTypeId = rtMapQD.get('Picklist'), Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
    //     Question_Dependency__c qd4 = new Question_Dependency__c(Question__c = q4.Id, Controlling_Question__c = q5.Id, Value__c = 'Test', RecordTypeId = rtMapQD.get('Picklist'), Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
    //     insert new List<Question_Dependency__c>{
    //             qd1, qd2, qd3, qd4
    //     };

    //     Requirement_Response__c rrQG = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = riMap.get('Question_Group'));
    //     insert rrQG;
    //     Question_Response__c qr1 = new Question_Response__c(ValueText__c = 'Test', Question__c = q2.Id, Requirement_Response__c = rrQG.Id);
    //     Question_Response__c qr2 = new Question_Response__c(ValueText__c = 'Test', Question__c = q3.Id, Requirement_Response__c = rrQG.Id);
    //     insert new List<Question_Response__c>{
    //             qr1, qr2
    //     };


    //     PageReference pr = Page.ApplicationRequirement;
    //     pr.getParameters().put('contactId', student.Id);
    //     pr.getParameters().put('applicationId', app.Id);
    //     pr.getParameters().put('requirementId', req.Id);
    //     Test.setCurrentPage(pr);
    //     ApplicationRequirement ac = new ApplicationRequirement();
    //     EASYApplicationInfo appInfo = new EASYApplicationInfo();
    //     appInfo.appId = app.Id;
    //     appInfo.contactId = student.Id;
    //     appInfo.requirementId = req.Id;
    //     appInfo.appControlId = appControl.Id;
    //     appInfo.isExternalUser = true;
    //     ac.appInfo = appInfo;
    //     ac.applicationRequirementInit();

    //     ac.submit();
    //     Test.startTest();
    //     q1.Dependency_Logic__c = 'OR';
    //     update q1;
    //     ac = new ApplicationRequirement();
    //     ac.appInfo = appInfo;
    //     ac.applicationRequirementInit();
    //     ac.submit();
    //     Test.stopTest();
    // }
    // @IsTest
    // public static void testQuestionGroup() {
    //     Application__c app = [SELECT Id FROM Application__c LIMIT 1];
    //     Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
    //     Contact student = [SELECT Id FROM Contact LIMIT 1];

    //     Requirement__c req = [SELECT Id FROM Requirement__c LIMIT 1];

    //     Map<String, Id> rtMap = new Map<String, Id>();
    //     for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
    //         rtMap.put(rt.DeveloperName, rt.Id);
    //     }
    //     Map<String, Id> rtMapRI = new Map<String, Id>();
    //     for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Requirement_Item__c']) {
    //         rtMapRI.put(rt.DeveloperName, rt.Id);
    //     }
    //     Map<String, Id> riMap = new Map<String, Id>();
    //     for (Requirement_Item__c ri : [SELECT Id,RecordType.DeveloperName FROM Requirement_Item__c]) {
    //         riMap.put(ri.RecordType.DeveloperName, ri.Id);
    //     }
    //     Question__c q1 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Picklist'), Picklist_Values__c = 'test1\ntest2\ntest3', Name = 'Test', Label__c = 'Test', Requirement_Item__c = riMap.get('Question_Group'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     Question__c q2 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test', Label__c = 'Test', Contact_Field__c = 'FirstName', Requirement_Item__c = riMap.get('Question_Group'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     Question__c q3 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Address'), Name = 'Test', Label__c = 'Test', Contact_Field__c = 'MailingAddress', Requirement_Item__c = riMap.get('Question_Group'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     Question__c q4 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Picklist'), Picklist_Values__c = Application__c.Student_Type__c.getDescribe().getPicklistValues()[0].getValue(), Name = 'Test', Label__c = 'Test', Application_Field__c = 'Student_Type__c', Requirement_Item__c = riMap.get('Question_Group'), Question_Integration_External_Id__c = ApplicationUtilities.getUUID());
    //     insert new List<Question__c>{
    //             q1, q2, q3, q4
    //     };


    //     PageReference pr = Page.ApplicationRequirement;
    //     pr.getParameters().put('contactId', student.Id);
    //     pr.getParameters().put('applicationId', app.Id);
    //     pr.getParameters().put('requirementId', req.Id);
    //     Test.setCurrentPage(pr);
    //     ApplicationRequirement ac = new ApplicationRequirement();
    //     EASYApplicationInfo appInfo = new EASYApplicationInfo();
    //     appInfo.appId = app.Id;
    //     appInfo.contactId = student.Id;
    //     appInfo.requirementId = req.Id;
    //     appInfo.appControlId = appControl.Id;
    //     appInfo.isExternalUser = true;
    //     ac.appInfo = appInfo;Program__c
    // }

    // @IsTest
    // public static void testMiscQuestion() {
    //     Test.startTest();

    //     new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Account(), 'Name', Schema.DisplayType.STRING, true);
    //     new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Account(), 'Name');
    //     new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Account(), 'Name', 'test');
    //     new ApplicationQuestion(new Account(), new Question__c(Length__c = 100), new Question_Response__c(), null);
    //     new ApplicationQuestion(new Application__c(), new Question__c(Application_Field__c = 'Student_Type__c', Hardcoded_Value__c = 'Test'), new Question_Response__c(), null);
    //     ApplicationQuestion q1 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Account(), 'Industry', Schema.DisplayType.PICKLIST, true);
    //     ApplicationQuestion q2 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Account(), 'Industry', Schema.DisplayType.MULTIPICKLIST, true);
    //     ApplicationQuestion q3 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Contact(), 'MailingAddress', Schema.DisplayType.ADDRESS, true);
    //     ApplicationQuestion q4 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Contact(), 'HasOptedOutOfEmail', Schema.DisplayType.BOOLEAN, true);
    //     ApplicationQuestion q5 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Contact(), 'Phone', Schema.DisplayType.PHONE, true);
    //     ApplicationQuestion q6 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Contact(), 'Email', Schema.DisplayType.EMAIL, true);
    //     ApplicationQuestion q7 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Contact(), 'Birthdate', Schema.DisplayType.DATE, true);
    //     ApplicationQuestion q8 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Account(), 'AnnualRevenue', Schema.DisplayType.CURRENCY, true);
    //     ApplicationQuestion q9 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Account(), 'NumberOfEmployees', Schema.DisplayType.INTEGER, true);
    //     ApplicationQuestion q10 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Account(), 'Description', Schema.DisplayType.TEXTAREA, true);
    //     ApplicationQuestion q11 = new ApplicationQuestion(new Contact(), new Application__c(), 'test', new Account(), 'Website', Schema.DisplayType.URL, true);

    //     Schema.FieldSetMember fsm;
    //     for (Schema.FieldSetMember m : Schema.SObjectType.Application_Review__c.fieldSets.Application_Review_Header.getFields()) {
    //         fsm = m;
    //         break;
    //     }

    //     ApplicationQuestion q12 = new ApplicationQuestion(fsm, new Application_Review__c(), Application_Review__c.SObjectType);

    //     q1.setPicklistOptions(new Map<String, String>{
    //             'test' => 'test'
    //     });
    //     q1.setReferenceOptions(new Map<Id, String>{
    //             Id.valueOf('001000000000000') => 'test'
    //     });
    //     q1.addControllingQuestion(q2, new Set<String>{
    //             'test'
    //     });
    //     q1.addControllingQuestions(new Map<ApplicationQuestion, Set<String>>{
    //             q2 => new Set<String>{
    //                     'test'
    //             }
    //     });
    //     q1.addDependentOptions(new Map<String, Map<String, String>>{
    //             'test' => new Map<String, String>{
    //                     'test' => 'test'
    //             }
    //     });
    //     q1.addIntendedProgramFilteringList(new List<Program__c>());
    //     q1.makeRadio();
    //     q1.acc = null;
    //     q2.controllingQuestion = q1;
    //     q2.intendedPrograms = new List<Program__c>{
    //             new Program__c(Name = 'test', Id = Id.valueOf(Schema.SObjectType.Program__c.getKeyPrefix() + '000000000000'))
    //     };
    //     q2.dependentOptions = new Map<String, List<SelectOption>>();
    //     List<SelectOption> options = q2.options;
    //     q2.question = new Question__c(URL_Parameter__c = 'test');
    //     q2.multiControllingQuestions = new Map<ApplicationQuestion, Set<String>>{
    //             q1 => new Set<String>{
    //                     'Test'
    //             }
    //     };
    //     q2.checkMultiControllingQuestion();
    //     ApplicationQuestion.getStateAndCountryPicklistEnabled();
    //     q3.processValue();
    //     q4.processValue();
    //     q5.response.ValuePhone__c = 'test';
    //     q5.processValue();
    //     q6.response.ValueEmail__c = 'test@test.com';
    //     q6.processValue();
    //     q7.response.ValueDate__c = Date.today();
    //     q7.processValue();
    //     q8.response.ValueCurrency__c = 1;
    //     q8.processValue();
    //     q9.response.ValueNumber__c = 1;
    //     q9.processValue();
    //     q10.response.ValueLongTextArea__c = 'test';
    //     q10.processValue();
    //     q11.response.ValueURL__c = 'www.test.com';
    //     q11.processValue();
    //     new ApplicationQuestionGroup(new List<ApplicationQuestion>());

    //     Test.stopTest();
    // }
}