/**
 * Created by nguy0092 on 7/14/2025.
 */

public with sharing class scholarshipEligibleListViewController {

    @AuraEnabled(Cacheable=true)
    public static List<Scholarship__c> eligibleScholarships(String contactId, String appId, String currentPage) {
        List<Application__c> apps = new List<Application__c>();
        List<Scholarship__c> scholarshipsEligible = new List<Scholarship__c>();

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

        System.debug('What is apps size: '+apps.size());
        for (Application__c a : apps) {
            System.debug('What is apps: '+a);
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

        System.debug('What is availableScholarships size: '+availableScholarships.size());
        System.debug('What is availableScholarships: '+availableScholarships);

        for (Application__c app : apps) {
            for (Scholarship__c scholarship : availableScholarships) {
                List<Boolean> eligibleScholarshipCheck = new List<Boolean>();
                List<String> scholarshipDegreeTypeList = scholarship.Degree_Type__c?.split(';');
                List<String> scholarshipProgramList = scholarship.Programs__c?.split(';');
                if (app.Citizenship__c == scholarship.Citizenship__c || String.isBlank(scholarship.Citizenship__c)) {
                    eligibleScholarshipCheck.add(true);
                } else {
                    eligibleScholarshipCheck.add(false);
                }
                if ((String.isNotBlank(scholarship.Degree_Type__c) && (String.isNotBlank(app.Degree_Type__c) ? scholarshipDegreeTypeList.contains(app.Degree_Type__c) : false))) {
                    eligibleScholarshipCheck.add(true);
                } else {
                    eligibleScholarshipCheck.add(false);
                }
                if ((String.isNotBlank(scholarship.Programs__c) && (String.isNotBlank(app.Generic_Filter_1__c) ? scholarshipProgramList.contains(app.Generic_Filter_1__c) : false))) {
                    eligibleScholarshipCheck.add(true);
                } else {
                    eligibleScholarshipCheck.add(false);
                }

                if (!eligibleScholarshipCheck.contains(false)) {
                    scholarshipsEligible.add(scholarship);
                }
            }
        }

        return scholarshipsEligible;
    }
}