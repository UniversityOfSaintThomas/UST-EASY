/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/19/2023.
 */


public class EASYAppRequirementItemWrapper {
    @AuraEnabled public Requirement_Item__c requirementItem { get; set; }
    @AuraEnabled public List<Requirement_Response__c> requirementResponse {get;set;}
    @AuraEnabled public List<EASYAppQuestionResponseWrapper> questions { get; set; }
    @AuraEnabled public List<Object> relatedObjectAnswer { get; set; }
    @AuraEnabled public Boolean is_related_object { get; set; }
    @AuraEnabled public Boolean is_document { get; set; }
    @AuraEnabled public Boolean is_question_group { get; set; }
    @AuraEnabled public Boolean display_response { get; set; }
}