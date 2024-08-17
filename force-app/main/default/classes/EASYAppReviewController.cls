public with sharing class EASYAppReviewController {

    private static Map<Id, Requirement__c> requirements { get; set; }
    private static Map<Id, Requirement_Item__c> requirementItems { get; set; }
    private static Map<String, RelatedObjectData> requirementItemIdRelatedObjectData { get; set; }
    private static Map<String, RelatedObjectData> referenceQuestionFieldData { get; set; }
    private static Map<Id, Requirement_Response__c> requirementResponses { get; set; }
    private static Map<Id, Question__c> questions { get; set; }
    private static Map<Id, Question_Response__c> questionResponses { get; set; }
    private static Map<Id, Question_Response__c> questionResponsesByQuestionId { get; set; }
    private static Map<Id, Question_Dependency__c> questionDependenciesByQuestionId { get; set; }
    private static Contact contactRecord { get; set; }
    private static Application__c applicationRecord { get; set; }
    private static Id contactId { get; set; }

    //Make a wrapper class for related object data
    public class RelatedObjectData {
        public String objectName { get; set; }
        public Set<String> objectFields { get; set; }
        public List<Id> questionIds { get; set; }
        public Map<String, String> fieldMapLabel { get; set; }
        public String whereClause { get; set; }
        public List<String> whereIds { get; set; }
        public String query { get; set; }
    }

    public class RelatedObjectDataItem {
        @AuraEnabled public String key { get; set; }
        @AuraEnabled public String fieldApi { get; set; }
        @AuraEnabled public String fieldValue { get; set; }
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public String fieldType { get; set; }
    }

    @AuraEnabled(Cacheable=true)
    public static Application__c getApplicantInfo(String appId) {
        return [
                SELECT Id, Name, Contact__c, Contact__r.FirstName, Contact__r.LastName
                FROM Application__c
                WHERE Id = :appId
                LIMIT 1
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static EASYAppWrapper getApplicationControl(String appId) {

        // Get Contact information for application
        applicationRecord = new Application__c();
        EASYAppWrapper appWrapper = new EASYAppWrapper();

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

                // Get the required requirements for the application
                requirements = new Map<Id, Requirement__c>([
                        SELECT Id, Name, Active__c, Display_on_Admin_Review_Pages__c, Label__c, Display_Order__c
                        FROM Requirement__c
                        WHERE Application_Control__c = :appControlId
                        AND Active__c = TRUE
                        AND Display_on_Admin_Review_Pages__c = TRUE
                        ORDER BY Display_Order__c
                ]);

                // Get the required items for the application
                requirementItems = new Map<Id, Requirement_Item__c>(
                [
                        SELECT Id, Name, Requirement__c, Active__c, Instructions__c, Label__c, Required__c,
                                Display_Order__c, RecordType.DeveloperName, Application_Control__c, Display_on_Admin_Review_Pages__c,
                                Related_List_Object__c
                        FROM Requirement_Item__c
                        WHERE Requirement__c IN :requirements.keySet()
                        // AND Application_Control__c = :appControlId
                        AND Active__c = TRUE
                        AND Display_on_Admin_Review_Pages__c = TRUE
                        ORDER BY Display_Order__c
                ]);

                //Get the Questions
                questions = new Map<Id, Question__c>([
                        SELECT Id, Name, Requirement_Item__c, Active__c, Additional_Field_Validation__c, Application_Field__c, Assistive_Text__c,
                                Dependency_Behavior__c, Dependency_Logic__c, Display_as_Picklist__c, Display_on_Admin_Review_Pages__c,
                                Display_Order__c, Help_Text__c, Label__c, Static_Text__c, Contact_Field__c, RecordType.DeveloperName, Required__c,
                                Related_Object__c, Related_Object_Field__c, Name_Field_API_Name__c, Requirement_Item__r.Related_List_Where_Clause__c,
                                Requirement_Item__r.Related_List_Object_Master_Field__c, Requirement_Item__r.Related_List_Object__c,
                                Requirement_Item__r.Related_List_Object_Master__c, Requirement_Item__r.RecordType.DeveloperName, Lookup_Object__c
                        FROM Question__c
                        WHERE Requirement_Item__c IN :requirementItems.keySet()
                        AND Display_on_Admin_Review_Pages__c = TRUE
                        AND Active__c = TRUE
                        ORDER BY Display_Order__c
                ]);

                //Get the Requirement Responses
                requirementResponses = new Map<Id, Requirement_Response__c>([
                        SELECT Id, Name, Requirement_Item__c, Viewed__c, Status__c, ValueTextEntry__c, Has_Child_Requirement__c,
                                HasDocument__c, Related_Record__c, Requirement_Item__r.RecordType.DeveloperName
                        FROM Requirement_Response__c
                        WHERE Requirement_Item__c IN :requirementItems.keySet()
                        AND Application__c = :appId
                ]);

                //Get the Question Responses
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

                //Use the wrapper class RelatedObjectData to store a list of related object data using the questions query above by requirement_item__c
                //This will allow us to query all related objects in one query

                requirementItemIdRelatedObjectData = new Map<String, RelatedObjectData>();
                referenceQuestionFieldData = new Map<String, RelatedObjectData>();
                Set<String> contactFieldsToQuery = new Set<String>();
                Set<String> applicationFieldsToQuery = new Set<String>();
                for (Question__c q : questions.values()) {

                    // Build reference queries
                    if (q.RecordType.DeveloperName.equalsIgnoreCase('reference')) {
                        referenceQuestionFieldData = buildRelatedObjectDataItem(referenceQuestionFieldData, q.Lookup_Object__c.toLowerCase(), q, true);
                    }

                    //Build related object queries
                    if (q.Requirement_Item__r.RecordType.DeveloperName.equalsIgnoreCase('related_object')) {
                        requirementItemIdRelatedObjectData = buildRelatedObjectDataItem(requirementItemIdRelatedObjectData, q.Related_Object__c.toLowerCase(), q, false);
                    }

                    if (String.isNotBlank(q.Contact_Field__c)) {
                        contactFieldsToQuery.add(q.Contact_Field__c.toLowerCase());
                    }
                    if (String.isNotBlank(q.Application_Field__c)) {
                        applicationFieldsToQuery.add(q.Application_Field__c.toLowerCase());
                    }
                }

                //Generate query string for requirementIdRelatedObjectData by requirement id
                for (String reqId : requirementItemIdRelatedObjectData.keySet()) {
                    RelatedObjectData rod = requirementItemIdRelatedObjectData.get(reqId);
                    rod.query = 'SELECT Id, ' + String.join(new List<String>(rod.objectFields), ',') + ' FROM ' + rod.objectName;
                    if (String.isNotBlank(rod.whereClause)) {
                        rod.query += rod.whereClause;
                    }
                    rod.query = rod.query.toLowerCase();
                }

                // Get the relevant fields from application and contact based on those mapped in the questions
                String contactFields = String.join(new List<String>(contactFieldsToQuery), ',');
                String applicationFields = String.join(new List<String>(applicationFieldsToQuery), ',');
                contactRecord = new Contact();
                applicationRecord = new Application__c();

                if (String.isNotBlank(contactFields)) {
                    String query = 'SELECT Id, ' + contactFields + ' FROM Contact WHERE Id = :contactId';
                    contactRecord = Database.query(query);
                }
                if (String.isNotBlank(applicationFields)) {
                    String query = 'SELECT Id, ' + applicationFields + ' FROM Application__c WHERE Id = :appId';
                    applicationRecord = Database.query(query);
                }

                // Get all the requirement responses that have documents attached to them
/*                Map<Id, ContentDocumentLink> documentLinks = new Map<Id, ContentDocumentLink>();
                for (Requirement_Response__c rr : requirementResponses.values()) {
                    if (rr.Requirement_Item__r.RecordType.DeveloperName == 'Document_Upload') {
                        documentLinks.put(rr.Id, new ContentDocumentLink());
                    }
                }*/

                // Query for all the requirement response documents and map them to the requirement response id
/*                List<ContentDocumentLink> documentLinksList = [
                        SELECT Id, ContentDocumentId, LinkedEntityId
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId IN :documentLinks.keySet()
                ];

                for (ContentDocumentLink cdl : documentLinksList) {
                    documentLinks.get(cdl.LinkedEntityId).put(cdl.Id, cdl);
                }*/


                questionResponsesByQuestionId = new Map<Id, Question_Response__c>();
                for (Question_Response__c qr : questionResponses.values()) {
                    if (String.isNotBlank(qr.ValueTextEncrypted__c)) {
                        qr.ValueTextEncrypted__c = '** Encrypted **';
                    }
                    questionResponsesByQuestionId.put(qr.Question__c, qr);
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

                appWrapper.requirements = buildRequirements();

            }
        }
        return appWrapper;
    }

    private static List<EASYAppRequirementWrapper> buildRequirements() {
        List<EASYAppRequirementWrapper> reqWrapperList = new List<EASYAppRequirementWrapper>();
        if (requirements.size() > 0) {
            for (Id reqKey : requirements.keySet()) {
                EASYAppRequirementWrapper reqWrapper = new EASYAppRequirementWrapper();
                reqWrapper.requirement = requirements.get(reqKey);
                reqWrapper.requirementItems = buildRequirementItems(reqKey);
                reqWrapperList.add(reqWrapper);
            }
        }
        return reqWrapperList;
    }

    private static List<EASYAppRequirementItemWrapper> buildRequirementItems(Id reqKey) {
        List<EASYAppRequirementItemWrapper> requirementItemsList = new List<EASYAppRequirementItemWrapper>();
        Integer keyCount = 0;
        for (Requirement_Item__c ri : requirementItems.values()) {
            if (ri.Requirement__c == reqKey) {
                EASYAppRequirementItemWrapper newRIWrap = new EASYAppRequirementItemWrapper();
                newRIWrap.requirementItem = ri;
                if (ri.RecordType.DeveloperName == 'Related_Object') {
                    newRIWrap.is_related_object = true;
                }
                if (ri.RecordType.DeveloperName == 'Document_Upload') {
                    newRIWrap.is_document = true;
                }
                if (ri.RecordType.DeveloperName == 'Question_Group') {
                    newRIWrap.is_question_group = true;
                }
                newRIWrap.questions = buildQuestions(ri.Id);
                newRIWrap.display_response = false;
                if (ri.RecordType.DeveloperName == 'Document_Upload') {
                    newRIWrap.display_response = true;
                }

                newRIWrap.requirementResponse = buildRequirementResponses(ri.Id);

                //Check if there are any related objects to query
                if(String.isNotBlank(ri.Related_List_Object__c)) {
                    if (requirementItemIdRelatedObjectData.containsKey(ri.Related_List_Object__c.toLowerCase())) {
                        RelatedObjectData rod = requirementItemIdRelatedObjectData.get(ri.Related_List_Object__c.toLowerCase());
                        String query = rod.query;
                        List<SObject> relatedObjectAnswer = Database.query(query);

                        List<RelatedObjectDataItem> relatedObjectDataItems = new List<RelatedObjectDataItem>();
                        for (SObject obj : relatedObjectAnswer) {
                            for (String field : rod.objectFields) {
                                keyCount++;
                                field = field.toLowerCase();
                                if (String.isNotBlank(String.valueOf(obj.get(field)))) {
                                    RelatedObjectDataItem rodItem = new RelatedObjectDataItem();
                                    rodItem.fieldApi = field;
                                    rodItem.key = obj.Id;
                                    rodItem.fieldValue = String.valueOf(obj.get(field));
                                    rodItem.fieldLabel = rod.fieldMapLabel.get(field);
                                    // Get the field describe result
                                    SObjectField sObjectField = obj.getSObjectType().getDescribe().fields.getMap().get(field);
                                    DescribeFieldResult fieldDescribe = sObjectField.getDescribe();
                                    rodItem.fieldType = fieldDescribe.getType().name();
                                    relatedObjectDataItems.add(rodItem);
                                }
                            }
                        }
                        newRIWrap.relatedObjectAnswer = relatedObjectDataItems;
                    }
                }

                requirementItemsList.add(newRIWrap);
            }
        }
        return requirementItemsList;
    }

    private static Map<String, RelatedObjectData> buildRelatedObjectDataItem(Map<String, RelatedObjectData> relatedObjectMap, String objectKey, Question__c q, Boolean isReference) {

        String queryField = '';
        if (isReference) {
            if (String.isNotBlank(q.Name_Field_API_Name__c)) {
                queryField = q.Name_Field_API_Name__c;
            }
        } else {
            if (String.isNotBlank(q.Related_Object_Field__c)) {
                queryField = q.Related_Object_Field__c;
            }
        }
        queryField = queryField.toLowerCase();

        if (relatedObjectMap.containsKey(objectKey)) {
            RelatedObjectData rod = relatedObjectMap.get(objectKey);
            rod.objectFields.add(queryField);
            rod.fieldMapLabel.put(queryField, q.Label__c);
            rod.questionIds.add(q.Id);
        } else {
            RelatedObjectData newROD = new RelatedObjectData();
            newROD.objectName = objectKey;
            newROD.objectFields = new Set<String>{
                    queryField
            };
            newROD.objectFields.add(queryField);
            newROD.questionIds = new List<Id>{
                    q.Id
            };
            newROD.fieldMapLabel = new Map<String, String>{
                    queryField => q.Label__c
            };

            if (!isReference) {
                if (String.isNotBlank(q.Requirement_Item__r.Related_List_Object_Master__c)) {
                    newROD.whereClause = ' WHERE ' + q.Requirement_Item__r.Related_List_Object_Master_Field__c;
                    if (q.Requirement_Item__r.Related_List_Object_Master__c == 'Application') {
                        newROD.whereClause += ' = :appId';
                    } else {
                        newROD.whereClause += ' = :contactId';
                    }
                }
                if (String.isNotBlank(q.Requirement_Item__r.Related_List_Where_Clause__c)) {
                    newROD.whereClause += ' AND ' + q.Requirement_Item__r.Related_List_Where_Clause__c;
                }
            } else {
                newROD.whereClause = ' WHERE Id = ';
                newROD.whereIds = new List<Id>();
            }

            relatedObjectMap.put(objectKey, newROD);
        }

        return relatedObjectMap;
    }

    private static List<EASYAppQuestionResponseWrapper> buildQuestions(Id reqItemId) {
        List<EASYAppQuestionResponseWrapper> questionsList = new List<EASYAppQuestionResponseWrapper>();
        for (Question__c q : questions.values()) {
            if (q.Requirement_Item__c == reqItemId) {
                //Evaluate if question dependencies are met
                EASYAppQuestionResponseWrapper qrWrapper = new EASYAppQuestionResponseWrapper();
                qrWrapper.question = q;
                qrWrapper.questionResponses = buildQuestionResponses(q.Id);
                qrWrapper.dependencies_met = true;
                qrWrapper.answered = false;
                qrWrapper.show_question = false;
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
                    } else if (qd.RecordType.Name == 'Multi-select picklist') {
//                        if (!questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueText__c.contains(qd.Value__c)) {
//                            qrWrapper.dependenciesMet = false;
//                        }
                    } else if (qd.RecordType.Name == 'Radio') {
                        if (qd.Value__c != questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueText__c) {
                            qrWrapper.dependencies_met = false;
                        }
                    }
                }

                if (qrWrapper.questionResponses.size() > 0 || String.isNotBlank(qrWrapper.question.Static_Text__c)) {
                    qrWrapper.answered = true;
                }
                if (qrWrapper.dependencies_met && qrWrapper.answered) {
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

    private static List<Question_Response__c> buildQuestionResponses(Id questionId) {
        List<Question_Response__c> questionResponsesList = new List<Question_Response__c>();
        for (Question_Response__c qr : questionResponses.values()) {
            if (qr.Question__c == questionId) {
                questionResponsesList.add(qr);
                if (qr.Question__r.RecordType.DeveloperName.equalsIgnoreCase('Reference')) {
                    String refKey = qr.Question__r.Lookup_Object__c.toLowerCase();
                    if (referenceQuestionFieldData.containsKey(refKey)) {
                        referenceQuestionFieldData.get(refKey).whereIds.add(qr.ValueText__c);
                    }
                }
            }
        }

        //Fill in all question responses for reference questions
        for (String key : referenceQuestionFieldData.keySet()) {
            RelatedObjectData rod = referenceQuestionFieldData.get(key);
            if (rod.whereIds.size() > 0) {
                List<String> whereIds = rod.whereIds;
                rod.query = 'SELECT Id, ' + String.join(new List<String>(rod.objectFields), ',') + ' FROM ' + rod.objectName + ' WHERE Id IN :whereIds';
            }
        }

        System.debug('referenceQuestionFieldData: ' + JSON.serializePretty(referenceQuestionFieldData));

/*        Map<Id, SObject> relatedObjectAnswerMap = new Map<Id, SObject>();
        List<SObject> relatedObjectAnswer = Database.query(rod.query);
        System.debug('relatedObjectAnswer: ' + JSON.serializePretty(relatedObjectAnswer));
        for (SObject obj : relatedObjectAnswer) {
            relatedObjectAnswerMap.put(obj.Id, obj);
        }*/

        for (Question_Response__c qr: questionResponsesList) {
            if(qr.Question__r.RecordType.DeveloperName.equalsIgnoreCase('Reference')) {
                //Use relatedObjectAnswerMap which is mapped to the id of question resonse to get the related object data for referenceAnswer

            }
        }





        return questionResponsesList;
    }
}