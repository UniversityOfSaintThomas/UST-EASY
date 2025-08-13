/**
 * Created by nguy0092 on 6/26/2025.
 */

public with sharing class ScholarshipCommunicationTemplates {
    public class orgWideEmailWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class emailTemplateWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String htmlValue;
        @AuraEnabled public String folderName;
    }

    @AuraEnabled(Cacheable=true)
    public static List<orgWideEmailWrapper> orgWideEmailsOptions() {
        List<orgWideEmailWrapper> orgWideEmailsOptionsList = new List<orgWideEmailWrapper>();
        Set<Id> permissionSetIds = new Set<Id>();
        List<PermissionSet> permissionSets = [
                SELECT Id,
                        Name
                FROM PermissionSet
                WHERE Name = 'Application_Community'
        ];

        if (permissionSets.size() > 0) {
            for (PermissionSet ps : permissionSets) {
                permissionSetIds.add(ps.Id);
            }

            List<OrgWideEmailAddress> orgWideEmailsList = [
                    SELECT Id,
                            Address,
                            DisplayName
                    FROM OrgWideEmailAddress
                    WHERE Id IN (
                            SELECT SetupEntityId
                            FROM SetupEntityAccess
                            WHERE ParentId IN :permissionSetIds
                            AND SetupEntityType = 'OrgWideEmailAddress'
                    )
                    ORDER BY Address
            ];

            if (orgWideEmailsList.size() > 0) {
                for (OrgWideEmailAddress oe : orgWideEmailsList) {
                    orgWideEmailWrapper emails = new orgWideEmailWrapper();
                    emails.label = oe.Address + ' (' + oe.DisplayName + ')';
                    emails.value = oe.Id;
                    orgWideEmailsOptionsList.add(emails);
                }
            }
        }

        return orgWideEmailsOptionsList;
    }

    @AuraEnabled(Cacheable=true)
    public static List<emailTemplateWrapper> emailTemplatesOptions(String scholarshipRecordId) {
        List<String> folderNames = new List<String>();
        List<Scholarship__c> scholarshipRecord = [
                SELECT Id,
                        Start_Scholarship_Email_Template_Folder__c,
                        Submit_Scholarship_Email_Template_Folder__c,
                        Recommender_1_Email_Template_Folder__c,
                        Recommender_2_Email_Template_Folder__c
                FROM Scholarship__c
                WHERE Id = :scholarshipRecordId
        ];

        if (scholarshipRecord.size() > 0) {
            if(String.isNotBlank(scholarshipRecord[0].Start_Scholarship_Email_Template_Folder__c)) {
                folderNames.add(scholarshipRecord[0].Start_Scholarship_Email_Template_Folder__c);
            }
            if(String.isNotBlank(scholarshipRecord[0].Submit_Scholarship_Email_Template_Folder__c)) {
                folderNames.add(scholarshipRecord[0].Submit_Scholarship_Email_Template_Folder__c);
            }
            if(String.isNotBlank(scholarshipRecord[0].Recommender_1_Email_Template_Folder__c)) {
                folderNames.add(scholarshipRecord[0].Recommender_1_Email_Template_Folder__c);
            }
            if(String.isNotBlank(scholarshipRecord[0].Recommender_2_Email_Template_Folder__c)) {
                folderNames.add(scholarshipRecord[0].Recommender_2_Email_Template_Folder__c);
            }
        }

        List<emailTemplateWrapper> emailTemplatesOptionsList = new List<emailTemplateWrapper>();
        List<EmailTemplate> emailTemplatesList = [
                SELECT Id,
                        Name,
                        HtmlValue,
                        FolderName
                FROM EmailTemplate
                WHERE UiType = 'SFX'
                AND Folder.Name IN :folderNames
//                AND Folder.Name IN ('Started Scholarship Templates',
//                        'Submitted Scholarship Templates',
//                        'Recommender 1 Scholarship Templates',
//                        'Recommender 2 Scholarship Templates')
//                AND Folder.Name = NULL
                ORDER BY Name
        ];

        if (emailTemplatesList.size() > 0) {
            for (EmailTemplate et : emailTemplatesList) {
                emailTemplateWrapper emailTemplate = new emailTemplateWrapper();
                emailTemplate.label = et.Name;
                emailTemplate.value = et.Id;
                emailTemplate.htmlValue = et.HtmlValue;
                emailTemplate.folderName = et.FolderName;
                emailTemplatesOptionsList.add(emailTemplate);
            }
        }
        return emailTemplatesOptionsList;
    }
}