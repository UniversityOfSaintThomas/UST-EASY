@isTest
private class UserApplicationTriggerHandler_TEST {
    
    @isTest
    private static void test_application_trigger_handler() {
        
        Test.startTest();
        
        new UserApplicationTriggerHandler();
        Database.insert(new List<User>{new User()}, false);
        
        Test.stopTest();
    }
}