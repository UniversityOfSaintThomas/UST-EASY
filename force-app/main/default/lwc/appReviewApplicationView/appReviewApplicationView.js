/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */

import {api, LightningElement, track, wire} from 'lwc';
import {MessageContext, publish, subscribe} from 'lightning/messageService';
import APP_SELECTED_CHANNEL from '@salesforce/messageChannel/App_Selected__c';
import {CurrentPageReference} from "lightning/navigation";
import {adjustURLParams, setAppIdFromURL} from 'c/appReviewUtility';

export default class AppReviewApplicationView extends LightningElement {

    @track appId;

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        this.lmsSubscription();
    }

    //This will subscribe the LWC to the LMS and grab/sync appId data
    lmsSubscription() {
        subscribe(this.messageContext, APP_SELECTED_CHANNEL, (message) => {
            this.appId = message.appId;
            adjustURLParams('c__appId', this.appId);
        });
        setAppIdFromURL(this.messageContext, APP_SELECTED_CHANNEL, this.currentPageReference, this.appId);
    }

}