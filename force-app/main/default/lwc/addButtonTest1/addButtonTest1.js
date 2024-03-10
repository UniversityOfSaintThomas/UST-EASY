/**
 * Created by nguy0092 on 3/8/2024.
 */

import {api, LightningElement, track, wire} from 'lwc';
import ID_FIELD from "@salesforce/schema/EASY_Widget__c.Id";
import BUTTON_CODE from "@salesforce/schema/EASY_Widget__c.Button_Code__c";
import {refreshApex} from "@salesforce/apex";
import {getFieldValue, getRecord, notifyRecordUpdateAvailable, updateRecord} from "lightning/uiRecordApi";

const WIDGETFIELDS = [ID_FIELD, BUTTON_CODE];

export default class AddButtonTest1 extends LightningElement {

    columns = [
        {
            label: 'Button Label',
            fieldName: 'buttonLabel',
            type: 'text',
            initialWidth: 150,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Button Link',
            fieldName: 'buttonLink',
            type: 'text',
            wrapText: true,
            hideDefaultActions: true
        },
        {
            type: "button-icon",
            initialWidth: 45,
            wrapText: true,
            typeAttributes: {
                name: 'up',
                title: 'Move Up',
                value: 'up',
                iconPosition: 'center',
                iconName: 'utility:arrowup'
            }
        },
        {
            type: "button-icon",
            initialWidth: 45,
            wrapText: true,
            typeAttributes: {
                name: 'down',
                title: 'Move Down',
                value: 'down',
                iconPosition: 'center',
                iconName: 'utility:arrowdown',
            }
        },
        {
            type: "button-icon",
            initialWidth: 45,
            wrapText: true,
            typeAttributes: {
                name: 'delete',
                title: 'Delete Item',
                value: 'delete',
                iconPosition: 'center',
                iconName: 'utility:delete',
            }
        }
    ];

    showDataTable = false;

    @api recordId;

    @track button_label;
    @track button_link;
    @track buttonJSON = [];
    @track buttonItem = {
        'id': '',
        'buttonLabel': '',
        'buttonLink': '',
    };

    @wire(getRecord, {recordId: '$recordId', fields: WIDGETFIELDS})
    widget({error, data}) {
        if (error) {

            console.log(error);
        } else if (data) {

            const JSONString = getFieldValue(data, BUTTON_CODE);

            if (JSONString === null || JSONString === '[]') {

                this.buttonJSON = [];
                this.showDataTable = false;
            } else {

                this.buttonJSON = JSON.parse(JSONString.toString());
                this.showDataTable = true;
            }
        }
    }

    validInput(event) {

        const allValid = [
            ...this.template.querySelectorAll('lightning-input')
        ].reduce((validSoFar, inputCmp) => {

            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {

            this.handleChange(event);
        } else {

            this.template.querySelector('.slds-has-error').scrollIntoView();
            return false;
        }
    }

    handleChange(event) {

        this.buttonItem['id'] = this.buttonJSON.length;

        if (event.target.name === 'ButtonLabel') {

            this.buttonItem['buttonLabel'] = event.target.value;
        } else if (event.target.name === 'ButtonLink') {

            this.buttonItem['buttonLink'] = event.target.value;
        }

        if (event.target.name === 'Submit') {

            this.buttonJSON.push(this.buttonItem);

            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[BUTTON_CODE.fieldApiName] = JSON.stringify(this.buttonJSON);

            const recordInput = {fields};

            updateRecord(recordInput).then(r => console.log(r)).catch(e => console.log(e));

            this.template.querySelector("form").reset();
        }

        // switch (event.target.name) {
        //     case 'questionType':
        //         this.isPicklist = false;
        //         this.isEmail = false;
        //         this.isTextarea = false;
        //         this.isTextBox = false;
        //         this.isStaticContent = false;
        //         if (event.target.value === 'Picklist' || event.target.value === 'Picklist required') {
        //             this.isPicklist = true;
        //             this.inputItem['isPicklist'] = true;
        //         }
        //         if (event.target.value === 'Text box' || event.target.value === 'Text box required') {
        //             this.isTextBox = true;
        //             this.inputItem['isTextBox'] = true;
        //         }
        //         if (event.target.value === 'Textarea' || event.target.value === 'Textarea required') {
        //             this.isTextarea = true;
        //             this.inputItem['isTextarea'] = true;
        //         }
        //         if (event.target.value === 'Email' || event.target.value === 'Email required') {
        //             this.isEmail = true;
        //             this.inputItem['isEmail'] = true;
        //         }
        //         if (event.target.value === 'Static content') {
        //             this.inputItem['isStaticContent'] = true;
        //             this.isStaticContent = true;
        //         }
        //         this.inputItem['questionType'] = event.target.value;
        //         if (event.target.value.includes('required')) {
        //             this.inputItem['isRequired'] = true;
        //             this.assistiveTextRequired = true;
        //         } else {
        //             this.assistiveTextRequired = false;
        //             this.inputItem['isRequired'] = false;
        //         }
        //         break;
        //     case 'fieldToApplyTo':
        //         this.inputItem['fieldToApplyTo'] = event.target.value;
        //         break;
        //     case 'picklistValues':
        //         let pickValues = event.target.value.split('\n');
        //         let pickValuesArray = [];
        //         pickValues.forEach(function (value, i) {    //Remove any blank lines
        //             if (value !== '') {
        //                 pickValuesArray.push({label: value, value: value});
        //             }
        //         })
        //         this.inputItem['picklistValues'] = pickValuesArray;
        //         this.inputItem['valuesFlat'] = pickValues.join(';');
        //         break;
        //     case 'staticContent':
        //         this.inputItem['valuesFlat'] = event.target.value;
        //         break;
        //     case 'questionLabel':
        //         this.inputItem['questionLabel'] = event.target.value;
        //         break;
        //     case 'assistiveText':
        //         this.inputItem['assistiveText'] = event.target.value;
        //         break;
        //     case 'position':
        //         this.inputItem['position'] = event.target.value;
        //         break;
        //     case 'Submit':
        //         this.Submit = event.target.value;
        //         //Now update the record field RFI_Controller__c.Additional_Questions__c with the new JSON
        //         this.questionJSON.push(this.inputItem);
        //         const fields = {};
        //         fields[ID_FIELD.fieldApiName] = this.recordId;
        //         fields[ADDITIONAL_QUESTIONS_FIELD.fieldApiName] = JSON.stringify(this.questionJSON);
        //         const recordInput = {fields};
        //         updateRecord(recordInput).then(r => console.log(r)).catch(e => console.log(e));
        //         this.template.querySelector("form").reset();
        //         this.template.querySelectorAll('form lightning-combobox, form lightning-input-rich-text').forEach(each => {
        //             each.value = undefined;
        //         });
        //         this.inputItem = {
        //             'questionLabel': '',
        //             'questionType': '',
        //             'fieldToApplyTo': '',
        //             'assistiveText': '',
        //             'isPicklist': false,
        //             'isRequired': false,
        //             'isTextBox': false,
        //             'isTextarea': false,
        //             'isRichText': false,
        //             'isStaticContent': false,
        //             'isEmail': false,
        //             'picklistValues': [],
        //             'valuesFlat': '',
        //         };
        //         break;
        // }
    }

}