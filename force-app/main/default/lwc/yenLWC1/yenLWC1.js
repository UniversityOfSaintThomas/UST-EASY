/**
 * Created by nguy0092 on 4/15/2024.
 */

import {LightningElement, api, wire} from 'lwc';
import eventRegistrationList from "@salesforce/apex/YnSummitEventsList.eventsRegistrations";
// import eventRegistrationListTest from "@salesforce/apex/YnSummitEventsListTEST1.eventsRegistrations";

// const EVENTREGISTRATIONCOLUMNS = [
//     // {label: 'Id', fieldName: 'Id'},
//     {label: 'Event Name', fieldName: 'EventName'},
//     {label: 'Event Date Time', fieldName: 'EventDateTime'}
// ];

export default class YenLwc1 extends LightningElement {

    // registrationList;

    // @wire(eventRegistrationListTest, {})
    // registrations
    // registrations({ error, data }) {
    //     if (data) {
    //         //note you'll need to change your template to handle this - remove the `data` object when you access activities
    //         this.registrationList = data;
    //     } else if (error) {
    //         console.log("this is error: "+error);
    //     }
    // }

    // registrationListError;
    // eventRegistrationColumns = EVENTREGISTRATIONCOLUMNS;

    @api contactId = '00303000013FeEdAAK';

    @wire(eventRegistrationList, {contactId: '$contactId'})
    registrationList

    // registrations(result) {
    //
    //     if (result.data) {
    //
    //         this.registrationList = result.data;
    //
    //
    //     } else if (result.error) {
    //
    //         this.registrationListError = result.error;
    //         this.registrationList = undefined;
    //
    //     }
    //
    // }

}