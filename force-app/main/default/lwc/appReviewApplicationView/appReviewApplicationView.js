/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */

import {api, LightningElement, track, wire} from 'lwc';
import {MessageContext, publish, subscribe} from 'lightning/messageService';
import APP_SELECTED_CHANNEL from '@salesforce/messageChannel/App_Selected__c';
import {CurrentPageReference} from "lightning/navigation";
import {adjustURLParams, setAppIdFromURL} from 'c/appReviewUtility';
import getApplicationControl from '@salesforce/apex/appReviewController.getApplicationControl';

export default class AppReviewApplicationView extends LightningElement {

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

    @wire(getApplicationControl, {appId: "$appId"})
    applicationControl;

    get appControlStr() {
        return this.applicationControl
            ? JSON.stringify(this.applicationControl.data, null, 2)
            : '';
    }


}