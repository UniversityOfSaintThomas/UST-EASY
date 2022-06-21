private static void setHoldingIds() {


    List<RecordType> highSchoolRecordType = [
            SELECT Id, Name, SobjectType
            FROM RecordType
            WHERE SobjectType = 'hed__Education_History__c'
            AND Name LIKE 'High School'
    ];

    Id highSchoolRecordTypeId = Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get('High School').getRecordTypeId();
    Id collegeRecordTypeId = Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get('College').getRecordTypeId();
    Id familyParentRecordTypeId = Schema.SObjectType.Family__c.getRecordTypeInfosByName().get('Parent/Guardian').getRecordTypeId();
    Id familySiblingRecordTypeId = Schema.SObjectType.Family__c.getRecordTypeInfosByName().get('Sibling').getRecordTypeId();

    List<Account> collegeHolders = [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'Unknown College'
    ];
    List<Account> highSchoolHolders = [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'Unknown High School'
    ];

    List<Requirement_Item__c> collegeRequirementItems = [
            SELECT Id, Name
            FROM Requirement_Item__c
            WHERE Name LIKE 'College%'
    ];

    List<Requirement_Item__c> hsRequirementItems = [
            SELECT Id, Name, Related_List_Where_Clause__c
            FROM Requirement_Item__c
            WHERE Name LIKE 'High School%'
    ];

    List<Requirement_Item__c> updateItems = new List<Requirement_Item__c>();

    for (Requirement_Item__c rItem : collegeRequirementItems) {
        if (collegeHolders.size() > 0) {
            rItem.Holding_Record_Id__c = collegeHolders[0].Id;
        }
        rItem.Related_List_Where_Clause__c = '(RecordTypeId=\'' + collegeRecordTypeId + '\')';
        rItem.Related_Object_Record_Type_ID__c = collegeRecordTypeId;
        updateItems.add(rItem);
    }

    for (Requirement_Item__c rItem : hsRequirementItems) {
        if (highSchoolHolders.size() > 0) {
            rItem.Holding_Record_Id__c = highSchoolHolders[0].Id;
        }
        rItem.Related_List_Where_Clause__c = '(RecordTypeId=\'' + highSchoolRecordTypeId + '\')';

        rItem.Related_Object_Record_Type_ID__c = highSchoolRecordTypeId;
        updateItems.add(rItem);
    }

    //Language holding values updated
    List<hed__Language__c> languageHolders = [
            SELECT Id, Name
            FROM hed__Language__c
            WHERE Name = 'English'
    ];

    List<Requirement_Item__c> languageRequirementItems = [
            SELECT Id, Name
            FROM Requirement_Item__c
            WHERE Name LIKE 'Language%'
    ];

    for (Requirement_Item__c rItem : languageRequirementItems) {
        if (languageHolders.size() > 0) {
            rItem.Holding_Record_Id__c = languageHolders[0].Id;
            updateItems.add(rItem);
        }
    }

    List<Application__c> testApplication = [SELECT Id, Contact__r.Name FROM Application__c WHERE Contact__r.Name = 'Test Contact'];

    Family__c familyHolderSibling = new Family__c(Holding_Name__c = 'Unknown Sibling Account', First_Name__c = 'Unknown', Last_Name__c = 'Sibling Account', RecordTypeId = familySiblingRecordTypeId, Application__c = testApplication[0].Id);
    insert familyHolderSibling;
    Family__c familyHolderParent = new Family__c(Holding_Name__c = 'Unknown Parent Account', First_Name__c = 'Unknown', Last_Name__c = 'Parent Account', RecordTypeId = familyParentRecordTypeId, Application__c = testApplication[0].Id);
    insert familyHolderParent;

    for (Requirement_Item__c familyRequirement : [
            SELECT Id, Name, RecordType.Name, Holding_Record_Id__c, Related_Object_Record_Type_ID__c
            FROM Requirement_Item__c
            WHERE RecordType.Name = 'Related Object'
            AND (Name LIKE '%Parent%%Guardian%'
            OR Name LIKE '%Sibling%')
    ]) {
        if (familyRequirement.Name.contains('Sibling')) {
            familyRequirement.Related_Object_Record_Type_ID__c = familySiblingRecordTypeId;
            familyRequirement.Holding_Record_Id__c = familyHolderSibling.RecordTypeId;
        } else {
            familyRequirement.Related_Object_Record_Type_ID__c = familyParentRecordTypeId;
            familyRequirement.Holding_Record_Id__c = familyHolderParent.RecordTypeId;
        }
        updateItems.add(familyRequirement);
    }

    if (updateItems.size() > 0) {
        update updateItems;
    }


}

