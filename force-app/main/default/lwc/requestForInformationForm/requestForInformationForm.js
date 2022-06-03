/**
 * author: nicole.b@digitalmass.com
 * created-date: 2022-06-01
 * last-modified: 2022-06-01
 */

//built-ins
import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import LEAD_OBJECT from '@salesforce/schema/Lead';

//fields
import LEAD_FIRST_NAME from '@salesforce/schema/Lead.FirstName';
import LEAD_LAST_NAME from '@salesforce/schema/Lead.LastName';
import LEAD_EMAIL from '@salesforce/schema/Lead.Email';
import LEAD_HOME_PHONE from '@salesforce/schema/Lead.Phone';
import LEAD_MOBILE_PHONE from '@salesforce/schema/Lead.MobilePhone';
import LEAD_ADDRESS from '@salesforce/schema/Lead.Address';

//controller
import getRFIController from '@salesforce/apex/requestForInformationFormController.getRFIController';
import getAcademicPrograms from '@salesforce/apex/requestForInformationFormController.getAcademicPrograms';

export default class RequestForInformationForm extends LightningElement {
    @api rfi_controller;
    @track program_type;
    @track show_spinner = false;

    record_input = {
        'apiName': 'Account',
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
          'Birthdate__c': ''
        }
    }

    address1;
    address2;

    state_picklist_values;
    country_picklist_values;

    //regex
    phone_pattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}';
    email_pattern = '/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/';
    invalid_phone_message = 'Phone # must match format: 000-000-0000';
    invalid_email_message = 'Email must match format: example@site.com';

    @wire(getRFIController, {rfi_controller_name: this.rfi_controller})
    rfi_controller(controller) {
        console.log(JSON.stringify(controller));
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

    get countryOptions() {
        return [
            { label: 'United States', value: 'United States' },
            { label: 'Albania', value: 'Albania' },
            { label: 'Colombia', value: 'Colombia' },
            { label: 'Cambodia', value: 'Cambodia' },
            { label: 'Yemen', value: 'Yemen' },
            { label: 'Burkina Faso', value: 'Burkina Faso' },
        ];
    }

}