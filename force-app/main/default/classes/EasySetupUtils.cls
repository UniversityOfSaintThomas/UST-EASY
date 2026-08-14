public class EasySetupUtils {

    // Maps each 'Related Object' Requirement_Item__c category to the RecordType it targets.
    // Only categories whose related list is filtered by RecordTypeId need an entry here;
    // categories that only need a holding record (e.g. Recommendation, Work History) don't.
    // NOTE: Parent/Guardian and Sibling requirement items relate to Family_Member__c, a
    // separate object from Family__c with its own RecordTypeIds - using Family__c's ids here
    // was a pre-existing bug that produced RecordTypeIds that don't match any Family_Member__c record.
    private static Map<String, Id> relatedObjectRecordTypeIdsByCategory() {
        return new Map<String, Id>{
                'College' => Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get('College').getRecordTypeId(),
                'High School' => Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get('High School').getRecordTypeId(),
                'Parent/Guardian' => Schema.SObjectType.Family_Member__c.getRecordTypeInfosByName().get('Parent/Guardian').getRecordTypeId(),
                'Sibling' => Schema.SObjectType.Family_Member__c.getRecordTypeInfosByName().get('Sibling').getRecordTypeId()
        };
    }

    // Name prefix of the holding Account for each category. Every category that needs a
    // Holding_Record_Id__c belongs here, whether or not it also has a RecordType entry above.
    private static final Map<String, String> HOLDING_ACCOUNT_NAME_PREFIX_BY_CATEGORY = new Map<String, String>{
            'College' => 'Unknown College',
            'High School' => 'Unknown High School',
            'Parent/Guardian' => 'Unknown Parent/Guardian',
            'Sibling' => 'Unknown Sibling',
            'Recommendation' => 'Unknown Recommender',
            'Work History' => 'Unknown Work History',
            'External Course Connection' => 'Unknown External Course Connection'
    };

    public static void setHoldingIds() {
        Map<String, Id> recordTypeIdsByCategory = relatedObjectRecordTypeIdsByCategory();

        Map<String, Id> holdingAccountIdByCategory = new Map<String, Id>();
        for (Account holdingAccount : [SELECT Id, Name FROM Account WHERE Name LIKE 'Unknown%']) {
            for (String category : HOLDING_ACCOUNT_NAME_PREFIX_BY_CATEGORY.keySet()) {
                String prefix = HOLDING_ACCOUNT_NAME_PREFIX_BY_CATEGORY.get(category);
                if (!holdingAccountIdByCategory.containsKey(category) && holdingAccount.Name.startsWith(prefix)) {
                    holdingAccountIdByCategory.put(category, holdingAccount.Id);
                }
            }
        }

        List<Requirement_Item__c> updateItems = new List<Requirement_Item__c>();

        // categorizeRelatedObjectItem() returns null for a handful of known stale/ambiguous
        // records (e.g. items referencing the non-namespaced legacy "Education_History__c"
        // object, which doesn't exist in this org) - those are intentionally left untouched.
        for (Requirement_Item__c item : [
                SELECT Id, Name, Label__c, Related_List_Object__c
                FROM Requirement_Item__c
                WHERE RecordType.Name = 'Related Object'
        ]) {
            String category = categorizeRelatedObjectItem(item);
            if (category == null) {
                continue;
            }

            if (recordTypeIdsByCategory.containsKey(category)) {
                Id recordTypeId = recordTypeIdsByCategory.get(category);
                item.Related_Object_Record_Type_ID__c = recordTypeId;
                item.Related_List_Where_Clause__c = '(RecordTypeId=\'' + recordTypeId + '\')';
            }

            if (holdingAccountIdByCategory.containsKey(category)) {
                item.Holding_Record_Id__c = holdingAccountIdByCategory.get(category);
            }
            updateItems.add(item);
        }

        List<hed__Language__c> englishHolders = [SELECT Id FROM hed__Language__c WHERE Name = 'English' LIMIT 1];
        if (!englishHolders.isEmpty()) {
            for (Requirement_Item__c item : [SELECT Id FROM Requirement_Item__c WHERE Name LIKE 'Language%']) {
                item.Holding_Record_Id__c = englishHolders[0].Id;
                updateItems.add(item);
            }
        }

        if (!updateItems.isEmpty()) {
            update updateItems;
        }
    }

    private static String categorizeRelatedObjectItem(Requirement_Item__c item) {
        String relatedObject = item.Related_List_Object__c;

        if (relatedObject == 'hed__Education_History__c') {
            if (item.Label__c != null && item.Label__c.contains('College')) {
                return 'College';
            }
            if (item.Label__c != null && item.Label__c.contains('High School')) {
                return 'High School';
            }
            return null;
        }

        if (relatedObject == 'Family_Member__c') {
            if (item.Name != null && item.Name.contains('Sibling')) {
                return 'Sibling';
            }
            if (item.Name != null && item.Name.contains('Parent') && item.Name.contains('Guardian')) {
                return 'Parent/Guardian';
            }
            return null;
        }

        if (relatedObject == 'Recommendation__c') {
            return 'Recommendation';
        }
        if (relatedObject == 'Work_History__c') {
            return 'Work History';
        }
        if (relatedObject == 'External_Course_Connection__c') {
            return 'External Course Connection';
        }

        return null;
    }

    public static void permissionGuestUser() {
        Site site = [
                SELECT GuestUserId
                FROM Site
                WHERE Name = 'EASY_Applicant_Portal'
        ];

        List<PermissionSet> guestPermissionSets = [
                SELECT Name, Id
                FROM PermissionSet
                WHERE Name = 'Application_Community_Guest'
                OR Name = 'RFI_User'
                OR Name = 'Graduate_Recommender'
                OR Name = 'Scholarship_Recommenders'
        ];

        List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet permission : guestPermissionSets) {
            newAssignments.add(new PermissionSetAssignment(PermissionSetId = permission.Id, AssigneeId = site.GuestUserId));
        }

        insertMissingPermissionSetAssignments(newAssignments);
    }

    public static void permissionAdminUser() {
        List<PermissionSet> adminPermissionSets = [
                SELECT Name, Id
                FROM PermissionSet
                WHERE Name = 'Application_Admin' OR Name = 'Data_Mover_Staging_Tables_Access'
        ];

        List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
        for (User u : [SELECT Id FROM User WHERE Profile.Name = 'System Administrator']) {
            for (PermissionSet permission : adminPermissionSets) {
                newAssignments.add(new PermissionSetAssignment(PermissionSetId = permission.Id, AssigneeId = u.Id));
            }
        }

        insertMissingPermissionSetAssignments(newAssignments);
    }

    // PermissionSetAssignment enforces uniqueness on (PermissionSetId, AssigneeId) and has no
    // external id to upsert against, so re-running a task that assigns permission sets already
    // held by the assignee would otherwise throw DUPLICATE_VALUE. Filter those out first so the
    // setup tasks are safe to re-run against an org that's already been through setup.
    private static void insertMissingPermissionSetAssignments(List<PermissionSetAssignment> candidateAssignments) {
        if (candidateAssignments.isEmpty()) {
            return;
        }

        Set<Id> permissionSetIds = new Set<Id>();
        Set<Id> assigneeIds = new Set<Id>();
        for (PermissionSetAssignment candidate : candidateAssignments) {
            permissionSetIds.add(candidate.PermissionSetId);
            assigneeIds.add(candidate.AssigneeId);
        }

        Set<String> existingKeys = new Set<String>();
        for (PermissionSetAssignment existing : [
                SELECT PermissionSetId, AssigneeId
                FROM PermissionSetAssignment
                WHERE PermissionSetId IN :permissionSetIds
                AND AssigneeId IN :assigneeIds
        ]) {
            existingKeys.add(existing.PermissionSetId + ':' + existing.AssigneeId);
        }

        List<PermissionSetAssignment> assignmentsToInsert = new List<PermissionSetAssignment>();
        for (PermissionSetAssignment candidate : candidateAssignments) {
            if (!existingKeys.contains(candidate.PermissionSetId + ':' + candidate.AssigneeId)) {
                assignmentsToInsert.add(candidate);
            }
        }

        if (!assignmentsToInsert.isEmpty()) {
            insert assignmentsToInsert;
        }
    }

    public static void setEASYCustomSettings() {

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

    public static void setUserRole() {
        List<User> userUsers = [SELECT Name FROM User WHERE Name = 'User User'];
        List<UserRole> roles = [SELECT Name, Id FROM UserRole WHERE Name = 'EASY Applicant'];

        if (userUsers.isEmpty()) {
            return;
        }

        userUsers[0].Country = 'United States';
        if (!roles.isEmpty()) {
            userUsers[0].UserRoleId = roles[0].Id;
        }
        update userUsers[0];
    }

    public static void setHierarchySettings() {
        hed__Hierarchy_Settings__c hierarchySettings = hed__Hierarchy_Settings__c.getOrgDefaults();
        hierarchySettings.hed__Household_Account_Naming_Format__c = '{!LastName} ({!{!FirstName}}) Household';
        hierarchySettings.hed__Admin_Account_Naming_Format__c = '{!LastName} ({!{!FirstName}}) Administrative Account';
        upsert hierarchySettings;
    }

    // Related_Object_Review__c is a List custom setting where Name is the unique key, but
    // upsert only dedupes on Id (blank here) - not Name - so re-running this without first
    // checking for existing rows throws FIELD_INTEGRITY_EXCEPTION on a second run.
    public static void setReviewSettings() {
        Set<String> reviewedObjectNames = new Set<String>{
                'hed__Attribute__c', 'hed__Contact_Language__c', 'hed__Education_History__c', 'hed__Test__c'
        };

        Set<String> existingNames = new Set<String>();
        for (Related_Object_Review__c existingReview : [SELECT Name FROM Related_Object_Review__c WHERE Name IN :reviewedObjectNames]) {
            existingNames.add(existingReview.Name);
        }

        List<Related_Object_Review__c> newReviews = new List<Related_Object_Review__c>();
        for (String objectName : reviewedObjectNames) {
            if (!existingNames.contains(objectName)) {
                newReviews.add(new Related_Object_Review__c(Name = objectName));
            }
        }

        if (!newReviews.isEmpty()) {
            insert newReviews;
        }
    }
}
