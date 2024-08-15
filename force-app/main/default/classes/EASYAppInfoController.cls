/**
 * Created by nguy0092 on 7/26/2024.
 */

public with sharing class EASYAppInfoController {

    @AuraEnabled(Cacheable=false)
    public static Application_Review__c upsertAppReviewData(String appId) {

        Application__c applicationInfo = new Application__c();
        hed__Education_History__c eduHistory = new hed__Education_History__c();
        Application_Review__c appReview = new Application_Review__c();

        String recTypeTestOptional = '';
        String recTypeTestScores = '';

        List<Application__c> applicationInfoList = [
                SELECT Id,
                        Name,
                        Contact__c,
                        Generic_Filter_3__c,
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

        if (!applicationInfoList.isEmpty()) {

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

            if (!eduHistoryList.isEmpty()) {

                eduHistory = eduHistoryList[0];
                appReview.High_School__c = eduHistory.hed__Account__c;
                appReview.High_School_GPA__c = eduHistory.hed__GPA__c;
                appReview.Primary_High_School_Rank__c = eduHistory.hed__Class_Rank__c;
                appReview.Primary_HS_Graduation_Date__c = eduHistory.Diploma_GED_Earned_Date__c;
            }

            List<RecordType> recType = [
                    SELECT Id,
                            Name
                    FROM RecordType
                    WHERE SobjectType = 'Application_Review__c'
                    AND DeveloperName IN ('Test_Optional', 'Test_Score')
            ];

            if (!recType.isEmpty()) {

                for (RecordType rec : recType) {

                    if (rec.Name == 'Test Score') {

                        recTypeTestScores = rec.Id;
                    } else if (rec.Name == 'Test Optional') {

                        recTypeTestOptional = rec.Id;
                    }
                }
            }

            if(applicationInfo.Generic_Filter_3__c == 'Apply With Standardized Test'){

                appReview.RecordTypeId = recTypeTestScores;
            } else {

                appReview.RecordTypeId = recTypeTestOptional;
            }

            List<Application_Review__c> appReviewList = [
                    SELECT Id
                    FROM Application_Review__c
                    WHERE Application__c = :appId
                    AND Application__c != NULL
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];

            if (!appReviewList.isEmpty()) {

                appReview.Id = appReviewList[0].Id;
            }

            upsert appReview;

        }

        return appReview;

    }

}