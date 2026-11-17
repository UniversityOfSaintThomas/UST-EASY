/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 *
 * Application Review: the form where a reviewer enters notes, ratings and decisions on the selected application's
 * review record. The read-only application facts live in easyAppReviewInfoPanel.
 */

import {LightningElement, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {MessageContext, subscribe, unsubscribe} from 'lightning/messageService';
import APP_SELECTED_CHANNEL from '@salesforce/messageChannel/EASY_App_Selected__c';
import {CurrentPageReference} from 'lightning/navigation';
import {adjustURLParams, ensureReviewRecord, setAppIdFromURL, showErrorToast} from 'c/easyAppReviewUtility';

import COACHES_LIST from '@salesforce/schema/Application_Review__c.Coaches_List__c';
import TRANSCRIPT_REIVEW from '@salesforce/schema/Application_Review__c.Transcript_Reivew__c';
import TRANSCRIPT_NOTES from '@salesforce/schema/Application_Review__c.Transcript_Notes__c';
import HIGHEST_LEVEL_MATH_COMPLETE_TESTING from '@salesforce/schema/Application_Review__c.Highest_Level_Math_Complete_Testing__c';
import GRADE_TREND from '@salesforce/schema/Application_Review__c.Grade_Trend__c';
import ENGLISH_PROGRESSION from '@salesforce/schema/Application_Review__c.English_Progression__c';
import MATH_PROGRESSION from '@salesforce/schema/Application_Review__c.Math_Progression__c';
import HONORS_COURSES from '@salesforce/schema/Application_Review__c.Honors_Courses__c';
import AP_COURSES from '@salesforce/schema/Application_Review__c.AP_Courses__c';
import IB_COURSES from '@salesforce/schema/Application_Review__c.IB_Courses__c';
import PSEO_COURSES from '@salesforce/schema/Application_Review__c.PSEO_Courses__c';
import CIS_PLTW from '@salesforce/schema/Application_Review__c.CIS_PLTW__c';
import ELL_COURSES from '@salesforce/schema/Application_Review__c.ELL_Courses__c';
import DEVELOPMENTAL_COURSES from '@salesforce/schema/Application_Review__c.Developmental_Courses__c';
import ESSAY_REVIEW from '@salesforce/schema/Application_Review__c.Essay_Review__c';
import ESSAY_NOTES from '@salesforce/schema/Application_Review__c.Essay_Notes__c';
import WRITING_STYLE from '@salesforce/schema/Application_Review__c.Writing_Style__c';
import WRITING_STORY from '@salesforce/schema/Application_Review__c.Writing_Story__c';
import STUDENT_INVOLVEMENT from '@salesforce/schema/Application_Review__c.Student_Involvement__c';
import COUNSELOR_RECOMMENDATION from '@salesforce/schema/Application_Review__c.Counselor_Recommendation__c';
import INITIAL_COUNSELOR_REVIEW from '@salesforce/schema/Application_Review__c.Initial_Counselor_Review__c';
import COUNSELOR_DECISION_NOTES from '@salesforce/schema/Application_Review__c.Counselor_Decision_Notes__c';
import COMMITTEE_DECISION from '@salesforce/schema/Application_Review__c.Committee_Decision__c';
import INITIAL_COMMITTEE_REVIEW from '@salesforce/schema/Application_Review__c.Initial_Committee_Review__c';
import COMMITTEE_DECISION_NOTES from '@salesforce/schema/Application_Review__c.Committee_Decision_Notes__c';
import COMPLETED from '@salesforce/schema/Application_Review__c.Completed__c';
import TERMINATED from '@salesforce/schema/Application_Review__c.Terminated__c';
import START_DATE from '@salesforce/schema/Application_Review__c.Start_Date__c';
import DUE_DATE from '@salesforce/schema/Application_Review__c.Due_Date__c';
import DATE_COMPLETED from '@salesforce/schema/Application_Review__c.Date_Completed__c';

const SECTIONS = [
    {name: 'COACHES', label: 'Coaches'},
    {name: 'TRANSCRIPT_REVIEW', label: 'Transcript Review'},
    {name: 'ESSAY_REVIEW', label: 'Essay Review'},
    {name: 'INVOLVEMENT', label: 'Involvement'},
    {name: 'REVIEW_RECOMMENDATION', label: 'Review Recommendation'}
];
const ALL_SECTION_NAMES = SECTIONS.map(section => section.name);

export default class EasyAppReviewForm extends LightningElement {

    progressSteps = [
        {label: 'Counselor Review', value: 'step-1'},
        {label: 'Committee Decision', value: 'step-2'},
        {label: 'Complete', value: 'step-3'},
    ];

    coachesList = COACHES_LIST;
    transcriptReivew = TRANSCRIPT_REIVEW;
    transcriptNotes = TRANSCRIPT_NOTES;
    highestLevelMathCompleteTesting = HIGHEST_LEVEL_MATH_COMPLETE_TESTING;
    gradeTrend = GRADE_TREND;
    englishProgression = ENGLISH_PROGRESSION;
    mathProgression = MATH_PROGRESSION;
    honorsCourses = HONORS_COURSES;
    apCourses = AP_COURSES;
    ibCourses = IB_COURSES;
    pseoCourses = PSEO_COURSES;
    cisPltw = CIS_PLTW;
    ellCourses = ELL_COURSES;
    developmentalCourses = DEVELOPMENTAL_COURSES;
    essayReview = ESSAY_REVIEW;
    essayNotes = ESSAY_NOTES;
    writingStyle = WRITING_STYLE;
    writingStory = WRITING_STORY;
    studentInvolvement = STUDENT_INVOLVEMENT;
    counselorRecommendation = COUNSELOR_RECOMMENDATION;
    initialCounselorReview = INITIAL_COUNSELOR_REVIEW;
    counselorDecisionNotes = COUNSELOR_DECISION_NOTES;
    committeeDecision = COMMITTEE_DECISION;
    initialCommitteeReview = INITIAL_COMMITTEE_REVIEW;
    committeeDecisionNotes = COMMITTEE_DECISION_NOTES;
    completed = COMPLETED;
    terminated = TERMINATED;
    startDate = START_DATE;
    dueDate = DUE_DATE;
    dateCompleted = DATE_COMPLETED;

    appId;
    appReviewId;
    onLoadRecord;
    onLoadFields;
    isDisabled = true;
    isLoading = false;
    activeSections = [];
    subscription;
    _beforeUnloadRegistered = false; // Guard against double-registering the same listener

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        this.lmsSubscription();
    }

    disconnectedCallback() {
        this._removeBeforeUnloadListener();
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    lmsSubscription() {
        this.subscription = subscribe(this.messageContext, APP_SELECTED_CHANNEL, (message) => {
            const requestedAppId = message.appId;
            this.appId = requestedAppId;
            // Unmount the edit form immediately so it remounts cleanly with the new record id instead of
            // swapping record-id while it is mounted.
            this.appReviewId = null;
            this.isLoading = true;
            adjustURLParams('c__appId', requestedAppId);
            ensureReviewRecord(requestedAppId).then(returnValue => {
                if (requestedAppId !== this.appId) {
                    return; // a newer selection has replaced this one
                }
                this.appReviewId = returnValue.Id;
                this.isLoading = false;
            }).catch(error => {
                if (requestedAppId === this.appId) {
                    this.isLoading = false;
                }
                showErrorToast(this, 'Error loading the review form', error);
            });
        });

        setAppIdFromURL(this.messageContext, APP_SELECTED_CHANNEL, this.currentPageReference, this.appId);
    }

    onloadHandler(evt) {
        this.onLoadRecord = evt.detail.records;
        // Guard: appReviewId may be null if the form is in new-record mode
        if (this.appReviewId && this.onLoadRecord[this.appReviewId]) {
            this.onLoadFields = this.onLoadRecord[this.appReviewId].fields;
        }
    }

    // Bound declaratively via onchange on every lightning-input-field in the template.
    handleFieldChange(evt) {
        const field = evt.target;
        // Guard: onLoadFields may not contain this field if form is in create mode
        const originalValue = this.onLoadFields?.[field.fieldName]?.value;
        if (field.value !== originalValue) {
            const accordionSection = field.closest('.accordionSection');
            const sectionWarning = accordionSection?.querySelector('.sectionSaveWarning');
            if (sectionWarning) {
                sectionWarning.style.display = 'block';
            }
            field.classList.add('fieldBorderWarning');
            this.isDisabled = false;
            this._addBeforeUnloadListener();
        } else {
            this._removeBeforeUnloadListener();
        }
    }

    beforeUnloadHandler = (evt) => {
        evt.preventDefault();
        evt.returnValue = true;
    };

    _addBeforeUnloadListener() {
        if (!this._beforeUnloadRegistered) {
            window.addEventListener('beforeunload', this.beforeUnloadHandler);
            this._beforeUnloadRegistered = true;
        }
    }

    _removeBeforeUnloadListener() {
        if (this._beforeUnloadRegistered) {
            window.removeEventListener('beforeunload', this.beforeUnloadHandler);
            this._beforeUnloadRegistered = false;
        }
    }

    cancelReset() {
        this.template.querySelectorAll('lightning-input-field').forEach(field => {
            field.reset();
        });
        this.clearSaveWarnings();
        this.isDisabled = true;
        this._removeBeforeUnloadListener();
    }

    updateSuccess() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Application Review Update Success',
            message: '',
            variant: 'success',
        }));
        this.clearSaveWarnings();
        this.isDisabled = true;
        this._removeBeforeUnloadListener();
    }

    clearSaveWarnings() {
        this.template.querySelectorAll('.sectionSaveWarning').forEach(warning => {
            warning.style.display = 'none';
        });
        this.template.querySelectorAll('.fieldBorderWarning').forEach(field => {
            field.classList.remove('fieldBorderWarning');
        });
    }

    get sectionButtons() {
        return SECTIONS.map(section => {
            const isOpen = this.activeSections.includes(section.name);
            return {
                ...section,
                pressed: String(isOpen),
                className: 'slds-button slds-p-horizontal_x-small slds-m-around_xx-small '
                    + (isOpen ? 'sectionButtonsSelect' : 'sectionButtons')
            };
        });
    }

    handleSectionToggle(event) {
        this.activeSections = [...event.detail.openSections];
    }

    closeAll() {
        this.activeSections = [];
    }

    expandAll() {
        this.activeSections = [...ALL_SECTION_NAMES];
    }

    sectionButtonsClick(event) {
        const section = event.currentTarget.name;
        if (this.activeSections.length === ALL_SECTION_NAMES.length) {
            // everything is open: a section button shows just that section
            this.activeSections = [section];
        } else if (this.activeSections.includes(section)) {
            this.activeSections = this.activeSections.filter(name => name !== section);
        } else {
            this.activeSections = [...this.activeSections, section];
        }
    }
}