/**
 * Created by nguy0092 on 4/25/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {gql, graphql} from "lightning/uiGraphQLApi";
import {getFieldValue, getRecord, updateRecord} from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/Scholarship__c.Id";
import RECOMMENDER_TEMPLATE1_ID from "@salesforce/schema/Scholarship__c.Recommender_Email_Template_Id__c";
import RECOMMENDER_TEMPLATE2_ID from "@salesforce/schema/Scholarship__c.Recommender2_Email_Template_Id__c";

const FIELDS = [ID_FIELD,
    RECOMMENDER_TEMPLATE1_ID,
    RECOMMENDER_TEMPLATE2_ID,
];

export default class ScholarshipRecommenderEmailTemplateLwc extends LightningElement {

    @api recordId;
    @track EmailTemplateOptions;

    emailTemplateIdUpdate1;
    emailTemplateIdUpdate2;

    selectValue;
    htmlValue;
    saveDisabled1 = true;


    handleChange(event) {
        this.selectValue = event.detail.value;

        if (this.selectValue !== this.emailTemplateIdUpdate1) {
            this.emailTemplateIdUpdate1 = event.detail.value;
            this.saveDisabled1 = false;
        } else {
            this.saveDisabled1 = true;
        }
    }

    handleClick() {
        const fields = {};

        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[RECOMMENDER_TEMPLATE1_ID.fieldApiName] = this.emailTemplateIdUpdate1;

        const recordUpdate = {
            fields: fields
        }

        updateRecord(recordUpdate).then((record) => {
            this.saveDisabled1 = true;
            console.log(record);
        });
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    scholarshipRecord;

    get idField() {
        return getFieldValue(this.scholarshipRecord.data, ID_FIELD);
    }

    get recommenderTemplateId1() {
        return getFieldValue(this.scholarshipRecord.data, RECOMMENDER_TEMPLATE1_ID);
    }

    get recommenderTemplateId2() {
        return getFieldValue(this.scholarshipRecord.data, RECOMMENDER_TEMPLATE2_ID);
    }

    // get options() {
    //     return [
    //         { label: 'New', value: 'new' },
    //         { label: 'In Progress', value: 'inProgress' },
    //         { label: 'Finished', value: 'finished' },
    //     ];
    // }

    @wire(graphql, {
        query: gql`
      query EmailTemplatetWithName {
        uiapi {
          query {
            EmailTemplate( where: { UiType: { eq: "SFX" }
                                    FolderName: { eq: "" } },
                           orderBy: { Name: { order: ASC } } ) {
              edges {
                node {
                  Id
                  Name { value }
                  FolderName { value }
                  UiType { value }
                  HtmlValue { value }
                }
              }
            }
          }
        }
      }
    `,
    })
    graphqlQueryResult({data, errors}) {
        if (data) {
            // this.results = data.uiapi.query.EmailTemplate.edges.map((edge) => edge.node);
            this.EmailTemplateOptions = data.uiapi.query.EmailTemplate.edges.map((edge) => ({
                    value: edge.node.Id,
                    label: edge.node.Name.value,
                    HtmlValue: edge.node.HtmlValue.value,
                })
            );
            this.errors = errors;
        }
    }

}