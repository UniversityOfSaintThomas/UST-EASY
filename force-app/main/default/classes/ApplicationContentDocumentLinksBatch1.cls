/**
 * Created by nguy0092 on 3/11/2026.
 * Used for ApplicationContentDocumentLinksInvocable
 */

public without sharing class ApplicationContentDocumentLinksBatch1 implements Database.Batchable<SObject>, Database.Stateful {
    private String academicYearCode;

    // Stateful map: Application Id -> Set of Document Title Display values
    private Map<Id, Set<String>> applicationDocumentTitlesMap = new Map<Id, Set<String>>();

    public ApplicationContentDocumentLinksBatch1(String academicYearCode) {
        this.academicYearCode = academicYearCode;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT Id,
                        Application_Status__c,
                        Intended_Term_of_Entry__r.Academic_Year_Code__c,
                        Intended_Program__r.Academic_Level__c,
                        Application_Control__r.Documents_To_Display_Keywords__c
                FROM Application__c
                WHERE Application_Status__c IN ('Admit', 'Confirmed')
                AND Intended_Term_of_Entry__r.Academic_Year_Code__c >= :academicYearCode
                AND Intended_Program__r.Academic_Level__c = 'U'
                AND Application_Control__r.Documents_To_Display_Keywords__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Application__c> scope) {
        // Build a map of Applications and a Set of document title display values
        for (Application__c app : scope) {
            Set<String> titleKeywords = new Set<String>();
            if (String.isNotBlank(app.Application_Control__r.Documents_To_Display_Keywords__c)) {
                List<String> docTitlesSplit = app.Application_Control__r.Documents_To_Display_Keywords__c.split(';');
                for (String titles : docTitlesSplit) {
                    if (String.isBlank(titles)) continue;
                    List<String> keywordsSplit = titles.trim().split('\\|');
                    String keyword = keywordsSplit[0].trim();
                    if (String.isNotBlank(keyword)) {
                        titleKeywords.add(keyword);
                    }
                }
            }
            if (!titleKeywords.isEmpty()) {
                applicationDocumentTitlesMap.put(app.Id, titleKeywords);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('applicationDocumentTitlesMap size: ' + applicationDocumentTitlesMap.size());
        System.debug('applicationDocumentTitlesMap: ' + applicationDocumentTitlesMap);

        if (!applicationDocumentTitlesMap.isEmpty()) {
            Database.executeBatch(new ApplicationContentDocumentLinksBatch2(applicationDocumentTitlesMap), 200);
        }
    }
}