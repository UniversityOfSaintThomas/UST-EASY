/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */

import {LightningElement, wire, track, api} from 'lwc';
import {getSObjectValue} from '@salesforce/apex';

import getApplicantInfo from '@salesforce/apex/appReviewController.getApplicantInfo';
import FIRST_NAME from '@salesforce/schema/Application__c.Contact__r.FirstName';
import LAST_NAME from '@salesforce/schema/Application__c.Contact__r.LastName';

import {MessageContext, publish, subscribe} from 'lightning/messageService';
import APP_SELECTED_CHANNEL from '@salesforce/messageChannel/App_Selected__c';
import {CurrentPageReference} from "lightning/navigation";
import {adjustURLParams, setAppIdFromURL, subscribeToLMS} from 'c/appReviewUtility';

export default class AppReviewInfoPanel extends LightningElement {

    @track appId;

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        this.lmsSubscription();
    }

    lmsSubscription() {
        subscribe(this.messageContext, APP_SELECTED_CHANNEL, (message) => {
            this.appId = message.appId;
            adjustURLParams('c__appId', this.appId);
        });
        setAppIdFromURL(this.messageContext, APP_SELECTED_CHANNEL, this.currentPageReference, this.appId);
    }

    @wire(getApplicantInfo, {appId: "$appId"})
    applicantInfo;

    get firstname() {
        return this.applicantInfo.data
            ? getSObjectValue(this.applicantInfo.data, FIRST_NAME)
            : '';
    }

    get lastname() {
        return this.applicantInfo.data
            ? getSObjectValue(this.applicantInfo.data, LAST_NAME)
            : '';
    }

    inputValueChange(event) {
        const payload = {appId: event.detail.value};
        publish(this.messageContext, APP_SELECTED_CHANNEL, payload);
    }

}