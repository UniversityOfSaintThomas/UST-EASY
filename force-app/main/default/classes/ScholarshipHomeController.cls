/**
 * Created by jjheaney on 3/3/2022.
 */

public class ScholarshipHomeController {
//    public Scholarship__c ScholarshipInfo { get; set; }
//    public String scholarshipId { get; set; }
//    public String pageURL { get; set; }
    public Id userId { get; set; }
    public String firstNameLastName { get; set; }
    public String contactId { get; set; }

    public ScholarshipHomeController() {
        this.userId = UserInfo.getUserId();
        this.firstNameLastName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
    }
//    public List<Scholarship__c> getAvailableScholarships() {
//        List<Scholarship__c> availableScholarships = [
//                SELECT Name, Id, Scholarship_ID__c, Short_Description__c
//                FROM Scholarship__c
//                WHERE Open_Date__c <= TODAY AND Close_Date__c >= TODAY AND RecordType.DeveloperName = 'Scholarship'
//                ORDER BY Name ASC NULLS FIRST
//        ];
//        return availableScholarships;
//    }
//
//    public PageReference chooseScholarship() {
//        return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage1, true, scholarshipId);
//    }

}