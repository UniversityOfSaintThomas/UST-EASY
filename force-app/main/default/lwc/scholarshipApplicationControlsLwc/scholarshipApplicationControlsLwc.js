/**
 * Created by nguy0092 on 7/23/2025.
 * Use child component SelectApplicationControlsLwc to show Application Control selection.
 */

import {api, LightningElement, wire} from 'lwc';
import ID_FIELD from "@salesforce/schema/Scholarship__c.Id";
import FILTER_APPLICATION_CONTROLS from "@salesforce/schema/Scholarship__c.Application_Controls__c";
import {getFieldValue, getRecord} from "lightning/uiRecordApi";

const FIELDS = [
    ID_FIELD,
    FILTER_APPLICATION_CONTROLS,
]

export default class ScholarshipApplicationControlsLwc extends LightningElement {

    @api recordId;

    initialApplicationControls = "";
    initialApplicationControlsSplit = [];

    get childProps() {
        return {
            parentRecordId: this.recordId,
            idField: ID_FIELD,
            applicationControlField: FILTER_APPLICATION_CONTROLS,
            additionalApplicationControlsInitial: this.initialApplicationControls,
            additionalApplicationControlValues: this.initialApplicationControlsSplit,
            LwcTitle: "Application Control Filters"
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    recordResults(results) {
        if (results.data) {
            let scholarshipData = results.data;
            this.initialApplicationControls = getFieldValue(scholarshipData, FILTER_APPLICATION_CONTROLS);
            this.initialApplicationControlsSplit = this.initialApplicationControls?.split(";");

        }
        if (results.error) {
            console.log("Scholarship Record error: "+results.error);
        }
    }

}