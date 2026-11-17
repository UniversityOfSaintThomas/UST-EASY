/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */

import {api, LightningElement, track, wire} from 'lwc';
import {MessageContext, publish, subscribe} from 'lightning/messageService';
import APP_SELECTED_CHANNEL from '@salesforce/messageChannel/EASY_App_Selected__c';
import {CurrentPageReference} from "lightning/navigation";
import {adjustURLParams, setAppIdFromURL} from 'c/easyAppReviewUtility';
import getApplicationControl from '@salesforce/apex/EASYAppReviewController.getApplicationControl';

export default class AppReviewApplicationView extends LightningElement {

    @track appId;
    @track requirementId;
    @track isLoading = false;
    @track applicationControl;

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        this.lmsSubscription();
    }

    lmsSubscription() {
        subscribe(this.messageContext, APP_SELECTED_CHANNEL, (message) => {
            this.isLoading = true;
            this.applicationControl = null;
            this.appId = message.appId;
            this.requirementId = null;
            adjustURLParams('c__appId', this.appId);
        });
        setAppIdFromURL(this.messageContext, APP_SELECTED_CHANNEL, this.currentPageReference, this.appId);
    }

    @wire(getApplicationControl, {appId: "$appId"})
    wiredApplicationControl(result) {
        this.applicationControl = result;
        if (result.data || result.error) {
            this.isLoading = false;
        }
    }

    get requirements() {
        let result = null;
        if (this.applicationControl && this.applicationControl.data) {
            result = this.applicationControl.data.requirements.find(item => item.requirement.Id === this.requirementId);
        }
        return result;
    }

    // Narrow {id, label} list for easyAppReviewNav — it only needs enough to render the
    // vertical nav menu, not the entire EASYAppWrapper graph.
    get navItems() {
        if (!this.applicationControl?.data?.requirements) {
            return [];
        }
        // title is the Label, or the Name when the Label is blank (the same rule the applicant pages use)
        return this.applicationControl.data.requirements
            .filter(item => item.requirement?.Id)
            .map(item => ({id: item.requirement.Id, label: item.title}));
    }

    get loadError() {
        return this.applicationControl?.error;
    }

    get hasData() {
        return Boolean(this.applicationControl?.data);
    }

    handleNewRequirement(event) {
        this.requirementId = event.detail;
    }


}