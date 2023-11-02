/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/19/2023.
 */


public class EASYAppRequirementWrapper {
    @AuraEnabled public Requirement__c requirement { get; set; }
    @AuraEnabled public List<EASYAppRequirementItemWrapper> requirementItems { get; set; }
}