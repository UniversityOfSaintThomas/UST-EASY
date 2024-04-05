@IsTest
public with sharing class gradRecommendationInfoController_TEST {
    @TestSetup
    static void setup(){
        // setup application control
        Application_Control__c app_control = new Application_Control__c(
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
        insert app_control;

        Requirement__c recommendation_requirement = new Requirement__c(
                Application_Control__c = app_control.Id,
                Name = 'Letter of Recommendation',
                Active__c = true
        );
        insert recommendation_requirement;

        Id question_group_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Question_Group').getRecordTypeId();
        Id related_object_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Related_Object').getRecordTypeId();
        Id document_upload_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Document_Upload').getRecordTypeId();
        Requirement_Item__c request_recommendation_ri = new Requirement_Item__c(
                Requirement__c = recommendation_requirement.Id,
                RecordTypeId = question_group_RT,
                Active__c = true,
                Name = 'Request Recommendation',
                Related_List_Object__c = 'Recommendation__c'
        );
        insert request_recommendation_ri;

        List<Requirement_Item__c> ri_to_insert = new List<Requirement_Item__c>();
        Requirement_Item__c recommender_info_ri = new Requirement_Item__c(
                Requirement__c = recommendation_requirement.Id,
                RecordTypeId = related_object_RT,
                Active__c = true,
                Name = 'Recommender Info',
                Internal_Requirement_Item__c = request_recommendation_ri.Id,
                Related_List_Object__c = 'Recommendation__c',
                Related_List_Object_Master__c = 'Application',
                Related_List_Object_Master_Field__c = 'Application__c'
        );
        ri_to_insert.add(recommender_info_ri);

        Requirement_Item__c document_upload_ri = new Requirement_Item__c(
                Requirement__c = recommendation_requirement.Id,
                RecordTypeId = document_upload_RT,
                Active__c = true,
                Name = 'Letter of Recommendation',
                Internal_Requirement_Item__c = request_recommendation_ri.Id,
                File_Types__c = 'PDF;DOC;TXT',
                Allow_Text_Entry__c = true
        );
        ri_to_insert.add(document_upload_ri);
        insert ri_to_insert;

        Id text_RT = Schema.SObjectType.Question__c.getRecordTypeInfosByDeveloperName().get('Text').getRecordTypeId();
        Id email_RT = Schema.SObjectType.Question__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        List<Question__c> questions_to_insert = new List<Question__c>();
        Question__c request_question1 = new Question__c(
                Requirement_Item__c = request_recommendation_ri.Id,
                RecordTypeId = text_RT,
                Active__c = true,
                Name = 'Recommender First Name',
                Related_Object_Field__c = 'First_Name__c'
        );
        questions_to_insert.add(request_question1);

        Question__c request_question2 = new Question__c(
                Requirement_Item__c = request_recommendation_ri.Id,
                RecordTypeId = text_RT,
                Active__c = true,
                Name = 'Recommender Last Name',
                Related_Object_Field__c = 'Last_Name__c'
        );
        questions_to_insert.add(request_question2);

        Question__c request_question3 = new Question__c(
                Requirement_Item__c = request_recommendation_ri.Id,
                RecordTypeId = email_RT,
                Active__c = true,
                Name = 'Recommender Email',
                Related_Object_Field__c = 'Rec_Email__c',
                External_Email_Field__c = true
        );
        questions_to_insert.add(request_question3);

        Question__c recommender_question1 = new Question__c(
                Requirement_Item__c = recommender_info_ri.Id,
                RecordTypeId = text_RT,
                Active__c = true,
                Name = 'First Name',
                Related_Object_Field__c = 'First_Name__c'
        );
        questions_to_insert.add(recommender_question1);

        Question__c recommender_question2 = new Question__c(
                Requirement_Item__c = recommender_info_ri.Id,
                RecordTypeId = text_RT,
                Active__c = true,
                Name = 'Last Name',
                Related_Object_Field__c = 'Last_Name__c'
        );
        questions_to_insert.add(recommender_question2);

        Question__c recommender_question3 = new Question__c(
                Requirement_Item__c = recommender_info_ri.Id,
                RecordTypeId = email_RT,
                Active__c = true,
                Name = 'Recommender Email',
                Related_Object_Field__c = 'Rec_Email__c',
                External_Email_Field__c = true
        );
        questions_to_insert.add(recommender_question3);
        insert questions_to_insert;

        // setup application
        Contact student = new Contact(
                FirstName = 'TestFirst',
                LastName = 'TestLast',
                Email = 'testfirst@testlast.com'
        );
        insert student;

        Account acc = new Account(Name = 'NewAcc');
        insert acc;

        hed__Term__c hed_term = new hed__Term__c(
                Name = 'Test 2022',
                hed__Account__c = acc.Id
        );
        insert hed_term;

        Academic_Term__c term = new Academic_Term__c(
                Name = 'Test 2022',
                Term__c = hed_term.Id
        );
        insert term;

        Program__c program = new Program__c(
                Name = 'Test Program',
                Program_Name_on_Application__c = 'Test Program',
                Program_College_of_Interest__c = 'Graduate'
        );
        insert program;

        Plan__c plan = new Plan__c(
                Name = 'Test Program',
                Plan_Code__c = 'TE_ST_CODE',
                Career__c = 'Graduate',
                Type__c = 'Recruitment',
                Program__c = program.Id
        );
        insert plan;

        Intended_Program_Term__c ipt = new Intended_Program_Term__c(
                Intended_Program__c = program.Id,
                Academic_Term__c = term.Id,
                Activate_Application_Date__c = Date.today().addDays(-1),
                End_Application_Date__c = Date.TODAY().addDays(-1),
                Applicant_Type__c = Intended_Program_Term__c.Applicant_Type__c.getDescribe().getPicklistValues()[0].getValue(),
                Intended_Program_Term_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        insert ipt;

        Interaction__c inter = new Interaction__c(
                Interaction_Source__c = 'Application',
                Interaction_Status__c = 'New',
                First_Name__c = student.FirstName,
                Last_Name__c = student.LastName,
                Email__c = student.Email,
                Opportunity_Stage__c = 'Suspect',
                Term__c = hed_term.Id
        );
        insert inter;

        Opportunity opp = new Opportunity(
                AccountId = acc.Id,
                Contact__c = student.Id,
                Name = 'TestLast|Test 2022|Test Program',
                CloseDate = system.today(),
                StageName = 'Started App'
        );
        insert opp;


        Application__c app = new Application__c(
                Contact__c = student.Id,
                Application_Control__c = app_control.Id,
                Intended_Term_of_Entry__c = term.Id,
                Intended_Program__c = program.Id,
                Application_Status__c = 'Started App',
                Generic_Filter_2__c = 'Male'
        );
        insert app;



        // set up responses
        List<Requirement_Response__c> rr_to_insert = new List<Requirement_Response__c>();
        Requirement_Response__c request_rr = new Requirement_Response__c(
                Requirement_Item__c = request_recommendation_ri.Id,
                Application__c = app.Id,
                External_Email__c = 'testrecommender@test.com'
        );
        rr_to_insert.add(request_rr);

        Requirement_Response__c recommender_info_rr = new Requirement_Response__c(
                Requirement_Item__c = recommender_info_ri.Id,
                Application__c = app.Id
        );
        rr_to_insert.add(recommender_info_rr);

        Requirement_Response__c document_upload_rr = new Requirement_Response__c(
                Requirement_Item__c = document_upload_ri.Id,
                Application__c = app.Id
        );
        rr_to_insert.add(document_upload_rr);

        insert rr_to_insert;

        Recommendation__c recommendation = new Recommendation__c(
                Recommendation_Requirement_Response__c = request_rr.Id,
                Application__c = app.Id,
                Rec_Email__c = 'testrecommender@test.com',
                Status__c = 'Requested'
        );
        insert recommendation;
    }

    @IsTest
    public static void testGetRelatedObjectInfo() {
        Recommendation__c recommendation = [
                SELECT Id,
                        Display_Instructive_Text__c,
                        Submitted__c,
                        Rec_Email__c
                FROM Recommendation__c
                LIMIT 1
        ];

        Application__c app = [
                SELECT Id,
                        Application_Status__c,
                        Application_Control__r.Id
                FROM Application__c
                LIMIT 1
        ];

        List<Id> record_type_ids = new List<Id>();
        Id related_object_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Related_Object').getRecordTypeId();
        Id document_upload_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Document_Upload').getRecordTypeId();
        record_type_ids.add(related_object_RT);
        record_type_ids.add(document_upload_RT);
        List<Requirement_Item__c> req_items = [
                SELECT Id,
                        Instructions__c,
                        Allow_Text_Entry__c,
                        File_Types__c,
                        Required__c,
                        RecordTypeId
                FROM Requirement_Item__c
                WHERE RecordTypeId IN: record_type_ids
        ];
        Requirement_Item__c related_object_ri;
        Requirement_Item__c document_upload_ri;
        for (Requirement_Item__c req_item : req_items) {
            if (req_item.RecordTypeId == related_object_RT) {
                related_object_ri = req_item;
            } else {
                document_upload_ri = req_item;
            }
        }
        Test.startTest();
        Map<String, String> related_object_info = graduateRecommenderInfoController.getRelatedObjectInfo(recommendation.Id);
        Test.stopTest();

        System.assertEquals(String.valueOf(recommendation.Id), related_object_info.get('recommendation_id'));
        System.assertEquals(String.valueOf(app.Id), related_object_info.get('application_id'));
        System.assertEquals(String.valueOf(app.Application_Status__c), related_object_info.get('application_status'));
        System.assertEquals(String.valueOf(app.Application_Control__r.Id), related_object_info.get('application_control_id'));
        System.assertEquals(String.valueOf(recommendation.Display_Instructive_Text__c), related_object_info.get('display_instructive_text'));
        System.assertEquals(String.valueOf(recommendation.Submitted__c), related_object_info.get('submitted'));
        System.assertEquals(String.valueOf(recommendation.Rec_Email__c), related_object_info.get('rec_email'));
        System.assertEquals(String.valueOf(related_object_ri.Instructions__c), related_object_info.get('related_object_requirement_item_instructions'));
        System.assertEquals(String.valueOf(related_object_ri.Id), related_object_info.get('related_object_requirement_item_id'));
        System.assertEquals(String.valueOf(document_upload_ri.Instructions__c), related_object_info.get('document_upload_requirement_item_instructions'));
        System.assertEquals(String.valueOf(document_upload_ri.Id), related_object_info.get('document_upload_requirement_item_id'));
        System.assertEquals(String.valueOf(document_upload_ri.Allow_Text_Entry__c), related_object_info.get('document_upload_requirement_item_allow_text_entry'));
        System.assertEquals(String.valueOf(document_upload_ri.File_Types__c), related_object_info.get('document_upload_requirement_item_file_types'));
        System.assertEquals(String.valueOf(document_upload_ri.Required__c), related_object_info.get('document_upload_requirement_item_required'));
    }

    @IsTest
    public static void testNullRequirementItems() {
        // setup application control
        Application_Control__c app_control = [SELECT Id FROM Application_Control__c LIMIT 1];

        Requirement__c recommendation_requirement = new Requirement__c(
                Application_Control__c = app_control.Id,
                Name = 'Letter of Recommendation 2',
                Active__c = true
        );
        insert recommendation_requirement;

        Id question_group_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Question_Group').getRecordTypeId();
        Requirement_Item__c request_recommendation_ri = new Requirement_Item__c(
                Requirement__c = recommendation_requirement.Id,
                RecordTypeId = question_group_RT,
                Active__c = true,
                Name = 'Request Recommendation 2',
                Related_List_Object__c = 'Recommendation__c'
        );
        insert request_recommendation_ri;

        // setup application
        Contact student = new Contact(
                FirstName = 'TestFirst',
                LastName = 'TestLast',
                Email = 'testfirst@testlast.com'
        );
        insert student;

        Account acc = new Account(Name = 'NewAcc');
        insert acc;

        hed__Term__c hed_term = new hed__Term__c(
                Name = 'Test 2022',
                hed__Account__c = acc.Id
        );
        insert hed_term;

        Academic_Term__c term = new Academic_Term__c(
                Name = 'Test 2022',
                Term__c = hed_term.Id
        );
        insert term;

        Program__c program = new Program__c(
                Name = 'Test Program',
                Program_Name_on_Application__c = 'Test Program',
                Program_College_of_Interest__c = 'Graduate'
        );
        insert program;

        Plan__c plan = new Plan__c(
                Name = 'Test Program',
                Plan_Code__c = 'TE_ST_CODE',
                Career__c = 'Graduate',
                Type__c = 'Recruitment',
                Program__c = program.Id
        );
        insert plan;

        Intended_Program_Term__c ipt = new Intended_Program_Term__c(
                Intended_Program__c = program.Id,
                Academic_Term__c = term.Id,
                Activate_Application_Date__c = Date.today().addDays(-1),
                End_Application_Date__c = Date.TODAY().addDays(-1),
                Applicant_Type__c = Intended_Program_Term__c.Applicant_Type__c.getDescribe().getPicklistValues()[0].getValue(),
                Intended_Program_Term_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        insert ipt;

        Interaction__c inter = new Interaction__c(
                Interaction_Source__c = 'Application',
                Interaction_Status__c = 'New',
                First_Name__c = student.FirstName,
                Last_Name__c = student.LastName,
                Email__c = student.Email,
                Opportunity_Stage__c = 'Suspect',
                Term__c = hed_term.Id
        );
        insert inter;

        Opportunity opp = new Opportunity(
                AccountId = acc.Id,
                Contact__c = student.Id,
                Name = 'TestLast|Test 2022|Test Program',
                CloseDate = system.today(),
                StageName = 'Started App'
        );
        insert opp;


        Application__c app = new Application__c(
                Contact__c = student.Id,
                Application_Control__c = app_control.Id,
                Intended_Term_of_Entry__c = term.Id,
                Intended_Program__c = program.Id,
                Application_Status__c = 'Started App',
                Generic_Filter_2__c = 'Male'
        );
        insert app;

        // set up responses
        Requirement_Response__c request_rr = new Requirement_Response__c(
                Requirement_Item__c = request_recommendation_ri.Id,
                Application__c = app.Id,
                External_Email__c = 'testrecommender2@test.com'
        );
        insert request_rr;

        Recommendation__c recommendation = new Recommendation__c(
                Recommendation_Requirement_Response__c = request_rr.Id,
                Application__c = app.Id,
                Rec_Email__c = 'testrecommender2@test.com',
                Status__c = 'Requested'
        );
        insert recommendation;

        Test.startTest();
        Map<String, String> related_object_info = graduateRecommenderInfoController.getRelatedObjectInfo(recommendation.Id);
        Test.stopTest();

        System.assertEquals(null, related_object_info.get('related_object_requirement_item_instructions'));
        System.assertEquals(null, related_object_info.get('related_object_requirement_item_id'));
        System.assertEquals(null, related_object_info.get('document_upload_requirement_item_instructions'));
        System.assertEquals(null, related_object_info.get('document_upload_requirement_item_id'));
        System.assertEquals(null, related_object_info.get('document_upload_requirement_item_allow_text_entry'));
        System.assertEquals(null, related_object_info.get('document_upload_requirement_item_file_types'));
        System.assertEquals(null, related_object_info.get('document_upload_requirement_item_required'));
    }

    @IsTest
    public static void testGetRelatedObjectQuestions() {
        Id related_object_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Related_Object').getRecordTypeId();
        Requirement_Item__c req_item = [
                SELECT Id
                FROM Requirement_Item__c
                WHERE RecordTypeId =: related_object_RT
                LIMIT 1
        ];
        Application__c app = [
                SELECT Id
                FROM Application__c
                LIMIT 1
        ];
        Test.startTest();
        List<Question__c> questions = graduateRecommenderInfoController.getRelatedObjectQuestions(req_item.Id, app.Id);
        Test.stopTest();

        System.assertEquals(3, questions.size());
    }

    @IsTest
    public static void testLookup() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'NewAcc' LIMIT 1];
        Test.startTest();
        Map<Id, SObject> query_result = graduateRecommenderInfoController.lookup('Account', 'Name = \'NewAcc\'', 'Name');
        Test.stopTest();
        System.debug(query_result);
        System.assert(query_result.get(acc.Id) != null);
        System.assertEquals(1, query_result.size());
    }

    @IsTest
    public static void testUpdateRecommendation() {
        Id recommendation_id = [SELECT Id FROM Recommendation__c LIMIT 1].Id;
        String record_input = '{"First_Name__c":"Changed","Id":"' + recommendation_id + '"}';
        Test.startTest();
        graduateRecommenderInfoController.updateRecommendation(record_input, 'Recommendation__c');
        Test.stopTest();
        Recommendation__c updated_rec = [SELECT First_Name__c FROM Recommendation__c LIMIT 1];
        System.assertEquals('Changed', updated_rec.First_Name__c);
    }

    @IsTest
    public static void testUploadFile() {
        Id recommendation_id = [SELECT Id FROM Recommendation__c LIMIT 1].Id;
        List<ContentDocumentLink> cdl_before = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recommendation_id];
        System.assertEquals(0, cdl_before.size());
        Test.startTest();
        Id cv_id = graduateRecommenderInfoController.uploadFile('Test file contents', 'test.txt', recommendation_id);
        Test.stopTest();
        List<ContentDocumentLink> cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recommendation_id];
        System.assertEquals(1, cdl.size());
    }

    @IsTest
    public static void testUpdateRequirementResponses() {
        List<Id> record_type_ids = new List<Id>();
        Id related_object_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Related_Object').getRecordTypeId();
        Id document_upload_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Document_Upload').getRecordTypeId();
        record_type_ids.add(related_object_RT);
        record_type_ids.add(document_upload_RT);
        List<Requirement_Item__c> req_items = [
                SELECT Id,
                        Instructions__c,
                        Allow_Text_Entry__c,
                        File_Types__c,
                        Required__c,
                        RecordTypeId
                FROM Requirement_Item__c
                WHERE RecordTypeId IN: record_type_ids
        ];
        Requirement_Item__c related_object_ri;
        Requirement_Item__c document_upload_ri;
        for (Requirement_Item__c req_item : req_items) {
            if (req_item.RecordTypeId == related_object_RT) {
                related_object_ri = req_item;
            } else {
                document_upload_ri = req_item;
            }
        }
        Test.startTest();
        graduateRecommenderInfoController.updateRequirementResponses(related_object_ri.Id, document_upload_ri.Id);
        Test.stopTest();

        List<Requirement_Response__c> req_responses = [SELECT Fulfilled_On__c FROM Requirement_Response__c WHERE Requirement_Item__c IN: req_items LIMIT 2];
        for (Requirement_Response__c req_response : req_responses) {
            System.assert(req_response.Fulfilled_On__c != null);
        }
    }
}