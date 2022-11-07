/**
 * @last modified on  : 08-08-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
@IsTest
public class ApplicationQuestion_TEST {

    @TestSetup
    public static void testSetup() {
        Account acc = new Account(Name = 'NewAcc');
        insert acc;
        
        Contact student = new Contact(FirstName = 'TestFirst', LastName = 'TestStudent', Email = 'testfirst@teststudent.com');
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

        Requirement__c req = new Requirement__c(Application_Control__c = appControl.Id, Active__c = true, Name = 'Test Req', Requirement_Integration_External_Id__c = ApplicationUtilities.getUUID(), Internal_Only__c = true);
        insert req;
        Requirement_Item__c riQG = new Requirement_Item__c(Requirement__c = req.Id, Name = 'Test RI', Active__c = true, RecordTypeId = rtMapRI.get('Question_Group'), Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(), Internal_Only__c = true);
        Requirement_Item__c riDU = new Requirement_Item__c(Requirement__c = req.Id, Name = 'Test RI', Active__c = true, RecordTypeId = rtMapRI.get('Document_Upload'), Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        Requirement_Item__c riRO = new Requirement_Item__c(Requirement__c = req.Id, Name = 'Test RI', Active__c = true, RecordTypeId = rtMapRI.get('Related_Object'), Related_List_Object__c = 'Application__c', Related_List_Object_Master__c = 'Contact', Related_List_Object_Master_Field__c = 'Contact__c', Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        insert new List<Requirement_Item__c>{
                riQG, riDU, riRO
        };

        Requirement__c req2 = new Requirement__c(Application_Control__c = appControl.Id, Active__c = true, Name = 'Test Req 2', Requirement_Integration_External_Id__c = ApplicationUtilities.getUUID());
        insert req2;
        Requirement_Item__c riQG2 = new Requirement_Item__c(Requirement__c = req2.Id, Name = 'Test RI', Active__c = true, RecordTypeId = rtMapRI.get('Question_Group'), Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        insert riQG2;

        Question__c q1 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test', Label__c = 'Test', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID(), Additional_Field_Validation__c = 'validateName', Dependency_Logic__c = 'AND');
        Question__c q2 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test2', Label__c = 'Test2', Requirement_Item__c = riQG2.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID(), Additional_Field_Validation__c = 'validateName');
        Question__c q5 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Radio'), Name = 'Test5', Label__c = 'Test5', Picklist_Values__c = 'Test1;Test2', Requirement_Item__c = riQG2.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID(), Additional_Field_Validation__c = 'validateName', URL_Parameter__c = 'test');
        Question__c q3 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Text'), Name = 'Test3', Label__c = 'Test3', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID(), Additional_Field_Validation__c = 'validateName', Hardcoded_Value__c = 'Test', Contact_Field__c = 'Additional_Family_Members__c');
        Question__c q4 = new Question__c(Active__c = true, RecordTypeId = rtMap.get('Reference'), Name = 'Test4', Label__c = 'Test3', Requirement_Item__c = riQG.Id, Question_Integration_External_Id__c = ApplicationUtilities.getUUID(), Additional_Field_Validation__c = 'validateName', Lookup_Object__c = 'Contact', Display_as_Picklist__c = true, URL_Parameter__c = 'test', Lookup_Where_Clause__c = 'Name != null');
        insert new List<Question__c>{
                q1, q2, q3, q4
        };

        Question_Dependency__c qd1 = new Question_Dependency__c(Question__c = q1.Id, Controlling_Question__c = q2.Id, Value__c = 'Test', Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        Question_Dependency__c qd2 = new Question_Dependency__c(Question__c = q1.Id, Controlling_Question__c = q3.Id, Value__c = 'Test;Test2;Test3', RecordTypeId = rtMapQD.get('Multi_Select_Picklist'), Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        Question_Dependency__c qd3 = new Question_Dependency__c(Question__c = q2.Id, Controlling_Question__c = q3.Id, Value__c = 'Test;Test2', RecordTypeId = rtMapQD.get('Radio'), Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID());
        insert new List<Question_Dependency__c>{
                qd1, qd2, qd3
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
    public static void testVarious() {
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Application__c app = [SELECT Id, Applicant_Type__c, Citizenship__c, Student_Type__c, School_College__c, Delivery_Type__c, Degree_Type__c, Residency__c FROM Application__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Question__c> questions = [
            SELECT Id, 
                Name, 
                Lookup_Where_Clause__c, 
                Name_Field_API_Name__c, 
                Additional_Field_Validation__c, 
                URL_Parameter__c, 
                Lookup_Object__c, 
                Display_as_Picklist__c, 
                RecordType.DeveloperName, 
                Placeholder__c,
                Label__c,
                Help_Text__c,
                Assistive_Text__c
            FROM Question__c 
            WHERE Name = 'Test4' OR Name = 'Test5' 
            LIMIT 2
        ];
        Question__c question;
        Question__c question2;
        for (Question__c q : questions) {
            if (q.Name == 'Test4') {
                question = q;
            } else {
                question2 = q;
            }
        }

        ApplicationQuestion appQuestion = new ApplicationQuestion(student, app, 'Test Label', app, 'Contact__c', 'Test Placeholder');

        Program__c program = new Program__c(
            Name = 'Test Program',
            Hide_Citizenship__c = 'International',
            Hide_Applicant_Type__c = 'First-Year',
            Hide_Student_Type__c = 'Software',
            Delivery_Type__c = 'Online',
            Degree_Type__c = 'Non-Degree',
            Residency__c = 'Resident'
        );
        Program__c program2 = new Program__c(
            Name = 'Test Program 2'
        );
        insert new List<Program__c>{program, program2};

        PageReference pageRef = Page.ApplicationPortal;
        pageRef.getParameters().put('test', '123');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ApplicationQuestionGroup appQuestionGroup = new ApplicationQuestionGroup(new List<ApplicationQuestion>{appQuestion});

        ApplicationQuestionSection appQuestionSection = new ApplicationQuestionSection(new List<ApplicationQuestionGroup>{appQuestionGroup});
        appQuestion.section = appQuestionSection;
        appQuestion.addIntendedProgramFilteringList(new List<Program__c>{program, program2});
        
        appQuestion.acc = acc;

        Map<String, String> submap = new Map<String, String>();
        Map<String, Map<String, String>> depOptions = new Map<String, Map<String, String>>();
        submap.put('test dep key', 'test dep value');
        depOptions.put('test dep key', submap);
        appQuestion.addQuestionObject(question);
        appQuestion.addDependentOptions(depOptions);

        List<SelectOption> selectOptions = appQuestion.options;

        Boolean showProgram = appQuestion.showIntendedProgram(program);

        appQuestion.showRelatedLabel(true);

        Map<String, String> options = new Map<String, String>();
        options.put('test key', 'test value');
        appQuestion.setPicklistOptions(options);

        Map<Id, String> referenceOptions = new Map<Id, String>();
        options.put(acc.Id, 'test ref value');
        appQuestion.setReferenceOptions(referenceOptions);

        appQuestion.makeRadio();

        appQuestion.writeResponse('test response');

        Datetime currentDateTime = System.now();
        appQuestion.setDatetimeValue(currentDateTime);
        Datetime dt = appQuestion.getDatetimeValue();

        Date currentDate = System.today();
        appQuestion.setDateValue(currentDate);
        Date d = appQuestion.getDateValue();

        List<String> values = new List<String>();
        values.add('test value');
        appQuestion.setMultiPicklistValues(values);
        List<String> picklists = appQuestion.getMultiPicklistValues();

        appQuestion.setTextEncryptedValue('test encrypt');
        String decrypt = appQuestion.getTextEncryptedValue();

        appQuestion.addControllingQuestion(new ApplicationQuestion(student, app, 'Test Label', app, 'Contact__c', 'Test Placeholder'), new Set<String>{'test value'});
        
        Map<ApplicationQuestion, Set<String>> controllingQuestions = new Map<ApplicationQuestion, Set<String>>();
        controllingQuestions.put(new ApplicationQuestion(student, app, 'Test Label', app, 'Contact__c', 'Test Placeholder'), new Set<String>{'test value'});
        appQuestion.addControllingQuestions(controllingQuestions);

        Boolean multiControlQuestion = appQuestion.checkMultiControllingQuestion();
        
        appQuestion.question = question;

        Boolean enabled = ApplicationQuestion.getStateAndCountryPicklistEnabled();
        Test.stopTest();

        SelectOption selectOption1 = new SelectOption('', '--None--');
        SelectOption selectOption2 = new SelectOption(program2.Id, 'Test Program 2');
        List<SelectOption> expectedSelectOptions = new List<SelectOption>{selectOption1, selectOption2};

        SelectOption selectOption3 = new SelectOption('test dep key', 'test dep value');
        List<SelectOption> depSelectOptions = new List<SelectOption>{selectOption1, selectOption3};
        Map<String, List<SelectOption>> expectedDependentOptions = new Map<String, List<SelectOption>>();
        expectedDependentOptions.put('test dep key', depSelectOptions);

        Question_Response__c expectedResponse = new Question_Response__c(
            PopulatedOn__c = currentDateTime,
            IsPopulated__c = true,
            ValueDateTime__c = currentDateTime,
            ValueDate__c = currentDate,
            ValueText__c = 'test value',
            ValueTextEncrypted__c = 'XXXXXXXXXXXX'
        );

        System.assertEquals(expectedSelectOptions, selectOptions);
        System.assertEquals(false, showProgram);
        System.assertEquals(true, appQuestion.showRelatedLabel);
        System.assertEquals(expectedSelectOptions, appQuestion.options);
        System.assertEquals(expectedDependentOptions, appQuestion.dependentOptions);
        System.assertEquals(true, appQuestion.radio);
        System.assertEquals(String.valueOf(expectedResponse), String.valueOf(appQuestion.response));
        System.assertEquals(currentDateTime, dt);
        System.assertEquals(currentDate, d);
        System.assertEquals(new List<String>{'test value'}, picklists);
        System.assertEquals('test encrypt', decrypt);
        System.assertEquals('ValueText__c', appQuestion.defaultFieldName);
        System.assertEquals('validateName', appQuestion.additionalValidation);
        System.assertEquals(null, appQuestion.responseId);
        System.assertEquals(false, multiControlQuestion);
        System.assertEquals(app.Id, appQuestion.controllingQuestion.application.Id);
        System.assertEquals(new Set<String>{'test value'}, appQuestion.showValues);
        System.assertEquals(1, appQuestion.multiControllingQuestions.size());
        System.assertEquals(true, enabled);
    }
}