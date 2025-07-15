/**
 * Created by nguy0092 on 7/14/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {getFieldValue, getRecord, updateRecord} from "lightning/uiRecordApi";
import {gql, graphql} from "lightning/uiGraphQLApi";
import ID_FIELD from "@salesforce/schema/EASY_Widget__c.Id";
import ADDITIONAL_APPLICATION_CONTROLS from "@salesforce/schema/EASY_Widget__c.Additional_Application_Controls__c";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

const FIELDS = [
    ADDITIONAL_APPLICATION_CONTROLS,
];

export default class EasyWidgetAdditionalAppControlsLwc extends LightningElement {
    @api recordId;

    selectedText;

    saveDisabled = true;
    cancelDisabled = false;
    widgetData;
    additionalApplicationControlsInitial;
    @track additionalApplicationControlValues = []
    @track applicationControlOptions = [];

    get availableLabel() {
        return "Available ("+(!!this.applicationControlOptions?.length ? this.applicationControlOptions.length : 0) + ")";
    }
    get selectedLabel() {
        let controlsValueFound = 0;
        this.additionalApplicationControlValues?.forEach((controlValue) => {
            this.applicationControlOptions?.forEach((controlOption) => {
                if (controlValue === controlOption.value) {
                    controlsValueFound++;
                }
            })
        })
        return "Chosen ("+ controlsValueFound + ")";
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    widgetRecord(results) {
        if (results.data) {
            this.widgetData = results.data;
            this.additionalApplicationControlsInitial = getFieldValue(this.widgetData, ADDITIONAL_APPLICATION_CONTROLS);
            this.additionalApplicationControlValues = this.additionalApplicationControlsInitial?.split(",");
        }
        if (results.error) {
            console.log("widgetRecord error: "+results.error);
        }
    }

    @wire(graphql, {
        query: gql`
          query ApplicationControls {
            uiapi {
              query 
              {
                Application_Control__c ( where: { Active__c: { eq: true }
                                                },
                                         orderBy: { Name: { order: ASC }
                                                  }
                                         upperBound: 5000
                                       ) 
                {
                  edges {
                    node {
                      Id                   
                      Name {value}
                      URL_Parameter__c {value}
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
            this.applicationControlOptions = data.uiapi.query.Application_Control__c.edges.map((edge) => ({
                label: edge.node.Name.value,
                value: edge.node.URL_Parameter__c.value,
            }));
        }
        this.errors = errors;
    }

    handleSelect(event) {
        this.additionalApplicationControlValues = event.detail.value;
        this.selectedText = event.detail.value;
        this.saveDisabled = false;
    }

    resetInitialValues() {
        this.additionalApplicationControlValues = this.additionalApplicationControlsInitial?.split(",");
        this.saveDisabled = true;
    }

    saveClick() {
        const updateFields = {};
        updateFields[ID_FIELD.fieldApiName] = this.recordId;
        updateFields[ADDITIONAL_APPLICATION_CONTROLS.fieldApiName] = this.additionalApplicationControlValues.toString();

        const recordUpdate = {
            fields: updateFields
        }

        updateRecord(recordUpdate).then((record) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Additional Application Controls Updated",
                    variant: "success",
                }),
            );
        })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: "error",
                    }),
                );
            });

        this.saveDisabled = true;
    }
}