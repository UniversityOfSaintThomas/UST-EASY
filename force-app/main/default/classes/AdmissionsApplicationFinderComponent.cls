/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 7/5/2022.
 */


public with sharing class AdmissionsApplicationFinderComponent {

    public String schoolURLParameter { get; set; }
    public String selectedSchool { get; set; }
    public String selectedApp { get; set; }
    public Map<String, List<Application_Control__c>> acMapBySchool { get; set; }

    public AdmissionsApplicationFinderComponent() {
        List<Application_Control__c> applicationList = [
                SELECT Name, Id, School_College__c, Active__c, URL_Parameter__c
                FROM Application_Control__c
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

    public List<SelectOption> getSchools() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select...'));

        for (String s : acMapBySchool.keySet()) {
            if (String.isNotBlank(s)) {
                options.add(new SelectOption(s, s));
            }
        }
        return options;
    }

    public List<SelectOption> getApps() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select...'));
        if (String.isNotBlank(selectedSchool)) {
            for (Application_Control__c ac : acMapBySchool.get(selectedSchool)) {
                options.add(new SelectOption(ac.URL_Parameter__c, ac.Name));
            }
        }
        return options;
    }

    public PageReference goToApp() {
        PageReference appCreate = Page.ApplicationCreate;
        appCreate.getParameters().put('at', selectedApp);
        appCreate.setRedirect(true);
        return appCreate;
    }

}