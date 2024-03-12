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
            initialWidth: 200,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Button Link',
            fieldName: 'buttonLink',
            type: 'text',
            initialWidth: 575,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Move Up',
            type: "button-icon",
            initialWidth: 75,
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
            label: 'Move Down',
            type: "button-icon",
            initialWidth: 90,
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
            label: 'Delete',
            type: "button-icon",
            initialWidth: 60,
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

        const targetName = event.target.name;
        const targetValue = event.target.value;

        this.buttonItem['id'] = this.buttonJSON.length;

        switch (targetName) {

            case 'ButtonLabel':

                this.buttonItem['buttonLabel'] = targetValue;

                break;
            case 'ButtonLink':

                this.buttonItem['buttonLink'] = targetValue;

                break;
            case 'Submit':

                this.buttonJSON.push(this.buttonItem);

                //Update the record field EASY_Widget__c.Button_Code__c with the new JSON
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[BUTTON_CODE.fieldApiName] = JSON.stringify(this.buttonJSON);

                const recordInput = {fields};

                updateRecord(recordInput).then(r => console.log(r)).catch(e => console.log(e));

                //Reset form
                this.template.querySelector("form").reset();

                this.template.querySelectorAll('form lightning-input').forEach(each => {
                    each.value = undefined;
                });

                this.buttonItem = {
                    'id': '',
                    'buttonLabel': '',
                    'buttonLink': '',
                };

                break;
        }
    }

    callRowAction(event) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;

        // Move row up or down in buttonJSON data structure
        switch (actionName) {

            case 'up':
                if (row.id > 0) {

                    const temp = this.buttonJSON[row.id - 1];
                    this.buttonJSON[row.id - 1] = this.buttonJSON[row.id];
                    this.buttonJSON[row.id] = temp;
                }

                break;
            case 'down':
                if (row.id < this.buttonJSON.length - 1) {

                    const temp = this.buttonJSON[row.id + 1];
                    this.buttonJSON[row.id + 1] = this.buttonJSON[row.id];
                    this.buttonJSON[row.id] = temp;
                }

                break;
            case 'delete': // Delete row
                this.buttonJSON.splice(row.id, 1);

                break;
        }
        //Fix ids to new index
        for (let i = 0; i < this.buttonJSON.length; i++) {

            this.buttonJSON[i].id = i;
        }

        //Update the record field EASY_Widget__c.Button_Code__c with the new JSON
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[BUTTON_CODE.fieldApiName] = JSON.stringify(this.buttonJSON);

        const recordInput = {fields};

        updateRecord(recordInput).then(r => console.log(r)).catch(e => console.log(e));
    }

}