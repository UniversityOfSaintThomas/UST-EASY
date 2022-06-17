public without sharing class requestForInformationFormController {

    // @author : andrew.d@digitalmass.com
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

    @AuraEnabled(cacheable=true)
    public static RFI_Controller__c getRFIController(String rfi_controller_name){
        try {
            return [
                SELECT
                    Academic_Level__c,
                    Applicant_Status__c,
                    Fields_to_Display__c,
                    Required_Fields__c
                FROM RFI_Controller__c 
                WHERE Name =: rfi_controller_name
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving RFI Controller: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, Program__c> getAcademicPrograms(String academic_level) {
        try {
            Id recruitment_record_type_id = Schema.SObjectType.Program__c.getRecordTypeInfosByDeveloperName().get('Recruitment_Program').getRecordTypeId();
            Map<Id, Program__c> programs = new Map<Id, Program__c>([
                SELECT
                    Name
                FROM Program__c
                WHERE RecordTypeId =: recruitment_record_type_id
                AND Academic_Level__c =: academic_level
                AND Program_Display__c INCLUDES ('RFI')
                AND Active__c = true
                AND (Program_Type__c = 'Major'
                    OR Program_Type__c = 'Pre-Professional')
            ]);
            return programs;
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

    @AuraEnabled
    public static Map<Id, Account> searchHighSchools(String search_term){
        try {
            Map<Id, Account> high_school_map = new Map<Id, Account>();
                Id educational_record_type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
                List<List<Account>> high_schools = [FIND :search_term IN NAME FIELDS RETURNING Account(Id, Name, ShippingCity, ShippingState WHERE RecordTypeId =: educational_record_type ORDER BY Name)];
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
    public static String getOwnerId(){
        try {
            return [SELECT Id FROM User WHERE Username = 'guest@fake.com' LIMIT 1].Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createAccount(String account_name){
        try {
            String account_id = '';
            if (account_name != null && account_name != '') {
                Id educational_record_type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
                Account new_account = new Account(RecordTypeId = educational_record_type, Name = account_name, OwnerId = getOwnerId());
                insert new_account;
                account_id = new_account.Id;
            }
            return account_id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
