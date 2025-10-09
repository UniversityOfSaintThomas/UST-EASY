/**
 * Created by nguy0092 on 10/6/2025.
 */

public without sharing class ApplicationDocumentsLwcController {

    @AuraEnabled(Cacheable=true)
//    public static List<ContentVersion> getDocumentsRecordId(String recordId) {
    public static List<Map<String, String>> getDocumentsRecordId(String recordId) {
        List<Id> linkDocumentFileId = new List<Id>();
        List<Map<String, String>> documentFilesList = new List<Map<String, String>>();

        List<ContentDocumentLink> linkDocumentFiles = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
        ];

        for(ContentDocumentLink documentFiles : linkDocumentFiles) {
            linkDocumentFileId.add(documentFiles.ContentDocumentId);
        }

        List<ContentVersion> documentVersions = [
                SELECT ContentDocumentId,
                        FileExtension,
                        Title,
                        VersionData
                FROM ContentVersion
                WHERE ContentDocumentId IN :linkDocumentFileId
        ];

        for(ContentVersion version : documentVersions) {
            Map<String, String> versionMap = new Map<String, String>{
                'ContentDocumentId' => version.ContentDocumentId,
                'FileExtension' => version.FileExtension,
                'Title' => version.Title,
                'VersionDataBlob' => ''
            };

            if(version.VersionData != null) {
                versionMap.put('VersionDataBlob', EncodingUtil.base64Encode(version.VersionData));
            }

            documentFilesList.add(versionMap);
        }

        System.debug('documentFilesList: '+documentFilesList);

        return documentFilesList;
    }
}