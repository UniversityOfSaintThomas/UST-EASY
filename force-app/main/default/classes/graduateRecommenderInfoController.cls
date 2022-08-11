/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-11-2022
 * @last modified by  : nicole.b@digitalmass.com
**/
public with sharing class graduateRecommenderInfoController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Id> getObjectIds() {
        try {
            Map<String, Id> id_map = new Map<String, Id>();

            Id recommendation_id; // = ApexPages.currentPage().getParameters().get('recId');
            if (recommendation_id == null) {
                recommendation_id = [SELECT Id FROM Recommendation__c LIMIT 1].Id;
            }
            id_map.put('recommendationId', recommendation_id);
    
            Recommendation__c recommendation_object = [
                SELECT 
                    Application__r.Id, 
                    Application__r.Application_Control__r.Id
                FROM Recommendation__c 
                WHERE Id =: recommendation_id
            ];
            id_map.put('applicationId', recommendation_object.Application__r.Id);
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
            id_map.put('requirementItemId', external_requirement_items.Id);
    
            return id_map;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving application information: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Question__c> getQuestions(Id requirement_item_id){
        try {
            return [
                SELECT Id,
                    Label__c,
                    RecordTypeId,
                    Requirement_Item_Name__c,
                    Requirement_Name__c,
                    Application_Control_Name__c,
                    Assistive_Text__c,
                    Display_as_Picklist__c,
                    Display_Order__c,
                    Help_Text__c,
                    Name,
                    External_Email_Field__c,
                    Placeholder__c,
                    Static_Text__c,
                    Hardcoded_Value__c
                FROM Question__c
                WHERE Requirement_Item__c =: requirement_item_id
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving form questions: ' + e.getMessage());
        }
    }
}
