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
    showScholarshipList = false;
    isLoading = true;
    hasError = false;

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

    get errorText() {
        return "We're unable to load scholarships right now. Please try again later.";
    }

    get totalScholarshipsText() {
        const count = this.scholarshipLists.length;
        return `${count} scholarship${count === 1 ? '' : 's'}`;
    }

    get toggleAllButtonLabel() {
        const allExpanded = this.scholarshipLists.length > 0 && this.scholarshipLists.every(scholarship => scholarship.showDetails);
        return allExpanded ? 'Hide all descriptions' : 'Show all descriptions';
    }

    connectedCallback() {
        eligibleScholarships({contactId: this.contactId, appId: this.appId, currentPage: this.currentPage}).then((results) => {
            if (results && results.length > 0) {
                this.scholarshipLists = results.map((scholarship, index) => ({
                    ...scholarship,
                    rowNumber: index + 1,
                    showDetails: false,
                    buttonLabel: 'Show description',
                    chevronClass: 'chevron'
                }));
                this.showScholarshipList = true;
            } else {
                this.showScholarshipList = false;
            }
        }).catch((error) => {
            this.hasError = true;
            this.showScholarshipList = false;
            // eslint-disable-next-line no-console
            console.error('Error loading eligible scholarships', error);
        }).finally(() => {
            this.isLoading = false;
        });
    }

    handleToggleDetails(event) {
        event.preventDefault();
        event.stopPropagation();
        const scholarshipId = event.target.closest('button').dataset.id;
        this.scholarshipLists = this.scholarshipLists.map(scholarship => {
            if (scholarship.Id === scholarshipId) {
                const expanded = !scholarship.showDetails;
                return {
                    ...scholarship,
                    showDetails: expanded,
                    buttonLabel: expanded ? 'Hide description' : 'Show description',
                    chevronClass: expanded ? 'chevron chevron_down' : 'chevron'
                };
            }
            return scholarship;
        });
    }

    handleToggleAllDetails(event) {
        event.preventDefault();
        event.stopPropagation();
        const allExpanded = this.scholarshipLists.length > 0
            && this.scholarshipLists.every(scholarship => scholarship.showDetails);
        const expand = !allExpanded;
        this.scholarshipLists = this.scholarshipLists.map(scholarship => ({
            ...scholarship,
            showDetails: expand,
            buttonLabel: expand ? 'Hide description' : 'Show description',
            chevronClass: expand ? 'chevron chevron_down' : 'chevron'
        }));
    }
}