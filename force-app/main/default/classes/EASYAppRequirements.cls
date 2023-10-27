/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/19/2023.
 */


public with sharing class EASYAppRequirements {
    @AuraEnabled public List<Requirement__c> requirements { get; set; }
    @AuraEnabled public List<EASYAppQuestionGroups> questionGroups { get; set; }
}