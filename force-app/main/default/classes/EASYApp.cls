/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/19/2023.
 */

public class EASYApp {
    @AuraEnabled public Application_Control__c appControl { get; set; }
    public class requirements {
        @AuraEnabled public List<Requirement__c> requirements { get; set; }
        @AuraEnabled public List<EASYAppQuestionGroups> questionGroups { get; set; }
    }
}