/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */

import {LightningElement, wire, track, api} from 'lwc';
import {getSObjectValue} from '@salesforce/apex';

import getApplicantInfo from '@salesforce/apex/EASYAppReviewController.getApplicantInfo';
import FIRST_NAME from '@salesforce/schema/Application__c.Contact__r.FirstName';
import LAST_NAME from '@salesforce/schema/Application__c.Contact__r.LastName';

import getAppInfoDetails from '@salesforce/apex/EASYAppInfoController.upsertAppReviewData';
import displayAppInfoDetails from '@salesforce/apex/EASYAppInfoController.displayAppReviewInfo';

import TEST_SCORE_PREFERENCE from '@salesforce/schema/Application_Review__c.Test_Score_Preference__c';
import APPLICATION from '@salesforce/schema/Application_Review__c.Application__c';
import APPLICATION_ADMISSION_PLAN from '@salesforce/schema/Application_Review__c.Application_Admission_Plan__c';
import APPLICATION_ADMISSION_STATUS from '@salesforce/schema/Application_Review__c.Application_Admission_Status__c';
import APPLICATION_START_TERM from '@salesforce/schema/Application_Review__c.Application_Start_Term__c';
import APPLICATION_TERM_START_DATE from '@salesforce/schema/Application_Review__c.Application_Term_Start_Date__c';
import APPLICATION_ADMISSIONS_SUBSTATUS from '@salesforce/schema/Application_Review__c.Application_Admissions_Substatus__c';
import CONTACT_NAME from '@salesforce/schema/Application_Review__c.Contact_Name__c';
import FIRST_GENERATION from '@salesforce/schema/Application_Review__c.First_Generation__c';
import MOBILE from '@salesforce/schema/Application_Review__c.Mobile__c';
import COACHES_LIST from '@salesforce/schema/Application_Review__c.Coaches_List__c';
import EMAIL from '@salesforce/schema/Application_Review__c.Email__c';
import CITY_STATE from '@salesforce/schema/Application_Review__c.City_State__c';
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


import {MessageContext, publish, subscribe} from 'lightning/messageService';
import APP_SELECTED_CHANNEL from '@salesforce/messageChannel/EASY_App_Selected__c';
import {CurrentPageReference} from "lightning/navigation";
import {adjustURLParams, setAppIdFromURL} from 'c/easyAppReviewUtility';

export default class EasyAppReviewInfoPanel extends LightningElement {

    activeSections = ['APPLICATION_DETAILS',
                            'STUDENT_INFORMATION',
                            'ACADEMIC_INFORMATION',
                            'TEST_SCORES',
                            'ACT',
                            'SAT',
                            'TRANSCRIPT_REVIEW',
                            'ESSAY_REVIEW',
                            'INVOLVEMENT',
                            'REVIEW_RECOMMENDATION'];

    testScorePreference= TEST_SCORE_PREFERENCE;
    application= APPLICATION;
    applicationAdmissionPlan= APPLICATION_ADMISSION_PLAN;
    applicationAdmissionStatus= APPLICATION_ADMISSION_STATUS;
    applicationStartTerm= APPLICATION_START_TERM;
    applicationTermStartDate= APPLICATION_TERM_START_DATE;
    applicationAdmissionsSubstatus= APPLICATION_ADMISSIONS_SUBSTATUS;
    contactName= CONTACT_NAME;
    firstGeneration= FIRST_GENERATION;
    mobile= MOBILE;
    coachesList= COACHES_LIST;
    email= EMAIL;
    cityState= CITY_STATE;
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




    connectedCallback() {
        this.lmsSubscription();

        getAppInfoDetails({appId: this.appId}).then((value)=>{

            this.appReviewId = value;
        })
    }

    lmsSubscription() {
        subscribe(this.messageContext, APP_SELECTED_CHANNEL, (message) => {
            this.appId = message.appId;
            adjustURLParams('c__appId', this.appId);
        });

        setAppIdFromURL(this.messageContext, APP_SELECTED_CHANNEL, this.currentPageReference, this.appId);
    }

    @track appId;

    @track appReviewId;

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

        getAppInfoDetails({appId: this.appId}).then(value => {

            this.appReviewId = value;
        });
    }

    handleReset(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

}