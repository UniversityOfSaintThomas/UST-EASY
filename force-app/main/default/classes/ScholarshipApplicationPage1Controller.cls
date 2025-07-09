/**
 * Created by jjheaney on 5/2/2022.
 */

public with sharing class ScholarshipApplicationPage1Controller {
//    public String pageURL { get; set; }
    public Scholarship__c scholarship { get; set; }
    public Scholarship_Applicant__c scholarshipApplicant { get; set; }
    private ScholarshipSharedUtilities.emailUtilities emailBuilder { get; set; }

    public ScholarshipApplicationPage1Controller() {
        emailBuilder = new ScholarshipSharedUtilities.emailUtilities();
        scholarship = ScholarshipSharedUtilities.getScholarshipInfo();

        if (scholarship != null) {
            scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
            List<RecordType> scholarshipType = [
                    SELECT Id
                    FROM RecordType
                    WHERE SobjectType = 'Scholarship__c'
                    AND Id = :scholarship.RecordTypeId
                    AND DeveloperName IN ('Graduate_Scholarship', 'Scholarship', 'Signature_Programs')
            ];
            if (scholarshipType.size() > 0) {
                if (String.isBlank(scholarship.Org_Wide_Email_Id__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Org Wide Email Not Set'));
                }
                if (scholarship.Send_Started_Scholarship_Email__c && String.isBlank(scholarship.Start_Scholarship_Email_Template_Id__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Started Email Template Not Set'));
                }
                if (String.isBlank(scholarship.Submit_Scholarship_Email_Template_Id__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Submit Email Template Not Set'));
                }
                if ((scholarship.Recommender_Option__c == 'Recommender Required' || scholarship.Recommender_Option__c == 'Recommender Optional') && String.isBlank(scholarship.Recommender_Email_Template_Id__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommender 1 Email Template Not Set'));
                }
                if ((scholarship.Recommender2_Option__c == 'Recommender2 Required' || scholarship.Recommender2_Option__c == 'Recommender2 Optional') && String.isBlank(scholarship.Recommender2_Email_Template_Id__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommender 2 Email Template Not Set'));
                }
            }
        }
    }

    public PageReference sanityCheck() {
        return ScholarshipSharedUtilities.checkScholarshipAccess();
    }

    public PageReference SaveCriteria() {
        Boolean sendStartedEmail = false;
        PageReference pageRef = ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage2, false, scholarship.Scholarship_ID__c);
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Scholarship not saved: ' + ex.getMessage()));
            return null;
        }
        scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
//        pageURL = ApexPages.currentPage().getUrl();

        if (sendStartedEmail) {
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            try {
//                emailsToSend.add(ScholarshipSharedUtilities.sendLightningEmail(scholarship.Start_Scholarship_Email_Template_Id__c, scholarship.Org_Wide_Email_Id__c, scholarshipApplicant.Id, scholarshipApplicant.Contact__c, scholarshipApplicant.Contact__r.Email));
//                Messaging.sendEmail(emailsToSend);
                emailsToSend.add(emailBuilder.createEmail(scholarship.Start_Scholarship_Email_Template_Id__c, scholarship.Org_Wide_Email_Id__c, scholarshipApplicant.Id, scholarshipApplicant.Contact__c, scholarshipApplicant.Contact__r.Email));
                emailBuilder.sendCreatedEmails(emailsToSend);
                pageRef.getParameters().put('pageMsg', '1test');
            } catch (Exception ex) {
                //Add Started confirmation email did not send ApexMessage on redirect Page 2 page
                pageRef.getParameters().put('pageMsg', '1w');
                System.debug('Send Start Email exception: ' + ex.getMessage());
            }
        }

        return pageRef;
    }
}