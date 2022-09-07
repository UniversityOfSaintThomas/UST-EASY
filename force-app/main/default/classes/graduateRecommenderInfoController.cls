/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 09-06-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
public without sharing class graduateRecommenderInfoController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getRelatedObjectInfo(String recId) {
        try {
            Map<String, String> id_map = new Map<String, String>();

            Id recommendation_id = Id.valueOf(recId);
            id_map.put('recommendation_id', recommendation_id);
    
            Recommendation__c recommendation_object = [
                SELECT 
                    Application__r.Id, 
                    Application__r.Application_Status__c,
                    Application__r.Application_Control__r.Id,
                    Application__r.Intended_Program__r.Application_Control__r.Id,
                    Display_Instructive_Text__c,
                    Submitted__c,
                    Requirement_Response__r.Requirement_Item__c,
                    Rec_Email__c
                FROM Recommendation__c 
                WHERE Id =: recommendation_id
                LIMIT 1
            ];

            id_map.put('application_id', recommendation_object.Application__r.Id);
            id_map.put('application_status', recommendation_object.Application__r.Application_Status__c);

            Id app_control_id;
            if (recommendation_object.Application__r.Application_Control__r.Id == null) {
                id_map.put('application_control_id', recommendation_object.Application__r.Intended_Program__r.Application_Control__r.Id);
                app_control_id = recommendation_object.Application__r.Intended_Program__r.Application_Control__r.Id;
            } else {
                id_map.put('application_control_id', recommendation_object.Application__r.Application_Control__r.Id);
                app_control_id = recommendation_object.Application__r.Application_Control__r.Id;
            }

            id_map.put('display_instructive_text', String.valueOf(recommendation_object.Display_Instructive_Text__c));
            id_map.put('submitted', String.valueOf(recommendation_object.Submitted__c));
            id_map.put('rec_email', String.valueOf(recommendation_object.Rec_Email__c));

            Application__c app = [
                SELECT Id,
                    Applicant_Type__c,
                    Application_Status__c,
                    Citizenship__c,
                    Degree_Type__c,
                    Delivery_Type__c,
                    Intended_Program__c,
                    School_College__c,
                    Student_Type__c,
                    Residency__c
                FROM Application__c 
                WHERE Id =: recommendation_object.Application__r.Id
                LIMIT 1
            ];

            String requirement_query_string = 'SELECT Id FROM Requirement__c WHERE Application_Control__c = \'' + app_control_id + '\' AND Active__c = true';
            requirement_query_string = filterQueryByApplication(requirement_query_string, app);

            List<Requirement__c> reqs = Database.query(requirement_query_string);
            Map<Id, Requirement__c> applicable_requirements = new Map<Id, Requirement__c>(reqs);
            Set<Id> applicable_requirement_ids = applicable_requirements.keySet();
    
            Id related_object_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Related_Object').getRecordTypeId();
            Id document_upload_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Document_Upload').getRecordTypeId();
            String app_control_case_sensitive_id = String.valueOf(app_control_id).substring(0,15); // Application_Control_Id__c is formula field and populated with 15-char Id
            String query_string = 'SELECT Id, ' +
                                        'Requirement__r.Id, ' +
                                        'Instructions__c, ' + 
                                        'File_Types__c, ' + 
                                        'RecordTypeId, ' + 
                                        'Required__c, ' + 
                                        'Allow_Text_Entry__c ' + 
                                  'FROM Requirement_Item__c ' + 
                                  'WHERE Application_Control_Id__c = \'' + app_control_case_sensitive_id + '\' ' +
                                  'AND Requirement__c IN: applicable_requirement_ids ' +
                                  'AND Internal_Requirement_Item__c = \'' + recommendation_object.Requirement_Response__r.Requirement_Item__c + '\' ' +
                                  'AND (RecordTypeId = \'' + related_object_RT + '\' ' +
                                        'OR RecordTypeId = \'' + document_upload_RT + '\') ' +
                                  'AND Active__c = true ';
            query_string = filterQueryByApplication(query_string, app);
            query_string += ' LIMIT 2';

            List<Requirement_Item__c> external_requirement_items = Database.query(query_string);
            Requirement_Item__c related_object_req_item;
            Requirement_Item__c document_upload_req_item;
            for (Requirement_Item__c req_item : external_requirement_items) {
                if (req_item.RecordTypeId == related_object_RT) {
                    related_object_req_item = req_item;
                } else if (req_item.RecordTypeId == document_upload_RT) {
                    document_upload_req_item = req_item;
                }
            }

            if (related_object_req_item != null) {
                id_map.put('related_object_requirement_item_instructions', related_object_req_item.Instructions__c);
                id_map.put('related_object_requirement_item_id', related_object_req_item.Id);
            } else {
                id_map.put('related_object_requirement_item_instructions', null);
                id_map.put('related_object_requirement_item_id', null);
            }

            if (document_upload_req_item != null) {
                id_map.put('document_upload_requirement_item_instructions', document_upload_req_item.Instructions__c);
                id_map.put('document_upload_requirement_item_id', document_upload_req_item.Id);
                id_map.put('document_upload_requirement_item_allow_text_entry', String.valueOf(document_upload_req_item.Allow_Text_Entry__c));
                id_map.put('document_upload_requirement_item_file_types', String.valueOf(document_upload_req_item.File_Types__c));
                id_map.put('document_upload_requirement_item_required', document_upload_req_item.Required__c);
            } else {
                id_map.put('document_upload_requirement_item_instructions', null);
                id_map.put('document_upload_requirement_item_id', null);
                id_map.put('document_upload_requirement_item_allow_text_entry', null);
                id_map.put('document_upload_requirement_item_file_types', null);
                id_map.put('document_upload_requirement_item_required', null);
            }
    
            return id_map;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving application information: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Question__c> getRelatedObjectQuestions(Id requirement_item_id, Id application_id){
        try {
            Application__c app = [
                SELECT Id,
                    Applicant_Type__c,
                    Application_Status__c,
                    Citizenship__c,
                    Degree_Type__c,
                    Delivery_Type__c,
                    Intended_Program__c,
                    School_College__c,
                    Student_Type__c,
                    Residency__c
                FROM Application__c 
                WHERE Id =: application_id
                LIMIT 1
            ];

            String query_string = 'SELECT Id, ' +
                                      'Name, ' +
                                      'Label__c, ' +
                                      'RecordType.DeveloperName, ' +
                                      'Assistive_Text__c, ' +
                                      'Display_as_Picklist__c, ' +
                                      'Display_Order__c, ' +
                                      'Help_Text__c, ' +
                                      'Placeholder__c, ' +
                                      'Static_Text__c, ' +
                                      'Hardcoded_Value__c, ' +
                                      'Additional_Field_Validation__c, ' +
                                      'Length__c, ' +
                                      'Picklist_Values__c, ' +
                                      'Required__c, ' +
                                      'Related_Object__c, ' +
                                      'Related_Object_Field__c, ' +
                                      'Lookup_Object__c, ' +
                                      'Lookup_Where_Clause__c, ' +
                                      'Name_Field_API_Name__c ' +
                                  'FROM Question__c ' +
                                  'WHERE Requirement_Item__c = \'' + requirement_item_id + '\' ' +
                                  'AND Active__c = true';
            query_string = filterQueryByApplication(query_string, app);
            query_string += 'ORDER BY Display_Order__c ASC';

            return Database.query(query_string);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving form questions: ' + e.getMessage());
        }
    }

    private static String filterQueryByApplication(String query_string, Application__c app) {
        if (app.Applicant_Type__c != null) {
            query_string += ' AND (Applicant_Type__c INCLUDES (\'' + String.escapeSingleQuotes(app.Applicant_Type__c) + '\') OR Applicant_Type__c = null)';
        }

        if (app.Application_Status__c != null) {
            query_string += ' AND (Application_Status__c INCLUDES (\'' + String.escapeSingleQuotes(app.Application_Status__c) + '\') OR Application_Status__c = null)';
        }

        if (app.Citizenship__c != null) {
            query_string += ' AND (Citizenship__c INCLUDES (\'' + String.escapeSingleQuotes(app.Citizenship__c) + '\') OR Citizenship__c = null)';
        }

        if (app.Degree_Type__c != null) {
            query_string += ' AND (Degree_Type__c INCLUDES (\'' + String.escapeSingleQuotes(app.Degree_Type__c) + '\') OR Degree_Type__c = null)';
        }

        if (app.Delivery_Type__c != null) {
            query_string += ' AND (Delivery_Type__c INCLUDES (\'' + String.escapeSingleQuotes(app.Delivery_Type__c) + '\') OR Delivery_Type__c = null)';
        }

        if (app.Intended_Program__c != null) {
            query_string += ' AND (Intended_Program__c = \'' + String.escapeSingleQuotes(app.Intended_Program__c) + '\' OR Intended_Program__c = null)';
        }

        if (app.School_College__c != null) {
            query_string += ' AND (School_College__c = \'' + String.escapeSingleQuotes(app.School_College__c) + '\' OR School_College__c = null)';
        }

        if (app.Student_Type__c != null) {
            query_string += ' AND (Student_Type__c INCLUDES (\'' + String.escapeSingleQuotes(app.Student_Type__c) + '\') OR Student_Type__c = null)';
        }

        if (app.Residency__c != null) {
            query_string += ' AND (Residency__c = \'' + String.escapeSingleQuotes(app.Residency__c) + '\' OR Residency__c = null)';
        }

        return query_string;
    }

    @AuraEnabled
    public static Map<Id, SObject> lookup(String lookup_object, String lookup_where_clause, String name_field_api_name){
        if (String.isNotBlank(lookup_object) && String.isNotBlank(lookup_where_clause) && String.isNotBlank(name_field_api_name)) {
            try {
                // string format / builder
                String query_string = 'SELECT Id, ' + name_field_api_name + ' FROM ' + lookup_object + ' WHERE ' + lookup_where_clause + ' ORDER BY ' + name_field_api_name;
                return new Map<Id, SObject>(Database.query(query_string));
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            return new Map<Id, SObject>();
        }
    }

    @AuraEnabled
    public static void updateRecommendation(String record, String objectApiName){
        try {
            SObject sobj;
            Map<String,SObjectField> fieldMap;
            Map<String,Object> objMap = (Map<String,Object>) JSON.deserializeUntyped(record);
            sobj = (SObject) Schema.describeSObjects(new List<String>{objectApiName})[0].getSObjectType().newSObject();
            fieldMap = sobj.getSObjectType().getDescribe().fields.getMap();
            for(String field : objMap.keySet()){
                Schema.SObjectField sObjField = fieldMap.get(field);
                if(sObjField == null){
                    continue;
                }
                if(objMap.get(field) == null){
                    sobj.put(field,null);
                }else{
                    switch on sObjField.getDescribe().getType().name().toLowerCase(){
                        when 'date'{
                            sobj.put(field,Date.valueOf((String)objMap.get(field)));
                        }when 'datetime'{
                            sobj.put(field,Datetime.valueOf(((String)objMap.get(field)).replace('T', ' ').replace('Z', '')));
                        }when else{
                            sobj.put(field,objMap.get(field));
                        }
                    }
                }
            }

            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = false;
            Database.SaveResult result = Database.update(sobj, dml);
        } catch (Exception e) {
            throw new AuraHandledException('Error updating recommendation: ' + e.getMessage());
        }
    }

    // adapted from https://www.salesforcetroop.com/custom_file_upload_using_lwc
    // can't use built-in lightning-file-upload element as it is not supported with Lightning Out
    @AuraEnabled
    public static Id uploadFile(String base_64, String file_name, String recommendation_id){
        try {
            ContentVersion cv = new ContentVersion(
                VersionData = EncodingUtil.base64Decode(base_64),
                Title = file_name,
                PathOnClient = file_name,
                OwnerId = UserInfo.getUserId(),
                FirstPublishLocationId = recommendation_id
            );
            if (!Test.isRunningTest()) {
                cv.NetworkId = Network.getNetworkId();
            }
            insert cv;
            return cv.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateRequirementResponses(String related_object_requirement_item_id, String document_upload_requirement_item_id){
        try {
            List<String> ids_to_query = new List<String>();
            if (related_object_requirement_item_id != null) {
                ids_to_query.add(related_object_requirement_item_id);
            }
            if (document_upload_requirement_item_id != null) {
                ids_to_query.add(document_upload_requirement_item_id);
            }
            List<Requirement_Response__c> req_responses = [
                SELECT Id, 
                    Document_Requirement_Fulfilled_On__c, 
                    Child_Requirement_Fulfilled_On__c, 
                    Requirement_Item__r.RecordTypeId 
                FROM Requirement_Response__c 
                WHERE Requirement_Item__c IN: ids_to_query
            ];
            Id related_object_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Related_Object').getRecordTypeId();
            Id document_upload_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Document_Upload').getRecordTypeId();
            for (Requirement_Response__c req_response : req_responses) {
                if (req_response.Requirement_Item__r.RecordTypeId == related_object_RT) {
                    req_response.Child_Requirement_Fulfilled_On__c = System.now();
                } else if (req_response.Requirement_Item__r.RecordTypeId == document_upload_RT) {
                    req_response.Document_Requirement_Fulfilled_On__c = System.now();
                }
            }
            update req_responses;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
