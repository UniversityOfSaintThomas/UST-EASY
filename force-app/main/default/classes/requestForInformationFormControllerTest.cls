@IsTest
public class requestForInformationFormControllerTest {
    @TestSetup
    public static void setup(){
        RFI_Controller__c controller = new RFI_Controller__c(
            Name = 'All Fields RFI Controller', 
            Applicant_Type__c = 'First-Year',
            Fields_to_Display__c = 'First Name;Last Name;Email;Home Phone;Mobile Phone;Address 1;Address 2;City;Zip Code;Country;Citizenship;Academic Interest;Birthdate;Expected Start Term;High School Attended;High School Graduation Year'
        );
        insert controller;
    }

    @isTest
    public static void testgetRFIController() {
        Test.startTest();
        RFI_Controller__c controller = requestForInformationFormController.getRFIController('All Fields RFI Controller');
        Test.stopTest();
        System.assertEquals('First-Year', controller.Applicant_Type__c);
    }
}
