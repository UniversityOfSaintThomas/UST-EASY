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
                            Contact__c,
                            Highest_ACT_Composite__c,
                            Highest_ACT_English__c,
                            Highest_ACT_Math__c,
                            Highest_ACT_Reading__c,
                            Highest_ACT_Science_Reasoning__c,
                            Highest_SAT_Composite__c,
                            Highest_SAT_Math__c,
                            Highest_SAT_Reading__c,
                            Highest_SAT_Writing__c,
                            SR_ACT_Composite__c,
                            SR_ACT_English__c,
                            SR_ACT_Math__c,
                            SR_ACT_Reading__c,
                            SR_ACT_Science_Reasoning__c,
                            SR_SAT_Composite__c,
                            SR_SAT_Math__c,
                            SR_SAT_Reading__c,
                            SR_SAT_Verbal__c,
                            Highest_Level_Math__c
                    FROM Application__c
                    WHERE Id = :appId
                    AND Id != NULL
            ];

            if (applicationInfoList.size() > 0) {
                applicationInfo = applicationInfoList[0];

                appReview.Application__c = applicationInfo.Id;
                appReview.Highest_ACT_Composite__c = applicationInfo.Highest_ACT_Composite__c;
                appReview.Highest_ACT_English__c = applicationInfo.Highest_ACT_English__c;
                appReview.Highest_ACT_Math__c = applicationInfo.Highest_ACT_Math__c;
                appReview.Highest_ACT_Reading__c = applicationInfo.Highest_ACT_Reading__c;
                appReview.Highest_ACT_Science_Reasoning__c = applicationInfo.Highest_ACT_Science_Reasoning__c;
                appReview.Highest_SAT_Composite__c = applicationInfo.Highest_SAT_Composite__c;
                appReview.Highest_SAT_Math__c = applicationInfo.Highest_SAT_Math__c;
                appReview.Highest_SAT_Reading__c = applicationInfo.Highest_SAT_Reading__c;
                appReview.Highest_SAT_Writing__c = applicationInfo.Highest_SAT_Writing__c;
                appReview.SR_ACT_Composite__c = applicationInfo.SR_ACT_Composite__c;
                appReview.SR_ACT_English__c = applicationInfo.SR_ACT_English__c;
                appReview.SR_ACT_Math__c = applicationInfo.SR_ACT_Math__c;
                appReview.SR_ACT_Reading__c = applicationInfo.SR_ACT_Reading__c;
                appReview.SR_ACT_Science_Reasoning__c = applicationInfo.SR_ACT_Science_Reasoning__c;
                appReview.SR_SAT_Composite__c = applicationInfo.SR_SAT_Composite__c;
                appReview.SR_SAT_Math__c = applicationInfo.SR_SAT_Math__c;
                appReview.SR_SAT_Reading__c = applicationInfo.SR_SAT_Reading__c;
                appReview.SR_SAT_Verbal__c = applicationInfo.SR_SAT_Verbal__c;
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

//    @AuraEnabled(Cacheable=true)
//    public static Application_Review__c displayAppReviewInfo(String appReviewId) {
//
//        Application_Review__c appReviewData = new Application_Review__c();
//        List<String> queryFields = new List<String>();
//
//        Map<String, Schema.SObjectField> appReviewFields = Schema.getGlobalDescribe().get('Application_Review__c').getDescribe().fields.getMap();
//
//        for (String fieldName : appReviewFields.keySet()) {
//
//            queryFields.add(fieldName);
//        }
//
//        List<String> additionalFields = new List<String> {'Application__r.Name',
//                                                          'Application__r.Intended_Term_of_Entry__r.Name',
//                                                          'High_School__r.Name'};
//
//        queryFields.addAll(additionalFields);
//
//        String appReviewQuery = 'SELECT ' + String.join(queryFields, ',') +
//                                ' FROM Application_Review__c WHERE Id = :appReviewId AND Id != NULL';
//
//        List<Application_Review__c> appReviewList = Database.query(appReviewQuery);
//
//        if (appReviewList.size() > 0) {
//
//            return appReviewData = appReviewList[0];
//        } else {
//
//            return null;
//        }
//
//    }
}