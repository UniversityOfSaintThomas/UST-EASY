/**
 * Created by nguy0092 on 6/26/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {getFieldValue, getRecord, updateRecord} from "lightning/uiRecordApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import orgWideEmailsApex from "@salesforce/apex/ScholarshipCommunicationTemplates.orgWideEmailsOptions";
import emailTemplatesApex from "@salesforce/apex/ScholarshipCommunicationTemplates.emailTemplatesOptions";
import ID_FIELD from "@salesforce/schema/Scholarship__c.Id";
import ORG_WIDE_EMAIL_ID from "@salesforce/schema/Scholarship__c.Org_Wide_Email_Id__c";
import SUBMIT_EMAIL_TEMPLATE_ID from "@salesforce/schema/Scholarship__c.Submit_Scholarship_Email_Template_Id__c";
import SEND_START_EMAIL from "@salesforce/schema/Scholarship__c.Send_Started_Scholarship_Email__c";
import START_EMAIL_TEMPLATE_ID from "@salesforce/schema/Scholarship__c.Start_Scholarship_Email_Template_Id__c";
import RECOMMENDER_OPTION1 from "@salesforce/schema/Scholarship__c.Recommender_Option__c"
import RECOMMENDER_OPTION2 from "@salesforce/schema/Scholarship__c.Recommender2_Option__c"
import RECOMMENDER1_EMAIL_TEMPLATE_ID from "@salesforce/schema/Scholarship__c.Recommender_Email_Template_Id__c";
import RECOMMENDER2_EMAIL_TEMPLATE_ID from "@salesforce/schema/Scholarship__c.Recommender2_Email_Template_Id__c";
import RECORD_TYPE_DEVELOPER_NAME from "@salesforce/schema/Scholarship__c.RecordType.DeveloperName";

const FIELDS = [
    ORG_WIDE_EMAIL_ID,
    SUBMIT_EMAIL_TEMPLATE_ID,
    SEND_START_EMAIL,
    START_EMAIL_TEMPLATE_ID,
    RECOMMENDER_OPTION1,
    RECOMMENDER_OPTION2,
    RECOMMENDER1_EMAIL_TEMPLATE_ID,
    RECOMMENDER2_EMAIL_TEMPLATE_ID,
    RECORD_TYPE_DEVELOPER_NAME
];

export default class ScholarshipCommunicationTemplatesLwc extends LightningElement {
    @api recordId;

    scholarshipEligibleCheck = false;
    @track missingDefaults = [];
    scholarshipFields;
    @track orgWideEmailValueOptions = [];
    @track emailTemplateValueOptions = [];
    saveDisabled = true;
    cancelDisabled = false;
    @track saveButtonDisabledBool = {};
    @track templateDetails = {
        "orgWideEmail": {initial:"", select:"", field: ORG_WIDE_EMAIL_ID},
        "startTemplate": {initial:"", select:"", field: START_EMAIL_TEMPLATE_ID},
        "submitTemplate": {initial:"", select:"", field: SUBMIT_EMAIL_TEMPLATE_ID},
        "recommender1Template": {initial:"", select:"", field: RECOMMENDER1_EMAIL_TEMPLATE_ID},
        "recommender2Template": {initial:"", select:"", field: RECOMMENDER2_EMAIL_TEMPLATE_ID},
    };
    sendStartEmailCheck;
    recommenderOption1;
    recommenderOption2;
    recordTypeDeveloperName;
    @track previewCheckbox = {
        "start": {selector:"", clicked:false},
        "submit": {selector:"", clicked:false},
        "recommender1": {selector:"", clicked:false},
        "recommender2": {selector:"", clicked:false},
    }
    startTemplateHtmlValue;
    submitTemplateHtmlValue;
    recommender1TemplateHtmlValue;
    recommender2TemplateHtmlValue;
    get startTemplateOptions() {
        return this.templateOptionFolders('Started');
    }
    get submitTemplateOptions() {
        return this.templateOptionFolders('Submitted');
    }
    get recommender1TemplateOptions() {
        return this.templateOptionFolders('Recommender 1');
    }
    get recommender2TemplateOptions() {
        return this.templateOptionFolders('Recommender 2');
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
    get startPreviewDisabled() {
        return !!!this.templateDetails.startTemplate.select;
    };
    get submitPreviewDisabled() {
        return !!!this.templateDetails.submitTemplate.select;
    };
    get recommender1PreviewDisabled() {
        return !!!this.templateDetails.recommender1Template.select;
    };
    get recommender2PreviewDisabled() {
        return !!!this.templateDetails.recommender2Template.select;
    };

    renderedCallback() {
        this.previewCheckbox.start.selector = this.template.querySelector("[data-checktype='startTemplate']");
        this.previewCheckbox.submit.selector = this.template.querySelector("[data-checktype='submitTemplate']");
        this.previewCheckbox.recommender1.selector = this.template.querySelector("[data-checktype='recommender1Template']");
        this.previewCheckbox.recommender2.selector = this.template.querySelector("[data-checktype='recommender2Template']");
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    scholarshipRecord(results) {
        this.missingDefaults = [];
        if (results.data) {
            this.scholarshipFields = results.data;
            this.templateDetails.orgWideEmail.initial = getFieldValue(this.scholarshipFields, ORG_WIDE_EMAIL_ID);
            this.templateDetails.startTemplate.initial = getFieldValue(this.scholarshipFields, START_EMAIL_TEMPLATE_ID);
            this.templateDetails.submitTemplate.initial = getFieldValue(this.scholarshipFields, SUBMIT_EMAIL_TEMPLATE_ID);
            this.templateDetails.recommender1Template.initial = getFieldValue(this.scholarshipFields, RECOMMENDER1_EMAIL_TEMPLATE_ID);
            this.templateDetails.recommender2Template.initial = getFieldValue(this.scholarshipFields, RECOMMENDER2_EMAIL_TEMPLATE_ID);
            this.sendStartEmailCheck = getFieldValue(this.scholarshipFields, SEND_START_EMAIL);
            this.recommenderOption1 = getFieldValue(this.scholarshipFields, RECOMMENDER_OPTION1);
            this.recommenderOption2 = getFieldValue(this.scholarshipFields, RECOMMENDER_OPTION2);
            this.recordTypeDeveloperName = getFieldValue(this.scholarshipFields, RECORD_TYPE_DEVELOPER_NAME);
            this.scholarshipEligibleCheck = this.recordTypeDeveloperName === "Graduate_Scholarship" || this.recordTypeDeveloperName === "Scholarship" || this.recordTypeDeveloperName === "Signature_Programs";
            if (!!!this.templateDetails.orgWideEmail.initial) {
                this.missingDefaults.push("'Sent From Email Address'");
            }
            if (this.sendStartEmailCheck && !!!this.templateDetails.startTemplate.initial) {
                this.missingDefaults.push("'Started Scholarship Email Template'");
            }
            if (!!!this.templateDetails.submitTemplate.initial) {
                this.missingDefaults.push("'Submitted Scholarship Email Template'");
            }
            if ((this.recommenderOption1 === "Recommender Required" || this.recommenderOption1 === "Recommender Optional") && !!!this.templateDetails.recommender1Template.initial) {
                this.missingDefaults.push("'Recommender 1 Email Template'");
            }
            if ((this.recommenderOption2 === "Recommender2 Required" || this.recommenderOption2 === "Recommender2 Optional") && !!!this.templateDetails.recommender2Template.initial) {
                this.missingDefaults.push("'Recommender 2 Email Template'");
            }
            this.setInitialValues();
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
        }
        if (error) {
            console.log("emailTemplateWire error: " + error);
        }
    }

    setInitialValues() {
        if (this.scholarshipEligibleCheck && this.missingDefaults.length > 0) {
            let displayMissingDefaults = this.missingDefaults.join(" and ");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Complete Scholarship Communication Templates Setup",
                    message: "Select and Save values for " + displayMissingDefaults + ".",
                    variant: "warning",
                }),
            );
        }
        this.templateDetails.orgWideEmail.select = this.templateDetails.orgWideEmail.initial;
        this.templateDetails.startTemplate.select = this.templateDetails.startTemplate.initial;
        this.templateDetails.submitTemplate.select = this.templateDetails.submitTemplate.initial;
        this.templateDetails.recommender1Template.select = this.templateDetails.recommender1Template.initial;
        this.templateDetails.recommender2Template.select = this.templateDetails.recommender2Template.initial;
        for (const key in this.previewCheckbox) {
            if (this.previewCheckbox[key].selector) {
                this.previewCheckbox[key].selector.checked = false;
            }
            this.previewCheckbox[key].clicked = false;
        }
        this.saveDisabled = true;
    }

    templateOptionFolders(folderString) {
        let templates = [];
        this.emailTemplateValueOptions.forEach((t) => {
            if (t.folderName.startsWith(folderString)) {
                templates.push(t);
            }
        })
        templates.unshift({label: "--None--", value: ""});
        return templates;
    }

    templateEventHandler(event) {
        let eventValue = event.detail.value;
        let eventChecked = event.target.checked;
        let datasetTemplateType = event.currentTarget.dataset.templatetype;
        let datasetSelectType = event.currentTarget.dataset.selecttype;
        let datasetCheckType = event.currentTarget.dataset.checktype;
        switch (datasetTemplateType) {
            case "orgWideEmail":
                this.templateDetails.orgWideEmail.select = eventValue;
                this.saveButtonDisabledBool.orgWideEmail = eventValue === this.templateDetails.orgWideEmail.initial ? "true" : "false";
                break;
            case "startTemplate":
                if (datasetSelectType) {
                    this.templateDetails.startTemplate.select = eventValue;
                    this.saveButtonDisabledBool.startTemplate = eventValue === this.templateDetails.startTemplate.initial ? "true" : "false";
                    this.previewCheckbox.start.selector.checked = false;
                    this.previewCheckbox.start.clicked = false;
                } else if (datasetCheckType) {
                    if (eventChecked) {
                        this.startTemplateHtmlValue = this.findTemplate(this.templateDetails.startTemplate.select).htmlValue;
                    }
                    this.previewCheckbox.start.clicked = eventChecked;
                }
                break;
            case "submitTemplate":
                if (datasetSelectType) {
                    this.templateDetails.submitTemplate.select = eventValue;
                    this.saveButtonDisabledBool.submitTemplate = eventValue === this.templateDetails.submitTemplate.initial ? "true" : "false";
                    this.previewCheckbox.submit.selector.checked = false;
                    this.previewCheckbox.submit.clicked = false;
                }
                else if (datasetCheckType) {
                    if (eventChecked) {
                        this.submitTemplateHtmlValue = this.findTemplate(this.templateDetails.submitTemplate.select).htmlValue;
                    }
                    this.previewCheckbox.submit.clicked = eventChecked;
                }
                break;
            case "recommender1Template":
                if (datasetSelectType) {
                    this.templateDetails.recommender1Template.select = eventValue;
                    this.saveButtonDisabledBool.recommender1Template = eventValue === this.templateDetails.recommender1Template.initial ? "true" : "false";
                    this.previewCheckbox.recommender1.selector.checked = false;
                    this.previewCheckbox.recommender1.clicked = false;
                } else if (datasetCheckType) {
                    if (eventChecked) {
                        this.recommender1TemplateHtmlValue = this.findTemplate(this.templateDetails.recommender1Template.select).htmlValue;
                    }
                    this.previewCheckbox.recommender1.clicked = eventChecked;
                }
                break;
            case "recommender2Template":
                if (datasetSelectType) {
                    this.templateDetails.recommender2Template.select = eventValue;
                    this.saveButtonDisabledBool.recommender2Template = eventValue === this.templateDetails.recommender2Template.initial ? "true" : "false";
                    this.previewCheckbox.recommender2.selector.checked = false;
                    this.previewCheckbox.recommender2.clicked = false;
                } else if (datasetCheckType) {
                    if (eventChecked) {
                        this.recommender2TemplateHtmlValue = this.findTemplate(this.templateDetails.recommender2Template.select).htmlValue;
                    }
                    this.previewCheckbox.recommender2.clicked = eventChecked;
                }
                break;
        }
        this.saveDisabled = !(Object.values(this.saveButtonDisabledBool).includes("false"));
    }

    findTemplate(templateId) {
        return this.emailTemplateValueOptions.find(template => template.value === templateId);
    }

    saveClick() {
        const updateFields = {};
        updateFields[ID_FIELD.fieldApiName] = this.recordId;

        for (const key in this.templateDetails) {
            if (this.templateDetails[key].select !== this.templateDetails[key].initial) {
                updateFields[this.templateDetails[key].field.fieldApiName] = this.templateDetails[key].select;
            }
        }

        const recordUpdate = {
            fields: updateFields
        }

        updateRecord(recordUpdate).then((record) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Email Templates Updated",
                    variant: "success",
                }),
            );
        })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: "error",
                    }),
                );
            });
        this.saveButtonDisabledBool = {};
        this.saveDisabled = true;
    }
}