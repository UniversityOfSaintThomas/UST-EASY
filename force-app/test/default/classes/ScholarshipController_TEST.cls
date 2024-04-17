/* Credit where due: although my name is on the commit to EASYApp, much of this is taken from the Old Scholarships repo, and was authored by Thad or his predecessors. */
@IsTest
public class ScholarshipController_TEST {

    @TestSetup static void setup() {
        List<Scholarship__c> scholarships = new List<Scholarship__c>();
        // Create two scholarships, one expired and one live.
        for (Integer i = 0; i < 2; i++) {
            //if i = 1 then make the close date expired
            Date openDate = Date.today().addDays(-3);
            Date closeDate = Date.today().addDays(3);
            if (i == 1) {
                openDate = Date.today().addDays(-3);
                closeDate = Date.today().addDays(-2);
            }
            Scholarship__c scholarship = new Scholarship__c(
                    Name = 'Test Scholarship' + i, Close_Date__c = closeDate,
                    Open_Date__c = openDate, Recommender__c = true,
                    Recommender_Auto_Send__c = true, Recommender2__c = true,
                    Recommender2_Auto_Send__c = true, Completion_Statement__c = 'TEST',
                    Criteria_Statement__c = 'TEST', Description__c = 'TEST',
                    Essay_1_Text__c = 'TEST', Essay_2_Text__c = 'TEST',
                    Question_1_Text__c = 'TEST', Recommender2_Description__c = 'TEST',
                    Recommender2_Question__c = 'TEST', Recommender_Description__c = 'TEST',
                    Recommender_Question__c = 'TEST', Short_Description__c = 'TEST',
                    Review_Award_Process_Description__c = 'TEST', Self_Report_ACT_GPA_Criteria__c = true
            );
            scholarships.add(scholarship);
        }
        insert scholarships;

        Account testAccount = new Account(Name = 'Test Account ' + Math.random());
        insert testAccount;

        // Insert a contact with the addon to first and last name of "recommender"
        Contact recommender = new Contact(
                FirstName = 'recommender',
                LastName = 'Contact',
                Email = 'recommender@test.com',
                MailingStreet = 'testStreet',
                MailingCity = 'testCity',
                MailingState = 'Rajasthan',
                MailingPostalCode = '123455',
                MailingCountry = 'India',
                AccountId = testAccount.Id
        );
        System.debug(JSON.serializePretty(recommender));
        insert recommender;

        // Insert a contact with the addon to first and last name of "student"
        Contact student = new Contact(
                FirstName = 'student',
                LastName = 'Contact',
                Email = 'student@test.com',
                MailingStreet = 'testStreet',
                MailingCity = 'testCity',
                MailingState = 'Rajasthan',
                MailingPostalCode = '123455',
                MailingCountry = 'India',
                AccountId = testAccount.Id
        );
        System.debug(JSON.serializePretty(student));
        insert student;

        Scholarship_Applicant__c applicant = new Scholarship_Applicant__c(
                Contact__c = student.Id,
                Scholarship__c = scholarships[0].Id,
                Recommender2_Name__c = 'Recommender',
                Recommender_Name__c = 'Contact',
                Recommender_Email__c = 'sf1@valleyhill.net',
                Recommender2_Email__c = 'sf2@valleyhill.net',
                Essay_1_Uploaded__c = false,
                Essay_2_Uploaded__c = false
        );
        insert applicant;
    }


    @IsTest
    static void testScholarshipHomeNullScholarship() {
        //Contact student = makeTestContact('_home');
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/Admissions/ScholarshipHome'));
        ScholarshipHomeController homeCon = new ScholarshipHomeController();
        homeCon.getAvailableScholarships();
        homeCon.chooseScholarship();  // Try to get scholarship with no info
        ApexPages.currentPage().getParameters().put('sid', ''); // Null SID.
        Test.stopTest();
    }

