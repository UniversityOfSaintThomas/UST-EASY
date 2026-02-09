/**
 * Created by nguy0092 on 10/6/2025.
 */

public without sharing class ApplicationDocumentsLwcController {

    @AuraEnabled(Cacheable=true)
    public static Application__c applicationTermName(String recordId) {

        return [
                SELECT Id,
                        Generic_Filter_4__c
                FROM Application__c
                WHERE Id = :recordId
                LIMIT 1
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getDocumentsRecordId(String recordId) {
//        DocumentContentLinks linkDocumentFiles = new DocumentContentLinks();
//        return linkDocumentFiles.documentsRecordId(recordId);

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

        List<ContentVersion> documentVersions = [
                SELECT ContentDocumentId,
                        FileExtension,
                        Title,
                        VersionData
                FROM ContentVersion
                WHERE (ContentDocument.Title LIKE '%AdmissionLetter%'
                    OR ContentDocument.Title LIKE '%BSNDirectAdmit%')
                AND ContentDocumentId IN :linkDocumentFileId
                AND FileExtension IN ('pdf', 'txt')
                AND IsLatest = TRUE
                ORDER BY Title
        ];

        System.debug('ContentVersion: ' + documentVersions);


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

//    private without sharing class DocumentContentLinks {
//
//        public List<Map<String, String>> documentsRecordId(String recordId) {
//
//            List<Id> linkDocumentFileId = new List<Id>();
//            List<Map<String, String>> documentFilesList = new List<Map<String, String>>();
//
//            List<ContentDocumentLink> linkDocumentFiles = [
//                    SELECT ContentDocumentId
//                    FROM ContentDocumentLink
//                    WHERE LinkedEntityId = :recordId
//            ];
//
//            for (ContentDocumentLink documentFiles : linkDocumentFiles) {
//                linkDocumentFileId.add(documentFiles.ContentDocumentId);
//            }
//
//            List<ContentVersion> documentVersions = [
//                    SELECT ContentDocumentId,
//                            FileExtension,
//                            Title,
//                            VersionData
//                    FROM ContentVersion
//                    WHERE ContentDocumentId IN :linkDocumentFileId
//                    AND FileExtension IN ('pdf', 'txt')
//                    AND IsLatest = TRUE
//                    ORDER BY Title
//            ];
//
//            for (ContentVersion version : documentVersions) {
//                Map<String, String> versionMap = new Map<String, String>{
//                        'ContentDocumentId' => version.ContentDocumentId,
//                        'FileExtension' => version.FileExtension,
//                        'Title' => version.Title,
//                        'VersionDataEncode' => ''
//                };
//
//                if (version.VersionData != null) {
//                    versionMap.put('VersionDataEncode', EncodingUtil.base64Encode(version.VersionData));
//                }
//
//                documentFilesList.add(versionMap);
//            }
//
//            System.debug('documentFilesList: ' + documentFilesList);
//
//            return documentFilesList;
//        }
//    }

}