/**
 * Created by nguy0092 on 7/14/2025.
 */

public with sharing class scholarshipEligibleListViewController {

    @AuraEnabled(Cacheable=true)
    public static List<scholarshipEligibleAppStatus> eligibleScholarships(String contactId, String appId, String currentPage) {
        List<Application__c> apps = new List<Application__c>();
        Set<Scholarship__c> scholarshipsEligibleSet = new Set<Scholarship__c>();
        List<Scholarship__c> scholarshipsEligibleList = new List<Scholarship__c>();
        Set<Id> scholarshipIds = new Set<Id>();
        List<Scholarship_Applicant__c> scholarshipApplicant = new List<Scholarship_Applicant__c>();
        List<scholarshipEligibleAppStatus> scholarshipEligibleAppStatusList = new List<scholarshipEligibleAppStatus>();

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
        appsQuery += ' Citizenship__c, Intended_Program_Codes__c, Intended_Term_of_Entry__r.Name, Intended_Program__r.Degree_Type__c, Degree_Type__c,';
        appsQuery += ' Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c, Applicant_Type__c';
        appsQuery += ' FROM Application__c';
        appsQuery += ' WHERE Application_Status__c NOT IN (\'Wrong Application\', \'Withdrawn\')';
//        appsQuery += ' WHERE Application_Status__c != \'Wrong Application\'';
//        appsQuery += ' AND (NOT(Application_Status__c = \'Withdrawn\' AND Application_Substatus__c = \'Wrong App\'))';
//        appsQuery += ' AND (NOT(Application_Status__c = \'Withdrawn\' AND Application_Substatus__c = \'Multiple App\'))';

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

        Datetime nowDateTime = Datetime.now();
        Date nowDate = nowDateTime.date();

        List<Scholarship__c> openScholarships = [
                SELECT Name,
                        Id,
                        Scholarship_ID__c,
                        Short_Description__c,
                        Direct_URL__c,
                        Application_Controls__c,
                        Citizenship_s__c,
                        Degree_Type__c,
                        Programs__c,
                        Academic_Term_s__c,
                        Admission_Application_Status__c,
                        Open_Date__c,
                        Open_Time__c,
                        Close_Date__c,
                        Close_Time__c
                FROM Scholarship__c
                WHERE Open_Date__c <= :nowDate AND Close_Date__c >= :nowDate AND RecordType.DeveloperName IN ('Scholarship', 'Graduate_Scholarship', 'Signature_Programs')
//                WHERE Open_Date__c <= TODAY AND Close_Date__c >= TODAY AND RecordType.DeveloperName IN ('Scholarship', 'Graduate_Scholarship', 'Signature_Programs')
                AND Do_Not_Show_On_Scholarship_List__c = FALSE
                ORDER BY Name ASC NULLS FIRST
        ];

        for (Application__c app : apps) {

            for (Scholarship__c scholarship : openScholarships) {
                if (ScholarshipSharedUtilities.isScholarshipOpen(scholarship)) {
                    List<Boolean> eligibleScholarshipCheck = new List<Boolean>();
                    List<String> scholarshipApplicationControlList = scholarship.Application_Controls__c?.split(';');
                    List<String> scholarshipCitizenshipList = scholarship.Citizenship_s__c?.split(';');
                    List<String> scholarshipDegreeTypeList = scholarship.Degree_Type__c?.split(';');
                    List<String> scholarshipProgramList = scholarship.Programs__c?.split(';');
                    List<String> scholarshipAcademicTermList = scholarship.Academic_Term_s__c?.split(';');
                    List<String> scholarshipAdmissionApplicationStatus = scholarship.Admission_Application_Status__c?.split(';');

                    eligibleScholarshipCheck.add(criteriaCompare(scholarshipApplicationControlList, app.Application_Control__r.URL_Parameter__c));
                    eligibleScholarshipCheck.add(criteriaCompare(scholarshipCitizenshipList, app.Citizenship__c));
                    eligibleScholarshipCheck.add(criteriaCompare(scholarshipDegreeTypeList, app.Degree_Type__c));
                    eligibleScholarshipCheck.add(criteriaCompare(scholarshipProgramList, app.Generic_Filter_1__c));
                    eligibleScholarshipCheck.add(criteriaCompare(scholarshipAcademicTermList, app.Intended_Term_of_Entry__r.Name));
                    eligibleScholarshipCheck.add(criteriaCompare(scholarshipAdmissionApplicationStatus, app.Application_Status__c));

                    if (!eligibleScholarshipCheck.contains(false)) {
                        scholarshipsEligibleSet.add(scholarship);
                    }
                }
            }
        }

        scholarshipsEligibleList = new List<Scholarship__c>(scholarshipsEligibleSet);
        scholarshipsEligibleList.sort();

        for (Scholarship__c scholarship : scholarshipsEligibleList) {
            scholarshipIds.add(scholarship.Id);
        }

        if (scholarshipIds.size() > 0) {
            scholarshipApplicant = [
                    SELECT Id,
                            Scholarship__r.Id,
                            Scholarship_Status__c
                    FROM Scholarship_Applicant__c
                    WHERE Scholarship__r.Id = :scholarshipIds
                    AND Contact__c = :contactId
                    ORDER BY Scholarship_Date_Started__c DESC
            ];
        }

        for (Scholarship__c scholarship : scholarshipsEligibleList) {
            scholarshipEligibleAppStatus scholarshipEligibleAppStatus = new scholarshipEligibleAppStatus();
            scholarshipEligibleAppStatus.Id = scholarship.Id;
            scholarshipEligibleAppStatus.Name = scholarship.Name;
            scholarshipEligibleAppStatus.ShortDescription = scholarship.Short_Description__c;
            scholarshipEligibleAppStatus.DirectUrl = scholarship.Direct_URL__c;
            scholarshipEligibleAppStatus.AppStatus = '';

            for (Scholarship_Applicant__c applicant : scholarshipApplicant) {
                if (scholarship.Id == applicant.Scholarship__r.Id) {
                    scholarshipEligibleAppStatus.AppStatus = applicant.Scholarship_Status__c;
                }
            }

            scholarshipEligibleAppStatusList.add(scholarshipEligibleAppStatus);
        }

        return scholarshipEligibleAppStatusList;
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

    public class scholarshipEligibleAppStatus {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String ShortDescription;
        @AuraEnabled public String DirectUrl;
        @AuraEnabled public String AppStatus;
    }
}