/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/14/2022.
 */


public with sharing class thadExperiment {

    public thadExperiment() {
        String appId = ApexPages.currentPage().getParameters().get('applicationId');

        Application_Control__c appControl =[SELECT Id, Hide_Term_Program__c, Application_Start_Status__c,
                Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c, Arrow_Color__c, Button_Color__c, Button_Text_Color__c,
                Cancel_Status__c, Line_Color__c, Link_Color__c, Logo_Static_Resource__c, Logo_Static_Resource_Path__c,
                Submit_Status__c, Withdraw_Status__c, Text_Color__c, URL_Parameter__c, Default__c, Academic_Level__c, School_College__c, Degree_Levels__c,
                Template__c
        FROM Application_Control__c
        WHERE Id = :appId];

    }

}