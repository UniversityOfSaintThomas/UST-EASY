/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-15-2022
 * @last modified by  : nicole.b@digitalmass.com
**/


//built-ins
import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { generateRecordInputForCreate, getRecordCreateDefaults } from 'lightning/uiRecordApi';

// lead object and fields
import LEAD_OBJECT from '@salesforce/schema/Lead';
import LEAD_FIRST_NAME from '@salesforce/schema/Lead.FirstName';
import LEAD_TITLE from '@salesforce/schema/Lead.Title';
import LEAD_ADMIT_TYPE from '@salesforce/schema/Lead.Admit_Type__c';
import LEAD_CITIZENSHIP from '@salesforce/schema/Lead.Citizenship_Type__c';
import LEAD_RECRUITMENT_PROGRAM from '@salesforce/schema/Lead.Recruitment_Program__c';
import LEAD_MAJOR1 from '@salesforce/schema/Lead.Major_Program__c';
import LEAD_MAJOR2 from '@salesforce/schema/Lead.Major_Program_2__c';
import LEAD_MAJOR3 from '@salesforce/schema/Lead.Major_Program_3__c';
import LEAD_MAJOR4 from '@salesforce/schema/Lead.Major_Program_4__c';
import LEAD_EMAIL from '@salesforce/schema/Lead.Email';
import LEAD_PHONE from '@salesforce/schema/Lead.Phone';
import LEAD_MOBILE_PHONE from '@salesforce/schema/Lead.MobilePhone';
import LEAD_TEXTS from '@salesforce/schema/Lead.Receive_Texts__c';
import LEAD_BIRTHDATE from '@salesforce/schema/Lead.Birthdate__c';
import LEAD_PREFERRED_ENROLLMENT from '@salesforce/schema/Lead.hed__Preferred_Enrollment_Date__c';
import LEAD_INTENDED_START_TERM from '@salesforce/schema/Lead.Intended_Start_Term__c';
import LEAD_STREET from '@salesforce/schema/Lead.Street';
import LEAD_CITY from '@salesforce/schema/Lead.City';
import LEAD_STATE from '@salesforce/schema/Lead.State';
import LEAD_POSTAL_CODE from '@salesforce/schema/Lead.PostalCode';
import LEAD_COUNTRY from '@salesforce/schema/Lead.Country';
import LEAD_HIGH_SCHOOL_OR_COLLEGE from '@salesforce/schema/Lead.High_School_or_College__c';
import LEAD_HIGH_SCHOOL_GRAD_YEAR from '@salesforce/schema/Lead.Expected_Graduate_Date__c';
import LEAD_TIMELINE from '@salesforce/schema/Lead.Timeline__c';
import LEAD_QUESTION from '@salesforce/schema/Lead.Has_Question__c';
import LEAD_DESCRIPTION from '@salesforce/schema/Lead.Description';
import LEAD_MAIL_INFO from '@salesforce/schema/Lead.Mail_Information_Requested__c';
import LEAD_COLLEGE_SCHOOL from '@salesforce/schema/Lead.St_Thomas_College_School__c';
import LEAD_RECENT_SCHOOL from '@salesforce/schema/Lead.hed__Most_Recent_School__c';

import FAMILY_OBJECT from '@salesforce/schema/Family_Member__c'; //using to get Country global picklist value set

//controller
import getRFIController from '@salesforce/apex/requestForInformationFormController.getRFIController';
import getPrograms from '@salesforce/apex/requestForInformationFormController.getPrograms';
import getTerms from '@salesforce/apex/requestForInformationFormController.getTerms';
import searchHighSchools from '@salesforce/apex/requestForInformationFormController.searchHighSchools';
import getAcademicLevelValue from '@salesforce/apex/requestForInformationFormController.getAcademicLevelValue';
import createLead from '@salesforce/apex/requestForInformationFormController.createLead';
import getPresetValues from '@salesforce/apex/requestForInformationFormController.getPresetValues';
import getSchoolCollegeAccount from '@salesforce/apex/requestForInformationFormController.getSchoolCollegeAccount';
import getRecruitmentProgram from '@salesforce/apex/requestForInformationFormController.getRecruitmentProgram';

