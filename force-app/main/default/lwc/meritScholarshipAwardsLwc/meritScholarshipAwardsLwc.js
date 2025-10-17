/**
 * Created by nguy0092 on 10/13/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import getMeritAwards from '@salesforce/apex/MeritScholarshipAwardsController.getMeritAwards';
import {getFieldValue, getRecord} from "lightning/uiRecordApi";
import INTENDED_TERM_OF_ENTRY from '@salesforce/schema/Application__c.Intended_Term_of_Entry__r.Name';
import CITIZENSHIP from '@salesforce/schema/Application__c.Citizenship__c';

const FIELDS = [
    INTENDED_TERM_OF_ENTRY,
    CITIZENSHIP
];

export default class MeritScholarshipAwardsLwc extends LightningElement {

    @api appId;
    @api recordId;

    get appRecordId() {
        return this.appId ? this.appId : this.recordId;
    }

    @track meritScholarshipAwards = {
        AwardInfo: {
            awardStatus: "",
            awardAmount: "0",
            awardAdjAmount: "0",
            awardAdjReason: ""
        },
        InternationalScholarship: {
            scholarshipPercent: "0",
            scholarshipAdjPercent: "0"
        },
        OpportunityFafsa: {
            fafsaFiled: false,
            mnDreamActFiled: false,
            notificationOfAward: false
        }

    };

    financialAidLink = `<a href="https://murphy.stthomas.edu/" target="_blank">official financial aid offer</a>`;
    scholarshipWebsite = `<a href="https://www.stthomas.edu/admissions/international-students/merit-based-scholarships/index.html" target="_blank">review our scholarship website</a>`

    @track adjustmentComments = [
        {
            Reason: "Already Has A Degree",
            Comment: "No Display"
        },
        {
            Reason: "Athletic Revision",
            Comment: "You have been offered an athletic scholarship that has updated your merit scholarship offer amount. Please refer to your NLI paperwork or contact your coach for more details."
        },
        {
            Reason: "Awarded as FTFY",
            Comment: "Your scholarship reflects our commitment to honor the merit scholarship you were offered when you applied to St. Thomas as a first-time, first-year student."
        },
        {
            Reason: "Catholic HS Scholarship",
            Comment: "No Comment"
        },
        {
            Reason: "Cristo Rey Scholarship",
            Comment: "No Comment"
        },
        {
            Reason: "Financial Appeal",
            Comment: "Congratulations on your new revised scholarship! Review your new admission letter and "+this.scholarshipWebsite+"."
        },
        {
            Reason: "Full Tuition 360 Journalism",
            Comment: "Congratulations on being offered the [Scholarship Name]! See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Full Tuition – Anderson Scholarship",
            Comment: "Congratulations, you have been awarded the Anderson Scholarship! Review your new admission letter and "+this.scholarshipWebsite+"."
        },
        {
            Reason: "Full Tuition Dease Scholarship",
            Comment: "Congratulations on being offered the Dease Scholarship (full tuition)! See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Full Tuition Excellence Scholarship",
            Comment: "Congratulations on being offered the DFC Excellence Scholarship (full tuition)! See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Full Tuition - GHR Scholarship",
            Comment: "Congratulations on being offered the GHR Fellows Program scholarship (full tuition)! See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Full Tuition - O’Neill",
            Comment: "Congratulations on being offered the Rory and Rhonda O’Neill Endowed Scholars Program scholarship (full tuition)! See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Full Tuition - Schulze Innovation",
            Comment: "Congratulations on being offered the Schulze Innovation Scholarship (full tuition)! See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "GPA - Missing Academic Work",
            Comment: "We have received additional academic work and have updated your initial merit scholarship. See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Kanthak Scholarship",
            Comment: "Congratulations, you have been offered a Kanthak Scholarship. See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Late Adjust",
            Comment: "Your merit scholarship has been updated. See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Manual Override",
            Comment: "Your merit scholarship has been updated. See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Pathway Scholarship",
            Comment: "No Comment"
        },
        {
            Reason: "Reinstate FTFY sch/awrd",
            Comment: "Your scholarship reflects our commitment to honor the merit scholarship you were offered when you applied to St. Thomas as a first-time, first-year student."
        },
        {
            Reason: "Revised GPA",
            Comment: "Your merit scholarship has been updated. See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Revised PTK",
            Comment: ""
        },
        {
            Reason: "Sauer Cristo Rey Scholarship",
            Comment: ""},
        {
            Reason: "Test Score Rescinded",
            Comment: "Your merit scholarship has been updated because of information received from a testing agency. See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Tuition Exchange",
            Comment: "Your merit scholarship has been updated because you were selected for a tuition benefit. See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Tuition Remission - ACTC",
            Comment: "Your merit scholarship has been updated because you were selected for a tuition benefit. See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Tuition Remission - CCTE",
            Comment: "Your merit scholarship has been updated because you were selected for a tuition benefit. See your "+this.financialAidLink+" for details."
        },
        {
            Reason: "Tuition Remission - UST",
            Comment: "Your merit scholarship has been updated because you were selected for a tuition benefit. See your "+this.financialAidLink+" for details."
        },
    ]

    testCommentLink = this.adjustmentComments[6].Comment;

    get fafsaMnDreamNotReceived() {
        return !this.meritScholarshipAwards.OpportunityFafsa.fafsaFiled && !this.meritScholarshipAwards.OpportunityFafsa.mnDreamActFiled && !this.meritScholarshipAwards.OpportunityFafsa.notificationOfAward;
    }

    get fafsaReceivedAward() {
        return this.meritScholarshipAwards.OpportunityFafsa.notificationOfAward;
    }

    get fafsaReceivedNoAward() {
        return ((this.meritScholarshipAwards.OpportunityFafsa.fafsaFiled || this.meritScholarshipAwards.OpportunityFafsa.mnDreamActFiled) && !this.meritScholarshipAwards.OpportunityFafsa.notificationOfAward);
    }

    @wire(getRecord, {recordId: "$appRecordId", fields: FIELDS})
    ApplicationRecord;

    get intendedTermOfEntry() {
        return getFieldValue(this.ApplicationRecord.data, INTENDED_TERM_OF_ENTRY);
    }

    get domesticApplicant() {
        const citizenship = getFieldValue(this.ApplicationRecord.data, CITIZENSHIP);
        return !(citizenship === 'International');
    }

    @wire(getMeritAwards,{appId: "$appRecordId", term: "$intendedTermOfEntry"})
    getMeritAwardsWire({error, data}) {

        if(data) {
            this.meritScholarshipAwards = JSON.parse(JSON.stringify(data));
            console.log("Data: "+JSON.stringify(data));
            console.log("meritScholarshipAwards: "+JSON.stringify(this.meritScholarshipAwards));
        }

        if(error) {
            console.log("getMeritAwardsWire error: " + error);
        }
    }
}