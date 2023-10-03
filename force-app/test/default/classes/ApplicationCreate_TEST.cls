/**
 * @last modified on  : 08-08-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
@IsTest
private class ApplicationCreate_TEST {
    @TestSetup
    static void setup() {
        Application_Control__c appControl = ApplicationTESTUtilities.createApplicationControl();

        // Create and insert Interaction Mapping Test Data
        List<Interaction_Mapping__c> testMappings = INT_TestDataFactory.createTestMappings();
        insert testMappings;


        Contact con = new Contact(
                FirstName = 'TestFirst',
                LastName = 'test',
                Email = 'testfirst@test.com'
        );
        insert con;

        Account acc = new Account(
                Name = 'Test Account',
                hed__Primary_Contact__c = con.Id
        );
        insert acc;

        hed__Term__c hedTerm = new hed__Term__c(
                Name = 'Test 2022',
                hed__Account__c = acc.Id
        );
        insert hedTerm;

        Academic_Term__c at = new Academic_Term__c(
                Name = 'test',
                Activate_Application_Date__c = Date.today().addDays(-2),
                End_Application_Date__c = Date.TODAY().addDays(2),
                Term__c = hedTerm.Id,
                Term_Start_Date__c = Date.today().addDays(5),
                Term_End_Date__c = Date.today().addDays(20)
        );
        insert at;

        Program__c p1 = new Program__c(
                Name = 'test1',
                Application_Control__c = appControl.Id,
                Number_of_Applications_Limit__c = 'One Application',
                Applicant_Type__c = Program__c.Applicant_Type__c.getDescribe().getPicklistValues()[0].getValue(),
                Program_Integration_External_Id__c = ApplicationUtilities.getUUID(),
                Program_Name_on_Application__c = 'test1'
        );
        Program__c p2 = new Program__c(
                Name = 'test2',
                Number_of_Applications_Limit__c = 'One Application Per Term',
                Hide_Applicant_Type__c = Program__c.Hide_Applicant_Type__c.getDescribe().getPicklistValues()[0].getValue(),
                Program_Integration_External_Id__c = ApplicationUtilities.getUUID(),
                Program_Name_on_Application__c = 'test2'
        );
        Program__c p3 = new Program__c(
                Name = 'test3',
                Number_of_Applications_Limit__c = 'One Application Per Program',
                Hide_Student_Type__c = Program__c.Hide_Student_Type__c.getDescribe().getPicklistValues()[0].getValue(),
                Program_Integration_External_Id__c = ApplicationUtilities.getUUID(),
                Program_Name_on_Application__c = 'test3'
        );
        Program__c p4 = new Program__c(
                Name = 'test4',
                Hide_Citizenship__c = Program__c.Hide_Citizenship__c.getDescribe().getPicklistValues()[0].getValue(),
                Program_Integration_External_Id__c = ApplicationUtilities.getUUID(),
                Program_Name_on_Application__c = 'test4'
        );
        Program__c p5 = new Program__c(
                Name = 'test5',
                Program_Integration_External_Id__c = ApplicationUtilities.getUUID(),
                Program_Name_on_Application__c = 'test5'
        );
        insert new List<Program__c>{
                p1, p2, p3, p4, p5
        };

        Plan__c plan1 = new Plan__c(
                Name = 'Test Plan',
                Plan_Code__c = 'TE_ST_CODE',
                Career__c = 'Undergraduate',
                Type__c = 'Recruitment',
                Program__c = p3.Id,
                Active__c = TRUE
        );
        insert plan1;

        Plan__c plan2 = new Plan__c(
                Name = 'Test Plan',
                Plan_Code__c = 'TE_ST_CODE',
                Career__c = 'Undergraduate',
                Type__c = 'Recruitment',
                Program__c = p4.Id,
                Active__c = TRUE
        );
        insert plan2;


        Intended_Program_Term__c ipt = new Intended_Program_Term__c(
                Intended_Program__c = p1.Id,
                Academic_Term__c = at.Id,
                Applicant_Type__c = Intended_Program_Term__c.Applicant_Type__c.getDescribe().getPicklistValues()[0].getValue(),
                Intended_Program_Term_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
                Activate_Application_Date__c = Date.today().addDays(-2),
                End_Application_Date__c = Date.TODAY().addDays(2)
        );
        insert ipt;

        Application__c app2 = new Application__c(
                Contact__c = con.Id,
                Intended_Program__c = p3.Id,
                Intended_Term_of_Entry__c = at.Id,
                Application_Status__c = 'Started App',
                Application_Control__c = appControl.Id
        );
        Application__c app3 = new Application__c(
                Contact__c = con.Id,
                Intended_Program__c = p4.Id,
                Intended_Term_of_Entry__c = at.Id,
                Application_Status__c = 'Started App',
                Application_Control__c = appControl.Id
        );
        insert new List<Application__c>{
                app2, app3
        };

        Id inquiryRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Inquiry_Opportunity').getRecordTypeId();
        Id appRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Applicant_Opportunity').getRecordTypeId();

        Interaction__c int2 = new Interaction__c(
                Interaction_Source__c = 'Application',
                Interaction_Status__c ='New',
                Academic_Program__c = p3.Id,
                Admit_Type__c = 'First-Year',
                Recruitment_Interest__c = Plan1.Id,
                Intended_Start_Term__c = at.Id,
                Country__c = 'United States of America',
                Opportunity_Record_Type__c = appRT,
                Opportunity_Stage__c = 'Started App',
                Term__c = hedTerm.Id,
                Date_Started_App__c = System.today(),
                Lead_Source__c = 'Application',
                Contact__c = con.Id,
                Email__c = con.Email,
                First_Name__c = con.FirstName,
                Last_Name__c = con.LastName,
                College_of_Interest__c = '4 Year College',
                Admissions_Application__c = app2.Id
        );

        Interaction__c int3 = new Interaction__c(
                Interaction_Source__c = 'Application',
                Interaction_Status__c ='New',
                Academic_Program__c = p4.Id,
                Admit_Type__c = 'First-Year',
                Recruitment_Interest__c = Plan2.Id,
                Intended_Start_Term__c = at.Id,
                Country__c = 'United States of America',
                Opportunity_Record_Type__c = appRT,
                Opportunity_Stage__c = 'Started App',
                Term__c = hedTerm.Id,
                Date_Started_App__c = System.today(),
                Lead_Source__c = 'Application',
                Contact__c = con.Id,
                Email__c = con.Email,
                First_Name__c = con.FirstName,
                Last_Name__c = con.LastName,
                College_of_Interest__c = '4 Year College',
                Admissions_Application__c = app3.Id
        );
        insert int2;


        Opportunity newOpp = new Opportunity(
                RecordTypeId = appRT,
                Name = 'test|test|test3',
                AccountId = acc.Id,
                Contact__c = con.Id,
                StageName = 'Started App',
                Admissions_Application__c = app2.Id,
                CloseDate = System.today(),
                Academic_Program__c = p3.Id,
                Term__c = hedTerm.Id,
                Country__c = 'United States of America',
                Citizenship__c = 'U.S. Citizen',
                Recruitment_Interest__c = plan1.Id,
                Intended_Start_Term__c = at.Id
        );
        insert newOpp;

        Opportunity newOpp2 = new Opportunity(
                Name = 'test|test|test3',
                AccountId = acc.Id,
                Contact__c = con.Id,
                StageName = 'Started App',
                Admissions_Application__c = app3.Id,
                CloseDate = System.today(),
                Academic_Program__c = p4.Id,
                Term__c = hedTerm.Id,
                Country__c = 'United States of America',
                Citizenship__c = 'U.S. Citizen',
                Recruitment_Interest__c = plan1.Id,
                Intended_Start_Term__c = at.Id
        );
        insert newOpp2;


        Requirement__c req1 = new Requirement__c(
                Application_Control__c = appControl.Id,
                Active__c = true,
                Name = 'test1',
                Show_on_Application_Creation__c = true,
                Application_Creation_Display_Order__c = 'Before Term/Program Questions',
                Requirement_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        Requirement__c req2 = new Requirement__c(
                Application_Control__c = appControl.Id,
                Active__c = true,
                Name = 'test2',
                Show_on_Application_Creation__c = true,
                Application_Creation_Display_Order__c = 'After Term/Program Questions',
                Requirement_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        insert new List<Requirement__c>{
                req1, req2
        };

        Requirement_Item__c item1 = new Requirement_Item__c(
                Requirement__c = req1.Id,
                Name = 'test1',
                Active__c = true,
                RecordTypeId = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByName().get('Question Group').getRecordTypeId(),
                Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        Requirement_Item__c item2 = new Requirement_Item__c(
                Requirement__c = req2.Id,
                Name = 'test2',
                Active__c = true,
                RecordTypeId = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByName().get('Question Group').getRecordTypeId(),
                Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        insert new List<Requirement_Item__c>{
                item1, item2
        };

        Question__c q1 = new Question__c(
                Requirement_Item__c = item1.Id,
                Name = 'test1',
                Label__c = 'test1',
                Active__c = true,
                Picklist_Values__c = 'One\nTwo',
                RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('Picklist').getRecordTypeId(),
                Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        Question__c q2 = new Question__c(
                Requirement_Item__c = item2.Id,
                Name = 'test2',
                Label__c = 'test2',
                Active__c = true,
                Picklist_Values__c = 'One\nTwo',
                RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('Picklist').getRecordTypeId(),
                Question_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        insert new List<Question__c>{
                q1, q2
        };

        insert new Question_Dependency__c(
                Question__c = q2.Id,
                Controlling_Question__c = q1.Id,
                Value__c = 'One',
                RecordTypeId = Schema.SObjectType.Question_Dependency__c.getRecordTypeInfosByName().get('Picklist').getRecordTypeId(),
                Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
    }

    @IsTest
    static void test_application_create() {

        Program__c prog1 = [SELECT Id, Applicant_Type__c FROM Program__c WHERE Name = :'test1'];
        Program__c prog2 = [SELECT Id, Hide_Applicant_Type__c FROM Program__c WHERE Name = :'test2'];
        Program__c prog3 = [SELECT Id, Hide_Student_Type__c FROM Program__c WHERE Name = :'test3'];
        Program__c prog4 = [SELECT Id, Hide_Citizenship__c FROM Program__c WHERE Name = :'test4'];
        Program__c prog5 = [SELECT Id FROM Program__c WHERE Name = :'test5'];
        Id termId = [SELECT Id FROM Academic_Term__c WHERE Name = :'test'].Id;
        Intended_Program_Term__c ipt = [SELECT Id, Applicant_Type__c FROM Intended_Program_Term__c WHERE Academic_Term__c = :termId];
        Id conId = [SELECT Id FROM Contact WHERE LastName = :'test'].Id;

        PageReference pr = Page.ApplicationCreate;
        pr.getParameters().put('contactId', conId);

        Test.startTest();

        Test.setCurrentPage(pr);
        ApplicationCreate ac = new ApplicationCreate();
        ac.ApplicationCreateInit();
        ac.save();

        Question_Response__c programResponse;

        for (ApplicationQuestionGroup g : ac.section.groups) {
            for (ApplicationQuestion q : g.questions) {
                if (q.fieldName != null && q.fieldName.equals('Intended_Program__c')) {
                    programResponse = q.response;
                } else if (q.fieldName != null && q.fieldName.equals('Intended_Term_of_Entry__c')) {
                    q.response.ValueText__c = termId;
                } else if (q.label.equals('test1')) {
                    q.response.ValueText__c = 'One';
                }
            }
        }

        programResponse.ValueText__c = prog1.Id;
        PageReference returnPage1 = ac.save();
        ac.app.Applicant_Type__c = prog1.Applicant_Type__c;
        PageReference returnPage2 = ac.save();
        delete [SELECT Id FROM Intended_Program_Term__c];
        PageReference returnPage3 = ac.save();

        programResponse.ValueText__c = prog2.Id;
        ac.app.Applicant_Type__c = prog2.Hide_Applicant_Type__c;
        PageReference returnPage4 = ac.save();
        ac.app.Applicant_Type__c = null;
        PageReference returnPage5 = ac.save();

        programResponse.ValueText__c = prog3.Id;
        ac.app.Student_Type__c = prog3.Hide_Student_Type__c;
        PageReference returnPage6 = ac.save();
        ac.app.Student_Type__c = null;
        PageReference returnPage7 = ac.save();

        programResponse.ValueText__c = prog4.Id;
        ac.app.Citizenship__c = prog4.Hide_Citizenship__c;
        PageReference returnPage8 = ac.save();

        programResponse.ValueText__c = prog5.Id;
        PageReference returnPage9 = ac.save();

        Test.stopTest();
        System.assertEquals(null, returnPage1);
        System.assertEquals(null, returnPage2);
        System.assertEquals(null, returnPage3);
        System.assertEquals(null, returnPage4);
        System.assertEquals(null, returnPage5);
        System.assertEquals(null, returnPage6);
        System.assertEquals(null, returnPage7);
        System.assertEquals(null, returnPage8);
        System.assertEquals(null, returnPage9);
    }

    @IsTest
    static void test_other() {
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c WHERE Name = :'test'];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        appControl.Default__c = false;
        appControl.URL_Parameter__c = 'test';
        update appControl;

        Id conId = [SELECT Id FROM Contact WHERE LastName = :'test'].Id;
        PageReference pr = Page.ApplicationCreate;
        //pr.getParameters().put('contactId', conId);
        pr.getParameters().put('at', appControl.Id);

        Test.startTest();
        Test.setCurrentPage(pr);

        ApplicationCreate ac = new ApplicationCreate();
        ac.ApplicationCreateInit();
        ac.applicationCreateSetup(new ApplicationQuestionGroup(new List<ApplicationQuestion>()), new ApplicationQuestionGroup(new List<ApplicationQuestion>()));
        delete [SELECT Id FROM Requirement__c WHERE Application_Control__c = :appControl.Id];
        appControl.Hide_Term_Program__c = true;
        update appControl;

        ac = new ApplicationCreate();
        ac.ApplicationCreateInit();
        //ac.app.Contact__c = null;
        PageReference returnPage = ac.save();
        Id appId = ac.app.Id;
        Id contactId = ac.contactId;
        List<RequirementWrapper> reqWrapper = ac.checklistItems;
        String degreeType = ac.degreeType;
        String template = ac.template;

        ac = new ApplicationCreate();
        ac.additionalDataString = 'not json';
        ac.ApplicationCreateInit();
        PageReference returnPage2 = ac.save();

        Test.stopTest();
        /*
        System.assertEquals('System.PageReference[/apex/ApplicationPortal?applicationId=a2MP0000000lqOXMAY&amp;at=test&amp;contactId=null', String.valueOf(returnPage));

        System.assertEquals(null, returnPage);
        */
        System.assertEquals(null, returnPage2);

    }

    @IsTest
    public static void testLookupSearch() {
        Test.startTest();
        insert new Account(Name = 'Example Account');
        Test.stopTest();
        List<SObject> results = ApplicationCreate.lookupSearch('Account', null, 'Name', 'Example');
        System.assertEquals(1, results.size());
    }

    
}