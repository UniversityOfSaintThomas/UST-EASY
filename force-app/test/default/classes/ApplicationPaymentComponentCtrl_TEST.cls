/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/24/2022.
 */


@IsTest
private class ApplicationPaymentComponentCtrl_TEST {

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
                Name = 'Deposit Test',
                Label__c = 'Deposit Test',
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

        Map<String, Id> questionTypeMap = new Map<String, Id>();
        for (RecordType qt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
            questionTypeMap.put(qt.DeveloperName, qt.Id);
        }
        system.debug(questionTypeMap);


        Requirement_Item__c riQG = new Requirement_Item__c(
                Requirement__c = req.Id,
                Name = 'Deposit Payment Type Test',
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

        Requirement_Response__c reqResponse = new Requirement_Response__c();
        reqResponse.Requirement_Item__c = riQG.Id;
        reqResponse.Application__c = app.Id;
        insert reqResponse;

        Question__c q1 = new Question__c(
                Active__c = true,
                RecordTypeId = questionTypeMap.get('Payment'),
                Name = 'Deposit',
                Label__c = 'Deposit',
                Requirement_Item__c = riQG.Id,
                Question_Integration_External_Id__c = ApplicationUtilities.getUUID(),
                Payment_Gateway__c = 'First_Year_Undergraduate_Deposit',
                Payment_Type__c = 'Program Application Fee Amount'

        );
        Question__c q3 = new Question__c(
                Active__c = true,
                RecordTypeId = questionTypeMap.get('Text'),
                Name = 'Test3',
                Label__c = 'Test3',
                Requirement_Item__c = riQG.Id,
                Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        insert new List<Question__c>{
                q1, q3
        };

        Application_Setting__c settings = new Application_Setting__c();
        settings.Default_Template__c = 'testTemplate';
        settings.Community_Profile_Ids__c = 'TEST';
        settings.Permission_Set_Id__c = 'TEST';
        settings.Community_URL__c = 'https://google.com';
        insert settings;

    }

    @IsTest
    static void testEmptyParameters() {
        ApplicationPaymentComponentController payController = new ApplicationPaymentComponentController();
        String forParameters = payController.getFormParameters();
        Test.startTest();
        System.assertEquals('', forParameters);
        Test.stopTest();
    }

    @IsTest
    static void testEmptyParameters2() {

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        Application__c app = [SELECT Id, Name, Contact__r.FirstName, Contact__r.LastName FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id, URL_Parameter__c FROM Application_Control__c WHERE URL_Parameter__c = 'st'];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Requirement_Item__c ri = [SELECT Id FROM Requirement_Item__c LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c WHERE Name = 'Deposit Test'];
        Requirement_Response__c reqResponse = [SELECT Id FROM Requirement_Response__c LIMIT 1];

        Question__c question = [
                SELECT RecordType.DeveloperName,
                        RecordType.Name,
                        Contact_Field__c,
                        Application_Field__c,
                        URL_Parameter__c,
                        Length__c,
                        Placeholder__c,
                        Label__c,
                        Help_Text__c,
                        Assistive_Text__c,
                        Active__c,
                        Intended_Program__c,
                        Applicant_Type__c,
                        Citizenship__c,
                        School_College__c,
                        Delivery_Type__c,
                        Residency__c,
                        Student_Type__c,
                        Degree_Type__c,
                        Generic_Filter_1__c,
                        Generic_Filter_2__c,
                        Generic_Filter_3__c,
                        Generic_Filter_4__c,
                        Application_Status__c,
                        Hardcoded_Value__c,
                        Related_Object_Field__c,
                        Required__c,
                        New_Reference_Field__c,
                        Lookup_Object__c,
                        Editable_Application_Status__c,
                        Display_as_Picklist__c,
                        Payment_Gateway__c,
                        Payment_Type__c,
                        Payment_Custom_Amount__c
                FROM Question__c
                WHERE Name = 'Deposit'
        ];

        List<Application_Payment_Gateway__mdt> gatewayInfo = [
                SELECT Id, Label, DeveloperName, UPay_Site_Id__c, Validation_Key__c, Gateway_URL__c
                FROM Application_Payment_Gateway__mdt
                WHERE DeveloperName = :question.Payment_Gateway__c
        ];


        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.requirementId = req.Id;
        appInfo.appControlId = appControl.Id;
        appInfo.isExternalUser = true;

        ApplicationPaymentComponentController payController = new ApplicationPaymentComponentController();
        payController.appInfoParam = appInfo;
        ApplicationQuestion appQuestion = new ApplicationQuestion(null, question, null, false);
        appQuestion.reqResponse = reqResponse;
        appQuestion.question = question;
        payController.question = appQuestion;

        String formParameters = payController.getFormParameters();

        String exTransId = app.Contact__r.FirstName + ' ' + app.Contact__r.LastName + ' | ' + app.Name;

        String valCode = '';

        valCode = gatewayInfo[0].Validation_Key__c;
        // EXT_TRANS_ID passed from payment form and can be used to track in our business office
        valCode += exTransId;//ac.appInfo.appId;

        // Amount passed from VF payment form to set amout requested.
        valCode += '0.00';

        //All the above in one string, MD5 hashed, converted to base64 string. Checked at gateway for access to the uPay site
        Blob requestBlob = Blob.valueOf(valCode);
        Blob hash = Crypto.generateDigest('MD5', requestBlob);
        valCode = EncodingUtil.base64Encode(hash);

        String protectedIds = ApplicationUtilities.createEncryptedString('{"appId":"' + app.Id + '","responseId":"' + appQuestion.reqResponse.Id + '","questionId":"' + appQuestion.question.Id + '"}');

        Test.startTest();

        Map<String, String> parameters = (Map<String, String>) JSON.deserialize(formParameters, Map<String, String>.class);
        System.assertEquals(parameters.get('EXT_TRANS_ID'), exTransId);
        System.assertEquals(parameters.get('VALIDATION_KEY'), valCode);
        System.assertEquals(parameters.get('SUCCESS_LINK'), 'https://google.com/ApplicationRequirement?at=null&requirementId=' + req.Id);
        System.assertEquals(parameters.get('CANCEL_LINK'), 'https://google.com/ApplicationRequirement?at=null&requirementId=' + req.Id);
        System.assertEquals(parameters.get('ERROR_LINK'), 'https://google.com/ApplicationRequirement?at=null&requirementId=' + req.Id);

        String protectedIdsEncrypted = parameters.get('EASY_APP');
        protectedIdsEncrypted = ApplicationUtilities.decryptString(protectedIdsEncrypted, true);
        Map<String, String> appIds = (Map<String, String>) JSON.deserialize(protectedIdsEncrypted, Map<String, String>.class);
        Id appId = appIds.get('appId');
        Id responseId = appIds.get('responseId');
        Id questionId = appIds.get('questionId');

        System.assertEquals(app.Id, appId);
        System.assertEquals(appQuestion.reqResponse.Id, responseId);
        System.assertEquals(appQuestion.question.Id, questionId);

        Test.stopTest();

    }
}