    @IsTest
    static void testScholarshipHomeLiveScholarship() {
        Scholarship__c scholarship = [SELECT Id, Scholarship_ID__c FROM Scholarship__c WHERE Name = 'Test Scholarship0' LIMIT 1];
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

    @IsTest
    static void testExpiredScholarship() {
        Scholarship__c expiredScholarship = [SELECT Id, Scholarship_ID__c FROM Scholarship__c WHERE Name = 'Test Scholarship1' LIMIT 1];

        Test.startTest();
        PageReference p1 = Page.ScholarshipApplicationPage1;
        System.debug('Schoarship Id: ' + expiredScholarship.Scholarship_ID__c);
        p1.getParameters().put('sid', expiredScholarship.Scholarship_ID__c);
        System.debug('Current Page: ' + p1.getParameters());
        Test.setCurrentPage(p1);
        ScholarshipApplicationPage1Controller p1con = new ScholarshipApplicationPage1Controller();

        // Should go to ScholarshipClosed page for this scholarship.
        PageReference nextPage = p1con.sanityCheck();
        PageReference shouldBeNextPage = ScholarshipSharedUtilities.setSid(Page.ScholarshipClosed, false, expiredScholarship.Scholarship_ID__c);
        System.assertEquals(nextPage.getUrl(), shouldBeNextPage.getUrl());
        Test.setCurrentPage(nextPage);

        Test.stopTest();
    }

/*    @IsTest
    static void testScholarshipSaveCriteriaError() {
        Scholarship__c scholarship = [SELECT Id, Scholarship_ID__c FROM Scholarship__c WHERE Name = 'Test Scholarship0' LIMIT 1];
        Test.startTest();
        PageReference p1 = ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage1, false, scholarship.Scholarship_ID__c);
        Test.setCurrentPage(p1);
        ScholarshipApplicationPage1Controller p1con = new ScholarshipApplicationPage1Controller();
        p1con.SaveCriteria();
        Boolean containsError = false;
        for (ApexPages.Message message : ApexPages.getMessages()) {
            if (message.getSummary().containsIgnoreCase('Logged in scholarship user could be found.')) {
                containsError = true;
            }
            System.debug('Message: ' + message.getSummary());
        }
        System.assert(containsError);
        Test.stopTest();
    }*/

    @IsTest
    static void testScholarship() {
        Contact student = [SELECT Id FROM Contact WHERE FirstName = 'student' LIMIT 1];
        Scholarship__c scholarship = [SELECT Id, Scholarship_ID__c FROM Scholarship__c WHERE Name = 'Test Scholarship0' LIMIT 1];

        System.runAs(userToRunWith(student.Id)) {
            Test.startTest();
            PageReference p1 = ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage1, false, scholarship.Scholarship_ID__c);
            Test.setCurrentPage(p1);
            ScholarshipApplicationPage1Controller p1con = new ScholarshipApplicationPage1Controller();
            PageReference sanityPageReference = p1con.sanityCheck();
            //Scholarship should be on page 1 returns null for sanityPageReference
            System.assert(sanityPageReference == null);

            System.debug('ScholarshipApplicant: ' + JSON.serializePretty(p1con.scholarshipApplicant));
            PageReference p2 = p1con.SaveCriteria();
            Test.setCurrentPage(p2);
            ScholarshipApplicationPage2Controller p2con = new ScholarshipApplicationPage2Controller();
            p2con.initialize();

            // Essay upload.
            Blob b = Blob.valueOf('Test Data');
            p2con.essay1Filename = 'Essay1.doc';
            p2con.essay2Filename = 'Essay2.pdf';
            Attachment essay1 = new Attachment();
            essay1.ParentId = p2con.applicant.Id;
            essay1.Name = 'Test Essay 1 for Parent';
            essay1.Body = b;
            p2con.essay1 = essay1;
            p2con.UploadEssay1();

            Attachment essay2 = new Attachment();
            essay2.ParentId = p2con.applicant.Id;
            essay2.Name = 'Test Essay 1 for Parent';
            essay2.Body = b;
            p2con.essay2 = essay2;
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

            Test.stopTest();
        }
    }

