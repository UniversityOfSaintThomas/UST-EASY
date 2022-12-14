/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 12/13/2022.
 */


@IsTest
private class CounselorInfoWidgetComponentCtrl_TEST {

    @TestSetup
    public static void setupData() {
        ApplicationRequirement_TEST.setupData();
    }

    @IsTest
    static void testBehavior() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req' LIMIT 1];
        Requirement__c req2 = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req 2' LIMIT 1];

        // This code runs as the system user
        User u = createTestUser('Unit', 'Tester');
        insert u;

        List<User> newUser = [SELECT Id, Name, College__c FROM User WHERE FirstName = 'Unit' AND LastName = 'Tester' AND College__c = 'University of Testerville'];
        System.debug(JSON.serializePretty(newUser));

        app.OwnerId = newUser[0].Id;
        update app;

        PageReference pr = new PageReference('/apex/ApplicationPortal');
        //pr.getParameters().put('contactId', student.Id);
        pr.getParameters().put('applicationId', app.Id);
        pr.getParameters().put('at', 'st');

        Test.setCurrentPage(pr);

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appControlId = appControl.Id;
        appInfo.contactId = student.Id;
        appInfo.appId = app.Id;
        appInfo.citizenship = 'U.S. Citizen';


        Test.startTest();
        CounselorInfoWidgetComponentController controller = new CounselorInfoWidgetComponentController();
        controller.appInfoParam = appInfo;
        CounselorInfoWidgetComponentController.counselorWrap cWrap = controller.getAdmissionsCounselor();
        System.assertEquals(cWrap.USTLove, 'I like all for the common good.');
        System.assertEquals(cWrap.about, 'I like to unit test apps. Weird eh?');
        System.assertEquals(cWRap.smallPhoto,'');
        System.assertEquals(cWrap.largePhoto, 'https://www.stthomas.edu/_media-library/_locate-counselor/unit_tester.jpg');
        Test.stopTest();

        System.debug(JSON.serializePretty(cWrap));
    }

    public static User createTestUser(String fName, String lName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(
                firstname = fName,
                lastName = lName,
                email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.id,
                Phone = '555-555-5555',
                Title = 'Admissions Counselor',
                College__c = 'University of Testerville',
                Major__c = 'Master of Testing',
                Hometown__c = 'Testville, MA',
                About_Me__c = 'I like to unit test apps. Weird eh?',
                What_I_Love_About_St_Thomas__c = 'I like all for the common good.',
                Words_of_Advice__c = 'A poor carpenter blames their tools.',
                Admissions_Counselor__c = true
        );
        return tuser;
    }
}