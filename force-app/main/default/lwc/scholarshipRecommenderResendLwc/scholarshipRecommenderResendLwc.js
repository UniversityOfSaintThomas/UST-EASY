/**
 * Created by nguy0092 on 3/28/2025.
 */

import {LightningElement, api, wire} from "lwc";
import { getRecord, getFieldValue, notifyRecordUpdateAvailable} from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';
import resendRecommendation from "@salesforce/apex/ScholarshipRecommenderResendController.resendRecommendation";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import SCHOLARSHIP_ID from "@salesforce/schema/Scholarship_Applicant__c.Scholarship__r.Scholarship_ID__c";
import CONTACT_ID from "@salesforce/schema/Scholarship_Applicant__c.Contact__c";
import RECOMMENDER_NAME1 from "@salesforce/schema/Scholarship_Applicant__c.Recommender_Name__c";
import RECOMMENDER_NAME2 from "@salesforce/schema/Scholarship_Applicant__c.Recommender2_Name__c";
import RECOMMENDER_EMAIL1 from "@salesforce/schema/Scholarship_Applicant__c.Recommender_Email__c";
import RECOMMENDER_EMAIL2 from "@salesforce/schema/Scholarship_Applicant__c.Recommender2_Email__c";

const FIELDS = [SCHOLARSHIP_ID,
    CONTACT_ID,
    RECOMMENDER_NAME1,
    RECOMMENDER_NAME2,
    RECOMMENDER_EMAIL1,
    RECOMMENDER_EMAIL2
];
export default class ScholarshipRecommenderResendLwc extends LightningElement {

    @api recordId;
    isLoaded = false;
    resendStatus = false;
    resendButtonDisable = true;
    resendRecommendation1 = false;
    resendRecommendation2 = false;
    recommendersSelected = [];

    get options() {
        var recommenders = [];

        if(this.recommender1 != null) {
            recommenders.push({ label: this.recommender1, value: "recommender1" });
        }

        if(this.recommender2 != null) {
            recommenders.push({ label: this.recommender2, value: "recommender2" });
        }

        return recommenders;
    }

    renderedCallback() {
        if(this.isLoaded) return;

        const STYLE_COMFY_DENSITY = document.createElement("style");
        STYLE_COMFY_DENSITY.innerText = ".uiModal--medium .modal-container{" +
            "width: 40% !important;" +
            "max-width: 40%;" +
            "min-width: 40%;}";

        const STYLE_COMPACT_DENSITY = document.createElement("style");
        STYLE_COMPACT_DENSITY.innerText = ".uiModal--horizontalForm .modal-container{" +
            "width: 40% !important;" +
            "max-width: 40%;" +
            "min-width: 40%;}";

        this.template.querySelector("lightning-quick-action-panel").appendChild(STYLE_COMFY_DENSITY);
        this.template.querySelector("lightning-quick-action-panel").appendChild(STYLE_COMPACT_DENSITY);

        this.isLoaded = true;
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    applicantRecord;

    get scholarshipId() {
        return getFieldValue(this.applicantRecord.data, SCHOLARSHIP_ID);
    }

    get contactId() {
        return getFieldValue(this.applicantRecord.data, CONTACT_ID);
    }

    get recommender1() {
        if (getFieldValue(this.applicantRecord.data, RECOMMENDER_NAME1)) {
            return getFieldValue(this.applicantRecord.data, RECOMMENDER_NAME1) + ' ' + getFieldValue(this.applicantRecord.data, RECOMMENDER_EMAIL1) + " (Recommender 1)";
        } else {
            return null;
        }
    }

    get recommender2() {
        if (getFieldValue(this.applicantRecord.data, RECOMMENDER_NAME2)) {
            return getFieldValue(this.applicantRecord.data, RECOMMENDER_NAME2) + ' ' + getFieldValue(this.applicantRecord.data, RECOMMENDER_EMAIL2) + " (Recommender 2)";
        } else {
            return null;
        }
    }

    get availableRecommenders() {
        return !getFieldValue(this.applicantRecord.data, RECOMMENDER_NAME1) && !getFieldValue(this.applicantRecord.data, RECOMMENDER_NAME2);
    }

    recommendersChecked(event) {
        this.recommendersSelected = event.detail.value;
        this.resendRecommendation1 = !!this.recommendersSelected.find((element) => element === "recommender1");
        this.resendRecommendation2 = !!this.recommendersSelected.find((element) => element === "recommender2");
        this.resendButtonDisable = !this.recommendersSelected.length > 0;
    }

    cancelResend() {
        this.recommendersSelected.length = 0;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async resendRequest() {
        try {
            this.resendStatus = await resendRecommendation({scholarshipId: this.scholarshipId,
                contactId: this.contactId,
                recommendation1: this.resendRecommendation1,
                recommendation2: this.resendRecommendation2});

            if (this.resendStatus) {
                await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Recommendation requests resent!',
                        variant: 'success'
                    })
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error resending recommendation requests!',
                        message: 'Requests not resent!',
                        variant: 'error'
                    })
                );
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error resending recommendation requests!',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

}