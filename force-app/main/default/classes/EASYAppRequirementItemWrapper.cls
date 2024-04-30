/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/19/2023.
 */


public class EASYAppRequirementItemWrapper {
    @AuraEnabled public Requirement_Item__c requirementItem { get; set; }
    @AuraEnabled public List<Requirement_Response__c> requirementResponse {get;set;}
    @AuraEnabled public List<EASYAppQuestionResponseWrapper> questions { get; set; }
}