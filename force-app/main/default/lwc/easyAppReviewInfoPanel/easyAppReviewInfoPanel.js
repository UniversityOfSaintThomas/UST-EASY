/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 *
 * Application Information: the read-only facts about the selected application (student, application, academics,
 * test scores). Reviewer input lives in easyAppReviewForm.
 */

import {LightningElement, wire} from 'lwc';
import {MessageContext, subscribe, unsubscribe} from 'lightning/messageService';
import APP_SELECTED_CHANNEL from '@salesforce/messageChannel/EASY_App_Selected__c';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import {adjustURLParams, ensureReviewRecord, setAppIdFromURL, showErrorToast} from 'c/easyAppReviewUtility';

import getApplicantInfo from '@salesforce/apex/EASYAppReviewController.getApplicantInfo';
import getSummarySections from '@salesforce/apex/EASYAppInfoController.getSummarySections';

import RECORDTYPEID from '@salesforce/schema/Application_Review__c.RecordTypeId';
import CONTACT_NAME from '@salesforce/schema/Application_Review__c.Contact_Name__c';
import FIRST_GENERATION from '@salesforce/schema/Application_Review__c.First_Generation__c';
import MOBILE from '@salesforce/schema/Application_Review__c.Mobile__c';
import EMAIL from '@salesforce/schema/Application_Review__c.Email__c';
import CITY_STATE from '@salesforce/schema/Application_Review__c.City_State__c';
import TEST_SCORE_PREFERENCE from '@salesforce/schema/Application_Review__c.Test_Score_Preference__c';
import APPLICATION from '@salesforce/schema/Application_Review__c.Application__c';
import APPLICATION_ADMISSION_PLAN from '@salesforce/schema/Application_Review__c.Application_Admission_Plan__c';
import APPLICATION_ADMISSION_STATUS from '@salesforce/schema/Application_Review__c.Application_Admission_Status__c';
import APPLICATION_START_TERM from '@salesforce/schema/Application_Review__c.Application_Start_Term__c';
import APPLICATION_TERM_START_DATE from '@salesforce/schema/Application_Review__c.Application_Term_Start_Date__c';
import APPLICATION_ADMISSIONS_SUBSTATUS from '@salesforce/schema/Application_Review__c.Application_Admissions_Substatus__c';
import HIGH_SCHOOL from '@salesforce/schema/Application_Review__c.High_School__c';
import HIGH_SCHOOL_GPA from '@salesforce/schema/Application_Review__c.High_School_GPA__c';
import PRIMARY_HIGH_SCHOOL_RANK from '@salesforce/schema/Application_Review__c.Primary_High_School_Rank__c';
import PRIMARY_HS_GRADUATION_DATE from '@salesforce/schema/Application_Review__c.Primary_HS_Graduation_Date__c';
import TEST_SCORES_BELOW_MINIMUM from '@salesforce/schema/Application_Review__c.Test_Scores_Below_Minimum__c';
import ACT_SAT_MAX_COMPOSITE_SCORE from '@salesforce/schema/Application_Review__c.ACT_SAT_Max_Composite_Score__c';
import TIMES_TAKEN_ACT_SAT from '@salesforce/schema/Application_Review__c.Times_Taken_ACT_SAT__c';
import FUTURE_TEST_DATE_1 from '@salesforce/schema/Application_Review__c.Future_Test_Date_1__c';
import OVERALL_HIGHEST_ACT_ENGLISH from '@salesforce/schema/Application_Review__c.Overall_Highest_ACT_English__c';
import OVERALL_HIGHEST_ACT_MATH from '@salesforce/schema/Application_Review__c.Overall_Highest_ACT_Math__c';
import OVERALL_HIGHEST_ACT_READING from '@salesforce/schema/Application_Review__c.Overall_Highest_ACT_Reading__c';
import OVERALL_HIGHEST_ACT_SCIENCE_REASONING from '@salesforce/schema/Application_Review__c.Overall_Highest_ACT_Science_Reasoning__c';
import OVERALL_HIGHEST_SAT_MATH from '@salesforce/schema/Application_Review__c.Overall_Highest_SAT_Math__c';
import OVERALL_HIGHEST_SAT_READING from '@salesforce/schema/Application_Review__c.Overall_Highest_SAT_Reading__c';
import OVERALL_HIGHEST_SAT_WRITING from '@salesforce/schema/Application_Review__c.Overall_Highest_SAT_Writing__c';

// The sections this panel can show. Which of them appear is chosen per Application Control (Review Summary
// Sections). Every section that is shown starts open; the reader can close any of them, and the panel keeps their choice.
const SECTION_NAMES = ['STUDENT_INFORMATION', 'APPLICATION_DETAILS', 'ACADEMIC_INFORMATION', 'TEST_SCORES'];

export default class EasyAppReviewInfoPanel extends NavigationMixin(LightningElement) {

