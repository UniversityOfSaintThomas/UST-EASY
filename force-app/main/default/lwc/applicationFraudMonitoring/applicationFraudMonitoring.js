import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

import FRAUD_REVIEW_STATUS_FIELD from '@salesforce/schema/Application__c.Fraud_Review_Status__c';
import SHARED_IP_WARNING_FIELD from '@salesforce/schema/Application__c.Shared_IP_Warning__c';
import SHARED_IP_COUNT_FIELD from '@salesforce/schema/Application__c.Shared_IP_User_Count_30Day__c';
import LOCATION_MATCH_WARNING_FIELD from '@salesforce/schema/Application__c.IP_Location_Match_Warning__c';
import LOCATION_MATCH_DETAILS_FIELD from '@salesforce/schema/Application__c.IP_Location_Match_Details__c';

const APPLICATION_FIELDS = [
    FRAUD_REVIEW_STATUS_FIELD,
    SHARED_IP_WARNING_FIELD,
    SHARED_IP_COUNT_FIELD,
    LOCATION_MATCH_WARNING_FIELD,
    LOCATION_MATCH_DETAILS_FIELD
];

const APPLICATION_LOGIN_COLUMNS = [
    { label: 'Event Type', fieldName: 'eventType', type: 'text' },
    { label: 'Date/Time', fieldName: 'createdDate', type: 'date', typeAttributes: { year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' } },
    { label: 'reCAPTCHA Score', fieldName: 'recaptchaScore', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'reCAPTCHA Status', fieldName: 'recaptchaStatus', type: 'text' },
    { label: 'IP Address', fieldName: 'ipAddress', type: 'text' },
    { label: 'Geolocation', fieldName: 'geolocation', type: 'text' },
    { label: 'Browser', fieldName: 'browser', type: 'text' },
    { label: 'OS', fieldName: 'operatingSystem', type: 'text' },
    { label: 'Device', fieldName: 'deviceType', type: 'text' }
];

/**
 * Fraud monitoring summary card for the Application__c record page (ECRMSF-5511 / ECRMSF-5529,
 * task 12). Surfaces the Apex/Flow-computed fraud signals (Shared IP Warning, Location Match
 * Warning, current Fraud Review Status) and a quick-view table of related Application_Login__c
 * audit records for the application. This component is display-only - it never blocks or denies
 * an application; all fraud signals here are monitoring/staff-review guidance only, per the
 * feature's core design contract. See docs/fraud-monitoring-recaptcha-ip-geo.md.
 */
export default class ApplicationFraudMonitoring extends LightningElement {
    /** @type {string} The Id of the Application__c record this component is placed on. */
    @api recordId;

    /** @type {object} Wire service state for the Application__c fraud fields. */
    application;

    /** @type {object} Wire service state for the related Application_Login__c records. */
    applicationLogins;

    applicationLoginColumns = APPLICATION_LOGIN_COLUMNS;

    @wire(getRecord, { recordId: '$recordId', fields: APPLICATION_FIELDS })
    wiredApplication(value) {
        this.application = value;
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Application_Logins__r',
        fields: [
            'Application_Login__c.Event_Type__c',
            'Application_Login__c.CreatedDate',
            'Application_Login__c.ReCAPTCHA_Score__c',
            'Application_Login__c.ReCAPTCHA_Score_Status__c',
            'Application_Login__c.IP_Address__c',
            'Application_Login__c.Geolocation__c',
            'Application_Login__c.Browser__c',
            'Application_Login__c.Operating_System__c',
            'Application_Login__c.Device_Type__c'
        ],
        sortBy: ['Application_Login__c.CreatedDate'],
        pageSize: 50
    })
    wiredApplicationLogins(value) {
        this.applicationLogins = value;
    }

    get isLoading() {
        return !this.application?.data && !this.application?.error;
    }

    get hasError() {
        return Boolean(this.application?.error);
    }

    get fraudReviewStatus() {
        return getFieldValue(this.application?.data, FRAUD_REVIEW_STATUS_FIELD);
    }

    get hasFraudReviewStatus() {
        return Boolean(this.fraudReviewStatus);
    }

    get sharedIpWarning() {
        return getFieldValue(this.application?.data, SHARED_IP_WARNING_FIELD) === true;
    }

    get sharedIpCount() {
        return getFieldValue(this.application?.data, SHARED_IP_COUNT_FIELD);
    }

    get sharedIpCountLabel() {
        const count = this.sharedIpCount;
        return count === null || count === undefined ? 'No data yet' : `${count} distinct applicant(s) in last 30 days`;
    }

    get locationMatchWarning() {
        return getFieldValue(this.application?.data, LOCATION_MATCH_WARNING_FIELD) === true;
    }

    get locationMatchDetails() {
        return getFieldValue(this.application?.data, LOCATION_MATCH_DETAILS_FIELD);
    }

    get hasAnyWarning() {
        return this.sharedIpWarning || this.locationMatchWarning;
    }

    get cardIconName() {
        return this.hasAnyWarning ? 'utility:warning' : 'utility:success';
    }

    get sharedIpBadgeVariant() {
        return this.sharedIpWarning ? 'warning' : 'success';
    }

    get sharedIpBadgeLabel() {
        return this.sharedIpWarning ? 'Shared IP Warning' : 'No Shared IP Warning';
    }

    get locationMatchBadgeVariant() {
        return this.locationMatchWarning ? 'warning' : 'success';
    }

    get locationMatchBadgeLabel() {
        return this.locationMatchWarning ? 'Location Mismatch' : 'Location OK';
    }

    get reviewStatusBadgeVariant() {
        return this.fraudReviewStatus === 'Confirmed Fraudulent' ? 'error' : 'inverse';
    }

    get applicationLoginRows() {
        const records = this.applicationLogins?.data?.records;
        if (!records) {
            return [];
        }
        return records.map((record) => ({
            id: record.id,
            eventType: this.getFieldStringValue(record, 'Event_Type__c'),
            createdDate: this.getFieldStringValue(record, 'CreatedDate'),
            recaptchaScore: this.getFieldNumberValue(record, 'ReCAPTCHA_Score__c'),
            recaptchaStatus: this.getFieldStringValue(record, 'ReCAPTCHA_Score_Status__c'),
            ipAddress: this.getFieldStringValue(record, 'IP_Address__c'),
            geolocation: this.getFieldStringValue(record, 'Geolocation__c'),
            browser: this.getFieldStringValue(record, 'Browser__c'),
            operatingSystem: this.getFieldStringValue(record, 'Operating_System__c'),
            deviceType: this.getFieldStringValue(record, 'Device_Type__c')
        }));
    }

    get hasApplicationLoginRows() {
        return this.applicationLoginRows.length > 0;
    }

    get applicationLoginsLoading() {
        return !this.applicationLogins?.data && !this.applicationLogins?.error;
    }

    get applicationLoginsError() {
        return Boolean(this.applicationLogins?.error);
    }

    /**
     * @description Safely extracts a field's string display value from a getRelatedListRecords
     * row, tolerating a missing field entry (e.g. field-level security hides it for this user)
     * without throwing.
     * @param {object} record A single related list record from getRelatedListRecords.
     * @param {string} fieldApiName The field's API name.
     * @return {string} The field's display value, or null if unavailable.
     */
    getFieldStringValue(record, fieldApiName) {
        return record?.fields?.[fieldApiName]?.value ?? null;
    }

    /**
     * @description Same as getFieldStringValue but coerces to a Number for numeric columns, so
     * lightning-datatable's number formatting type renders correctly rather than treating the
     * value as text.
     * @param {object} record A single related list record from getRelatedListRecords.
     * @param {string} fieldApiName The field's API name.
     * @return {number} The field's numeric value, or null if unavailable/not a number.
     */
    getFieldNumberValue(record, fieldApiName) {
        const rawValue = this.getFieldStringValue(record, fieldApiName);
        if (rawValue === null || rawValue === undefined || rawValue === '') {
            return null;
        }
        const parsed = Number(rawValue);
        return Number.isNaN(parsed) ? null : parsed;
    }
}
