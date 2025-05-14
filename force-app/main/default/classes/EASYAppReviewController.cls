public with sharing class EASYAppReviewController {

    // Static maps to store various data related to requirements, questions, and responses
    private static Map<Id, Requirement__c> requirements { get; set; }
    private static Map<Id, Requirement_Item__c> requirementItems { get; set; }
    private static Map<String, RelatedObjectData> requirementItemIdRelatedObjectData { get; set; }
    private static Map<String, RelatedObjectData> referenceQuestionFieldData { get; set; }
    private static Map<Id, Requirement_Response__c> requirementResponses { get; set; }
    private static Map<Id, Question__c> questions { get; set; }
    private static Map<Id, Question_Response__c> questionResponses { get; set; }
    private static Map<Id, Question_Response__c> questionResponsesByQuestionId { get; set; }
    private static Map<Id, Question_Dependency__c> questionDependenciesByQuestionId { get; set; }
    private static Map<Id, EASYAppRequirementItemWrapper> documentLinkByRequirementId { get; set; }
    private static Map<Id, SObject> referenceAnswers { get; set; }
    private static Map<String, List<SObject>> relatedObjectAnswersByRequirementId { get; set; }
    private static Contact contactRecord { get; set; }
    private static Application__c applicationRecord { get; set; }
    private static Id contactId { get; set; }

    // Create a map to store the sObject fields for each object and share across classes
    public static Map<String, Map<String, SObjectField>> sObjectFieldMap { get; set; }

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
        return [
                SELECT Id, Name, Contact__c, Contact__r.FirstName, Contact__r.LastName
                FROM Application__c
                WHERE Id = :appId
                LIMIT 1
        ];
    }

    // Method to set SObject field map for field describes and cache them
    public static Map<String, Map<String, SObjectField>> setSObjectFieldMap(String objectName) {
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

    // Method to get application control information
    @AuraEnabled(Cacheable=true)
    public static EASYAppWrapper getApplicationControl(String appId) {

        // Initialize application record and wrapper
        applicationRecord = new Application__c();
        EASYAppWrapper appWrapper = new EASYAppWrapper();

        // Query application record
        applicationRecord = [
                SELECT Id, Contact__c, Application_Control__c
                FROM Application__c
                WHERE Id = :appId
        ];

        if (applicationRecord != null) {
            Id appControlId = applicationRecord.Application_Control__c;
            contactId = applicationRecord.Contact__c;

            Application_Control__c appControl = [
                    SELECT Id, Name, Academic_Level__c, Active__c, Degree_Levels__c, School_College__c
                    FROM Application_Control__c
                    WHERE Id = :appControlId
                    AND Active__c = TRUE
            ];
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
                        ORDER BY Display_Order__c NULLS LAST
                ]);

                // Query requirement responses for the application
                requirementResponses = new Map<Id, Requirement_Response__c>([
                        SELECT Id, Name, Requirement_Item__c, Viewed__c, Status__c, ValueTextEntry__c, Has_Child_Requirement__c,
                                HasDocument__c, Related_Record__c, Requirement_Item__r.RecordType.DeveloperName, Original_Uploaded_Document_File_Name__c
                        FROM Requirement_Response__c
                        WHERE Requirement_Item__c IN :requirementItems.keySet()
                        AND Application__c = :appId
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
                        WITH SECURITY_ENFORCED
                        ORDER BY CreatedDate DESC NULLS LAST
                ]
                );

                // Initialize maps for related object data and reference question field data
                requirementItemIdRelatedObjectData = new Map<String, RelatedObjectData>();
                referenceQuestionFieldData = new Map<String, RelatedObjectData>();
                Set<String> contactFieldsToQuery = new Set<String>();
                Set<String> recommendationFieldsToQuery = new Set<String>();
                Set<String> applicationFieldsToQuery = new Set<String>();

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
                        for (Integer i = 0; i < relatedQueryFields.size(); i++) {
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

                    // Get field level descriptions and cache them for later use
                    setSObjectFieldMap('contact');
                    setSObjectFieldMap('application__c');
                    setSObjectFieldMap('recommendation__c');

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
                    //Make sure application query has all filter fields. Use lowercase to match lowercased fields applied above
                    applicationFieldsToQuery.add('application_status__c');
                    applicationFieldsToQuery.add('generic_filter_1__c');
                    applicationFieldsToQuery.add('generic_filter_2__c');
                    applicationFieldsToQuery.add('generic_filter_3__c');
                    applicationFieldsToQuery.add('generic_filter_4__c');
                    applicationFieldsToQuery.add('generic_filter_5__c');
                    applicationFieldsToQuery.add('generic_filter_6__c');
                    applicationFieldsToQuery.add('generic_filter_7__c');
                    applicationFieldsToQuery.add('generic_filter_8__c');
                    applicationFieldsToQuery.add('intended_program__c');
                    applicationFieldsToQuery.add('applicant_type__c');
                    applicationFieldsToQuery.add('citizenship__c');
                    applicationFieldsToQuery.add('school_college__c');
                    applicationFieldsToQuery.add('delivery_type__c');
                    applicationFieldsToQuery.add('residency__c');
                    applicationFieldsToQuery.add('student_type__c');
                    applicationFieldsToQuery.add('degree_type__c');

                    // Add recommendation fields to query set
                    if (String.isNotBlank(q.Related_Object_Field__c) && q.Related_Object__c != null) {
                        if (q.Related_Object__c.equalsIgnoreCase('Recommendation__c')) {
                            Map<String, SObjectField> sObjectField = sObjectFieldMap.get('recommendation__c');
                            if (sObjectField.containsKey(q.Related_Object_Field__c)) {
                                recommendationFieldsToQuery.add(q.Related_Object_Field__c.toLowerCase());
                            }
                        }
                    }
                }

                // Get the relevant fields from application and contact based on those mapped in the questions
                String contactFields = String.join(new List<String>(contactFieldsToQuery), ',');
                String applicationFields = String.join(new List<String>(applicationFieldsToQuery), ',');
                String recommendationFields = String.join(new List<String>(recommendationFieldsToQuery), ',');
                contactRecord = new Contact();
                applicationRecord = new Application__c();
                List<Recommendation__c> recommendations = new List<Recommendation__c>();

                if (String.isNotBlank(contactFields)) {
                    String query = 'SELECT Id, ' + contactFields + ' FROM Contact WHERE Id = :contactId';
                    contactRecord = Database.query(query);
                }
                if (String.isNotBlank(applicationFields)) {
                    String query = 'SELECT Id, ' + applicationFields + ' FROM Application__c WHERE Id = :appId';
                    applicationRecord = Database.query(query);
                }

                if (String.isNotBlank(recommendationFields)) {
                    String query = 'SELECT Id, ' + recommendationFields + ' FROM Recommendation__c WHERE Application__c = :appId';
                    recommendations = Database.query(query);
                }

                // Process question responses to build reference object data
                for (Question_Response__c qr : questionResponses.values()) {
                    if (String.isNotBlank(qr.Question__r.RecordTypeId)) {
                        if (qr.Question__r.RecordType.DeveloperName.equalsIgnoreCase('Reference')) {
                            if (String.isNotBlank(qr.Question__r.Lookup_Object__c)) {
                                String refKey = qr.Question__r.Lookup_Object__c.toLowerCase();
                                if (referenceQuestionFieldData.containsKey(refKey)) {
                                    System.debug('qr.ValueText__c: ' + qr.ValueText__c + ', refKey: ' + refKey + ', qr.Question__r.Lookup_Object__c: ' + qr.Question__r.Lookup_Object__c + ', qr.Id: ' + qr.Id);

                                    if (String.isNotBlank(qr.ValueText__c)) {
                                        Id refId;
                                        try {
                                            refId = Id.valueOf(qr.ValueText__c);
                                        } catch (Exception e) {
                                            System.debug('Error: ' + e.getMessage());
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

                    List<SObject> relatedObjectAnswerList = new List<SObject>();
                    if (rod.objectName.equalsIgnoreCase('recommendation__c')) {
                        relatedObjectAnswerList = recommendations;
                    } else {
                        relatedObjectAnswerList = Database.query(rod.query);
                    }

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
                        for (SObject obj : Database.query(rod.query)) {
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
                appWrapper.requirements = buildRequirements();
            }
        }
        return appWrapper;
    }

    private static List<EASYAppRequirementWrapper> buildRequirements() {
        List<EASYAppRequirementWrapper> reqWrapperList = new List<EASYAppRequirementWrapper>();
        if (requirements.size() > 0) {
            for (Id reqKey : requirements.keySet()) {
                if (ApplicationFilter.filter(applicationRecord, requirements.get(reqKey))) {
                    EASYAppRequirementWrapper reqWrapper = new EASYAppRequirementWrapper();
                    reqWrapper.requirement = requirements.get(reqKey);
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

    private static List<EASYAppRequirementItemWrapper> buildRequirementItems(Id reqKey) {
        List<EASYAppRequirementItemWrapper> requirementItemsList = new List<EASYAppRequirementItemWrapper>();
        Integer keyCount = 0;
        for (Requirement_Item__c ri : requirementItems.values()) {
            if (ri.Requirement__c == reqKey) {
                if (ApplicationFilter.filter(applicationRecord, ri)) {
                    EASYAppRequirementItemWrapper newRIWrap = new EASYAppRequirementItemWrapper();
                    newRIWrap.requirementItem = ri;
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
                                                    rodItem.answerMultiValue = answerString.split(';');
                                                    if (answerString.contains(';')) {
                                                        List<String> answerList = answerString.split(';');
                                                        rodItem.answerValue = String.join(answerList, ', ');
                                                    } else {
                                                        rodItem.answerValue = String.valueOf(obj.get(field));
                                                    }
                                                } else {
                                                    rodItem.answerValue = String.valueOf(obj.get(field));
                                                }

                                                relatedObjectAnswer.add(rodItem);
                                            }
                                        }
                                    }
                                }
                            }
                            newRIWrap.relatedObjectAnswers.add(relatedObjectAnswer);
                        }
                    }

                    requirementItemsList.add(newRIWrap);
                }
            }
        }
        return requirementItemsList;
    }

    private static List<EASYAppQuestionResponseWrapper> buildQuestions(Id reqItemId) {
        List<EASYAppQuestionResponseWrapper> questionsList = new List<EASYAppQuestionResponseWrapper>();
        for (Question__c q : questions.values()) {
            if (q.Requirement_Item__c == reqItemId) {
                //Evaluate if question dependencies are met

                EASYAppQuestionResponseWrapper qrWrapper = new EASYAppQuestionResponseWrapper();
                qrWrapper.answered = false;
                qrWrapper.question = q;
                String valueField = fieldRecTypeFieldName.get(q.RecordType.DeveloperName);
                System.debug('valueField: ' + valueField);

                if (questionResponsesByQuestionId.containsKey(q.Id)) {
                    qrWrapper.questionResponse = questionResponsesByQuestionId.get(q.Id);
                    //Check if the question has a Contact_Field__c or Application_Field__c and apply the value to the question response
                    if (String.isNotBlank(valueField) && !valueField.equalsIgnoreCase('Address')) {
                        if (String.isNotBlank(q.Contact_Field__c) && contactRecord.get(q.Contact_Field__c) != null) {
                            //Clear other values
                            for (String valField : fieldRecTypeFieldName.values()) {
                                if (!valField.equalsIgnoreCase('Address')) {
                                    qrWrapper.questionResponse.put(valField, null);
                                }
                            }
                            qrWrapper.questionResponse.put(valueField, contactRecord.get(q.Contact_Field__c));
                            if(q.RecordType.DeveloperName.equalsIgnoreCase('multiPicklist')){
                                qrWrapper.answerMultiValue = contactRecord.get(q.Contact_Field__c).toString().split(';');
                            }
                        }
                        if (String.isNotBlank(q.Application_Field__c) && applicationRecord.get(q.Application_Field__c) != null) {
                            if(q.RecordType.DeveloperName.equalsIgnoreCase('multiPicklist')){
                                qrWrapper.answerMultiValue = applicationRecord.get(q.Application_Field__c).toString().split(';');
                            }
                            qrWrapper.questionResponse.put(valueField, applicationRecord.get(q.Application_Field__c));
                        }
                    }

                    if (qrWrapper.questionResponse.IsShown__c && qrWrapper.questionResponse.IsComplete__c && qrWrapper.questionResponse.IsPopulated__c) {
                        qrWrapper.answered = true;
                    }
                    //qrWrapper.answered = true;
                }
                qrWrapper.valueType = q.RecordType.DeveloperName.toLowerCase();
                qrWrapper.dependencies_met = true;

                qrWrapper.show_question = false;
                if (q.RecordType.DeveloperName.equalsIgnoreCase('Reference')) {
                    if (String.isNotBlank(qrWrapper.questionResponse.ValueText__c)) {
                        if (referenceAnswers.containsKey(qrWrapper.questionResponse.ValueText__c)) {
                            qrWrapper.answerLabel = referenceAnswers.get(qrWrapper.questionResponse.ValueText__c).get(q.Name_Field_API_Name__c).toString();
                            qrWrapper.answerLink = Url.getOrgDomainUrl().toExternalForm() + '/' + qrWrapper.questionResponse.ValueText__c;
                        }
                    }
                }
                if (q.RecordType.DeveloperName.equalsIgnoreCase('MultiPicklist')) {
                    System.debug('MultiPicklist: ' + qrWrapper.questionResponse.ValueText__c);
                    if(String.isNotBlank(qrWrapper.questionResponse.ValueText__c)){
                        qrWrapper.answerMultiValue = qrWrapper.questionResponse.ValueText__c.split(';');
                    }
                }

                if (questionDependenciesByQuestionId.containsKey(q.Id)) {
                    Question_Dependency__c qd = questionDependenciesByQuestionId.get(q.Id);
                    if (questionResponsesByQuestionId.get(qd.Controlling_Question__c) == null) {
                        qrWrapper.dependencies_met = false;
                    } else if (qd.RecordType.Name == 'Picklist') {
                        if (qd.Value__c != questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueText__c) {
                            qrWrapper.dependencies_met = false;
                        }
                    } else if (qd.RecordType.Name == 'Checkbox') {
                        if (Boolean.valueOf(qd.ValueCheckbox__c) != questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueCheckbox__c) {
                            qrWrapper.dependencies_met = false;
                        }
                    } else if (qd.RecordType.Name == 'MultiPicklist') {
                        if (questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueText__c != null) {
                            List<String> controllingValues = questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueText__c.split(';');
                            if (!controllingValues.contains(qd.Value__c)) {
                                qrWrapper.dependencies_met = false;
                            }
                        }
                    } else if (qd.RecordType.Name == 'Radio') {
                        if (qd.Value__c != questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueText__c) {
                            qrWrapper.dependencies_met = false;
                        }
                    }
                }

                if (qrWrapper.dependencies_met && (qrWrapper.answered || String.isNotBlank(q.Static_Text__c))) {
                    qrWrapper.show_question = true;
                }
                questionsList.add(qrWrapper);
            }
        }
        return questionsList;
    }

    private static List<Requirement_Response__c> buildRequirementResponses(Id reqItemId) {
        List<Requirement_Response__c> requirementResponsesList = new List<Requirement_Response__c>();
        for (Requirement_Response__c r : requirementResponses.values()) {
            if (r.Requirement_Item__c == reqItemId) {
                requirementResponsesList.add(r);
            }
        }
        return requirementResponsesList;
    }

}