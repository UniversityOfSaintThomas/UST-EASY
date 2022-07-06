/**
 * author: nicole.b@digitalmass.com
 * created-date: 2022-06-01
 * last-modified: 2022-06-06
 */

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
import LEAD_EMAIL from '@salesforce/schema/Lead.Email';
import LEAD_PHONE from '@salesforce/schema/Lead.Phone';
import LEAD_MOBILE_PHONE from '@salesforce/schema/Lead.MobilePhone';
import LEAD_SMS_OPT_OUT from '@salesforce/schema/Lead.hed__SMS_Opt_Out__c';
import LEAD_BIRTHDATE from '@salesforce/schema/Lead.Birthdate__c';
import LEAD_PREFERRED_ENROLLMENT from '@salesforce/schema/Lead.hed__Preferred_Enrollment_Date__c';
import LEAD_TERM from '@salesforce/schema/Lead.Term__c';
import LEAD_STREET from '@salesforce/schema/Lead.Street';
import LEAD_CITY from '@salesforce/schema/Lead.City';
import LEAD_STATE from '@salesforce/schema/Lead.State';
import LEAD_POSTAL_CODE from '@salesforce/schema/Lead.PostalCode';
import LEAD_COUNTRY from '@salesforce/schema/Lead.Country';
import LEAD_ACCOUNT from '@salesforce/schema/Lead.Affiliated_Account__c';
import LEAD_HIGH_SCHOOL_GRAD_YEAR from '@salesforce/schema/Lead.Expected_Graduate_Date__c';
import LEAD_TIMELINE from '@salesforce/schema/Lead.Timeline__c';
import LEAD_QUESTION from '@salesforce/schema/Lead.Has_Question__c';
import LEAD_DESCRIPTION from '@salesforce/schema/Lead.Description';
import LEAD_MAIL_INFO from '@salesforce/schema/Lead.Mail_Information_Requested__c';
import LEAD_COLLEGE_SCHOOL from '@salesforce/schema/Lead.St_Thomas_College_School__c';

//controller
import getRFIController from '@salesforce/apex/requestForInformationFormController.getRFIController';
import getPrograms from '@salesforce/apex/requestForInformationFormController.getPrograms';
import getTerms from '@salesforce/apex/requestForInformationFormController.getTerms';
import searchHighSchools from '@salesforce/apex/requestForInformationFormController.searchHighSchools';
import getAcademicLevelValue from '@salesforce/apex/requestForInformationFormController.getAcademicLevelValue';
import createLead from '@salesforce/apex/requestForInformationFormController.createLead';
import createAccount from '@salesforce/apex/requestForInformationFormController.createAccount';
import getPresetValues from '@salesforce/apex/requestForInformationFormController.getPresetValues';
import getSchoolCollegeAccount from '@salesforce/apex/requestForInformationFormController.getSchoolCollegeAccount';

const ADDITIONAL_FIELDS = [
    LEAD_FIRST_NAME,
    LEAD_TITLE,
    LEAD_ADMIT_TYPE,
    LEAD_CITIZENSHIP,
    LEAD_RECRUITMENT_PROGRAM,
    LEAD_EMAIL,
    LEAD_PHONE,
    LEAD_MOBILE_PHONE,
    LEAD_SMS_OPT_OUT,
    LEAD_BIRTHDATE,
    LEAD_PREFERRED_ENROLLMENT,
    LEAD_TERM,
    LEAD_STREET,
    LEAD_CITY,
    LEAD_STATE,
    LEAD_POSTAL_CODE,
    LEAD_COUNTRY,
    LEAD_ACCOUNT,
    LEAD_HIGH_SCHOOL_GRAD_YEAR,
    LEAD_TIMELINE,
    LEAD_QUESTION,
    LEAD_DESCRIPTION,
    LEAD_MAIL_INFO,
    LEAD_COLLEGE_SCHOOL
]