const ADDITIONAL_FIELDS = [
    LEAD_FIRST_NAME,
    LEAD_TITLE,
    LEAD_ADMIT_TYPE,
    LEAD_CITIZENSHIP,
    LEAD_RECRUITMENT_PROGRAM,
    LEAD_MAJOR1,
    LEAD_MAJOR2,
    LEAD_MAJOR3,
    LEAD_MAJOR4,
    LEAD_EMAIL,
    LEAD_PHONE,
    LEAD_MOBILE_PHONE,
    LEAD_TEXTS,
    LEAD_BIRTHDATE,
    LEAD_PREFERRED_ENROLLMENT,
    LEAD_INTENDED_START_TERM,
    LEAD_STREET,
    LEAD_CITY,
    LEAD_STATE,
    LEAD_POSTAL_CODE,
    LEAD_COUNTRY,
    LEAD_HIGH_SCHOOL_OR_COLLEGE,
    LEAD_HIGH_SCHOOL_GRAD_YEAR,
    LEAD_TIMELINE,
    LEAD_QUESTION,
    LEAD_DESCRIPTION,
    LEAD_MAIL_INFO,
    LEAD_COLLEGE_SCHOOL,
    LEAD_RECENT_SCHOOL
];

export default class RequestForInformationForm extends LightningElement {
    // // RFI controller info
    @api rfi_controller = 'RFI Controller 0000';
    academic_level;
    academic_level_api;
    school_college_title;
    school_college;
    citizenship_type;
    lead_owner;
    redirect_url;
    fields_to_display;
    required_fields;
    @track hide_form_title = true;

    // lead info
    lead_default_record_type;
    all_lead_field_api_names = [];

    // family info - used to get Country global picklist value set
    family_default_record_type;

    // maps to populate picklists, where value is name and key is id of object
    program_id_to_name_map; // for Recruitment_Program__c
    term_id_to_name_map; // for Intended_Start_Term__c
    account_id_to_name_map; // for High_School_or_College__c

    //front-end display
    @track show_spinner = true;
    @track manually_enter_high_school = false;
    @track high_school_data = false;
    @track form_submitted_successfully = false;
    @track international_citizen_type = false;
    @track is_undergraduate = false;

    //RFI controller determined booleans
    @track show_fields = {
        'I_will_apply_to_St_Thomas_as_a': false,
        'Citizenship': false,
        'Academic_Interest': false,
        'Title': false,
        'Email': false,
        'Home_and_Mobile_Phone': false,
        'I_would_like_to_receive_text_messages': false,
        'Birthdate': false,
        'Employer': false,
        'Expected_Start_Term_at_St_Thomas': false,
        'High_School_Attended': false,
        'Address_1': false,
        'Address_2': false,
        'Address_3': false,
        'City': false,
        'State': false,
        'Zipcode': false,
        'Country': false,
        'High_School_Graduation_Year': false,
        'Timeline_to_Enrollment': false,
        'I_have_a_question': false,
        'Description': false,
        'I_would_like_program_information_to_be_mailed_to_me': false,
    }

    @track require_fields = {
        'I_will_apply_to_St_Thomas_as_a': false,
        'Citizenship': false,
        'Academic_Interest': false,
        'Title': false,
        'Email': false,
        'Home_Phone': false,
        'Mobile_Phone': false,
        'Birthdate': false,
        'Employer': false,
        'Expected_Start_Term_at_St_Thomas': false,
        'High_School_Attended': false,
        'Address_1': false,
        'Address_2': false,
        'Address_3': false,
        'City': false,
        'State': false,
        'Zipcode': false,
        'Country': false,
        'High_School_Graduation_Year': false,
        'Timeline_to_Enrollment': false,
        'I_have_a_question': false,
    }

    record_input; // stores user entered form information

