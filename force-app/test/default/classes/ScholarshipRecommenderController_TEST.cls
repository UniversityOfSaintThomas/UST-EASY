@isTest
private class ScholarshipRecommenderController_TEST{
    /* @TestSetup static void insertCertainBaselineDataForTestsIfNotPresent() { Util.insertCertainBaselineDataForTestsIfNotPresent(); }
     private static Profile testProfile ;
     private static Contact student;
     private static User testUser;
     private static  Scholarship__c ScholarshipInfo {get; set;}
     private static  Scholarship_Applicant__c ScholarshipApplicant {get; set;}*/

    @IsTest
    static void scholarshipRecommendersTest() {
        /* dataPrepare();
         System.runAs(testUser){
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
         }*/
    }

    /********* Function Perpared the all required information **********/
    private static void dataPrepare(){
        /*   //Querying on profile
           testProfile = [select id, name from profile where name='Student Portal User'];
           student = new Contact(firstname='test',lastname='Contact',MailingStreet='testStreet',MailingCity='testCity',MailingState='Rajasthan',MailingPostalCode='123455',MailingCountry='India');
           insert student;
           testUser = new User(alias = 'u1', email='u1@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = testProfile.Id, timezonesidkey='America/Los_Angeles', username='u1@testorg.com',contactId=student.Id);
           //inserting user
           insert testUser;

           List<EnrollmentrxRx__Enrollment_Opportunity__c> app = [Select Id, Fellowship_Type__c from EnrollmentrxRx__Enrollment_Opportunity__c where EnrollmentrxRx__Applicant__c=: student.Id];
           if(app.size() > 0){
               currentApplication = app[0] ;
           }

           Date yesterday = Date.today().addDays(-1);
           Date tomorrow = Date.today().addDays(1);
           ScholarshipInfo = new Scholarship__c(
               Name = 'Test Scholarship', Close_Date__c = tomorrow, Open_Date__c = yesterday,
               Recommender__c = true, Recommender_Auto_Send__c = true,Recommender2__c = true, Recommender2_Auto_Send__c = true,
               Completion_Statement__c = 'TEST', Criteria_Statement__c='TEST', Description__c = 'TEST', Essay_1_Text__c = 'TEST',
               Essay_2_Text__c = 'TEST', Question_1_Text__c = 'TEST', Recommender2_Description__c='TEST', Recommender2_Question__c='TEST',
               Recommender_Description__c = 'TEST', Recommender_Question__c= 'TEST', Short_Description__c = 'TEST',
               Review_Award_Process_Description__c = 'TEST', Self_Report_ACT_GPA_Criteria__c = true
           );
           insert ScholarshipInfo;

           ScholarshipApplicant = new Scholarship_Applicant__c(Application__c = currentApplication.Id, Scholarship__c = ScholarshipInfo.Id, Recommendation__c = 'TEST');
           insert ScholarshipApplicant;    */

    }

}