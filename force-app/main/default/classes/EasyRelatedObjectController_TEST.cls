/*******************************************************************************
 * @description Test class for EasyRelatedObjectController.
 *              Uses Family__c as the related object. Its Application__c field
 *              is a Master-Detail to Application__c (always required).
 * @author UST
 *******************************************************************************/
@IsTest(SeeAllData=false)
private class EasyRelatedObjectController_TEST {

    // =========================================================================
    // TEST SETUP
    // =========================================================================

    @TestSetup
    static void makeData() {
        // Application_Control is required for Application__c
        Application_Control__c appControl = new Application_Control__c(
            Application_Start_Status__c = Application_Control__c.Application_Start_Status__c
                .getDescribe().getPicklistValues()[0].getValue(),
            Active__c = true,
            Allow_Cancel_From__c = Application_Control__c.Allow_Cancel_From__c
                .getDescribe().getPicklistValues()[0].getValue(),
            Allow_Withdraw_From__c = Application_Control__c.Allow_Withdraw_From__c
                .getDescribe().getPicklistValues()[0].getValue(),
            Allow_Submit_From__c = Application_Control__c.Allow_Submit_From__c
                .getDescribe().getPicklistValues()[0].getValue(),
            Cancel_Status__c = Application_Control__c.Cancel_Status__c
                .getDescribe().getPicklistValues()[0].getValue(),
            Default__c = true,
            URL_Parameter__c = 'ero-test',
            Submit_Status__c = Application_Control__c.Submit_Status__c
                .getDescribe().getPicklistValues()[0].getValue(),
            Withdraw_Status__c = Application_Control__c.Withdraw_Status__c
                .getDescribe().getPicklistValues()[0].getValue()
        );
        insert appControl;

        Contact student = new Contact(
            FirstName = 'EROTest',
            LastName = 'Student',
            Email = 'erotest@student-erotest.invalid'
        );
        insert student;

        Application__c app = new Application__c(
            Contact__c = student.Id,
            Application_Control__c = appControl.Id,
            Application_Status__c = appControl.Application_Start_Status__c
        );
        insert app;

        Requirement__c req = new Requirement__c(
            Application_Control__c = appControl.Id,
            Active__c = true,
            Name = 'EROTest Req',
            Requirement_Integration_External_Id__c = ApplicationUtilities.getUUID()
        );
        insert req;

        Map<String, Id> requirementItemRecordTypesByDeveloperName = new Map<String, Id>();
        for (RecordType recordType : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Requirement_Item__c']) {
            requirementItemRecordTypesByDeveloperName.put(recordType.DeveloperName, recordType.Id);
        }

        // Primary test Requirement_Item using Family__c as the related object.
        // Family__c.Application__c is a Master-Detail, so the master is Application (not Contact).
        Requirement_Item__c relatedObjectItem = new Requirement_Item__c(
            Requirement__c = req.Id,
            Name = 'EROTest RI Family',
            Active__c = true,
            RecordTypeId = requirementItemRecordTypesByDeveloperName.get('Related_Object'),
            Requirement_Item_Integration_Ext_Id__c = ApplicationUtilities.getUUID(),
            Related_List_Object__c = 'Family__c',
            Related_List_Object_Master__c = 'Application',
            Related_List_Object_Master_Field__c = 'Application__c',
            Required_Number_of_Children__c = 1,
            Maximum_Number_of_Children__c = 3,
            File_Name_Prefix__c = 'TEST_FAMILY_DOC'
        );
        insert relatedObjectItem;

        Map<String, Id> questionRecordTypesByDeveloperName = new Map<String, Id>();
        for (RecordType recordType : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Question__c']) {
            questionRecordTypesByDeveloperName.put(recordType.DeveloperName, recordType.Id);
        }

        // Text question mapped to First_Name__c on Family__c
        Question__c firstNameQuestion = new Question__c(
            Active__c = true,
            RecordTypeId = questionRecordTypesByDeveloperName.get('Text'),
            Name = 'EROTest Q First Name',
            Label__c = 'First Name',
            Requirement_Item__c = relatedObjectItem.Id,
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID(),
            Related_Object_Field__c = 'First_Name__c',
            New_Reference_Field__c = false,
            Display_Order__c = 1
        );
        // Text question with a hardcoded value (set automatically on insert, never on update)
        Question__c hardcodedQuestion = new Question__c(
            Active__c = true,
            RecordTypeId = questionRecordTypesByDeveloperName.get('Text'),
            Name = 'EROTest Q Last Name Hardcoded',
            Label__c = 'Last Name (Auto)',
            Requirement_Item__c = relatedObjectItem.Id,
            Question_Integration_External_Id__c = ApplicationUtilities.getUUID(),
            Related_Object_Field__c = 'Last_Name__c',
            New_Reference_Field__c = false,
            Hardcoded_Value__c = 'AutoLastName',
            Display_Order__c = 2
        );
        insert new List<Question__c>{ firstNameQuestion, hardcodedQuestion };

        // Requirement_Response linking the item to the application
        Requirement_Response__c requirementResponse = new Requirement_Response__c(
            Application__c = app.Id,
            Requirement_Item__c = relatedObjectItem.Id
        );
        insert requirementResponse;

        // Pre-existing Family__c record. Application__c is a Master-Detail — always required.
        Family__c existingFamilyMember = new Family__c(
            Application__c = app.Id,
            Contact__c = student.Id,
            First_Name__c = 'PreExisting',
            Last_Name__c = 'FamilyMember',
            User_Created__c = true
        );
        insert existingFamilyMember;
    }