    //field labels
    field_labels = {
        'admit_type_label' : 'I will apply to St. Thomas as a',
        'citizenship_label' : 'Citizenship',
        'academic_interest_label' : 'Academic Interest',
        'first_name_label' : 'First Name',
        'last_name_label' : 'Last Name',
        'email_label' : 'Email',
        'home_phone_label' : 'Home Phone',
        'mobile_phone_label' : 'Mobile Phone',
        'text_messages_label' : 'I would like to receive text messages',
        'birthdate_label' : 'Birthday (MM/DD/YYYY)',
        'address1_label' : 'Address 1',
        'address2_label' : 'Address 2',
        'address3_label' : 'Address 3',
        'city_label' : 'City',
        'state_label' : 'State',
        'region_label' : 'Region, Province, or State',
        'zipcode_label' : 'Zip Code',
        'country_label' : 'Country',
        'academic_term_label' : 'Expected Start Term at St. Thomas',
        'high_school_search_label' : 'High School Attended',
        'high_school_not_found_label' : 'I can\'t find my High School',
        'high_school_datatable_name' : 'High School Datatable',
        'employer_label': 'Employer',
        'title_label': 'Title',
        'high_school_graduation_year_label': 'High School Graduation (YYYY)',
        'timeline_label': 'Timeline to Enrollment',
        'has_question_label': 'I have a question',
        'description_label': 'Questions/Comments',
        'mail_info_label': 'I would like program information to be mailed to me',
    }

    //picklist values
    @track state_picklist_values;
    @track country_picklist_values;
    @track citizenship_picklist_values;
    @track admit_type_picklist_values;
    @track academic_level_picklist_values;
    @track academic_term_picklist_values;
    @track academic_interest_picklist_values;
    @track high_school_search_results; // populate via SOSL
    @track timeline_picklist_values;

    //intermediate values
    address1;
    address2;
    address3;
    academic_interest_id_list = [];
    
    //high school datatable columns
    high_school_columns = [
        { label: 'Name', fieldName: 'name', type: 'text' },
        { label: 'Address', fieldName: 'address', type: 'text', 
            cellAttributes: { class: 'slds-text-color_weak' }
        }
    ];

    /**
    ******************************************
    * Begin WIRES
    ******************************************
    */
    @wire(getRFIController, { rfi_controller_name: '$rfi_controller' })
    rfi(result) {
        if (result.data) {
            if (Boolean(result.data)) {
                this.academic_level_api = result.data.Academic_Level__c;
                if (this.academic_level_api == 'U') {
                    this.is_undergraduate = true;
                }
                if (Boolean(result.data.School_College__c)
                    && result.data.School_College__c != 'Graduate' 
                    && result.data.School_College__c != 'Undergraduate') {
                        this.school_college_title = 'from the ' + result.data.School_College__c;
                }
                this.school_college = result.data.School_College__c;
                this.citizenship_type = result.data.Citizenship_Type__c;
                this.fields_to_display = result.data.Fields_to_Display__c;
                this.required_fields = result.data.Required_Fields__c;
                this.lead_owner = result.data.Lead_Owner__c;
                this.redirect_url = result.data.Redirect_URL__c;
                this.hide_form_title = result.data.Hide_Form_Title__c;
                this.redirect_after_submit = result.data.Redirect_After_Form_Submission__c;
                // sets boolean values for front-end display i.e. which fields on are form, which are required
                this.handleFieldsToDisplay();
                this.handleRequiredFields();
                //gets value/label of picklist by api name to use in form title
                getAcademicLevelValue({api_name : result.data.Academic_Level__c})
                .then((level) => {
                    this.academic_level = level;
                })
                .catch(error => {
                    console.log(error);
                });
                getTerms({account_name : this.school_college})
                .then(terms => {
                    if (Boolean(terms)) {
                        this.term_id_to_name_map = terms;
                        var values = [];
                        for (const term in terms) {
                            values.push(
                                {label: terms[term].Name, value: terms[term].Id}
                            );
                        }
                        this.academic_term_picklist_values = values;
                    }
                })
                .catch(error => {
                    console.log(error);
                })
                if (Boolean(this.academic_level_api)) {
                    // gets programs based on academic level
                    getPrograms({academic_level: this.academic_level_api, school_college: this.school_college})
                    .then((programs) => {
                        this.program_id_to_name_map = programs;
                        var values = [];
                        if (this.academic_level == 'U') {
                            for (const program in programs) {
                                values.push(
                                    {label: programs[program].Name, value: programs[program].Id}
                                );
                            }
                        } else {
                            for (const program in programs) {
                                values.push(
                                    {label: programs[program].Name, value: programs[program].Id, description: programs[program].Degree__c}
                                );
                            }
                        }
                        this.academic_interest_picklist_values = values;
                    })
                    .catch(error => {
                        console.log(error);
                    });
                }
                this.show_spinner = false;
            }
        } else {
            console.log(result.error);
            this.show_spinner = false;
        }
    }

    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    object_info(result) {
        if (result.data) {
            this.lead_default_record_type = result.data.defaultRecordTypeId;
            var fields = new Map(Object.entries(result.data.fields));
            for (const field of fields) {
                this.all_lead_field_api_names.push(field[0]);
            }
        } else {
            console.log(result.error);
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: LEAD_OBJECT, recordTypeId: '$lead_default_record_type' })
    picklist_values(result) {
        if (result.data) {
            this.citizenship_picklist_values = result.data.picklistFieldValues.Citizenship_Type__c.values;
            this.admit_type_picklist_values = result.data.picklistFieldValues.Admit_Type__c.values;
            this.timeline_picklist_values = result.data.picklistFieldValues.Timeline__c.values;
        } else {
            console.log(result.error);
        }
    }

