/**
 * Created by jjheaney on 5/2/2022.
 */

public class ScholarshipApplicationPage1Controller {
    public String pageURL { get; set; }
    public Scholarship__c scholarship { get; set; }
    public Scholarship_Applicant__c scholarshipApplicant { get; set; }

    public ScholarshipApplicationPage1Controller() {
        scholarship = ScholarshipSharedUtilities.getScholarshipInfo();
        if (scholarship != null) {
            scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
        }
    }

    public PageReference sanityCheck() {
        return ScholarshipSharedUtilities.checkScholarshipAccess();
    }

    public PageReference SaveCriteria() {
        Boolean sendStartedEmail = false;
        scholarshipApplicant.Scholarship__c = scholarship.Id;
        scholarshipApplicant.Scholarship_Status__c = 'Started App';

        //For Lightning Email Template merge
        scholarshipApplicant.Review_Award_Process_Description__c = scholarship.Review_Award_Process_Description__c;
        scholarshipApplicant.Scholarship_Communicated_Close_Date__c = scholarship.Communicated_Close_Date__c;
        scholarshipApplicant.Recommender_Question__c = scholarship.Recommender_Question__c;
        scholarshipApplicant.Recommender2_Question__c = scholarship.Recommender2_Question__c;

        if (scholarshipApplicant.Scholarship_Date_Started__c == null) {
            if (scholarship.Send_Started_Scholarship_Email__c) {
                sendStartedEmail = true;
            }
            scholarshipApplicant.Scholarship_Date_Started__c = Datetime.now();
        }
        if (String.isBlank(scholarshipApplicant.Contact__c)) {
            scholarshipApplicant.Contact__c = ScholarshipSharedUtilities.getActiveContactId();
        }

        try {
            upsert scholarshipApplicant;
        } catch (DmlException ex) {
            //Add a message that the record was not saved
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
        pageURL = ApexPages.currentPage().getUrl();

        if (sendStartedEmail) {
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            emailsToSend.add(ScholarshipSharedUtilities.sendLightningEmail(scholarship.Start_Scholarship_Email_Template_Id__c, scholarship.Org_Wide_Email_Id__c, scholarshipApplicant.Id, scholarshipApplicant.Contact__c, scholarshipApplicant.Contact__r.Email));
            Messaging.sendEmail(emailsToSend);
        }

        return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage2, false, scholarship.Scholarship_ID__c);
    }
}