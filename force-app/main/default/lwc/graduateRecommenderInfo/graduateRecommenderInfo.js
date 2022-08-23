/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-23-2022
 * @last modified by  : nicole.b@digitalmass.com
**/

import { LightningElement, wire, track } from 'lwc';
import { generateRecordInputForCreate, getRecordCreateDefaults } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import RECOMMENDATION_OBJECT from '@salesforce/schema/Recommendation__c';

import getRelatedObjectInfo from '@salesforce/apex/graduateRecommenderInfoController.getRelatedObjectInfo';
import getRelatedObjectQuestions from '@salesforce/apex/graduateRecommenderInfoController.getRelatedObjectQuestions';
import lookup from '@salesforce/apex/graduateRecommenderInfoController.lookup';

export default class GraduateRecommenderInfo extends LightningElement {

    // parent object related
    recommendation_id = '';
    application_id = '';
    application_status = '';
    requirement_id = '';
    @track requirement_item_instructions = '';
    related_object_requirement_item_id = '';

    // recommendation related
    recommendation_input;
    recommendation_default_RT_ID;
    all_recommendation_field_api_names = [];
    rec_fields_data_type_map = new Map();

    // question related
    @track questions_to_display_list = [];
    hardcoded_question_list = [];
    question_id_to_question_map_map = new Map();
    reference_question_options_map = new Map();

    reference_question_search_columns = [
        { label: 'Name', fieldName: 'label', type: 'text' }
    ];

    @track show_spinner = false;

    @wire(getObjectInfo, { objectApiName: RECOMMENDATION_OBJECT })
    object_info(result) {
        if (result.data) {
            let fields = new Map(Object.entries(result.data.fields));
            for (const field of fields) {
                this.all_recommendation_field_api_names.push(field[1].apiName);
                this.rec_fields_data_type_map.set(field[1].apiName, field[1].dataType);
            }
        } else {
            console.log(result.error);
        }
    }

    @wire(getRecordCreateDefaults, { objectApiName: RECOMMENDATION_OBJECT})
    output(result) {
        if (result.data) {
            this.recommendation_input = generateRecordInputForCreate(result.data.record);
            getRelatedObjectInfo()
            .then(objectInfo => {
                if (Boolean(objectInfo)) {
                    this.recommendation_id = objectInfo.recommendation_id;
                    this.application_id = objectInfo.application_id;
                    this.application_status = objectInfo.application_status;
                    this.requirement_id = objectInfo.requirement_id;
                    this.related_object_requirement_item_id = objectInfo.related_object_requirement_item_id;
                    if (objectInfo.display_instructive_text == 'true') {
                        this.requirement_item_instructions = objectInfo.requirement_item_instructions;
                    }

                    getRelatedObjectQuestions({requirement_item_id: this.related_object_requirement_item_id, application_id: this.application_id})
                    .then(questions => {
                        this.generateReferenceOptions(questions);
                        this.questions_to_display_list.sort((a,b) => a.Display_Order__c - b.Display_Order__c);
                    })
                    .catch(error => {
                        console.log(error);
                    })
                }
            })
            .catch(error => {
                console.log(error);
            })
        } else {
            console.log(result.error);
        }
    }


    generateReferenceOptions(questions) {
        for (const question of questions) {
            let lookup_object = question.Lookup_Object__c;
            let lookup_where_clause = question.Lookup_Where_Clause__c;
            let name_field_api_name = question.Name_Field_API_Name__c;
            lookup({lookup_object : lookup_object, lookup_where_clause : lookup_where_clause, name_field_api_name : name_field_api_name})
            .then((results) => {
                if (JSON.stringify(results).length > 2) {
                    let values = [];
                    if(Boolean(results)) {
                        for (const objectId in results) {
                            values.push(
                                {label: results[objectId][question.Name_Field_API_Name__c], value: objectId}
                            );
                        }
                    }
                    this.reference_question_options_map.set(question.Id, values);
                }
                this.handleQuestion(question);
            })
            .catch((error) => {
                console.log(error);
            })
        }
    }

