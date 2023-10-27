/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/19/2023.
 */
public class EASYAppQuestionGroups {
    @AuraEnabled public List<Requirement_Item__c> questionGroup { get; set; }
    public class question {
        @AuraEnabled public List<question> questions { get; set; }
    }
}