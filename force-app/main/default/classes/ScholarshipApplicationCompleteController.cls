/**
 * Created by jjheaney on 5/12/2022.
 */

public with sharing class ScholarshipApplicationCompleteController {
    public Scholarship__c scholarship { get; set; }
    public Scholarship_Applicant__c scholarshipApplicant { get; set;}
    public String recommender1EmailStatus { get; set;}
    public String recommender2EmailStatus { get; set;}

    public ScholarshipApplicationCompleteController() {
        Id contactId = ScholarshipSharedUtilities.getActiveContactId();
        scholarship = ScholarshipSharedUtilities.getScholarshipInfo();
        scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(scholarship.Id, contactId);

        ScholarshipSharedUtilities.RecommenderEmailStatus recommenderStatus = new ScholarshipSharedUtilities.RecommenderEmailStatus();
        recommender1EmailStatus = recommenderStatus.emailStatus(scholarshipApplicant.Id, scholarshipApplicant.Recommender_Email__c);
        recommender2EmailStatus = recommenderStatus.emailStatus(scholarshipApplicant.Id, scholarshipApplicant.Recommender2_Email__c);
    }

}