    @wire(getObjectInfo, { objectApiName: FAMILY_OBJECT })
    object_info_family(result) {
        if (result.data) {
            this.family_default_record_type = result.data.defaultRecordTypeId;
        } else {
            console.log(result.error);
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: FAMILY_OBJECT, recordTypeId: '$family_default_record_type' })
    picklist_values_family(result) {
        if (result.data) {
            this.country_picklist_values = result.data.picklistFieldValues.Birth_Country_Region_Territory__c.values;
        } else {
            console.log(result.error);
        }
    }

    @wire(getRecordCreateDefaults, { objectApiName: LEAD_OBJECT, optionalFields: ADDITIONAL_FIELDS})
    output(result) {
        if (result.data) {
            this.record_input = generateRecordInputForCreate(result.data.record);
            getPresetValues({rfi_controller_name : this.rfi_controller})
            .then(preset_values => {
                for (const preset_value of preset_values) {
                    if (this.all_lead_field_api_names.includes(preset_value.Field_API_Name__c)) {
                        this.record_input.fields[preset_value.Field_API_Name__c] = preset_value.Value__c;
                    }
                }
            })
            .catch(error => {
                console.log(error);
            })
        } else {
            console.log(result.error);
        }
    }

    /**
    ******************************************
    * END Wires
    ******************************************
    ******************************************
    * Begin OnChange
    ******************************************
    */