    handleQuestion(question) {
        if (Boolean(question.Hardcoded_Value__c)) {
            this.handleHardcodedValue(question);
        } else {
            let picklist_values = this.handlePicklistValues(question);
            let required = this.handleRequired(question);
            let length = this.handleLength(question);
            let label = this.handleLabel(question);

            let question_map = {
                'RecordTypeDeveloperName' : question.RecordType.DeveloperName,
                'Id' : question.Id,
                'Label__c' : label,
                'Help_Text__c' : question.Help_Text__c,
                'Placeholder__c' : question.Placeholder__c,
                'Static_Text__c' : question.Static_Text__c,
                'Assistive_Text__c' : question.Assistive_Text__c,
                'Display_as_Picklist__c' : question.Display_as_Picklist__c,
                'Display_Order__c' : question.Display_Order__c,
                'Additional_Field_Validation__c' : question.Additional_Field_Validation__c,
                'Related_Object__c' : question.Related_Object__c,
                'Related_Object_Field__c' : question.Related_Object_Field__c,
                'Lookup_Object__c' : question.Lookup_Object__c,
                'Lookup_Where_Clause__c' : question.Lookup_Where_Clause__c,
                'Name_Field_API_Name__c' : question.Name_Field_API_Name__c,
                'Picklist_Values__c' : picklist_values,
                'Required__c' : required,
                'Length__c' : length
            }
            question_map[question.RecordType.DeveloperName] = true;
            this.questions_to_display_list.push(question_map);
            this.question_id_to_question_map_map.set(question.Id, question_map);
        }
    }

    handleHardcodedValue(question) {
        if (question.Related_Object__c == 'Recommendation__c' && this.all_recommendation_field_api_names.includes(question.Related_Object_Field__c)) {
            let field_input = this.convertInput(question.Hardcoded_Value__c, question.Related_Object_Field__c);
            this.recommendation_input.fields[question.Related_Object_Field__c] = field_input;
            if (question.Related_Object_Field__c.includes('Rec_Question_')) {
                let question_text_field = question.Related_Object_Field__c.replace('Response', 'Text');
                this.recommendation_input.fields[question_text_field] = this.handleLabel(question);
            }
        }
    }

    handlePicklistValues(question) {
        if (question.RecordType.DeveloperName == 'Reference') {
            return this.reference_question_options_map.get(question.Id);
        } else if (Boolean(question.Picklist_Values__c)) {
            let picklist_values = question.Picklist_Values__c.split('\n');
            let value_list = [];
            for (const picklist_value of picklist_values) {
                let value = picklist_value;
                if (value.includes('\r')) {
                    value = value.replace('\r', '')
                }
                value_list.push(
                    {label: value, value: value}
                );
            }
            return value_list;
        } else {
            return question.Picklist_Values__c;
        }
    }

    handleRequired(question) {
        if (Boolean(question.Required__c)) {
            if (question.Required__c.includes(this.application_status)) {
                return true;
            }
        }
        return false;
    }

    handleLength(question) {
        if (Boolean(question.Length__c)) {
            if (question.RecordType.DeveloperName == 'Currency' || 
                question.RecordType.DeveloperName == 'Number' || 
                question.RecordType.DeveloperName == 'Percent') {
                    let max_value = '';
                    for (let i = 0; i < Integer(question.Length__c); i++) {
                        max_value += '9';
                    }
                    return max_value;
            } else if (question.RecordType.DeveloperName == 'Text' || question.RecordType.DeveloperName == 'Text') {
                if (Integer(question.Length__c) > 255) {
                    return '255';
                }
            } else if (question.RecordType.DeveloperName == 'LongTextArea') {
                if (Integer(question.Length__c) > 131072) {
                    return '131072';
                }
            }
        }
        return question.Length__c;
    }

    handleLabel(question) {
        if (Boolean(question.Label__c)) {
            return question.Label__c;
        } else {
            return question.Name;
        }
    }

