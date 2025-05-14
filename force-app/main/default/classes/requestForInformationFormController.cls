/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-15-2022
 * @last modified by  : nicole.b@digitalmass.com
**/

public without sharing class requestForInformationFormController {

    public class fieldItem {
        //Generate auto generate a unique id for each field
        @AuraEnabled
        public String id {
            get {
                if (id == null) {
                    id = String.valueOf(UUID.randomUUID());
                }
                return id;
            }
            set;
        }
        @AuraEnabled
        public String field_label { get; set; }
        @AuraEnabled
        public Boolean required { get; set; }
        @AuraEnabled
        public Boolean show { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public List<SelectOption> picklistValues { get; set; }
    }

    public class rfiWrapper {
        @AuraEnabled
        public RFI_Controller__c rfi_controller { get; set; }
        @AuraEnabled
        public Map<Id, Program__c> programs { get; set; }
        @AuraEnabled
        public Map<Id, Academic_Term__c> terms { get; set; }
        @AuraEnabled
        public String academic_level_value { get; set; }
        @AuraEnabled
        public Map<String, String> countries { get; set; }
        @AuraEnabled
        public Map<String, fieldItem> field_definitions { get; set; }
    }

    //Wrapper class for rfi controller, program, term, academic level, countries
    @AuraEnabled(cacheable=true)
    public static rfiWrapper getRFIData(String rfi_controller_name, String recordId) {
        rfiWrapper rfi_data = new rfiWrapper();
        rfi_data.rfi_controller = getRFIController(rfi_controller_name, recordId);
        if(rfi_data.rfi_controller != null) {
            rfi_data.programs = new Map<Id, Program__c>();
            rfi_data.terms = new Map<Id, Academic_Term__c>();
            rfi_data.field_definitions = getFieldItemDefinitions(rfi_data.rfi_controller);
            List<Program__c> programs = new List<Program__c>();
            Map<Id, Program__c> program_map = new Map<Id, Program__c>();
            program_map = getPrograms(rfi_data.rfi_controller.Academic_Level__c, rfi_data.rfi_controller.School_College__c, rfi_data.rfi_controller.Academic_Interests_To_Display__c, false);
            rfi_data.terms = getTerms(null);
            rfi_data.programs = program_map;
            rfi_data.academic_level_value = getAcademicLevelValue(rfi_data.rfi_controller.Academic_Level__c);
            rfi_data.countries = getCountries();
        }
        System.debug('rfi_data: ' + JSON.serializePretty(rfi_data));
        return rfi_data;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<string, fieldItem> getFieldItemDefinitions(RFI_Controller__c rfi_controller) {
        Map<string, fieldItem> fieldItemMap = new Map<string, fieldItem>();
        fieldItem fi = new fieldItem();

        fi.field_label = 'I will apply to St. Thomas as a';
        fi.required = rfi_controller.Required_Fields__c.contains('I will apply to St. Thomas as a') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('I will apply to St. Thomas as a') ? true : false;
        fi.type = 'radio';
        fi.picklistValues = createExistingPicklist('Lead', 'Admit_Type__c');
        fieldItemMap.put('I_will_apply_to_St_Thomas_as_a', fi);

        fi.field_label = 'College\\School';
        fi.required = rfi_controller.Required_Fields__c.contains('St Thomas Colleges') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('St Thomas Colleges') ? true : false;
        fi.type = 'select';
        fi.picklistValues = createExistingPicklist('RFI_Controller__c', 'School_College__c');
        fieldItemMap.put('St_Thomas_Colleges', fi);

        fi.field_label = 'Citizenship';
        fi.required = rfi_controller.Required_Fields__c.contains('Citizenship') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Citizenship') ? true : false;
        fi.type = 'radio';
        fi.picklistValues = createExistingPicklist('Lead', 'Citizenship_Type__c');
        fieldItemMap.put('Citizenship', fi);

        fi.field_label = 'Academic Interest (Max 4)';
        fi.required = rfi_controller.Required_Fields__c.contains('Academic Interest') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Academic Interest') ? true : false;
        fi.picklistValues = createExistingPicklist('Program__c', 'Program_Major_Concentration__c');
        fi.type = 'multi-select';
        fieldItemMap.put('Academic_Interest', fi);

        fi.field_label = 'Title';
        fi.required = rfi_controller.Required_Fields__c.contains('Title') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Title') ? true : false;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'text';
        fieldItemMap.put('Title', fi);

        fi.field_label = 'First Name';
        fi.required = true;
        fi.show = true;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'text';
        fieldItemMap.put('FirstName', fi);

        fi.field_label = 'Last Name';
        fi.required = true;
        fi.show = true;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'text';
        fieldItemMap.put('LastName', fi);

        fi.field_label = 'Email';
        fi.required = rfi_controller.Required_Fields__c.contains('Email') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Email') ? true : false;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'email';
        fieldItemMap.put('Email', fi);

        fi.field_label = 'Home Phone';
        fi.required = rfi_controller.Required_Fields__c.contains('Home Phone') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Home and Mobile Phone') ? true : false;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'phone';
        fieldItemMap.put('Home_Phone', fi);

        fi.field_label = 'Mobile Phone';
        fi.required = rfi_controller.Required_Fields__c.contains('Mobile Phone') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Home and Mobile Phone') ? true : false;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'phone';
        fieldItemMap.put('Mobile_Phone', fi);

        fi.field_label = 'Phone';
        fi.required = rfi_controller.Required_Fields__c.contains('Phone') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Phone') ? true : false;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'phone';
        fieldItemMap.put('Phone', fi);

        fi.field_label = 'I would like to receive text messages';
        fi.required = rfi_controller.Required_Fields__c.contains('I would like to receive text messages') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('I would like to receive text messages') ? true : false;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'checkbox';
        fieldItemMap.put('I_would_like_to_receive_text_messages', fi);

        fi.field_label = 'Birthdate';
        fi.required = rfi_controller.Required_Fields__c.contains('Birthdate') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Birthdate') ? true : false;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'date';
        fieldItemMap.put('Birthdate', fi);

        fi.field_label = 'Employer';
        fi.required = rfi_controller.Required_Fields__c.contains('Employer') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Employer') ? true : false;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'text';
        fieldItemMap.put('Employer', fi);

        //TODO: picklist relies on school account selected and will probably always have to be dynamic
        fi.field_label = 'Expected Start Term at St. Thomas';
        fi.required = rfi_controller.Required_Fields__c.contains('Expected Start Term at St. Thomas') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Expected Start Term at St. Thomas') ? true : false;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'select';
        fieldItemMap.put('Expected_Start_Term_at_St_Thomas', fi);

        fi.field_label = 'Timeline to Enrollment';
        fi.required = rfi_controller.Required_Fields__c.contains('Timeline to Enrollment') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Timeline to Enrollment') ? true : false;
        fi.picklistValues = createExistingPicklist('Lead', 'Timeline__c');
        fi.type = 'select';
        fieldItemMap.put('Timeline_to_Enrollment', fi);

        fi.field_label = 'High School Attended';
        fi.required = rfi_controller.Required_Fields__c.contains('High School Attended') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('High School Attended') ? true : false;
        fi.picklistValues = new List<SelectOption>();
        fi.type = 'lookup';
        fieldItemMap.put('High_School_Attended', fi);

        fi.field_label = 'Address 1';
        fi.required = rfi_controller.Required_Fields__c.contains('Address 1') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Address 1') ? true : false;
        fi.type = 'text';
        fieldItemMap.put('Address_1', fi);

        fi.field_label = 'Address 2';
        fi.required = rfi_controller.Required_Fields__c.contains('Address 2') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Address 2') ? true : false;
        fi.type = 'text';
        fieldItemMap.put('Address_2', fi);

        fi.field_label = 'Address 3';
        fi.required = rfi_controller.Required_Fields__c.contains('Address 3') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Address 3') ? true : false;
        fi.type = 'text';
        fieldItemMap.put('Address_3', fi);

        fi.field_label = 'City';
        fi.required = rfi_controller.Required_Fields__c.contains('City') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('City') ? true : false;
        fi.type = 'text';
        fieldItemMap.put('City', fi);

        fi.field_label = 'State';
        fi.required = rfi_controller.Required_Fields__c.contains('State') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('State') ? true : false;
        fi.type = 'text';
        fieldItemMap.put('State', fi);

        fi.field_label = 'Zipcode';
        fi.required = rfi_controller.Required_Fields__c.contains('Zipcode') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Zipcode') ? true : false;
        fi.type = 'text';
        fieldItemMap.put('Zipcode', fi);

        fi.field_label = 'Country';
        fi.required = rfi_controller.Required_Fields__c.contains('Country') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Country') ? true : false;
        fi.type = 'select';
        fieldItemMap.put('Country', fi);

        fi.field_label = 'High School Graduation Year';
        fi.required = rfi_controller.Required_Fields__c.contains('High School Graduation Year') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('High School Graduation Year') ? true : false;
        fi.type = 'text';
        fieldItemMap.put('High_School_Graduation_Year', fi);

        fi.field_label = 'I have a question';
        fi.required = rfi_controller.Required_Fields__c.contains('I have a question') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('I have a question') ? true : false;
        fi.type = 'checkbox';
        fieldItemMap.put('I_have_a_question', fi);

        fi.field_label = 'Description';
        fi.required = rfi_controller.Required_Fields__c.contains('Description') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Description') ? true : false;
        fi.type = 'textarea';
        fieldItemMap.put('Description', fi);

        fi.field_label = 'I would like program information to be mailed to me';
        fi.required = rfi_controller.Required_Fields__c.contains('I would like program information to be mailed to me') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('I would like program information to be mailed to me') ? true : false;
        fi.type = 'checkbox';
        fieldItemMap.put('I_would_like_program_information_to_be_mailed_to_me', fi);

        fi.field_label = 'Phone';
        fi.required = rfi_controller.Required_Fields__c.contains('Phone') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Phone') ? true : false;
        fi.type = 'phone';
        fieldItemMap.put('Phone', fi);

        fi.field_label = 'How did you hear about us';
        fi.required = rfi_controller.Required_Fields__c.contains('How did you hear about us') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('How did you hear about us') ? true : false;
        fi.type = 'select';
        fieldItemMap.put('How_did_you_hear_about_us', fi);

        fi.field_label = 'Tell us about yourself';
        fi.required = rfi_controller.Required_Fields__c.contains('Tell us about yourself') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Tell us about yourself') ? true : false;
        fi.type = 'textarea';
        fieldItemMap.put('Tell_us_about_yourself', fi);

        fi.field_label = 'Scholarship of Interest';
        fi.required = rfi_controller.Required_Fields__c.contains('Scholarship of Interest') ? true : false;
        fi.show = rfi_controller.Fields_to_Display__c.contains('Scholarship of Interest') ? true : false;
        fi.type = 'select';
        fieldItemMap.put('Scholarship_of_Interest', fi);

        fi.field_label = String.isNotBlank(rfi_controller.School_College_Question__c) ? rfi_controller.School_College_Question__c : 'What college are you interested in?';
        fi.required = String.isNotBlank(rfi_controller.School_College_To_Display__c) ? true : false;
        fi.show = String.isNotBlank(rfi_controller.School_College_To_Display__c) ? true : false;
        fi.type = 'select';
        fieldItemMap.put('program_filter_school', fi);

        return fieldItemMap;
    }

    public static List<SelectOption> createExistingPicklist(String objectString, String existingPicklist) {
        List<SelectOption> picklists = new List<SelectOption>();
        Type registrationType = Type.forName(objectString);
        SObject registrationObj = (SObject) registrationType.newInstance();
        DescribeSObjectResult registrationDescribe = registrationObj.getSObjectType().getDescribe();
        List<Schema.PicklistEntry> PicklistValues = registrationDescribe.fields.getMap().get(existingPicklist).getDescribe().getPicklistValues();
        picklists.add(new SelectOption('', 'Select...'));
        for (Schema.PicklistEntry PicklistValue : PicklistValues) {
            picklists.add(new SelectOption(PicklistValue.getValue(), PicklistValue.getLabel()));
        }
        return picklists;
    }

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
                if (objMap.get(field) == null) {
                    sobj.put(field, null);
                } else {
                    String fieldType = sObjField.getDescribe().getType().name().toLowerCase();
                    switch on fieldType {
                        when 'date' {
                            sobj.put(field, Date.valueOf((String) objMap.get(field)));
                        } when 'datetime' {
                            sobj.put(field, Datetime.valueOf(((String) objMap.get(field)).replace('T', ' ').replace('Z', '')));
                        } when 'reference' {
                            try {
                                sobj.put(field, (Id) objMap.get(field).toString().escapeHtml4());
                            } catch (Exception e) {
                                //value wasn't an id and did not convert
                            }
                        } when else {
                            Integer fieldLength = sObjField.getDescribe().getLength();
                            if (field.startsWith('utm_') || field.startsWith('gclid')) {
                                sobj.put(field, objMap.get(field).toString().escapeHtml4());
                            }
                            if (fieldLength > 0 && fieldType == 'string' || fieldType == 'url') {
                                sobj.put(field, objMap.get(field).toString().abbreviate(fieldLength));
                            } else {
                                sobj.put(field, objMap.get(field));
                            }

                        }
                    }
                }
            }

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.duplicateRuleHeader.allowSave = false;
            //System.debug('Lead object for insert: ');
            //System.debug(JSON.serializePretty(sobj));
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
                            Citizen_Types_To_Display__c,
                            Citizen_Type_Question__c,
                            Country__c,
                            Degree_Type_Question__c,
                            Degree_Type_To_Display__c,
                            Delivery_Type_Question__c,
                            Delivery_Type_To_Display__c,
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
                            Generic_Filter_8_To_Display__c,
                            Program_Type_Question__c,
                            Program_Type_To_Display__c,
                            School_College_Question__c,
                            School_College_To_Display__c,
                            Student_Type_Question__c,
                            Student_Type_To_Display__c
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
        Schema.sObjectType objType = Contact.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> values = fieldMap.get('MailingCountryCode').getDescribe().getPickListValues();
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