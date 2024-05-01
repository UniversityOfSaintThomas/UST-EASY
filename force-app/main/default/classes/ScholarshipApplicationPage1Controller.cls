/**
 * Created by jjheaney on 5/2/2022.
 */

public class ScholarshipApplicationPage1Controller {
    public String pageURL { get; set; }
    public Scholarship__c scholarship { get; set; }
    public Scholarship_Applicant__c scholarshipApplicant { get; set; }

    public ScholarshipApplicationPage1Controller() {
        String sId = ApexPages.currentPage().getParameters().get('sid');
        String scholarshipId = null;
        if (String.isNotBlank(sId)) {
            scholarshipId = sId;
            scholarship = ScholarshipSharedUtilities.getScholarshipInfo(sId);
            scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
        }
    }

    public PageReference sanityCheck() {
        return ScholarshipSharedUtilities.checkScholarshipAccess();
    }

    public PageReference SaveCriteria() {

        scholarshipApplicant.Scholarship__c = scholarship.Id;
        scholarshipApplicant.Scholarship_Status__c = 'Started App';

        if (scholarshipApplicant.Scholarship_Date_Started__c == null) {
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
        return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage2, false, scholarship.Scholarship_ID__c);
    }
}