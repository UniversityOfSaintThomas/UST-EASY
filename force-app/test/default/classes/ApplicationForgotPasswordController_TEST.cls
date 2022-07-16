/**
 * An apex page controller that exposes the site forgot password functionality
 */
@IsTest public with sharing class ApplicationForgotPasswordController_TEST {
     @IsTest(SeeAllData=true) public static void testApplicationForgotPasswordController() {
      // Instantiate a new controller with all parameters in the page
      ApplicationForgotPasswordController controller = new ApplicationForgotPasswordController();
      controller.username = 'test@salesforce.com';       
    
      System.assertEquals(controller.ApplicationforgotPassword(),null); 
    }
}