private static void permissionGuestUser() {
    Site site = [
            SELECT GuestUserId
            FROM Site
            WHERE Name = 'EASY_Applicant_Portal'
    ];

    List<PermissionSet> guestPermissionSet = [
            SELECT Name, Id
            FROM PermissionSet
            WHERE Name = 'Application_Community_Guest'
    ];

    List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();

    if (!guestPermissionSet.isEmpty()) {
        permissionSetList.add(new PermissionSetAssignment(PermissionSetId = guestPermissionSet[0].Id, AssigneeId = site.GuestUserId));
    }

    if (!permissionSetList.isEmpty()) {
        upsert permissionSetList;
    }
}

private static void permissionAdminUser() {
    List<PermissionSet> adminPermissionSets = [
            SELECT Name, Id
            FROM PermissionSet
            WHERE Name = 'Application_Admin' OR Name = 'Data_Mover_Staging_Tables_Access'
    ];

    List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();

    if (!adminPermissionSets.isEmpty()) {
        for (User u : [SELECT ID FROM User WHERE Profile.Name = 'System Administrator']) {
            permissionSetList.add(new PermissionSetAssignment(PermissionSetId = adminPermissionSets[0].Id, AssigneeId = u.Id));
        }
    }

    if (!permissionSetList.isEmpty()) {
        upsert permissionSetList;
    }
}

private static void setEASYCustomSettings() {

    Site mySite = [SELECT Id FROM Site WHERE Name = 'EASY_Applicant_Portal'];
    SiteDetail mySiteDetail = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :mySite.Id];
    String url = mySiteDetail.SecureURL;

    List<Profile> easyProfile = [
            SELECT Name, Id
            FROM Profile
            WHERE Name = 'EASY Applicant Portal Profile'
    ];

    List<PermissionSet> easyCommunityPermissionSet = [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name = 'Application_Community'
    ];

    Application_Setting__c applicationSettings = Application_Setting__c.getOrgDefaults();
    applicationSettings.Community_URL__c = url;

    if (easyProfile.size() > 0) {
        applicationSettings.Community_Profile_Ids__c = easyProfile[0].Id;
    }

    if (easyCommunityPermissionSet.size() > 0) {
        applicationSettings.Permission_Set_Id__c = easyCommunityPermissionSet[0].Id;
    }

    applicationSettings.Default_Template__c = 'stthomas2021';

    upsert applicationSettings;
}

private static void setUserRole() {
    List<User> userUsers = [SELECT Name FROM User WHERE Name = 'User User'];

    List<UserRole> roles = [SELECT Name, Id FROM UserRole WHERE Name = 'EASY Applicant'];

    if (userUsers.size() > 0) {
        if (roles.size() > 0) {
            userUsers[0].UserRoleId = roles[0].Id;
            update userUsers[0];
        }
    }
}

private static void setHierarchySettings() {
    hed__Hierarchy_Settings__c hierarchySettings = hed__Hierarchy_Settings__c.getOrgDefaults();
    hierarchySettings.hed__Admin_Account_Naming_Format__c = '{!LastName} Administrative Account';
    hierarchySettings.hed__Household_Account_Naming_Format__c = '{!LastName} ({!{!FirstName}}) Household';
    hierarchySettings.hed__Admin_Account_Naming_Format__c = '{!LastName} ({!{!FirstName}}) Administrative Account';
    upsert hierarchySettings;
}

private static void setReviewSettings() {
    insert new Related_Object_Review__c (Name = 'hed__Attribute__c');
    insert new Related_Object_Review__c (Name = 'hed__Contact_Language__c');
    insert new Related_Object_Review__c (Name = 'hed__Education_History__c');
    insert new Related_Object_Review__c (Name = 'hed__Test__c');
}
