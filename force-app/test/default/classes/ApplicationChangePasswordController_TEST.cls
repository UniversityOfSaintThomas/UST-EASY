/**
 * An apex page controller that exposes the change password functionality for the UST Applicant Portal -- FDF July 2022
 */
@IsTest public with sharing class ApplicationChangePasswordController_TEST {
     @IsTest(SeeAllData=true) public static void testApplicationChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ApplicationChangePasswordController controller = new ApplicationChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.ApplicationchangePassword(),null);                           
    }    
}