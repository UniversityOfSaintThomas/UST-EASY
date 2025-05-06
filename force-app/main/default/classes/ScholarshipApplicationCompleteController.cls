/**
 * Created by jjheaney on 5/12/2022.
 */

public with sharing class ScholarshipApplicationCompleteController {
    public Scholarship__c scholarship { get; set; }
    public Scholarship_Applicant__c scholarshipApplicant { get; set;}

    public ScholarshipApplicationCompleteController() {
        Id contactId = ScholarshipSharedUtilities.getActiveContactId();
        scholarship = ScholarshipSharedUtilities.getScholarshipInfo();
        scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(scholarship.Id, contactId);
    }

}