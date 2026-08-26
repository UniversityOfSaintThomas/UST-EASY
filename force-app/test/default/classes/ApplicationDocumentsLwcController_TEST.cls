@IsTest
private class ApplicationDocumentsLwcController_TEST {

    @TestSetup
    static void setupTestData() {
        Application_Control__c appControl = new Application_Control__c(
            Name = 'Test Control',
            Application_Start_Status__c = Application_Control__c.Application_Start_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Active__c = true,
            Allow_Cancel_From__c = Application_Control__c.Allow_Cancel_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Allow_Withdraw_From__c = Application_Control__c.Allow_Withdraw_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Allow_Submit_From__c = Application_Control__c.Allow_Submit_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Cancel_Status__c = Application_Control__c.Cancel_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Default__c = true,
            URL_Parameter__c = 'test',
            Submit_Status__c = Application_Control__c.Submit_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Withdraw_Status__c = Application_Control__c.Withdraw_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Documents_To_Display_Keywords__c = 'UGTR_AdmissionLetter|Admission Letter;BSN_AdmissionLetter|Nursing Admission Letter'
        );
        insert appControl;

        Contact student = new Contact(
            LastName = 'TestStudent',
            FirstName = 'TestFirst',
            Email = 'test@email.com',
            University_Banner_ID__c = '111111111'
        );
        insert student;

        insert new Application__c(
            Contact__c = student.Id,
            Application_Status__c = Application__c.Application_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Application_Control__c = appControl.Id,
            Citizenship__c = 'U.S. Citizen',
            Generic_Filter_4__c = Application__c.Generic_Filter_4__c.getDescribe().getPicklistValues()[0].getValue()
        );
    }

    @IsTest
    static void applicationInformation_shouldReturnApplicationDetailsAndKeywords() {
        Application__c app = [
            SELECT Id, Generic_Filter_4__c, Application_Control__r.Documents_To_Display_Keywords__c
            FROM Application__c
            LIMIT 1
        ];

        Test.startTest();
        ApplicationDocumentsLwcController.ApplicationWrapper result = ApplicationDocumentsLwcController.applicationInformation(app.Id);
        Test.stopTest();

        System.assertEquals(app.Id, result.recordId);
        System.assertEquals(app.Generic_Filter_4__c, result.termName);
        System.assertEquals('Admission Letter', result.documentsToDisplayKeywords.get('UGTR_AdmissionLetter'));
        System.assertEquals('Nursing Admission Letter', result.documentsToDisplayKeywords.get('BSN_AdmissionLetter'));
    }

    @IsTest
    static void getDocumentsRecordId_shouldReturnMatchingContentVersions() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        ContentVersion version = new ContentVersion(
            Title = 'UGTR_AdmissionLetter_Final',
            PathOnClient = 'UGTR_AdmissionLetter_Final.pdf',
            VersionData = Blob.valueOf('test document')
        );
        insert version;

        ContentVersion insertedVersion = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :version.Id
            LIMIT 1
        ];

        insert new ContentDocumentLink(
            LinkedEntityId = app.Id,
            ContentDocumentId = insertedVersion.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        Map<String, String> titleKeywords = new Map<String, String>{
            'UGTR_AdmissionLetter' => 'Admission Letter'
        };

        Test.startTest();
        List<Map<String, String>> results = ApplicationDocumentsLwcController.getDocumentsRecordId(app.Id, titleKeywords);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(insertedVersion.ContentDocumentId, results[0].get('ContentDocumentId'));
        System.assertEquals('pdf', results[0].get('FileExtension'));
        System.assertEquals('UGTR_AdmissionLetter_Final', results[0].get('Title'));
        System.assertEquals(EncodingUtil.base64Encode(Blob.valueOf('test document')), results[0].get('VersionDataEncode'));
    }
}