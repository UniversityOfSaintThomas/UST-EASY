/**
 * AuraEnabled controller for the easyDocumentUpload LWC.
 * Handles document upload config retrieval, file save, text-entry save, and file deletion
 * for Document_Upload type Requirement Items embedded via Lightning Out.
 *
 * Uses without sharing so guest/community applicants can read and write their own
 * Requirement_Response__c, ContentVersion, and Supporting_Document__c records.
 */
public without sharing class EasyDocumentUploadController {

    // ─── Inner DTOs ───────────────────────────────────────────────────────────

    /**
     * All state the LWC needs for a single document-upload requirement item.
     */
    public class DocumentUploadConfig {
        /** Requirement_Response__c.Id (null if no response yet) */
        @AuraEnabled public String responseId;
        /** Whether the item supports rich-text entry in addition to / instead of a file */
        @AuraEnabled public Boolean allowTextEntry;
        /** Semicolon-separated accepted file extensions, e.g. "PDF;DOCX;DOC" */
        @AuraEnabled public String acceptedFileTypes;
        /** True when the item is required for the current application status */
        @AuraEnabled public Boolean isRequired;
        /** Original file name shown to the applicant */
        @AuraEnabled public String existingFileName;
        /** ContentVersion.Id of the most recent version (for download link) */
        @AuraEnabled public String existingFileVersionId;
        /** ContentDocument.Id of the existing attachment (for delete) */
        @AuraEnabled public String existingContentDocumentId;
        /** Current rich-text / plain-text entry value */
        @AuraEnabled public String textEntryValue;
        /** True when a file or text entry has been saved */
        @AuraEnabled public Boolean hasDocument;
    }

    // ─── Public AuraEnabled Methods ───────────────────────────────────────────

    /**
     * Returns DocumentUploadConfig for the given requirement item and application.
     *
     * @param requirementItemId  Id of the Requirement_Item__c (Document_Upload record type)
     * @param applicationId      Id of the Admissions_Application__c
     * @param applicationStatus  Current Application_Status__c value, used to evaluate Required__c
     * @return DocumentUploadConfig populated with current state
     */
    @AuraEnabled
    public static DocumentUploadConfig getDocumentUploadConfig(
        String requirementItemId,
        String applicationId,
        String applicationStatus
    ) {
        DocumentUploadConfig config = new DocumentUploadConfig();

        List<Requirement_Item__c> items = [
            SELECT Allow_Text_Entry__c, File_Types__c, Required__c
            FROM Requirement_Item__c
            WHERE Id = :requirementItemId
            WITH USER_MODE
            LIMIT 1
        ];
        if (items.isEmpty()) {
            throw new AuraHandledException('Requirement item not found.');
        }
        Requirement_Item__c item = items[0];

        config.allowTextEntry = item.Allow_Text_Entry__c;
        config.acceptedFileTypes = item.File_Types__c;
        config.isRequired = String.isNotBlank(item.Required__c)
            && String.isNotBlank(applicationStatus)
            && item.Required__c.containsIgnoreCase(applicationStatus);

        List<Requirement_Response__c> responses = [
            SELECT Id, HasDocument__c, ValueTextEntry__c,
                   Original_Uploaded_Document_File_Name__c,
                   (SELECT ContentDocument.Title, ContentDocumentId, Id
                    FROM ContentDocumentLinks
                    LIMIT 1)
            FROM Requirement_Response__c
            WHERE Requirement_Item__c = :requirementItemId
            AND Application__c = :applicationId
            WITH USER_MODE
            LIMIT 1
        ];

        config.hasDocument = false;
        if (!responses.isEmpty()) {
            Requirement_Response__c response = responses[0];
            config.responseId = response.Id;
            config.textEntryValue = response.ValueTextEntry__c;
            config.hasDocument = response.HasDocument__c == true;

            if (!response.ContentDocumentLinks.isEmpty()) {
                ContentDocumentLink link = response.ContentDocumentLinks[0];
                config.existingFileName = String.isNotBlank(response.Original_Uploaded_Document_File_Name__c)
                    ? response.Original_Uploaded_Document_File_Name__c
                    : link.ContentDocument.Title;
                config.existingContentDocumentId = link.ContentDocumentId;

                List<ContentVersion> versions = [
                    SELECT Id
                    FROM ContentVersion
                    WHERE ContentDocumentId = :link.ContentDocumentId
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
                if (!versions.isEmpty()) {
                    config.existingFileVersionId = versions[0].Id;
                }
            }
        }

        return config;
    }

    /**
     * Saves an uploaded file as a ContentVersion linked to the requirement response,
     * and optionally creates Supporting_Document__c / ContentDocumentLink records.
     * Returns the refreshed DocumentUploadConfig.
     *
     * @param requirementItemId  Id of the Requirement_Item__c
     * @param applicationId      Id of the Admissions_Application__c
     * @param fileName           Original file name (e.g. "transcript.pdf")
     * @param base64Data         Data URL from FileReader.readAsDataURL (includes data:...;base64, prefix)
     * @param applicationStatus  Current Application_Status__c value
     * @return Refreshed DocumentUploadConfig
     */
    @AuraEnabled
    public static DocumentUploadConfig saveDocumentFile(
        String requirementItemId,
        String applicationId,
        String fileName,
        String base64Data,
        String applicationStatus
    ) {
        List<Requirement_Item__c> items = [
            SELECT File_Name_Prefix__c, Uploaded_Document_Object__c,
                   Uploaded_Document_Type__c, Uploaded_Document_Source__c, File_Types__c
            FROM Requirement_Item__c
            WHERE Id = :requirementItemId
            WITH USER_MODE
            LIMIT 1
        ];
        if (items.isEmpty()) {
            throw new AuraHandledException('Requirement item not found.');
        }
        Requirement_Item__c item = items[0];

        validateFileType(fileName, item.File_Types__c);

        // Find or create the requirement response
        List<Requirement_Response__c> responses = [
            SELECT Id,
                   (SELECT ContentDocumentId
                    FROM ContentDocumentLinks
                    LIMIT 1)
            FROM Requirement_Response__c
            WHERE Requirement_Item__c = :requirementItemId
            AND Application__c = :applicationId
            WITH USER_MODE
            LIMIT 1
        ];

        Requirement_Response__c response;
        if (responses.isEmpty()) {
            response = new Requirement_Response__c(
                Requirement_Item__c = requirementItemId,
                Application__c = applicationId
            );
            insert response;
        } else {
            response = responses[0];
            // Delete previous attachment before inserting the new one
            if (!response.ContentDocumentLinks.isEmpty()) {
                try {
                    delete new ContentDocument(Id = response.ContentDocumentLinks[0].ContentDocumentId);
                } catch (Exception deleteError) {
                    System.debug('Could not delete previous document: ' + deleteError.getMessage());
                }
            }
        }

        // Determine saved file name (apply prefix when configured)
        String originalFileName = fileName;
        String savedFileName = fileName;
        if (String.isNotBlank(item.File_Name_Prefix__c)) {
            String extension = '';
            if (fileName.contains('.')) {
                extension = fileName.substring(fileName.lastIndexOf('.'));
            }
            savedFileName = item.File_Name_Prefix__c + extension;
        }

        // Insert the Content Version
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = savedFileName;
        contentVersion.PathOnClient = savedFileName;
        contentVersion.VersionData = EncodingUtil.base64Decode(base64Data.substringAfter(','));
        contentVersion.FirstPublishLocationId = response.Id;
        if (!Test.isRunningTest()) {
            contentVersion.put('NetworkId', Network.getNetworkId());
        }
        insert contentVersion;

        // Update the response record
        response.Original_Uploaded_Document_File_Name__c = originalFileName;
        response.Saved_Uploaded_Document_File_Name__c = savedFileName;
        response.HasDocument__c = true;
        response.Document_Requirement_Fulfilled_On__c = System.now();
        update response;

        // Optionally create Supporting_Document__c and additional CDLs
        if (String.isNotBlank(item.Uploaded_Document_Object__c)) {
            ContentVersion insertedVersion = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :contentVersion.Id
                LIMIT 1
            ];

            List<Requirement_Response__c> fullResponses = [
                SELECT Application__r.Contact__c
                FROM Requirement_Response__c
                WHERE Id = :response.Id
                WITH USER_MODE
                LIMIT 1
            ];
            Id contactId = fullResponses.isEmpty() ? null : fullResponses[0].Application__r.Contact__c;

            if (item.Uploaded_Document_Object__c.contains('Supporting Document') && contactId != null) {
                List<Supporting_Document__c> existingDocs = [
                    SELECT Id
                    FROM Supporting_Document__c
                    WHERE Requirement_Response__c = :response.Id
                    WITH USER_MODE
                    LIMIT 1
                ];

                Supporting_Document__c supportingDoc = new Supporting_Document__c();
                supportingDoc.Name = savedFileName.abbreviate(80);
                if (!existingDocs.isEmpty()) {
                    supportingDoc.Id = existingDocs[0].Id;
                }
                supportingDoc.Contact__c = contactId;
                supportingDoc.Original_Uploaded_Document_File_Name__c = originalFileName;
                supportingDoc.Saved_Uploaded_Document_File_Name__c = savedFileName;
                supportingDoc.Requirement_Response__c = response.Id;
                supportingDoc.Admissions_Application__c = applicationId;
                supportingDoc.Document_Type__c = String.isNotBlank(item.Uploaded_Document_Type__c)
                    ? item.Uploaded_Document_Type__c : 'Transcript - High School';
                supportingDoc.Source__c = String.isNotBlank(item.Uploaded_Document_Source__c)
                    ? item.Uploaded_Document_Source__c : 'Admissions Application';
                supportingDoc.Document_Load_Date__c = Date.today();
                String admissionsDocumentRecordTypeId = Schema.getGlobalDescribe()
                    .get('Supporting_Document__c').getDescribe()
                    .getRecordTypeInfosByDeveloperName().get('Admissions_Document').getRecordTypeId();
                supportingDoc.RecordTypeId = admissionsDocumentRecordTypeId;
                upsert supportingDoc;

                ContentDocumentLink supportingDocLink = new ContentDocumentLink();
                supportingDocLink.ContentDocumentId = insertedVersion.ContentDocumentId;
                supportingDocLink.LinkedEntityId = supportingDoc.Id;
                supportingDocLink.ShareType = 'V';
                insert supportingDocLink;
            }

            if (item.Uploaded_Document_Object__c.contains('Admissions Application')) {
                ContentDocumentLink applicationLink = new ContentDocumentLink();
                applicationLink.ContentDocumentId = insertedVersion.ContentDocumentId;
                applicationLink.LinkedEntityId = applicationId;
                applicationLink.ShareType = 'V';
                insert applicationLink;
            }
        }

        return getDocumentUploadConfig(requirementItemId, applicationId, applicationStatus);
    }

    /**
     * Saves a rich-text / plain-text entry for a Document_Upload requirement item.
     * Returns the refreshed DocumentUploadConfig.
     *
     * @param requirementItemId  Id of the Requirement_Item__c
     * @param applicationId      Id of the Admissions_Application__c
     * @param textValue          HTML string from the rich-text editor
     * @param applicationStatus  Current Application_Status__c value
     * @return Refreshed DocumentUploadConfig
     */
    @AuraEnabled
    public static DocumentUploadConfig saveTextEntry(
        String requirementItemId,
        String applicationId,
        String textValue,
        String applicationStatus
    ) {
        List<Requirement_Response__c> responses = [
            SELECT Id, Document_Requirement_Fulfilled_On__c
            FROM Requirement_Response__c
            WHERE Requirement_Item__c = :requirementItemId
            AND Application__c = :applicationId
            WITH USER_MODE
            LIMIT 1
        ];

        Requirement_Response__c response;
        if (responses.isEmpty()) {
            response = new Requirement_Response__c(
                Requirement_Item__c = requirementItemId,
                Application__c = applicationId
            );
            insert response;
        } else {
            response = responses[0];
        }

        Boolean hasContent = String.isNotBlank(textValue);
        response.ValueTextEntry__c = textValue;
        response.HasDocument__c = hasContent;
        if (hasContent && response.Document_Requirement_Fulfilled_On__c == null) {
            response.Document_Requirement_Fulfilled_On__c = System.now();
        } else if (!hasContent) {
            response.Document_Requirement_Fulfilled_On__c = null;
        }
        update response;

        return getDocumentUploadConfig(requirementItemId, applicationId, applicationStatus);
    }

    /**
     * Deletes an existing document attachment and clears the response fields.
     * Returns the refreshed DocumentUploadConfig.
     *
     * @param contentDocumentId  ContentDocument.Id to delete
     * @param responseId         Requirement_Response__c.Id to clear
     * @param requirementItemId  Id of the Requirement_Item__c (for config refresh)
     * @param applicationId      Id of the Admissions_Application__c (for config refresh)
     * @param applicationStatus  Current Application_Status__c value (for config refresh)
     * @return Refreshed DocumentUploadConfig
     */
    @AuraEnabled
    public static DocumentUploadConfig deleteDocumentFile(
        String contentDocumentId,
        String responseId,
        String requirementItemId,
        String applicationId,
        String applicationStatus
    ) {
        // Collect any linked Supporting_Document__c records before deleting the ContentDocument
        List<ContentDocumentLink> links = [
            SELECT Id, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :contentDocumentId
            WITH USER_MODE
        ];

        List<Id> supportingDocumentIds = new List<Id>();
        for (ContentDocumentLink link : links) {
            String objectName = link.LinkedEntityId.getSobjectType().getDescribe().getName();
            if (objectName == 'Supporting_Document__c') {
                supportingDocumentIds.add(link.LinkedEntityId);
            }
        }

        try {
            delete new ContentDocument(Id = contentDocumentId);
        } catch (Exception deleteError) {
            throw new AuraHandledException('Failed to delete document: ' + deleteError.getMessage());
        }

        update new Requirement_Response__c(
            Id = responseId,
            Original_Uploaded_Document_File_Name__c = '',
            Saved_Uploaded_Document_File_Name__c = '',
            HasDocument__c = false,
            Document_Requirement_Fulfilled_On__c = null
        );

        if (!supportingDocumentIds.isEmpty()) {
            delete [
                SELECT Id
                FROM Supporting_Document__c
                WHERE Id IN :supportingDocumentIds
                AND Requirement_Response__c = :responseId
                WITH USER_MODE
            ];
        }

        return getDocumentUploadConfig(requirementItemId, applicationId, applicationStatus);
    }

    /**
     * Enforces the Requirement_Item__c.File_Types__c allow-list against an uploaded
     * file's extension. Mirrors the client-side check in easyDocumentUpload.js, but
     * this is the authoritative check since the client can be bypassed.
     * A blank File_Types__c means all file types are allowed.
     *
     * @param fileName   Original file name, e.g. "transcript.pdf"
     * @param fileTypes  Semicolon-separated accepted extensions, e.g. "PDF;DOCX;DOC"
     */
    private static void validateFileType(String fileName, String fileTypes) {
        if (String.isBlank(fileTypes)) {
            return;
        }
        String extension = fileName.contains('.')
            ? fileName.substring(fileName.lastIndexOf('.') + 1).toUpperCase()
            : '';
        Set<String> acceptedTypes = new Set<String>();
        for (String rawType : fileTypes.split(';')) {
            if (String.isNotBlank(rawType)) {
                acceptedTypes.add(rawType.trim().toUpperCase());
            }
        }
        if (!acceptedTypes.contains(extension)) {
            throw new AuraHandledException(
                'File type not accepted. Please upload one of the following: '
                    + String.join(new List<String>(acceptedTypes), ', ') + '.'
            );
        }
    }
}