@isTest
public class AdmissionsApplicationFinderCmp_TEST {
    @TestSetup
    static void setup(){
        Application_Control__c appControl = new Application_Control__c(
            Application_Start_Status__c = Application_Control__c.Application_Start_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Active__c = true,
            Allow_Cancel_From__c = Application_Control__c.Allow_Cancel_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Allow_Withdraw_From__c = Application_Control__c.Allow_Withdraw_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Allow_Submit_From__c = Application_Control__c.Allow_Submit_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Cancel_Status__c = Application_Control__c.Cancel_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Default__c = true,
            URL_Parameter__c = 'st',
            Submit_Status__c = Application_Control__c.Submit_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Withdraw_Status__c = Application_Control__c.Withdraw_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            School_College__c = 'Undergraduate'
        );
        insert appControl;
    }

    @isTest
    public static void testGetSchools() {
        AdmissionsApplicationFinderComponent component = new AdmissionsApplicationFinderComponent();

        Test.startTest();
        List<SelectOption> options = component.getSchools();
        Test.stopTest();

        List<SelectOption> expected = new List<SelectOption>();
        expected.add(new SelectOption('', 'Select...'));
        expected.add(new SelectOption('Undergraduate', 'Undergraduate'));

        System.assertEquals(String.valueOf(expected), String.valueOf(options));
    }

    @isTest
    public static void testGetApps() {
        Application_Control__c appControl = [SELECT Name FROM Application_Control__c LIMIT 1];
        AdmissionsApplicationFinderComponent component = new AdmissionsApplicationFinderComponent();
        component.selectedSchool = 'Undergraduate';

        Test.startTest();
        List<SelectOption> options = component.getApps();
        Test.stopTest();

        List<SelectOption> expected = new List<SelectOption>();
        expected.add(new SelectOption('', 'Select...'));
        expected.add(new SelectOption('st', appControl.Name));

        System.assertEquals(String.valueOf(expected), String.valueOf(options));

    }

    @isTest
    public static void testGoToApp() {
        AdmissionsApplicationFinderComponent component = new AdmissionsApplicationFinderComponent();
        component.selectedApp = 'test';

        Test.startTest();
        PageReference returnPage = component.goToApp();
        Test.stopTest();

        PageReference expected = Page.ApplicationCreate;
        expected.getParameters().put('at', 'test');

        System.assertEquals(String.valueOf(expected), String.valueOf(returnPage));
    }
}