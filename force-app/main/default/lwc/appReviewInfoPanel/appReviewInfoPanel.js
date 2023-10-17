/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */

import {LightningElement, wire, track} from 'lwc';
import {getSObjectValue} from '@salesforce/apex';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';

import getApplicantInfo from '@salesforce/apex/appReviewController.getApplicantInfo';
import FIRST_NAME from '@salesforce/schema/Application__c.Contact__r.FirstName';
import LAST_NAME from '@salesforce/schema/Application__c.Contact__r.LastName';

import { subscribe, MessageContext, publish } from 'lightning/messageService';
import APP_SELECTED_CHANNEL from '@salesforce/messageChannel/App_Selected__c';

export default class AppReviewInfoPanel extends LightningElement {

    @track currentPageReference;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        const message = {
            appId: this.appId
        };
        publish(this.messageContext, APP_SELECTED_CHANNEL, message);
    }

    get appId() {
        return this.currentPageReference?.state?.c__appId;
    }

    @wire(getApplicantInfo, {appId: '$appId'})
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

}