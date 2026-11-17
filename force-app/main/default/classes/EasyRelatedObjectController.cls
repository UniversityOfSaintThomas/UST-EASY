/*******************************************************************************
 * @description AuraEnabled controller for the easyRelatedObjectForm LWC.
 *              Handles all CRUD operations for Related_Object type Requirement Items,
 *              replacing the VF view-state-based implementation to eliminate the
 *              135 KB VF view state limit errors.
 *
 *              Design notes:
 *              - without sharing: guest/community applicants must be able to read and
 *                write their own related records; sharing rules alone are insufficient
 *                for all deployments.
 *              - All DML is validated against the application record before execution.
 *              - Questions with Hardcoded_Value__c are set server-side on insert and
 *                excluded from the user-supplied field values map.
 * @author UST
 *******************************************************************************/
public without sharing class EasyRelatedObjectController {

    private static final String SUPPORTING_DOC_DESCRIPTION = 'Supporting Document';

    // =========================================================================
    // INNER DTO CLASSES
    // =========================================================================

    /**
     * @description Configuration payload returned to the LWC on initialisation.
     *              Contains all metadata needed to render the related-object form.
     */
    public class RequirementItemConfigDTO {
        /** Id of the Requirement_Item__c */
        @AuraEnabled public String requirementItemId { get; set; }
        /** API name of the related SObject (e.g. Education_History__c) */
        @AuraEnabled public String relatedObjectApiName { get; set; }
        /** API name of the master field on the child object */
        @AuraEnabled public String masterFieldApiName { get; set; }
        /** 'Contact' or 'Application' */
        @AuraEnabled public String masterObjectType { get; set; }
        /** Additional WHERE clause filter appended to the SOQL query */
        @AuraEnabled public String whereClause { get; set; }
        /** Minimum number of child records required */
        @AuraEnabled public Decimal requiredChildCount { get; set; }
        /** Maximum number of child records allowed */
        @AuraEnabled public Decimal maximumChildCount { get; set; }
        /** Id of the placeholder lookup record used for new-reference flow */
        @AuraEnabled public String holdingRecordId { get; set; }
        /** Applicant-facing instructions */
        @AuraEnabled public String instructions { get; set; }
        /** Semicolon-delimited application statuses that require a supporting document */
        @AuraEnabled public String requiredDocumentationStatuses { get; set; }
        /** Whether supporting document upload is allowed */
        @AuraEnabled public Boolean allowSupportingDocumentationUpload { get; set; }
        /** Semicolon-delimited allowed file extensions */
        @AuraEnabled public String fileTypes { get; set; }
        /** Human-readable label for the card header (Label__c or Name of the Requirement Item) */
        @AuraEnabled public String itemLabel { get; set; }
        /** Question definitions for the main form fields */
        @AuraEnabled public List<QuestionConfigDTO> questions { get; set; }
        /** Question definitions for the new-reference creation form (New_Reference_Field__c = true) */
        @AuraEnabled public List<QuestionConfigDTO> referenceQuestions { get; set; }
        /** SObject API name of the object that can be created in the new-reference flow */
        @AuraEnabled public String newReferenceObjectType { get; set; }
    }

    /** @description Definition of a single question in the related-object form. */
    public class QuestionConfigDTO {
        /** Id of the Question__c */
        @AuraEnabled public String questionId { get; set; }
        /** Display label */
        @AuraEnabled public String label { get; set; }
        /** Optional help text shown below the input */
        @AuraEnabled public String helpText { get; set; }
        /** API name of the field on the related SObject */
        @AuraEnabled public String fieldApiName { get; set; }
        /** RecordType.DeveloperName of the question (e.g. Text, Picklist, Reference) */
        @AuraEnabled public String fieldType { get; set; }
        /** Server-side default value; hidden from the user but set automatically on new records */
        @AuraEnabled public String hardcodedValue { get; set; }
        /** Semicolon-delimited application statuses for which this field is required */
        @AuraEnabled public String requiredStatuses { get; set; }
        /** API name of the SObject used for Reference-type lookup typeahead */
        @AuraEnabled public String lookupObjectType { get; set; }
        /** Additional WHERE clause filter for the lookup typeahead query */
        @AuraEnabled public String lookupWhereClause { get; set; }
        /** API name of the Name field on the lookup object (defaults to Name) */
        @AuraEnabled public String nameFieldApiName { get; set; }
        /** True when this question belongs to the new-reference creation form */
        @AuraEnabled public Boolean isNewReferenceField { get; set; }
        /** Sort order within the form */
        @AuraEnabled public Integer displayOrder { get; set; }
        /** Picklist options for Picklist and MultiPicklist question types */
        @AuraEnabled public List<PicklistOptionDTO> picklistOptions { get; set; }
        /**
         * AND/OR logic for evaluating multiple dependencies (blank or 'AND' means all must match;
         * 'OR' means any one match is sufficient)
         */
        @AuraEnabled public String dependencyLogic { get; set; }
        /**
         * 'Show' (default/blank) or 'Hide' - controls whether the question is shown or hidden
         * when the dependency condition is satisfied
         */
        @AuraEnabled public String dependencyBehavior { get; set; }
        /** Dependency rules that control visibility of this question */
        @AuraEnabled public List<QuestionDependencyDTO> dependencies { get; set; }
        /**
         * Additional_Field_Validation__c picklist value (e.g. validateACT, validateSATComposite,
         * validateSATSubject, validateAge). Drives client-side range validation in the LWC,
         * mirroring the same-named CSS-class-driven validation on the VF-rendered forms
         * (see easyFormValidation.js numericFieldValidation()).
         */
        @AuraEnabled public String additionalFieldValidation { get; set; }
    }

    /** @description A single dependency rule linking a dependent question to its controlling question. */
    public class QuestionDependencyDTO {
        /** Id of the controlling Question__c record */
        @AuraEnabled public String controllingQuestionId { get; set; }
        /** RecordType.DeveloperName of the Question_Dependency__c (Picklist, Radio, Checkbox, Multi_Select_Picklist) */
        @AuraEnabled public String dependencyType { get; set; }
        /** Expected string value for Picklist, Radio, and Multi_Select_Picklist types */
        @AuraEnabled public String value { get; set; }
        /** Expected boolean value for Checkbox type */
        @AuraEnabled public Boolean valueCheckbox { get; set; }
    }

    /** @description A single option in a picklist or multi-select picklist field. */
    public class PicklistOptionDTO {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        /**
         * @param optionLabel Display label
         * @param optionValue API value
         */
        public PicklistOptionDTO(String optionLabel, String optionValue) {
            this.label = optionLabel;
            this.value = optionValue;
        }
    }

    /** @description An existing related-object record returned to the LWC. */
    public class RelatedRecordDTO {
        /** Salesforce record Id */
        @AuraEnabled public String recordId { get; set; }
        /** True when this record was created by the applicant (User_Created__c = true) */
        @AuraEnabled public Boolean userCreated { get; set; }
        /** Map of question field API name to its current value */
        @AuraEnabled public Map<String, Object> fieldValues { get; set; }
        /** Title of the linked supporting document (null if none exists) */
        @AuraEnabled public String documentTitle { get; set; }
        /** ContentDocumentId of the linked supporting document */
        @AuraEnabled public String documentId { get; set; }
        /** Holding_Name__c value used when the user selected a new-reference placeholder */
        @AuraEnabled public String holdingName { get; set; }
        /** JSON payload stored for deferred new-reference record creation by staff */
        @AuraEnabled public String relatedObjectJson { get; set; }
        /** Display names for lookup/reference fields, keyed by field API name */
        @AuraEnabled public Map<String, String> lookupDisplayNames { get; set; }
    }

    /** @description Result returned after a successful save operation. */
    public class SaveResultDTO {
        /** Id of the inserted or updated record */
        @AuraEnabled public String savedRecordId { get; set; }
        /** True when the requirement is now fulfilled (enough child records exist) */
        @AuraEnabled public Boolean requirementFulfilled { get; set; }

        /**
         * @param savedRecordId      Id of the saved record
         * @param requirementFulfilled Whether the child-count requirement is now met
         */
        public SaveResultDTO(String savedRecordId, Boolean requirementFulfilled) {
            this.savedRecordId = savedRecordId;
            this.requirementFulfilled = requirementFulfilled;
        }
    }

    // =========================================================================
    // PUBLIC @AuraEnabled METHODS
    // =========================================================================

    /**
     * @description Returns the configuration for a Related_Object Requirement Item including
     *              all question definitions with picklist options and field metadata.
     *              Cached because it is read-only metadata configuration.
     *
     * @param requirementItemId Id of the Requirement_Item__c record
     * @return RequirementItemConfigDTO populated from the item and its questions
     */
    @AuraEnabled(Cacheable=false)
    public static RequirementItemConfigDTO getRequirementItemConfig(String requirementItemId) {
        if (String.isBlank(requirementItemId)) {
            throw new AuraHandledException('requirementItemId is required.');
        }
        try {
            Requirement_Item__c item = queryRequirementItem(requirementItemId);
            return buildRequirementItemConfig(item);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading requirement configuration: ' + e.getMessage());
        }
    }

    /**
     * @description Returns all existing related-object records for the given application
     *              and requirement item, including any linked supporting documents.
     *
     * @param requirementItemId Id of the Requirement_Item__c record
     * @param applicationId     Id of the Application__c record
     * @return List of RelatedRecordDTO, one per existing record
     */
    @AuraEnabled
    public static List<RelatedRecordDTO> getExistingRelatedRecords(String requirementItemId, String applicationId) {
        if (String.isBlank(requirementItemId) || String.isBlank(applicationId)) {
            throw new AuraHandledException('requirementItemId and applicationId are required.');
        }
        try {
            Requirement_Item__c item = queryRequirementItem(requirementItemId);
            Application__c app = queryApplication(applicationId);

            return queryRelatedRecords(item, app);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading related records: ' + e.getMessage());
        }
    }

    /**
     * @description Inserts or updates a single related-object record.
     *              After the DML, updates Has_Child_Requirement__c on the Requirement_Response__c.
     *
     * @param requirementItemId  Id of the Requirement_Item__c record
     * @param applicationId      Id of the Application__c record
     * @param fieldValuesJson    JSON-serialised Map of field API name to user-supplied value
     * @param existingRecordId   Null when inserting; the record Id when updating
     * @return SaveResultDTO with the saved record Id and current fulfilment status
     */
    @AuraEnabled
    public static SaveResultDTO saveRelatedRecord(
            String requirementItemId,
            String applicationId,
            String fieldValuesJson,
            String existingRecordId
    ) {
        if (String.isBlank(requirementItemId) || String.isBlank(applicationId) || String.isBlank(fieldValuesJson)) {
            throw new AuraHandledException('requirementItemId, applicationId, and fieldValuesJson are required.');
        }
        try {
            Requirement_Item__c item = queryRequirementItem(requirementItemId);
            Application__c app = queryApplication(applicationId);
            Map<String, Object> fieldValues = (Map<String, Object>) JSON.deserializeUntyped(fieldValuesJson);
            SObject record = buildSObjectFromFieldValues(item, app, fieldValues, existingRecordId);

            Savepoint savepoint = Database.setSavepoint();
            try {
                if (String.isNotBlank(existingRecordId)) {
                    Database.update(record, System.AccessLevel.SYSTEM_MODE);
                } else {
                    Database.insert(record, System.AccessLevel.SYSTEM_MODE);
                }
            } catch (DmlException dmlException) {
                Database.rollback(savepoint);
                throw new AuraHandledException('Error saving record: ' + dmlException.getDmlMessage(0));
            }

            Integer childCount = countValidChildRecords(item, app);
            Boolean fulfilled = updateRequirementFulfillment(item, applicationId, childCount);
            return new SaveResultDTO(String.valueOf(record.Id), fulfilled);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error saving record: ' + e.getMessage());
        }
    }

    /**
     * @description Deletes a related-object record and updates requirement fulfilment.
     *              Validates that the record belongs to the given application before deleting.
     *
     * @param recordId          Id of the record to delete
     * @param requirementItemId Id of the Requirement_Item__c record
     * @param applicationId     Id of the Application__c record
     * @return True when the requirement is still fulfilled after deletion; false otherwise
     */
    @AuraEnabled
    public static Boolean deleteRelatedRecord(String recordId, String requirementItemId, String applicationId) {
        if (String.isBlank(recordId) || String.isBlank(requirementItemId) || String.isBlank(applicationId)) {
            throw new AuraHandledException('recordId, requirementItemId, and applicationId are required.');
        }
        try {
            Requirement_Item__c item = queryRequirementItem(requirementItemId);
            Application__c app = queryApplication(applicationId);

            // Verify ownership: record must belong to this application's contact or application
            Id rawConnectingId = item.Related_List_Object_Master__c == 'Contact'
                    ? app.Contact__c
                    : app.Id;
            if (rawConnectingId == null) {
                throw new AuraHandledException(
                        'Cannot delete record: Application is not linked to a '
                                + item.Related_List_Object_Master__c + '.'
                );
            }
            String connectingId = String.valueOf(rawConnectingId);
            String ownershipQuery = 'SELECT Id FROM ' + item.Related_List_Object__c
                    + ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\''
                    + ' AND ' + item.Related_List_Object_Master_Field__c
                    + ' = \'' + String.escapeSingleQuotes(connectingId) + '\' LIMIT 1';
            if (Database.query(ownershipQuery).isEmpty()) {
                throw new AuraHandledException('Record not found or does not belong to this application.');
            }

            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(item.Related_List_Object__c);
            Database.delete(sObjectType.newSObject(Id.valueOf(recordId)), System.AccessLevel.SYSTEM_MODE);

            Integer childCount = countValidChildRecords(item, app);
            return updateRequirementFulfillment(item, applicationId, childCount);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting record: ' + e.getMessage());
        }
    }

    /**
     * @description Uploads a supporting document as a ContentVersion linked to a related record.
     *              Replaces any previously uploaded supporting document for the same record.
     *
     * @param relatedRecordId   Id of the related SObject record to attach the document to
     * @param requirementItemId Id of the Requirement_Item__c (used for File_Name_Prefix__c configuration)
     * @param fileName          Original filename including extension
     * @param base64Data        Base64-encoded file content, optionally prefixed with a data URI header
     * @return Id of the newly created ContentVersion record
     */
    @AuraEnabled
    public static String uploadSupportingDocument(
            String relatedRecordId,
            String requirementItemId,
            String fileName,
            String base64Data
    ) {
        if (String.isBlank(relatedRecordId) || String.isBlank(fileName) || String.isBlank(base64Data)) {
            throw new AuraHandledException('relatedRecordId, fileName, and base64Data are required.');
        }
        try {
            String documentTitle = applyFileNamePrefix(fileName, requirementItemId);
            String pureBase64 = base64Data.contains(',') ? base64Data.substringAfter(',') : base64Data;

            // Delete existing supporting document before inserting the new one
            List<ContentDocumentLink> existingLinks = [
                    SELECT Id, ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :relatedRecordId
                    AND ContentDocument.Description = :SUPPORTING_DOC_DESCRIPTION
                    LIMIT 1
            ];
            if (!existingLinks.isEmpty()) {
                Database.delete(new ContentDocument(Id = existingLinks[0].ContentDocumentId), System.AccessLevel.SYSTEM_MODE);
            }

            ContentVersion newDocument = new ContentVersion();
            newDocument.Title = documentTitle;
            newDocument.PathOnClient = documentTitle;
            newDocument.VersionData = EncodingUtil.base64Decode(pureBase64);
            newDocument.FirstPublishLocationId = relatedRecordId;
            newDocument.Description = SUPPORTING_DOC_DESCRIPTION;
            if (!Test.isRunningTest()) {
                newDocument.put('NetworkId', Network.getNetworkId());
            }
            Database.insert(newDocument, System.AccessLevel.SYSTEM_MODE);
            return String.valueOf(newDocument.Id);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading document: ' + e.getMessage());
        }
    }

    // =========================================================================
    // PRIVATE HELPER METHODS
    // =========================================================================

    /**
     * @description Queries a Requirement_Item__c with all fields and sub-selected questions
     *              needed by this controller.
     *
     * @param requirementItemId Id of the item
     * @return The queried Requirement_Item__c
     */
    private static Requirement_Item__c queryRequirementItem(String requirementItemId) {
        List<Requirement_Item__c> items = [
                SELECT Id, Name, Label__c, Instructions__c, Related_List_Object__c, Related_List_Object_Master_Field__c,
                        Related_List_Object_Master__c, Related_List_Where_Clause__c,
                        Required_Number_of_Children__c, Maximum_Number_of_Children__c,
                        Holding_Record_Id__c, Required_Supporting_Documentation__c,
                        Related_Object_Record_Type_ID__c, Allow_Supporting_Documentation_Upload__c,
                        File_Types__c, File_Name_Prefix__c, (
                        SELECT Id, Label__c, Help_Text__c, Related_Object_Field__c,
                                RecordType.DeveloperName, Required__c, Hardcoded_Value__c,
                                Lookup_Object__c, Lookup_Where_Clause__c, Name_Field_API_Name__c,
                                New_Reference_Field__c, Active__c, Display_Order__c,
                                Dependency_Logic__c, Dependency_Behavior__c, Additional_Field_Validation__c
                        FROM Questions__r
                        WHERE Active__c = TRUE
                        ORDER BY Display_Order__c ASC NULLS LAST
                )
                FROM Requirement_Item__c
                WHERE Id = :requirementItemId
                LIMIT 1
        ];
        if (items.isEmpty()) {
            throw new AuraHandledException('Requirement Item not found.');
        }
        return items[0];
    }

    /**
     * @description Queries an Application__c with the fields needed for related-object operations.
     *
     * @param applicationId Id of the application
     * @return The queried Application__c
     */
    private static Application__c queryApplication(String applicationId) {
        List<Application__c> apps = [
                SELECT Id, Contact__c, Application_Status__c
                FROM Application__c
                WHERE Id = :applicationId
                LIMIT 1
        ];
        if (apps.isEmpty()) {
            throw new AuraHandledException('Application not found.');
        }
        return apps[0];
    }

    /**
     * @description Converts a Requirement_Item__c record (with questions populated) into a
     *              RequirementItemConfigDTO for the LWC.
     *
     * @param item The queried Requirement_Item__c with Questions__r
     * @return Populated RequirementItemConfigDTO
     */
    private static RequirementItemConfigDTO buildRequirementItemConfig(Requirement_Item__c item) {
        RequirementItemConfigDTO config = new RequirementItemConfigDTO();
        config.requirementItemId = item.Id;
        config.relatedObjectApiName = item.Related_List_Object__c;
        config.masterFieldApiName = item.Related_List_Object_Master_Field__c;
        config.masterObjectType = item.Related_List_Object_Master__c;
        config.whereClause = item.Related_List_Where_Clause__c;
        config.requiredChildCount = item.Required_Number_of_Children__c;
        config.maximumChildCount = item.Maximum_Number_of_Children__c;
        config.holdingRecordId = item.Holding_Record_Id__c;
        config.instructions = item.Instructions__c;
        config.requiredDocumentationStatuses = item.Required_Supporting_Documentation__c;
        config.allowSupportingDocumentationUpload = item.Allow_Supporting_Documentation_Upload__c;
        config.fileTypes = item.File_Types__c;
        config.itemLabel = String.isNotBlank(item.Label__c) ? item.Label__c : item.Name;
        config.questions = new List<QuestionConfigDTO>();
        config.referenceQuestions = new List<QuestionConfigDTO>();

        // Pre-load the field schema for the related object to drive picklist options
        Map<String, Schema.SObjectField> relatedObjectFields = new Map<String, Schema.SObjectField>();
        if (String.isNotBlank(item.Related_List_Object__c)) {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(item.Related_List_Object__c);
            if (objectType != null) {
                relatedObjectFields = objectType.getDescribe().fields.getMap();
            }
        }

        // Pre-load Question_Dependency__c records for all questions in this item
        Set<Id> questionIds = new Set<Id>();
        for (Question__c question : item.Questions__r) {
            questionIds.add(question.Id);
        }
        Map<Id, List<Question_Dependency__c>> dependencyMap = new Map<Id, List<Question_Dependency__c>>();
        for (Question_Dependency__c dep : [
                SELECT Id, Question__c, Controlling_Question__c, Value__c, ValueCheckbox__c,
                        RecordType.DeveloperName
                FROM Question_Dependency__c
                WHERE Question__c IN :questionIds
                AND Question_Active__c = TRUE
                AND Controlling_Question_Active__c = TRUE
        ]) {
            if (!dependencyMap.containsKey(dep.Question__c)) {
                dependencyMap.put(dep.Question__c, new List<Question_Dependency__c>());
            }
            dependencyMap.get(dep.Question__c).add(dep);
        }

        String newReferenceObjectType = null;
        for (Question__c question : item.Questions__r) {
            List<Question_Dependency__c> questionDeps = dependencyMap.containsKey(question.Id)
                    ? dependencyMap.get(question.Id)
                    : new List<Question_Dependency__c>();
            QuestionConfigDTO questionDto = buildQuestionConfig(question, relatedObjectFields, questionDeps);
            if (question.New_Reference_Field__c) {
                config.referenceQuestions.add(questionDto);
                if (String.isNotBlank(question.Lookup_Object__c) && newReferenceObjectType == null) {
                    newReferenceObjectType = question.Lookup_Object__c;
                }
            } else {
                config.questions.add(questionDto);
            }
        }
        config.newReferenceObjectType = newReferenceObjectType;
        return config;
    }

    /**
     * @description Builds a QuestionConfigDTO from a single Question__c record,
     *              including picklist options resolved from Schema.describe and
     *              any dependency rules that control question visibility.
     *
     * @param question             The Question__c record
     * @param relatedObjectFields  Field schema map for the parent related SObject
     * @param questionDeps         Question_Dependency__c records whose Question__c equals this question
     * @return Populated QuestionConfigDTO
     */
    private static QuestionConfigDTO buildQuestionConfig(
            Question__c question,
            Map<String, Schema.SObjectField> relatedObjectFields,
            List<Question_Dependency__c> questionDeps
    ) {
        QuestionConfigDTO dto = new QuestionConfigDTO();
        dto.questionId = question.Id;
        dto.label = question.Label__c;
        dto.helpText = question.Help_Text__c;
        dto.fieldApiName = question.Related_Object_Field__c;
        dto.fieldType = question.RecordType.DeveloperName;
        dto.hardcodedValue = question.Hardcoded_Value__c;
        dto.requiredStatuses = question.Required__c;
        dto.lookupObjectType = question.Lookup_Object__c;
        dto.lookupWhereClause = question.Lookup_Where_Clause__c;
        dto.nameFieldApiName = question.Name_Field_API_Name__c;
        dto.isNewReferenceField = question.New_Reference_Field__c;
        dto.displayOrder = question.Display_Order__c != null ? Integer.valueOf(question.Display_Order__c) : 0;
        dto.picklistOptions = new List<PicklistOptionDTO>();
        dto.dependencyLogic = question.Dependency_Logic__c;
        dto.dependencyBehavior = question.Dependency_Behavior__c;
        dto.dependencies = new List<QuestionDependencyDTO>();
        dto.additionalFieldValidation = question.Additional_Field_Validation__c;

        Boolean isPicklistType = question.RecordType.DeveloperName == 'Picklist'
                || question.RecordType.DeveloperName == 'MultiPicklist'
                || question.RecordType.DeveloperName == 'Radio';

        if (isPicklistType && String.isNotBlank(question.Related_Object_Field__c)) {
            String fieldKey = question.Related_Object_Field__c.toLowerCase();
            if (relatedObjectFields.containsKey(fieldKey)) {
                Schema.DescribeFieldResult fieldDescribe = relatedObjectFields.get(fieldKey).getDescribe();
                for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                    if (entry.isActive()) {
                        dto.picklistOptions.add(new PicklistOptionDTO(entry.getLabel(), entry.getValue()));
                    }
                }
            }
        }

        for (Question_Dependency__c dep : questionDeps) {
            QuestionDependencyDTO depDto = new QuestionDependencyDTO();
            depDto.controllingQuestionId = dep.Controlling_Question__c;
            depDto.dependencyType = dep.RecordType.DeveloperName;
            depDto.value = dep.Value__c;
            depDto.valueCheckbox = Boolean.valueOf(dep.ValueCheckbox__c);
            dto.dependencies.add(depDto);
        }

        return dto;
    }

    /**
     * @description Executes the dynamic SOQL query to load all existing related records
     *              for the given application and requirement item.
     *
     * @param item  Requirement item configuration (provides object name, where clause, questions)
     * @param app   Application record (provides Contact__c and Id for the master field filter)
     * @return List of RelatedRecordDTO, one per result row
     */
    private static List<RelatedRecordDTO> queryRelatedRecords(Requirement_Item__c item, Application__c app) {
        Set<String> fieldsToQuery = new Set<String>{
                'id', 'user_created__c', 'holding_name__c', 'related_object_json__c'
        };

        // fieldApiName -> relationship name (e.g. Account__c -> Account__r)
        Map<String, String> lookupRelationshipNames = new Map<String, String>();
        // fieldApiName -> first name field to display (e.g. Account__c -> Name)
        Map<String, String> lookupNameFields = new Map<String, String>();

        for (Question__c question : item.Questions__r) {
            if (String.isNotBlank(question.Related_Object_Field__c) && !question.New_Reference_Field__c) {
                fieldsToQuery.add(question.Related_Object_Field__c.toLowerCase());

                Boolean isReference = question.RecordType.DeveloperName == 'Reference'
                        || question.RecordType.DeveloperName == 'Lookup';
                if (isReference) {
                    String fieldApiName = question.Related_Object_Field__c;
                    String relationshipName = fieldApiName.endsWith('__c')
                            ? fieldApiName.removeEnd('__c') + '__r'
                            : fieldApiName.removeEnd('Id');
                    String nameField = String.isNotBlank(question.Name_Field_API_Name__c)
                            ? question.Name_Field_API_Name__c.split(',')[0].trim()
                            : 'Name';
                    lookupRelationshipNames.put(fieldApiName, relationshipName);
                    lookupNameFields.put(fieldApiName, nameField);
                    fieldsToQuery.add((relationshipName + '.' + nameField).toLowerCase());
                }
            }
        }

        Id rawConnectingId = item.Related_List_Object_Master__c == 'Contact'
                ? app.Contact__c
                : app.Id;
        if (rawConnectingId == null) {
            throw new AuraHandledException(
                    'Cannot load related records: Application is not linked to a '
                            + item.Related_List_Object_Master__c + '.'
            );
        }
        String connectingId = String.valueOf(rawConnectingId);

        String query = 'SELECT (SELECT Id, ContentDocumentId, ContentDocument.Title'
                + ' FROM ContentDocumentLinks WHERE ContentDocument.Description = \'' + SUPPORTING_DOC_DESCRIPTION + '\' LIMIT 1), '
                + String.join(new List<String>(fieldsToQuery), ', ')
                + ' FROM ' + item.Related_List_Object__c
                + ' WHERE ' + item.Related_List_Object_Master_Field__c
                + ' = \'' + String.escapeSingleQuotes(connectingId) + '\'';

        if (String.isNotBlank(item.Related_List_Where_Clause__c)) {
            query += ' AND ' + item.Related_List_Where_Clause__c;
        }

        System.debug('existing record query: ' + query);
        List<RelatedRecordDTO> results = new List<RelatedRecordDTO>();
        for (SObject record : Database.query(query)) {
            RelatedRecordDTO dto = new RelatedRecordDTO();
            dto.recordId = String.valueOf(record.Id);
            dto.userCreated = (record.get('User_Created__c') == true);
            dto.holdingName = (String) record.get('Holding_Name__c');
            dto.relatedObjectJson = (String) record.get('Related_Object_JSON__c');
            dto.fieldValues = new Map<String, Object>();
            dto.lookupDisplayNames = new Map<String, String>();

            for (Question__c question : item.Questions__r) {
                if (String.isNotBlank(question.Related_Object_Field__c) && !question.New_Reference_Field__c) {
                    try {
                        dto.fieldValues.put(question.Related_Object_Field__c, record.get(question.Related_Object_Field__c));
                    } catch (Exception e) {
                        // Field may not be accessible on this object; skip silently
                    }
                }
            }

            for (String fieldApiName : lookupRelationshipNames.keySet()) {
                String relationshipName = lookupRelationshipNames.get(fieldApiName);
                String nameField = lookupNameFields.get(fieldApiName);
                try {
                    SObject relatedObject = record.getSObject(relationshipName);
                    if (relatedObject != null) {
                        String displayName = (String) relatedObject.get(nameField);
                        if (String.isNotBlank(displayName)) {
                            dto.lookupDisplayNames.put(fieldApiName, displayName);
                        }
                    }
                } catch (Exception e) {
                    // Relationship null or inaccessible; skip silently
                }
            }

            List<ContentDocumentLink> documentLinks =
                    record.getSObjects('ContentDocumentLinks');
            if (documentLinks != null && !documentLinks.isEmpty()) {
                dto.documentTitle = documentLinks[0].ContentDocument.Title;
                dto.documentId = String.valueOf(documentLinks[0].ContentDocumentId);
            }
            results.add(dto);
        }
        return results;
    }

    /**
     * @description Constructs the SObject record ready for DML from user-supplied field values.
     *              Sets hardcoded values on new insertions; excludes them from updates.
     *
     * @param item              Requirement item configuration
     * @param app               Application record (provides Contact__c and Id)
     * @param fieldValues       User-supplied field values from the LWC
     * @param existingRecordId  Null for inserts; the record Id for updates
     * @return Configured SObject ready for insert or update
     */
    private static SObject buildSObjectFromFieldValues(
            Requirement_Item__c item,
            Application__c app,
            Map<String, Object> fieldValues,
            String existingRecordId
    ) {
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(item.Related_List_Object__c);
        if (sObjectType == null) {
            throw new AuraHandledException('Unknown SObject type: ' + item.Related_List_Object__c);
        }
        Map<String, Schema.SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap();

        Boolean isNew = String.isBlank(existingRecordId);
        SObject record = isNew ? sObjectType.newSObject() : sObjectType.newSObject(Id.valueOf(existingRecordId));

        if (isNew) {
            record.put('User_Created__c', true);
            Id masterObjectId = item.Related_List_Object_Master__c == 'Contact' ? app.Contact__c : app.Id;
            if (masterObjectId == null) {
                throw new AuraHandledException(
                        'Cannot save record: Application is not linked to a '
                                + item.Related_List_Object_Master__c + '.'
                );
            }
            record.put(item.Related_List_Object_Master_Field__c, masterObjectId);
        }

        if (String.isNotBlank(item.Related_Object_Record_Type_ID__c)) {
            record.put('RecordTypeId', item.Related_Object_Record_Type_ID__c);
        }

        for (Question__c question : item.Questions__r) {
            if (String.isBlank(question.Related_Object_Field__c) || question.New_Reference_Field__c) {
                continue;
            }

            // Hardcoded values are set server-side on insert; never overridden on update
            if (String.isNotBlank(question.Hardcoded_Value__c)) {
                if (isNew) {
                    Schema.SObjectField fieldToken = sObjectFields.get(question.Related_Object_Field__c.toLowerCase());
                    if (fieldToken != null) {
                        Schema.DisplayType displayType = fieldToken.getDescribe().getType();
                        record.put(question.Related_Object_Field__c, castToFieldType(question.Hardcoded_Value__c, displayType));
                    }
                }
                continue;
            }

            // Set user-supplied values for non-hardcoded fields
            if (fieldValues.containsKey(question.Related_Object_Field__c)) {
                Schema.SObjectField fieldToken = sObjectFields.get(question.Related_Object_Field__c.toLowerCase());
                if (fieldToken == null) {
                    continue;
                }
                Schema.DisplayType displayType = fieldToken.getDescribe().getType();
                record.put(
                        question.Related_Object_Field__c,
                        castToFieldType(fieldValues.get(question.Related_Object_Field__c), displayType)
                );
            }
        }
        return record;
    }

    /**
     * @description Counts the number of user-created child records that qualify towards
     *              the Required_Number_of_Children__c threshold.
     *              If Required_Supporting_Documentation__c includes the current application
     *              status, only records with a linked supporting document are counted.
     *
     * @param item  Requirement item (provides object name, master field, where clause, doc check)
     * @param app   Application record (provides the connecting Id and application status)
     * @return Count of qualifying child records
     */
    private static Integer countValidChildRecords(Requirement_Item__c item, Application__c app) {
        String connectingId = item.Related_List_Object_Master__c == 'Contact'
                ? String.valueOf(app.Contact__c)
                : String.valueOf(app.Id);

        Boolean requiresDocumentForStatus = String.isNotBlank(item.Required_Supporting_Documentation__c)
                && String.isNotBlank(app.Application_Status__c)
                && item.Required_Supporting_Documentation__c.contains(app.Application_Status__c);

        String subQuery = requiresDocumentForStatus
                ? ', (SELECT Id FROM ContentDocumentLinks WHERE ContentDocument.Description = \'' + SUPPORTING_DOC_DESCRIPTION + '\' LIMIT 1)'
                : '';

        String query = 'SELECT Id, User_Created__c' + subQuery
                + ' FROM ' + item.Related_List_Object__c
                + ' WHERE ' + item.Related_List_Object_Master_Field__c
                + ' = \'' + String.escapeSingleQuotes(connectingId) + '\'';

        if (String.isNotBlank(item.Related_List_Where_Clause__c)) {
            query += ' AND ' + item.Related_List_Where_Clause__c;
        }

        Integer count = 0;
        for (SObject record : Database.query(query)) {
            if (record.get('User_Created__c') != true) {
                continue;
            }
            if (requiresDocumentForStatus) {
                List<ContentDocumentLink> links =
                        record.getSObjects('ContentDocumentLinks');
                if (links == null || links.isEmpty()) {
                    continue;
                }
            }
            count++;
        }
        return count;
    }

    /**
     * @description Updates Has_Child_Requirement__c and Child_Requirement_Fulfilled_On__c
     *              on the Requirement_Response__c record for the given requirement item and application.
     *
     * @param item          Requirement item (supplies Required_Number_of_Children__c)
     * @param applicationId Application Id used to locate the response
     * @param childCount    Current count of qualifying child records
     * @return True when the requirement is fulfilled; false otherwise
     */
    private static Boolean updateRequirementFulfillment(
            Requirement_Item__c item,
            String applicationId,
            Integer childCount
    ) {
        List<Requirement_Response__c> responses = [
                SELECT Id, Has_Child_Requirement__c, Child_Requirement_Fulfilled_On__c
                FROM Requirement_Response__c
                WHERE Requirement_Item__c = :item.Id
                AND Application__c = :applicationId
                LIMIT 1
        ];
        if (responses.isEmpty()) {
            return false;
        }

        Requirement_Response__c response = responses[0];
        Boolean fulfilled;

        if (item.Required_Number_of_Children__c != null && item.Required_Number_of_Children__c > childCount) {
            response.Has_Child_Requirement__c = false;
            response.Child_Requirement_Fulfilled_On__c = null;
            fulfilled = false;
        } else {
            if (!response.Has_Child_Requirement__c || response.Child_Requirement_Fulfilled_On__c == null) {
                response.Child_Requirement_Fulfilled_On__c = System.now();
            }
            response.Has_Child_Requirement__c = true;
            fulfilled = true;
        }
        Database.update(response, System.AccessLevel.SYSTEM_MODE);
        return fulfilled;
    }

    /**
     * @description Applies the Requirement Item's File_Name_Prefix__c to a filename while
     *              preserving the original file extension.
     *
     * @param originalFileName  The original uploaded filename
     * @param requirementItemId Id of the Requirement_Item__c; null/blank skips prefix lookup
     * @return The final document title with prefix applied (if configured)
     */
    private static String applyFileNamePrefix(String originalFileName, String requirementItemId) {
        if (String.isBlank(requirementItemId)) {
            return originalFileName;
        }
        List<Requirement_Item__c> items = [
                SELECT Id, File_Name_Prefix__c
                FROM Requirement_Item__c
                WHERE Id = :requirementItemId
                LIMIT 1
        ];
        if (items.isEmpty() || String.isBlank(items[0].File_Name_Prefix__c)) {
            return originalFileName;
        }
        String prefix = items[0].File_Name_Prefix__c;
        String extension = originalFileName.contains('.')
                ? originalFileName.substringAfterLast('.')
                : '';
        return String.isNotBlank(extension) ? prefix + '.' + extension : prefix;
    }

    /**
     * @description Casts a raw value to the appropriate Apex type for the given SObject field.
     *
     * @param rawValue    The value from JSON deserialisation (may be String, Boolean, Decimal, etc.)
     * @param displayType Schema.DisplayType of the target field
     * @return The value cast to the correct Apex type, or null for blank/null inputs
     */
    private static Object castToFieldType(Object rawValue, Schema.DisplayType displayType) {
        if (rawValue == null) {
            return null;
        }
        String stringValue = String.valueOf(rawValue);
        if (String.isBlank(stringValue)) {
            return null;
        }

        if (displayType == Schema.DisplayType.BOOLEAN) {
            return Boolean.valueOf(stringValue);
        } else if (displayType == Schema.DisplayType.DATE) {
            return Date.valueOf(stringValue);
        } else if (displayType == Schema.DisplayType.DATETIME) {
            return Datetime.valueOf(stringValue);
        } else if (displayType == Schema.DisplayType.DOUBLE
                || displayType == Schema.DisplayType.CURRENCY
                || displayType == Schema.DisplayType.PERCENT) {
            return Decimal.valueOf(stringValue);
        } else if (displayType == Schema.DisplayType.INTEGER || displayType == Schema.DisplayType.LONG) {
            return Integer.valueOf(stringValue);
        }
        return stringValue;
    }
}