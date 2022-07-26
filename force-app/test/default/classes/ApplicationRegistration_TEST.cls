@IsTest
private class ApplicationRegistration_TEST {

    @TestSetup
    static void dataSetup() {
        Contact student = new Contact(FirstName = 'Test', LastName = 'Student', Email = 'test@student.com');
        insert student;
        //Turn of hed__ TDTM triggers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        for (hed.TDTM_Global_API.TdtmToken TDTMToken : tokens) {
            // disable all EDA-provided trigger handlers
            if (TDTMToken.ownedByNamespace == 'hed') {
                TDTMToken.active = false;
            }
        }
        hed.TDTM_Global_API.setTdtmConfig(tokens);

        Application_Control__c appControl = ApplicationTESTUtilities.createApplicationControl();

        Application_Setting__c appSetting = new Application_Setting__c(
            Community_Profile_Ids__c = 'Test',
            Community_URL__c = 'Test',
            Cookie_Encryption_Key__c = 'Test',
            Default_Template__c = 'Test',
            Permission_Set_Id__c = 'Test'
        );
        insert appSetting;

        Academic_Term__c at = new Academic_Term__c(
            Name = 'test', 
            Activate_Application_Date__c = Date.today().addDays(-2), 
            End_Application_Date__c = Date.today().addDays(2), 
            Academic_Term_Integration_External_ID__c = ApplicationUtilities.getUUID()
        );
        insert at;

        //Thad - added hide from application, ext id, active true, and app control id
        insert new Program__c(
            Name = 'test', 
            Program_Integration_External_Id__c = ApplicationUtilities.getUUID(), 
            Hide_from_Application__c = false, 
            Active__c = true, 
            Application_Control__c = appControl.Id
        );

