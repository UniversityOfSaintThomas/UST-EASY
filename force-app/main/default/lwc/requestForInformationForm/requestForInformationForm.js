/**
 * author: nicole.b@digitalmass.com
 * created-date: 2022-06-01
 * last-modified: 2022-06-06
 */

//built-ins
import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent, createRecord, generateRecordInputForCreate, getRecordCreateDefaults } from 'lightning/uiRecordApi';

// lead object and fields
import LEAD_OBJECT from '@salesforce/schema/Lead';
import LEAD_FIRST_NAME from '@salesforce/schema/Lead.FirstName';
import LEAD_ADMIT_TYPE from '@salesforce/schema/Lead.Admit_Type__c';
import LEAD_CITIZENSHIP from '@salesforce/schema/Lead.hed__Citizenship__c';
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

//controller
import getRFIController from '@salesforce/apex/requestForInformationFormController.getRFIController';
import getAcademicPrograms from '@salesforce/apex/requestForInformationFormController.getAcademicPrograms';
import getAcademicTerms from '@salesforce/apex/requestForInformationFormController.getAcademicTerms';
import searchHighSchools from '@salesforce/apex/requestForInformationFormController.searchHighSchools';
import getAcademicLevelValue from '@salesforce/apex/requestForInformationFormController.getAcademicLevelValue';

const OPTIONAL_FIELDS = [
    LEAD_FIRST_NAME,
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
    LEAD_ACCOUNT
]

const lookup_fields = [
    'Affiliated_Account__r',
    'Recruitment_Program__r',
    'Term__r'
]

export default class RequestForInformationForm extends LightningElement {
    // RFI controller info
    @api rfi_controller = 'RFI Controller 0001';
    academic_level;
    academic_level_api;
    applicant_status;
    fields_to_display; //use to determine which fields on form to display

    // lead info
    lead_default_record_type;

    // maps to populate picklists, where label is name and value is id of object
    program_id_to_name_map; // for Recruitment_Program__c
    term_id_to_name_map; // for Term__c
    account_id_to_name_map; // for Affiliated_Account__c

    //front-end display
    @track show_spinner = true;
    @track manually_enter_high_school = false;
    @track high_school_data = false;

    //RFI controller determined booleans
    @track show_name_fields = false;
    @track show_phone_fields = false;
    @track show_address_fields = false;
    @track show_admit_type = false;
    @track show_citizenship = false;
    @track show_academic_interest = false;
    @track show_email = false;
    @track show_birthdate = false;
    @track show_academic_term = false;
    @track show_high_school = false;

    record_input; // used in createRecord - stores user enter form information

    //field labels
    admit_type_label = 'I will apply to St. Thomas as a';
    citizenship_label = 'Citizenship';
    academic_interest_label = 'Academic Interest';
    first_name_label = 'First Name';
    last_name_label = 'Last Name';
    email_label = 'Email';
    home_phone_label = 'Home Phone';
    mobile_phone_label = 'Mobile Phone';
    text_messages_label = 'I would like to receive text messages';
    birthdate_label = 'Birthdate';
    address1_label = 'Address 1';
    address2_label = 'Address 2';
    city_label = 'City';
    state_label = 'State';
    zipcode_label = 'Zip Code';
    country_label = 'Country';
    academic_term_label = 'Expected Start Term at St. Thomas';
    high_school_search_label = 'High School Attended';
    high_school_not_found_label = 'I can\'t find my High School';
    high_school_datatable_name = 'High School Datatable';

    //picklist values
    @track state_picklist_values;
    @track country_picklist_values;
    @track citizenship_picklist_values;
    @track admit_type_picklist_values;
    @track academic_level_picklist_values;
    @track academic_term_picklist_values;
    @track high_school_search_results; // populate via SOSL


    //intermediate values
    address1; //concat w/ address 2 before submit (address combined field only has one 'Street' label)
    address2;
    new_account; // used to create new account high school not found