    onChange(event) {
        let question = this.question_id_to_question_map_map.get(event.target.name);
        if (Boolean(question.Related_Object_Field__c) && this.all_recommendation_field_api_names.includes(question.Related_Object_Field__c) && question.Related_Object__c == 'Recommendation__c') {
            switch (question.RecordTypeDeveloperName) {
                case 'MultiPicklist':
                    this.recommendation_input.fields[question.Related_Object_Field__c] = this.convertInput(event.detail.value.join(';'), question.Related_Object_Field__c);
                    break;
                case 'Address':
                    let street = event.target.street;
                    let city = event.target.city;
                    let country = event.target.country;
                    let province = event.target.province;
                    let postalcode = event.target.postalCode;
                    this.recommendation_input.fields[question.Related_Object_Field__c] = this.convertInput(street + '\n' + city + ', ' + province + ' ' + postalcode + '\n' + country, question.Related_Object_Field__c);
                    break;
                case 'Checkbox':
                    this.recommendation_input.fields[question.Related_Object_Field__c] = this.convertInput(event.target.checked, question.Related_Object_Field__c);
                    break;
                default:
                    this.recommendation_input.fields[question.Related_Object_Field__c] = this.convertInput(event.target.value, question.Related_Object_Field__c);
                    break;

            }

            if (question.RecordTypeDeveloperName == 'Reference' && question.Display_as_Picklist__c == false) {
                try {
                    var selected_row = this.template.querySelector('lightning-datatable[data-id="' + question.Id + '"]').getSelectedRows();
                    this.recommendation_input.fields[question.Related_Object_Field__c] = this.convertInput(selected_row[0].value, question.Related_Object_Field__c);
                } catch (error) {
                    console.log(error);
                }
            }

            if (question.Related_Object_Field__c.includes('Rec_Question_')) {
                let question_text_field = question.Related_Object_Field__c.replace('Response', 'Text');
                this.recommendation_input.fields[question_text_field] = question.Label__c;
            }
        }
        console.log(this.recommendation_input);
    }

    convertInput(input, related_object_field) {
        if (this.all_recommendation_field_api_names.includes(related_object_field)) {
            let data_type = this.rec_fields_data_type_map.get(related_object_field).toLowerCase();
            switch (data_type) {
                case 'boolean':
                    if (input.toLowerCase() == 'true') {
                        return true;
                    } else if (input.toLowerCase() == 'false') {
                        return false;
                    }
                    break;
                case 'double':
                case 'currency':
                case 'percent':
                    return parseFloat(input);
                case 'int':
                case 'long':
                    return parseInt(input);
                default: // everything else can be string
                    return String(input);
            }
        }
        return null;
    }

    handleSearch(event) {
        try {
            if (event.target.value.length > 0) {
                let possible_values = this.reference_question_options_map.get(event.target.name);
                const filtered_values = possible_values.filter(value => value.label.toLowerCase().includes(String(event.target.value).toLowerCase()));
                this.template.querySelector('lightning-datatable[data-id="' + String(event.target.name) + '"]').selectedRows = [];
                this.template.querySelector('lightning-datatable[data-id="' + String(event.target.name) + '"]').data = filtered_values;
                this.recommendation_input.fields[this.question_id_to_question_map_map.get(event.target.name).Related_Object_Field__c] = null;
            } else {
                this.template.querySelector('lightning-datatable[data-id="' + String(event.target.name) + '"]').selectedRows = [];
                this.template.querySelector('lightning-datatable[data-id="' + String(event.target.name) + '"]').data = this.reference_question_options_map.get(event.target.name);
                this.recommendation_input.fields[this.question_id_to_question_map_map.get(event.target.name).Related_Object_Field__c] = null;
            }
        } catch (error) {
            console.log(error);
        }
    }

    handleSubmit() {
        if (this.validateInput()) {
            this.show_spinner = true;
            console.log(this.recommendation_input);
            for (let property in this.recommendation_input.fields) {
                if (this.recommendation_input.fields[property] == null) {
                    delete this.recommendation_input.fields[property];
                }
            }
            console.log(this.recommendation_input);
            this.show_spinner = false;
        }
        console.log('submit');
    }

    validateInput() {
        let valid_input_fields = this.validateInputFields();
        let valid_picklist_fields = this.validatePicklistFields();
        let valid_multi_picklist_fields = this.validateMultiPicklistFields();
        let valid_text_area_fields = this.validateTextAreaFields();
        let valid_radio_group_fields = this.validateRadioGroupFields();
        let valid_input_address_fields = this.validateInputAddressFields();
        if (valid_input_fields && valid_picklist_fields && valid_multi_picklist_fields && valid_text_area_fields && valid_radio_group_fields && valid_input_address_fields) {
            return true;
        } else {
            return false;
        }
    }

    //https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation
    validateInputFields() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            return true;
        } else {
            return false;
        }
    }

    validatePicklistFields() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            return true;
        } else {
            return false;
        }
    }

    validateMultiPicklistFields() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-dual-listbox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            return true;
        } else {
            return false;
        }
    }

    validateTextAreaFields() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-textarea'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            return true;
        } else {
            return false;
        }
    }

    validateRadioGroupFields() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-radio-group'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            return true;
        } else {
            return false;
        }
    }

    validateInputAddressFields() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input-address'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            return true;
        } else {
            return false;
        }
    }
}