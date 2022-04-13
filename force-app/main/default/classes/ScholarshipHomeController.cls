/**
 * Created by jjheaney on 3/3/2022.
 */

public class ScholarshipHomeController {
    public Scholarship__c ScholarshipInfo { get; set; }
    public String scholarshipId { get; set; }
    public String pageURL { get; set; }

    public Id contactId { get; set; }
    public ScholarshipHomeController() {
        contactId = apexpages.currentpage().getparameters().get('cont');
        System.debug('contactId:' + contactId);
    }

    public List<Scholarship__c> getAvailableScholarships() {
        contactId = apexpages.currentpage().getparameters().get('cont');
        System.debug('contactId:' + contactId);

        ScholarshipInfo = new Scholarship__c();
        List<Scholarship__c> availableScholarships = [
                SELECT Name,Id,Scholarship_ID__c,Short_Description__c
                FROM Scholarship__c
                WHERE Open_Date__c <= TODAY AND Close_Date__c >= TODAY
                ORDER BY Name ASC NULLS FIRST
        ];
        return availableScholarships;
    }

    public PageReference chooseScholarship() {
        //assignTo="{!scholarshipID}" sets scholarshipId as instance data
        ScholarshipSharedUtilities.getScholarshipInfo(scholarshipId);
        if (ScholarshipInfo == null) {
            return null;
        }
        //getApplicantInfo();
        pageURL = ScholarshipSharedUtilities.setHistoryPage(scholarshipId);
        return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplication, false, scholarshipId);
    }

}