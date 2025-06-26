/**
 * Created by nguy0092 on 6/13/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {gql, graphql} from "lightning/uiGraphQLApi";
import {getFieldValue, getRecord, updateRecord} from "lightning/uiRecordApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import orgWideEmailsApex from "@salesforce/apex/ScholarshipEmailTemplatesController.orgWideEmailsOptions";
import emailTemplatesApex from "@salesforce/apex/ScholarshipEmailTemplatesController.emailTemplatesOptions";
import ID_FIELD from "@salesforce/schema/Scholarship__c.Id";
import ORG_WIDE_EMAIL_ID from "@salesforce/schema/Scholarship__c.Org_Wide_Email_Id__c";
import SUBMIT_EMAIL_TEMPLATE_ID from "@salesforce/schema/Scholarship__c.Submit_Scholarship_Email_Template_Id__c";
import SEND_START_EMAIL from "@salesforce/schema/Scholarship__c.Send_Started_Scholarship_Email__c";
import START_EMAIL_TEMPLATE_ID from "@salesforce/schema/Scholarship__c.Start_Scholarship_Email_Template_Id__c";
import RECOMMENDER_OPTION1 from "@salesforce/schema/Scholarship__c.Recommender_Option__c"
import RECOMMENDER_OPTION2 from "@salesforce/schema/Scholarship__c.Recommender2_Option__c"
import RECOMMENDER1_EMAIL_TEMPLATE_ID from "@salesforce/schema/Scholarship__c.Recommender_Email_Template_Id__c";
import RECOMMENDER2_EMAIL_TEMPLATE_ID from "@salesforce/schema/Scholarship__c.Recommender2_Email_Template_Id__c";
import {refreshApex} from "@salesforce/apex";

const FIELDS = [
    // ID_FIELD,
    ORG_WIDE_EMAIL_ID,
    SUBMIT_EMAIL_TEMPLATE_ID,
    SEND_START_EMAIL,
    START_EMAIL_TEMPLATE_ID,
    RECOMMENDER_OPTION1,
    RECOMMENDER_OPTION2,
    RECOMMENDER1_EMAIL_TEMPLATE_ID,
    RECOMMENDER2_EMAIL_TEMPLATE_ID
];

export default class ScholarshipSelectEmailTemplates extends LightningElement {
    @api recordId;

    scholarshipFields;
    orgWideEmailValueOptions;
    emailTemplateValueOptions;

    orgWideEmailIdUpdate;
    emailTemplateIdUpdate1;
    emailTemplateIdUpdate2;

    templateHtmlValue;
    submitPreviewCheck = false;
    saveDisabled = true;
    cancelDisabled = false;
    orgWideEmailId;
    submitEmailTemplateId;
    sendStartEmailCheck;
    startEmailTemplateId;
    recommenderOption1;
    recommenderOption2;
    recommender1EmailTemplateId;
    recommender2EmailTemplateId;
    orgWideEmailIdValue;
    submitTemplateIdValue;
    startTemplateIdValue;
    recommender1TemplateIdValue;
    recommender2TemplateIdValue;

    orgWideEmailSelectCurrent;
    startTemplateSelectCurrent;
    submitTemplateSelectCurrent;
    recommender1TemplateSelectCurrent;
    recommender2TemplateSelectCurrent;

    unsavedChanges = true;

    renderedCallback() {
        this.orgWideEmailSelectCurrent = this.template.querySelector("[data-selecttype='orgWideEmail']");
        this.submitTemplateSelectCurrent = this.template.querySelector("[data-selecttype='submitTemplate']");
        this.startTemplateSelectCurrent = this.template.querySelector("[data-selecttype='startTemplate']");
        this.recommender1TemplateSelectCurrent = this.template.querySelector("[data-selecttype='recommender1Template']");
        this.recommender2TemplateSelectCurrent = this.template.querySelector("[data-selecttype='recommender2Template']");
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    scholarshipRecord(results) {
        let missingDefaults = [];
        if (results.data) {
            this.scholarshipFields = results.data;
            this.orgWideEmailId = getFieldValue(this.scholarshipFields, ORG_WIDE_EMAIL_ID);
            this.submitEmailTemplateId = getFieldValue(this.scholarshipFields, SUBMIT_EMAIL_TEMPLATE_ID);
            this.sendStartEmailCheck = getFieldValue(this.scholarshipFields, SEND_START_EMAIL);
            this.startEmailTemplateId = getFieldValue(this.scholarshipFields, START_EMAIL_TEMPLATE_ID);
            this.recommenderOption1 = getFieldValue(this.scholarshipFields, RECOMMENDER_OPTION1);
            this.recommenderOption2 = getFieldValue(this.scholarshipFields, RECOMMENDER_OPTION2);
            this.recommender1EmailTemplateId = getFieldValue(this.scholarshipFields, RECOMMENDER1_EMAIL_TEMPLATE_ID);
            this.recommender2EmailTemplateId = getFieldValue(this.scholarshipFields, RECOMMENDER2_EMAIL_TEMPLATE_ID);
            if (!!!this.orgWideEmailId) {
                missingDefaults.push("'Emails Sent From Address'");
            }
            if (!!!this.submitEmailTemplateId) {
                missingDefaults.push("'Scholarship Submitted Email Template'");
            }
            if (this.sendStartEmailCheck && !!!this.startEmailTemplateId) {
                missingDefaults.push("'Scholarship Started Email Template'");
            }
            if ((this.recommenderOption1 === "Recommender Required" || this.recommenderOption1 === "Recommender Optional") && !!!this.recommender1EmailTemplateId) {
                missingDefaults.push("'Recommender 1 Email Template'");
            }
            if ((this.recommenderOption2 === "Recommender2 Required" || this.recommenderOption2 === "Recommender2 Optional") && !!!this.recommender2EmailTemplateId) {
                missingDefaults.push("'Recommender 2 Email Template'");
            }
            if (missingDefaults.length > 0) {
                let displayMissingDefaults = missingDefaults.join(" and ");
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Complete Scholarship Email Templates Setup",
                        message: "Select and save values for " + displayMissingDefaults + ".",
                        variant: "warning",
                    }),
                );
            }
            this.setInitialValues();
            console.log("Full Results: "+JSON.stringify(this.scholarshipFields));
            console.log("orgWideEmailId: "+this.orgWideEmailId);
            console.log("submitEmailTemplateId: "+this.submitEmailTemplateId);
            console.log("sendStartEmailCheck: "+this.sendStartEmailCheck);
            console.log("Recommender1 Option: "+this.recommenderOption1);
            console.log("Recommender2 Option: "+this.recommenderOption2);
            console.log("recommender1EmailTemplateId: "+this.recommender1EmailTemplateId);
            console.log("recommender2EmailTemplateId: "+this.recommender2EmailTemplateId);
        }

    }

    get startSelectVisible() {
        return this.sendStartEmailCheck
    }
    get recommender1SelectVisible() {
        return this.recommenderOption1 === "Recommender Required" || this.recommenderOption1 === "Recommender Optional"
    }
    get recommender2SelectVisible() {
        return this.recommenderOption2 === "Recommender2 Required" || this.recommenderOption2 === "Recommender2 Optional";
    }



    @wire(orgWideEmailsApex)
    orgWideEmailWire({error, data}) {
        if (data) {
            this.orgWideEmailValueOptions = JSON.parse(JSON.stringify(data));
            this.orgWideEmailValueOptions.unshift({label: "--None--", value: ""});
        }

        if (error) {
            console.log("orgWideEmailWire error: " + error)
        }
    }

    @wire(emailTemplatesApex)
    emailTemplateWire({error, data}) {
        if (data) {
            this.emailTemplateValueOptions = JSON.parse(JSON.stringify(data));
            this.emailTemplateValueOptions.unshift({label: "--None--", value: ""});

            // if (!!this.emailTemplateValueOptions && !!this.recommender1TemplateIdValue) {
            //     this.templateHtmlValue = this.findTemplate(this.recommender1TemplateIdValue).htmlValue;
            // } else {
            //     this.templateHtmlValue = "";
            // }
        }

        if (error) {
            console.log("emailTemplateWire error: " + error);
        }
    }

    setInitialValues() {
        this.orgWideEmailIdValue = this.orgWideEmailId;
        this.submitTemplateIdValue = this.submitEmailTemplateId;
        this.startTemplateIdValue = this.startEmailTemplateId;
        this.recommender1TemplateIdValue = this.recommender1EmailTemplateId;
        this.recommender2TemplateIdValue = this.recommender2EmailTemplateId;
        this.saveDisabled = true;
    }

    orgWideEmailSelectValue //USE FOR TESTING
    submitTemplateSelectValue; //USE FOR TESTING
    startTemplateSelectValue; //USE FOR TESTING
    recommender1TemplateSelectValue; //USE FOR TESTING
    recommender2TemplateSelectValue; //USE FOR TESTING
    saveButtonDisabledBool = {};
    saveButtonDisableCheck(evnt) {
        let evntValue = evnt.detail.value;
        switch (evnt.currentTarget.dataset.selecttype) {
            case "orgWideEmail":
                this.orgWideEmailSelectValue = evnt.detail.value; //USE FOR TESTING
                this.orgWideEmailIdValue = evnt.detail.value;
                this.saveButtonDisabledBool.orgWideEmail = evntValue === this.orgWideEmailId ? "true" : "false";
                break;
            case "submitTemplate":
                this.submitTemplateSelectValue = evnt.detail.value; //USE FOR TESTING
                this.submitTemplateIdValue = evnt.detail.value;
                this.saveButtonDisabledBool.submitTemplate = evntValue === this.submitEmailTemplateId ? "true" : "false";
                break;
            case "startTemplate":
                this.startTemplateSelectValue = evnt.detail.value; //USE FOR TESTING
                this.startTemplateIdValue = evnt.detail.value;
                this.saveButtonDisabledBool.startTemplate = evntValue === this.startEmailTemplateId ? "true" : "false";
                break;
            case "recommender1Template":
                this.recommender1TemplateSelectValue = evnt.detail.value; //USE FOR TESTING
                this.recommender1TemplateIdValue = evnt.detail.value;
                this.saveButtonDisabledBool.recommender1Template = evntValue === this.recommender1EmailTemplateId ? "true" : "false";
                break;
            case "recommender2Template":
                this.recommender2TemplateSelectValue = evnt.detail.value; //USE FOR TESTING
                this.recommender2TemplateIdValue = evnt.detail.value;
                this.saveButtonDisabledBool.recommender2Template = evntValue === this.recommender2EmailTemplateId ? "true" : "false";
                break;
        }
        this.saveDisabled = !(Object.values(this.saveButtonDisabledBool).includes("false"));

        // console.log("startTemplateSelectCurrent: "+this.startTemplateSelectCurrent.value);
        console.log("submitTemplateSelectCurrent: "+this.submitTemplateSelectCurrent.value);
        console.log("orgWideEmailSelectCurrent: "+this.orgWideEmailSelectCurrent.value);
        // console.log("recommender1TemplateSelectCurrent: "+this.recommender1TemplateSelectCurrent.value);
        // console.log("recommender2TemplateSelectCurrent: "+this.recommender2TemplateSelectCurrent.value);
    }

    saveClick() {
        let orgWideEmailSelectCurrent = this.template.querySelector("[data-selecttype='orgWideEmail']");
        let emailTemplateSelectCurrent = this.template.querySelector("[data-selecttype='emailTemplate']");

        const fields = {};

        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[ORG_WIDE_EMAIL_ID.fieldApiName] = orgWideEmailSelectCurrent.value;
        fields[RECOMMENDER1_EMAIL_TEMPLATE_ID.fieldApiName] = emailTemplateSelectCurrent.value;

        // if (this.recommenderNumber === 1) {
        //     fields[ORG_WIDE_EMAIL_ID1.fieldApiName] = orgWideEmailSelectCurrent.value;
        //     fields[RECOMMENDER_EMAIL_TEMPLATE_ID.fieldApiName] = emailTemplateSelectCurrent.value;
        // } else if (this.recommenderNumber === 2) {
        //     fields[ORG_WIDE_EMAIL_ID2.fieldApiName] = orgWideEmailSelectCurrent.value;
        //     fields[RECOMMENDER_TEMPLATE_ID2.fieldApiName] = emailTemplateSelectCurrent.value;
        // }

        const recordUpdate = {
            fields: fields
        }

        updateRecord(recordUpdate).then((record) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Recommender " + this.recommenderNumber + " Details Updated",
                    variant: "success",
                }),
            );
            this.saveDisabled = true;
        })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: "error",
                    }),
                );
                orgWideEmailSelectCurrent.value = this.orgWideEmailIdValue;
                emailTemplateSelectCurrent.value = this.recommender1TemplateIdValue;
                this.saveDisabled = true;
            });

    }

    previewClick(event) {
        this.previewCheck = !!event.target.checked;
    }

    findEmail(emailId) {
        return this.orgWideEmailValueOptions.find(template => template.value === emailId);
    }

    findTemplate(templateId) {
        return this.emailTemplateValueOptions.find(template => template.value === templateId);
    }



}