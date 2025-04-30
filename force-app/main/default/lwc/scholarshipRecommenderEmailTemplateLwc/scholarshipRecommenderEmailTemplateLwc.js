/**
 * Created by nguy0092 on 4/25/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {gql, graphql} from "lightning/uiGraphQLApi";
import {getFieldValue, getRecord, updateRecord} from "lightning/uiRecordApi";
import orgWideEmailsApex from "@salesforce/apex/ScholarshipRecommenderEmailTemplate.orgWideEmailsOptions";
import emailTemplatesApex from "@salesforce/apex/ScholarshipRecommenderEmailTemplate.emailTemplatesOptions";
import ID_FIELD from "@salesforce/schema/Scholarship__c.Id";
import ORG_WIDE_EMAIL_ID1 from "@salesforce/schema/Scholarship__c.Recommender_Org_From_Email_Id__c";
import ORG_WIDE_EMAIL_ID2 from "@salesforce/schema/Scholarship__c.Recommender2_Org_From_Email_Id__c";
import RECOMMENDER_TEMPLATE_ID1 from "@salesforce/schema/Scholarship__c.Recommender_Email_Template_Id__c";
import RECOMMENDER_TEMPLATE_ID2 from "@salesforce/schema/Scholarship__c.Recommender2_Email_Template_Id__c";

const FIELDS = [ID_FIELD,
    ORG_WIDE_EMAIL_ID1,
    ORG_WIDE_EMAIL_ID2,
    RECOMMENDER_TEMPLATE_ID1,
    RECOMMENDER_TEMPLATE_ID2,
];

export default class ScholarshipRecommenderEmailTemplateLwc extends LightningElement {

    @api recordId;
    @api recommenderNumber = 0;

    orgWideEmailOptions;
    emailTemplateOptions;

    orgWideEmailIdUpdate;
    emailTemplateIdUpdate1;
    emailTemplateIdUpdate2;

    templateHtmlValue;
    previewCheck = false;
    saveDisabled = true;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    scholarshipRecord;

    get idField() {
        return getFieldValue(this.scholarshipRecord.data, ID_FIELD);
    }

    get recommenderOrgWideEmailId1() {
        return getFieldValue(this.scholarshipRecord.data, ORG_WIDE_EMAIL_ID1);
    }

    get recommenderOrgWideEmailId2() {
        return getFieldValue(this.scholarshipRecord.data, ORG_WIDE_EMAIL_ID2);
    }

    get recommenderTemplateId1() {
        return getFieldValue(this.scholarshipRecord.data, RECOMMENDER_TEMPLATE_ID1);
    }

    get recommenderTemplateId2() {
        return getFieldValue(this.scholarshipRecord.data, RECOMMENDER_TEMPLATE_ID2);
    }

    get orgWideEmailSelectionLabel() {
        return "Recommender "+this.recommenderNumber+" Sent From Email";
    }

    get OrgWideEmailIdValue() {
        if (this.recommenderNumber === 1) {
            return this.recommenderOrgWideEmailId1;
        } else if (this.recommenderNumber === 2) {
            return this.recommenderOrgWideEmailId2;
        } else {
            return null;
        }
    }

    get emailTemplateSelectionLabel() {
        return "Recommender "+this.recommenderNumber+" Email Template";
    }

    get recommenderTemplateIdValue() {
        if (this.recommenderNumber === 1) {
            return this.recommenderTemplateId1;
        } else if (this.recommenderNumber === 2) {
            return this.recommenderTemplateId2;
        } else {
            return null;
        }
    }

    @wire(orgWideEmailsApex)
    orgWideEmailWire({error, data}) {
        if (data) {
            this.orgWideEmailOptions = JSON.parse(JSON.stringify(data));
        }

        if (error) {
            console.log("orgWideEmailWire error: " + error)
        }
    }

    @wire(emailTemplatesApex)
    emailTemplateWire({error, data}) {
        if (data) {
            this.emailTemplateOptions = JSON.parse(JSON.stringify(data));

            if (!!this.emailTemplateOptions && !!this.recommenderTemplateIdValue) {
                this.templateHtmlValue = this.findTemplate(this.recommenderTemplateIdValue).htmlValue;
            } else {
                this.templateHtmlValue = "";
            }
        }

        if (error) {
            console.log("emailTemplateWire error: " + error);
        }
    }

    orgWideEmailSelectValue //USE FOR TESTING
    orgWideEmailHandleChange(event) {
        this.orgWideEmailSelectValue = event.detail.value; //USE FOR TESTING
        this.saveButtonBool();
    }

    emailTemplateSelectValue; //USE FOR TESTING
    emailTemplateHandleChange(event) {
        this.emailTemplateSelectValue = event.detail.value; //USE FOR TESTING
        this.templateHtmlValue = this.findTemplate(event.detail.value).htmlValue;
        this.saveButtonBool();

        // if (this.recommenderNumber === 1) {
        //     if (emailTemplateSelectValue !== this.recommenderTemplateIdValue) {
        //         this.emailTemplateIdUpdate1 = emailTemplateSelectValue;
        //     }
        // } else if (this.recommenderNumber === 2) {
        //     if (emailTemplateSelectValue !== this.recommenderTemplateIdValue) {
        //         this.emailTemplateIdUpdate2 = emailTemplateSelectValue;
        //     }
        // }
    }

    saveButtonBool() {
        let emailTemplateSelectCurrent = this.template.querySelector("[data-selecttype='emailTemplate']").value;
        let orgWideEmailSelectCurrent = this.template.querySelector("[data-selecttype='orgWideEmail']").value;

        console.log("template Select Value: "+emailTemplateSelectCurrent);
        console.log("template Id Value: "+this.recommenderTemplateIdValue);
        console.log("org email Select Value: "+orgWideEmailSelectCurrent);
        console.log("org email Id Value: "+this.OrgWideEmailIdValue);

        if (emailTemplateSelectCurrent !== this.recommenderTemplateIdValue || orgWideEmailSelectCurrent !== this.OrgWideEmailIdValue) {
            this.saveDisabled = false;
        } else {
            this.saveDisabled = true;
        }
    }

    handleClick() {
        let emailTemplateSelectCurrent = this.template.querySelector("[data-selecttype='emailTemplate']").value;
        let orgWideEmailSelectCurrent = this.template.querySelector("[data-selecttype='orgWideEmail']").value;

        const fields = {};

        fields[ID_FIELD.fieldApiName] = this.recordId;

        if (this.recommenderNumber === 1) {
            fields[ORG_WIDE_EMAIL_ID1.fieldApiName] = orgWideEmailSelectCurrent;
            fields[RECOMMENDER_TEMPLATE_ID1.fieldApiName] = emailTemplateSelectCurrent;
        } else if (this.recommenderNumber === 2) {
            fields[ORG_WIDE_EMAIL_ID2.fieldApiName] = orgWideEmailSelectCurrent;
            fields[RECOMMENDER_TEMPLATE_ID2.fieldApiName] = emailTemplateSelectCurrent;
        }

        const recordUpdate = {
            fields: fields
        }

        updateRecord(recordUpdate).then((record) => {
            this.saveDisabled = true;
        });
    }

    previewClick() {
        this.previewCheck = !this.previewCheck;
    }

    findTemplate(templateId) {
        return this.emailTemplateOptions.find(template => template.value === templateId);
    }

}