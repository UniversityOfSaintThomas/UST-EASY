/**
 * Created by nguy0092 on 10/6/2025.
 */

public with sharing class ApplicationDocumentsLwcController {

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getDocumentsRecordId(String recordId) {
        DocumentContentLinks linkDocumentFiles = new DocumentContentLinks();

        return linkDocumentFiles.documentsRecordId(recordId);
    }

    private without sharing class DocumentContentLinks {

        public List<Map<String, String>> documentsRecordId(String recordId) {

            List<Id> linkDocumentFileId = new List<Id>();
            List<Map<String, String>> documentFilesList = new List<Map<String, String>>();

            List<ContentDocumentLink> linkDocumentFiles = [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :recordId
            ];

            for (ContentDocumentLink documentFiles : linkDocumentFiles) {
                linkDocumentFileId.add(documentFiles.ContentDocumentId);
            }

            List<ContentVersion> documentVersions = [
                    SELECT ContentDocumentId,
                            FileExtension,
                            Title,
                            VersionData
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :linkDocumentFileId
                    AND FileExtension IN ('pdf', 'txt')
                    AND IsLatest = TRUE
                    ORDER BY Title
            ];

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

}