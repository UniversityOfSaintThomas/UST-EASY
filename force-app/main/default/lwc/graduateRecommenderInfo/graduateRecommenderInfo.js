/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-17-2022
 * @last modified by  : nicole.b@digitalmass.com
**/

import { LightningElement, wire, track } from 'lwc';
import { generateRecordInputForCreate, getRecordCreateDefaults } from 'lightning/uiRecordApi';

import RECOMMENDATION_OBJECT from '@salesforce/schema/Recommendation__c';

import getObjectIds from '@salesforce/apex/graduateRecommenderInfoController.getObjectIds';
import getRelatedObjectQuestions from '@salesforce/apex/graduateRecommenderInfoController.getRelatedObjectQuestions';
import lookup from '@salesforce/apex/graduateRecommenderInfoController.lookup';

export default class GraduateRecommenderInfo extends LightningElement {

    recommendationId = '';
    applicationId = '';
    requirementId = '';
    relatedObjectRequirementItemId = '';
    applicationStatus = '';

    recommendation_input;
    recommendation_default_RT_ID;
    all_recommendation_field_api_names;

    @track address_question_list = [];
    @track checkbox_question_list = [];
    @track currency_question_list = [];
    @track date_question_list = [];
    @track datetime_question_list = [];
    @track email_question_list = [];
    @track number_question_list = [];
    @track percent_question_list = [];
    @track phone_question_list = [];
    @track picklist_question_list = [];
    @track multipicklist_question_list = [];
    @track radio_question_list = [];
    @track reference_question_list = [];
    @track static_question_list = [];
    @track text_question_list = [];
    @track text_encrypted_question_list = [];
    @track textarea_question_list = [];
    @track textarea_long_question_list = [];
    @track url_question_list = [];
    @track hardcoded_question_list = [];

    question_id_to_question_map_map = new Map();

    @wire(getObjectIds)
    objects(result) {
        if (result.data) {
            if (Boolean(result.data)) {
                console.log(result.data);
                this.recommendationId = result.data.recommendationId;
                this.applicationId = result.data.applicationId;
                this.applicationStatus = result.data.applicationStatus;
                this.requirementId = result.data.requirementId;
                this.relatedObjectRequirementItemId = result.data.relatedObjectRequirementItemId;
                getRelatedObjectQuestions({requirement_item_id: this.relatedObjectRequirementItemId, application_id: this.applicationId})
                .then(questions => {
                    var count = 1;
                    for (const question of questions) {
                        this.handleQuestion(question, count);
                    }
                })
                .catch(error => {
                    console.log(error);
                })
            }
        } else {
            console.log(result.error);
        }
    }

    @wire(getRecordCreateDefaults, { objectApiName: RECOMMENDATION_OBJECT})
    output(result) {
        if (result.data) {
            this.recommendation_input = generateRecordInputForCreate(result.data.record);
        } else {
            console.log(result.error);
        }
    }

