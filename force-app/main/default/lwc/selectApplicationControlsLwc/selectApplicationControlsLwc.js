/**
 * Created by nguy0092 on 7/23/2025.
 * Used as a child component to add Application Control filtering.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {getFieldValue, getRecord, updateRecord} from "lightning/uiRecordApi";
import {gql, graphql} from "lightning/uiGraphQLApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class SelectApplicationControlsLwc extends LightningElement {
    @api recordId;

    @api parentRecordId;
    @api idField;
    @api applicationControlField;

    @api existingApplicationControl = "";
    @api additionalApplicationControlsInitial = "";
    @api additionalApplicationControlValues = [];
    @api LwcTitle = "";

    selectedText;

    saveDisabled = true;
    cancelDisabled = false;

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

    @wire(graphql, {
        query: gql`
          query ApplicationControls ($currentApplicationControl: String) {
            uiapi {
              query 
              {
                Application_Control__c ( where: { Active__c: { eq: true }
                                                  URL_Parameter__c: { ne: $currentApplicationControl }
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
        variables: "$variables",
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

    get variables() {
        return {
            currentApplicationControl: this.existingApplicationControl,
        }
    }

    handleSelect(event) {
        this.additionalApplicationControlValues = event.detail.value;
        this.selectedText = event.detail.value;
        this.saveDisabled = false;
    }

    resetInitialValues() {
        this.additionalApplicationControlValues = this.additionalApplicationControlsInitial?.split(";");
        this.saveDisabled = true;
    }

    saveClick() {
        const updateFields = {};
        updateFields[this.idField.fieldApiName] = this.parentRecordId;
        updateFields[this.applicationControlField.fieldApiName] = this.additionalApplicationControlValues.join(";");

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