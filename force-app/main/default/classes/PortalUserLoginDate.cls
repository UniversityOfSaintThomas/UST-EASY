/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PortalUserLoginDate {
    @future
    public static void upsertContacts(List<String> userIdsAffected) {
        List<Id> contactAffectedIds = new List<Id>();
        List<User> usersAffected = 
        [
            SELECT 
                Id, 
                ContactId,
                Contact.Portal_User_First_Login__c,
                Contact.Portal_User_Latest_Login__c
            FROM User
            WHERE Id IN :userIdsAffected
        ];
        List<Contact> contactsToUpdate = new List<Contact>();
        //Populate Portal User First Login and Portal User Latest Login on Contact for each UserID
        for(User user : usersAffected) {
            Contact new_contact = new Contact(
                Id = user.ContactId,
                Portal_User_First_Login__c = user.Contact.Portal_User_First_Login__c,
                Portal_User_Latest_Login__c = user.Contact.Portal_User_Latest_Login__c
                );
            if (new_contact.Portal_User_First_Login__c == null) {
                new_contact.Portal_User_First_Login__c = System.today();
            }
            new_contact.Portal_User_Latest_Login__c = System.today();
            contactsToUpdate.add(new_contact);
            upsert contactsToUpdate;
        }        
    }
}