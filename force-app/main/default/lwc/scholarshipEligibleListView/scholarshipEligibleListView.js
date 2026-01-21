/**
 * Created by nguy0092 on 7/14/2025.
 */

import {api, LightningElement, track, wire} from 'lwc';
import eligibleScholarships from "@salesforce/apex/scholarshipEligibleListViewController.eligibleScholarships";

export default class ScholarshipEligibleListView extends LightningElement {

    @api contactId;
    @api appId;
    @api currentPage;
    @api widgetDisplay = false;

    @track scholarshipLists = [];
    showScholarshipList = true;

    get widgetStyle() {
        return this.widgetDisplay ? "scholarship-item" : "slds-p-bottom_medium";
    }

    get noEligibleText() {
        if (this.currentPage === "applicationportal") {
            return "You do not have any eligible scholarships.";
        } else {
            return "You do not have eligible scholarships for the selected application.";
        }
    }

    connectedCallback() {
        eligibleScholarships({contactId: this.contactId, appId: this.appId, currentPage: this.currentPage}).then((results) => {
            if (results && results.length > 0) {
                this.scholarshipLists = results.map(scholarship => ({
                    ...scholarship,
                    showDetails: false,
                    buttonLabel: '+ Show description'
                }));
                this.showScholarshipList = true;
            } else {
                this.showScholarshipList = false;
            }
        });
    }

    handleToggleDetails(event) {
        event.preventDefault();
        event.stopPropagation();
        const scholarshipId = event.target.dataset.id;
        this.scholarshipLists = this.scholarshipLists.map(scholarship => {
            if (scholarship.Id === scholarshipId) {
                return {
                    ...scholarship,
                    showDetails: !scholarship.showDetails,
                    buttonLabel: scholarship.showDetails ? '+ Show description' : '- Hide description'
                };
            }
            return scholarship;
        });
    }
}