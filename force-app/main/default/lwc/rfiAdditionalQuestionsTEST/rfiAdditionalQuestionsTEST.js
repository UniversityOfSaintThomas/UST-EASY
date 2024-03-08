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

export default class rfiAdditionalQuestionsTEST extends LightningElement {

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
            label: 'Position',
            fieldName: 'position',
            type: 'text',
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Value(s)',
            fieldName: 'valuesFlat',
            type: 'text',
            wrapTextMaxLines: 3,
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
    @track isTextarea = false;
    @track isTextBox = false;
    @track isEmail = false;
    @track isStaticContent = false;
    @track assistiveTextRequired = false;

    @track inputItem = {
        'id': '',
        'questionLabel': '',
        'questionType': '',
        'fieldToApplyTo': '',
        'assistiveText': '',
        'position': '',
        'isPicklist': false,
        'isRequired': false,
        'isTextBox': false,
        'isTextarea': false,
        'isRichText': false,
        'isStaticContent': false,
        'isEmail': false,
        'picklistValues': [],
        'valuesFlat': ''
    };

    @track questionJSON = [];

    @track showDataTable = false;

    @track questionTypes = [
        {label: 'Email', value: 'Email'},
        {label: 'Email required', value: 'Email required'},
        {label: 'Picklist', value: 'Picklist'},
        {label: 'Picklist required', value: 'Picklist required'},
        {label: 'Static content', value: 'Static content'},
        {label: 'Text box', value: 'Text box'},
        {label: 'Text box required', value: 'Text box required'},
        {label: 'Textarea', value: 'Textarea'},
        {label: 'Textarea required', value: 'Textarea required'}
    ];

    positionOptions = [
        {label: 'Top', value: 'top'},
        {label: 'Bottom', value: 'bottom'}
    ]

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
                let fieldType = field.dataType.toLowerCase();
                if (((fieldType === 'string' || fieldType === 'textArea') && (this.isTextBox || this.isTextarea || this.isPicklist))
                    || (fieldType === 'email' && this.isEmail)
                    && field.updateable && field.createable
                    && !fieldName.toLowerCase().startsWith('utm_')
                    && !fieldName.toLowerCase().startsWith('gclid')
                    && !fieldName.toLowerCase().startsWith('linkedin')) {
                    leadFields.push({label: field.label, value: fieldName});
                }
            });
        }
        return leadFields;
    }

    validInput(event) {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input,lightning-combobox'),
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
        this.inputItem['id'] = this.questionJSON.length;
        switch (event.target.name) {
            case 'questionType':
                this.isPicklist = false;
                this.isEmail = false;
                this.isTextarea = false;
                this.isTextBox = false;
                this.isStaticContent = false;
                if (event.target.value === 'Picklist' || event.target.value === 'Picklist required') {
                    this.isPicklist = true;
                    this.inputItem['isPicklist'] = true;
                }
                if (event.target.value === 'Text box' || event.target.value === 'Text box required') {
                    this.isTextBox = true;
                    this.inputItem['isTextBox'] = true;
                }
                if (event.target.value === 'Textarea' || event.target.value === 'Textarea required') {
                    this.isTextarea = true;
                    this.inputItem['isTextarea'] = true;
                }
                if (event.target.value === 'Email' || event.target.value === 'Email required') {
                    this.isEmail = true;
                    this.inputItem['isEmail'] = true;
                }
                if (event.target.value === 'Static content') {
                    this.inputItem['isStaticContent'] = true;
                    this.isStaticContent = true;
                }
                this.inputItem['questionType'] = event.target.value;
                if (event.target.value.includes('required')) {
                    this.inputItem['isRequired'] = true;
                    this.assistiveTextRequired = true;
                } else {
                    this.assistiveTextRequired = false;
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
                this.inputItem['valuesFlat'] = pickValues.join(';');
                break;
            case 'staticContent':
                this.inputItem['valuesFlat'] = event.target.value;
                break;
            case 'questionLabel':
                this.inputItem['questionLabel'] = event.target.value;
                break;
            case 'assistiveText':
                this.inputItem['assistiveText'] = event.target.value;
                break;
            case 'position':
                this.inputItem['position'] = event.target.value;
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
                this.template.querySelectorAll('form lightning-combobox, form lightning-input-rich-text').forEach(each => {
                    each.value = undefined;
                });
                this.inputItem = {
                    'questionLabel': '',
                    'questionType': '',
                    'fieldToApplyTo': '',
                    'assistiveText': '',
                    'isPicklist': false,
                    'isRequired': false,
                    'isTextBox': false,
                    'isTextarea': false,
                    'isRichText': false,
                    'isStaticContent': false,
                    'isEmail': false,
                    'picklistValues': [],
                    'valuesFlat': '',
                };
                break;
        }
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

    customButtons = [
        {
            category: "FORMAT_TEXT",
            label: 'Format Text',
            buttons: [
                {
                    value: 'like',
                    label: 'Like',
                    iconName: 'utility:like',
                    format: 'header',
                    handler: function () {
                        // format selection to be h1...
                        this.quill.format('header', 'h1');
                        this.quill.classList.add('slds-text-heading_large');
                    }
                }
            ]
        },

    ];
}