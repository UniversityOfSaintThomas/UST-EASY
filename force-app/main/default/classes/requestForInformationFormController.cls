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

            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = false;
            Database.SaveResult result = Database.insert(sobj, dml);
        } catch (Exception e) {
            throw new AuraHandledException('Error creating lead: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String createAccount(String account_name, String owner_id){
        try {
            String account_id = '';
            if (!String.isBlank(account_name)) {
                Account new_account = new Account(Type = 'High School', Name = account_name, OwnerId = owner_id);
                insert new_account;
                account_id = new_account.Id;
            }
            return account_id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
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
                    Lead_Owner__c
                FROM RFI_Controller__c 
                WHERE Name =: rfi_controller_name
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving RFI Controller: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, Program__c> getAcademicPrograms(String academic_level, String school_college, String citizenship_type) {
        try {
            Id recruitment_record_type_id = Schema.SObjectType.Program__c.getRecordTypeInfosByDeveloperName().get('Recruitment_Program').getRecordTypeId();
            String query_string = 
                'SELECT ' + 
                    'Name ' +
                'FROM Program__c ' +
                'WHERE RecordTypeId = \'' + recruitment_record_type_id + '\' ' +
                'AND Academic_Level__c = \'' + academic_level + '\' ' +
                'AND Program_Display__c INCLUDES (\'RFI\') ' +
                'AND Active__c = true ' +
                'AND (Program_Type__c = \'Major\' OR Program_Type__c = \'Pre-Professional\')';
            
            if (!String.isBlank(school_college)) {
                query_string += ' AND (Associated_Schools__c INCLUDES (\'' + school_college + '\') OR School_College__c = \'' + school_college + '\')';
            }
            if (!String.isBlank(citizenship_type)) {
                query_string += ' AND Citizenship__c = \'' + citizenship_type + '\'';
            }
            System.debug('%% query string: ' + query_string);
            List<Program__c> programs = Database.query(query_string);
            return new Map<Id, Program__c>(programs);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving academic programs: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, hed__Term__c> getAcademicTerms() {
        try {
            Date today = System.today();
            Map<Id, hed__Term__c> terms = new Map<Id, hed__Term__c>([
                SELECT
                    Id,
                    Name,
                    hed__Start_Date__c
                FROM hed__Term__c
                WHERE End_Application_Date__c >=: today
            ]);
            return terms;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving academic programs: ' + e.getMessage());
        }
    }

    // TO DO: change to BillingState and BillingCity
    // AND Type = 'High School'
    @AuraEnabled
    public static Map<Id, Account> searchHighSchools(String search_term){
        try {
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
            List<Lead_Preset_Value__mdt> preset_values = new List<Lead_Preset_Value__mdt>();
            preset_values = [SELECT Field_API_Name__c, Value__c FROM Lead_Preset_Value__mdt WHERE RFI_Controller_Name__c =: rfi_controller_name];
            return preset_values;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
