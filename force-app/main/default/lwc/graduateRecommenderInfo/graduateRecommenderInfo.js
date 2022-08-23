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

    // question related
    @track questions_to_display_list = [];
    hardcoded_question_list = [];
    question_id_to_question_map_map = new Map();
    reference_question_options_map = new Map();

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
                        for (const question of questions) {
                            this.handleQuestion(question);
                        }
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

    @wire(getObjectInfo, { objectApiName: RECOMMENDATION_OBJECT })
    object_info(result) {
        if (result.data) {
            let fields = new Map(Object.entries(result.data.fields));
            for (const field of fields) {
                this.all_recommendation_field_api_names.push(field[0]);
            }
        } else {
            console.log(result.error);
        }
    }

    generateReferenceOptions(questions) {
        for (const question of questions) {
            if (question.RecordType.DeveloperName == 'Reference' && question.Display_as_Picklist__c == true) {
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
                                    {label: results[objectId][question.Name_Field_API_Name__c], value: 'Name: ' + results[objectId][question.Name_Field_API_Name__c] + ', Id: ' + objectId}
                                );
                            }
                        }
                        this.reference_question_options_map.set(question.Id, values);
                    }
                })
                .catch((error) => {
                    console.log(error);
                })
            }
        }
    }

    handleQuestion(question) {
        if (Boolean(question.Hardcoded_Value__c)) {
            this.handleHardcodedValue(question);
        } else {
            let picklist_values = this.handlePicklistValues(question);
            let required = this.handleRequired(question);
            let length = this.handleLength(question);

            let question_map = {
                'RecordTypeDeveloperName' : question.RecordType.DeveloperName,
                'Id' : question.Id,
                'Label__c' : question.Label__c,
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
    
            console.log(question_map);
            console.log(this.questions_to_display_list);
        }
    }

    handleHardcodedValue(question) {
        if (question.Related_Object__c == 'Recommendation__c') {
            if (this.all_recommendation_field_api_names.includes(question.Related_Object_Field__c)) {
                switch (question.RecordType.DeveloperName) {
                    case 'Checkbox':
                        if (question.Hardcoded_Value__c.toLowerCase() == 'true') {
                            this.recommendation_input.fields[question.Related_Object_Field__c] = true;
                        } else if (question.Hardcoded_Value__c.toLowerCase() == 'false') {
                            this.recommendation_input.fields[question.Related_Object_Field__c] = false;
                        }
                        break;
                    case 'Currency', 'Number', 'Percent':
                        let value = question.Hardcoded_Value__c;
                        value = value.replace(/[^0-9.,]/g, '');
                        this.recommendation_input.fields[question.Related_Object_Field__c] = parseFloat(value);
                        break;
                    default:
                        this.recommendation_input.fields[question.Related_Object_Field__c] = question.Hardcoded_Value__c;
                        break;
                }
            }
        }
    }

    handlePicklistValues(question) {
        if (question.RecordType.DeveloperName == 'Reference') {
            console.log('reference map 2');
            console.log(this.reference_question_options_map);
            console.log(this.reference_question_options_map[0]);
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

    onChange(event) {
        let question = this.question_id_to_question_map_map.get(event.target.name);
        if (Boolean(question.Related_Object_Field__c) && this.all_recommendation_field_api_names.includes(question.Related_Object_Field__c) && question.Related_Object__c == 'Recommendation__c') {
            switch (question.RecordTypeDeveloperName) {
                case 'MultiPicklist':
                    this.recommendation_input.fields[question.Related_Object_Field__c] = event.detail.value.join(';');
                    break;
                case 'Address':
                    let street = event.target.street;
                    let city = event.target.city;
                    let country = event.target.country;
                    let province = event.target.province;
                    let postalcode = event.target.postalCode;
                    this.recommendation_input.fields[question.Related_Object_Field__c] = street + '\n' + city + ', ' + province + ' ' + postalcode + '\n' + country;
                    console.log(this.recommendation_input.fields[question.Related_Object_Field__c]);
                    break;
                case 'Checkbox':
                    this.recommendation_input.fields[question.Related_Object_Field__c] = String(event.target.checked);
                    break;
                default:
                    this.recommendation_input.fields[question.Related_Object_Field__c] = event.target.value;
                    break;

            }
            if (question.Related_Object_Field__c.includes('Rec_Question_')) {
                let question_text_field = question.Related_Object_Field__c.replace('Response', 'Text');
                this.recommendation_input.fields[question_text_field] = question.Label__c;
            }
        }
        console.log(this.recommendation_input);
    }

    handleSearch(event) {
        console.log(event);
    }
}