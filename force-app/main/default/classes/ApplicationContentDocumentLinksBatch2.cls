/**
 * Created by nguy0092 on 3/11/2026.
 * Used for ApplicationContentDocumentLinksInvocable
 */

public without sharing class ApplicationContentDocumentLinksBatch2 implements Database.Batchable<SObject>, Database.Stateful {
    private final Map<Id, Set<String>> applicationMap;
    Integer scopeTotal = 0;
    Integer updateTotal = 0;

    public ApplicationContentDocumentLinksBatch2(Map<Id, Set<String>> applicationDocumentTitlesMap) {
        this.applicationMap = applicationDocumentTitlesMap;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> appIds = applicationMap.keySet();

        System.debug('appIds Size: ' + appIds.size());

        Boolean hasKeywords = false;
        for (Set<String> titleSet : applicationMap.values()) {
            if (!titleSet.isEmpty()) {
                hasKeywords = true;
                break;
            }
        }

        if (!hasKeywords) {
            Id noOpId = bc.getJobId(); // real Id, will never match a ContentDocumentLink's LinkedEntityId
            return Database.getQueryLocator([
                    SELECT Id
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :noOpId
            ]);
        }

        /*Potentially not all records are returned when using a bind variable list (:appIds) for LinkedEntityId because of SOQL limits.
        Using subquery to get and match LinkedEntityId seems to bypass these limits.*/
        return Database.getQueryLocator([
                SELECT Id, ContentDocumentId,
                        ContentDocument.Title,
                        Visibility,
                        LinkedEntityId
                FROM ContentDocumentLink
                WHERE Visibility = 'InternalUsers'
                AND LinkedEntityId IN (
                        SELECT Id
                        FROM Application__c
                        WHERE Id IN :appIds)
        ]);
    }

    public void execute(Database.BatchableContext bc, List<ContentDocumentLink> scope) {
        List<ContentDocumentLink> toUpdate = new List<ContentDocumentLink>();

        scopeTotal += scope.size();

        for (ContentDocumentLink cdl : scope) {
            Id appId = cdl.LinkedEntityId;
            String docTitle = cdl.ContentDocument.Title;

            Set<String> titleKeywords = applicationMap.get(appId);

            if (titleKeywords != null && docTitle != null) {
                for (String keyword : titleKeywords) {
                    String trimmedKeyword = keyword.trim();
                    if (String.isNotBlank(trimmedKeyword) && docTitle.containsIgnoreCase(trimmedKeyword)) {
                        cdl.Visibility = 'AllUsers';
                        toUpdate.add(cdl);
                        break;
                    }
                }
            }
        }

        if (!toUpdate.isEmpty()) {
            try {
                Database.update(toUpdate);
                updateTotal += toUpdate.size();
            } catch (Exception e) {
                System.debug('ContentDocumentLinkUpdateBatch Error: ' + e.getMessage());
            }
        }

    }

    public void finish(Database.BatchableContext bc) {
        System.debug('scopeTotal: '+scopeTotal);
        System.debug('updateTotal: '+updateTotal);
        System.debug('ContentDocumentLinkUpdateBatch finished.');
    }
}