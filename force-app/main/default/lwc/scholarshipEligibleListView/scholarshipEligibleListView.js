/**
 * Created by nguy0092 on 7/14/2025.
 */

import {api, LightningElement, track, wire} from 'lwc';
import eligibleScholarships from "@salesforce/apex/scholarshipEligibleListViewController.eligibleScholarships";

export default class ScholarshipEligibleListView extends LightningElement {

    @api contactId;
    @api appId;
    @api currentPage;
    @api widgetSize = "";

    @track scholarshipLists = [];

    showScholarshipList = true;

    get heightSize() {
        return this.widgetSize === "" ? "widget-height" : "";
    }
    get listViewStyle() {
        return this.widgetSize === "" ? "slds-p-bottom_x-small" : "slds-p-bottom_x-small list-no-style";
    }
    get noEligibleText() {
        if (this.currentPage === "applicationportal") {
            return "You do not have any eligible scholarships.";
        } else {
            return "You do not have eligible scholarships for selected application.";
        }
    }

    connectedCallback() {
        eligibleScholarships({contactId: this.contactId, appId: this.appId, currentPage: this.currentPage}).then((results) => {
            if (results && results.length > 0) {
                this.scholarshipLists = JSON.parse(JSON.stringify(results));
                console.log("scholarshipLists: "+JSON.stringify(this.scholarshipLists));
                this.showScholarshipList = true;
            } else {
                this.showScholarshipList = false;
            }
        });
    }
}