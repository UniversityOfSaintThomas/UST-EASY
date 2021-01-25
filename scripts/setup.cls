private static void setHoldingIds() {
    String collegeRecordTypeId = null;
    String highSchoolRecordTypeId = null;
    List<RecordType> EducationRecordTypes = [
            SELECT Id, Name, SobjectType
            FROM RecordType
            WHERE SobjectType = 'hed__Education_History__c'
    ];
    for (RecordType recType : EducationRecordTypes) {
        if (recType.Name.equalsIgnoreCase('college')) {
            collegeRecordTypeId = recType.Id;
        } else if (recType.Name.equalsIgnoreCase('high school')) {
            highSchoolRecordTypeId = recType.Id;
        }
    }
    //College holding Ids in place
    Id collegeHolderId = null;
    List<Account> collegeHolders = [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'Unknown College'
    ];

    if (collegeHolders.size() > 0) {
        collegeHolderId = collegeHolders[0].Id;

        List<Requirement_Item__c> collegeRequirementItems = [
                SELECT Id, Name
                FROM Requirement_Item__c
                WHERE Name LIKE 'College%'
                AND Holding_Record_Id__c != ''
        ];
        for (Requirement_Item__c requirementItem : collegeRequirementItems) {
            requirementItem.Holding_Record_Id__c = collegeHolderId;
            if (collegeRecordTypeId != null) {
                requirementItem.Related_List_Where_Clause__c = '(RecordTypeId=\'' + collegeRecordTypeId + '\')';
            }
        }
        upsert collegeRequirementItems;
    }

    //High School holding Ids in place
    Id highSchoolHolderId = null;
    List<Account> highSchoolHolders = [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'Unknown High School'
    ];
    if (highSchoolHolders.size() > 0) {
        highSchoolHolderId = highSchoolHolders[0].Id;

        List<Requirement_Item__c> collegeRequirementItems = [
                SELECT Id, Name, Related_List_Where_Clause__c
                FROM Requirement_Item__c
                WHERE Name LIKE 'High School%'
                AND Holding_Record_Id__c != ''
        ];
        for (Requirement_Item__c requirementItem : collegeRequirementItems) {
            requirementItem.Holding_Record_Id__c = highSchoolHolderId;
            if (highSchoolRecordTypeId != null) {
                requirementItem.Related_List_Where_Clause__c = '(RecordTypeId=\'' + highSchoolRecordTypeId + '\')';
            }
        }
        upsert collegeRequirementItems;
    }

    //Language holding Ids in place
    Id languageHolderId = null;
    List<hed__Language__c> languageHolders = [
            SELECT Id, Name
            FROM hed__Language__c
            WHERE Name = 'English'
    ];
    if (languageHolders.size() > 0) {
        languageHolderId = languageHolders[0].Id;

        List<Requirement_Item__c> languageRequirementItems = [
                SELECT Id, Name
                FROM Requirement_Item__c
                WHERE Name LIKE 'Language%'
                AND Holding_Record_Id__c != ''
        ];
        for (Requirement_Item__c requirementItem : languageRequirementItems) {
            requirementItem.Holding_Record_Id__c = languageHolderId;
        }
        upsert languageRequirementItems;
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
            WHERE Name = 'Application_Admin'
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
    Site site = [
            SELECT GuestUserId
            FROM Site
            WHERE Name = 'EASY_Applicant_Portal'
    ];

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

    String path = '/sites/servlet.SiteDebugMode';
    PageReference pr = new PageReference(path);
    pr.getParameters().put('guid', site.GuestUserId);
    pr.getParameters().put('sitedebugmode', 'x');
    String url = pr.getContent().toString().substringAfter('URL=').substringBefore(path);

    Application_Setting__c applicationSettings = Application_Setting__c.getOrgDefaults();
    applicationSettings.Community_URL__c = url;

    if (easyProfile.size() > 0) {
        applicationSettings.Community_Profile_Ids__c = easyProfile[0].Id;
    }

    if (easyCommunityPermissionSet.size() > 0) {
        applicationSettings.Permission_Set_Id__c = easyCommunityPermissionSet[0].Id;
    }

    upsert applicationSettings;
}

private static void setUserRole() {
    List<User> userUsers = [SELECT Name FROM User WHERE Name = 'User User'];

    List<UserRole> roles = [SELECT Name, Id FROM UserRole WHERE Name = 'EASY Applicant'];

    List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Application_Community'];

    if (userUsers.size() > 0) {
        if (roles.size() > 0) {
            userUsers[0].UserRoleId = roles[0].Id;
            if (permissionSets.size() > 0) {
                userUsers[0].Community_Permissions__c = permissionSets[0].Id;
            }
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
    insert new Related_Object_Review__c (Name='hed__Attribute__c');
    insert new Related_Object_Review__c (Name='hed__Contact_Language__c');
    insert new Related_Object_Review__c (Name='hed__Education_History__c');
    insert new Related_Object_Review__c (Name='hed__Test__c');
}

private static void turnOnCommunityTrigger() {
    hed__Trigger_Handler__c permissionTrigger = new hed__Trigger_Handler__c();
    permissionTrigger.Name = 'User Community Permissions';
    permissionTrigger.hed__Active__c = true;
    permissionTrigger.hed__Class__c = 'User_Community_Permission_TDTM';
    permissionTrigger.hed__Load_Order__c = 2.0;
    permissionTrigger.hed__Object__c = 'User';
    permissionTrigger.hed__Trigger_Action__c = 'AfterInsert;AfterUpdate';
    insert permissionTrigger;
}