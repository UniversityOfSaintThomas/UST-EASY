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

    @IsTest static void testScholarshipHome() {
        //dataPrepare();
        Contact student = makeStudentContact();
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

    @IsTest static void testScholarship() {
        dataPrepare();
        Scholarship__c scholarship = makeTestScholarship();
        Contact student = makeStudentContact();
        System.runAs(getScholarshipTestUser(student)) {
            Test.startTest();
            PageReference p1 = ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage1, false, scholarship.Id);
            Test.setCurrentPage(p1);
            ScholarshipApplicationPage1Controller p1con = new ScholarshipApplicationPage1Controller();
            p1con.sanityCheck();
            PageReference p2 = p1con.SaveCriteria();
            Test.setCurrentPage(p2);
            ScholarshipApplicationPage2Controller p2con = new ScholarshipApplicationPage2Controller();
            Test.stopTest();
            /*p2con.


            schCon.sanityCheck();
            schCon.SaveCriteria();
            schCon.SaveApplication();
            schCon.SaveFinishLater();
            schCon.SaveComplete();
            //Add scholarship Test Applicant
            //schCon.ScholarshipApplicant = NewScholarshipApplicant;
            //Expired scholarship
            System.currentPageReference().getParameters().put('sid', ScholarshipInfoExpired.Scholarship_ID__c);
            schCon.ScholarshipInfo = ScholarshipInfoExpired;
            schCon.scholarshipId = ScholarshipInfoExpired.Id;
            schCon.sanityCheck();
            schCon.SaveCriteria();
            schCon.SaveApplication();
            schCon.SaveFinishLater();
            schCon.SaveComplete();
            //Active Scholarship
            System.currentPageReference().getParameters().put('sid', ScholarshipInfo.Scholarship_ID__c);
            schCon.scholarshipId = ScholarshipInfo.Id;
            schCon.ScholarshipInfo = ScholarshipInfo;
            schCon.sanityCheck();
            schCon.SaveCriteria();
            schCon.Essay1Filename = 'test.txt';
            schCon.Essay2Filename = 'test2.text';
            schCon.Essay1 = Essay1;
            schCon.Essay2 = Essay2;
            schCon.e1Text = true;
            schCon.e2Text = false;
            schCon.UploadEssay1();
            schCon.UploadEssay2();
            schCon.DeleteEssay1();
            schCon.DeleteEssay2();
            schCon.sendRecommenderEmail();
            schCon.GoHome();
            schCon.GoCriteria();
            schCon.SaveCriteria();
            schCon.SaveApplication();
            schCon.SaveFinishLater();
            schCon.SaveComplete();
            schCon.completedPage();
            Test.stopTest();*/
        }
    }
    private static User getScholarshipTestUser(Contact student) {
        User testUser;

        User[] testUsers = [SELECT Id FROM User WHERE Email='u1@testorg.com'];
        if (testUsers.size() > 0) {
            testUser = testUsers.get(0);
        } else {
            Profile testProfile = getTestProfile();
            testUser = new User(alias = 'u1', email = 'u1@testorg.com', emailencodingkey = 'UTF-8', lastname = 'Testing',
                    languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = testProfile.Id,
                    timezonesidkey = 'America/Los_Angeles', username = 'u1@testorg.com', contactId = student.Id);
            insert testUser;
            testUser = [SELECT Id FROM User WHERE Id=:testUser.Id];
        }
        return testUser;
    }

    private static Scholarship__c makeTestScholarship() {
        Date yesterday = Date.today().addDays(-1);
        Date tomorrow = Date.today().addDays(1);
        Scholarship__c ScholarshipInfo = new Scholarship__c(
                Name = 'Test Scholarship', Close_Date__c = tomorrow, Open_Date__c = yesterday,
                Recommender__c = true, Recommender_Auto_Send__c = true,Recommender2__c = true, Recommender2_Auto_Send__c = true,
                Completion_Statement__c = 'TEST', Criteria_Statement__c='TEST', Description__c = 'TEST', Essay_1_Text__c = 'TEST',
                Essay_2_Text__c = 'TEST', Question_1_Text__c = 'TEST', Recommender2_Description__c='TEST', Recommender2_Question__c='TEST',
                Recommender_Description__c = 'TEST', Recommender_Question__c= 'TEST', Short_Description__c = 'TEST',
                Review_Award_Process_Description__c = 'TEST', Self_Report_ACT_GPA_Criteria__c = true
        );
        insert ScholarshipInfo;
        ScholarshipInfo = [SELECT Id, Scholarship_ID__c, Description__c, Recommender2_Auto_Send__c, Recommender_Question__c, Recommender2_Question__c, Recommender_Auto_Send__c, Essay_1_Text__c,Essay_2_Text__c,  Name, Close_Date__c, Open_Date__c, Recommender2__c, Recommender__c FROM Scholarship__c WHERE Id =:ScholarshipInfo.Id];
        return ScholarshipInfo;
    }

    private static Profile getTestProfile() {
        Profile testProfile = [SELECT id, name FROM profile WHERE name='Customer Community Login User'];
        return testProfile;
    }

    public static Contact makeStudentContact() {
        //Creating a student contact
        Contact student = new Contact(firstname='test',lastname='Contact',MailingStreet='testStreet',MailingCity='testCity',
                MailingState='Rajasthan',MailingPostalCode='123455',MailingCountry='India');
        insert student;
        student = [SELECT Id FROM Contact WHERE ID = :student.Id];
        return student;
    }

    private static void dataPrepare(){
            //Querying on profile
            Profile testProfile = getTestProfile();
            Contact student = makeStudentContact();
            Scholarship__c scholarship = makeTestScholarship();

            //Creating a test user based on the student
            User testUser = new User(alias = 'u1', email='u1@testorg.com', emailencodingkey='UTF-8',
                                    lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                    profileid = testProfile.Id, timezonesidkey='America/Los_Angeles',
                                    username='u1@testorg.com',contactId=student.Id);
            insert testUser;
            testUser = [SELECT Id FROM User WHERE Id=:testUser.Id];
            Date yesterday = Date.today().addDays(-1);
            Date twoDaysAgo = Date.today().addDays(-2);
            Scholarship__c ScholarshipInfoExpired = new Scholarship__c(
                   Name = 'Test Scholarship', Close_Date__c = yesterday, Open_Date__c = twoDaysAgo,
                   Recommender__c = true, Recommender_Auto_Send__c = true,Recommender2__c = true, Recommender2_Auto_Send__c = true,
                   Completion_Statement__c = 'TEST', Criteria_Statement__c='TEST', Description__c = 'TEST', Essay_1_Text__c = 'TEST',
                   Essay_2_Text__c = 'TEST', Question_1_Text__c = 'TEST', Recommender2_Description__c='TEST', Recommender2_Question__c='TEST',
                   Recommender_Description__c = 'TEST', Recommender_Question__c= 'TEST', Short_Description__c = 'TEST',
                   Review_Award_Process_Description__c = 'TEST', Self_Report_ACT_GPA_Criteria__c = true
            );
           insert ScholarshipInfoExpired;
           ScholarshipInfoExpired = [SELECT Id,Recommender_Auto_Send__c, Description__c, Scholarship_ID__c, Name, Close_Date__c, Open_Date__c,
                   Recommender2__c, Recommender__c FROM Scholarship__c WHERE Id =:ScholarshipInfoExpired.Id];
           Scholarship_Applicant__c ScholarshipApplicant = new Scholarship_Applicant__c(
                   Contact__c = student.Id,
                   Scholarship__c = scholarship.Id,
                   Recommender2_name__c = 'Thad2',
                   Recommender_Name__c = 'Thad1',
                   Recommender_Email__c = 'sf1@valleyhill.net',
                   Recommender2_Email__c = 'sf2@valleyhill.net',
                   Essay_1_Uploaded__c = false,
                   Essay_2_uploaded__c = false
           );
           insert ScholarshipApplicant;
           ScholarshipApplicant = [SELECT
                   Contact__c, Scholarship__c,
                   Recommender_Name__c,
                   Recommender2_Name__c,
                   Recommender_Email__c,
                   Recommender2_Email__c,
                   Essay_1_Uploaded__c,
                   Essay_1_Uploaded_Orig_Filename__c,
                   Essay_2_Uploaded__c,
                   Essay_2_Uploaded_Orig_Filename__c,
                   Essay_1_Answer__c FROM Scholarship_Applicant__c WHERE Id =:ScholarshipApplicant.Id];

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