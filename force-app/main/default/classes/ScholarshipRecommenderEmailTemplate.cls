/**
 * Created by nguy0092 on 4/29/2025.
 */

public with sharing class ScholarshipRecommenderEmailTemplate {

    public class orgWideEmailWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class emailTemplateWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String htmlValue;
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
    public static List<emailTemplateWrapper> emailTemplatesOptions() {

        List<emailTemplateWrapper> emailTemplatesOptionsList = new List<emailTemplateWrapper>();

        List<EmailTemplate> emailTemplatesList = [
                SELECT Id,
                        Name,
                        HtmlValue
                FROM EmailTemplate
                WHERE UiType = 'SFX'
                AND FolderName = NULL
                ORDER BY Name
        ];

        if (emailTemplatesList.size() > 0) {
            for (EmailTemplate et : emailTemplatesList) {
                emailTemplateWrapper emailTemplate = new emailTemplateWrapper();
                emailTemplate.label = et.Name;
                emailTemplate.value = et.Id;
                emailTemplate.htmlValue = et.HtmlValue;
                emailTemplatesOptionsList.add(emailTemplate);
            }
        }

        return emailTemplatesOptionsList;
    }

}