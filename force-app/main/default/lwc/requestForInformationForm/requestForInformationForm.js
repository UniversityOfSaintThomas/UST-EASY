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

    lead_default_record_type;
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

    address1;
    address2;

    //picklist values
    state_picklist_values;
    country_picklist_values;
    citizenship_picklist_values;
    admit_type_picklist_values;getPicklistValuesByRecordType

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
            console.log(JSON.stringify(result.data));
        } else {
            console.log(result.error);
        }
    }

    onChange(event) {
        switch (event.target.label) {
            case 'First Name':
                this.record_input.FirstName = event.target.value;
                break;
            case 'Last Name':
                this.record_input.LastName = event.target.value;
                break;
            case 'Email':
                this.record_input.Email = event.target.value;
                break;
            case 'Home Phone':
                this.record_input.Phone = event.target.value;
                break;
            case 'Mobile Phone':
                this.record_input.MobilePhone = event.target.value;
                break;
            case 'Address 1':
                this.address1 = event.target.value;
                break;
            case 'Address 2':
                this.address2 = event.target.value; // combine two address fields into Street before submit
                break;
            case 'City':
                this.record_input.City = event.target.value;
                break;
            case 'State':
                this.record_input.State = event.target.value;
                break;
            case 'Zip Code':
                this.record_input.PostalCode = event.target.value;
                break;
            case 'Country':
                this.record_input.Country = event.target.value;
                break;
            case 'I would like to receive text messages':
                this.record_input.hed__SMS_Opt_Out__c = event.target.checked;
            case 'Birthdate':
                this.record_input.Birthdate__c = event.target.value;
            case 'Citizenship':
                this.record_input.hed__Citizenship__c = event.target.value;
            case 'I will to St. Thomas as a':
                this.record_input.Admit_Type__c = event.target.value;
            case 'Academic Interest':
                this.record_input.Recruitment_Program__c = event.target.value;
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