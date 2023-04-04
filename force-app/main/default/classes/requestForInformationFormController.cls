/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-15-2022
 * @last modified by  : nicole.b@digitalmass.com
**/

public without sharing class requestForInformationFormController {

    @AuraEnabled
    public static void createLead(String record, String objectApiName, String rfiController) {
        try {
            SObject sobj;
            Map<String, SObjectField> fieldMap;
            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(record);
            sobj = (SObject) Schema.describeSObjects(new List<String>{
                    objectApiName
            })[0].getSObjectType().newSObject();
            fieldMap = sobj.getSObjectType().getDescribe().fields.getMap();
            for (String field : objMap.keySet()) {
                Schema.SObjectField sObjField = fieldMap.get(field);
                if (sObjField == null) {
                    continue;
                }
                if (field.startsWith('utm_') && String.isNotEmpty((String) objMap.get(field))) {
                    sobj.put(field, objMap.get(field).toString().escapeHtml4());
                }
                if (objMap.get(field) == null) {
                    sobj.put(field, null);
                } else {
                    switch on sObjField.getDescribe().getType().name().toLowerCase() {
                        when 'date' {
                            sobj.put(field, Date.valueOf((String) objMap.get(field)));
                        } when 'datetime' {
                            sobj.put(field, Datetime.valueOf(((String) objMap.get(field)).replace('T', ' ').replace('Z', '')));
                        } when else {
                            sobj.put(field, objMap.get(field));
                        }
                    }
                }
            }

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.duplicateRuleHeader.allowSave = false;
            Database.SaveResult result = Database.insert(sobj, dml);
            if (result.isSuccess() == false) {
                String context = 'Creation of lead failed on insert. \n Error: ' + result.getErrors();
                insertErrorRecord(rfiController, record, context);
            }
        } catch (Exception e) {
            String context = 'Creation of lead failed because of caught exception in requestForInformationFormController.createLead(). \n Error: ' + e.getMessage();
            insertErrorRecord(rfiController, record, context);
            throw new AuraHandledException('Error creating lead: ' + e.getMessage());
        }
    }

    public static void insertErrorRecord(String rfiController, String record, String context) {
        hed__Error__c error_message = new hed__Error__c(
                hed__Object_Type__c = 'Lead',
                hed__Error_Type__c = 'ERROR: RFI Form Lead creation failed',
                hed__Full_Message__c = context + '. \n\n RFI Controller of form: ' + rfiController + '. \n\n The following information was entered on the form to be mapped to Lead: \n' + record
        );
        insert error_message;
    }

    @AuraEnabled(Cacheable=true)
    public static RFI_Controller__c getRFIController(String rfi_controller_name) {
        try {
            return [
                    SELECT
                            Academic_Level__c,
                            School_College__c,
                            Citizenship_Type__c,
                            Fields_to_Display__c,
                            Required_Fields__c,
                            Academic_Interests_To_Display__c,
                            Lead_Owner__c,
                            Redirect_URL__c,
                            Hide_Form_Title__c,
                            Lead_Source__c,
                            Redirect_After_Form_Submission__c
                    FROM RFI_Controller__c
                    WHERE Name = :rfi_controller_name
                    LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving RFI Controller: ' + e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getProgramIds(String academic_interest_codes) {
        System.debug('ACADEMIC INTEREST CODES: ' + academic_interest_codes);
        List<String> programIds = new List<Id>();
        academic_interest_codes = academic_interest_codes.escapeHtml4();
        List<String> programCodes = academic_interest_codes.split(';');
        List<Program__c> programs = [
                SELECT Id
                FROM Program__c
                WHERE Program_Major_Concentration__c IN :programCodes
                AND RecordType.DeveloperName = 'Recruitment_Program'
                AND Program_Display__c INCLUDES ('RFI')
                AND Active__c = TRUE
        ];
        System.debug(JSON.serializePretty(programs));
        for (Program__c p : programs) {
            programIds.add(p.Id);
        }
        return programIds;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<Id, Program__c> getPrograms(String academic_level, String school_college, String academic_interest_codes) {
        try {
            String query_string =
                    //Student type buckets
                    'SELECT ' +
                            'Id, ' +
                            'Name, ' +
                            'Program_Name_on_Application__c, ' +
                            'Student_Type__c, ' +
                            'Degree__c, ' +
                            'Program_Major_Concentration__c ' +
                            'FROM Program__c ' +
                            'WHERE RecordType.DeveloperName = \'Recruitment_Program\' ' +
                            'AND Program_Display__c INCLUDES (\'RFI\') ' +
                            'AND Active__c = true';
            if (academic_level == 'U' || academic_level == 'Undergraduate') {
                query_string += ' AND (Academic_Level__c = \'Undergraduate\' OR Academic_Level__c = \'U\') ';
                query_string += ' AND (Program_Type__c INCLUDES (\'Major\') OR Program_Type__c INCLUDES (\'Pre-Professional\'))';
            } else {
                query_string += ' AND (Academic_Level__c = \'Graduate\' OR Academic_Level__c = \'G\')  ';
                if (!String.isBlank(school_college)) {
                    query_string += ' AND Associated_Schools__c INCLUDES (\'' + school_college + '\')';
                }
                if (school_college == 'School of Law') {
                    query_string += ' AND Banner_Program_Code__c LIKE \'LW_%\'';
                }
            }

            if (String.isNotBlank(academic_interest_codes)) {
                academic_interest_codes = academic_interest_codes.escapeHtml4();
                List<String> academicCodes = academic_interest_codes.split(';');
                query_string += ' AND Program_Major_Concentration__c IN :academicCodes ';
            }
            query_string += ' ORDER BY Program_Name_on_Application__c';
            System.debug('PROGRAM QUERY: ');
            System.debug(query_string);
            List<Program__c> programs = Database.query(query_string);
            System.debug(JSON.serializePretty(programs));
            return new Map<Id, Program__c>(programs);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving programs: ' + e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static Map<Id, Academic_Term__c> getTerms(String account_name) {
        try {
            Date today = System.today();
            Date today_plus_four_years = today.addYears(4);
            // Academic Term -> intended start term
            // limit by 4 years, show Fall and Spring 
            Map<Id, Academic_Term__c> terms = new Map<Id, Academic_Term__c>([
                    SELECT
                            Id,
                            Name,
                            Term_Start_Date__c
                    FROM Academic_Term__c
                    WHERE Term_Start_Date__c >= :today
                    AND Term_Start_Date__c <= :today_plus_four_years
                    AND (Name LIKE 'Fall%' OR Name LIKE 'Spring%')
                    ORDER BY Term_Start_Date__c
            ]);
            return terms;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving terms: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String getAcademicLevelValue(String api_name) {
        try {
            String level = '';
            Schema.DescribeFieldResult describe_result = RFI_Controller__c.Academic_Level__c.getDescribe();
            List<Schema.PicklistEntry> values = describe_result.getPicklistValues();
            for (Schema.PicklistEntry value : values) {
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
    public static List<Lead_Preset_Value__mdt> getPresetValues(String rfi_controller_name) {
        try {
            List<Lead_Preset_Value__mdt> return_preset_values = new List<Lead_Preset_Value__mdt>();
            List<Lead_Preset_Value__mdt> preset_values = [SELECT Field_API_Name__c, Value__c FROM Lead_Preset_Value__mdt WHERE RFI_Controller_Name__c = :rfi_controller_name AND Active__c = TRUE];
            if (preset_values.size() > 0) {
                return preset_values;
            }
            return return_preset_values;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getSchoolCollegeAccount(String school_college_name) {
        try {
            String school_college_id = '';
            List<Account> school_college_accounts = [
                    SELECT Id
                    FROM Account
                    WHERE Name = :school_college_name
                    AND RecordType.DeveloperName = 'University_Department'
                    AND Banner_Key__c LIKE 'STVCOLL-%'
                    AND Name != 'other'
            ];
            if (school_college_accounts.size() > 0) {
                school_college_id = school_college_accounts[0].Id;
            }
            return school_college_id;
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static Id getRecruitmentProgram(String academic_level, String citizenship_type, String admit_type, String major_id, String school_name) {
        String program_name = '';
        String program_code = 'AS_UN_BA';
        System.debug('SCHOOL_NAME: ' + school_name);
        System.debug('ACADEMIC_LEVEL: ' + academic_level);
        System.debug('MAJOR ID: ' + major_id);
        System.debug('CITIZENSHIP TYPE: ' + citizenship_type);
        if (academic_level == 'U' || academic_level == 'Undergraduate') {
            if (admit_type == 'Transfer') {
                if (citizenship_type == 'International') {
                    program_name = 'Undergraduate Transfer (INTL)';
                } else {
                    program_name = 'Undergraduate Transfer';
                }
            } else if (school_name.equalsIgnoreCase('Dougherty Family College')) {
                program_name = 'Dougherty Family College';
                program_code = 'DC_UG_AA|LIBA';
            } else {
                program_name = 'Undergraduate First-Year';
            }
        }
        List<Program__c> academicPrograms = new List<Program__c>();
        if (String.isNotBlank(program_name) && String.isNotBlank(program_code)) {
            academicPrograms = [
                    SELECT Id
                    FROM Program__c
                    WHERE Name = :program_name
                    AND Program_Major_Concentration__c = :program_code
                    AND RecordType.DeveloperName = 'Academic_Program'
                    LIMIT 1
            ];
        } else if (String.isNotEmpty(major_id)) {
            Program__c programRecruitment = [
                    SELECT
                            Id, Name, Program_Major_Concentration__c
                    FROM Program__c
                    WHERE Id = :major_id
            ];
            if (programRecruitment != null) {
                academicPrograms = [
                        SELECT Id
                        FROM Program__c
                        WHERE Program_Major_Concentration__c = :programRecruitment.Program_Major_Concentration__c
                        AND RecordType.DeveloperName = 'Academic_Program'
                        LIMIT 1
                ];
            }
        }
        if (academicPrograms.size() > 0) {
            return academicPrograms[0].Id;
        } else {
            return null;
        }
    }
}