    onChange(event) {
        switch (event.target.label) {
            case this.field_labels.first_name_label:
                this.record_input.fields.FirstName = event.target.value;
                break;
            case this.field_labels.last_name_label:
                this.record_input.fields.LastName = event.target.value;
                break;
            case this.field_labels.email_label:
                this.record_input.fields.Email = event.target.value;
                break;
            case this.field_labels.home_phone_label:
                this.record_input.fields.Phone = event.target.value;
                break;
            case this.field_labels.mobile_phone_label:
                this.record_input.fields.MobilePhone = event.target.value;
                break;
            case this.field_labels.address1_label:
                this.address1 = event.target.value;
                break;
            case this.field_labels.address2_label:
                this.address2 = event.target.value;
                break;
            case this.field_labels.address3_label:
                this.address3 = event.target.value;
                break;
            case this.field_labels.city_label:
                this.record_input.fields.City = event.target.value;
                break;
            case this.field_labels.state_label:
                this.record_input.fields.State = event.target.value;
                break;
            case this.field_labels.region_label:
                this.record_input.fields.State = event.target.value;
                break;
            case this.field_labels.zipcode_label:
                this.record_input.fields.PostalCode = event.target.value;
                if (String(event.target.value).length === 5 
                    && String(event.target.value).match(/^[0-9]+$/) != null
                    && !this.international_citizen_type
                ) {
                    this.populateUSCityStateAndCountry(event.target.value);
                }
                break;
            case this.field_labels.country_label:
                this.record_input.fields.Country = event.target.value;
                if (event.target.value != 'United States of America') {
                    this.international_citizen_type = true;
                } else {
                    this.international_citizen_type = false;
                }
                break;
            case this.field_labels.text_messages_label:
                if (event.target.checked) {
                    this.record_input.fields.Receive_Texts__c = 'Yes';
                } else {
                    this.record_input.fields.Receive_Texts__c = 'No';
                }
                break;
            case this.field_labels.birthdate_label:
                this.record_input.fields.Birthdate__c = event.target.value;
                break;
            case this.field_labels.citizenship_label:
                this.record_input.fields.Citizenship_Type__c = event.target.value;
                if (event.target.value == 'International') {
                    this.international_citizen_type = true;
                } else {
                    this.international_citizen_type = false;
                }
                break;
            case this.field_labels.admit_type_label:
                this.record_input.fields.Admit_Type__c = event.target.value;
                break;
            case this.field_labels.academic_interest_label:
                if (this.is_undergraduate) {
                    this.academic_interest_id_list = event.detail.value;
                } else {
                    this.record_input.fields.Recruitment_Program__c = event.target.value;
                }
                break;
            case this.field_labels.academic_term_label:
                this.record_input.fields.Intended_Start_Term__c = event.target.value;
                this.record_input.fields.hed__Preferred_Enrollment_Date__c = this.term_id_to_name_map[event.target.value].Term_Start_Date__c;
                break;
            case this.field_labels.high_school_not_found_label:
                this.manually_enter_high_school = event.target.checked;
                if (event.target.checked) {
                    this.record_input.fields.High_School_or_College__c = '';
                    this.high_school_search_results = null;
                    this.high_school_data = false;
                }
                break;
            case this.field_labels.high_school_search_label:
                this.record_input.fields.hed__Most_Recent_School__c = event.target.value;
                break;
            case this.field_labels.employer_label:
                this.record_input.fields.Company = event.target.value;
                break;
            case this.field_labels.title_label:
                this.record_input.fields.Title = event.target.value;
                break;
            case this.field_labels.high_school_graduation_year_label:
                this.record_input.fields.Expected_Graduate_Date__c = event.target.value;
                break;
            case this.field_labels.timeline_label:
                this.record_input.fields.Timeline__c = event.target.value;
                break;
            case this.field_labels.has_question_label:
                this.record_input.fields.Has_Question__c = event.target.checked;
                this.show_fields.Description = event.target.checked;
                break;
            case this.field_labels.description_label:
                this.record_input.fields.Description = event.target.value;
                break;
            case this.field_labels.mail_info_label:
                this.record_input.fields.Mail_Information_Requested__c = event.target.checked;
                break;
            default:
                break;
        }

        if (event.target.name == this.field_labels.high_school_datatable_name) {
            var selected_row = this.template.querySelector('lightning-datatable').getSelectedRows();
            this.record_input.fields.High_School_or_College__c = selected_row[0].account_id;
            this.template.querySelector('lightning-input[data-id="high_school"]').value = selected_row[0].name;
        }
    }

    handleSearch(event) {
        if (JSON.stringify(event.target.value).length > 4) {
            searchHighSchools({ search_term : event.target.value })
            .then((high_schools) => {
                if (Boolean(Object.keys(high_schools))) {
                    this.high_school_data = true;
                    this.account_id_to_name_map = high_schools;
                    var values = [];
                    for (const school in high_schools) {
                        var address_info;
                        if (Boolean(high_schools[school].BillingCity) && Boolean(high_schools[school].BillingState)) {
                            address_info = high_schools[school].BillingCity + ', ' + high_schools[school].BillingState;
                        } else if (Boolean(high_schools[school].BillingCity) && Boolean(high_schools[school].BillingCountry)) {
                            address_info = high_schools[school].BillingCity + ', ' + high_schools[school].BillingCountry;
                        } else if (Boolean(high_schools[school].BillingCountry)) {
                            address_info = high_schools[school].BillingCountry;
                        } else {
                            address_info = 'Unknown';
                        }
                        values.push(
                            {   
                                name: high_schools[school].Name, 
                                account_id: high_schools[school].Id, 
                                address: address_info
                            }
                        );
                    }
                    this.high_school_search_results = values;
                }
            })
            .catch(error => {
                console.log(error);
            });
        } else {
            this.high_school_search_results = null;
            this.high_school_data = false;
        }
    } 

