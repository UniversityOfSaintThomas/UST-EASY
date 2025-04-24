/**
 * Created by nguy0092 on 3/28/2025.
 */

public with sharing class ScholarshipRecommenderResendController {

    @AuraEnabled(Cacheable=false)
    public static Boolean resendRecommendation(String scholarshipId, String contactId, Boolean recommendation1, Boolean recommendation2) {

        ScholarshipApplicationPage2Controller scholarshipApp = new ScholarshipApplicationPage2Controller(scholarshipId, contactId);

        scholarshipApp.resendRecommendationRequestBool = true;
        scholarshipApp.resendRecommendation1 = recommendation1;
        scholarshipApp.resendRecommendation2 = recommendation2;

        scholarshipApp.scholarship = [
                SELECT Close_Date__c, Completion_Statement__c, Criteria_Statement__c, Description__c, Essay_1_Text__c, Essay_2_Text__c,
                        Id, Name, Open_Date__c, OwnerId, Question_1_Text__c, Question_2_Text__c, Question_3_Text__c, Question_4_Text__c,
                        Recommender2_Auto_Send__c, Recommender2_Description__c, Recommender2_Question__c, Recommender2__c, Recommender_Auto_Send__c,
                        Recommender_Description__c, Recommender_Question__c, Recommender__c, Scholarship_ID__c, Short_Description__c,
                        Review_Award_Process_Description__c, Self_Report_ACT_GPA_Criteria__c, Essay_1_Allow_Upload__c, Essay_2_Allow_Upload__c,
                        Recommender_Option__c, Recommender2_Option__c, Recommender_Email_Template_Id__c, Recommender2_Email_Template_Id__c, Recommender_Org_From_Email_Id__c
                FROM Scholarship__c
                WHERE Scholarship_ID__c = :scholarshipId
        ];

        if (scholarshipApp.scholarship != null) {
            scholarshipApp.applicant = ScholarshipSharedUtilities.getApplicantInfo(scholarshipApp.scholarship.Id, contactId);
            scholarshipApp.essay1HasText = !String.isEmpty(scholarshipApp.applicant.Essay_1_Answer__c);
            scholarshipApp.essay2HasText = !String.isEmpty(scholarshipApp.applicant.Essay_2_Answer__c);
            if (scholarshipApp.applicant.Recommendation_Request_Date__c != null) {
                scholarshipApp.recommendRequestDate1 = ScholarshipSharedUtilities.adjustForCentralTime(scholarshipApp.applicant.Recommendation_Request_Date__c);
            }
            if (scholarshipApp.applicant.Recommendation2_Request_Date__c != null) {
                scholarshipApp.recommendRequestDate2 = ScholarshipSharedUtilities.adjustForCentralTime(scholarshipApp.applicant.Recommendation2_Request_Date__c);
            }
        }

        try {
            return scholarshipApp.SendRecommenderEmail() != null ? true : false;
        } catch (Exception ex) {
            System.debug('Recommendation Request Resent Error: '+ex);
        }

        return false;
    }

}