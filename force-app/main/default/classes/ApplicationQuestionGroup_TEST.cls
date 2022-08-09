/**
 * @last modified on  : 08-08-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
@IsTest
public class ApplicationQuestionGroup_TEST {
    @TestSetup
    static void setup() {
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

        Contact student = new Contact(
            FirstName = 'TestFirst', 
            LastName = 'Student', 
            Email = 'testfirst@student.com'
        );
        insert student;

        Account acc = new Account(
            Name = 'Test Account', 
            hed__Primary_Contact__c = student.Id
        );
        insert acc;

        ContentVersion cv = new ContentVersion(
            Title = 'Test', 
            PathOnClient = 'Test', 
            VersionData = Blob.valueOf('test')
        );
        insert cv;
        
        cv = [
            SELECT Id,
                ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ];
        insert new ContentDocumentLink(
            LinkedEntityId = student.Id, 
            ContentDocumentId = cv.ContentDocumentId, 
            Visibility = 'AllUsers', 
            ShareType = 'I'
        );

        Id inquiryRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Inquiry_Opportunity').getRecordTypeId();
        Opportunity newOpp = new Opportunity(
            RecordTypeId = inquiryRT, 
            Name = 'Student|Test 2022|Test Program', 
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

        Map<String, Id> rtMapRI = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Requirement_Item__c']) {
            rtMapRI.put(rt.DeveloperName, rt.Id);
        }

        Requirement_Item__c riQG = new Requirement_Item__c(
            Requirement__c = req.Id, 
            Name = 'Test RI', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Related_Object'), 
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(), 
            Internal_Only__c = true,
            Related_List_Object__c = 'Application__c', 
            Related_List_Object_Master__c = 'Application',
            Related_List_Object_Master_Field__c = 'Contact__c'
        );
        Requirement_Item__c riDU = new Requirement_Item__c(
            Requirement__c = req.Id, 
            Name = 'Test RI 2', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Document_Upload'), 
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        Requirement_Item__c riRO = new Requirement_Item__c(
            Requirement__c = req.Id, 
            Name = 'Test RI 3', 
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

        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }

        Question__c q1 = new Question__c(
            Active__c = true, 
            RecordTypeId = rtMap.get('Text'), 
            Name = 'Test', 
            Label__c = 'Test', 
            Requirement_Item__c = riQG.Id, 
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID(), 
            Additional_Field_Validation__c = 'validateName',
            Lookup_Object__c = 'Account',
            Related_Object_Field__c = '',
            New_Reference_Field__c = false,
            Hardcoded_Value__c = 'test value',
            Required__c = 'Started App;Pending',
            Contact_Field__c = 'test'
        );
        Question__c q2 = new Question__c(
            Active__c = true, 
            RecordTypeId = rtMap.get('Text'), 
            Name = 'Test2', 
            Label__c = 'Test2', 
            Requirement_Item__c = riQG.Id, 
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID(), 
            Additional_Field_Validation__c = 'validateName',
            Lookup_Object__c = 'Account',
            Related_Object_Field__c = 'Id',
            New_Reference_Field__c = false,
            Hardcoded_Value__c = 'test value',
            Required__c = 'Started App;Pending',
            Contact_Field__c = 'test'
        );
        Question__c q3 = new Question__c(
            Active__c = true, 
            RecordTypeId = rtMap.get('Text'), 
            Name = 'Test3', 
            Label__c = 'Test3', 
            Requirement_Item__c = riDU.Id, 
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID(), 
            Additional_Field_Validation__c = 'validateName',
            Lookup_Object__c = 'Account',
            Related_Object_Field__c = 'Id',
            New_Reference_Field__c = false,
            Hardcoded_Value__c = 'test value',
            Required__c = 'Started App;Pending',
            Contact_Field__c = 'test'
        );
        Question__c q4 = new Question__c(
            Active__c = true, 
            RecordTypeId = rtMap.get('Reference'), 
            Name = 'Test4', 
            Label__c = 'Test3', 
            Requirement_Item__c = riDU.Id, 
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID(), 
            Additional_Field_Validation__c = 'validateName', 
            Lookup_Object__c = 'Account', 
            Display_as_Picklist__c = true, 
            URL_Parameter__c = 'test', 
            Lookup_Where_Clause__c = 'Name != \'testing123\'',
            Related_Object_Field__c = 'Id',
            New_Reference_Field__c = false,
            Hardcoded_Value__c = 'test value',
            Required__c = 'Started App;Pending',
            Contact_Field__c = 'test'
        );
        insert new List<Question__c>{
                q1, q2, q3, q4
        };

        Map<String, Id> rtMapQD = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question_Dependency__c']) {
            rtMapQD.put(rt.DeveloperName, rt.Id);
        }

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
            Requirement_Item__c = riQG.Id,
            External_Email__c = 'test@test.com'
        );
        Requirement_Response__c rrDU = new Requirement_Response__c(
            Application__c = app.Id, 
            Requirement_Item__c = riDU.Id, 
            HasDocument__c = true,
            External_Email__c = 'test@test.com'
        );
        Requirement_Response__c rrRO = new Requirement_Response__c(
            Application__c = app.Id, 
            Requirement_Item__c = riRO.Id, 
            Has_Child_Requirement__c = true,
            External_Email__c = 'test@test.com'
        );
        insert new List<Requirement_Response__c>{
                rrQG, rrDU, rrRO
        };

        Question_Response__c qr1 = new Question_Response__c(
            Requirement_Response__c = rrQG.Id,
            Question__c = q1.Id
        );
        Question_Response__c qr2 = new Question_Response__c(
            Requirement_Response__c = rrDU.Id,
            Question__c = q3.Id
        );
        Question_Response__c qr3 = new Question_Response__c(
            Requirement_Response__c = rrRO.Id,
            Question__c = q4.Id
        );

        insert new List<Question_Response__c>{
            qr1, qr2, qr3
        };
    }

    @IsTest
    public static void testVarious() {
        Contact student = [SELECT Id, Department, Name, (SELECT Id FROM ContentDocumentLinks) FROM Contact LIMIT 1];
        Application__c app = [SELECT Id, Name, Contact__c, Application_Status__c, (SELECT Id FROM ContentDocumentLinks) FROM Application__c LIMIT 1];
        Requirement_Item__c reqItem = [
            SELECT Id, 
                RecordType.DeveloperName, 
                Internal_Only__c, 
                Instructions__c,
                Related_List_Object_Master__c,
                Related_List_Object__c,
                Related_List_Object_Master_Field__c,
                Related_List_Where_Clause__c,
                Required_Number_of_Children__c,
                Editable_Application_Status__c,
                (SELECT Id, 
                    RecordType.DeveloperName, 
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
                    Display_as_Picklist__c
                FROM Questions__r) 
            FROM Requirement_Item__c 
            WHERE Name = 'Test RI' LIMIT 1];
        Map<Id, Question__c> questions = new Map<Id, Question__c>([
            SELECT Id, 
                RecordType.DeveloperName, 
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
                Display_as_Picklist__c
            FROM Question__c 
            WHERE Requirement_Item__c =: reqItem.Id
        ]);
        List<Question_Dependency__c> questionDependencies = [
            SELECT Id, Controlling_Question__c 
            FROM Question_Dependency__c 
            WHERE Controlling_Question__c 
            IN: questions.keySet()
        ];
        Map<Id, List<Question_Dependency__c>> dependentQuestions = new Map<Id, List<Question_Dependency__c>>();
        for (Question_Dependency__c qd : questionDependencies) {
            if (dependentQuestions.get(qd.Controlling_Question__c) != null) {
                dependentQuestions.get(qd.Controlling_Question__c).add(qd);
            } else {
                List<Question_Dependency__c> qdList = new List<Question_Dependency__c>();
                qdList.add(qd);
                dependentQuestions.put(qd.Controlling_Question__c, qdList);
            }
        }
        Requirement_Response__c reqResponse = [
            SELECT Id, 
                External_Email__c, 
                Has_Child_Requirement__c,
                Application__c,
                Send_Reminder__c
            FROM Requirement_Response__c 
            WHERE Requirement_Item__c =: reqItem.Id
        ];
        List<Question_Response__c> questionResponses = [SELECT Id FROM Question_Response__c WHERE Requirement_Response__c =: reqResponse.Id];
        Schema.DescribeFieldResult describeField = Question__c.Additional_Field_Validation__c.getDescribe();
        Schema.sObjectField field = describeField.getSObjectField();
        Map<String, Schema.sObjectField> sobjectFieldMap = new Map<String, Schema.sObjectField>();
        sobjectFieldMap.put('Additional_Field_Validation__c', field);
        
        Test.startTest();
        ApplicationQuestionGroup appQuestionGroup = new ApplicationQuestionGroup(
            student, app, reqItem, dependentQuestions, reqResponse, questionResponses, sobjectFieldMap
        );

        ApplicationQuestionGroup.MultiPicklistWrapper multiPicklistWrapper = new ApplicationQuestionGroup.MultiPicklistWrapper(app, 'Contact__c');
        SObject obj = multiPicklistWrapper.obj;
        String fieldName = multiPicklistWrapper.fieldName;
        List<String> values = new List<String>{String.valueOf(student.Id)};
        multiPicklistWrapper.setMultiPicklistValues(values);
        List<String> multiPicklistValues = multiPicklistWrapper.getMultiPicklistValues();

        appQuestionGroup.questions[0].dependencyCalculated = true;
        appQuestionGroup.questions[0].showQuestion = true;

        appQuestionGroup.selectedRelatedId = student.Id;
        ApplicationQuestionGroup.SObjectWrapper sobjectWrapper1 = new ApplicationQuestionGroup.SObjectWrapper(appQuestionGroup, 'idx test', student);
        ApplicationQuestionGroup.SObjectWrapper sobjectWrapper2 = new ApplicationQuestionGroup.SObjectWrapper(appQuestionGroup, 'idx test', student, false);
        sobjectWrapper1.enableEditMode();
        sobjectWrapper1.enableViewMode();
        sobjectWrapper1.enableConfirmMode();
        SObject obj2 = sobjectWrapper1.obj;
        Boolean isEditMode = sobjectWrapper1.isEditMode;
        Boolean isDeleted = sobjectWrapper1.isDeleted;
        String idx = sobjectWrapper1.idx;
        ContentDocumentLink att = sobjectWrapper1.att;
        Map<ApplicationQuestion, Boolean> showQuestions = sobjectWrapper1.showQuestions;
        Map<String, ApplicationQuestionGroup.MultiPicklistWrapper> multiPicklistValues2 = sobjectWrapper1.multiPicklistValues;

        appQuestionGroup.addNewReferenceObject();
        appQuestionGroup.createNewReferenceObject();
        appQuestionGroup.sendReminder();
        appQuestionGroup.processValues();

        List<ApplicationQuestionGroup.SObjectWrapper> relatedObjects = appQuestionGroup.relatedObjects;
        String newReferenceObjectType = appQuestionGroup.newReferenceObjectType;
        SObject newReferenceObject = appQuestionGroup.newReferenceObject;
        appQuestionGroup.newReferenceObjectSelectedWrapper = String.valueOf(student.Id);
        appQuestionGroup.newReferenceObjectSelectedWrapperName = String.valueOf(student.Id);
        Boolean isInternal = appQuestionGroup.isInternal;
        String instructions = appQuestionGroup.instructions;
        Map<String, Map<String, Object>> fieldResultMap = appQuestionGroup.fieldResultMap;

        appQuestionGroup.setCreatingNewRelatedRecord();
        Boolean creatingNewRelatedRecord = appQuestionGroup.creatingNewRelatedRecord;
        appQuestionGroup.enableEditMode();
        String selectedRelatedId = appQuestionGroup.selectedRelatedId;
        appQuestionGroup.enableViewMode();
        appQuestionGroup.enableConfirmMode();
        appQuestionGroup.enableDeleteMode();
        appQuestionGroup.relatedUpload();

        appQuestionGroup.newRow();
        appQuestionGroup.sendReminder();

        Test.stopTest();

        Account expectedReferenceObject = [SELECT Id, Name FROM Account WHERE Name != 'Test Account' LIMIT 1];
        Map<String, Map<String, Object>> expectedFieldResultMap = new Map<String, Map<String, Object>>();
        expectedFieldResultMap.put('Additional_Field_Validation__c', new Map<String, Object>());
        expectedFieldResultMap.get('Additional_Field_Validation__c').put('isReference', false);
        Application__c expectedObj = [SELECT Id, Name, Contact__c, Application_Status__c FROM Application__c LIMIT 1];
        Contact expectedObj2 = [SELECT Id, Name FROM Contact LIMIT 1];
        ContentDocumentLink expectedAtt = [SELECT LinkedEntityId, Id FROM ContentDocumentLink WHERE LinkedEntityId =: student.Id LIMIT 1];

        System.assertEquals(new List<ApplicationQuestionGroup.SObjectWrapper>(), relatedObjects);
        System.assertEquals(expectedObj, obj);
        System.assertEquals('Contact__c', fieldName);
        System.assertEquals(new List<String>{student.Id}, multiPicklistValues);
        System.assertEquals(String.valueOf(expectedObj2), String.valueOf(obj2));
        System.assertEquals(false, isEditMode);
        System.assertEquals(false, isDeleted);
        System.assertEquals('idx test', idx);
        System.assertEquals(expectedAtt, att);
        System.assertEquals(2, showQuestions.size());
        System.assertEquals(new Map<String, ApplicationQuestionGroup.MultiPicklistWrapper>(), multiPicklistValues2);
        System.assertEquals(new List<ApplicationQuestionGroup.SObjectWrapper>(), relatedObjects);
        System.assertEquals('Account', newReferenceObjectType);
        System.assertEquals(expectedReferenceObject, newReferenceObject);
        System.assertEquals(false, isInternal);
        System.assertEquals(null, instructions);
        System.assertEquals(expectedFieldResultMap, fieldResultMap);
        System.assertEquals(true, creatingNewRelatedRecord);
        System.assertEquals(student.Id, selectedRelatedId);
    }

    @IsTest
    public static void testAddress() {
        Contact student = [SELECT Id, Department, Name, (SELECT Id FROM ContentDocumentLinks) FROM Contact LIMIT 1];
        Application__c app = [SELECT Id, Name, Contact__c, Application_Status__c FROM Application__c LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c LIMIT 1];

        Map<String, Id> rtMapRI = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Requirement_Item__c']) {
            rtMapRI.put(rt.DeveloperName, rt.Id);
        }
        Requirement_Item__c reqItem = new Requirement_Item__c(
            Requirement__c = req.Id, 
            Name = 'Address Test', 
            Active__c = true, 
            RecordTypeId = rtMapRI.get('Related_Object'),
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(), 
            Internal_Only__c = true,
            Related_List_Object__c = 'Family__c',
            Related_List_Object_Master_Field__c = 'Applicant__c'
        );
        insert reqItem;

        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }
        Question__c q1 = new Question__c(
            Active__c = true, 
            RecordTypeId = rtMap.get('Address'), 
            Name = 'Test Address', 
            Label__c = 'Test', 
            Requirement_Item__c = reqItem.Id, 
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID(), 
            Additional_Field_Validation__c = 'validateName',
            Lookup_Object__c = 'Family__c',
            Related_Object_Field__c = 'Applicant__c',
            New_Reference_Field__c = false,
            Hardcoded_Value__c = 'test value',
            Required__c = 'Started App;Pending',
            Contact_Field__c = 'test'
        );

        Question__c q2 = new Question__c(
            Active__c = true,
            RecordTypeId = rtMap.get('MultiPicklist'),
            Name = 'Test MultiPicklist',
            Label__c = 'Test MultiPicklist',
            Requirement_Item__c = reqItem.Id,
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID(),
            Additional_Field_Validation__c = 'validateName',
            Related_Object_Field__c = 'Applicant__c'
        );
        insert new List<Question__c>{ q1, q2 };

        Map<String, Id> rtMapQD = new Map<String, Id>();
        for (RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Question_Dependency__c']) {
            rtMapQD.put(rt.DeveloperName, rt.Id);
        }
        Question_Dependency__c qd = new Question_Dependency__c(
            Question__c = q1.Id, 
            Controlling_Question__c = q1.Id, 
            Value__c = 'Test Address', 
            Question_Dependency_Integration_Ext_Id__c = ApplicationUtilities.getUUID()
        );
        insert qd;

        Requirement_Response__c rr = new Requirement_Response__c(
            Application__c = app.Id, 
            Requirement_Item__c = reqItem.Id,
            External_Email__c = 'testaddress@test.com'
        );
        insert rr;

        Question_Response__c qr = new Question_Response__c(
            Requirement_Response__c = rr.Id,
            Question__c = q1.Id
        );
        insert qr;

        reqItem = [
            SELECT Id,                 
                RecordType.DeveloperName, 
                Internal_Only__c, 
                Instructions__c,
                Related_List_Object_Master__c,
                Related_List_Object__c,
                Related_List_Object_Master_Field__c,
                Related_List_Where_Clause__c,
                Required_Number_of_Children__c,
                Editable_Application_Status__c,
                    (SELECT Id, 
                        RecordType.DeveloperName, 
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
                        Picklist_Values__c
                    FROM Questions__r) 
            FROM Requirement_Item__c 
            WHERE Name = 'Address Test' 
            LIMIT 1
        ];

        Family__c family = new Family__c(Application__c = app.Id, Applicant__c = student.Id);
        insert family;

        q1 = [SELECT Id FROM Question__c WHERE Name = 'Test Address' LIMIT 1];
        qd = [SELECT Id FROM Question_Dependency__c WHERE Value__c = 'Test Address' LIMIT 1];
        rr = [SELECT Id FROM Requirement_Response__c WHERE External_Email__c = 'testaddress@test.com' LIMIT 1];
        qr = [SELECT Id FROM Question_Response__c WHERE Question__c =: q1.Id LIMIT 1];

        Map<Id, List<Question_Dependency__c>> dependentQuestions = new Map<Id, List<Question_Dependency__c>>();
        List<Question_Dependency__c> qdList = new List<Question_Dependency__c>{qd};
        dependentQuestions.put(q1.Id, qdList);
        List<Question_Response__c> qrList = new List<Question_Response__c>{qr};
        Schema.DescribeFieldResult describeField = Question__c.Additional_Field_Validation__c.getDescribe();
        Schema.sObjectField field = describeField.getSObjectField();
        Map<String, Schema.sObjectField> sobjectFieldMap = new Map<String, Schema.sObjectField>();
        sobjectFieldMap.put('Additional_Field_Validation__c', field);

        Test.startTest();
        ApplicationQuestionGroup appQuestionGroup = new ApplicationQuestionGroup(
            student, app, reqItem, dependentQuestions, rr, qrList, sobjectFieldMap, true
        );
        ApplicationQuestionGroup.SObjectWrapper objectWrapper = new ApplicationQuestionGroup.SObjectWrapper(appQuestionGroup, 'idx test', family);
        Map<String, ApplicationQuestionGroup.MultiPicklistWrapper> multiPicklistWrapper = objectWrapper.multiPicklistValues;
        objectWrapper.enableViewMode();
        objectWrapper.enableConfirmMode();
        Map<String, ApplicationQuestionGroup.SObjectWrapper> relatedObjectsMap = new Map<String, ApplicationQuestionGroup.SObjectWrapper>();
        relatedObjectsMap.put(String.valueOf(family.Id), objectWrapper);
        appQuestionGroup.relatedObjectsMap = relatedObjectsMap;
        appQuestionGroup.selectedRelatedId = String.valueOf(family.Id);
        appQuestionGroup.enableDeleteMode();

        ApplicationQuestionGroup.SObjectWrapper objectWrapper2 = new ApplicationQuestionGroup.SObjectWrapper(appQuestionGroup, 'idx test', new Family__c(Application__c = app.Id, Applicant__c = student.Id));
        Map<String, ApplicationQuestionGroup.SObjectWrapper> relatedObjectsMap2 = new Map<String, ApplicationQuestionGroup.SObjectWrapper>();
        appQuestionGroup.selectedRelatedId = String.valueOf(family.Id);
        relatedObjectsMap2.put(appQuestionGroup.selectedRelatedId, objectWrapper2);
        appQuestionGroup.relatedObjectsMap = relatedObjectsMap2;
        appQuestionGroup.relatedUpload();
        Test.stopTest();
        System.assertEquals(false, objectWrapper.isEditMode);
    }
}
