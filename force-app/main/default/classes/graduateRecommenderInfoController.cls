/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-17-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
public with sharing class graduateRecommenderInfoController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getObjectIds() {
        try {
            Map<String, String> id_map = new Map<String, String>();

            Id recommendation_id;// = ApexPages.currentPage().getParameters().get('recId');
            if (recommendation_id == null) {
                recommendation_id = [SELECT Id FROM Recommendation__c LIMIT 1].Id;
            }
            id_map.put('recommendationId', recommendation_id);
    
            Recommendation__c recommendation_object = [
                SELECT 
                    Application__r.Id, 
                    Application__r.Application_Status__c,
                    Application__r.Application_Control__r.Id
                FROM Recommendation__c 
                WHERE Id =: recommendation_id
            ];
            id_map.put('applicationId', recommendation_object.Application__r.Id);
            id_map.put('applicationStatus', recommendation_object.Application__r.Application_Status__c);
            id_map.put('applicationControlId', recommendation_object.Application__r.Application_Control__r.Id);
    
            Id related_object_RT = Schema.SObjectType.Requirement_Item__c.getRecordTypeInfosByDeveloperName().get('Related_Object').getRecordTypeId();
            String app_control_case_sensitive_id = String.valueOf(recommendation_object.Application__r.Application_Control__r.Id).substring(0,15); // Application_Control_Id__c is formula field and populated with 15-char Id
            Requirement_Item__c external_requirement_items = [
                SELECT Id, Requirement__r.Id
                FROM Requirement_Item__c 
                WHERE Application_Control_Id__c =: app_control_case_sensitive_id
                AND Internal_Requirement_Item__c != null
                AND RecordTypeId =: related_object_RT
                AND Active__c = true
                AND Requirement__r.Active__c = true
                LIMIT 1
            ];
            id_map.put('requirementId', external_requirement_items.Requirement__r.Id);
            id_map.put('relatedObjectRequirementItemId', external_requirement_items.Id);
    
            return id_map;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving application information: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Question__c> getRelatedObjectQuestions(Id requirement_item_id, Id application_id){
        try {
            List<Question__c> questions = new List<Question__c>();
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
                                      'Lookup_Where_Clause__c ' +
                                  'FROM Question__c ' +
                                  'WHERE Requirement_Item__c = \'' + requirement_item_id + '\' ' +
                                  'AND Active__c = true';
                                  
            if (app.Applicant_Type__c != null) {
                query_string += ' AND Applicant_Type__c INCLUDES (\'' + app.Applicant_Type__c + '\')';
            }

            if (app.Application_Status__c != null) {
                query_string += ' AND Application_Status__c INCLUDES (\'' + app.Application_Status__c + '\')';
            }

            if (app.Citizenship__c != null) {
                query_string += ' AND Citizenship__c INCLUDES (\'' + app.Citizenship__c + '\')';
            }

            if (app.Degree_Type__c != null) {
                query_string += ' AND Degree_Type__c INCLUDES (\'' + app.Degree_Type__c + '\')';
            }

            if (app.Delivery_Type__c != null) {
                query_string += ' AND Delivery_Type__c INCLUDES (\'' + app.Delivery_Type__c + '\')';
            }

            if (app.Intended_Program__c != null) {
                query_string += ' AND Intended_Program__c = \'' + app.Intended_Program__c + '\'';
            }

            if (app.School_College__c != null) {
                query_string += ' AND School_College__c = \'' + app.School_College__c + '\'';
            }

            if (app.Student_Type__c != null) {
                query_string += ' AND Student_Type__c INCLUDES (\'' + app.Student_Type__c + '\')';
            }

            if (app.Residency__c != null) {
                query_string += ' AND Residency__c = \'' + app.Residency__c + '\'';
            }

            query_string += 'ORDER BY Display_Order__c ASC';

            System.debug('query string: ' + query_string);

            questions = Database.query(query_string);
            return questions;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving form questions: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<Id, SObject> lookup(String lookup_object, String lookup_where_clause){
        try {
            String query_string = 'SELECT Id, Name FROM ' + lookup_object + 'WHERE ' + lookup_where_clause + ' ORDER BY Name';
            return new Map<Id, SObject>(Database.query(query_string));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
