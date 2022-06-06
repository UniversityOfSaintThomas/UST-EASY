/**
 * author: nicole.b@digitalmass.com
 * created-date: 2022-06-01
 * last-modified: 2022-06-01
 */

//built-ins
import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

import LEAD_OBJECT from '@salesforce/schema/Lead';

//controller
import getRFIController from '@salesforce/apex/requestForInformationFormController.getRFIController';
import getAcademicPrograms from '@salesforce/apex/requestForInformationFormController.getAcademicPrograms';

export default class RequestForInformationForm extends LightningElement {
    // RFI controller info
    @api rfi_controller;
    academic_level = 'Undergraduate';
    applicant_type = 'Undergraduate';
    fields_to_display;

    // lead info
    lead_default_record_type;

    //front-end display
    @track show_spinner = false;

    record_input = {
        'apiName': 'Lead',
        'fields': {
          'FirstName': '',
          'LastName': '',
          'Email': '',
          'Phone': '',
          'MobilePhone': '',
          'hed__SMS_Opt_Out__c': '',
          'Street': '',
          'City': '',
          'State': '',
          'PostalCode': '',
          'Country': '',
          'Recruitment_Program__c': '',
          'Affiliated_Account__c': '',
          'Term__c': '',
          'Birthdate__c': '',
          'hed__Citizenship__c': '',
          'Admit_Type__c': '',
          'Recruitment_Program__c': ''
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


    address1;
    address2;

    //picklist values
    state_picklist_values;
    country_picklist_values;
    citizenship_picklist_values;
    admit_type_picklist_values;
    academic_interest_picklist_values;

    //regex
    phone_pattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}';
    invalid_phone_message = 'Phone # must match format: 000-000-0000';

    @wire(getRFIController, { rfi_controller_name: '$rfi_controller' })
    rfi(result) {
        if (result.data) {
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
            default:
                break;
        }
        console.log(JSON.stringify(event.target.value));
    }

    get stateOptions() {
        return [
            { label: 'MN', value: 'MN' },
            { label: 'NY', value: 'NY' },
            { label: 'WA', value: 'WA' },
        ];
    }

}