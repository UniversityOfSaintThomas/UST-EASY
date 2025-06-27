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

    saveDisabled = true;
    cancelDisabled = false;
    saveButtonDisabledBool = {};

    orgWideEmailInitialId;
    submitInitialTemplateId;
    sendStartEmailCheck;
    startInitialTemplateId;
    recommenderOption1;
    recommenderOption2;
    recommender1InitialTemplateId;
    recommender2InitialTemplateId;

    orgWideEmailSelectId;
    submitSelectTemplateId;
    startSelectTemplateId;
    recommender1SelectTemplateId;
    recommender2SelectTemplateId;

    submitPreviewCheckbox;
    startPreviewCheckbox;
    recommender1PreviewCheckbox;
    recommender2PreviewCheckbox;

    submitPreviewChecked = false;
    startPreviewChecked = false;
    recommender1PreviewChecked = false;
    recommender2PreviewChecked = false;

    submitTemplateHtmlValue;
    startTemplateHtmlValue;
    recommender1TemplateHtmlValue;
    recommender2TemplateHtmlValue

    get startSelectVisible() {
        return this.sendStartEmailCheck
    }
    get recommender1SelectVisible() {
        return this.recommenderOption1 === "Recommender Required" || this.recommenderOption1 === "Recommender Optional"
    }
    get recommender2SelectVisible() {
        return this.recommenderOption2 === "Recommender2 Required" || this.recommenderOption2 === "Recommender2 Optional";
    }
    get submitPreviewDisabled() {
        return !!!this.submitSelectTemplateId;
    };
    get startPreviewDisabled() {
        return !!!this.startSelectTemplateId;
    };
    get recommender1PreviewDisabled() {
        return !!!this.recommender1SelectTemplateId;
    };
    get recommender2PreviewDisabled() {
        return !!!this.recommender2SelectTemplateId;
    };

    renderedCallback() {
        this.submitPreviewCheckbox = this.template.querySelector("[data-checktype='submitTemplate']");
        this.startPreviewCheckbox = this.template.querySelector("[data-checktype='startTemplate']");
        this.recommender1PreviewCheckbox = this.template.querySelector("[data-checktype='recommender1Template']");
        this.recommender2PreviewCheckbox = this.template.querySelector("[data-checktype='recommender2Template']");
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    scholarshipRecord(results) {
        let missingDefaults = [];
        if (results.data) {
            this.scholarshipFields = results.data;
            this.orgWideEmailInitialId = getFieldValue(this.scholarshipFields, ORG_WIDE_EMAIL_ID);
            this.submitInitialTemplateId = getFieldValue(this.scholarshipFields, SUBMIT_EMAIL_TEMPLATE_ID);
            this.sendStartEmailCheck = getFieldValue(this.scholarshipFields, SEND_START_EMAIL);
            this.startInitialTemplateId = getFieldValue(this.scholarshipFields, START_EMAIL_TEMPLATE_ID);
            this.recommenderOption1 = getFieldValue(this.scholarshipFields, RECOMMENDER_OPTION1);
            this.recommenderOption2 = getFieldValue(this.scholarshipFields, RECOMMENDER_OPTION2);
            this.recommender1InitialTemplateId = getFieldValue(this.scholarshipFields, RECOMMENDER1_EMAIL_TEMPLATE_ID);
            this.recommender2InitialTemplateId = getFieldValue(this.scholarshipFields, RECOMMENDER2_EMAIL_TEMPLATE_ID);
            if (!!!this.orgWideEmailInitialId) {
                missingDefaults.push("'Sent From Email Address'");
            }
            if (!!!this.submitInitialTemplateId) {
                missingDefaults.push("'Submitted Scholarship Email Template'");
            }
            if (this.sendStartEmailCheck && !!!this.startInitialTemplateId) {
                missingDefaults.push("'Started Scholarship Email Template'");
            }
            if ((this.recommenderOption1 === "Recommender Required" || this.recommenderOption1 === "Recommender Optional") && !!!this.recommender1InitialTemplateId) {
                missingDefaults.push("'Recommender 1 Email Template'");
            }
            if ((this.recommenderOption2 === "Recommender2 Required" || this.recommenderOption2 === "Recommender2 Optional") && !!!this.recommender2InitialTemplateId) {
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
            console.log("orgWideEmailId: "+this.orgWideEmailInitialId);
            console.log("submitEmailTemplateId: "+this.submitInitialTemplateId);
            console.log("sendStartEmailCheck: "+this.sendStartEmailCheck);
            console.log("startEmailTemplateId: "+this.startInitialTemplateId);
            console.log("Recommender1 Option: "+this.recommenderOption1);
            console.log("Recommender2 Option: "+this.recommenderOption2);
            console.log("recommender1EmailTemplateId: "+this.recommender1InitialTemplateId);
            console.log("recommender2EmailTemplateId: "+this.recommender2InitialTemplateId);
        }
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
        }
        if (error) {
            console.log("emailTemplateWire error: " + error);
        }
    }

    setInitialValues() {
        this.orgWideEmailSelectId = this.orgWideEmailInitialId;
        this.submitSelectTemplateId = this.submitInitialTemplateId;
        this.startSelectTemplateId = this.startInitialTemplateId;
        this.recommender1SelectTemplateId = this.recommender1InitialTemplateId;
        this.recommender2SelectTemplateId = this.recommender2InitialTemplateId;
        this.saveDisabled = true;
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
                orgWideEmailSelectCurrent.value = this.orgWideEmailSelectId;
                emailTemplateSelectCurrent.value = this.recommender1SelectTemplateId;
                this.saveDisabled = true;
            });

    }

    findTemplate(templateId) {
        return this.emailTemplateValueOptions.find(template => template.value === templateId);
    }

    templateEventHandler(event) {
        let eventValue = event.detail.value;
        let eventChecked = event.target.checked;
        let datasetTemplateType = event.currentTarget.dataset.templatetype;
        let datasetSelectType = event.currentTarget.dataset.selecttype;
        let datasetCheckType = event.currentTarget.dataset.checktype;

        console.log("eventValue: "+eventValue);
        console.log("eventChecked: "+eventChecked);
        console.log("datasetTemplateType: "+datasetTemplateType);
        console.log("datasetSelectType: "+datasetSelectType);
        console.log("datasetCheckType: "+datasetCheckType);
        console.log("!!datasetSelectType: "+!!datasetSelectType);
        console.log("!!datasetCheckType: "+!!datasetCheckType);

        switch (datasetTemplateType) {
            case "orgWideEmail":
                this.orgWideEmailSelectId = eventValue;
                this.saveButtonDisabledBool.orgWideEmail = eventValue === this.orgWideEmailInitialId ? "true" : "false";
                break;
            case "submitTemplate":
                if (!!datasetSelectType) {
                    this.submitSelectTemplateId = eventValue;
                    this.saveButtonDisabledBool.submitTemplate = eventValue === this.submitInitialTemplateId ? "true" : "false";
                    this.submitPreviewCheckbox.checked = false;
                    this.submitPreviewChecked = false;
                }
                else if (!!datasetCheckType) {
                    if (!!eventChecked) {
                        this.submitTemplateHtmlValue = this.findTemplate(this.submitSelectTemplateId).htmlValue;
                    }
                    this.submitPreviewChecked = eventChecked;
                }
                break;
            case "startTemplate":
                if (!!datasetSelectType) {
                    this.startSelectTemplateId = eventValue;
                    this.saveButtonDisabledBool.startTemplate = eventValue === this.startInitialTemplateId ? "true" : "false";
                    this.startPreviewCheckbox.checked = false;
                    this.startPreviewChecked = false;
                } else if (!!datasetCheckType) {
                    if (!!eventChecked) {
                        this.startTemplateHtmlValue = this.findTemplate(this.startSelectTemplateId).htmlValue;
                    }
                    this.startPreviewChecked = eventChecked;
                }
                break;
            case "recommender1Template":
                if (!!datasetSelectType) {
                    this.recommender1SelectTemplateId = eventValue;
                    this.saveButtonDisabledBool.recommender1Template = eventValue === this.recommender1InitialTemplateId ? "true" : "false";
                    this.recommender1PreviewCheckbox.checked = false;
                    this.recommender1PreviewChecked = false;
                } else if (!!datasetCheckType) {
                    if (!!eventChecked) {
                        this.recommender1TemplateHtmlValue = this.findTemplate(this.recommender1SelectTemplateId).htmlValue;
                    }
                    this.recommender1PreviewChecked = eventChecked;
                }
                break;
            case "recommender2Template":
                if (!!datasetSelectType) {
                    this.recommender2SelectTemplateId = eventValue;
                    this.saveButtonDisabledBool.recommender2Template = eventValue === this.recommender2InitialTemplateId ? "true" : "false";
                    this.recommender2PreviewCheckbox.checked = false;
                    this.recommender2PreviewChecked = false;
                } else if (!!datasetCheckType) {
                    if (!!eventChecked) {
                        this.recommender2TemplateHtmlValue = this.findTemplate(this.recommender2SelectTemplateId).htmlValue;
                    }
                    this.recommender2PreviewChecked = eventChecked;
                }
                break;
        }
        this.saveDisabled = !(Object.values(this.saveButtonDisabledBool).includes("false"));
    }

    // templateSelectHandler(evnt) {
    //     let evntValue = evnt.detail.value;
    //     switch (evnt.currentTarget.dataset.selecttype) {
    //         case "orgWideEmail":
    //             this.orgWideEmailSelectValue = evnt.detail.value; //USE FOR TESTING
    //             this.orgWideEmailIdValue = evnt.detail.value;
    //             this.saveButtonDisabledBool.orgWideEmail = evntValue === this.orgWideEmailId ? "true" : "false";
    //             break;
    //         case "submitTemplate":
    //             this.submitTemplateSelectValue = evnt.detail.value; //USE FOR TESTING
    //             this.submitSelectTemplateId = evnt.detail.value;
    //             this.saveButtonDisabledBool.submitTemplate = evntValue === this.submitInitialTemplateId ? "true" : "false";
    //             this.submitPreviewCheckbox.checked = false;
    //             this.submitPreviewChecked = false;
    //             break;
    //         case "startTemplate":
    //             this.startTemplateSelectValue = evnt.detail.value; //USE FOR TESTING
    //             this.startTemplateIdValue = evnt.detail.value;
    //             this.saveButtonDisabledBool.startTemplate = evntValue === this.startEmailTemplateId ? "true" : "false";
    //             this.startPreviewCheckbox.checked = false;
    //             this.startPreviewChecked = false;
    //             break;
    //         case "recommender1Template":
    //             this.recommender1TemplateSelectValue = evnt.detail.value; //USE FOR TESTING
    //             this.recommender1SelectTemplateId = evnt.detail.value;
    //             this.saveButtonDisabledBool.recommender1Template = evntValue === this.recommender1InitialTemplateId ? "true" : "false";
    //             break;
    //         case "recommender2Template":
    //             this.recommender2TemplateSelectValue = evnt.detail.value; //USE FOR TESTING
    //             this.recommender2SelectTemplateId = evnt.detail.value;
    //             this.saveButtonDisabledBool.recommender2Template = evntValue === this.recommender2InitialTemplateId ? "true" : "false";
    //             break;
    //     }
    //     this.saveDisabled = !(Object.values(this.saveButtonDisabledBool).includes("false"));
    //
    //     // console.log("orgWideEmailSelectCurrent: "+this.orgWideEmailSelectCurrent.value);
    //     // console.log("submitTemplateSelectCurrent: "+this.submitTemplateSelectCurrent.value);
    //     // console.log("startTemplateSelectCurrent: "+this.startTemplateSelectCurrent.value);
    //     // console.log("recommender1TemplateSelectCurrent: "+this.recommender1TemplateSelectCurrent.value);
    //     // console.log("recommender2TemplateSelectCurrent: "+this.recommender2TemplateSelectCurrent.value);
    // }
    // previewChecked(evnt) {
    //     console.log("Checkbox Event type: "+evnt.currentTarget.type);
    //     console.log("Checkbox Event tagName: "+evnt.currentTarget.tagName);
    //     console.log("Checkbox Event dataset: "+evnt.currentTarget.datasetNames);
    //
    //     let evntChecked = evnt.target.checked;
    //     switch (evnt.currentTarget.dataset.checktype) {
    //         case "submitPreview":
    //             if (evntChecked) {
    //                 this.submitTemplateHtmlValue = this.findTemplate(this.submitSelectTemplateId).htmlValue;
    //             }
    //             this.submitPreviewChecked = evntChecked;
    //             break;
    //         case "startPreview":
    //             if (evntChecked) {
    //                 this.startTemplateHtmlValue = this.findTemplate(this.startTemplateIdValue).htmlValue;
    //             }
    //             this.startPreviewChecked = evntChecked;
    //             break;
    //     }
    // }

    findEmail(emailId) {
        return this.orgWideEmailValueOptions.find(template => template.value === emailId);
    }

}