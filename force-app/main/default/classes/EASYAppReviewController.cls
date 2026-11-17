public with sharing class EASYAppReviewController {

    // Instance state for a single getApplicationControl call. A fresh instance is created
    // per call (see getApplicationControl below) so this class is safe to invoke more than
    // once within the same transaction — these were previously static fields shared across
    // the whole transaction, which made the class non-reentrant.
    private Map<Id, Requirement__c> requirements;
    private Map<Id, Requirement_Item__c> requirementItems;
    private Map<String, RelatedObjectData> requirementItemIdRelatedObjectData;
    private Map<String, RelatedObjectData> referenceQuestionFieldData;
    private Map<Id, Requirement_Response__c> requirementResponses;
    private Map<Id, Question__c> questions;
    private Map<Id, Question_Response__c> questionResponses;
    private Map<Id, Question_Response__c> questionResponsesByQuestionId;
    private Map<Id, Question_Dependency__c> questionDependenciesByQuestionId;
    private Map<Id, EASYAppRequirementItemWrapper> documentLinkByRequirementId;
    private Map<Id, SObject> referenceAnswers;
    private Map<String, List<SObject>> relatedObjectAnswersByRequirementId;
    private Contact contactRecord;
    private Application__c applicationRecord;
    private Id contactId;

    // Cache of sObject field describes for this instance's call, keyed by object name.
    private Map<String, Map<String, SObjectField>> sObjectFieldMap;

    // Wrapper class for related object data
    private class RelatedObjectData {
        public String objectName { get; set; }
        public Set<String> objectFields { get; set; }
        public List<Id> questionIds { get; set; }
        public Map<String, String> fieldMapLabel { get; set; }
        public String whereClause { get; set; }
        public List<String> whereIds { get; set; }
        public String query { get; set; }
    }

    // Translates record types to appropriate field API names to land answers
    private static final Map<String, String> fieldRecTypeFieldName = new Map<String, String>{
            'Address' => 'Address',
            'Checkbox' => 'ValueCheckbox__c',
            'Currency' => 'ValueCurrency__c',
            'Date' => 'ValueDate__c',
            'DateTime' => 'ValueDateTime__c',
            'Decimal' => 'ValueNumber__c',
            'Email' => 'ValueEmail__c',
            'TextEncrypted' => 'ValueTextEncrypted__c',
            'Integer' => 'ValueNumber__c',
            'MultiPicklist' => 'ValueLongTextArea__c',
            'Percent' => 'ValuePercent__c',
            'Phone' => 'ValuePhone__c',
            'Picklist' => 'ValueText__c',
            'Reference' => 'ValueText__c',
            'Text' => 'ValueText__c',
            'TextArea' => 'ValueTextArea__c',
            'LongTextArea' => 'ValueLongTextArea__c',
            'URL' => 'ValueURL__c'
    };

    // Method to get applicant information
    @AuraEnabled(Cacheable=true)
    public static Application__c getApplicantInfo(String appId) {
        if (String.isBlank(appId)) {
            return null;
        }
        List<Application__c> results = [
                SELECT Id, Name, Contact__c, Contact__r.FirstName, Contact__r.LastName
                FROM Application__c
                WHERE Id = :appId
                WITH USER_MODE
                LIMIT 1
        ];
        return results.isEmpty() ? null : results[0];
    }

    // Method to set SObject field map for field describes and cache them
    private Map<String, Map<String, SObjectField>> setSObjectFieldMap(String objectName) {
        if (sObjectFieldMap == null) {
            sObjectFieldMap = new Map<String, Map<String, SObjectField>>();
        }
        if (!sObjectFieldMap.containsKey(objectName)) {
            Type t = Type.forName(objectName);
            SObject sObj = (SObject) t.newInstance();
            Map<String, SObjectField> sObjectField = sObj.getSObjectType().getDescribe().fields.getMap();
            sObjectFieldMap.put(objectName, sObjectField);
        }
        return sObjectFieldMap;
    }

    // Method to get application control information. A new instance is created per call so
    // the working state above never bleeds between invocations in the same transaction.
    @AuraEnabled(Cacheable=true)
    public static EASYAppWrapper getApplicationControl(String appId) {
        return new EASYAppReviewController().buildApplicationControl(appId);
    }

    private EASYAppWrapper buildApplicationControl(String appId) {

        // Initialize application record and wrapper
        applicationRecord = new Application__c();
        EASYAppWrapper appWrapper = new EASYAppWrapper();

        if (String.isBlank(appId)) {
            return appWrapper;
        }

        // Query application record
        List<Application__c> appList = [
                SELECT Id, Contact__c, Application_Control__c
                FROM Application__c
                WHERE Id = :appId
                WITH USER_MODE
        ];

        if (appList.isEmpty()) {
            return appWrapper;
        }
        applicationRecord = appList[0];

        if (applicationRecord != null) {
            Id appControlId = applicationRecord.Application_Control__c;
            contactId = applicationRecord.Contact__c;

            List<Application_Control__c> appControlList = [
                    SELECT Id, Name, Academic_Level__c, Active__c, Degree_Levels__c, School_College__c
                    FROM Application_Control__c
                    WHERE Id = :appControlId
                    AND Active__c = TRUE
            ];

            if (appControlList.isEmpty()) {
                return appWrapper;
            }
            Application_Control__c appControl = appControlList[0];

            appWrapper.appControl = appControl;
            appWrapper.requirements = new List<EASYAppRequirementWrapper>();

            if (appControl != null) {

                // Query requirements for the application
                requirements = new Map<Id, Requirement__c>([
                        SELECT Id, Name, Active__c, Display_on_Admin_Review_Pages__c, Label__c, Display_Order__c, Application_Status__c,
                                Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c,
                                Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c,
                                Intended_Program__c, Applicant_Type__c, Citizenship__c, School_College__c, Delivery_Type__c,
                                Residency__c, Student_Type__c, Degree_Type__c
                        FROM Requirement__c
                        WHERE Application_Control__c = :appControlId
                        AND Active__c = TRUE
                        AND Display_on_Admin_Review_Pages__c = TRUE
                        AND Show_on_Application_Creation__c = FALSE
                        WITH USER_MODE
                        ORDER BY Display_Order__c NULLS LAST
                ]);

                // Query requirement items for the application
                requirementItems = new Map<Id, Requirement_Item__c>(
                [
                        SELECT Id, Name, Requirement__c, Active__c, Instructions__c, Label__c, Required__c,
                                Display_Order__c, RecordType.DeveloperName, Application_Control__c, Display_on_Admin_Review_Pages__c,
                                Related_List_Object__c, Related_Object_Record_Type_ID__c, Related_List_Where_Clause__c, Application_Status__c,
                                Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c,
                                Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c,
                                Intended_Program__c, Applicant_Type__c, Citizenship__c, School_College__c, Delivery_Type__c,
                                Residency__c, Student_Type__c, Degree_Type__c
                        FROM Requirement_Item__c
                        WHERE Requirement__c IN :requirements.keySet()
                        // AND Application_Control__c = :appControlId
                        AND Active__c = TRUE
                        AND Display_on_Admin_Review_Pages__c = TRUE
                        WITH USER_MODE
                        ORDER BY Display_Order__c NULLS LAST
                ]);

                // Query questions for the application
                questions = new Map<Id, Question__c>([
                        SELECT Id, Name, Requirement_Item__c, Active__c, Additional_Field_Validation__c, Application_Field__c, Assistive_Text__c,
                                Dependency_Behavior__c, Dependency_Logic__c, Display_as_Picklist__c, Display_on_Admin_Review_Pages__c,
                                Display_Order__c, Help_Text__c, Label__c, Static_Text__c, Contact_Field__c, RecordType.DeveloperName, Required__c,
                                Related_Object__c, Related_Object_Field__c, Name_Field_API_Name__c, Requirement_Item__r.Related_List_Where_Clause__c,
                                Requirement_Item__r.Related_List_Object_Master_Field__c, Requirement_Item__r.Related_List_Object__c,
                                Requirement_Item__r.Related_List_Object_Master__c, Requirement_Item__r.RecordType.DeveloperName, Lookup_Object__c,
                                Requirement_Item__r.Related_Object_Record_Type_ID__c, Application_Status__c, Generic_Filter_1__c, Generic_Filter_2__c,
                                Generic_Filter_3__c, Generic_Filter_4__c, Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c,
                                Intended_Program__c, Applicant_Type__c, Citizenship__c, School_College__c, Delivery_Type__c,
                                Residency__c, Student_Type__c, Degree_Type__c
                        FROM Question__c
                        WHERE Requirement_Item__c IN :requirementItems.keySet()
                        AND Display_on_Admin_Review_Pages__c = TRUE
                        AND Active__c = TRUE
                        WITH USER_MODE
                        ORDER BY Display_Order__c NULLS LAST
                ]);

                // Query requirement responses for the application
                requirementResponses = new Map<Id, Requirement_Response__c>([
                        SELECT Id, Name, Requirement_Item__c, Viewed__c, Status__c, ValueTextEntry__c, Has_Child_Requirement__c,
                                HasDocument__c, Related_Record__c, Requirement_Item__r.RecordType.DeveloperName, Original_Uploaded_Document_File_Name__c
                        FROM Requirement_Response__c
                        WHERE Requirement_Item__c IN :requirementItems.keySet()
                        AND Application__c = :appId
                        WITH USER_MODE
                ]);

                // Query question responses for the application
                questionResponses = new Map<Id, Question_Response__c>(
                [
                        SELECT Id, Name, Question_Label__c, IsShown__c, IsComplete__c, IsPopulated__c, IsRequired__c, Application__c,
                                Requirement_Response__r.Requirement_Item__c, Question__c, ValueText__c, ValueCheckbox__c,
                                ValueCurrency__c, ValueDate__c, ValueDateTime__c, ValueEmail__c, ValueLongTextArea__c,
                                ValueNumber__c, ValuePercent__c, ValuePhone__c, ValueTextArea__c, ValueTextEncrypted__c,
                                ValueURL__c, Street__c, State__c, City__c, PostalCode__c, Country__c, Question__r.RecordType.DeveloperName,
                                Question__r.Lookup_Object__c
                        FROM Question_Response__c
                        WHERE Requirement_Response__r.Requirement_Item__c IN :requirementItems.keySet()
                        AND Application__c = :appId
                        WITH USER_MODE
                        ORDER BY CreatedDate DESC NULLS LAST
                ]
                );

                // Initialize maps for related object data and reference question field data
                requirementItemIdRelatedObjectData = new Map<String, RelatedObjectData>();
                referenceQuestionFieldData = new Map<String, RelatedObjectData>();
                Set<String> contactFieldsToQuery = new Set<String>();
                Set<String> applicationFieldsToQuery = new Set<String>();

                // Pre-cache object field maps and seed base application filter fields once,
                // outside the question loop so we don't repeat describe calls per question.
                setSObjectFieldMap('contact');
                setSObjectFieldMap('application__c');
                applicationFieldsToQuery.addAll(new Set<String>{
                        'application_status__c', 'generic_filter_1__c', 'generic_filter_2__c',
                        'generic_filter_3__c', 'generic_filter_4__c', 'generic_filter_5__c',
                        'generic_filter_6__c', 'generic_filter_7__c', 'generic_filter_8__c',
                        'intended_program__c', 'applicant_type__c', 'citizenship__c',
                        'school_college__c', 'delivery_type__c', 'residency__c',
                        'student_type__c', 'degree_type__c'
                });

                // Process questions to build reference and related object queries
                for (Question__c q : questions.values()) {

                    // Build reference queries
                    String refQueryField = '';
                    if (q.RecordType.DeveloperName.equalsIgnoreCase('reference')) {

                        String refObjectKey = q.Lookup_Object__c.toLowerCase();
                        if (String.isNotBlank(q.Name_Field_API_Name__c)) {
                            refQueryField = q.Name_Field_API_Name__c;
                        }

                        refQueryField = refQueryField.toLowerCase();

                        if (referenceQuestionFieldData.containsKey(refObjectKey)) {
                            RelatedObjectData rod = referenceQuestionFieldData.get(refObjectKey);
                            rod.objectFields.add(refQueryField);
                            rod.fieldMapLabel.put(refQueryField, q.Label__c);
                            rod.questionIds.add(q.Id);
                        } else {
                            RelatedObjectData newROD = new RelatedObjectData();
                            newROD.objectName = refObjectKey;
                            newROD.objectFields = new Set<String>{
                                    refQueryField
                            };
                            newROD.objectFields.add(refQueryField);
                            newROD.questionIds = new List<Id>{
                                    q.Id
                            };
                            newROD.fieldMapLabel = new Map<String, String>{
                                    refQueryField => q.Label__c
                            };
                            newROD.whereIds = new List<Id>();
                            newROD.whereClause = '';

                            if (String.isNotBlank(q.Requirement_Item__r.Related_List_Where_Clause__c)) {
                                newROD.whereClause += ' AND ' + q.Requirement_Item__r.Related_List_Where_Clause__c;
                            }
                            referenceQuestionFieldData.put(refObjectKey, newROD);
                        }

                    }

                    // Build related object queries
                    if (q.Requirement_Item__r.RecordType.DeveloperName.equalsIgnoreCase('related_object')) {
                        String relatedQueryField = '';
                        String relatedObjectKey = q.Requirement_Item__c;
                        if (String.isNotBlank(q.Related_Object_Field__c)) {
                            relatedQueryField = q.Related_Object_Field__c;
                        }

                        relatedQueryField = relatedQueryField.toLowerCase();
                        //remove all spaces from relatedQueryField
                        relatedQueryField = relatedQueryField.replaceAll(' ', '');
                        List<String> relatedQueryFields = relatedQueryField.split(',');
                        //remove spaces from fields
                        setSObjectFieldMap(q.Related_Object__c);
                        //Check if field related query fields exists in object field map or remove it from the list
                        for (Integer i = relatedQueryFields.size() - 1; i >= 0; i--) {
                            if (!sObjectFieldMap.get(q.Related_Object__c).containsKey(relatedQueryFields[i])) {
                                relatedQueryFields.remove(i);
                            }
                        }
                        //Turn relatedQueryFields into a set
                        Set<String> relatedQueryFieldsSet = new Set<String>(relatedQueryFields);
                        if (requirementItemIdRelatedObjectData.containsKey(relatedObjectKey)) {
                            RelatedObjectData rod = requirementItemIdRelatedObjectData.get(relatedObjectKey);
                            rod.objectFields.addAll(relatedQueryFieldsSet);
                            rod.fieldMapLabel.put(relatedQueryField, q.Label__c);
                            rod.questionIds.add(q.Id);
                        } else {
                            RelatedObjectData newROD = new RelatedObjectData();
                            newROD.objectName = q.Related_Object__c.toLowerCase();
                            newROD.objectFields = new Set<String>{
                            };
                            newROD.objectFields.addAll(relatedQueryFieldsSet);
                            newROD.questionIds = new List<Id>{
                                    q.Id
                            };
                            newROD.fieldMapLabel = new Map<String, String>{
                                    relatedQueryField => q.Label__c
                            };

                            if (String.isNotBlank(q.Related_Object__c)) {
                                newROD.whereClause = ' WHERE ' + q.Requirement_Item__r.Related_List_Object_Master_Field__c;
                                if (q.Requirement_Item__r.Related_List_Object_Master__c == 'Application') {
                                    newROD.whereClause += ' = :appId';
                                } else if (newROD.objectName.equalsIgnoreCase('recommendation__c')) {
                                    newROD.whereClause = ' WHERE Application__c = :appId';
                                } else {
                                    newROD.whereClause += ' = :contactId';
                                }
                            }
                            if (String.isNotBlank(q.Requirement_Item__r.Related_List_Where_Clause__c)) {
                                newROD.whereClause += ' AND ' + requirementItems.get(q.Requirement_Item__c).Related_List_Where_Clause__c;
                            }
                            requirementItemIdRelatedObjectData.put(relatedObjectKey, newROD);
                        }
                    }

                    // Add contact and application fields to query sets
                    if (String.isNotBlank(q.Contact_Field__c)) {
                        Map<String, SObjectField> sObjectField = sObjectFieldMap.get('contact');
                        if (sObjectField.containsKey(q.Contact_Field__c)) {
                            contactFieldsToQuery.add(q.Contact_Field__c.toLowerCase());
                        }
                    }
                    if (String.isNotBlank(q.Application_Field__c)) {
                        Map<String, SObjectField> sObjectField = sObjectFieldMap.get('application__c');
                        if (sObjectField.containsKey(q.Application_Field__c)) {
                            applicationFieldsToQuery.add(q.Application_Field__c.toLowerCase());
                        }
                    }

                }

                // Get the relevant fields from application and contact based on those mapped in the questions
                String contactFields = String.join(new List<String>(contactFieldsToQuery), ',');
                String applicationFields = String.join(new List<String>(applicationFieldsToQuery), ',');
                contactRecord = new Contact();
                applicationRecord = new Application__c();

                if (String.isNotBlank(contactFields)) {
                    String query = 'SELECT Id, ' + contactFields + ' FROM Contact WHERE Id = :contactId';
                    contactRecord = Database.query(query, AccessLevel.USER_MODE);
                }
                if (String.isNotBlank(applicationFields)) {
                    String query = 'SELECT Id, ' + applicationFields + ' FROM Application__c WHERE Id = :appId';
                    applicationRecord = Database.query(query, AccessLevel.USER_MODE);
                }


                // Enrich referenceQuestionFieldData with reference IDs that come directly
                // from Contact/Application field mappings. This covers Reference-type questions
                // that have no Question_Response__c yet so they still resolve their display name.
                for (Question__c q : questions.values()) {
                    if (!q.RecordType.DeveloperName.equalsIgnoreCase('Reference')) continue;
                    if (String.isBlank(q.Lookup_Object__c)) continue;
                    String refKey = q.Lookup_Object__c.toLowerCase();
                    if (!referenceQuestionFieldData.containsKey(refKey)) continue;
                    String refIdStr = null;
                    if (String.isNotBlank(q.Contact_Field__c) && contactRecord.get(q.Contact_Field__c) != null) {
                        refIdStr = String.valueOf(contactRecord.get(q.Contact_Field__c));
                    }
                    if (String.isNotBlank(q.Application_Field__c) && applicationRecord.get(q.Application_Field__c) != null) {
                        refIdStr = String.valueOf(applicationRecord.get(q.Application_Field__c));
                    }
                    if (String.isNotBlank(refIdStr)) {
                        try {
                            Id.valueOf(refIdStr); // validate it's a real Id
                            if (!referenceQuestionFieldData.get(refKey).whereIds.contains(refIdStr)) {
                                referenceQuestionFieldData.get(refKey).whereIds.add(refIdStr);
                            }
                        } catch (Exception e) { /* not a valid Id — skip */ }
                    }
                }

                // Process question responses to build reference object data
                for (Question_Response__c qr : questionResponses.values()) {
                    if (String.isNotBlank(qr.Question__r.RecordTypeId)) {
                        if (qr.Question__r.RecordType.DeveloperName.equalsIgnoreCase('Reference')) {
                            if (String.isNotBlank(qr.Question__r.Lookup_Object__c)) {
                                String refKey = qr.Question__r.Lookup_Object__c.toLowerCase();
                                if (referenceQuestionFieldData.containsKey(refKey)) {
                                    if (String.isNotBlank(qr.ValueText__c)) {
                                        Id refId;
                                        try {
                                            refId = Id.valueOf(qr.ValueText__c);
                                        } catch (Exception e) {
                                            // Not a valid Id — skip
                                        }
                                        if (refId != null) {
                                            referenceQuestionFieldData.get(refKey).whereIds.add(qr.ValueText__c);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                //Generate query string for requirementIdRelatedObjectData by requirement id
                relatedObjectAnswersByRequirementId = new Map<String, List<SObject>>();
                for (String reqId : requirementItemIdRelatedObjectData.keySet()) {
                    RelatedObjectData rod = requirementItemIdRelatedObjectData.get(reqId);
                    //get rid of blank values in rod.objectFields set
                    rod.objectFields.remove('');
                    rod.query = 'SELECT Id, ' + String.join(new List<String>(rod.objectFields), ',') + ' FROM ' + rod.objectName;
                    if (String.isNotBlank(rod.whereClause)) {
                        rod.query += rod.whereClause;
                    }

                    setSObjectFieldMap(rod.objectName);
                    Map<String, SObjectField> sObjectField = sObjectFieldMap.get(rod.objectName);

                    // Every Related_Object item runs its own query (including recommendations), so the item's
                    // Related_List_Where_Clause__c decides which records it shows.
                    List<SObject> relatedObjectAnswerList = Database.query(rod.query, AccessLevel.USER_MODE);

                    //loop over relatedObjectAnswerList and if the field
                    for (SObject refObjAnswer : relatedObjectAnswerList) {
                        for (String field : rod.objectFields) {
                            //get field description and see if it is a reference field
                            if (sObjectField.keySet().contains(field)) {
                                DescribeFieldResult fieldDescribe = sObjectField.get(field).getDescribe();
                                if (fieldDescribe.getType().name().toLowerCase() == 'reference') {
                                    //Get the name of the reference object (not the name of the field)
                                    List<SObjectType> refObjectKeys = fieldDescribe.getReferenceTo();
                                    String ObjName = refObjectKeys.get(0).getDescribe().getName().toLowerCase();
                                    if (referenceQuestionFieldData.containsKey(ObjName)) {
                                        RelatedObjectData refRod = referenceQuestionFieldData.get(ObjName);
                                        String whereIdValue = String.valueOf(refObjAnswer.get(field));
                                        refRod.whereIds.add(whereIdValue);
                                    } else {
                                        RelatedObjectData newROD = new RelatedObjectData();
                                        newROD.objectName = ObjName;
                                        newROD.objectFields = new Set<String>{
                                                field
                                        };
                                        newROD.whereIds = new List<Id>{
                                                String.valueOf(refObjAnswer.get(field))
                                        };
                                        referenceQuestionFieldData.put(ObjName, newROD);
                                    }
                                }
                            }
                        }
                    }

                    if (relatedObjectAnswerList.size() > 0) {
                        //get answer field type
                        relatedObjectAnswersByRequirementId.put(reqId, relatedObjectAnswerList);
                    }
                }

                referenceAnswers = new Map<Id, SObject>();
                for (String key : referenceQuestionFieldData.keySet()) {
                    RelatedObjectData rod = referenceQuestionFieldData.get(key);
                    if (rod.whereIds.size() > 0) {
                        List<String> whereIds = rod.whereIds;
                        rod.query = 'SELECT Id, ' + String.join(new List<String>(rod.objectFields), ',') + ' FROM ' + rod.objectName + ' WHERE Id IN :whereIds';
                        //run query and get results in Map<id, SObject>
                        for (SObject obj : Database.query(rod.query, AccessLevel.USER_MODE)) {
                            referenceAnswers.put(obj.Id, obj);
                        }
                    }
                }

                //Now process dependencies across the entire application
                //Question dependencies have 4 record types: Picklist, Checkbox, Multi-select picklist, and Radio
                List<Question_Dependency__c> questionDependencies = [
                        SELECT Id, Name, Question__c, Controlling_Question__c, ValueCheckbox__c, Value__c, RecordType.Name
                        FROM Question_Dependency__c
                        WHERE Question__c IN :questions.keySet()
                        WITH USER_MODE
                ];

                questionDependenciesByQuestionId = new Map<Id, Question_Dependency__c>();
                for (Question_Dependency__c qd : questionDependencies) {
                    questionDependenciesByQuestionId.put(qd.Question__c, qd);
                }

                questionResponsesByQuestionId = new Map<Id, Question_Response__c>();
                for (Question_Response__c qr : questionResponses.values()) {
                    questionResponsesByQuestionId.put(qr.Question__c, qr);
                }

                // Get all the requirement responses that have documents attached to them
                documentLinkByRequirementId = new Map<Id, EASYAppRequirementItemWrapper>();
                Set<Id> requirementsWithDocuments = new Set<Id>();
                for (Requirement_Response__c rr : requirementResponses.values()) {
                    if (rr.Requirement_Item__r.RecordType.DeveloperName == 'Document_Upload') {
                        requirementsWithDocuments.add(rr.Id);
                    }
                }

                // Query for all the requirement response documents and map them to the requirement response id
                // ContentDocumentLink requires a non-empty IN set — skip if no document responses found
                if (!requirementsWithDocuments.isEmpty()) {
                List<ContentDocumentLink> documentLinksList = [
                        SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId IN :requirementsWithDocuments
                ];

                for (ContentDocumentLink cdl : documentLinksList) {
                    if (cdl.ContentDocumentId != null) {
                        EASYAppRequirementItemWrapper documentRelatedObjectData = new EASYAppRequirementItemWrapper();
                        documentRelatedObjectData.answerLink = '/lightning/r/ContentDocument/' + cdl.ContentDocumentId + '/view';
                        documentRelatedObjectData.answerLabel = cdl.ContentDocument.Title;
                        documentRelatedObjectData.answerValue = requirementResponses.get(cdl.LinkedEntityId).Original_Uploaded_Document_File_Name__c;
                        //get requirement item id to land response
                        Id reqItemId = requirementResponses.get(cdl.LinkedEntityId).Requirement_Item__c;
                        documentLinkByRequirementId.put(reqItemId, documentRelatedObjectData);
                    }
                }
                }
                appWrapper.requirements = buildRequirements();
            }
        }
        return appWrapper;
    }

    private List<EASYAppRequirementWrapper> buildRequirements() {
        List<EASYAppRequirementWrapper> reqWrapperList = new List<EASYAppRequirementWrapper>();
        if (requirements.size() > 0) {
            for (Id reqKey : requirements.keySet()) {
                if (ApplicationFilter.filter(applicationRecord, requirements.get(reqKey))) {
                    EASYAppRequirementWrapper reqWrapper = new EASYAppRequirementWrapper();
                    reqWrapper.requirement = requirements.get(reqKey);
                    reqWrapper.title = headingFor(reqWrapper.requirement.Label__c, reqWrapper.requirement.Name);
                    reqWrapper.requirementItems = buildRequirementItems(reqKey);
                    //find out if there are any question responses for this requirement
                    for (EASYAppRequirementItemWrapper reqItem : reqWrapper.requirementItems) {
                        reqItem.no_answers = true;
                        if (reqItem.relatedObjectAnswers != null) {
                            if (reqItem.relatedObjectAnswers.size() > 0) {
                                reqItem.no_answers = false;
                            }
                        }
                        for (EASYAppQuestionResponseWrapper qrWrapper : reqItem.questions) {
                            if (qrWrapper.answered) {
                                reqItem.no_answers = false;
                            }
                        }
                    }

                    reqWrapperList.add(reqWrapper);


                }
            }
        }
        return reqWrapperList;
    }

    private List<EASYAppRequirementItemWrapper> buildRequirementItems(Id reqKey) {
        List<EASYAppRequirementItemWrapper> requirementItemsList = new List<EASYAppRequirementItemWrapper>();
        Integer keyCount = 0;
        for (Requirement_Item__c ri : requirementItems.values()) {
            if (ri.Requirement__c == reqKey) {
                if (ApplicationFilter.filter(applicationRecord, ri)) {
                    EASYAppRequirementItemWrapper newRIWrap = new EASYAppRequirementItemWrapper();
                    newRIWrap.requirementItem = ri;
                    newRIWrap.title = headingFor(ri.Label__c, ri.Name);
                    if (ri.RecordType.DeveloperName == 'Related_Object') {
                        newRIWrap.is_related_object = true;
                    }
                    if (ri.RecordType.DeveloperName == 'Document_Upload') {
                        newRIWrap.is_document = true;
                    }
                    newRIWrap.questions = buildQuestions(ri.Id);

                    if (documentLinkByRequirementId.containsKey(ri.Id)) {
                        newRIWrap.answerLabel = documentLinkByRequirementId.get(ri.Id).answerLabel;
                        newRIWrap.answerLink = documentLinkByRequirementId.get(ri.Id).answerLink;
                        newRIWrap.answerValue = documentLinkByRequirementId.get(ri.Id).answerValue;
                    }

                    newRIWrap.requirementResponse = buildRequirementResponses(ri.Id);

                    //Check if there are any related objects to query
                    if (relatedObjectAnswersByRequirementId.containsKey(ri.Id)) {
                        newRIWrap.relatedObjectAnswers = new List<List<EASYAppQuestionResponseWrapper>>();
                        for (SObject obj : relatedObjectAnswersByRequirementId.get(ri.Id)) {
                            List<EASYAppQuestionResponseWrapper> relatedObjectAnswer = new List<EASYAppQuestionResponseWrapper>();
                            for (String field : requirementItemIdRelatedObjectData.get(ri.Id).objectFields) {
                                keyCount++;
                                field = field.toLowerCase();
                                if (String.isNotBlank(String.valueOf(obj.get(field)))) {
                                    EASYAppQuestionResponseWrapper rodItem = new EASYAppQuestionResponseWrapper();
                                    //Iterate over question ids
                                    for (Id qId : requirementItemIdRelatedObjectData.get(ri.Id).questionIds) {
                                        if (questions.containsKey(qId)) {
                                            Question__c q = questions.get(qId);
                                            if (q.Related_Object_Field__c == field) {
                                                rodItem.question = q;
                                                rodItem.valueType = q.RecordType.DeveloperName.toLowerCase();
                                                rodItem.key = UUID.randomUUID();
                                                rodItem.answerValue = '';
                                                rodItem.answerLabel = requirementItemIdRelatedObjectData.get(ri.Id).fieldMapLabel.get(field);
                                                if (rodItem.valueType.equalsIgnoreCase('reference')) {
                                                    if (String.isNotBlank(String.valueOf(obj.get(field)))) {
                                                        String answerValueId = String.valueOf(obj.get(field));
                                                        if (referenceAnswers.containsKey(answerValueId)) {
                                                            List<String> refFields = q.Name_Field_API_Name__c.split(',');
                                                            String answerValue = '';
                                                            for (String refField : refFields) {
                                                                refField = refField.trim();
                                                                if (referenceAnswers.get(answerValueId).get(refField) != null) {
                                                                    answerValue += referenceAnswers.get(answerValueId).get(refField).toString();
                                                                }
                                                                answerValue += ', ';
                                                            }
                                                            answerValue = answerValue.removeEnd(', ');
                                                            rodItem.answerValue = answerValue;
                                                            rodItem.answerLink = Url.getOrgDomainUrl().toExternalForm() + '/' + answerValueId;
                                                        }
                                                    }
                                                } else if (q.recordType.DeveloperName.equalsIgnoreCase('MultiPicklist')) {
                                                    String answerString = String.valueOf(obj.get(field));
                                                    rodItem.answerMultiValue = splitChoices(answerString);
                                                    rodItem.answerValue = String.join(splitChoices(answerString), ', ');
                                                } else {
                                                    rodItem.answerValue = String.valueOf(obj.get(field));
                                                }

                                                relatedObjectAnswer.add(rodItem);
                                            }
                                        }
                                    }
                                }
                            }
                            // A record with no populated field for this item would render an empty box.
                            if (!relatedObjectAnswer.isEmpty()) {
                            newRIWrap.relatedObjectAnswers.add(relatedObjectAnswer);
                        }
                    }
                    }

                    requirementItemsList.add(newRIWrap);
                }
            }
        }
        return requirementItemsList;
    }

    private List<EASYAppQuestionResponseWrapper> buildQuestions(Id reqItemId) {
        List<EASYAppQuestionResponseWrapper> questionsList = new List<EASYAppQuestionResponseWrapper>();
        for (Question__c q : questions.values()) {
            if (q.Requirement_Item__c != reqItemId) continue;

                EASYAppQuestionResponseWrapper qrWrapper = new EASYAppQuestionResponseWrapper();
                qrWrapper.answered = false;
                qrWrapper.question = q;
            qrWrapper.valueType = q.RecordType.DeveloperName.toLowerCase();
            qrWrapper.dependencies_met = true;
            qrWrapper.show_question = false;

                String valueField = fieldRecTypeFieldName.get(q.RecordType.DeveloperName);

            // ── 1. Attach the real question response when one exists ──────────
                if (questionResponsesByQuestionId.containsKey(q.Id)) {
                    qrWrapper.questionResponse = questionResponsesByQuestionId.get(q.Id);
                if (qrWrapper.questionResponse.IsShown__c
                        && qrWrapper.questionResponse.IsComplete__c
                        && qrWrapper.questionResponse.IsPopulated__c) {
                    qrWrapper.answered = true;
                }
            }

            // ── 2. Apply live Contact / Application field value ───────────────
            // Runs regardless of whether a real QR exists. When there is no QR
            // a lightweight synthetic record is created just to carry the value.
            // A non-null live value always marks the question as answered in the
            // review context, regardless of QR completion flags.
                    if (String.isNotBlank(valueField) && !valueField.equalsIgnoreCase('Address')) {
                Object liveValue = null;

                if (String.isNotBlank(q.Contact_Field__c)
                        && contactRecord.get(q.Contact_Field__c) != null) {
                    liveValue = contactRecord.get(q.Contact_Field__c);
                }
                // Application field wins over Contact field when both are mapped
                if (String.isNotBlank(q.Application_Field__c)
                        && applicationRecord.get(q.Application_Field__c) != null) {
                    liveValue = applicationRecord.get(q.Application_Field__c);
                }

                if (liveValue != null) {
                    if (qrWrapper.questionResponse == null) {
                        // No real QR — create a lightweight synthetic holder (display only)
                        qrWrapper.questionResponse = new Question_Response__c();
                        qrWrapper.questionResponse.Question__c = q.Id;
                    }
                    // Clear other value slots to prevent stale data bleed-through
                            for (String valField : fieldRecTypeFieldName.values()) {
                                if (!valField.equalsIgnoreCase('Address')) {
                                    qrWrapper.questionResponse.put(valField, null);
                                }
                            }
                    qrWrapper.questionResponse.put(valueField, liveValue);
                        qrWrapper.answered = true;
                    }
                }

            // ── 2b. Address questions mapped to a Contact / Application address ─
            // The applicant may never have saved a response for these (the address lives on the Contact), so
            // read the live address the question is mapped to, exactly as step 2 does for the other types.
            if (q.RecordType.DeveloperName.equalsIgnoreCase('Address')) {
                applyLiveAddress(q, qrWrapper);
            }

            // ── 3. Resolve display values for Reference and MultiPicklist ─────
            if (qrWrapper.questionResponse != null) {
                if (q.RecordType.DeveloperName.equalsIgnoreCase('Reference')) {
                    String refVal = qrWrapper.questionResponse.ValueText__c;
                    if (String.isNotBlank(refVal) && referenceAnswers.containsKey(refVal)) {
                        qrWrapper.answerLabel = referenceAnswers.get(refVal)
                                .get(q.Name_Field_API_Name__c).toString();
                        qrWrapper.answerLink = Url.getOrgDomainUrl().toExternalForm() + '/' + refVal;
                        }
                    }
                // A multi-select answer is shown as one pill per choice. The choices are usually saved in
                // ValueLongTextArea__c, but a response (or a mapped Contact/Application text field) can hold the
                // semicolon-separated text in another text field, so use the first text field that has a value.
                if (q.RecordType.DeveloperName.equalsIgnoreCase('MultiPicklist')) {
                    Question_Response__c multiResponse = qrWrapper.questionResponse;
                    qrWrapper.answerMultiValue = splitChoices(firstNonBlank(
                            new List<String>{
                                    multiResponse.ValueLongTextArea__c, multiResponse.ValueText__c, multiResponse.ValueTextArea__c
                            }
                    ));
                    }
                }

            // The template shows an address when any part of it is filled in, not only the street.
            if (qrWrapper.questionResponse != null) {
                qrWrapper.hasAddress = hasAnyAddressPart(qrWrapper.questionResponse);
            }

            // ── 4. Evaluate question dependencies ─────────────────────────────
                if (questionDependenciesByQuestionId.containsKey(q.Id)) {
                    Question_Dependency__c qd = questionDependenciesByQuestionId.get(q.Id);
                Question_Response__c ctrlQR = questionResponsesByQuestionId.get(qd.Controlling_Question__c);
                if (ctrlQR == null) {
                        qrWrapper.dependencies_met = false;
                } else if (qd.RecordType.Name == 'Picklist' || qd.RecordType.Name == 'Radio') {
                    if (qd.Value__c != ctrlQR.ValueText__c) {
                            qrWrapper.dependencies_met = false;
                        }
                    } else if (qd.RecordType.Name == 'Checkbox') {
                    if (Boolean.valueOf(qd.ValueCheckbox__c) != ctrlQR.ValueCheckbox__c) {
                            qrWrapper.dependencies_met = false;
                        }
                    } else if (qd.RecordType.Name == 'MultiPicklist') {
                    if (String.isNotBlank(ctrlQR.ValueText__c)) {
                        List<String> ctrlValues = ctrlQR.ValueText__c.split(';');
                        if (!ctrlValues.contains(qd.Value__c)) {
                                qrWrapper.dependencies_met = false;
                            }
                        }
                    }
                }

                if (qrWrapper.dependencies_met && (qrWrapper.answered || String.isNotBlank(q.Static_Text__c))) {
                    qrWrapper.show_question = true;
                }
                questionsList.add(qrWrapper);
            }
        return questionsList;
    }

    // Splits semicolon-separated choices into trimmed, non-empty values; null when there is nothing to show
    // (an empty list would still look "present" to the template).
    private List<String> splitChoices(String choices) {
        if (String.isBlank(choices)) {
            return null;
        }
        List<String> trimmed = new List<String>();
        for (String choice : choices.split(';')) {
            if (String.isNotBlank(choice)) {
                trimmed.add(choice.trim());
            }
        }
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String firstNonBlank(List<String> candidates) {
        for (String candidate : candidates) {
            if (String.isNotBlank(candidate)) {
                return candidate;
            }
        }
        return null;
    }

    // Same heading rule as the applicant-side pages: the Label, falling back to the Name when the Label is blank.
    private String headingFor(String label, String name) {
        return String.isNotBlank(label) ? label : name;
    }

    // Copies the address a question is mapped to (for example Contact.MailingAddress) onto its response.
    private void applyLiveAddress(Question__c q, EASYAppQuestionResponseWrapper qrWrapper) {
        Object liveValue = null;
        if (String.isNotBlank(q.Contact_Field__c)) {
            Object contactValue = readFieldOrNull(contactRecord, q.Contact_Field__c);
            if (contactValue != null) {
                liveValue = contactValue;
            }
        }
        // Application field wins over Contact field when both are mapped
        if (String.isNotBlank(q.Application_Field__c)) {
            Object applicationValue = readFieldOrNull(applicationRecord, q.Application_Field__c);
            if (applicationValue != null) {
                liveValue = applicationValue;
            }
        }
        if (!(liveValue instanceof Address)) {
            return;
        }
        Address liveAddress = (Address) liveValue;
        String stateText = String.isNotBlank(liveAddress.getState()) ? liveAddress.getState() : liveAddress.getStateCode();
        String countryText = String.isNotBlank(liveAddress.getCountry()) ? liveAddress.getCountry() : liveAddress.getCountryCode();
        if (String.isBlank(liveAddress.getStreet()) && String.isBlank(liveAddress.getCity())
                && String.isBlank(stateText) && String.isBlank(liveAddress.getPostalCode()) && String.isBlank(countryText)) {
            return;
        }
        if (qrWrapper.questionResponse == null) {
            // No saved response: a lightweight holder for display only
            qrWrapper.questionResponse = new Question_Response__c();
            qrWrapper.questionResponse.Question__c = q.Id;
        }
        qrWrapper.questionResponse.Street__c = liveAddress.getStreet();
        qrWrapper.questionResponse.City__c = liveAddress.getCity();
        qrWrapper.questionResponse.State__c = stateText;
        qrWrapper.questionResponse.PostalCode__c = liveAddress.getPostalCode();
        qrWrapper.questionResponse.Country__c = countryText;
        qrWrapper.answered = true;
    }

    // Reads a field by name; null when the record was not queried with that field.
    private Object readFieldOrNull(SObject record, String fieldName) {
        try {
            return record.get(fieldName);
        } catch (SObjectException fieldNotAvailable) {
            return null;
        }
    }

    private Boolean hasAnyAddressPart(Question_Response__c response) {
        return String.isNotBlank(response.Street__c) || String.isNotBlank(response.City__c)
                || String.isNotBlank(response.State__c) || String.isNotBlank(response.PostalCode__c)
                || String.isNotBlank(response.Country__c);
    }

    private List<Requirement_Response__c> buildRequirementResponses(Id reqItemId) {
        List<Requirement_Response__c> requirementResponsesList = new List<Requirement_Response__c>();
        for (Requirement_Response__c r : requirementResponses.values()) {
            if (r.Requirement_Item__c == reqItemId) {
                requirementResponsesList.add(r);
            }
        }
        return requirementResponsesList;
    }

}