    // =========================================================================
    // HELPER METHODS
    // =========================================================================

    /** @return The EROTest Requirement_Item__c */
    private static Requirement_Item__c getTestRequirementItem() {
        return [SELECT Id, Name FROM Requirement_Item__c WHERE Name = 'EROTest RI Family' LIMIT 1];
    }

    /** @return The test Application__c */
    private static Application__c getTestApplication() {
        return [SELECT Id, Contact__c FROM Application__c WHERE Application_Control__r.URL_Parameter__c = 'ero-test' LIMIT 1];
    }

    // =========================================================================
    // getRequirementItemConfig TESTS
    // =========================================================================

    @IsTest
    static void givenValidRequirementItemId_whenGetConfig_thenReturnsConfigWithQuestions() {
        Requirement_Item__c item = getTestRequirementItem();

        Test.startTest();
        EasyRelatedObjectController.RequirementItemConfigDTO config =
            EasyRelatedObjectController.getRequirementItemConfig(item.Id);
        Test.stopTest();

        Assert.areEqual(item.Id, config.requirementItemId, 'requirementItemId should match');
        Assert.areEqual('Family__c', config.relatedObjectApiName, 'relatedObjectApiName should be Family__c');
        Assert.areEqual('Application', config.masterObjectType, 'masterObjectType should be Application');
        Assert.areEqual('Application__c', config.masterFieldApiName, 'masterFieldApiName should be Application__c');
        Assert.isTrue(config.questions.size() >= 2, 'Should have at least 2 questions');
        Assert.isTrue(config.requiredChildCount == 1, 'requiredChildCount should be 1');
    }

