/**
 * @last modified on  : 08-08-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
@IsTest
public class ApplicationReview_TEST {
    @TestSetup
    public static void testSetup() {
        //Turn of hed__ TDTM
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        for (hed.TDTM_Global_API.TdtmToken TDTMToken : tokens) {
            // disable all EDA-provided trigger handlers
            if (TDTMToken.ownedByNamespace == 'hed') {
                TDTMToken.active = false;
            }
        }
        hed.TDTM_Global_API.setTdtmConfig(tokens);


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
                StageName = 'Suspect', CloseDate = System.today()
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

        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }

        Map<String, Id> rtMapQD = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Question_Dependency__c']) {
            rtMapQD.put(rt.DeveloperName, rt.Id);
        }

        Map<String, Id> rtMapRI = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Requirement_Item__c']) {
            rtMapRI.put(rt.DeveloperName, rt.Id);
        }

        Requirement__c req = new Requirement__c(
                Active__c = true,
                Name = 'Test Req',
                Application_Control__c = appControl.Id
        );
        insert req;
        Requirement_Item__c riQG = new Requirement_Item__c(
                Requirement__c = req.Id,
                Name = 'Test RI',
                Active__c = true,
                RecordTypeId = rtMapRI.get('Question_Group'),
                Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
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
                Active__c = true,
                Name = 'Test Req 2',
                Application_Control__c = appControl.Id,
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
                Requirement_Item__c = riDU.Id, HasDocument__c = true
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
    public static void appReview() {
        Application__c app = [
                SELECT Id,
                        Generic_Filter_1__c,
                        Generic_Filter_2__c,
                        Generic_Filter_3__c,
                        Generic_Filter_4__c,
                        Generic_Filter_5__c,
                        Generic_Filter_6__c,
                        Generic_Filter_7__c,
                        Generic_Filter_8__c
                FROM Application__c
                LIMIT 1
        ];
        Contact student = [
                SELECT Id
                FROM Contact
                LIMIT 1
        ];

        PageReference pr = Page.ApplicationReview;
        pr.getParameters().put('contactId', student.Id);
        pr.getParameters().put('applicationId', app.Id);
        Test.setCurrentPage(pr);
        ApplicationReview ar = new ApplicationReview();
        ar.init();
        System.assertEquals(1, [SELECT COUNT() FROM Application_Review__c]);
        ar.review.Decision_Recommendation__c = 'Accepted';
        ar.submit();
    }
}