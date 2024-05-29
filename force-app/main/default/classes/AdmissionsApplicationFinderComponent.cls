/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 7/5/2022.
 */


public with sharing class AdmissionsApplicationFinderComponent {

    public String selectedApplicationControl { get; set; }
    public Map<String, List<Application_Control__c>> acMapBySchool { get; set; }

    public AdmissionsApplicationFinderComponent() {
        List<Application_Control__c> applicationList = [
                SELECT Name, Id, School_College__c, Active__c, Show_on_App_Finder__c, URL_Parameter__c
                FROM Application_Control__c
                WHERE Active__c = TRUE AND Show_on_App_Finder__c = TRUE
                ORDER BY Name
        ];

        acMapBySchool = new Map<String, List<Application_Control__c>>();

        for (Application_Control__c ac : applicationList) {
            List<Application_Control__c> acList = new List<Application_Control__c>();
            if (acMapBySchool.containsKey(ac.School_College__c)) {
                acList = acMapBySchool.get(ac.School_College__c);
            }
            acList.add(ac);
            acMapBySchool.put(ac.School_College__c, acList);
        }
    }

    public List<SelectOption> getACs() {
        List<SelectOption> options = new List<SelectOption>();
        try {
            options.add(new SelectOption('', 'Select application type'));
            List<Application_Control__c> allACs = [SELECT URL_Parameter__c, Name FROM Application_Control__c WHERE Active__c = TRUE AND Show_on_App_Finder__c = TRUE ORDER BY Name];

            for (Application_Control__c acs : allACs) {
                options.add(new SelectOption(acs.URL_Parameter__c, acs.Name));
            }

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + '*' + e.getStackTraceString()));
        }
        return options;
    }

    public List<SelectOption> getSchools() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select a college'));

        for (String s : acMapBySchool.keySet()) {
            if (String.isNotBlank(s)) {
                options.add(new SelectOption(s, s));
            }
        }
        return options;
    }

    public PageReference goToApp() {
        PageReference appCreate = Page.ApplicationCreate;
        appCreate.getParameters().put('at', selectedApplicationControl);
        appCreate.setRedirect(true);
        return appCreate;
    }

}