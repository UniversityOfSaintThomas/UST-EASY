/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-23-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
public without sharing class graduateRecommenderInfoController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getRelatedObjectInfo() {
        try {
            Map<String, String> id_map = new Map<String, String>();

            Id recommendation_id;// = ApexPages.currentPage().getParameters().get('recId');
            if (recommendation_id == null) {
                recommendation_id = [SELECT Id FROM Recommendation__c LIMIT 1].Id;
            }
            id_map.put('recommendation_id', recommendation_id);
    
            Recommendation__c recommendation_object = [
                SELECT 
                    Application__r.Id, 
                    Application__r.Application_Status__c,
                    Application__r.Application_Control__r.Id,
                    Display_Instructive_Text__c
                FROM Recommendation__c 
                WHERE Id =: recommendation_id
                LIMIT 1
            ];
            id_map.put('application_id', recommendation_object.Application__r.Id);
            id_map.put('application_status', recommendation_object.Application__r.Application_Status__c);
            id_map.put('application_control_id', recommendation_object.Application__r.Application_Control__r.Id);
            id_map.put('display_instructive_text', String.valueOf(recommendation_object.Display_Instructive_Text__c));

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

            String requirement_query_string = 'SELECT Id FROM Requirement__c WHERE Application_Control__c = \'' + recommendation_object.Application__r.Application_Control__r.Id + '\'';
            requirement_query_string = filterQueryByApplication(requirement_query_string, app);

            List<Requirement__c> reqs = Database.query(requirement_query_string);
            Map<Id, Requirement__c> applicable_requirements = new Map<Id, Requirement__c>(reqs);
            Set<Id> applicable_requirement_ids = applicable_requirements.keySet();
    
            Id related_object_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Related_Object').getRecordTypeId();
            String app_control_case_sensitive_id = String.valueOf(recommendation_object.Application__r.Application_Control__r.Id).substring(0,15); // Application_Control_Id__c is formula field and populated with 15-char Id
            String query_string = 'SELECT Id, ' +
                                        'Requirement__r.Id, ' +
                                        'Instructions__c ' + 
                                  'FROM Requirement_Item__c ' + 
                                  'WHERE Application_Control_Id__c = \'' + app_control_case_sensitive_id + '\' ' +
                                  'AND Requirement__c IN: applicable_requirement_ids ' +
                                  'AND Internal_Requirement_Item__c != null ' +
                                  'AND RecordTypeId = \'' + related_object_RT + '\' ' +
                                  'AND Active__c = true ' +
                                  'AND Requirement__r.Active__c = true';
            query_string = filterQueryByApplication(query_string, app);
            query_string += ' LIMIT 1';

            List<Requirement_Item__c> external_requirement_items = Database.query(query_string);

            id_map.put('requirement_id', external_requirement_items[0].Requirement__r.Id);
            id_map.put('requirement_item_instructions', external_requirement_items[0].Instructions__c);
            id_map.put('related_object_requirement_item_id', external_requirement_items[0].Id);
    
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
            query_string += ' AND Applicant_Type__c INCLUDES (\'' + String.escapeSingleQuotes(app.Applicant_Type__c) + '\')';
        }

        if (app.Application_Status__c != null) {
            query_string += ' AND Application_Status__c INCLUDES (\'' + String.escapeSingleQuotes(app.Application_Status__c) + '\')';
        }

        if (app.Citizenship__c != null) {
            query_string += ' AND Citizenship__c INCLUDES (\'' + String.escapeSingleQuotes(app.Citizenship__c) + '\')';
        }

        if (app.Degree_Type__c != null) {
            query_string += ' AND Degree_Type__c INCLUDES (\'' + String.escapeSingleQuotes(app.Degree_Type__c) + '\')';
        }

        if (app.Delivery_Type__c != null) {
            query_string += ' AND Delivery_Type__c INCLUDES (\'' + String.escapeSingleQuotes(app.Delivery_Type__c) + '\')';
        }

        if (app.Intended_Program__c != null) {
            query_string += ' AND Intended_Program__c = \'' + String.escapeSingleQuotes(app.Intended_Program__c) + '\'';
        }

        if (app.School_College__c != null) {
            query_string += ' AND School_College__c = \'' + String.escapeSingleQuotes(app.School_College__c) + '\'';
        }

        if (app.Student_Type__c != null) {
            query_string += ' AND Student_Type__c INCLUDES (\'' + String.escapeSingleQuotes(app.Student_Type__c) + '\')';
        }

        if (app.Residency__c != null) {
            query_string += ' AND Residency__c = \'' + String.escapeSingleQuotes(app.Residency__c) + '\'';
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
}
