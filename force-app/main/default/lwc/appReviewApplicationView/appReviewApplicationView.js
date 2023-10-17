/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */

import {api, LightningElement, track, wire} from 'lwc';
import {MessageContext, subscribe} from "lightning/messageService";
import APP_SELECTED_CHANNEL from '@salesforce/messageChannel/App_Selected__c';

export default class AppReviewApplicationView extends LightningElement {

    @wire(MessageContext)
    messageContext;

    subscription = null;
    @api appId;

    // By using the MessageContext @wire adapter, unsubscribe will be called
    // implicitly during the component descruction lifecycle.


    // Standard lifecycle hooks used to sub/unsub to message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        console.log('subscribing');
        this.subscription = subscribe(
            this.messageContext,
            APP_SELECTED_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    get getAppId() {
        return this.appId;
    }

    // Handler for message received by component
    handleMessage(message) {
        console.log('handling message');
        console.log(JSON.stringify(message));
        this.appId = message.appId;
    }

}