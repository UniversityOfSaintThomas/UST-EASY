/**
 * Created by nguy0092 on 7/14/2025.
 */

import {api, LightningElement, track, wire} from 'lwc';
import eligibleScholarships from "@salesforce/apex/scholarshipEligibleListViewController.eligibleScholarships";


export default class ScholarshipEligibleListView extends LightningElement {

    @api contactId = "003Ru00000VkdOuIAJ";
    @api appId = "a0qRu000006zuuhIAA";
    @api currentPage = "applicationhome";

    @track scholarshipLists = [];
    scholarshipListsLength = false;

    @wire(eligibleScholarships, {contactId: "$contactId", appId: "$appId", currentPage: "$currentPage"})
    scholarships(results) {
        if (results.data) {
            this.scholarshipLists = results.data;
        }
        this.scholarshipListsLength = !!this.scholarshipLists;
    }

}