    /**
    ******************************************
    * END OnChange
    ******************************************
    ******************************************
    * Begin OnClick
    ******************************************
    */

    handleSubmit() {
        if (this.validateInput()) {
            this.show_spinner = true;
            this.record_input.fields.OwnerId = this.lead_owner;
            if (!Boolean(this.record_input.fields.Company)) {
                this.record_input.fields.Company = this.record_input.fields.FirstName + ' ' + this.record_input.fields.LastName;
            }
            this.record_input.fields.Inquiry_Date__c = this.getTodaysDate();
            this.handleStreetAddress();
            if (Boolean(this.record_input.fields.Description)) {
                this.record_input.fields.Description = 'Questions/Comments from RFI: ' + this.record_input.fields.Description;
            }
            getSchoolCollegeAccount({school_college_name : this.school_college})
            .then(school_college_account_id => {
                if (Boolean(school_college_account_id)){
                    this.record_input.fields.St_Thomas_College_School__c = school_college_account_id;
                }
                this.handleRecruitmentProgram();
            })
            .catch(error => {
                console.log(error);
                this.handleRecruitmentProgram();
            })
        }
    }

    /**
    ******************************************
    * END OnClick
    ******************************************
    */

    /**
    ******************************************
    * BEGIN Helper Methods
    ******************************************
    */

    handleRecruitmentProgram() {
        var count = 0;
        if (this.is_undergraduate) {
            for (const program_id of this.academic_interest_id_list) {
                if (count == 0) {
                    this.record_input.fields.Major_Program__c = program_id;
                } else if (count == 1) {
                    this.record_input.fields.Major_Program_2__c = program_id;
                } else if (count == 2) {
                    this.record_input.fields.Major_Program_3__c = program_id;
                } else {
                    this.record_input.fields.Major_Program_4__c = program_id;
                }
                count++;
            }
            getRecruitmentProgram({academic_level: this.academic_level_api, citizenship_type: this.record_input.fields.Citizenship_Type__c, admit_type: this.record_input.fields.Admit_Type__c})
            .then(program => {
                if (Boolean(program)) {
                    this.record_input.fields.Recruitment_Program__c = String(program);
                }
                this.createLead();
            })
            .catch(error => {
                console.log(error);
                this.createLead();
            })
        } else {
            this.createLead();
        }
    }

    createLead() {
        console.log(this.record_input.fields);
        createLead({ record : JSON.stringify(this.record_input.fields), objectApiName : 'Lead', rfiController : this.rfi_controller})
        .then(() => {
            this.show_spinner = false;
            this.form_submitted_successfully = true;
            if (this.redirect_after_submit) {
                window.open(this.redirect_url, '_self');
            }
        })
        .catch(error => {
            console.log(error);
            this.show_spinner = false;
        });
    }

    // used Fields_to_Display__c field on RFI_Controller__c to determine which fields to display on form
    handleFieldsToDisplay() {
        var fields = this.fields_to_display.split(';');
        for (const field of fields) {
            var object_property = field.replaceAll(' ', '_');
            this.show_fields[object_property] = true;
        }
    }

    handleRequiredFields() {
        var fields = this.required_fields.split(';');
        for (const field of fields) {
            var object_property = field.replaceAll(' ', '_');
            this.require_fields[object_property] = true;
        }
    }

    validateInput() {
        let valid_input_fields = this.validateInputFields();
        let valid_picklist_fields = this.validatePicklistFields();
        let valid_multi_picklist_fields = this.validateMultiPicklistFields();
        if (valid_input_fields && valid_picklist_fields && valid_multi_picklist_fields) {
            return true;
        } else {
            return false;
        }
    }

