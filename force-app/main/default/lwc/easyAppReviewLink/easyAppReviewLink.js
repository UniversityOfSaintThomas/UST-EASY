/**
 * easyAppReviewLink — Button/link placed on an Application__c record page
 * that navigates to the Application_Review_LWC app page, pre-loading the
 * application via the c__appId URL state parameter.
 *
 * @author Thaddaeus Dahlberg, University of St. Thomas
 */

import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

const REVIEW_PAGE = 'Application_Review_LWC';

export default class EasyAppReviewLink extends NavigationMixin(LightningElement) {

    /** Injected automatically by the record page */
    @api recordId;

    /** Label shown on the button — configurable in App Builder */
    @api label = 'Open Application Review';

    /** SLDS button variant: brand | neutral | outline-brand | inverse */
    @api variant = 'brand';

    reviewPageUrl;

    // Re-generate URL if the page reference changes (e.g. in Experience Cloud)
    @wire(CurrentPageReference)
    wiredPageRef() {
        this._generateUrl();
    }

    get buttonClass() {
        const v = this.variant ?? 'brand';
        return `slds-button slds-button_${v}`;
    }

    _generateUrl() {
        if (!this.recordId) return;
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__navItemPage',
            attributes: { apiName: REVIEW_PAGE },
            state: { c__appId: this.recordId }
        }).then(url => {
            this.reviewPageUrl = url;
        });
    }

    handleClick(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: { apiName: REVIEW_PAGE },
            state: { c__appId: this.recordId }
        });
    }
}