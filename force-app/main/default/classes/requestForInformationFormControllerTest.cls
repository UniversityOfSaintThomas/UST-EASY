@IsTest
public class requestForInformationFormControllerTest {
    @TestSetup
    public static void setup(){
        RFI_Controller__c controller = new RFI_Controller__c(
            Academic_Level__c = 'U',
            Fields_to_Display__c = 'Email',
            Required_Fields__c = 'Email',
            Redirect_Url__c = 'https://developer.salesforce.com',
            School_College__c = 'Undergraduate'
        );
        
        insert controller;
    }

    @isTest
    public static void testCreateLead() {
        String record_input_fields = '{"FirstName":"Testing","LastName":"CreateLead","Company":"Company 123"}';
        Test.startTest();
        requestForInformationFormController.createLead(record_input_fields, 'Lead');
        Test.stopTest();
        List<Lead> new_lead = [SELECT Id FROM Lead WHERE LastName = 'CreateLead'];
        System.assertEquals(1, new_lead.size());

    }

    @isTest
    public static void testGetRFIController() {
        RFI_Controller__c rfic = [SELECT Name FROM RFI_Controller__c];
        Test.startTest();
        RFI_Controller__c controller = requestForInformationFormController.getRFIController(rfic.Name);
        Test.stopTest();
        System.assertEquals('U', controller.Academic_Level__c);
    }

}