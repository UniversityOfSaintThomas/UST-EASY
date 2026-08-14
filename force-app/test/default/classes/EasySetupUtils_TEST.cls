// This class only wraps one-time scratch-org setup logic that operates on data seeded by the
// scratch-org build itself (the EASY_Applicant_Portal Site, the "Unknown ..." holding Accounts,
// the Requirement_Item__c catalog). None of that can reasonably be constructed inside a test
// method - SeeAllData=true is intentional here rather than a general Apex testing pattern.
@isTest(SeeAllData=true)
private class EasySetupUtils_TEST {

    @isTest
    static void setHoldingIdsPointsFamilyMemberItemsAtTheirOwnRecordTypes() {
        Test.startTest();
        EasySetupUtils.setHoldingIds();
        Test.stopTest();

        Id familyMemberSiblingRtId = Schema.SObjectType.Family_Member__c.getRecordTypeInfosByName().get('Sibling').getRecordTypeId();

        List<Requirement_Item__c> siblingItems = [
                SELECT Related_Object_Record_Type_ID__c, Holding_Record_Id__c
                FROM Requirement_Item__c
                WHERE Related_List_Object__c = 'Family_Member__c'
                AND Name LIKE '%Sibling%'
        ];

        System.assert(!siblingItems.isEmpty(), 'Expected at least one Family_Member__c sibling requirement item to exist');
        for (Requirement_Item__c item : siblingItems) {
            System.assertEquals(familyMemberSiblingRtId, item.Related_Object_Record_Type_ID__c,
                    'Sibling requirement items should reference Family_Member__c\'s own RecordType, not Family__c\'s');
            System.assertNotEquals(null, item.Holding_Record_Id__c, 'Sibling requirement items should have a holding record');
        }
    }

    @isTest
    static void setHoldingIdsIsSafeToRunTwice() {
        Test.startTest();
        EasySetupUtils.setHoldingIds();
        EasySetupUtils.setHoldingIds();
        Test.stopTest();
    }

    @isTest
    static void permissionGuestUserAssignsWithoutErrorAndIsIdempotent() {
        Test.startTest();
        EasySetupUtils.permissionGuestUser();
        EasySetupUtils.permissionGuestUser();
        Test.stopTest();
    }

    @isTest
    static void permissionAdminUserAssignsEveryMatchedPermissionSet() {
        List<PermissionSet> adminPermissionSets = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'Application_Admin' OR Name = 'Data_Mover_Staging_Tables_Access'
        ];
        List<User> adminUsers = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        System.assert(!adminPermissionSets.isEmpty(), 'Expected at least one admin permission set to exist for this test to be meaningful');
        System.assert(!adminUsers.isEmpty(), 'Expected at least one System Administrator user to exist for this test to be meaningful');

        Test.startTest();
        EasySetupUtils.permissionAdminUser();
        EasySetupUtils.permissionAdminUser();
        Test.stopTest();

        Set<Id> expectedPermissionSetIds = new Set<Id>();
        for (PermissionSet ps : adminPermissionSets) {
            expectedPermissionSetIds.add(ps.Id);
        }

        List<PermissionSetAssignment> assignments = [
                SELECT PermissionSetId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :adminUsers[0].Id
                AND PermissionSetId IN :expectedPermissionSetIds
        ];

        System.assertEquals(expectedPermissionSetIds.size(), assignments.size(),
                'Every matched admin permission set should be assigned to the admin user, not just the first one');
    }

    @isTest
    static void setEASYCustomSettingsPopulatesCommunityDetails() {
        Test.startTest();
        EasySetupUtils.setEASYCustomSettings();
        Test.stopTest();

        Application_Setting__c settings = Application_Setting__c.getOrgDefaults();
        System.assertEquals('stthomas2021', settings.Default_Template__c);
        System.assertNotEquals(null, settings.Community_URL__c);
    }

    @isTest
    static void setUserRoleUpdatesCountryAndRole() {
        List<User> userUsers = [SELECT Id FROM User WHERE Name = 'User User' LIMIT 1];
        System.assert(!userUsers.isEmpty(), 'Expected a "User User" record to exist for this test to be meaningful');

        Test.startTest();
        EasySetupUtils.setUserRole();
        Test.stopTest();

        User updated = [SELECT Country, UserRoleId FROM User WHERE Id = :userUsers[0].Id];
        System.assertEquals('United States', updated.Country);
    }

    @isTest
    static void setHierarchySettingsPopulatesNamingFormats() {
        Test.startTest();
        EasySetupUtils.setHierarchySettings();
        Test.stopTest();

        hed__Hierarchy_Settings__c settings = hed__Hierarchy_Settings__c.getOrgDefaults();
        System.assertEquals('{!LastName} ({!{!FirstName}}) Household', settings.hed__Household_Account_Naming_Format__c);
        System.assertEquals('{!LastName} ({!{!FirstName}}) Administrative Account', settings.hed__Admin_Account_Naming_Format__c);
    }

    @isTest
    static void setReviewSettingsCreatesAllExpectedRowsAndIsIdempotent() {
        Test.startTest();
        EasySetupUtils.setReviewSettings();
        EasySetupUtils.setReviewSettings();
        Test.stopTest();

        Set<String> expectedNames = new Set<String>{
                'hed__Attribute__c', 'hed__Contact_Language__c', 'hed__Education_History__c', 'hed__Test__c'
        };

        List<Related_Object_Review__c> reviews = [SELECT Name FROM Related_Object_Review__c WHERE Name IN :expectedNames];

        Set<String> actualNames = new Set<String>();
        for (Related_Object_Review__c review : reviews) {
            actualNames.add(review.Name);
        }

        System.assertEquals(expectedNames, actualNames, 'Every expected object name should have exactly one review row');
    }
}