const lookup_fields = [
    'Affiliated_Account__r',
    'Recruitment_Program__r',
    'Term__r'
]

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
    fields_to_display; //use to determine which fields on form to display
    required_fields; //used for validating input
    @track hide_form_title = true;

    // lead info
    lead_default_record_type;
    all_lead_field_api_names = [];

    // maps to populate picklists, where label is name and value is id of object
    program_id_to_name_map; // for Recruitment_Program__c
    term_id_to_name_map; // for Term__c
    account_id_to_name_map; // for Affiliated_Account__c

    //front-end display
    @track show_spinner = true;
    @track manually_enter_high_school = false;
    @track high_school_data = false;
    @track form_submitted_successfully = false;

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
        'I_will_apply_to_St_Thomas_Law_as_a': false,
        'When_do_you_plan_to_start_school': false
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
        'I_will_apply_to_St_Thomas_Law_as_a': false,
        'When_do_you_plan_to_start_school': false
    }

    record_input; // stores user enter form information

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
        'apply_law_school_label': 'I will apply to St. Thomas Law as a',
        'plan_to_start_label': 'When do you plan to start school?'
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
    new_account; // used to create new account high school not found
    new_account_id;
    
    //high school datatable columns
    high_school_columns = [
        { label: 'Name', fieldName: 'name', type: 'text' },
        { label: 'Address', fieldName: 'address', type: 'text', 
            cellAttributes: { class: 'slds-text-color_weak' }
        }
    ];

    @wire(getRFIController, { rfi_controller_name: '$rfi_controller' })
    rfi(result) {
        if (result.data) {
            if (Boolean(result.data)) {
                this.academic_level_api = result.data.Academic_Level__c;
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
            this.country_picklist_values = result.data.picklistFieldValues.hed__Citizenship__c.values;
            this.admit_type_picklist_values = result.data.picklistFieldValues.Admit_Type__c.values;
            this.timeline_picklist_values = result.data.picklistFieldValues.Timeline__c.values;
        } else {
            console.log(result.error);
        }
    }

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
            case this.field_labels.zipcode_label:
                this.record_input.fields.PostalCode = event.target.value;
                break;
            case this.field_labels.country_label:
                this.record_input.fields.Country = event.target.value;
                break;
            case this.field_labels.text_messages_label:
                if (event.target.checked) {
                    this.record_input.fields.hed__SMS_Opt_Out__c = false;
                } else {
                    this.record_input.fields.hed__SMS_Opt_Out__c = true;
                }
                break;
            case this.field_labels.birthdate_label:
                this.record_input.fields.Birthdate__c = event.target.value;
                break;
            case this.field_labels.citizenship_label:
                this.record_input.fields.Citizenship_Type__c = event.target.value;
                break;
            case this.field_labels.admit_type_label:
                this.record_input.fields.Admit_Type__c = event.target.value;
                break;
            case this.field_labels.academic_interest_label:
                this.record_input.fields.Recruitment_Program__c = event.target.value;
                break;
            case this.field_labels.academic_term_label:
                this.record_input.fields.Term__c = event.target.value; 
                this.record_input.fields.hed__Preferred_Enrollment_Date__c = this.term_id_to_name_map[event.target.value].hed__Start_Date__c;
                break;
            case this.field_labels.high_school_not_found_label:
                this.manually_enter_high_school = event.target.checked;
                if (event.target.checked) {
                    this.record_input.fields.Affiliated_Account__c = '';
                    this.high_school_search_results = null;
                    this.high_school_data = false;
                } else {
                    this.new_account = null;
                }
                break;
            case this.field_labels.high_school_search_label:
                this.new_account = event.target.value;
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
            case this.field_labels.apply_law_school_label:
                this.record_input.fields.Recruitment_Program__c = event.target.value;
                break;
            case this.field_labels.plan_to_start_label:
                this.record_input.fields.Term__c = event.target.value;
                this.record_input.fields.hed__Preferred_Enrollment_Date__c = this.term_id_to_name_map[event.target.value].hed__Start_Date__c;
                break;
            default:
                break;
        }

        if (event.target.name == this.field_labels.high_school_datatable_name) {
            var selected_row = this.template.querySelector('lightning-datatable').getSelectedRows();
            this.record_input.fields.Affiliated_Account__c = selected_row[0].account_id;
            this.template.querySelector('lightning-input[data-id="high_school"]').value = selected_row[0].name;
        }
    }

    handleSubmit() {
        if (this.validateInput()) {
            this.record_input.fields.OwnerId = this.lead_owner;
            this.show_spinner = true;
            if (Boolean(this.record_input.fields.Description)) {
                this.record_input.fields.Description = 'Questions/Comments from RFI: ' + this.record_input.fields.Description;
            }
            this.handleStreetAddress();
            getSchoolCollegeAccount({school_college_name : this.school_college})
            .then(school_college_account_id => {
                this.record_input.fields.St_Thomas_College_School__c = school_college_account_id;
            }) 
            .catch(error => {
                console.log(error);
            })
            createAccount({ account_name : this.new_account, owner_id: this.lead_owner}) 
            .then(account_id => {
                if (Boolean(account_id)) {
                    this.record_input.fields.Affiliated_Account__c = account_id;
                }
                createLead({ record : JSON.stringify(this.record_input.fields), objectApiName : 'Lead'})
                .then(() => {
                    // redirect
                    this.show_spinner = false;
                    this.form_submitted_successfully = true;
                    console.log(this.record_input);
                    window.open(this.redirect_url, '_self');
                })
                .catch(error => {
                    console.log(error);
                    this.show_spinner = false;
                });
            })
            .catch(error => {
                console.log(error);
                this.show_spinner = false;
            });
        }
    }

    validateInput() {
        let valid_input_fields = this.validateInputFields();
        let valid_picklist_fields = this.validatePicklistFields();
        if (valid_input_fields && valid_picklist_fields) {
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

    handleStreetAddress() {
        if (Boolean(this.address1) && Boolean(this.address2) && Boolean(this.address3)) {
            this.record_input.fields.Street = this.address1 + ', ' + this.address2 + ', ' + this.address3;
        } else if (Boolean(this.address1) && Boolean(this.address2)) {
            this.record_input.fields.Street = this.address1 + ', ' + this.address2;
        } else if (Boolean(this.address1)) {
            this.record_input.fields.Street = this.address1;
        }
    }

    @wire(getRecordCreateDefaults, { objectApiName: LEAD_OBJECT, optionalFields: ADDITIONAL_FIELDS})
    output(result) {
        if (result.data) {
            this.record_input = generateRecordInputForCreate(result.data.record);
            this.record_input.fields.hed__SMS_Opt_Out__c = true; // since question asks if user wants to opt-in, should default to true (opt-out)
            this.record_input.fields.Company = 'Random Company ' + Math.floor(Math.random() * 100);
            getPresetValues({rfi_controller_name : this.rfi_controller})
            .then(preset_values => {
                for (const preset_value of preset_values) {
                    if (this.all_lead_field_api_names.includes(preset_value.Field_API_Name__c)) {
                        this.record_input.fields[preset_value.Field_API_Name__c] = preset_value.Value__c;
                    }
                }
                console.log(JSON.stringify(this.record_input));
            })
            .catch(error => {
                console.log(error);
            })
            // relationship lookup fields throwing error on insert, so removing
            for (const relationship_name of lookup_fields) {
                delete this.record_input.fields[relationship_name];         
            }
        } else {
            console.log(result.error);
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

    // can't query for global value sets -- would need to be a field
    get stateOptions() {
        return [
            { label: 'AL', value: 'AL' },
            { label: 'AK', value: 'AK' },
            { label: 'AS', value: 'AS' },
            { label: 'AZ', value: 'AZ' },
            { label: 'AR', value: 'AR' },
            { label: 'CA', value: 'CA' },
            { label: 'CO', value: 'CO' },
            { label: 'CT', value: 'CT' },
            { label: 'DE', value: 'DE' },
            { label: 'DC', value: 'DC' },
            { label: 'FM', value: 'FM' },
            { label: 'FL', value: 'FL' },
            { label: 'GA', value: 'GA' },
            { label: 'GU', value: 'GU' },
            { label: 'HI', value: 'HI' },
            { label: 'ID', value: 'ID' },
            { label: 'IL', value: 'IL' },
            { label: 'IN', value: 'IN' },
            { label: 'IA', value: 'IA' },
            { label: 'KS', value: 'KS' },
            { label: 'KY', value: 'KY' },
            { label: 'LA', value: 'LA' },
            { label: 'ME', value: 'ME' },
            { label: 'MH', value: 'MH' },
            { label: 'MD', value: 'MD' },
            { label: 'MA', value: 'MA' },
            { label: 'MI', value: 'MI' },
            { label: 'MN', value: 'MN' },
            { label: 'MS', value: 'MS' },
            { label: 'MO', value: 'MO' },
            { label: 'MT', value: 'MT' },
            { label: 'NE', value: 'NE' },
            { label: 'NV', value: 'NV' },
            { label: 'NH', value: 'NH' },
            { label: 'NJ', value: 'NJ' },
            { label: 'NM', value: 'NM' },
            { label: 'NY', value: 'NY' },
            { label: 'NC', value: 'NC' },
            { label: 'ND', value: 'ND' },
            { label: 'MP', value: 'MP' },
            { label: 'OH', value: 'OH' },
            { label: 'OK', value: 'OK' },
            { label: 'OR', value: 'OR' },
            { label: 'PW', value: 'PW' },
            { label: 'PA', value: 'PA' },
            { label: 'PR', value: 'PR' },
            { label: 'RI', value: 'RI' },
            { label: 'SC', value: 'SC' },
            { label: 'SD', value: 'SD' },
            { label: 'TN', value: 'TN' },
            { label: 'TX', value: 'TX' },
            { label: 'UT', value: 'UT' },
            { label: 'VT', value: 'VT' },
            { label: 'VI', value: 'VI' },
            { label: 'VA', value: 'VA' },
            { label: 'WA', value: 'WA' },
            { label: 'WV', value: 'WV' },
            { label: 'WI', value: 'WI' },
            { label: 'WY', value: 'WY' }
        ];
    }
}