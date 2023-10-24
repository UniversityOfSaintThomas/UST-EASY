/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/24/2023.
 */


public with sharing class EASYAppQuestionResponseWrapper {
    @AuraEnabled public Question__c question { get; set; }
    @AuraEnabled public List<Question_Response__c> questionResponse { get; set; }
}