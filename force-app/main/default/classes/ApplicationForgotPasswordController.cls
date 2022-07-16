public with sharing class ApplicationForgotPasswordController {

    public String username {get; set;}   
       
    public ApplicationForgotPasswordController() {}
  
    public PageReference ApplicationForgotPassword() {
      Boolean success = Site.forgotPassword(username);
      PageReference pr = Page.ApplicationForgotPasswordConfirm;
      pr.setRedirect(true);
      
      if (success) {        
        return pr;
      }
      return null;
    }
}