/**
 * Created by jjheaney on 5/2/2022.
 */

public class ScholarshipApplicationPage1Controller {
    public String pageURL { get; set; }

    public PageReference sanityCheck() {
        String sId = ApexPages.currentPage().getParameters().get('sid');
        Scholarship__c scholarship = null;
        String scholarshipId = null;
        Scholarship_Applicant__c applicantInfo;

        if (!String.isBlank(sId)) {
            scholarshipId = sId;
            //ActiveApplicationId = PortalUtility.getActiveApplicationId();
            scholarship = ScholarshipSharedUtilities.getScholarshipInfo(sId);
            applicantInfo = ScholarshipSharedUtilities.getApplicantInfo(scholarshipId, ScholarshipSharedUtilities.getActiveContactId());
        }
        if (String.isEmpty(scholarshipId)) {
            return Page.ScholarshipHome.setRedirect(true);
        }
        if (scholarship == null) {
            return Page.ScholarshipHome.setRedirect(true);
        }
/*
        if (ScholarshipApplicant.Scholarship_Complete__c) {
            return new PageReference('/applicantportal/ScholarshipApplicationComplete?sid=' + scholarshipId);
            //return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationComplete, false, scholarshipId);
        }
        Boolean scholarshipOpen = ScholarshipSharedUtilities.isScholarshipOpen(scholarship);
        if (!scholarshipOpen || scholarshipClosed) {
            return ScholarshipSharedUtilities.setSid(Page.ScholarshipClosed, false, scholarshipId);
        }*/

        return null;
    }
}