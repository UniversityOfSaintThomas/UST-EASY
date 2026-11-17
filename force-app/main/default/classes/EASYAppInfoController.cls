/**
 * Created by nguy0092 on 7/26/2024.
 */

public with sharing class EASYAppInfoController {

    /**
     * Which sections of the Application Information summary to show for an application. An administrator chooses
     * them on the application's Application Control (Review Summary Sections). If the application has no Application
     * Control, or nothing is selected there, every section the field offers is returned.
     *
     * @param appId The Application__c Id
     * @return The section keys to show (the values of the Review Summary Sections field)
     */
    @AuraEnabled(Cacheable=false)
    public static List<String> getSummarySections(String appId) {
        List<String> allSections = new List<String>();
        for (Schema.PicklistEntry entry : Application_Control__c.Review_Summary_Sections__c.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                allSections.add(entry.getValue());
            }
        }

        List<Application__c> applications = [
                SELECT Application_Control__c
                FROM Application__c
                WHERE Id = :appId
                AND Id != NULL
                WITH USER_MODE
                LIMIT 1
        ];
        if (applications.isEmpty() || applications[0].Application_Control__c == null) {
            return allSections;
        }

        // This is configuration set by administrators, not applicant data. Read it in system mode so reviewers
        // do not each need field access to it.
        Id appControlId = applications[0].Application_Control__c;
        List<Application_Control__c> appControls = [
                SELECT Review_Summary_Sections__c
                FROM Application_Control__c
                WHERE Id = :appControlId
                WITH SYSTEM_MODE
                LIMIT 1
        ];
        if (appControls.isEmpty() || String.isBlank(appControls[0].Review_Summary_Sections__c)) {
            return allSections;
        }

        List<String> selected = new List<String>();
        for (String section : appControls[0].Review_Summary_Sections__c.split(';')) {
            if (String.isNotBlank(section)) {
                selected.add(section.trim());
            }
        }
        return selected;
    }

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
                        SR_SAT_Verbal__c,
                        Highest_Level_Math__c
                FROM Application__c
                WHERE Id = :appId
                AND Id != NULL
                WITH USER_MODE
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
                    WITH USER_MODE
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
                            Name,
                            DeveloperName
                    FROM RecordType
                    WHERE SobjectType = 'Application_Review__c'
                    AND DeveloperName IN ('Test_Optional', 'Test_Score')
            ];

            if (!recType.isEmpty()) {

                for (RecordType rec : recType) {

                    if (rec.DeveloperName == 'Test_Score') {

                        recTypeTestScores = rec.Id;
                    } else if (rec.DeveloperName == 'Test_Optional') {

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
                    WITH USER_MODE
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];

            if (!appReviewList.isEmpty()) {

                appReview.Id = appReviewList[0].Id;
            }

            SObjectAccessDecision decision = Security.stripInaccessible(
                    appReview.Id == null ? AccessType.CREATABLE : AccessType.UPDATABLE,
                    new List<Application_Review__c>{ appReview }
            );
            appReview = (Application_Review__c) decision.getRecords()[0];
            upsert appReview;

        }

        return appReview;

    }

}