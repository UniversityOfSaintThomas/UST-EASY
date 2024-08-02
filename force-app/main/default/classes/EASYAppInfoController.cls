/**
 * Created by nguy0092 on 7/26/2024.
 */

public with sharing class EASYAppInfoController {

    @AuraEnabled(Cacheable=false)
    public static String upsertAppReviewData(String appId) {

        Application__c applicationInfo = new Application__c();
        hed__Education_History__c eduHistory = new hed__Education_History__c();
        Application_Review__c appReview = new Application_Review__c();

        if (!String.isBlank(appId)) {
            List<Application__c> applicationInfoList = [
                    SELECT Id,
                            Name,
//                        Generic_Filter_3__c,
                            Contact__c,
//                        Contact__r.FirstName,
//                        Contact__r.LastName,
//                        Contact__r.Email,
//                        Contact__r.MobilePhone,
//                        Contact__r.MailingCity,
//                        Contact__r.MailingState,
//                        Admission_Plan__c,
//                        Intended_Term_of_Entry__c,
//                        Application_Status__c,
//                        Application_Substatus__c,
//                        First_Generation__c,
//                        Self_Reported_Test_Scores_Times_Taken__c,
//                        Future_Test_Date__c,
//                        ACT_SAT_Max_Composite_Score__c,
//                        Overall_Highest_ACT_English__c,
//                        Overall_Highest_ACT_Math__c,
//                        Overall_Highest_ACT_Reading__c,
//                        Overall_Highest_ACT_Science_Reasoning__c,
//                        Overall_Highest_SAT_Math__c,
//                        Overall_Highest_SAT_Writing__c,
//                        Overall_Highest_SAT_Reading__c,
                            Highest_Level_Math__c
                    FROM Application__c
                    WHERE Id = :appId
                    AND Id != NULL
            ];

            if (applicationInfoList.size() > 0) {
                applicationInfo = applicationInfoList[0];

//            appReview.Test_Score_Preference__c = applicationInfo.Generic_Filter_3__c;
                appReview.Application__c = applicationInfo.Id;
//            appReview.Application_Admission_Plan__c = applicationInfo.Admission_Plan__c;
//            appReview.Application_Admission_Status__c = applicationInfo.Application_Status__c;
//            appReview.Application_Admissions_Substatus__c = applicationInfo.Application_Substatus__c;
//            appReview.Application_Start_Term__c = applicationInfo.Intended_Term_of_Entry__c;
//            appReview.Contact_Name__c = (applicationInfo.Contact__r.FirstName != null ? applicationInfo.Contact__r.FirstName : '') + ' ' + (applicationInfo.Contact__r.LastName != null ? applicationInfo.Contact__r.LastName : '');
//            appReview.Is_First_Gen__c = applicationInfo.First_Generation__c?.toUpperCase().contains('YES') ? true : false;
//            appReview.Mobile__c = applicationInfo.Contact__r.MobilePhone;
//            appReview.Email__c = applicationInfo.Contact__r.Email;
//            appReview.City_State__c = (applicationInfo.Contact__r.MailingCity != null ? applicationInfo.Contact__r.MailingCity : '') + ', ' + (applicationInfo.Contact__r.MailingState != null ? applicationInfo.Contact__r.MailingState : '');

//            if(appReview.Overall_Highest_ACT_English__c < 20 || appReview.Overall_Highest_ACT_Math__c < 20 || appReview.Overall_Highest_ACT_Reading__c < 20 || appReview.Overall_Highest_ACT_Science_Reasoning__c < 20 ||
//                appReview.Overall_Highest_SAT_Math__c < 20 || appReview.Overall_Highest_SAT_Writing__c < 20 || appReview.Overall_Highest_SAT_Reading__c < 20){
//
//                appReview.Test_Scores_Below_Minimum__c = true;
//            }
//            appReview.Times_Taken_ACT_SAT__c = applicationInfo.Self_Reported_Test_Scores_Times_Taken__c;
//            appReview.Future_Test_Date_1__c = applicationInfo.Future_Test_Date__c;
//            appReview.ACT_SAT_Max_Composite_Score__c = applicationInfo.ACT_SAT_Max_Composite_Score__c;
//            appReview.Overall_Highest_ACT_English__c = applicationInfo.Overall_Highest_ACT_English__c;
//            appReview.Overall_Highest_ACT_Math__c = applicationInfo.Overall_Highest_ACT_Math__c;
//            appReview.Overall_Highest_ACT_Reading__c = applicationInfo.Overall_Highest_ACT_Reading__c;
//            appReview.Overall_Highest_ACT_Science_Reasoning__c = applicationInfo.Overall_Highest_ACT_Science_Reasoning__c;
//            appReview.Overall_Highest_SAT_Math__c = applicationInfo.Overall_Highest_SAT_Math__c;
//            appReview.Overall_Highest_SAT_Reading__c = applicationInfo.Overall_Highest_SAT_Writing__c;
//            appReview.Overall_Highest_SAT_Writing__c = applicationInfo.Overall_Highest_SAT_Reading__c;

                appReview.Highest_Level_Math_Complete_Testing__c = applicationInfo.Highest_Level_Math__c;
            }

            List<hed__Education_History__c> eduHistoryList = [
                    SELECT Id,
                            Diploma_GED_Earned_Date__c,
                            hed__Account__c,
                            hed__Class_Rank__c,
                            hed__GPA__c
                    FROM hed__Education_History__c
                    WHERE hed__Contact__c = :applicationInfo.Contact__c
                    AND hed__Contact__c != NULL
                    AND Primary_High_School__c = TRUE
                    ORDER BY LastModifiedDate DESC
                    LIMIT 1
            ];

            if (eduHistoryList.size() > 0) {

                eduHistory = eduHistoryList[0];
                appReview.High_School__c = eduHistory.hed__Account__c;
                appReview.High_School_GPA__c = eduHistory.hed__GPA__c;
                appReview.Primary_High_School_Rank__c = eduHistory.hed__Class_Rank__c;
                appReview.Primary_HS_Graduation_Date__c = eduHistory.Diploma_GED_Earned_Date__c;
            }

            List<Application_Review__c> appReviewList = [
                    SELECT Id
                    FROM Application_Review__c
                    WHERE Application__c = :appId
                    AND Application__c != NULL
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];

            if (appReviewList.size() > 0) {

                appReview.Id = appReviewList[0].Id;
            }

            upsert appReview;
        }

        return appReview.Id;
    }


    @AuraEnabled(Cacheable=true)
    public static Application_Review__c displayAppReviewInfo(String appReviewId) {

        Application_Review__c appReviewData = new Application_Review__c();
        List<String> queryFields = new List<String>();

        Map<String, Schema.SObjectField> appReviewFields = Schema.getGlobalDescribe().get('Application_Review__c').getDescribe().fields.getMap();

        for (String fieldName : appReviewFields.keySet()) {

            queryFields.add(fieldName);
        }

        List<String> additionalFields = new List<String> {'Application__r.Name',
                                                          'Application__r.Intended_Term_of_Entry__r.Name',
                                                          'High_School__r.Name'};

        queryFields.addAll(additionalFields);

        String appReviewQuery = 'SELECT ' + String.join(queryFields, ',') +
                                ' FROM Application_Review__c WHERE Id = :appReviewId AND Id != NULL';

        List<Application_Review__c> appReviewList = Database.query(appReviewQuery);

        if (appReviewList.size() > 0) {

            return appReviewData = appReviewList[0];
        } else {

            return null;
        }

    }
}