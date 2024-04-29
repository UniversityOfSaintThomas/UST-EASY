/**
 * Created by nguy0092 on 4/15/2024.
 */

import {LightningElement, api, wire} from 'lwc';
import eventRegistrationListTest from "@salesforce/apex/YnSummitEventsList.eventsRegistrations";


export default class YenLwc1 extends LightningElement {

    @api contactIdIn = "003DC00000Wp9DCYAZ";

    registrationList;
    registrationObject = {};
    newList = [];


    @wire(eventRegistrationListTest, {contactId: "$contactIdIn"})
    eventlist(results) {

        if (results.data) {


            this.registrationList = results.data;
            // Data comes back as an array of Objects. So it is possible to iterate in HTML.
            // Needs to be Javascript Array to iterate.

            for (let i = 0; i < this.registrationList.length; i++) {

                this.registrationObject.Id = this.registrationList[i].Id;
                this.registrationObject.newDate = this.registrationList[i].EventDate;
                this.registrationObject.weirdString = this.registrationList[i].randomString;

                this.newList[i]= this.registrationObject;

                // I created a Javascript Object registrationObject then added to Javascript Array newList to iterate in HTML for display.
                // Needs to be Javascript Array to iterate.
            }
        }
    }
}