/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */


public with sharing class appReviewController {

    @AuraEnabled(cacheable=true)
    public static Application__c getApplicantInfo(String appId) {
        System.debug(appId);
        return [
                SELECT Id, Name, Contact__r.FirstName, Contact__r.LastName
                FROM Application__c
                WHERE id = :appId
                WITH USER_MODE
                LIMIT 1
        ];
    }
}