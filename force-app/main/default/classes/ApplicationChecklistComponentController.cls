/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/23/2021.
 */


public with sharing class ApplicationChecklistComponentController {

    public Id appId { get; set; }
    public Id contactId { get; set; }
    public Application__c app { get; set; }
    public Application_Control__c appControl { get;set;}

    public ApplicationChecklistComponentController() {

    }

    public List<RequirementWrapper> getChecklistItems() {
        Map<Id, RequirementWrapper> reqMap = new Map<Id, RequirementWrapper>();
        Set<Id> reqIds = new Set<Id>();
        System.debug(appId);
        Application__c app = [
                SELECT Id, Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name,
                        Intended_Program__c, Applicant_Type__c, Citizenship__c, Delivery_Type__c, Student_Type__c,
                        Application_Status__c, School_College__c, Residency__c, Degree_Type__c, Application_Control__c,
                        Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, Contact__c
                FROM Application__c
                WHERE Id = :appId
        ];

        contactId = app.Contact__c;
        for (Requirement__c r : [
                SELECT Id, Internal_Only__c, Internal_Only_Show_on_Checklist__c, Display_on_Checklist__c, Name, Label__c, Active__c,
                        Intended_Program__c, Application_Status__c, Applicant_Type__c, Citizenship__c, Degree_Type__c, Delivery_Type__c,
                        Residency__c, School_College__c, Student_Type__c, Generic_Filter_1__c, Generic_Filter_2__c,
                        Generic_Filter_3__c, Generic_Filter_4__c
                FROM Requirement__c
                WHERE Application_Control__c = :appControl.Id
                AND Active__c = :true
                AND Show_on_Application_Creation__c = FALSE
                ORDER BY Display_Order__c ASC NULLS LAST
        ]) {
            if (ApplicationFilter.filter(app, r)) {
                reqIds.add(r.Id);
                reqMap.put(r.Id, new RequirementWrapper(r));
            }
        }
        System.debug(JSON.serializePretty(reqMap));

        return reqMap.values();

    }
}