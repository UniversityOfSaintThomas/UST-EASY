/**
 * Created by jjheaney on 5/2/2022.
 */

public class ScholarshipApplicationPage1Controller {
    public String pageURL { get; set; }
    public Scholarship__c scholarship { get; set; }
    public Scholarship_Applicant__c scholarshipApplicant { get; set; }

    public PageReference sanityCheck() {
        String sId = ApexPages.currentPage().getParameters().get('sid');
        String scholarshipId = null;
        PageReference result = null;

        if (!String.isBlank(sId)) {
            scholarshipId = sId;
            this.scholarship = ScholarshipSharedUtilities.getScholarshipInfo(sId);
            this.scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(scholarshipId, ScholarshipSharedUtilities.getActiveContactId());
        }
        if (String.isEmpty(scholarshipId)) {
            return Page.ScholarshipHome.setRedirect(true);
        }
        if (this.scholarship == null) {
            return Page.ScholarshipHome.setRedirect(true);
        }

        if (this.scholarshipApplicant.Scholarship_Complete__c) {
            result = new PageReference('/applicantportal/ScholarshipHome' + scholarshipId); // TODO: Temporary!
            //return new PageReference('/applicantportal/ScholarshipApplicationComplete?sid=' + scholarshipId);
            //return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationComplete, false, scholarshipId);
        } else {
            Boolean scholarshipOpen = ScholarshipSharedUtilities.isScholarshipOpen(scholarship);
            if (!scholarshipOpen) {
                result = ScholarshipSharedUtilities.setSid(Page.ScholarshipHome, false, scholarshipId); // TODO: Temporary!
                //return ScholarshipSharedUtilities.setSid(Page.ScholarshipClosed, false, scholarshipId);
            }
        }
        return result;
    }

    public PageReference SaveCriteria() {
        //Validate input
        /*if (String.isEmpty(scholarshipApplicant.Application__c)) {
            scholarshipApplicant.Application__c = ActiveApplicationId;
        }*/
        this.scholarshipApplicant.Scholarship__c = this.scholarship.Id;
        this.scholarshipApplicant.Scholarship_Status__c = 'Started App';

        if (this.scholarshipApplicant.Scholarship_Date_Started__c == null) {
            this.scholarshipApplicant.Scholarship_Date_Started__c = Datetime.now();
        }

        try {
            upsert this.scholarshipApplicant;
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        this.scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(this.scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
        pageURL = ApexPages.currentPage().getUrl();
        pageURL = ScholarshipSharedUtilities.setHistoryPage(this.scholarship.Id);
        return ScholarshipSharedUtilities.setSid(Page.ScholarshipHome, false, this.scholarship.Id); // TODO: Should go to ScholarshipApplicationPage2.
    }
}