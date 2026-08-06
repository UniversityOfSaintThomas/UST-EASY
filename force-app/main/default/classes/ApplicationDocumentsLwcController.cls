/**
 * Created by nguy0092 on 10/6/2025.
 */

public without sharing class ApplicationDocumentsLwcController {

    public class ApplicationWrapper {
        @AuraEnabled public String recordId;
        @AuraEnabled public String termName;
        @AuraEnabled public Map<String, String> documentsToDisplayKeywords = new Map<String, String>();
    }

    @AuraEnabled(Cacheable=true)
    public static ApplicationWrapper applicationInformation(String recordId) {
        ApplicationWrapper wrapper = new ApplicationWrapper();

        List<Application__c> apps = [
                SELECT Id,
//                        Generic_Filter_4__c,
                        Intended_Term_of_Entry__r.Name,
                        Application_Control__r.Documents_To_Display_Keywords__c
                FROM Application__c
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];

        if (apps.isEmpty()) {
            return wrapper;
        }

        Application__c app = apps[0];

        wrapper.recordId = app.Id;
        wrapper.termName = app.Intended_Term_of_Entry__r.Name; //app.Generic_Filter_4__c;

        if (app.Application_Control__r != null && String.isNotBlank(app.Application_Control__r.Documents_To_Display_Keywords__c)) {
            List<String> docTitlesSplit = app.Application_Control__r.Documents_To_Display_Keywords__c.split(';');
            for (String titles : docTitlesSplit) {
                if (String.isBlank(titles)) continue;
                List<String> keywordsSplit = titles.trim().split('\\|');
                if (keywordsSplit.size() >= 2) {
                    wrapper.documentsToDisplayKeywords.put(keywordsSplit[0].trim(), keywordsSplit[1].trim());
                } else {
                    wrapper.documentsToDisplayKeywords.put(keywordsSplit[0].trim(), '');
                }
            }
        }

        return wrapper;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getDocumentsRecordId(String recordId, Map<String, String> titleKeywords) {

        List<Id> linkDocumentFileId = new List<Id>();
        List<Map<String, String>> documentFilesList = new List<Map<String, String>>();

        List<ContentDocumentLink> linkDocumentFiles = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
        ];

        System.debug('linkDocumentFiles: ' + linkDocumentFiles);

        for (ContentDocumentLink documentFiles : linkDocumentFiles) {
            linkDocumentFileId.add(documentFiles.ContentDocumentId);
        }

        List<ContentVersion> documentVersions = new List<ContentVersion>();

        if (!linkDocumentFileId.isEmpty() && titleKeywords != null && !titleKeywords.isEmpty()) {

            // Create a set of keys from titleKeywords
            Set<String> titleKeywordSet = new Set<String>(titleKeywords.keySet());

            // Build dynamic LIKE conditions from each keyword
            List<String> likeConditions = new List<String>();
            for (String keyword : titleKeywordSet) {
                likeConditions.add('ContentDocument.Title LIKE \'%' + String.escapeSingleQuotes(keyword) + '%\'');
            }

            // Build dynamic SOQL string
            String dynamicQuery =
                    'SELECT ContentDocumentId, FileExtension, Title, VersionData ' +
                            'FROM ContentVersion ' +
                            'WHERE (' + String.join(likeConditions, ' OR ') + ') ' +
                            'AND ContentDocumentId IN :linkDocumentFileId ' +
                            'AND FileExtension IN (\'pdf\', \'txt\') ' +
                            'AND IsLatest = TRUE ' +
                            'ORDER BY Title';

            System.debug('dynamicQuery: ' + dynamicQuery);

            documentVersions = Database.query(dynamicQuery);
            System.debug('documentVersions: ' + documentVersions);
        }

        for (ContentVersion version : documentVersions) {
            Map<String, String> versionMap = new Map<String, String>{
                    'ContentDocumentId' => version.ContentDocumentId,
                    'FileExtension' => version.FileExtension,
                    'Title' => version.Title,
                    'VersionDataEncode' => ''
            };

            if (version.VersionData != null) {
                versionMap.put('VersionDataEncode', EncodingUtil.base64Encode(version.VersionData));
            }

            documentFilesList.add(versionMap);
        }

        System.debug('documentFilesList: ' + documentFilesList);

        return documentFilesList;
    }

}