/**
 * Created by nguy0092 on 3/8/2024.
 */

import {api, LightningElement, track, wire} from 'lwc';
import ID_FIELD from "@salesforce/schema/EASY_Widget__c.Id";
import BUTTON_CODE from "@salesforce/schema/EASY_Widget__c.Button_Code__c";
import {refreshApex} from "@salesforce/apex";
import {getFieldValue, getRecord, notifyRecordUpdateAvailable, updateRecord} from "lightning/uiRecordApi";

const WIDGETFIELDS = [ID_FIELD, BUTTON_CODE];

export default class EasyWidgetButton extends LightningElement {

    columns = [
        {
            label: 'Type',
            fieldName: 'buttonType',
            type: 'text',
            initialWidth: 90,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Label',
            fieldName: 'buttonLabel',
            type: 'text',
            initialWidth: 120,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Requirement ID',
            fieldName: 'buttonRequirementId',
            type: 'text',
            initialWidth: 155,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'URL',
            fieldName: 'buttonUrl',
            type: 'text',
            initialWidth: 200,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Style',
            fieldName: 'buttonStyle',
            type: 'text',
            initialWidth: 70,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Size',
            fieldName: 'buttonSize',
            type: 'text',
            initialWidth: 60,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Position',
            fieldName: 'buttonPosition',
            type: 'text',
            initialWidth: 80,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Icon',
            fieldName: 'buttonIcon',
            type: 'text',
            initialWidth: 75,
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: '',
            type: "button-icon",
            // initialWidth: 45,
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
            label: '',
            type: "button-icon",
            // initialWidth: 45,
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
            label: '',
            type: "button-icon",
            // initialWidth: 45,
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

    @track buttonTypeOptions = [
        {label: 'Requirement Form', value: 'Requirement'},
        {label: 'URL', value: 'URL'},
    ];

    @track buttonStyleOptions = [
        {label: 'Text Link', value: 'text_link'},
        {label: 'Brand', value: 'brand'},
        {label: 'Outline Brand Button', value: 'outline-brand'},
        {label: 'Destructive', value: 'destructive'},
        {label: 'Text Destructive', value: 'text-destructive'},
        {label: 'Neutral', value: 'neutral'},
        {label: 'Success', value: 'success'},

    ];

    @track buttonSizeOptions = [
        {label: '1/8 widget size', value: '1-of-8'},
        {label: '2/8 widget size', value: '2-of-8'},
        {label: '3/8 widget size', value: '3-of-8'},
        {label: '4/8 Widget Size', value: '4-of-8'},
        {label: '5/8 widget size', value: '5-of-8'},
        {label: '6/8 widget size', value: '6-of-8'},
        {label: '7/8 widget size', value: '7-of-8'},
        {label: '8/8 widget size', value: '8-of-8'},
    ];

    @track buttonPositionOptions = [
        {label: 'Left', value: 'left'}, //Left position is default/no class. slds-grid_align-left does not exist. Using to fulfill field value requirement check.
        {label: 'Center', value: 'center'},
        {label: 'Right', value: 'end'},
    ];

    // @track buttonIconOptions = [
    //     {label: 'Event', value: 'event'},
    //     {label: 'Form', value: 'form'},
    //     {label: 'People', value: 'people'},
    // ];

    @api recordId;

    showDataTable = false;
    buttonUrlSelect = false;
    buttonRequirementSelect = false;
    buttonDisable = false;

    button_label;
    button_url;
    button_requirement_id;
    button_style;
    button_size;
    button_position;
    button_icon;

    @track buttonJSON = [];
    @track buttonItem = {
        'id': '',
        'buttonType': '',
        'buttonLabel': '',
        'buttonUrl': '',
        'buttonRequirementId': '',
        'buttonStyle': '',
        'buttonSize': '',
        'buttonPosition': '',
        'buttonIcon': '',
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
            ...this.template.querySelectorAll('lightning-input, lightning-combobox')
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

            case 'ButtonType':

                this.buttonItem['buttonType'] = targetValue;

                if (targetValue === 'Requirement') {

                    this.buttonRequirementSelect = true;
                    this.buttonUrlSelect = false;

                    this.buttonItem['buttonUrl'] = '';
                } else if (targetValue === 'URL') {

                    this.buttonRequirementSelect = false;
                    this.buttonUrlSelect = true;

                    this.buttonItem['buttonRequirementId'] = '';
                }

                break;
            case 'ButtonLabel':

                this.buttonItem['buttonLabel'] = targetValue;

                break;
            case 'ButtonUrl':

                this.buttonItem['buttonUrl'] = targetValue;

                break;
            case 'ButtonRequirementId':

                this.buttonItem['buttonRequirementId'] = targetValue.trim();

                break;
            case 'ButtonStyle':

                this.buttonItem['buttonStyle'] = targetValue;

                if (targetValue === 'text_link') {

                    this.buttonDisable = true;
                    this.button_size = '';
                    this.buttonItem['buttonSize'] = '';
                    this.button_icon = '';
                    this.buttonItem['buttonIcon'] = '';
                } else {

                    this.buttonDisable = false;
                }

                break;
            case 'ButtonSize':

                this.buttonItem['buttonSize'] = targetValue;

                break;
            case 'ButtonPosition':

                this.buttonItem['buttonPosition'] = targetValue;

                break;
            case 'ButtonIcon':

                this.buttonItem['buttonIcon'] = targetValue.toLowerCase().trim();

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
                this.template.querySelectorAll('form lightning-input, form lightning-combobox').forEach(each => {
                    each.value = undefined;
                });

                this.buttonItem = {
                    'id': '',
                    'buttonType': '',
                    'buttonLabel': '',
                    'buttonUrl': '',
                    'buttonRequirementId': '',
                    'buttonStyle': '',
                    'buttonSize': '',
                    'buttonPosition': '',
                    'buttonIcon': '',
                };

                this.buttonUrlSelect = false;
                this.buttonRequirementSelect = false;
                this.buttonDisable = false;

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