/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/19/2023.
 */


public class EASYAppRequirementItemWrapper {
    @AuraEnabled public Requirement_Item__c requirementItem { get; set; }
    @AuraEnabled public List<Requirement_Response__c> requirementResponse {get;set;}
    @AuraEnabled public List<EASYAppQuestionResponseWrapper> questions { get; set; }
    @AuraEnabled public List<List<EASYAppQuestionResponseWrapper>> relatedObjectAnswers { get; set; }
    @AuraEnabled public Boolean is_related_object { get; set; }
    @AuraEnabled public Boolean is_document { get; set; }
    @AuraEnabled public Boolean no_answers { get; set; }
    @AuraEnabled public String answerLabel { get; set; }
    @AuraEnabled public String answerLink { get; set; }
    @AuraEnabled public String answerValue { get; set; }
}