    //regex
    phone_pattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}';
    invalid_phone_message = 'Phone # must match format: 000-000-0000';

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
            if (result.data.length != 0) {
                this.academic_level_api = result.data.Academic_Level__c;
                this.applicant_status = result.data.Applicant_Status__c;
                this.fields_to_display = result.data.Fields_to_Display__c;
                // sets boolean values for front-end display i.e. which fields on are form
                this.handleFieldsToDisplay();
                //gets value/label of picklist by api name to use in form title
                getAcademicLevelValue({api_name : result.data.Academic_Level__c})
                .then((level) => {
                    this.academic_level = level;
                })
                .catch(error => {
                    console.log(error);
                });
                if (this.academic_level_api != undefined) {
                    // gets programs based on academic level
                    getAcademicPrograms({academic_level: this.academic_level_api})
                    .then((programs) => {
                        this.program_id_to_name_map = programs;
                        var values = [];
                        for (const program in programs) {
                            values.push(
                                {label: programs[program].Name, value: programs[program].Id}
                            );
                        }
                        this.academic_interest_picklist_values = values;
                    })
                    .catch(error => {
                        console.log(error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error retreiving Academic Programs',
                                message: error.body.message,
                                variant: 'error'
                            })
                        )
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
            switch (field) {
                case 'Name fields':
                    this.show_name_fields = true;
                    break;
                case 'Phone fields':
                    this.show_phone_fields = true;
                    break;
                case 'Address fields':
                    this.show_address_fields = true;
                    break;
                case 'Academic Interest':
                    this.show_academic_interest = true;
                    break;
                case 'Academic Term':
                    this.show_academic_term = true;
                    break;
                case 'High School Attended':
                    this.show_high_school = true;
                    break;
                case 'Birthdate':
                    this.show_birthdate = true;
                    break;
                case 'Email':
                    this.show_email = true;
                    break;
                case 'Admit Type':
                    this.show_admit_type = true;
                    break;
                case 'Citizenship':
                    this.show_citizenship = true;
                    break;
            }
        }
    }

    @wire(getAcademicTerms)
    academic_terms(result) {
        if (result.data) {
            if (result.data.length != 0) {
                this.term_id_to_name_map = result.data;
                var values = [];
                for (const term in result.data) {
                    values.push(
                        {label: result.data[term].Name, value: result.data[term].Id}
                    );
                }
                this.academic_term_picklist_values = values;
            }
        } else {
            console.log(result.error);
        }
    }

    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    object_info(result) {
        if (result.data) {
            this.lead_default_record_type = result.data.defaultRecordTypeId;
        } else {
            console.log(result.error);
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: LEAD_OBJECT, recordTypeId: '$lead_default_record_type' })
    picklist_values(result) {
        if (result.data) {
            this.citizenship_picklist_values = result.data.picklistFieldValues.hed__Citizenship__c.values;
            this.country_picklist_values = result.data.picklistFieldValues.hed__Citizenship__c.values;
            this.admit_type_picklist_values = result.data.picklistFieldValues.Admit_Type__c.values;
        } else {
            console.log(result.error);
        }
    }

    onChange(event) {
        switch (event.target.label) {
            case this.first_name_label:
                this.record_input.fields.FirstName = event.target.value;
                break;
            case this.last_name_label:
                this.record_input.fields.LastName = event.target.value;
                break;
            case this.email_label:
                this.record_input.fields.Email = event.target.value;
                break;
            case this.home_phone_label:
                this.record_input.fields.Phone = event.target.value;
                break;
            case this.mobile_phone_label:
                this.record_input.fields.MobilePhone = event.target.value;
                break;
            case this.address1_label:
                this.address1 = event.target.value;
                break;
            case this.address2_label:
                this.address2 = event.target.value;
                if (this.address1 != null) {
                    this.record_input.fields.Street = this.address1 + ' ' + this.address2;
                }
                break;
            case this.city_label:
                this.record_input.fields.City = event.target.value;
                break;
            case this.state_label:
                this.record_input.fields.State = event.target.value;
                break;
            case this.zipcode_label:
                this.record_input.fields.PostalCode = event.target.value;
                break;
            case this.country_label:
                this.record_input.fields.Country = event.target.value;
                break;
            case this.text_messages_label:
                if (event.target.checked) {
                    this.record_input.fields.hed__SMS_Opt_Out__c = false;
                } else {
                    this.record_input.fields.hed__SMS_Opt_Out__c = true;
                }
                break;
            case this.birthdate_label:
                this.record_input.fields.Birthdate__c = event.target.value;
                break;
            case this.citizenship_label:
                this.record_input.fields.hed__Citizenship__c = event.target.value;
                break;
            case this.admit_type_label:
                this.record_input.fields.Admit_Type__c = event.target.value;
                break;
            case this.academic_interest_label:
                this.record_input.fields.Recruitment_Program__c = event.target.value;
                break;
            case this.academic_term_label:
                this.record_input.fields.Term__c = event.target.value; 
                this.record_input.fields.hed__Preferred_Enrollment_Date__c = this.term_id_to_name_map[event.target.value].hed__Start_Date__c;
                break;
            case this.high_school_not_found_label:
                this.manually_enter_high_school = event.target.checked;
                if (event.target.checked) {
                    this.record_input.fields.Affiliated_Account__c = '';
                    this.high_school_search_results = null;
                    this.high_school_data = false;
                } else {
                    this.new_account = null;
                }
                break;
            case this.high_school_search_label:
                this.new_account = event.target.value;
            default:
                break;
        }

        if (event.target.name == this.high_school_datatable_name) {
            var selected_row = this.template.querySelector('lightning-datatable').getSelectedRows();
            this.record_input.fields.Affiliated_Account__c = selected_row[0].account_id;
            this.template.querySelector('lightning-input[data-id="high_school"]').value = selected_row[0].name;
        }
        console.log(this.record_input);
    }

    handleSubmit() {
        createRecord(this.record_input)
        .then(() => {
            console.log('Success!');
        })
        .catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating lead.',
                    message: error.body.message,
                    variant: 'error'
                })
            )
        });
    }

    @wire(getRecordCreateDefaults, { objectApiName: LEAD_OBJECT, optionalFields: OPTIONAL_FIELDS})
    output(result) {
        if (result.data) {
            console.log(result.data);
            this.record_input = generateRecordInputForCreate(result.data.record);
            this.record_input.fields.hed__SMS_Opt_Out__c = true; // since question asks if user wants to opt-in, should default to true (opt-out)
            this.record_input.fields.Company = 'Random Company ' + Math.floor(Math.random() * 100); // TO DO: determine what this should be
            this.record_input.fields.LeadSource = 'Web';
            // relationship lookup fields throwing error on insert, so removing
            for (const relationship_name of lookup_fields) {
                delete this.record_input.fields[relationship_name];
            }
            // delete this.record_input.fields.Affiliated_Account__r;
            // delete this.record_input.fields.Recruitment_Program__r;
            // delete this.record_input.fields.Term__r;
            console.log(this.record_input);
        } else {
            console.log(result.error);
        }
    }

    handleSearch(event) {
        if (JSON.stringify(event.target.value).length > 4) {
            searchHighSchools({ search_term : event.target.value })
            .then((high_schools) => {
                if (Object.keys(high_schools).length != 0) {
                    this.high_school_data = true;
                    this.account_id_to_name_map = high_schools;
                    var values = [];
                    for (const school in high_schools) {
                        values.push(
                            {   
                                name: high_schools[school].Name, 
                                account_id: high_schools[school].Id, 
                                address: high_schools[school].ShippingCity + ', ' + high_schools[school].ShippingState
                            }
                        );
                    }
                    this.high_school_search_results = values;
                }
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error retreiving High Schools',
                        message: error.body.message,
                        variant: 'error'
                    })
                )
            });
        } else {
            this.high_school_search_results = null;
            this.high_school_data = false;
        }
    } 

    get setDataTableHeight() {
        if (this.high_school_search_results.length > 6) {
            return "height: 210px"
        }
    }

    get stateOptions() {
        return [
            { label: 'MN', value: 'MN' },
            { label: 'NY', value: 'NY' },
            { label: 'WA', value: 'WA' },
        ];
    }

}