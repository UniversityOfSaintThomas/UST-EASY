/**
 * Created by nguy0092 on 3/22/2025.
 */

public with sharing class YenTestResend1 {

    @AuraEnabled(Cacheable=false)
    public static Boolean showMeStuff(String scholarshipId, String contactId, Boolean recommendation1, Boolean recommendation2) {

        ScholarshipApplicationPage2Controller newS = new ScholarshipApplicationPage2Controller(scholarshipId, contactId);

//        System.debug('What is resend before: '+newS.resendRecommendationRequestBool);
        newS.resendRecommendationRequestBool = true;
        newS.resendRecommendation1 = recommendation1;
        newS.resendRecommendation2 = recommendation2;
//        System.debug('What is resend after: '+newS.resendRecommendationRequestBool);

        newS.scholarship = [
                SELECT Close_Date__c, Completion_Statement__c, Criteria_Statement__c, Description__c, Essay_1_Text__c, Essay_2_Text__c,
                        Id, Name, Open_Date__c, OwnerId, Question_1_Text__c, Question_2_Text__c, Question_3_Text__c, Question_4_Text__c,
                        Recommender2_Auto_Send__c, Recommender2_Description__c, Recommender2_Question__c, Recommender2__c, Recommender_Auto_Send__c,
                        Recommender_Description__c, Recommender_Question__c, Recommender__c, Scholarship_ID__c, Short_Description__c,
                        Review_Award_Process_Description__c, Self_Report_ACT_GPA_Criteria__c, Essay_1_Allow_Upload__c, Essay_2_Allow_Upload__c,
                        Recommender_Option__c, Recommender2_Option__c
                FROM Scholarship__c
                WHERE Scholarship_ID__c = :scholarshipId
        ];

        if (newS.scholarship != null) {
            newS.applicant = ScholarshipSharedUtilities.getApplicantInfo(newS.scholarship.Id, contactId);
            newS.essay1HasText = !String.isEmpty(newS.applicant.Essay_1_Answer__c);
            newS.essay2HasText = !String.isEmpty(newS.applicant.Essay_2_Answer__c);
            if (newS.applicant.Recommendation_Request_Date__c != null) {
                newS.recommendRequestDate1 = ScholarshipSharedUtilities.adjustForCentralTime(newS.applicant.Recommendation_Request_Date__c);
            }
            if (newS.applicant.Recommendation2_Request_Date__c != null) {
                newS.recommendRequestDate2 = ScholarshipSharedUtilities.adjustForCentralTime(newS.applicant.Recommendation2_Request_Date__c);
            }
        }

//        System.debug(newS.scholarship);
//        System.debug(newS.applicant);

        try {
            return newS.SendRecommenderEmail() != null ? true : false;
//            upsert new Scholarship_Applicant__c(Id = newS.applicant.Id,
//                                                Resend_Recommendation_Request__c = false,
//                                                Resend_Recommendation2_Request__c = false);
        } catch (Exception ex) {
            System.debug('Recommendation Request Resent Error: '+ex);
        }

        return false;
    }

//    private static void SendRecommenderEmail(Scholarship__c scholarship, Scholarship_Applicant__c applicant) {
//        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
//
////        PageReference redirectPage = Page.ScholarshipApplicationPage2;
////        redirectPage.setRedirect(true);
////        redirectPage.getParameters().put('sid', sid);
//        //return redirectPage;
//
//        String recName1 = applicant.Recommender_Name__c;
//        String recEmail1 = applicant.Recommender_Email__c;
//        String recLink1 = applicant.Recommendation_Link__c;
//
//        String recName2 = applicant.Recommender2_Name__c;
//        String recEmail2 = applicant.Recommender2_Email__c;
//        String recLink2 = applicant.Recommendation_Link_2__c;
//
//        Boolean recSent = false;
//        String RecSubject = 'University of St. Thomas ' + scholarship.Name;
//        String styles = ' style="margin: 10px 0;padding: 0;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: rgb(85, 85, 85);font-family: Palatino Linotype, Georgia, serif;font-size: 16px;line-height: 150%;text-align: left;"';
//        String styledP = '<p ' + styles + '>';
//        String RecMessage = styledP + applicant.Name + ' has applied for the ' + scholarship.Name + ' at the University of St. Thomas and indicated that you would be willing to write a recommendation. </p>';
//        String recMessageLink1;
//        String recMessageLink2;
//
//        if (String.isNotBlank(scholarship.Description__c)) {
//            String scholarshipDescription = scholarship.Description__c;
//            scholarshipDescription = scholarshipDescription.replaceAll('<p>', styledP);
//            scholarshipDescription = scholarshipDescription.replaceAll('<ul>', '<ul ' + styles + '>');
//            scholarshipDescription = scholarshipDescription.replaceAll('<li>', '<li ' + styles + '>');
//            RecMessage += styledP + '<strong>Scholarship Description</strong><br/>' + scholarshipDescription + '</p>';
//        }
//        if (String.isNotBlank(scholarship.Recommender_Question__c)) {
//            RecMessage += styledP + scholarship.Recommender_Question__c + '</p>';
//        }
//
////        if (String.isNotBlank(recName1) && String.isNotBlank(recEmail1) && applicant.Recommendation_Request_Date__c == null) {
//        if (String.isNotBlank(recName1) && String.isNotBlank(recEmail1)) {
//            recMessageLink1 = RecMessage;
//            recMessageLink1 += styledP + '<a href="' + recLink1 + '" class="button">Submit your recommendation</a></p>';
//            if (!String.isEmpty(recEmail1)) {
//                emailsToSend.add(ScholarshipSharedUtilities.sendEmail(recName1, recEmail1, RecSubject, recMessageLink1, recMessageLink1, scholarship.Name));
//                applicant.Recommendation_Request_Date__c = Datetime.now();
//            }
//        }
//
////        if (String.isNotBlank(recName2) && String.isNotBlank(recEmail2) && applicant.Recommendation2_Request_Date__c == null) {
//        if (String.isNotBlank(recName2) && String.isNotBlank(recEmail2)) {
//            recMessageLink2 = RecMessage;
//            recMessageLink2 += styledP + '<a href="' + recLink2 + '" class="button">Submit your recommendation</a></p>';
//            if (!String.isEmpty(recEmail2)) {
//                emailsToSend.add(ScholarshipSharedUtilities.sendEmail(recName2, recEmail2, RecSubject, recMessageLink2, recMessageLink2, scholarship.Name));
//                applicant.Recommendation2_Request_Date__c = Datetime.now();
//            }
//        }
//
//        upsert applicant;
//
//        if (emailsToSend.size() > 0) {
//            try {
//                Messaging.sendEmail(emailsToSend);
////                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Recommendation request sent'));
//            } catch (Exception ex) {
//                //If the email fails, we want to add the error message to the activity task description
////                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No recommendation request sent' + ex.getMessage()));
////                System.debug(ex.getMessage());
////                return null;
//            }
//        }
//
//    }

}