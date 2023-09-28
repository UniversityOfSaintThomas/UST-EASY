@isTest
public class ApplicationTESTUtilities {

    public static Application_Control__c createApplicationControl() {
        Application_Control__c appControl = new Application_Control__c(
                Name = 'test',
                Application_Start_Status__c = Application_Control__c.Application_Start_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Active__c = true,
                Allow_Cancel_From__c = Application_Control__c.Allow_Cancel_From__c.getDescribe().getPicklistValues()[0].getValue(),
                Allow_Withdraw_From__c = Application_Control__c.Allow_Withdraw_From__c.getDescribe().getPicklistValues()[0].getValue(),
                Allow_Submit_From__c = Application_Control__c.Allow_Submit_From__c.getDescribe().getPicklistValues()[0].getValue(),
                Cancel_Status__c = Application_Control__c.Cancel_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Default__c = true,
                URL_Parameter__c = 'st',
                Submit_Status__c = Application_Control__c.Submit_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Withdraw_Status__c = Application_Control__c.Withdraw_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Application_Control_External_ID__c = ApplicationUtilities.getUUID()
        );
        insert appControl;
        return appControl;
    }

    public static User userToRunWith(String profileName, String PermissionSetToAdd, Id userContact) {

        User u2 = buildUser('example1@sfdx-test.com', 'lm', 'System Administrator');
        insert u2;
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Portal User%' Limit 1];

        System.runAs(u2) {
            User u3 = buildUser('example2@sfdx-test.com', 'ceo', profileName);
            U3.ContactId = userContact;
            insert u3;
            if (String.isNotBlank(PermissionSetToAdd)) {
                List<PermissionSet> seaGuestPermissions = [SELECT Id, Name FROM PermissionSet WHERE Name = :PermissionSetToAdd];
                Id permId = seaGuestPermissions[0].Id;
                PermissionSetAssignment permissionSetChange = new PermissionSetAssignment();
                permissionSetChange.AssigneeId = u3.Id;
                permissionSetChange.PermissionSetId = permId;
                insert permissionSetChange;
            }
            return u3;
        }
        return null;
    }

    private static User buildUser(String username, String alias, String profileName) {
        // Profile p = [SELECT Id, Name FROM Profile WHERE Name = :profileName];
        Profile p;
        profileName = '%' + profileName + '%';

        p = [select Id, name from Profile where Name LIKE :profileName LIMIT 1];

        return new User(
                Alias = alias,
                Username = username,
                LastName = 'LM',
                Email = 'example@example-213213.com',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                ProfileId = p.Id
        );
    }
}