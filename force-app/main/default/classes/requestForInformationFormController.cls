/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-11-2022
 * @last modified by  : nicole.b@digitalmass.com
**/

public without sharing class requestForInformationFormController {

    @AuraEnabled
    public static void createLead(String record,String objectApiName){
        try {
            SObject sobj;
            Map<String,SObjectField> fieldMap;
            Map<String,Object> objMap = (Map<String,Object>) JSON.deserializeUntyped(record);
            System.debug(objMap);
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

            System.debug('sobj: ' + sobj);
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = false;
            Database.SaveResult result = Database.insert(sobj, dml);
        } catch (Exception e) {
            throw new AuraHandledException('Error creating lead: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static RFI_Controller__c getRFIController(String rfi_controller_name){
        try {
            return [
                SELECT
                    Academic_Level__c,
                    School_College__c,
                    Citizenship_Type__c,
                    Fields_to_Display__c,
                    Required_Fields__c,
                    Lead_Owner__c,
                    Redirect_URL__c,
                    Hide_Form_Title__c
                FROM RFI_Controller__c 
                WHERE Name =: rfi_controller_name
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving RFI Controller: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, Program__c> getPrograms(String academic_level, String school_college) {
        try {
            Id recruitment_program_id = Schema.SObjectType.Program__c.getRecordTypeInfosByDeveloperName().get('Recruitment_Program').getRecordTypeId();
            String query_string = 
                'SELECT ' + 
                    'Id, ' +
                    'Name, ' +
                    'Degree__c ' +
                'FROM Program__c ' +
                'WHERE RecordTypeId = \'' + recruitment_program_id + '\' ' +
                'AND Academic_Level__c = \'' + academic_level + '\' ' +
                'AND Program_Display__c INCLUDES (\'RFI\') ' +
                'AND Active__c = true';
            
            if (!String.isBlank(school_college)) {
                query_string += ' AND Associated_Schools__c INCLUDES (\'' + school_college + '\')';
            }

            if (school_college == 'School of Law') {
                query_string += ' AND Banner_Program_Code__c LIKE \'LW_%\'';
            }

            if (academic_level == 'U') {
                query_string += ' AND (Program_Type__c INCLUDES \'Major\' OR Program_Type__c INCLUDES \'Pre-Professional\')';
            } else {
                query_string += ' ORDER BY Degree__c';
            }
            
            System.debug('%% query string: ' + query_string);
            List<Program__c> programs = Database.query(query_string);
            return new Map<Id, Program__c>(programs);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving programs: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, hed__Term__c> getTerms(String account_name) {
        try {
            String account_id = getSchoolCollegeAccount(account_name);
            Date today = System.today();
            Map<Id, hed__Term__c> terms = new Map<Id, hed__Term__c>([
                SELECT
                    Id,
                    Name,
                    hed__Start_Date__c
                FROM hed__Term__c
                WHERE hed__Start_Date__c >=: today
                AND hed__Account__c =: account_id
            ]);
            return terms;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving terms: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<Id, Account> searchHighSchools(String search_term){
        try {
            Id educational_institution_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
            Map<Id, Account> high_school_map = new Map<Id, Account>();
                List<List<Account>> high_schools = [
                    FIND :search_term 
                    IN NAME FIELDS 
                    RETURNING Account(
                                    Id, 
                                    Name, 
                                    BillingCity, 
                                    BillingState, 
                                    BillingCountry 
                                WHERE Type =: 'High School' 
                                AND RecordTypeId =: educational_institution_id
                                ORDER BY Name
                )];
                for (List<Account> account_list : high_schools) {
                    for (Account high_school : account_list) {
                        high_school_map.put(high_school.Id, high_school);
                    }
                }
            return high_school_map;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getAcademicLevelValue(String api_name){
        try {
            String level = '';
            Schema.DescribeFieldResult describe_result = RFI_Controller__c.Academic_Level__c.getDescribe();
            List<Schema.PicklistEntry> values = describe_result.getPicklistValues();
            for(Schema.PicklistEntry value : values) {
                if (value.getValue() == api_name) {
                    return value.getLabel();
                }
            }
            return level;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Lead_Preset_Value__mdt> getPresetValues(String rfi_controller_name){
        try {
            List<Lead_Preset_Value__mdt> return_preset_values = new List<Lead_Preset_Value__mdt>();
            List<Lead_Preset_Value__mdt> preset_values = [SELECT Field_API_Name__c, Value__c FROM Lead_Preset_Value__mdt WHERE RFI_Controller_Name__c =: rfi_controller_name];
            if (preset_values.size() > 0) {
                return preset_values;
            }
            return return_preset_values;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getSchoolCollegeAccount(String school_college_name){
        try {
            String school_college_id = '';
            Id administrative_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();
            List<Account> school_college_accounts = [
                SELECT Id
                FROM Account 
                WHERE Name =: school_college_name 
                AND RecordTypeId =: administrative_id
                AND Banner_Key__c LIKE 'STVCOLL-%'
            ];
            if (school_college_accounts.size() > 0) {
                school_college_id = school_college_accounts[0].Id;
            } 
            return school_college_id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}