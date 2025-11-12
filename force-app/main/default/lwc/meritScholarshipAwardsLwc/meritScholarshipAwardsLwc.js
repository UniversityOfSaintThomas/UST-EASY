/**
 * Created by nguy0092 on 10/13/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import getMeritAwards from '@salesforce/apex/MeritScholarshipAwardsController.getMeritAwards';
import {getFieldValue, getRecord} from "lightning/uiRecordApi";
import INTENDED_TERM_OF_ENTRY from '@salesforce/schema/Application__c.Intended_Term_of_Entry__r.Name';
import TERM_NAME from '@salesforce/schema/Application__c.Generic_Filter_4__c';
import CITIZENSHIP from '@salesforce/schema/Application__c.Citizenship__c';

const FIELDS = [
    INTENDED_TERM_OF_ENTRY,
    TERM_NAME,
    CITIZENSHIP
];

export default class MeritScholarshipAwardsLwc extends LightningElement {

    @api appId;
    @api recordId;

    scholarshipType = "";

    scholarshipControllerNames = [
        {Name: "UG Merit Scholarship", Type: "Domestic"},
        {Name: "UG TR Merit Scholarship", Type: "Transfer"},
        {Name: "UG INTL Merit Scholarship", Type: "International"}
    ]

    @track foundAdjReason = {
        Reason: "",
        Comment: ""
    }

    @track meritScholarshipAwards = {
        AwardInfo: {
            awardStatus: "",
            awardAmount: "0",
            awardAdjAmount: "0",
            awardAdjReason: "",
            scholarshipControllerName: ""
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
            Comment: ""//"No Comment"
        },
        {
            Reason: "Cristo Rey Scholarship",
            Comment: ""//"No Comment"
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
            Comment: ""//"No Comment"
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
            Comment: ""//"No Comment"
        },
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

    get appRecordId() {
        return this.appId ? this.appId : this.recordId;
    }

    get displayAward() {
        let noDisplay = false;

        if (this.foundAdjReason) {
            noDisplay = this.foundAdjReason.Comment === "No Display"
        }
        return !noDisplay;
    }

    get awardToDisplay() {
        const display = {
            Description: "",
            TotalAwardAmount: 0,
            TotalAwardDisplay: false,
            Scholarships: [],
        };

        switch (this.scholarshipType) {
            case "Domestic":
            case "Transfer":
                if (this.meritScholarshipAwards.AwardInfo.awardStatus === "Calculated" && this.meritScholarshipAwards.AwardInfo.awardAmount > 0) {
                    display.Description = "Congratulations! You have been awarded a scholarship!";
                    display.TotalAwardAmount = this.meritScholarshipAwards.AwardInfo.awardAmount;
                    this.meritScholarshipAwards.DomesticScholarshipsList.forEach(scholarship => {
                        if (scholarship.scholarshipAmount > 0) {
                            display.Scholarships.push({
                                scholarshipName: scholarship.scholarshipName,
                                scholarshipAmount: scholarship.scholarshipAmount
                            });
                        }
                    })
                }

                if (this.meritScholarshipAwards.AwardInfo.awardStatus === "Adjusted" && this.meritScholarshipAwards.AwardInfo.awardAdjReason) {
                    if (this.meritScholarshipAwards.AwardInfo.awardAdjAmount > 0) {
                        display.Description = this.foundAdjReason ? this.foundAdjReason.Comment : "";
                        display.TotalAwardAmount = this.meritScholarshipAwards.AwardInfo.awardAdjAmount;
                        this.meritScholarshipAwards.DomesticScholarshipsList.forEach(scholarship => {
                            if (scholarship.scholarshipAdjAmount > 0) {
                                display.Scholarships.push({
                                    scholarshipName: scholarship.scholarshipName,
                                    scholarshipAmount: scholarship.scholarshipAdjAmount
                                });
                            }
                        })
                    } else if (this.meritScholarshipAwards.AwardInfo.awardAdjAmount === 0 || this.meritScholarshipAwards.AwardInfo.awardAdjAmount == null) {
                        display.Description = this.foundAdjReason ? this.foundAdjReason.Comment : "";
                        display.TotalAwardAmount = this.meritScholarshipAwards.AwardInfo.awardAmount;
                    }
                }
                break;
            case "International":
                if (this.meritScholarshipAwards.AwardInfo.awardStatus === "Calculated" && this.meritScholarshipAwards.AwardInfo.awardAmount > 0) {
                    display.Description = 'Congratulations! You have been awarded a scholarship!'
                    display.Scholarships.push({
                        scholarshipName: this.meritScholarshipAwards.InternationalScholarship.scholarshipPercent,
                        scholarshipAmount: this.meritScholarshipAwards.AwardInfo.awardAmount
                    });
                    display.TotalAwardAmount = this.meritScholarshipAwards.AwardInfo.awardAmount;
                }

                if (this.meritScholarshipAwards.AwardInfo.awardStatus === "Adjusted" && this.meritScholarshipAwards.AwardInfo.awardAdjReason) {
                    if (this.meritScholarshipAwards.AwardInfo.awardAdjAmount > 0) {
                        display.Description = this.foundAdjReason ? this.foundAdjReason.Comment : "";
                        display.TotalAwardAmount = this.meritScholarshipAwards.AwardInfo.awardAdjAmount;
                        display.Scholarships.push({
                            scholarshipName: this.meritScholarshipAwards.InternationalScholarship.scholarshipAdjPercent,
                            scholarshipAmount: this.meritScholarshipAwards.AwardInfo.awardAdjAmount
                        });
                    } else if (this.meritScholarshipAwards.AwardInfo.awardAdjAmount === 0 || this.meritScholarshipAwards.AwardInfo.awardAdjAmount == null) {
                        display.Description = this.foundAdjReason ? this.foundAdjReason.Comment : "";
                        display.TotalAwardAmount = this.meritScholarshipAwards.AwardInfo.awardAmount;
                    }
                }
                break;
        }
        display.TotalAwardDisplay = this.meritScholarshipAwards.AwardInfo.awardAmount > 0 || this.meritScholarshipAwards.AwardInfo.awardAdjAmount > 0
        return display;
    }

    get fafsaMnDreamNotReceived() {
        return !this.meritScholarshipAwards.OpportunityFafsa.fafsaFiled && !this.meritScholarshipAwards.OpportunityFafsa.mnDreamActFiled && !this.meritScholarshipAwards.OpportunityFafsa.notificationOfAward;
    }

    get fafsaReceivedAward() {
        return this.meritScholarshipAwards.OpportunityFafsa.notificationOfAward;
    }

    get fafsaReceivedNoAward() {
        return ((this.meritScholarshipAwards.OpportunityFafsa.fafsaFiled || this.meritScholarshipAwards.OpportunityFafsa.mnDreamActFiled) && !this.meritScholarshipAwards.OpportunityFafsa.notificationOfAward);
    }

    get domesticApplicant() {
        return this.scholarshipType === 'Domestic' || this.scholarshipType === "Transfer";
    }

    @wire(getRecord, {recordId: "$appRecordId", fields: FIELDS})
    ApplicationRecord;

    get termName() {
        return getFieldValue(this.ApplicationRecord.data, TERM_NAME);
    }

    @wire(getMeritAwards, {appId: "$appRecordId", term: "$termName", domesticApplicant: "$domesticApplicant"})
    getMeritAwardsWire({error, data}) {

        if (data) {
            this.meritScholarshipAwards = JSON.parse(JSON.stringify(data));
            console.log("Data: " + JSON.stringify(data));
            console.log("meritScholarshipAwards: " + JSON.stringify(this.meritScholarshipAwards));

            this.foundAdjReason = this.adjustmentComments.find(adj => adj.Reason === this.meritScholarshipAwards.AwardInfo.awardAdjReason);
            console.log("What is Adj Reason: " + JSON.stringify(this.foundAdjReason));

            console.log("Scholarship Controller: " + this.meritScholarshipAwards.AwardInfo.scholarshipControllerName);
            const scholarshipTypeFind = this.scholarshipControllerNames.find(type => {
                const namePattern = new RegExp(`${type.Name}`, 'i');
                return this.meritScholarshipAwards.AwardInfo.scholarshipControllerName.search(namePattern) >= 0;
            });

            if (scholarshipTypeFind) {
                this.scholarshipType = scholarshipTypeFind.Type;
            }
            console.log("Scholarship Type: " + this.scholarshipType);
        }

        if (error) {
            console.log("getMeritAwardsWire error: " + error);
        }
    }
}