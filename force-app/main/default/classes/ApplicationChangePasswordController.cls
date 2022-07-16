/**
 * An apex page controller that exposes the change password functionality for the UST Applicant Portal  -- FDF July 2022
 */
 
public with sharing class ApplicationChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference ApplicationChangePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
     public ApplicationChangePasswordController() {}
}