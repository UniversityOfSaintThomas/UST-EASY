/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 12/13/2023.
 */

import {api, LightningElement, track, wire} from 'lwc';
import {getObjectInfo} from "lightning/uiObjectInfoApi";
import {getRecord, getFieldValue} from "lightning/uiRecordApi";
import {updateRecord} from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/RFI_Controller__c.Id";
import ADDITIONAL_QUESTIONS_FIELD from "@salesforce/schema/RFI_Controller__c.Additional_Questions__c";

const FIELDS = [
    ID_FIELD,
    ADDITIONAL_QUESTIONS_FIELD
];

export default class RfiAdditionalQuestions extends LightningElement {

    columns = [
        {
            label: 'Question',
            fieldName: 'questionLabel',
            type: 'text',
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Question Type',
            fieldName: 'questionType',
            type: 'text',
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Field to Apply to',
            fieldName: 'fieldToApplyTo',
            type: 'text',
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Picklist Values',
            fieldName: 'picklistValuesFlat',
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

    @api recordId;

    @track isPicklist = false;

    @track inputItem = {
        'id': '',
        'questionLabel': '',
        'questionType': '',
        'fieldToApplyTo': '',
        'assistiveText': '',
        'isPicklist': false,
        'isRequired': false,
        'isTextBox': false,
        'picklistValues': [],
        'picklistValuesFlat': ''
    };

    @track questionJSON = [];

    @track showDataTable = false;

    @track questionTypes = [
        {label: 'Picklist', value: 'Picklist'},
        {label: 'Picklist required', value: 'Picklist required'},
        {label: 'Text box', value: 'Text box'},
        {label: 'Text box required', value: 'Text box required'},
        {label: 'Textarea', value: 'Textarea'},
        {label: 'Textarea required', value: 'Textarea required'}
    ];

    @wire(getRecord, {recordId: "$recordId", fields: FIELDS})
    addQuestionJSON({error, data}) {
        if (error) {
            console.log(error);
        } else if (data) {
            const JSONString = getFieldValue(data, ADDITIONAL_QUESTIONS_FIELD);
            if (JSONString === null || JSONString === '[]') {
                this.questionJSON = [];
                this.showDataTable = false;
            } else {
                this.questionJSON = JSON.parse(JSONString.toString());
                this.showDataTable = true;
            }
        }
    }

    //Get all the field names and api names for the lead object using getObjectInfo
    @wire(getObjectInfo, {objectApiName: 'Lead'})
    leadObjectInfo;

    //Getting all available lead fields
    get leadFields() {
        let leadFields = [];
        if (this.leadObjectInfo.data) {
            let fieldNames = Object.keys(this.leadObjectInfo.data.fields);
            //iterate over keys
            fieldNames.forEach(fieldName => {
                let field = this.leadObjectInfo.data.fields[fieldName];
                //Check if field is updatable before adding it to the combobox options
                //check if field is a text box or a textarea
                console.log(field.dataType);
                if (field.dataType === 'String' || field.dataType === 'TextArea') {
                    if (field.updateable) {
                        leadFields.push({label: field.label, value: fieldName});
                    }
                }
            });
        }
        return leadFields;
    }

    handleChange(event) {

        this.inputItem['id'] = this.questionJSON.length;
        switch (event.target.name) {
            case 'questionType':
                this.isPicklist = false;
                if (event.target.value === 'Picklist' || event.target.value === 'Picklist required') {
                    this.isPicklist = true;
                    this.inputItem['isPicklist'] = true;
                }
                if (event.target.value === 'Text box' || event.target.value === 'Text box required') {
                    this.inputItem['isTextBox'] = true;
                }
                this.inputItem['questionType'] = event.target.value;
                if (event.target.value.includes('required')) {
                    this.inputItem['isRequired'] = true;
                } else {
                    this.inputItem['isRequired'] = false;
                }
                break;
            case 'fieldToApplyTo':
                this.inputItem['fieldToApplyTo'] = event.target.value;
                break;
            case 'picklistValues':
                let pickValues = event.target.value.split('\n');
                let pickValuesArray = [];
                pickValues.forEach(function (value, i) {    //Remove any blank lines
                    if (value !== '') {
                        pickValuesArray.push({label: value, value: value});
                    }
                })
                this.inputItem['picklistValues'] = pickValuesArray;
                this.inputItem['picklistValuesFlat'] = pickValues.join(';');
                break;
            case 'questionLabel':
                this.inputItem['questionLabel'] = event.target.value;
                break;
            case 'assistiveText':
                this.inputItem['assistiveText'] = event.target.value;
                break;
            case 'Submit':
                this.Submit = event.target.value;
                //Now update the record field RFI_Controller__c.Additional_Questions__c with the new JSON
                this.questionJSON.push(this.inputItem);
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[ADDITIONAL_QUESTIONS_FIELD.fieldApiName] = JSON.stringify(this.questionJSON);
                const recordInput = {fields};
                updateRecord(recordInput).then(r => console.log(r)).catch(e => console.log(e));
                this.template.querySelector("form").reset();
                this.template.querySelectorAll('form lightning-combobox').forEach(each => {
                    each.value = undefined;
                });
                this.inputItem = {
                    'questionLabel': '',
                    'questionType': '',
                    'fieldToApplyTo': '',
                    'picklistValues': '',
                    'picklistValuesFlat': '',
                    isPicklist: false,
                    isRequired: false,
                    isTextBox: false,
                };
                break;
        }

        // console.log(this.questionJSON);
        // console.log(JSON.stringify(this.inputItem));
    }

    callRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        // Move row up or down in questionJSON data structure
        switch (actionName) {
            case 'up':
                if (row.id > 0) {
                    const temp = this.questionJSON[row.id - 1];
                    this.questionJSON[row.id - 1] = this.questionJSON[row.id];
                    this.questionJSON[row.id] = temp;
                }
                break;
            case 'down':
                if (row.id < this.questionJSON.length - 1) {
                    const temp = this.questionJSON[row.id + 1];
                    this.questionJSON[row.id + 1] = this.questionJSON[row.id];
                    this.questionJSON[row.id] = temp;
                }
                break;
            case 'delete': // Delete row
                this.questionJSON.splice(row.id, 1);
                break;
        }
        //Fix ids to new index
        for (let i = 0; i < this.questionJSON.length; i++) {
            this.questionJSON[i].id = i;
        }
        //Now update the record field RFI_Controller__c.Additional_Questions__c with the new JSON

        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[ADDITIONAL_QUESTIONS_FIELD.fieldApiName] = JSON.stringify(this.questionJSON);
        const recordInput = {fields};
        updateRecord(recordInput).then(r => console.log(r)).catch(e => console.log(e));

    }


}