        Interaction_Mapping__c im1 = new Interaction_Mapping__c(
            Target_Object_API_Name__c = 'Contact', 
            Target_Field_API_Name__c = 'FirstName', 
            Source_Object_API_Name__c = 'Interaction__c', 
            Source_Field_API_Name__c = 'First_Name__c', 
            Interaction_Source_Field_API_Name__c = 'First_Name__c', 
            Active__c = true
        );
        Interaction_Mapping__c im2 = new Interaction_Mapping__c(
            Target_Object_API_Name__c = 'Contact', 
            Target_Field_API_Name__c = 'LastName', 
            Source_Object_API_Name__c = 'Interaction__c', 
            Source_Field_API_Name__c = 'Last_Name__c', 
            Interaction_Source_Field_API_Name__c = 'Last_Name__c', 
            Active__c = true
        );
        Interaction_Mapping__c im3 = new Interaction_Mapping__c(
            Target_Object_API_Name__c = 'Contact', 
            Target_Field_API_Name__c = 'Email', 
            Source_Object_API_Name__c = 'Interaction__c', 
            Source_Field_API_Name__c = 'Email__c', 
            Interaction_Source_Field_API_Name__c = 'Email__c', 
            Active__c = true
        );
        insert new List<Interaction_Mapping__c>{
                im1, im2, im3
        };
    }

    @IsTest
    static void test_registration() {
        Id programId = [SELECT Id FROM Program__c WHERE Name = 'test'].Id;
        Id termId = [SELECT Id FROM Academic_Term__c WHERE Name = 'test'].Id;

        Application_Control__c appControl = [SELECT Id FROM Application_Control__c WHERE Name = 'test'];
        System.debug('Test Id: ' + appControl.Id);
        appControl.Default__c = false;
        appControl.URL_Parameter__c = appControl.Id;
        update appControl;

        PageReference pr = Page.ApplicationRegistration;
        pr.getParameters().put('at', appControl.Id);

        User testUser = ApplicationTESTUtilities.userToRunWith('Standard User', 'Application_Community_Guest');

        Test.startTest();

        ApplicationRegistration.lookupSearch('Program__c', 'Name != \'not_test\'', 'Name', 'test');

        Test.setCurrentPage(pr);
        ApplicationRegistration ar = new ApplicationRegistration();
        ar.interaction = new Interaction__c();
        ar.applicationRegistrationInit();
        PageReference returnPage1 = ar.submit();

        for (ApplicationQuestionGroup g : ar.appCreate.section.groups) {
            for (ApplicationQuestion q : g.questions) {
                if (q.fieldName != null && q.fieldName.equals('Intended_Program__c')) {
                    q.response.ValueText__c = programId;
                } else if (q.fieldName != null && q.fieldName.equals('Intended_Term_of_Entry__c')) {
                    q.response.ValueText__c = termId;
                } else if (q.fieldName != null && q.fieldName.equals('First_Name__c') && q.label.equals('First Name')) {
                    q.response.ValueText__c = 'test';
                } else if (q.fieldName != null && q.fieldName.equals('Last_Name__c') && q.label.equals('Last Name')) {
                    q.response.ValueText__c = 'test';
                } else if (q.fieldName != null && q.fieldName.equals('Email__c')) {
                    q.response.ValueText__c = 'ApplicationRegistrationTest@test.com';
                } else if (q.fieldName != null && q.fieldName.equals('First_Name__c')) {
                    q.response.ValueText__c = 'testpass1';
                } else if (q.fieldName != null && q.fieldName.equals('Last_Name__c')) {
                    q.response.ValueText__c = 'testpass1';
                }
            }
        }


        PageReference returnPage2 = ar.submit();

        //Contact con = [SELECT Id FROM Contact WHERE Email = :'ApplicationRegistrationTest@test.com'];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        con.Email = null;
        update con;

        PageReference returnPage3 = ar.submit();

        con.Email = UserInfo.getUserName();
        update con;

        PageReference returnPage4 = ar.submit();

        ar = new ApplicationRegistration();

        for (ApplicationQuestionGroup g : ar.appCreate.section.groups) {
            for (ApplicationQuestion q : g.questions) {
                if (q.fieldName != null && q.fieldName.equals('Intended_Program__c')) {
                    q.response.ValueText__c = programId;
                } else if (q.fieldName != null && q.fieldName.equals('Intended_Term_of_Entry__c')) {
                    q.response.ValueText__c = termId;
                } else if (q.fieldName != null && q.fieldName.equals('First_Name__c') && q.label.equals('First Name')) {
                    q.response.ValueText__c = 'test2';
                } else if (q.fieldName != null && q.fieldName.equals('Last_Name__c') && q.label.equals('Last Name')) {
                    q.response.ValueText__c = 'test2';
                } else if (q.fieldName != null && q.fieldName.equals('Email__c')) {
                    q.response.ValueText__c = 'ApplicationRegistrationTest2@test.com';
                } else if (q.fieldName != null && q.fieldName.equals('First_Name__c')) {
                    q.response.ValueText__c = 'testpass1';
                } else if (q.fieldName != null && q.fieldName.equals('Last_Name__c')) {
                    q.response.ValueText__c = 'testpass1';
                }
            }
        }

        PageReference returnPage5 = ar.submit();
        PageReference returnPage6 = ar.login();

        Test.stopTest();
        System.assertEquals(null, returnPage1);
        System.assertEquals(null, returnPage2);
        System.assertEquals(null, returnPage3);
        System.assertEquals(null, returnPage4);
        System.assertEquals(null, returnPage5);
        System.assertEquals(null, returnPage6);

    }

    @IsTest
    public static void testLookupSearch() {
        Test.startTest();
        insert new Account(Name = 'Example Account');
        Test.stopTest();
        List<SObject> results = ApplicationRegistration.lookupSearch('Account', null, 'Name', 'Example');
        System.assertEquals(1, results.size());
    }

    @isTest
    public static void testCookieKey() {
        ApplicationRegistration appReg = new ApplicationRegistration();
        PageReference pageRef = Page.ApplicationRegistration;
        pageRef.getParameters().put('at', 'test');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        PageReference returnPage = appReg.testCookieKey();
        Test.stopTest();
        System.assertEquals(String.valueOf(pageRef), String.valueOf(returnPage));
    }
}