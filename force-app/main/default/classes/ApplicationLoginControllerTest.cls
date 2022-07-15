/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class ApplicationLoginControllerTest {
    @IsTest(SeeAllData=true) global static void testApplicationLoginController () {
        // Instantiate a new controller with all parameters in the page
        ApplicationLoginController controller = new ApplicationLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}