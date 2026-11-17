/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/19/2023.
 */


public class EASYAppRequirementWrapper {
    @AuraEnabled public Requirement__c requirement { get; set; }
    // Heading shown to the reviewer: the Label, or the Name when the Label is blank (same rule as the applicant pages).
    @AuraEnabled public String title { get; set; }
    @AuraEnabled public List<EASYAppRequirementItemWrapper> requirementItems { get; set; }
}