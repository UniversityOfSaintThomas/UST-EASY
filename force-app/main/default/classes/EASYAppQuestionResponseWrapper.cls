/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/24/2023.
 */


public with sharing class EASYAppQuestionResponseWrapper {
    @AuraEnabled public Question__c question { get; set; }
    @AuraEnabled public List<Question_Response__c> questionResponses { get; set; }
    @AuraEnabled public Object referenceAnswer { get; set; }
    @AuraEnabled public Boolean dependencies_met { get; set; }
    @AuraEnabled public Boolean answered { get; set; }
    @AuraEnabled public Boolean show_question { get; set; }
}