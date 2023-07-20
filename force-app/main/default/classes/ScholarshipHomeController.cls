/**
 * Created by jjheaney on 3/3/2022.
 */

public class ScholarshipHomeController {
    public Scholarship__c ScholarshipInfo { get; set; }
    public String scholarshipId { get; set; }
    public String pageURL { get; set; }
    public Id userId { get; set; }
    public String firstNameLastName { get; set; }

    public ScholarshipHomeController() {
        this.userId = UserInfo.getUserId();
        this.firstNameLastName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
    }

    public List<Scholarship__c> getAvailableScholarships() {
        List<Scholarship__c> availableScholarships = [
                SELECT Name,Id,Scholarship_ID__c,Short_Description__c
                FROM Scholarship__c
                WHERE Open_Date__c <= TODAY AND Close_Date__c >= TODAY  AND RecordType.DeveloperName = 'Scholarship'
                ORDER BY Name ASC NULLS FIRST
        ];
        return availableScholarships;
    }

    public PageReference chooseScholarship() {
        //assignTo="{!scholarshipID}" sets scholarshipId as instance data
        this.ScholarshipInfo = ScholarshipSharedUtilities.getScholarshipInfo(scholarshipId);
        if (this.ScholarshipInfo == null) {
            System.debug('Return null. :( ');
            return null;
        }
        pageURL = ScholarshipSharedUtilities.setHistoryPage(scholarshipId);
        System.debug('It should redirect now.');
        return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage1, true, scholarshipId);
    }

}