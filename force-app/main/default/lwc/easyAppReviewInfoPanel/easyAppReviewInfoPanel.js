/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */

import {LightningElement, wire, track, api} from 'lwc';
import {getSObjectValue} from '@salesforce/apex';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningAlert from "lightning/alert";

import getApplicantInfo from '@salesforce/apex/EASYAppReviewController.getApplicantInfo';
import FIRST_NAME from '@salesforce/schema/Application__c.Contact__r.FirstName';
import LAST_NAME from '@salesforce/schema/Application__c.Contact__r.LastName';

import {MessageContext, publish, subscribe} from 'lightning/messageService';
import APP_SELECTED_CHANNEL from '@salesforce/messageChannel/EASY_App_Selected__c';
import {CurrentPageReference} from "lightning/navigation";
import {adjustURLParams, setAppIdFromURL} from 'c/easyAppReviewUtility';

import getAppInfoDetails from '@salesforce/apex/EASYAppInfoController.upsertAppReviewData';

import RECORDTYPEID from '@salesforce/schema/Application_Review__c.RecordTypeId';
import CONTACT_NAME from '@salesforce/schema/Application_Review__c.Contact_Name__c';
import FIRST_GENERATION from '@salesforce/schema/Application_Review__c.First_Generation__c';
import MOBILE from '@salesforce/schema/Application_Review__c.Mobile__c';
import COACHES_LIST from '@salesforce/schema/Application_Review__c.Coaches_List__c';
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

export default class EasyAppReviewInfoPanel extends LightningElement {

    @track allSections = ['STUDENT_INFORMATION',
        'APPLICATION_DETAILS',
        'ACADEMIC_INFORMATION',
        'TEST_SCORES',
        'TRANSCRIPT_REVIEW',
        'ESSAY_REVIEW',
        'INVOLVEMENT',
        'REVIEW_RECOMMENDATION'];

    @track testsSections = ['ACT',
        'SAT']

    @track activeSections = [];

    recordtypeid = RECORDTYPEID;
    contactName= CONTACT_NAME;
    firstGeneration= FIRST_GENERATION;
    mobile= MOBILE;
    coachesList= COACHES_LIST;
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
    overallHighestActScienceReasoning= OVERALL_HIGHEST_ACT_SCIENCE_REASONING
    overallHighestSatMath= OVERALL_HIGHEST_SAT_MATH;
    overallHighestSatReading= OVERALL_HIGHEST_SAT_READING;
    overallHighestSatWriting= OVERALL_HIGHEST_SAT_WRITING;
    transcriptReivew= TRANSCRIPT_REIVEW;
    transcriptNotes= TRANSCRIPT_NOTES;
    highestLevelMathCompleteTesting= HIGHEST_LEVEL_MATH_COMPLETE_TESTING;
    gradeTrend= GRADE_TREND;
    englishProgression= ENGLISH_PROGRESSION;
    mathProgression= MATH_PROGRESSION;
    honorsCourses= HONORS_COURSES;
    apCourses= AP_COURSES;
    ibCourses= IB_COURSES;
    pseoCourses= PSEO_COURSES;
    cisPltw= CIS_PLTW;
    ellCourses= ELL_COURSES;
    developmentalCourses= DEVELOPMENTAL_COURSES;
    essayReview= ESSAY_REVIEW;
    essayNotes= ESSAY_NOTES;
    writingStyle= WRITING_STYLE;
    writingStory= WRITING_STORY;
    studentInvolvement= STUDENT_INVOLVEMENT;
    counselorRecommendation= COUNSELOR_RECOMMENDATION;
    initialCounselorReview= INITIAL_COUNSELOR_REVIEW;
    counselorDecisionNotes= COUNSELOR_DECISION_NOTES;
    committeeDecision= COMMITTEE_DECISION;
    initialCommitteeReview= INITIAL_COMMITTEE_REVIEW;
    committeeDecisionNotes= COMMITTEE_DECISION_NOTES;
    completed= COMPLETED;
    terminated= TERMINATED;
    startDate= START_DATE;
    dueDate= DUE_DATE;
    dateCompleted= DATE_COMPLETED;

    appId;
    appReviewId;
    appReviewRecordId;
    onLoadRecord;
    onLoadFields;
    isDisabled = true;
    activeAllSections = false;
    openSections = [];

    connectedCallback() {
        this.lmsSubscription();

        getAppInfoDetails({appId: this.appId}).then((value)=>{

            this.appReviewId = value.Id;
            this.appReviewRecordId = value.RecordTypeId;
        })

        this.activeSections = ['STUDENT_INFORMATION'];
    }

    renderedCallback() {
        this.enableUpdate();
    }

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    currentPageReference;

