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
            this.scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(this.scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
        }
        if (String.isEmpty(scholarshipId)) {
            return Page.ScholarshipHome.setRedirect(true);
        }
        if (this.scholarship == null) {
            return Page.ScholarshipHome.setRedirect(true);
        }

        if (this.scholarshipApplicant.Scholarship_Complete__c) {
            result = new PageReference('/ScholarshipApplicationComplete?sid=' + scholarshipId);
            //return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationComplete, false, scholarshipId); // This looks to me like it should work, but is commented out in the original, so I won't mess with it YET. -JJH
        } else {
            Boolean scholarshipOpen = ScholarshipSharedUtilities.isScholarshipOpen(scholarship);
            if (!scholarshipOpen) {
                result = ScholarshipSharedUtilities.setSid(Page.ScholarshipClosed, false, scholarshipId);
            }
        }
        return result;
    }

    public PageReference SaveCriteria() {
        //Validate input
        /*if (String.isEmpty(scholarshipApplicant.Application__c)) {
            scholarshipApplicant.Application__c = ActiveApplicationId;
        }*/
        System.debug('SaveCriteria() starts.');
        this.scholarshipApplicant.Scholarship__c = this.scholarship.Id;
        this.scholarshipApplicant.Scholarship_Status__c = 'Started App';

        if (this.scholarshipApplicant.Scholarship_Date_Started__c == null) {
            this.scholarshipApplicant.Scholarship_Date_Started__c = Datetime.now();
        }
        if (this.scholarshipApplicant.Contact__c == null) {
            this.scholarshipApplicant.Contact__c = ScholarshipSharedUtilities.getActiveContactId();
        }

        try {
            upsert this.scholarshipApplicant;
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        this.scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(this.scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
        pageURL = ApexPages.currentPage().getUrl();
        pageURL = ScholarshipSharedUtilities.setHistoryPage(this.scholarship.Scholarship_ID__c);
        System.debug('SaveCriteria() ends.');
        return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage2, false, this.scholarship.Scholarship_ID__c);
    }
}