    //https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation
    validateInputFields() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            return true;
        } else {
            return false;
        }
    }

    validatePicklistFields() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            return true;
        } else {
            return false;
        }
    }

    validateMultiPicklistFields() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-dual-listbox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            return true;
        } else {
            return false;
        }
    }

    handleStreetAddress() {
        if (Boolean(this.address1) && Boolean(this.address2) && Boolean(this.address3)) {
            this.record_input.fields.Street = this.address1 + ', ' + this.address2 + ', ' + this.address3;
        } else if (Boolean(this.address1) && Boolean(this.address2)) {
            this.record_input.fields.Street = this.address1 + ', ' + this.address2;
        } else if (Boolean(this.address1)) {
            this.record_input.fields.Street = this.address1;
        }
    }

    getTodaysDate() {
        const date = new Date();
        let day = String(date.getDate());
        let month = String(date.getMonth() + 1);
        let year = String(date.getFullYear());
        return year + '-' + month + '-' + day;
    }

    populateUSCityStateAndCountry(zipcode) {
        this.show_spinner = true;
        let url = 'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&addressdetails=1&postalcode=' + String(zipcode) + '&countrycodes=US';
        fetch(url)
        .then((response) => response.json())
        .then((result) => {
            let city = result[0].address.city;
            if (city == null) {
                city = result[0].address.hamlet;
            }
            if (city == null) {
                city = result[0].address.town;
            }
            if (city == null) {
                city = result[0].address.municipality;
            }

            let state = result[0].address.state;
            if (state == null) {
                state = result[0].address.county;
            }

            if (this.show_fields.City) {
                this.template.querySelector('lightning-input[data-id="city"]').value = city;
                this.record_input.fields.City = city;
            }
            if (this.show_fields.State) {
                let state_map = this.getStateMap();
                this.template.querySelector('lightning-combobox[data-id="state"]').value = state_map[state];
                this.record_input.fields.State = state_map[state];
            }
            if (this.show_fields.Country) {
                this.template.querySelector('lightning-combobox[data-id="country"]').value = 'United States of America';
                this.record_input.fields.Country = 'United States of America';
            }
            this.show_spinner = false;
        })
        .catch((error) => {
            console.log(error);
            this.show_spinner = false;
        })
    }

    // can't query for state picklist values -- would need to be on a field
    get stateOptions() {
        return [
            { label: 'Alabama', value: 'AL' },
            { label: 'Alaska', value: 'AK' },
            { label: 'American Samoa', value: 'AS' },
            { label: 'Arizona', value: 'AZ' },
            { label: 'Arkansas', value: 'AK' },
            { label: 'Armed Forces the Americas', value: 'AA' },
            { label: 'Armed Forces Europe', value: 'AE' },
            { label: 'Armed Forces Pacific', value: 'AP' },
            { label: 'California', value: 'CA' },
            { label: 'Colorado', value: 'CO' },
            { label: 'Connecticut', value: 'CT' },
            { label: 'Delaware', value: 'DE' },
            { label: 'District of Columbia', value: 'DC' },
            { label: 'Micronesia', value: 'FM' },
            { label: 'Florida', value: 'FL' },
            { label: 'Georgia', value: 'GA' },
            { label: 'Guam', value: 'Guam' },
            { label: 'Hawaii', value: 'HI' },
            { label: 'Idaho', value: 'ID' },
            { label: 'Illinois', value: 'IL' },
            { label: 'Indiana', value: 'IN' },
            { label: 'Iowa', value: 'IA' },
            { label: 'Kansas', value: 'KS' },
            { label: 'Kentucky', value: 'KY' },
            { label: 'Louisiana', value: 'LA' },
            { label: 'Maine', value: 'ME' },
            { label: 'Marshall Islands', value: 'MH' },
            { label: 'Maryland', value: 'MD' },
            { label: 'Massachusetts', value: 'MA' },
            { label: 'Michigan', value: 'MI' },
            { label: 'Minnesota', value: 'MN' },
            { label: 'Mississippi', value: 'MS' },
            { label: 'Missouri', value: 'MO' },
            { label: 'Montana', value: 'MT' },
            { label: 'Nebraska', value: 'NE' },
            { label: 'Nevada', value: 'NV' },
            { label: 'New Hampshire', value: 'NH' },
            { label: 'New Jersey', value: 'NJ' },
            { label: 'New Mexico', value: 'NM' },
            { label: 'New York', value: 'NY' },
            { label: 'North Carolina', value: 'NC' },
            { label: 'North Dakota', value: 'ND' },
            { label: 'Northern Mariana Islands', value: 'MP' },
            { label: 'Ohio', value: 'OH' },
            { label: 'Oklahoma', value: 'OK' },
            { label: 'Oregon', value: 'OR' },
            { label: 'Palau', value: 'PW' },
            { label: 'Pennsylvania', value: 'PA' },
            { label: 'Puerto Rico', value: 'PR' },
            { label: 'Rhode Island', value: 'RI' },
            { label: 'South Carolina', value: 'SC' },
            { label: 'South Dakota', value: 'SD' },
            { label: 'Tennessee', value: 'TN' },
            { label: 'Texas', value: 'TX' },
            { label: 'Utah', value: 'UT' },
            { label: 'Vermont', value: 'VT' },
            { label: 'Virgin Islands', value: 'VI' },
            { label: 'Virginia', value: 'VA' },
            { label: 'Washington', value: 'WA' },
            { label: 'West Virginia', value: 'WV' },
            { label: 'Wisconsin', value: 'WI' },
            { label: 'Wyoming', value: 'WY' }
        ];
    }

    getStateMap() {
        let state_map = new Map();
        state_map.set('Alabama', 'AL');
        state_map.set('Alaska', 'AK');
        state_map.set('American Samoa', 'AS');
        state_map.set('Arizona', 'AZ');
        state_map.set('Arkansas', 'AK');
        state_map.set('Armed Forces the Americas', 'AA');
        state_map.set('Armed Forces Europe', 'AE');
        state_map.set('Armed Forces Pacific', 'AP');
        state_map.set('California', 'CA');
        state_map.set('Colorado', 'CO');
        state_map.set('Connecticut', 'CT');
        state_map.set('Delaware', 'DE');
        state_map.set('District of Columbia', 'DC');
        state_map.set('Micronesia', 'FM');
        state_map.set('Florida', 'FL');
        state_map.set('Georgia', 'GA');
        state_map.set('Guam', 'Guam');
        state_map.set('Hawaii', 'HI');
        state_map.set('Idaho', 'ID');
        state_map.set('Illinois', 'IL');
        state_map.set('Indiana', 'IN');
        state_map.set('Iowa', 'IA');
        state_map.set('Kansas', 'KS');
        state_map.set('Kentucky', 'KY');
        state_map.set('Louisiana', 'LA');
        state_map.set('Maine', 'ME');
        state_map.set('Marshall Islands', 'MH');
        state_map.set('Maryland', 'MD');
        state_map.set('Massachusetts', 'MA');
        state_map.set('Michigan', 'MI');
        state_map.set('Minnesota', 'MN');
        state_map.set('Mississippi', 'MS');
        state_map.set('Missouri', 'MO');
        state_map.set('Montana', 'MT');
        state_map.set('Nebraska', 'NE');
        state_map.set('Nevada', 'NV');
        state_map.set('New Hampshire', 'NH');
        state_map.set('New Jersey', 'NJ');
        state_map.set('New Mexico', 'NM');
        state_map.set('New York', 'NY');
        state_map.set('North Carolina', 'NC');
        state_map.set('North Dakota', 'ND');
        state_map.set('Northern Mariana Islands', 'MP');
        state_map.set('Ohio', 'OH');
        state_map.set('Oklahoma', 'OK');
        state_map.set('Oregon', 'OR');
        state_map.set('Palau', 'PW');
        state_map.set('Pennsylvania', 'PA');
        state_map.set('Puerto Rico', 'PR');
        state_map.set('Rhode Island', 'RI');
        state_map.set('South Carolina', 'SC');
        state_map.set('South Dakota', 'SD');
        state_map.set('Tennessee', 'TN');
        state_map.set('Texas', 'TX');
        state_map.set('Utah', 'UT');
        state_map.set('Vermont', 'VT');
        state_map.set('Virgin Islands', 'VI');
        state_map.set('Virginia', 'VA');
        state_map.set('Washington', 'WA');
        state_map.set('West Virginia', 'WV');
        state_map.set('Wisconsin', 'WI');
        state_map.set('Wyoming', 'WY');
        return state_map;
    }
        /**
    ******************************************
    * END Helper Methods
    ******************************************
    */
}