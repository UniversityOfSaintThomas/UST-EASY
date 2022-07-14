global with sharing class ApplicationLoginController {

    global String username {get; set;}
    global String password {get; set;}     
 
    global PageReference login() {            
            
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        
        //String startUrl = 'apex/ApplicationPortal';
        return Site.login(username, password, startUrl);

    }
      
      global ApplicationLoginController () {}
  
         
}