    @IsTest
    static void scholarshipRecommendersTest() {
        //Contact recommender = [SELECT Id FROM Contact WHERE FirstName = 'recommender' LIMIT 1];
        Contact student = [SELECT Id FROM Contact WHERE FirstName = 'student' LIMIT 1];
        Scholarship_Applicant__c scholarshipApplicant = [SELECT Id FROM Scholarship_Applicant__c WHERE Contact__c = :student.Id LIMIT 1];

        Test.startTest();

        ScholarshipRecommenderController schRecCon = new ScholarshipRecommenderController();

        //No Rec ID
        System.currentPageReference().getParameters().put('recId', '');
        schRecCon = new ScholarshipRecommenderController();
        schRecCon.Save();

        //Rec ID doesn't exist but is 15 characters
        System.currentPageReference().getParameters().put('recId', 'AAAAAAAAAAAAAAA0');
        schRecCon = new ScholarshipRecommenderController();
        schRecCon.Save();

        //No Scholarship Applicant
        System.currentPageReference().getParameters().put('recId', scholarshipApplicant.Id + '1');
        schRecCon = new ScholarshipRecommenderController();
        schRecCon.Save();

        //recId less than 15
        System.currentPageReference().getParameters().put('recId', scholarshipApplicant.Id);
        schRecCon = new ScholarshipRecommenderController();
        schRecCon.Save();

        //Add scholarship applicant
        schRecCon.ScholarshipApplicant = scholarshipApplicant;
        schRecCon = new ScholarshipRecommenderController();
        schRecCon.Save();

        //recId = 2
        System.currentPageReference().getParameters().put('recId', scholarshipApplicant.Id + '2');
        schRecCon = new ScholarshipRecommenderController();
        schRecCon.Save();

        //recID > 2
        System.currentPageReference().getParameters().put('recId', scholarshipApplicant.Id + '3');
        schRecCon = new ScholarshipRecommenderController();
        schRecCon.Save();
        Test.stopTest();
    }

    @IsTest
    static void aggressivelyTestSharedUtilitiesForCodeCoverage() {
        Test.startTest();
        ScholarshipSharedUtilities.getActiveUserId();
        ScholarshipSharedUtilities.getContactRecord(ScholarshipSharedUtilities.getActiveUserId());
        ScholarshipSharedUtilities.getActiveContactId();
        ScholarshipSharedUtilities.setSid(System.currentPageReference(), false, 'Scholarship-FAKE');
        ScholarshipSharedUtilities.getScholarshipInfo('Scholarship-FAKE');
        ScholarshipSharedUtilities.getApplicantInfo('Scholarship-FAKE', ScholarshipSharedUtilities.getActiveUserId());
        ScholarshipSharedUtilities.isScholarshipOpen(ScholarshipSharedUtilities.getScholarshipInfo('Scholarship-FAKE'));
        ScholarshipSharedUtilities.adjustForCentralTime(Datetime.newInstance(2022, 10, 11));
        ScholarshipSharedUtilities.sendEmail('na', 'testemail20221011@stthomas-test.edu',
                'Test Email Subject', '<p>Test Email HTML Body</p>',
                'Test Email Plain Text', 'Test Email Recipient Name');
        Test.stopTest();
    }

    @IsTest
    static void testScholarshipApplicationComplete() {
        Scholarship__c scholarship = [SELECT Id, Scholarship_ID__c FROM Scholarship__c WHERE Name = 'Test Scholarship0' LIMIT 1];
        Test.startTest();
        PageReference appPageComplete = Page.ScholarshipApplicationComplete;
        appPageComplete.getParameters().put('sid', scholarship.Scholarship_ID__c);
        Test.setCurrentPage(appPageComplete);
        ScholarshipApplicationCompleteController appCompleteCon = new ScholarshipApplicationCompleteController();
        System.assertEquals(appCompleteCon.scholarship.Id, scholarship.Id);
        Test.stopTest();
    }

    @IsTest
    static void testScholarshipClosed() {
        Scholarship__c scholarship = [SELECT Id, Scholarship_ID__c FROM Scholarship__c WHERE Name = 'Test Scholarship1' LIMIT 1];
        Test.startTest();
        PageReference appPageClosed = Page.ScholarshipClosed;
        appPageClosed.getParameters().put('sid', scholarship.Scholarship_ID__c);
        Test.setCurrentPage(appPageClosed);
        ScholarshipClosedController appClosedCon = new ScholarshipClosedController();
        System.assertEquals(appClosedCon.scholarship.Id, scholarship.Id);
        Test.stopTest();
    }

    public static User userToRunWith(Id userContact) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User'];
        User u2 = new User(
                Alias = 'newUser',
                Email = 'newuser@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = 'newuser@testorg.com',
                ContactId = userContact
        );

        return u2;
    }


}