    @IsTest
    static void givenBlankRequirementItemId_whenGetConfig_thenThrowsAuraHandledException() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            EasyRelatedObjectController.getRequirementItemConfig('');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, 'Should throw AuraHandledException for blank requirementItemId');
    }

    @IsTest
    static void givenInvalidRequirementItemId_whenGetConfig_thenThrowsAuraHandledException() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            EasyRelatedObjectController.getRequirementItemConfig('badId');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, 'Should throw AuraHandledException for invalid Id');
    }

    // =========================================================================
    // getExistingRelatedRecords TESTS
    // =========================================================================

    @IsTest
    static void givenExistingRecords_whenGetExistingRelatedRecords_thenReturnsRecords() {
        Requirement_Item__c item = getTestRequirementItem();
        Application__c app = getTestApplication();

        Test.startTest();
        List<EasyRelatedObjectController.RelatedRecordDTO> records =
            EasyRelatedObjectController.getExistingRelatedRecords(item.Id, app.Id);
        Test.stopTest();

        Assert.isTrue(records.size() >= 1, 'Should return at least the pre-existing Family__c record');
        EasyRelatedObjectController.RelatedRecordDTO firstRecord = records[0];
        Assert.isNotNull(firstRecord.recordId, 'Record Id should not be null');
        Assert.isNotNull(firstRecord.fieldValues, 'fieldValues map should not be null');
    }

    @IsTest
    static void givenBlankApplicationId_whenGetExistingRelatedRecords_thenThrowsAuraHandledException() {
        Requirement_Item__c item = getTestRequirementItem();
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            EasyRelatedObjectController.getExistingRelatedRecords(item.Id, '');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, 'Should throw AuraHandledException for blank applicationId');
    }

    // =========================================================================
    // saveRelatedRecord TESTS
    // =========================================================================

    @IsTest
    static void givenValidFieldValues_whenSaveNewRecord_thenInsertsRecordAndUpdatesFulfillment() {
        Requirement_Item__c item = getTestRequirementItem();
        Application__c app = getTestApplication();

        Map<String, Object> fieldValues = new Map<String, Object>{
            'First_Name__c' => 'NewFirst'
        };
        String fieldValuesJson = JSON.serialize(fieldValues);

        Test.startTest();
        EasyRelatedObjectController.SaveResultDTO result =
            EasyRelatedObjectController.saveRelatedRecord(item.Id, app.Id, fieldValuesJson, null);
        Test.stopTest();

        Assert.isNotNull(result.savedRecordId, 'savedRecordId should not be null after insert');
        List<Family__c> insertedRecords = [SELECT Id, First_Name__c, Last_Name__c, User_Created__c
                                           FROM Family__c WHERE Id = :result.savedRecordId];
        Assert.areEqual(1, insertedRecords.size(), 'Exactly one Family__c should have been inserted');
        Assert.areEqual('NewFirst', insertedRecords[0].First_Name__c, 'First_Name__c should match submitted value');
        Assert.areEqual('AutoLastName', insertedRecords[0].Last_Name__c, 'Hardcoded Last_Name__c should be set automatically');
        Assert.isTrue(insertedRecords[0].User_Created__c, 'User_Created__c must be true');
        // Requirement is fulfilled: 2 records (preexisting + new) >= required 1
        Assert.isTrue(result.requirementFulfilled, 'Requirement should be fulfilled after 2 records exist');
    }

    @IsTest
    static void givenExistingRecordId_whenSaveRecord_thenUpdatesRecord() {
        Requirement_Item__c item = getTestRequirementItem();
        Application__c app = getTestApplication();

        Family__c existingRecord = [SELECT Id FROM Family__c WHERE First_Name__c = 'PreExisting' LIMIT 1];

        Map<String, Object> fieldValues = new Map<String, Object>{
            'First_Name__c' => 'UpdatedFirst'
        };
        String fieldValuesJson = JSON.serialize(fieldValues);

        Test.startTest();
        EasyRelatedObjectController.SaveResultDTO result =
            EasyRelatedObjectController.saveRelatedRecord(item.Id, app.Id, fieldValuesJson, existingRecord.Id);
        Test.stopTest();

        Assert.areEqual(String.valueOf(existingRecord.Id), result.savedRecordId, 'savedRecordId should be the updated record Id');
        Family__c updatedRecord = [SELECT First_Name__c FROM Family__c WHERE Id = :existingRecord.Id];
        Assert.areEqual('UpdatedFirst', updatedRecord.First_Name__c, 'First_Name__c should be updated');
    }

    @IsTest
    static void givenBlankFieldValuesJson_whenSaveRecord_thenThrowsAuraHandledException() {
        Requirement_Item__c item = getTestRequirementItem();
        Application__c app = getTestApplication();
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            EasyRelatedObjectController.saveRelatedRecord(item.Id, app.Id, '', null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, 'Should throw AuraHandledException when fieldValuesJson is blank');
    }

    // =========================================================================
    // deleteRelatedRecord TESTS
    // =========================================================================

    @IsTest
    static void givenValidRecord_whenDeleteRelatedRecord_thenDeletesAndUpdatesFulfillment() {
        Requirement_Item__c item = getTestRequirementItem();
        Application__c app = getTestApplication();
        Family__c existingRecord = [SELECT Id FROM Family__c WHERE First_Name__c = 'PreExisting' LIMIT 1];

        Test.startTest();
        Boolean fulfilled = EasyRelatedObjectController.deleteRelatedRecord(existingRecord.Id, item.Id, app.Id);
        Test.stopTest();

        List<Family__c> remainingRecords = [SELECT Id FROM Family__c WHERE Id = :existingRecord.Id];
        Assert.isTrue(remainingRecords.isEmpty(), 'Record should be deleted');
        // 0 records remaining < required 1, so requirement is NOT fulfilled
        Assert.isFalse(fulfilled, 'Requirement should not be fulfilled after deleting the only record');
    }

    @IsTest
    static void givenWrongApplicationRecord_whenDeleteRelatedRecord_thenThrowsAuraHandledException() {
        Requirement_Item__c item = getTestRequirementItem();

        // Create a second application so we can insert a Family__c under it
        Application_Control__c appControl =
            [SELECT Id FROM Application_Control__c WHERE URL_Parameter__c = 'ero-test' LIMIT 1];
        Contact otherContact = new Contact(LastName = 'OtherTestContact');
        insert otherContact;
        Application__c otherApp = new Application__c(
            Contact__c = otherContact.Id,
            Application_Control__c = appControl.Id
        );
        insert otherApp;

        // Family__c.Application__c is Master-Detail, so this record belongs to otherApp, not the test app
        Family__c unrelatedFamilyMember = new Family__c(
            Application__c = otherApp.Id,
            First_Name__c = 'Unrelated',
            User_Created__c = true
        );
        insert unrelatedFamilyMember;

        Application__c app = getTestApplication();
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            EasyRelatedObjectController.deleteRelatedRecord(unrelatedFamilyMember.Id, item.Id, app.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Deleting a record from a different application should throw AuraHandledException');
    }

    @IsTest
    static void givenBlankRecordId_whenDeleteRelatedRecord_thenThrowsAuraHandledException() {
        Requirement_Item__c item = getTestRequirementItem();
        Application__c app = getTestApplication();
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            EasyRelatedObjectController.deleteRelatedRecord('', item.Id, app.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, 'Should throw AuraHandledException for blank recordId');
    }

    // =========================================================================
    // uploadSupportingDocument TESTS
    // =========================================================================

    @IsTest
    static void givenValidFileData_whenUploadSupportingDocument_thenCreatesContentVersion() {
        Requirement_Item__c item = getTestRequirementItem();
        Family__c existingRecord = [SELECT Id FROM Family__c WHERE First_Name__c = 'PreExisting' LIMIT 1];

        String base64Data = 'data:text/plain;base64,' + EncodingUtil.base64Encode(Blob.valueOf('test file content'));

        Test.startTest();
        String contentVersionId = EasyRelatedObjectController.uploadSupportingDocument(
            existingRecord.Id,
            item.Id,
            'testdoc.txt',
            base64Data
        );
        Test.stopTest();

        Assert.isNotNull(contentVersionId, 'ContentVersion Id should not be null');
        List<ContentVersion> createdDocuments = [
            SELECT Id, Title, Description
            FROM ContentVersion
            WHERE Id = :contentVersionId
        ];
        Assert.areEqual(1, createdDocuments.size(), 'ContentVersion should have been created');
        Assert.areEqual('Supporting Document', createdDocuments[0].Description, 'Description should be Supporting Document');
        // File_Name_Prefix__c = 'TEST_FAMILY_DOC', so title should be 'TEST_FAMILY_DOC.txt'
        Assert.isTrue(createdDocuments[0].Title.startsWith('TEST_FAMILY_DOC'), 'Title should use the configured prefix');
    }

    @IsTest
    static void givenBlankFileName_whenUploadSupportingDocument_thenThrowsAuraHandledException() {
        Family__c existingRecord = [SELECT Id FROM Family__c WHERE First_Name__c = 'PreExisting' LIMIT 1];
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            EasyRelatedObjectController.uploadSupportingDocument(
                existingRecord.Id,
                null,
                '',
                'data:text/plain;base64,dGVzdA=='
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, 'Should throw AuraHandledException for blank fileName');
    }

    // =========================================================================
    // BULK PATH TEST
    // =========================================================================

    @IsTest
    static void givenManyRecords_whenGetExistingRelatedRecords_thenHandlesBulkLoad() {
        Requirement_Item__c item = getTestRequirementItem();
        Application__c app = getTestApplication();

        // Insert 200 additional Family__c records under the same application
        List<Family__c> bulkFamilyMembers = new List<Family__c>();
        for (Integer index = 0; index < 200; index++) {
            bulkFamilyMembers.add(new Family__c(
                Application__c = app.Id,
                First_Name__c = 'Bulk' + index,
                User_Created__c = true
            ));
        }
        insert bulkFamilyMembers;

        Test.startTest();
        List<EasyRelatedObjectController.RelatedRecordDTO> results =
            EasyRelatedObjectController.getExistingRelatedRecords(item.Id, app.Id);
        Test.stopTest();

        // Should return at least 200 records (200 bulk + 1 preexisting)
        Assert.isTrue(results.size() >= 200, 'Should return at least 200 records from bulk insert');
    }
}