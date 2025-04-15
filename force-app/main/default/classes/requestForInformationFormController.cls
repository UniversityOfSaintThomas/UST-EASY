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
            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(record);
            SObject sObj = Schema.getGlobalDescribe().get(objectApiName).newSObject();
            Map<String, SObjectField> fieldMap = sObj.getSObjectType().getDescribe().fields.getMap();

            for (String field : objMap.keySet()) {
                Schema.SObjectField sObjField = fieldMap.get(field);
                if (sObjField == null) continue;

                Object fieldValue = objMap.get(field);
                if (fieldValue == null) {
                    sObj.put(field, null);
                    continue;
                }

                String fieldType = sObjField.getDescribe().getType().name().toLowerCase();
                switch on fieldType {
                    when 'date' {
                        sObj.put(field, Date.valueOf((String) fieldValue));
                    }
                    when 'datetime' {
                        sObj.put(field, Datetime.valueOf(((String) fieldValue).replace('T', ' ').replace('Z', '')));
                    }
                    when 'reference' {
                        try {
                            sObj.put(field, (Id) fieldValue.toString().escapeHtml4());
                        } catch (Exception e) {
                            // value wasn't an id and did not convert
                        }
                    }
                    when else {
                        Integer fieldLength = sObjField.getDescribe().getLength();
                        String fieldValueStr = fieldValue.toString().escapeHtml4();
                        if (field.startsWith('utm_') || field.startsWith('gclid')) {
                            sObj.put(field, fieldValueStr);
                        } else if (fieldLength > 0 && (fieldType == 'string' || fieldType == 'url')) {
                            sObj.put(field, fieldValueStr.abbreviate(fieldLength));
                        } else {
                            sObj.put(field, fieldValue);
                        }
                    }
                }
            }

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.duplicateRuleHeader.allowSave = false;
            Database.SaveResult result = Database.insert(sObj, dml);

            if (!result.isSuccess()) {
                insertErrorRecord(rfiController, record, 'Creation of lead failed on insert. \n Error: ' + result.getErrors());
            }
        } catch (Exception e) {
            insertErrorRecord(rfiController, record, 'Creation of lead failed because of caught exception in requestForInformationFormController.createLead(). \n Error: ' + e.getMessage());
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
    public static RFI_Controller__c getRFIController(String rfi_controller_name, String recordId) {
        Id recordIdConverted = null;
        try {
            recordIdConverted = recordId;
        } catch (Exception e) {
            //could not convert to Id
        }
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
                            Redirect_After_Form_Submission__c,
                            Multi_Select_Display_Type__c,
                            Additional_Questions__c,
                            Academic_Interest_Max_Selection__c,
                            Disable_fields_to_display__c,
                            School_College_To_Display__c,
                            School_College_Question__c,
                            Citizen_Type_Question__c,
                            Citizen_Types_To_Display__c,
                            Degree_Type_Question__c,
                            Degree_Type_To_Display__c,
                            Student_Type_Question__c,
                            Student_Type_To_Display__c,
                            Delivery_Type_Question__c,
                            Delivery_Type_To_Display__c,
                            Program_Type_Question__c,
                            Program_Type_To_Display__c,
                            Generic_Filter_2_Question__c,
                            Generic_Filter_2_To_Display__c,
                            Generic_Filter_3_Question__c,
                            Generic_Filter_3_To_Display__c,
                            Generic_Filter_4_Question__c,
                            Generic_Filter_4_To_Display__c,
                            Generic_Filter_6_Question__c,
                            Generic_Filter_6_To_Display__c,
                            Generic_Filter_7_Question__c,
                            Generic_Filter_7_To_Display__c,
                            Generic_Filter_8_Question__c,
                            Generic_Filter_8_To_Display__c
                    FROM RFI_Controller__c
                    WHERE Id = :recordIdConverted
                    OR (Name = :rfi_controller_name AND Name != 'RFI Controller 000' AND Id = NULL)
                    LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving RFI Controller: ' + e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getProgramIds(String academic_interest_codes) {
        List<String> programIds = new List<Id>();
        academic_interest_codes = academic_interest_codes.escapeHtml4();
        List<String> programCodes = academic_interest_codes.split(';');
        List<Program__c> programs = [
                SELECT Id
                FROM Program__c
                WHERE Program_Major_Concentration__c IN :programCodes
                AND RecordType.DeveloperName = 'Recruitment_Program'
                //AND Program_Display__c INCLUDES ('RFI')
                AND Active__c = TRUE
        ];
        for (Program__c p : programs) {
            programIds.add(p.Id);
        }
        return programIds;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<Id, Program__c> getPrograms(String academic_level, String school_college, String academic_interest_codes, Boolean multi_select_standard) {
        try {
            String query_string =
                    //Student type buckets
                    'SELECT ' +
                            'Id, ' +
                            'Name, ' +
                            'Program_Name_on_Application__c, ' +
                            'Student_Type__c, ' +
                            'Degree__c, ' +
                            'Degree_Type__c, ' +
                            'Delivery_Type__c, ' +
                            'Program_Major_Concentration__c ' +
                            'FROM Program__c ' +
                            'WHERE RecordType.DeveloperName = \'Recruitment_Program\' ' +
                            'AND Program_Display__c INCLUDES (\'RFI\') ' +
                            'AND Active__c = true ';
            if (academic_level == 'U' || academic_level == 'Undergraduate') {
                query_string += ' AND (Academic_Level__c = \'Undergraduate\' OR Academic_Level__c = \'U\') ';
                query_string += ' AND (Program_Type__c INCLUDES (\'Major\') OR Program_Type__c INCLUDES (\'Pre-Professional\') OR Program_Type__c INCLUDES (\'Major Concentration\') OR Program_Type__c INCLUDES (\'Co-Major\')) ';
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
            if (multi_select_standard) {
                query_string += ' ORDER BY Program_Name_on_Application__c ';
            } else {
                query_string += ' ORDER BY Degree__c, Program_Name_on_Application__c ';
            }

            //System.debug('PROGRAM QUERY: ');
            //System.debug(query_string);
            List<Program__c> programs = Database.query(query_string);
            //System.debug(JSON.serializePretty(programs));
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

    @AuraEnabled(Cacheable=true)
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

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getCountries() {
        Map<String, String> mapCountryCodeString = new Map<String, String>();
        Schema.SObjectType objType = Contact.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> values = fieldMap.get('MailingCountryCode').getDescribe().getPicklistValues();
        for (Schema.PicklistEntry a : values) {
            mapCountryCodeString.put(a.getLabel(), a.getValue());
        }
        return mapCountryCodeString;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Lead_Preset_Value__mdt> getPresetValues(String rfi_controller_name) {
        try {
            List<Lead_Preset_Value__mdt> return_preset_values = new List<Lead_Preset_Value__mdt>();
            List<Lead_Preset_Value__mdt> preset_values = [
                    SELECT Field_API_Name__c, Value__c
                    FROM Lead_Preset_Value__mdt
                    WHERE RFI_Controller_Name__c = :rfi_controller_name
                    AND Active__c = TRUE
            ];
            if (preset_values.size() > 0) {
                return preset_values;
            }
            return return_preset_values;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static String getSchoolCollegeAccount(String school_college_name) {
        try {
            String school_college_id = '';
            List<Account> school_college_accounts = [
                    SELECT Id
                    FROM Account
                    WHERE School_College_Name__c = :school_college_name
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

    @AuraEnabled(Cacheable=true)
    public static Id getRecruitmentProgram(String academic_level, String citizenship_type, String admit_type, String major_id, String school_name) {
        String program_name = '';
        String program_code = 'AS_UN_BA';
        //.debug('SCHOOL_NAME: ' + school_name);
        //System.debug('ACADEMIC_LEVEL: ' + academic_level);
        //System.debug('MAJOR ID: ' + major_id);
        //System.debug('CITIZENSHIP TYPE: ' + citizenship_type);
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