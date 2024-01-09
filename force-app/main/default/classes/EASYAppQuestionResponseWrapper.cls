/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/24/2023.
 */


public with sharing class EASYAppQuestionResponseWrapper {
    @AuraEnabled public Question__c question { get; set; }
    @AuraEnabled public List<Question_Response__c> questionResponses { get; set; }
    public class questionResponseValue {
        @AuraEnabled public String stringValue { get; set; }
        @AuraEnabled public Datetime dateTimeValue { get; set; }
        @AuraEnabled public String link { get; set; }
    }
    @AuraEnabled public Boolean dependencies_met { get; set; }
}