    @wire(getApplicantInfo, {appId: "$appId"})
    applicantInfo;

    get firstname() {
        return this.applicantInfo.data
            ? getSObjectValue(this.applicantInfo.data, FIRST_NAME) : '';
    }

    get lastname() {
        return this.applicantInfo.data
            ? getSObjectValue(this.applicantInfo.data, LAST_NAME) : '';
    }

    inputValueChange(event) {
        const payload = {appId: event.detail.value};
        publish(this.messageContext, APP_SELECTED_CHANNEL, payload);

        getAppInfoDetails({appId: this.appId}).then(returnValue => {
            this.appReviewId = returnValue;
        });
    }

    lmsSubscription() {
        subscribe(this.messageContext, APP_SELECTED_CHANNEL, (message) => {
            this.appId = message.appId;
            adjustURLParams('c__appId', this.appId);
        });

        setAppIdFromURL(this.messageContext, APP_SELECTED_CHANNEL, this.currentPageReference, this.appId);
    }

    enableUpdate() {
        let inputFields = this.template.querySelectorAll('lightning-input-field');

        if (inputFields) {

            if (inputFields.length > 0) {

                inputFields.forEach(field => {

                    field.addEventListener('change', (evt) => {

                        if (field.value !== this.onLoadFields[field.fieldName].value) {

                            let accordionSection;
                            let sectionWarning;

                            accordionSection = field.closest(".accordionSection");

                            if (accordionSection) {

                                sectionWarning = accordionSection.querySelector(".sectionSaveWarning");
                            }

                            if (sectionWarning) {

                                sectionWarning.style.display = "block";
                            }

                            evt.target.classList.add("fieldBorderWarning");
                            this.isDisabled = false;
                            window.addEventListener("beforeunload", this.beforeUnloadHandler);
                        } else {

                            window.removeEventListener("beforeunload", this.beforeUnloadHandler);
                        }
                    });
                });
            }
        }
    }

    onloadHandler(evt){

        this.onLoadRecord = evt.detail.records;
        this.onLoadFields = this.onLoadRecord[this.appReviewId].fields;
    }

    beforeUnloadHandler = (evt) => {

        evt.preventDefault();
        evt.returnValue = true;
    };

    cancelReset(event) {
        let inputFields = this.template.querySelectorAll('lightning-input-field');

        if (inputFields) {

            inputFields.forEach(field => {

                field.reset();
            });
        }

        this.clearSaveWarnings();
        this.isDisabled = true;
    }

    updateSuccess(){
        const evt = new ShowToastEvent({
            title: 'Application Review Update Success',
            message: '',
            variant: 'success',
        });

        this.dispatchEvent(evt);
        this.clearSaveWarnings();
        this.isDisabled = true;
        window.removeEventListener("beforeunload", this.beforeUnloadHandler);
    }

    clearSaveWarnings() {
        let sectionWarningText = this.template.querySelectorAll(".sectionSaveWarning");
        let fieldWarningBorder = this.template.querySelectorAll(".fieldBorderWarning");

        if (sectionWarningText) {

            sectionWarningText.forEach(field => {

                field.style.display = "none";
            })
        }

        if (fieldWarningBorder) {

            fieldWarningBorder.forEach(field => {

                field.classList.remove("fieldBorderWarning")
            })
        }
    }

    handleSectionToggle(evt) {
        this.openSections = evt.detail.openSections;

        let sectionButton = this.template.querySelectorAll('.sectionButtonsSelect, .sectionButtons');

        if (this.openSections) {

            if (sectionButton) {

                sectionButton.forEach(button => {

                    if (this.openSections.includes(button.name)) {

                        button.classList.remove("sectionButtons");
                        button.classList.add("sectionButtonsSelect");
                    } else {

                        button.classList.remove("sectionButtonsSelect");
                        button.classList.add("sectionButtons");
                    }
                });
            }
        } else {
            sectionButton.forEach(button => {

                button.classList.remove("sectionButtonsSelect");
                button.classList.add("sectionButtons");
            });
        }
    }

    closeAll(evt){
        this.activeSections = [];
    }

    expandAll(evt) {
        this.activeSections = this.allSections;
        this.activeAllSections = true;
    }

    sectionButtonsClick(evt) {
        let section = evt.target.name;

        if (!this.activeAllSections) {

            let idx = this.openSections.indexOf(section);

            if (idx === -1) {

                this.openSections.push(section);
                this.activeSections = this.openSections;
            } else {

                this.activeSections = this.openSections.toSpliced(idx, 1);
            }
        } else {

            this.activeSections = [section];
            this.activeAllSections = false;
        }
    }

}