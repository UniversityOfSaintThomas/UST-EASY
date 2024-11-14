/**
 * Created by nguy0092 on 7/26/2024.
 */

public with sharing class EASYAppInfoWrapper {
    @AuraEnabled
    public Application__c appDetails { get; set; }
    @AuraEnabled
    public Contact contactDetails { get; set; }
    @AuraEnabled
    public Opportunity oppDetails { get; set; }
    @AuraEnabled
    public hed__Education_History__c eduDetails { get; set; }
    @AuraEnabled
    public String highestMath { get; set; }
    @AuraEnabled
    public String firstGeneration { get; set; }
    @AuraEnabled
    public Id testScoreRecType { get; set; }
    @AuraEnabled
    public Id testOptScoreRecType { get; set; }
    @AuraEnabled
    public hed__Test__c actComp { get; set; }
    @AuraEnabled
    public hed__Test__c satComp { get; set; }

}