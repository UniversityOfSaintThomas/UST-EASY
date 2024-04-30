/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/19/2023.
 */

public class EASYAppWrapper {
    @AuraEnabled public Application_Control__c appControl { get; set; }
    @AuraEnabled public List<EASYAppRequirementWrapper> requirements { get; set; }
}