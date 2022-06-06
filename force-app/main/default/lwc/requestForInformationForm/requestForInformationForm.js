/**
 * author: nicole.b@digitalmass.com
 * created-date: 2022-06-01
 * last-modified: 2022-06-06
 */

//built-ins
import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

import LEAD_OBJECT from '@salesforce/schema/Lead';

//controller
import getRFIController from '@salesforce/apex/requestForInformationFormController.getRFIController';
import getAcademicPrograms from '@salesforce/apex/requestForInformationFormController.getAcademicPrograms';
import getAcademicTerms from '@salesforce/apex/requestForInformationFormController.getAcademicTerms';

export default class RequestForInformationForm extends LightningElement {
    // RFI controller info
    @api rfi_controller;
    academic_level = 'Undergraduate';
    applicant_type = 'Undergraduate';
    fields_to_display; //use to determine which fields on form to display

    // lead info
    lead_default_record_type;

    // maps to use on submit (need to populate lookup field with id)
    program_id_to_name_map; // for Recruitment_Program__c
    account_id_to_name_map; // for Affiliated_Account__c

    //front-end display
    @track show_spinner = false;
    @track show_name_fields = true;
    @track show_phone_fields = true;
    @track show_address_fields = true;
    @track show_admit_type = true;
    @track show_citizenship = true;
    @track show_academic_interest = true;
    @track show_email = true;
    @track show_birthdate = true;
    @track show_academic_term = true;
    @track show_high_school = true;
    @track manually_enter_high_school = false;

    record_input = {
        'apiName': 'Lead',
        'fields': {
            'Admit_Type__c': '',
            'hed__Citizenship__c': '',
            'Recruitment_Program__c': '', //lookup
            'FirstName': '',
            'LastName': '',
            'Email': '',
            'Phone': '',
            'MobilePhone': '',
            'hed__SMS_Opt_Out__c': '',
            'Birthdate__c': '',
            'hed__Preferred_Enrollment_Date__c': '',
            'Street': '',
            'City': '',
            'State': '',
            'PostalCode': '',
            'Country': '',
            'Affiliated_Account__c': '' //lookup
        }
    }

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
    high_school_search_results_label = 'High School Attended Search Results';
    high_school_not_found_label = 'I can\'t find my High School';

    //picklist values
    @track state_picklist_values;
    @track country_picklist_values;
    @track citizenship_picklist_values;
    @track admit_type_picklist_values;
    @track academic_interest_picklist_values;
    @track academic_term_picklist_values;
    @track high_school_picklist_values; // populate via SOSL


    //intermediate values
    high_school_search_term;
    address1; //concat w/ address 2 before submit (address combined field only has one 'Street' label)
    address2;

    //regex
    phone_pattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}';
    invalid_phone_message = 'Phone # must match format: 000-000-0000';

    @wire(getRFIController, { rfi_controller_name: '$rfi_controller' })
    rfi(result) {
        if (result.data) {
            console.log('controller');
            console.log(JSON.stringify(result.data));
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

    @wire(getAcademicPrograms, { academic_level: '$academic_level'})
    academic_programs(result) {
        if (result.data) {
            console.log('academic programs');
            console.log(JSON.stringify(result.data));
            this.program_id_to_name_map = result.data;
            if (result.data.length != 0) {
                console.log('success!')
            }
        } else {
            console.log(result.error);
        }
    }

    @wire(getAcademicTerms)
    academic_terms(result) {
        if (result.data) {
            console.log('academic terms');
            console.log(JSON.stringify(result.data));
            if (result.data.length != 0) {
                this.academic_terms_picklist_values = result.data;
            }
        } else {
            console.log(result.error);
        }
    }

    onChange(event) {
        switch (String.valueOf(event.target.label)) {
            case this.first_name_label:
                this.record_input.FirstName = event.target.value;
                break;
            case this.last_name_label:
                this.record_input.LastName = event.target.value;
                break;
            case this.email_label:
                this.record_input.Email = event.target.value;
                break;
            case this.home_phone_label:
                this.record_input.Phone = event.target.value;
                break;
            case this.mobile_phone_label:
                this.record_input.MobilePhone = event.target.value;
                break;
            case this.address1_label:
                this.address1 = event.target.value;
                break;
            case this.address2_label:
                this.address2 = event.target.value; // combine two address fields into Street before submit
                break;
            case this.city_label:
                this.record_input.City = event.target.value;
                break;
            case this.state_label:
                this.record_input.State = event.target.value;
                break;
            case this.zipcode_label:
                this.record_input.PostalCode = event.target.value;
                break;
            case this.country_label:
                this.record_input.Country = event.target.value;
                break;
            case this.text_messages_label:
                this.record_input.hed__SMS_Opt_Out__c = event.target.checked;
                break;
            case this.birthdate_label:
                this.record_input.Birthdate__c = event.target.value;
                break;
            case this.citizenship_label:
                this.record_input.hed__Citizenship__c = event.target.value;
                break;
            case this.admit_type_label:
                this.record_input.Admit_Type__c = event.target.value;
                break;
            case this.academic_interest_label:
                this.record_input.Recruitment_Program__c = event.target.value;
                break;
            case this.academic_term_label:
                this.record_input.hed__Preferred_Enrollment_Date__c = event.target.value;
                break;
            case this.high_school_search_results_label:
                this.record_input.Affiliated_Account__c = event.target.value;
                break;
            case this.high_school_not_found_label:
                this.manually_enter_high_school = event.target.checked;
                break;
            case this.high_school_search_label:
                this.record_input.Affiliated_Account__c = event.target.value;
                break;
            default:
                break;
        }
        console.log(JSON.stringify(event.target.value));
    }

    handleSearch(event) {
        this.high_school_search_term = event.target.label;
        console.log(this.high_school_search_term);
        //search via SOSL
        //set high school picklist values
    }

    get stateOptions() {
        return [
            { label: 'MN', value: 'MN' },
            { label: 'NY', value: 'NY' },
            { label: 'WA', value: 'WA' },
        ];
    }

}