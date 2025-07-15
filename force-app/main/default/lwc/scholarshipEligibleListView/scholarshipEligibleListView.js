/**
 * Created by nguy0092 on 7/14/2025.
 */

import {api, LightningElement, track, wire} from 'lwc';
import eligibleScholarships from "@salesforce/apex/scholarshipEligibleListViewController.eligibleScholarships";


export default class ScholarshipEligibleListView extends LightningElement {

    @api contactId;
    @api appId;
    @api currentPage;

    @track scholarshipLists = [];
    scholarshipListsLength = false;

    @wire(eligibleScholarships, {contactId: "$contactId", appId: "$appId", currentPage: "$currentPage"})
    scholarships(results) {
        if (results.data) {
            this.scholarshipLists = results.data;
        }
        this.scholarshipListsLength = this.scholarshipLists.length > 0;
        console.log("this.scholarshipListsLength:  "+this.scholarshipListsLength);
        console.log("this.scholarshipLists.length:  "+this.scholarshipLists.length);
    }

}