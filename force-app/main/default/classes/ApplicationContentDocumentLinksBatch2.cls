/**
 * Created by nguy0092 on 3/11/2026.
 * Used for ApplicationContentDocumentLinksInvocable
 */

public without sharing class ApplicationContentDocumentLinksBatch2 implements Database.Batchable<SObject>, Database.Stateful {
    private Map<Id, Set<String>> applicationMap;
    Integer scopeTotal = 0;
    Integer updateTotal = 0;

    public ApplicationContentDocumentLinksBatch2(Map<Id, Set<String>> applicationDocumentTitlesMap) {
        this.applicationMap = applicationDocumentTitlesMap;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> appIds = applicationMap.keySet();

        System.debug('appIds Size: ' + appIds.size());

        Set<String> likeKeyWordsConditions = new Set<String>();
        for (Set<String> titleSet : applicationMap.values()) {
            for (String title : titleSet) {
                String trimmedTitle = title.trim();
                trimmedTitle = trimmedTitle.replace('%', '');
                if (String.isNotBlank(trimmedTitle)) {
                    likeKeyWordsConditions.add('ContentDocument.Title LIKE \'%' + String.escapeSingleQuotes(trimmedTitle) + '%\'');
                }
            }
        }

        String documentTitlesConditions = '';
        if (!likeKeyWordsConditions.isEmpty()) {
            documentTitlesConditions = 'AND (' + String.join(new List<String>(likeKeyWordsConditions), ' OR ') + ')';
            System.debug('documentTitlesConditions: ' + documentTitlesConditions);
        } else {
            return Database.getQueryLocator('SELECT Id FROM ContentDocumentLink WHERE Id = NULL');
        }

        //Current Salesforce issue: not all records are returned when using a bind variable list for LinkedEntityId. Instead use subquery to get LinkedEntityId.
        String queryString = 'SELECT Id, ContentDocumentId, ContentDocument.Title, Visibility, LinkedEntityId ' +
                'FROM ContentDocumentLink ' +
                'WHERE Visibility = \'InternalUsers\' ' +
                documentTitlesConditions +
                ' AND LinkedEntityId IN (' +
                'SELECT Id ' +
                'FROM Application__c ' +
                'WHERE Id IN :appIds)';

        System.debug('queryString: ' + queryString);

        return Database.getQueryLocator(queryString);
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