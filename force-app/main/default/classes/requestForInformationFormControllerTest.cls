@IsTest
public class requestForInformationFormControllerTest {
    @isTest
    public static void testgetRFIController() {
        Test.startTest();
        RFI_Controller__c controller = requestForInformationFormController.getRFIController('All Fields RFI Controller');
        Test.stopTest();
        System.assertEquals('First-Year', controller.Applicant_Type__c);
    }
}
