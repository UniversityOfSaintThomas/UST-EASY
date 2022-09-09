@IsTest
public class ScholarshipController_TEST {
/*    @TestSetup static void insertCertainBaselineDataForTestsIfNotPresent() { Util.insertCertainBaselineDataForTestsIfNotPresent(); }
	private static Profile testProfile ;
    private static Contact student;
    private static User testUser;
    private static  Scholarship__c ScholarshipInfo {get; set;}
    private static Scholarship__c ScholarshipInfoExpired {get;set;}
    private static  Scholarship_Applicant__c ScholarshipApplicant {get; set;}
    private static Attachment Essay1 { get; set; }
    private static Attachment Essay2 { get; set; }*/

    @IsTest static void testScholarshipHomeNullScholarship() {
        //dataPrepare();
        Contact student = makeTestContact('_home');
        System.runAs(getScholarshipTestUser(student)) {
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('/Admissions/ScholarshipHome'));
            ScholarshipHomeController homeCon = new ScholarshipHomeController();

            //Get all scholarships no input needed
            homeCon.getAvailableScholarships();

            //Try to get scholarship with no info
            homeCon.chooseScholarship();

            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('sid', '');
            Test.stopTest();
        }
    }

    @IsTest static void testScholarshipHomeLiveScholarship() {
        String identifier = '_homeLive';
        Scholarship__c scholarship = makeTestScholarship(identifier);
        Contact student = makeTestContact('_home');
        System.runAs(getScholarshipTestUser(student)) {
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('/Admissions/ScholarshipHome'));
            ScholarshipHomeController homeCon = new ScholarshipHomeController();
            homeCon.getAvailableScholarships();

            homeCon.scholarshipId = scholarship.Scholarship_ID__c;
            PageReference p1 = homeCon.chooseScholarship();
            Test.setCurrentPage(p1);
            ScholarshipApplicationPage1Controller p1con = new ScholarshipApplicationPage1Controller();
            p1con.sanityCheck();
            Test.stopTest();
        }
    }

    @IsTest static void testExpiredScholarship() {
        String identifier = '_expiredTest';
        Contact student = makeTestContact(identifier);
        Scholarship__c expiredScholarship = makeTestExpiredScholarship(identifier);
        Scholarship_Applicant__c scholarshipApplicant = makeTestScholarshipApplicant(student, expiredScholarship);
        System.runAs(getScholarshipTestUser(student)) {
            Test.startTest();
            PageReference p1 = ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage1, false, expiredScholarship.Scholarship_ID__c);
            Test.setCurrentPage(p1);
            ScholarshipApplicationPage1Controller p1con = new ScholarshipApplicationPage1Controller();

            // Should go to ScholarshipClosed page for this scholarship.
            PageReference nextPage = p1con.sanityCheck();
            PageReference shouldBeNextPage = ScholarshipSharedUtilities.setSid(Page.ScholarshipClosed, false, expiredScholarship.Scholarship_ID__c);
            System.assertEquals(nextPage.getUrl(), shouldBeNextPage.getUrl());
            Test.setCurrentPage(nextPage);
            ScholarshipClosedController pClosedCon = new ScholarshipClosedController();
            pClosedCon.initialize();

            Test.stopTest();
        }
    }

    @IsTest static void testScholarship() {
        String identifier = '_page1and2Test';
        Contact student = makeTestContact(identifier);
        Scholarship__c scholarship = makeTestScholarship(identifier);
        Scholarship_Applicant__c scholarshipApplicant = makeTestScholarshipApplicant(student, scholarship);

        System.runAs(getScholarshipTestUser(student)) {
            Test.startTest();
            PageReference p1 = ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage1, false, scholarship.Scholarship_ID__c);
            Test.setCurrentPage(p1);
            ScholarshipApplicationPage1Controller p1con = new ScholarshipApplicationPage1Controller();
            p1con.sanityCheck();
            PageReference p2 = p1con.SaveCriteria();
            Test.setCurrentPage(p2);
            ScholarshipApplicationPage2Controller p2con = new ScholarshipApplicationPage2Controller();
            p2con.initialize();

            // Essay upload.
            Blob b = Blob.valueOf('Test Data');
            p2con.essay1Filename = 'Essay1.doc.test';
            Attachment essay1 = new Attachment();
            essay1.ParentId = ScholarshipApplicant.Id;
            essay1.Name = 'Test Essay 1 for Parent';
            essay1.Body = b;
            p2con.essay1 = essay1;
            p2con.UploadEssay1();

            Attachment essay2 = new Attachment();
            essay2.ParentId = scholarshipApplicant.Id;
            essay2.Name = 'Test Essay 1 for Parent';
            essay2.Body = b;
            p2con.essay1 = essay2;
            p2con.UploadEssay2();

            // Other page 2 functions.
            p2con.DeleteEssay1();
            p2con.DeleteEssay2();
            p2con.SendRecommenderEmail();

            // Try navigating between the pages.
            p1 = p2con.GoCriteria();
            Test.setCurrentPage(p1);
            p1con = new ScholarshipApplicationPage1Controller();
            p1con.sanityCheck();
            p2 = p1con.SaveCriteria();
            Test.setCurrentPage(p2);
            p2con = new ScholarshipApplicationPage2Controller();
            p2con.initialize();

            // ScholarshipComplete page.
            p2con.SaveFinishLater();
            PageReference pComplete = p2con.SaveComplete();
            Test.setCurrentPage(pComplete);
            ScholarshipApplicationCompleteController pCompleteCon = new ScholarshipApplicationCompleteController();
            pCompleteCon.initialize();

            Test.stopTest();
        }
    }

    @IsTest static void scholarshipRecommendersTest() {
        String identifier = '_recTest';
        Contact recommender = makeTestContact(identifier);
        Scholarship_Applicant__c scholarshipApplicant = makeTestScholarshipApplicant(makeTestContact(identifier), makeTestScholarship(identifier));
        System.runAs(getScholarshipTestUser(recommender, true)) {
            Test.startTest();
            ScholarshipRecommenderController schRecCon = new ScholarshipRecommenderController();
            schRecCon.buildRecommendation();

            //No Rec ID
            System.currentPageReference().getParameters().put('recId', '');
            schRecCon = new ScholarshipRecommenderController();
            schRecCon.Save();

            //Rec ID doesn't exist but is 15 characters
            System.currentPageReference().getParameters().put('recId', 'AAAAAAAAAAAAAAA0');
            schRecCon = new ScholarshipRecommenderController();
            schRecCon.Save();

            //No Scholarship Applicant
            System.currentPageReference().getParameters().put('recId', ScholarshipApplicant.Id + '1');
            schRecCon = new ScholarshipRecommenderController();
            schRecCon.Save();

            //recId less than 15
            System.currentPageReference().getParameters().put('recId', ScholarshipApplicant.Id );
            schRecCon = new ScholarshipRecommenderController();
            schRecCon.Save();

            //Add scholarship applicant
            schRecCon.ScholarshipApplicant = ScholarshipApplicant;
            schRecCon = new ScholarshipRecommenderController();
            schRecCon.Save();

            //recId = 2
            System.currentPageReference().getParameters().put('recId', ScholarshipApplicant.Id + '2');
            schRecCon = new ScholarshipRecommenderController();
            schRecCon.Save();
            //recID > 2
            System.currentPageReference().getParameters().put('recId', ScholarshipApplicant.Id + '3');
            schRecCon = new ScholarshipRecommenderController();
            schRecCon.Save();
            Test.stopTest();
        }
    }

    private static Profile getStudentTestProfile() {
        Profile testProfile = [SELECT id, name FROM profile WHERE name='Customer Community Login User'];
        return testProfile;
    }

    private static Profile getRecommenderTestProfile() {
        Profile[] profiles = [SELECT id, name FROM profile WHERE name='EASY Applicant Portal Site Guest User'];
        if (profiles.size() == 0) {
            profiles = [SELECT id, name FROM profile WHERE name='Admissions Site Guest User']; // Fallback
        }

        Profile testProfile = profiles.get(0);
        return testProfile;
    }

    public static Contact makeTestContact(String uniqueBit) {
        Contact student = new Contact(firstname='test',lastname='Contact'+uniqueBit,MailingStreet='testStreet',MailingCity='testCity',
                MailingState='Rajasthan',MailingPostalCode='123455',MailingCountry='India');
        insert student;
        student = [SELECT Id FROM Contact WHERE ID = :student.Id];
        return student;
    }
    private static User getScholarshipTestUser(Contact contact) {
        return getScholarshipTestUser(contact, false);
    }
    private static User getScholarshipTestUser(Contact contact, boolean isRecommender) {
        User testUser;

        User[] testUsers = [SELECT Id FROM User WHERE Email='u1@testorg.com'];
        if (testUsers.size() > 0) {
            testUser = testUsers.get(0);
        } else {
            Profile testProfile;
            if (isRecommender == true) {
                testProfile = getStudentTestProfile();
            } else {
                testProfile = getRecommenderTestProfile();
            }
            testUser = new User(alias = 'u1', email = 'u1@testorg.com', emailencodingkey = 'UTF-8', lastname = 'Testing',
                    languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = testProfile.Id,
                    timezonesidkey = 'America/Los_Angeles', username = 'u1@testorg.com', contactId = contact.Id);
            insert testUser;
            testUser = [SELECT Id FROM User WHERE Id=:testUser.Id];
        }
        return testUser;
    }

    private static Scholarship__c makeTestScholarship(String uniqueBit) {
        Date yesterday = Date.today().addDays(-1);
        Date tomorrow = Date.today().addDays(1);
        Scholarship__c scholarship = new Scholarship__c(
                Name = 'Test Scholarship' + uniqueBit, Close_Date__c = tomorrow, Open_Date__c = yesterday,
                Recommender__c = true, Recommender_Auto_Send__c = true,Recommender2__c = true, Recommender2_Auto_Send__c = true,
                Completion_Statement__c = 'TEST', Criteria_Statement__c='TEST', Description__c = 'TEST', Essay_1_Text__c = 'TEST',
                Essay_2_Text__c = 'TEST', Question_1_Text__c = 'TEST', Recommender2_Description__c='TEST', Recommender2_Question__c='TEST',
                Recommender_Description__c = 'TEST', Recommender_Question__c= 'TEST', Short_Description__c = 'TEST',
                Review_Award_Process_Description__c = 'TEST', Self_Report_ACT_GPA_Criteria__c = true
        );
        insert scholarship;
        scholarship = [SELECT Id, Scholarship_ID__c, Description__c, Recommender2_Auto_Send__c, Recommender_Question__c, Recommender2_Question__c, Recommender_Auto_Send__c, Essay_1_Text__c,Essay_2_Text__c,  Name, Close_Date__c, Open_Date__c, Recommender2__c, Recommender__c FROM Scholarship__c WHERE Id =:scholarship.Id];
        System.debug('TEST SCHOLARSHIP::' + JSON.serialize(scholarship));
        return scholarship;
    }

    private static Scholarship__c makeTestExpiredScholarship(String uniqueBit) {
        Date yesterday = Date.today().addDays(-1);
        Date twoDaysAgo = Date.today().addDays(-2);
        Scholarship__c scholarshipInfoExpired = new Scholarship__c(
                Name = 'Expired Test Scholarship' + uniqueBit, Close_Date__c = yesterday, Open_Date__c = twoDaysAgo,
                Recommender__c = true, Recommender_Auto_Send__c = true,Recommender2__c = true, Recommender2_Auto_Send__c = true,
                Completion_Statement__c = 'TEST', Criteria_Statement__c='TEST', Description__c = 'TEST', Essay_1_Text__c = 'TEST',
                Essay_2_Text__c = 'TEST', Question_1_Text__c = 'TEST', Recommender2_Description__c='TEST', Recommender2_Question__c='TEST',
                Recommender_Description__c = 'TEST', Recommender_Question__c= 'TEST', Short_Description__c = 'TEST',
                Review_Award_Process_Description__c = 'TEST', Self_Report_ACT_GPA_Criteria__c = true
        );
        insert scholarshipInfoExpired;
        scholarshipInfoExpired = [SELECT Id,Recommender_Auto_Send__c, Description__c, Scholarship_ID__c, Name, Close_Date__c, Open_Date__c,
                Recommender2__c, Recommender__c FROM Scholarship__c WHERE Id =:scholarshipInfoExpired.Id];
        return scholarshipInfoExpired;
    }

    private static Scholarship_Applicant__c makeTestScholarshipApplicant(Contact student, Scholarship__c scholarship) {
        Scholarship_Applicant__c applicant = new Scholarship_Applicant__c(
                Contact__c = student.Id,
                Scholarship__c = scholarship.Id,
                Recommender2_name__c = 'Thad2',
                Recommender_Name__c = 'Thad1',
                Recommender_Email__c = 'sf1@valleyhill.net',
                Recommender2_Email__c = 'sf2@valleyhill.net',
                Essay_1_Uploaded__c = false,
                Essay_2_uploaded__c = false
        );
        insert applicant;
        applicant = [SELECT
                Contact__c, Scholarship__c,
                Recommender_Name__c,
                Recommender2_Name__c,
                Recommender_Email__c,
                Recommender2_Email__c,
                Essay_1_Uploaded__c,
                Essay_1_Uploaded_Orig_Filename__c,
                Essay_2_Uploaded__c,
                Essay_2_Uploaded_Orig_Filename__c,
                Essay_1_Answer__c FROM Scholarship_Applicant__c WHERE Id =:applicant.Id];
        return applicant;
    }

    private static void dataPrepare(){
        //Querying on profile
        String identifier = '_dataPrep';
        Profile testProfile = getStudentTestProfile();
        Contact student = makeTestContact(identifier);
        Scholarship__c scholarship = makeTestScholarship(identifier);
        User testUser = getScholarshipTestUser(student);
        Scholarship__c expiredScholarship = makeTestExpiredScholarship(identifier);
        Scholarship_Applicant__c scholarshipApplicant = makeTestScholarshipApplicant(student, scholarship);

        //Create fake blogs for attachment uploading
        Blob b = Blob.valueOf('Test Data');
        Attachment Essay1 = new Attachment();
        Essay1.ParentId = ScholarshipApplicant.Id;
        Essay1.Name = 'Test Essay 2 for Parent';
        Essay1.Body = b;
        //insert(Essay1);

        Attachment Essay2 = new Attachment();
        Essay2.ParentId = ScholarshipApplicant.Id;
        Essay2.Name = 'Test Essay 2 for Parent';
        Essay2.Body = b;
        //insert(Essay2);
    }
}