    handleQuestion(question, count) {
        console.log(question);
        if (count < 21) {
            var question_map = new Map();

            question_map.set('RecordType.DeveloperName', question.RecordType.DeveloperName);
            question_map.set('Id', question.Id);
            question_map.set('Label__c', question.Label__c);
            question_map.set('Help_Text__c', question.Help_Text__c);
            question_map.set('Placeholder__c', question.Placeholder__c);
            question_map.set('Static_Text__c', question.Static_Text__c);

            question_map.set('Assistive_Text__c', question.Assistive_Text__c);
            question_map.set('Display_as_Picklist__c', question.Display_as_Picklist__c);
            question_map.set('Display_Order__c', question.Display_Order__c);
            question_map.set('Additional_Field_Validation__c', question.Additional_Field_Validation__c);
            question_map.set('Related_Object__c', question.Related_Object__c);
            question_map.set('Related_Object_Field__c', question.Related_Object_Field__c);
            question_map.set('Lookup_Object__c', question.Lookup_Object__c);
            question_map.set('Lookup_Where_Clause__c', question.Lookup_Where_Clause__c);

            question_map = this.handlePicklistValues(question, question_map);

            question_map = this.handleRequired(question, question_map);

            question_map = this.handleLength(question, question_map);

            if (Boolean(question.Hardcoded_Value__c)) {
                this.hardcoded_question_list.push(question_map);
            } else {
                switch (question.RecordType.DeveloperName) {
                    case 'Address':
                        this.address_question_list.push(question_map);
                        break;
                    case 'Checkbox':
                        this.checkbox_question_list.push(question_map);
                        break;
                    case 'Currency':
                        this.currency_question_list.push(question_map);
                        break;
                    case 'Date':
                        this.date_question_list.push(question_map);
                        break;
                    case 'DateTime':
                        this.datetime_question_list.push(question_map);
                        break;
                    case 'Email':
                        this.email_question_list.push(question_map);
                        break;
                    case 'Number':Lookup_Object__c
                        this.number_question_list
                        break;
                    case 'Phone':
                        this.phone_question_list.push(question_map);
                        break;
                    case 'Picklist':
                        this.picklist_question_list.push(question_map);
                        break;
                    case 'MultiPicklist':
                        this.multipicklist_question_list.push(question_map);
                        break;
                    case 'Radio':
                        this.radio_question_list.push(question_map);
                        break;
                    case 'Reference':
                        if (question.Display_as_Picklist__c == true) {
                            var values = this.generateReferencePicklistValues(question.Lookup_Object__c, question.Lookup_Where_Clause__c);
                            question_map.set('Picklist_Values__c', values);
                        }
                        this.reference_question_list.push(question_map);
                        break;
                    case 'Static':
                        this.static_question_list.push(question_map);
                        break;
                    case 'Text':
                        this.text_question_list.push(question_map);
                        break;
                    case 'TextEncrypted':
                        this.text_encrypted_question_list.push(question_map);
                        break;
                    case 'TextArea':
                        this.textarea_question_list.push(question_map);
                        break;
                    case 'LongTextArea':
                        this.textarea_long_question_list.push(question_map);
                        break;
                    case 'URL':
                        this.url_question_list.push(question_map);
                        break;
                    
                }
            }
            console.log(question_map);
            this.question_id_to_question_map_map.set(question.Id, question_map);
        }
    }

    generateReferencePicklistValues(lookup_object, lookup_where_clause) {
        lookup({lookup_object : lookup_object, lookup_where_clause : lookup_where_clause})
        .then((results) => {
            var values = [];
            if(Boolean(results)) {
                for (const objectId in results) {
                    values.push(
                        {label: results[objectId].Name, value: objectId}
                    );
                }
            }
            return values;
        })
        .catch((error) => {
            console.log(error)
        })
    }

    handleSearch(event) {
        console.log(event);
    }

    handlePicklistValues(question, question_map) {
        if (Boolean(question.Picklist_Values__c)) {
            var picklist_values = question.Picklist_Values__c.split('\n');
            var value_list = [];
            for (const picklist_value of picklist_values) {
                value_list.push(
                    {label: picklist_value, value: picklist_value}
                );
            }
            question_map.set('Picklist_Values__c', value_list);
        } else {
            question_map.set('Picklist_Value__c', question.Picklist_Values__c);
        }
        return question_map;
    }

    handleRequired(question, question_map) {
        if (Boolean(question.Required__c)) {
            if (question.Required__c.includes(this.applicationStatus)) {
                question_map.set('Required__c', true);
            }
        } else {
            question_map.set('Required__c', false);
        }
        return question_map;
    }

    handleLength(question, question_map) {
        if (Boolean(question.Length__c)) {
            if (question.RecordType.DeveloperName == 'Currency' || 
                question.RecordType.DeveloperName == 'Number' || 
                question.RecordType.DeveloperName == 'Percent') {
                    var max_value = '';
                    for (let i = 0; i < Integer(question.Length__c); i++) {
                        max_value += '9';
                    }
                    question_map.set('Length__c', max_value);
            } else if (question.RecordType.DeveloperName == 'Text' || question.RecordType.DeveloperName == 'Text') {
                if (Integer(question.Length__c) > 255) {
                    question_map.set('Length__c', '255');
                } else {
                    question_map.set('Length__c', question.Length__c);
                }
            } else if (question.RecordType.DeveloperName == 'LongTextArea') {
                if (Integer(question.Length__c) > 131072) {
                    question_map.set('Length__c', '131072');
                } else {
                    question_map.set('Length__c', question.Length__c);
                }
            } else {
                question_map.set('Length__c', question.Length__c);
            }
        } else {
            question_map.set('Length__c', question.Length__c);
        }
        return question_map;
    }
}