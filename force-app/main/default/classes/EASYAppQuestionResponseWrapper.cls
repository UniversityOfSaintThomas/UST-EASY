/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/24/2023.
 */


public with sharing class EASYAppQuestionResponseWrapper {
    @AuraEnabled public Question__c question { get; set; }
    @AuraEnabled public List<Question_Response__c> questionResponses { get; set; }
    public class questionResponseValue {
        @AuraEnabled public String stringValue { get; set; }
        @AuraEnabled public Datetime dateTimeValue { get; set; }
        @AuraEnabled public String link { get; set; }
        @AuraEnabled public String linkName { get; set; }
        @AuraEnabled public Address addressValue { get; set; }
        /*
        'Address' => 'Address',
        'Checkbox' => 'ValueCheckbox__c',
        'Currency' => 'ValueCurrency__c',
        'Date' => 'ValueDate__c',
        'DateTime' => 'ValueDateTime__c',
        'Decimal' => 'ValueNumber__c',
        'Email' => 'ValueEmail__c',
        'TextEncrypted' => 'ValueTextEncrypted__c',
        'Integer' => 'ValueNumber__c',
        'MultiPicklist' => 'multiPicklistValues',
        'Percent' => 'ValuePercent__c',
        'Phone' => 'ValuePhone__c',
        'Picklist' => 'ValueText__c',
        'Reference' => 'ValueText__c',
        'Text' => 'ValueText__c',
        'TextArea' => 'ValueTextArea__c',
        'LongTextArea' => 'ValueLongTextArea__c',
        'URL' => 'ValueURL__c'
        */
    }
    @AuraEnabled public Boolean dependencies_met { get; set; }
}