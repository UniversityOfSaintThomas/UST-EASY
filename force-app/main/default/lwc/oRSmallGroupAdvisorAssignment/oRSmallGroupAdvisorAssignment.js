/**
 * Created by nguy0092 on 1/9/2024.
 */

import {api, LightningElement, wire} from 'lwc';
import {refreshApex} from "@salesforce/apex";
import {getFieldValue, getRecord, notifyRecordUpdateAvailable, updateRecord} from "lightning/uiRecordApi";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import eventRegistrationCriteria from "@salesforce/apex/ORSmallGroupAssignment.eventRegistrationCriteria";
import assignAppointmentTypes from "@salesforce/apex/ORSmallGroupAssignment.assignAppointmentTypes";
import recordAppointmentAssignment from "@salesforce/apex/ORSmallGroupAssignment.recordAppointmentAssignment";
import appointmentDataDisplay from "@salesforce/apex/ORSmallGroupAssignment.appointmentDataDisplay";

import assignappointmenthost from "@salesforce/apex/ORRegistrationAdvisorAssignment.assignAppointmentHost";
import instancehostassigncheck from "@salesforce/apex/ORRegistrationAdvisorAssignment.instanceHostAssignCheck";

import ID_FIELD from "@salesforce/schema/summit__Summit_Events_Instance__c.Id";
import REGISTRATION_TERM from "@salesforce/schema/summit__Summit_Events_Instance__c.summit__Event__r.O_R_SGA_Term__c";
import SCHOLARSHIP_ID from "@salesforce/schema/summit__Summit_Events_Instance__c.summit__Event__r.O_R_SGA_Scholarship__c";
import ASSIGNED_DATE from "@salesforce/schema/summit__Summit_Events_Instance__c.O_R_SGA_Assignment_Date__c";
import HOST_ASSIGNED_DATE from "@salesforce/schema/summit__Summit_Events_Instance__c.O_R_Advisor_Assignment_Date__c";

const APPOINTMENTSFIELDS = [REGISTRATION_TERM,
                                                            SCHOLARSHIP_ID,
                                                            ASSIGNED_DATE,
                                                            HOST_ASSIGNED_DATE];

const APPOINTMENTSDATACOLUMNS = [
    {label: 'Group', fieldName: 'Appointment_Id', initialWidth: 110},
    {label: 'Student', fieldName: 'Contact_Name', initialWidth: 150},
    // {label: 'SoC', fieldName: 'Student_of_Color', type: 'boolean', initialWidth: 50},
    {label: 'FirstGen', fieldName: 'First_Gen_Student', type: 'boolean', initialWidth: 50},
    {label: 'Athlete', fieldName: 'Athlete', type: 'boolean', initialWidth: 75},
    {label: 'Housing', fieldName: 'Housing_Exception', type: 'boolean', initialWidth: 75},
    {label: 'Out State', fieldName: 'Outside_of_Minnesota', type: 'boolean', initialWidth: 75}
];

export default class oRSmallGroupAdvisorAssignment extends LightningElement {

    appointmentsIsAssigning = false;
    appointmentsGridIsSelected = false;
    appointmentsDataToggle = false;
    appointmentsDataColumns = APPOINTMENTSDATACOLUMNS;
    appointmentsData;
    appointmentsDataRefresh;
    appointmentsDataError;

    hostIsAssigning = false;
    hostAssignCheck = false;
    hostAssignDate;
    hostAssignDateRefresh;
    hostAssignDateError;

    wiredRecordData;
    assignedDate;
    registrationTerm;
    scholarshipId;
    hostAssignedDate
    currentDate = new Date().toISOString().slice(0, 10);

    @api recordId;

    @wire(getRecord, {recordId: '$recordId', fields: APPOINTMENTSFIELDS})
    wiredRecord(result) {
        refreshApex(this.appointmentsDataRefresh);

        if (result.data) {

            this.wiredRecordData = result.data;

            this.registrationTerm = getFieldValue(this.wiredRecordData, REGISTRATION_TERM);
            this.scholarshipId = getFieldValue(this.wiredRecordData, SCHOLARSHIP_ID);
            this.assignedDate = getFieldValue(this.wiredRecordData, ASSIGNED_DATE);
            this.hostAssignedDate = getFieldValue(this.wiredRecordData, HOST_ASSIGNED_DATE);
        }
    }

    @wire(appointmentDataDisplay, {eventInstance: '$recordId'})
    appointments(result) {
        this.appointmentsDataRefresh = result;

        if (result.data) {

            this.appointmentsData = JSON.parse(JSON.stringify(result.data))

            for (let i = 0; i < this.appointmentsData.length; i++) {

                this.appointmentsData[i]._children = this.appointmentsData[i]["Appointment_Information"];
            }

            this.appointmentsDataToggle = this.appointmentsData.length;

        } else if (result.error) {

            this.appointmentsDataError = result.error;
            this.appointmentsData = undefined;
        }
    }

    @wire(instancehostassigncheck, {eventInstance: '$recordId'})
    hostCheck(result) {
        this.hostAssignDateRefresh = result;

        if (result.data) {

            this.hostAssignDate = JSON.parse(JSON.stringify(result.data))

            this.hostAssignCheck = this.hostAssignDate.length;

        } else if (result.error) {

            this.hostAssignDateError = result.error;
            this.hostAssignDate = undefined;
        }
    }

    async buttonClickGroups(event) {
        const updateFields = {};
        updateFields[ID_FIELD.fieldApiName] = this.recordId;
        updateFields[ASSIGNED_DATE.fieldApiName] = this.currentDate;
        const recordUpdate = {
            fields: updateFields
        }

        try {
            this.appointmentsIsAssigning = true;
            await eventRegistrationCriteria({eventInstance: this.recordId, registrationTerm: this.registrationTerm, scholarshipId: this.scholarshipId});
            await assignAppointmentTypes({eventInstance: this.recordId});
            await recordAppointmentAssignment({eventInstance: this.recordId}).then(result => {
                console.log("This result: "+result.length);
                let toastTitle;
                let toastMessage;
                let toastVariant;

                if (result.length > 0) {
                    toastTitle = 'Success';
                    toastMessage = 'Small Groups assigned!';
                    toastVariant = 'success'

                    updateRecord(recordUpdate);
                } else {
                    toastTitle = 'Warning';
                    toastMessage = 'No Small Groups assigned.';
                    toastVariant = 'warning'
                }

                this.appointmentsIsAssigning = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: toastTitle,
                        message: toastMessage,
                        variant: toastVariant
                    })
                );
            });

        } catch (error) {
            this.appointmentsIsAssigning = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error assigning Small Groups!',
                    message: '',
                    variant: 'error'
                })
            );
        }

        await refreshApex(this.appointmentsDataRefresh);
    }

    async buttonClickAdvisors(event) {

        try {
            this.hostIsAssigning = true;
            await assignappointmenthost({eventInstance: this.recordId});
            await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
            await refreshApex(this.hostAssignDateRefresh);
            this.hostIsAssigning = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Registration Advisors assigned!',
                    variant: 'success'
                })
            );
        } catch (error) {
            this.hostIsAssigning = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error assigning Registration Advisors!',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    refreshList(event) {
        refreshApex(this.appointmentsDataRefresh);
    }

    expandCollapse(event) {
        const grid = this.template.querySelector('lightning-tree-grid');

        if (this.appointmentsGridIsSelected) {

            try {
                grid.collapseAll();
            } catch (error) {
            }

        } else {

            try {
                grid.expandAll();
            } catch (error) {
            }
        }

        this.appointmentsGridIsSelected = !this.appointmentsGridIsSelected;
    }

}