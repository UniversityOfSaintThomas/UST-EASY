/**
 * Created by nguy0092 on 7/14/2025.
 */

public with sharing class scholarshipEligibleListViewController {

    @AuraEnabled(Cacheable=true)
    public static List<Scholarship__c> eligibleScholarships(String contactId, String appId, String currentPage) {
        List<Application__c> apps = new List<Application__c>();
        Set<Scholarship__c> scholarshipsEligibleSet = new Set<Scholarship__c>();
        List<Scholarship__c> scholarshipsEligibleList = new List<Scholarship__c>();

        List<String> pagesWithMultipleAppInfo = new List<String>{
                'applicationportal'
        };

        String currentPageName = currentPage;

        if (String.isNotBlank(currentPageName)) {
            currentPageName = currentPageName.toLowerCase();
        } else {
            currentPageName = 'applicationhome';
        }

        String appsQuery = ' SELECT Id, Application_Control__r.Id, Application_Control__r.URL_Parameter__c, Application_Status__c, Application_Substatus__c, OwnerId,';
        appsQuery += ' Citizenship__c, Intended_Program_Codes__c, Intended_Program__r.Degree_Type__c, Degree_Type__c,';
        appsQuery += ' Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c, Applicant_Type__c';
        appsQuery += ' FROM Application__c';
        appsQuery += ' WHERE Application_Status__c != \'Wrong Application\'';
        appsQuery += ' AND (NOT(Application_Status__c = \'Withdrawn\' AND Application_Substatus__c = \'Wrong App\'))';
        appsQuery += ' AND (NOT(Application_Status__c = \'Withdrawn\' AND Application_Substatus__c = \'Multiple App\'))';
//        appsQuery += ' AND Contact__c IN (SELECT ContactId FROM User WHERE Id = \'' + UserInfo.getUserId() + '\') ';

        if (pagesWithMultipleAppInfo.contains(currentPageName)) {
            appsQuery += ' AND Contact__c = \'' + contactId + '\'';
        } else {
            appsQuery += ' AND Id = \'' + appId + '\'';
        }

        try {
            apps = Database.query(appsQuery);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        List<Scholarship__c> availableScholarships = [
                SELECT Name,
                        Id,
                        Scholarship_ID__c,
                        Short_Description__c,
                        Direct_URL__c,
                        Citizenship__c,
                        Degree_Type__c,
                        Programs__c
                FROM Scholarship__c
                WHERE Open_Date__c <= TODAY AND Close_Date__c >= TODAY AND RecordType.DeveloperName = 'Scholarship'
                ORDER BY Name ASC NULLS FIRST
        ];

        for (Application__c app : apps) {

            for (Scholarship__c scholarship : availableScholarships) {
                List<Boolean> eligibleScholarshipCheck = new List<Boolean>();
                List<String> scholarshipCitizenshipList = scholarship.Citizenship__c?.split(';');
                List<String> scholarshipDegreeTypeList = scholarship.Degree_Type__c?.split(';');
                List<String> scholarshipProgramList = scholarship.Programs__c?.split(';');

                eligibleScholarshipCheck.add(criteriaCompare(scholarshipCitizenshipList, app.Citizenship__c));
                eligibleScholarshipCheck.add(criteriaCompare(scholarshipDegreeTypeList, app.Degree_Type__c));
                eligibleScholarshipCheck.add(criteriaCompare(scholarshipProgramList, app.Generic_Filter_1__c));

                if (!eligibleScholarshipCheck.contains(false)) {
                    scholarshipsEligibleSet.add(scholarship);
                }
            }
        }

        return scholarshipsEligibleList = new List<Scholarship__c>(scholarshipsEligibleSet);
    }

    public static Boolean criteriaCompare(List<String> scholarshipList, String appValue) {
        Boolean matched = true;
        if (scholarshipList?.size() > 0) {
            if (String.isNotBlank(appValue)) {
                if (scholarshipList.contains(appValue)) {
                    matched = true;
                } else {
                    matched = false;
                }
            } else {
                matched = false;
            }
        }
        return matched;
    }
}