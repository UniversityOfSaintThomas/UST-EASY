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
        //Query Contact data for each user Id
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
        //Populate Portal User First Login and Portal User Latest Login on Contact for each User
        for(User user : usersAffected) {
            Contact new_contact = new Contact(
                Id = user.ContactId,
                Portal_User_First_Login__c = user.Contact.Portal_User_First_Login__c,
                Portal_User_Latest_Login__c = user.Contact.Portal_User_Latest_Login__c
                );
            //Only populate this field the first time a user logs into portal
            if (new_contact.Portal_User_First_Login__c == null) {
                new_contact.Portal_User_First_Login__c = System.today();
            }
            new_contact.Portal_User_Latest_Login__c = System.today();
            contactsToUpdate.add(new_contact); 
        } 
        if (contactsToUpdate.size() > 0 && !System.isFuture() && !System.isBatch()) {
            try {
                upsert contactsToUpdate;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }     
    }
}