/**
 * Created by nguy0092 on 7/14/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {getFieldValue, getRecord, updateRecord} from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/EASY_Widget__c.Id";
import APPLICATION_CONTROL from "@salesforce/schema/EASY_Widget__c.Application_Control__r.URL_Parameter__c";
import ADDITIONAL_APPLICATION_CONTROLS from "@salesforce/schema/EASY_Widget__c.Additional_Application_Controls__c";

const FIELDS = [
    APPLICATION_CONTROL,
    ADDITIONAL_APPLICATION_CONTROLS,
];

export default class EasyWidgetAdditionalAppControlsLwc extends LightningElement {

    @api recordId;

    applicationControl = "";
    initialApplicationControls = "";
    initialApplicationControlsSplit = [];

    get childProps() {
        return {
            parentRecordId: this.recordId,
            idField: ID_FIELD,
            applicationControlField: ADDITIONAL_APPLICATION_CONTROLS,
            existingApplicationControl: this.applicationControl,
            additionalApplicationControlsInitial: this.initialApplicationControls,
            additionalApplicationControlValues: this.initialApplicationControlsSplit,
            LwcTitle: "Additional Application Controls"
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    recordResults(results) {
        if (results.data) {
            let widgetData = results.data;
            this.applicationControl = getFieldValue(widgetData, APPLICATION_CONTROL);
            this.initialApplicationControls = getFieldValue(widgetData, ADDITIONAL_APPLICATION_CONTROLS);
            this.initialApplicationControlsSplit = this.initialApplicationControls?.split(";");

            // console.log("What is Id: "+JSON.stringify(ID_FIELD));
            // console.log("What is primary thing: "+this.applicationControl);
            // console.log("What is initial thing: "+this.initialApplicationControls);
            // console.log("What is split thing: "+this.initialApplicationControlsSplit);
            // console.log("What is thing all: "+JSON.stringify(this.childProps));
        }
        if (results.error) {
            console.log("Widget Record error: "+results.error);
        }
    }
}