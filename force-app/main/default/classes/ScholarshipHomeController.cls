/**
 * Created by jjheaney on 3/3/2022.
 */

public class ScholarshipHomeController {
    public Id userId { get; set; }
    public String firstNameLastName { get; set; }
    public String contactId { get; set; }

    public ScholarshipHomeController() {
        this.userId = UserInfo.getUserId();
        this.firstNameLastName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
    }
}