@IsTest
public class requestForInformationFormControllerTest {
    @TestSetup
    public static void setup(){
        RFI_Controller__c controller = new RFI_Controller__c(
            Academic_Level__c = 'U',
            Fields_to_Display__c = 'Email',
            Required_Fields__c = 'Email'
        );
        insert controller;
    }

    @isTest
    public static void testCreateLead() {
        String record_input = '{"apiName": "Lead",' + '"fields": {'
        + '"FirstName": "Testing",'
        + '"LastName": "CreateLead",'
        + '"Company": "Company 1234"'
        + '}'
        + '}';
        Test.startTest();
        requestForInformationFormController.createLead(record_input, 'Lead');
        Test.stopTest();
        List<Lead> new_lead = [SELECT Id FROM Lead WHERE LastName = 'CreateLead'];
        System.assertEquals(1, new_lead.size());

    }

    @isTest
    public static void testGetRFIController() {
        RFI_Controller__c rfic = [SELECT Name FROM RFI_Controller__c LIMIT 1];
        System.debug(rfic);
        Test.startTest();
        RFI_Controller__c controller = requestForInformationFormController.getRFIController('RFI Controller-{0000}');
        Test.stopTest();
        System.assertEquals('Undergraduate', controller.Academic_Level__c);
    }
}