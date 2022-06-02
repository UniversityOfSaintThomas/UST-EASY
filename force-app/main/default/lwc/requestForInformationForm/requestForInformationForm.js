/**
 * author: nicole.b@digitalmass.com
 * created-date: 2022-06-01
 * last-modified: 2022-06-01
 */

//built-ins
import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

//field imports

import LEAD_FIRST_NAME from '@salesforce/schema/Lead.FirstName';
import LEAD_LAST_NAME from '@salesforce/schema/Lead.LastName';
import LEAD_EMAIL from '@salesforce/schema/Lead.Email';
import LEAD_HOME_PHONE from '@salesforce/schema/Lead.Phone';
import LEAD_MOBILE_PHONE from '@salesforce/schema/Lead.MobilePhone';
import LEAD_ADDRESS from '@salesforce/schema/Lead.Address';

export default class RequestForInformationForm extends LightningElement {
    @track program_type;

    @track show_spinner = false;

    //fields
    first_name = LEAD_FIRST_NAME;
    last_name = LEAD_LAST_NAME;
    email = LEAD_EMAIL;
    home_phone = LEAD_HOME_PHONE;
    mobile_phone = LEAD_MOBILE_PHONE;
    address = LEAD_ADDRESS;

    phone_pattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}';
    email_pattern = '/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/';

    invalid_phone_message = 'Phone # must match format: 000-000-0000';
    invalid_email_message = 'Email must match format: example@site.com';

    @wire(CurrentPageReference)
    pageRef(result) {
        this.program_type = 'Undergraduate';
        if (result) {
            // TO DO
            this.program_type = 'Undergraduate'
        }
    }

    get state_options() {
        return [
            { label: 'MN', value: 'MN' },
            { label: 'NY', value: 'NY' },
            { label: 'WA', value: 'WA' },
        ];
    }

}