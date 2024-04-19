/**
 * Created by nguy0092 on 4/15/2024.
 */

import {LightningElement, api, wire} from 'lwc';
import eventRegistrationList from "@salesforce/apex/YnSummitEventsList.eventsRegistrations";

const EVENTREGISTRATIONCOLUMNS = [
    // {label: 'Id', fieldName: 'Id'},
    {label: 'Event Name', fieldName: 'EventName'},
    {label: 'Event Date Time', fieldName: 'EventDateTime'}
];

export default class YenLwc1 extends LightningElement {

    // registrationList;
    registrationListError;
    eventRegistrationColumns = EVENTREGISTRATIONCOLUMNS;

    @api contactId = '00303000013EvRqAAK';

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