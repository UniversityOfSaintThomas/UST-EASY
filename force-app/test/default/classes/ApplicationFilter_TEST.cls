@isTest
private class ApplicationFilter_TEST {
    
    @isTest
    static void test_application_filter() {
        
        Program__c p = new Program__c(Name = 'test');
        insert p;
        
        Requirement__c r = new Requirement__c();
        Application__c app = new Application__c();
        
        Test.startTest();
        
        // Null application should pass
        System.assert(ApplicationFilter.filter(null, r));
        
        // Inactive should never show
        r.Active__c = false;
        System.assert(!ApplicationFilter.filter(app, r));
        r.Active__c = true;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Intended Program
        r.Intended_Program__c = p.Id;
        System.assert(!ApplicationFilter.filter(app, r));
        app.Intended_Program__c = p.Id;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Applicant Type
        r.Applicant_Type__c = Requirement__c.Applicant_Type__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Applicant_Type__c = r.Applicant_Type__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Citizenship
        r.Citizenship__c = Requirement__c.Citizenship__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Citizenship__c = r.Citizenship__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // School/College
        r.School_College__c = Requirement__c.School_College__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.School_College__c = r.School_College__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Delivery Type
        r.Delivery_Type__c = Requirement__c.Delivery_Type__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Delivery_Type__c = r.Delivery_Type__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Residency
        r.Residency__c = Requirement__c.Residency__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Residency__c = r.Residency__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Student Type
        r.Student_Type__c = Requirement__c.Student_Type__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Student_Type__c = r.Student_Type__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Degree Type
        r.Degree_Type__c = Requirement__c.Degree_Type__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Degree_Type__c = r.Degree_Type__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Generic Filter 1
        r.Generic_Filter_1__c = Requirement__c.Generic_Filter_1__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Generic_Filter_1__c = r.Generic_Filter_1__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Generic Filter 2
        r.Generic_Filter_2__c = Requirement__c.Generic_Filter_2__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Generic_Filter_2__c = r.Generic_Filter_2__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Generic Filter 3
        r.Generic_Filter_3__c = Requirement__c.Generic_Filter_3__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Generic_Filter_3__c = r.Generic_Filter_3__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Generic Filter 4
        r.Generic_Filter_4__c = Requirement__c.Generic_Filter_4__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Generic_Filter_4__c = r.Generic_Filter_4__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        // Status
        r.Application_Status__c = Requirement__c.Application_Status__c.getDescribe().getPicklistValues()[0].getValue();
        System.assert(!ApplicationFilter.filter(app, r));
        app.Application_Status__c = r.Application_Status__c;
        System.assert(ApplicationFilter.filter(app, r));
        
        Test.stopTest();
    }
}