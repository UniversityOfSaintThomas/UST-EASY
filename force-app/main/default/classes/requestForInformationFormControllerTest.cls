@IsTest
public class requestForInformationFormControllerTest {
    @TestSetup
    public static void setup(){
        RFI_Controller__c controller = new RFI_Controller__c(
            Academic_Level__c = 'Undergraduate',
            Fields_to_Display__c = 'First Name;Last Name;Email;Home Phone;Mobile Phone;Address 1;Address 2;City;Zip Code;Country;Citizenship;Academic Interest;Birthdate;Expected Start Term;High School Attended;High School Graduation Year'
        );
        insert controller;
    }

    @isTest
    public static void testgetRFIController() {
        Test.startTest();
        RFI_Controller__c controller = requestForInformationFormController.getRFIController('RFI Controller-{0000}');
        Test.stopTest();
        System.assertEquals('Undergraduate', controller.Academic_Level__c);
    }
}