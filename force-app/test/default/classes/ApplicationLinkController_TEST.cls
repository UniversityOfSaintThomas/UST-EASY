/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 11/21/2022.
 */


@IsTest
private class ApplicationLinkController_TEST {

    @TestSetup
    public static void setupData() {
        ApplicationRequirement_TEST.setupData();
    }

    @IsTest
    static void testBehavior() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Requirement__c req = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req' LIMIT 1];
        Requirement__c req2 = [SELECT Id FROM Requirement__c WHERE Name = 'Test Req 2' LIMIT 1];

        PageReference pr = Page.ApplicationLink;
        pr.getParameters().put('requirementId', req.Id);
        Test.setCurrentPage(pr);

        ApplicationLinkController appLinkController = new ApplicationLinkController();

        PageReference pageOut = appLinkController.goToRequirement();

        Test.startTest();
        System.assertEquals(pageOut.getUrl(), '/apex/applicationrequirement?at=st&requirementId=' + req.Id);
        Test.stopTest();

    }
}