    recordTypeId = RECORDTYPEID;
    contactName= CONTACT_NAME;
    firstGeneration= FIRST_GENERATION;
    mobile= MOBILE;
    email= EMAIL;
    cityState= CITY_STATE;
    testScorePreference= TEST_SCORE_PREFERENCE;
    application= APPLICATION;
    applicationAdmissionPlan= APPLICATION_ADMISSION_PLAN;
    applicationAdmissionStatus= APPLICATION_ADMISSION_STATUS;
    applicationStartTerm= APPLICATION_START_TERM;
    applicationTermStartDate= APPLICATION_TERM_START_DATE;
    applicationAdmissionsSubstatus= APPLICATION_ADMISSIONS_SUBSTATUS;
    highSchool= HIGH_SCHOOL;
    highSchoolGpa= HIGH_SCHOOL_GPA;
    primaryHighSchoolRank= PRIMARY_HIGH_SCHOOL_RANK;
    primaryHsGraduationDate= PRIMARY_HS_GRADUATION_DATE;
    testScoresBelowMinimum= TEST_SCORES_BELOW_MINIMUM;
    actSatMaxCompositeScore= ACT_SAT_MAX_COMPOSITE_SCORE;
    timesTakenActSat= TIMES_TAKEN_ACT_SAT;
    futureTestDate1= FUTURE_TEST_DATE_1;
    overallHighestActEnglish= OVERALL_HIGHEST_ACT_ENGLISH;
    overallHighestActMath= OVERALL_HIGHEST_ACT_MATH;
    overallHighestActReading= OVERALL_HIGHEST_ACT_READING;
    overallHighestActScienceReasoning = OVERALL_HIGHEST_ACT_SCIENCE_REASONING;
    overallHighestSatMath= OVERALL_HIGHEST_SAT_MATH;
    overallHighestSatReading= OVERALL_HIGHEST_SAT_READING;
    overallHighestSatWriting= OVERALL_HIGHEST_SAT_WRITING;

    appId;
    appReviewId;
    isLoading = false;
    activeSections = [...SECTION_NAMES];
    visibleSections = [...SECTION_NAMES];
    subscription;

    // Link to the applicant's Supporting Documents (a related list on the Contact), built for the org the user is in.
    documentsUrl;

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        this.lmsSubscription();
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    @wire(getApplicantInfo, {appId: '$appId'})
    wiredApplicantInfo(result) {
        this.updateDocumentsUrl(result?.data?.Contact__c);
    }

    updateDocumentsUrl(contactId) {
        if (!contactId) {
            this.documentsUrl = null;
            return;
        }
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: contactId,
                objectApiName: 'Contact',
                relationshipApiName: 'Admissions_Documents__r',
                actionName: 'view'
            }
        }).then(url => {
            this.documentsUrl = url;
        });
    }

    lmsSubscription() {
        this.subscription = subscribe(this.messageContext, APP_SELECTED_CHANNEL, (message) => {
            const requestedAppId = message.appId;
            this.appId = requestedAppId;
            // Unmount the view form immediately so it remounts cleanly with the new record id instead of
            // swapping record-id while it is mounted.
            this.appReviewId = null;
            this.isLoading = true;
            adjustURLParams('c__appId', requestedAppId);
            Promise.all([ensureReviewRecord(requestedAppId), this.loadVisibleSections(requestedAppId)]).then(([returnValue, sections]) => {
                if (requestedAppId !== this.appId) {
                    return; // a newer selection has replaced this one
                }
                this.visibleSections = sections;
            this.appReviewId = returnValue.Id;
                this.isLoading = false;
            }).catch(error => {
                if (requestedAppId === this.appId) {
                    this.isLoading = false;
                }
                showErrorToast(this, 'Error loading application information', error);
        });
        });

        setAppIdFromURL(this.messageContext, APP_SELECTED_CHANNEL, this.currentPageReference, this.appId);
    }

    // The sections the Application Control turns on for this application. If the setting cannot be read, show
    // everything rather than hiding information the reviewer needs.
    loadVisibleSections(applicationId) {
        return getSummarySections({appId: applicationId}).catch(error => {
            showErrorToast(this, 'Could not read the summary settings, so every section is shown', error);
            return [...SECTION_NAMES];
                    });
    }

    get showStudentInformation() {
        return this.visibleSections.includes('STUDENT_INFORMATION');
    }

    get showApplicationDetails() {
        return this.visibleSections.includes('APPLICATION_DETAILS');
    }

    get showAcademicInformation() {
        return this.visibleSections.includes('ACADEMIC_INFORMATION');
    }

    get showTestScores() {
        return this.visibleSections.includes('TEST_SCORES');
    }

    get hasNoSections() {
        return !SECTION_NAMES.some(name => this.visibleSections.includes(name));
    }

    handleSectionToggle(event) {
        this.activeSections = [...event.detail.openSections];
        }
    }