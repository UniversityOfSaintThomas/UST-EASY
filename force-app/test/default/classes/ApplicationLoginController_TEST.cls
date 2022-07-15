/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class ApplicationLoginController_TEST {
    @IsTest(SeeAllData=true) global static void testApplicationLoginController() {
        // Instantiate a new controller with all parameters in the page
        ApplicationLoginController controller = new ApplicationLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456';

        System.assertEquals(controller.login(), null);
    }

    @IsTest
    public static void testLoginState() {
        ApplicationLoginController controller = new ApplicationLoginController ();
        PageReference testPage = controller.checkIfLoggedIn();
        System.assertEquals(testPage,null);

        System.runAs(getPortalUser('CspLitePortal', null, true)) {
            testPage = controller.checkIfLoggedIn();
            System.assertEquals(testPage.getUrl(), '/apex/applicationportal');

            PageReference pageRef = Page.ApplicationLogin;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('startURL', 'stThomas');
            testPage = controller.checkIfLoggedIn();
            System.assertEquals(testPage.getUrl(), '/stThomas');
        }
    }

    public static User getPortalUser(String portalType, User userWithRole, Boolean doInsert) {

        /* Make sure the running user has a role otherwise an exception
           will be thrown. */
        if (userWithRole == null) {

            if (UserInfo.getUserRoleId() == null) {

                UserRole r = new UserRole(name = 'TEST ROLE');
                Database.insert(r);

                userWithRole = new User(alias = 'hasrole', email = 'userwithrole@roletest1.com', userroleid = r.id,
                        emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                        localesidkey = 'en_US', profileid = UserInfo.getProfileId(),
                        timezonesidkey = 'America/Los_Angeles', username = 'userwithrole@testorg.com');
            } else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }

            System.assert(userWithRole.userRoleId != null,
                    'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');
        }

        Account a;
        Contact c;
        System.runAs(userWithRole) {

            a = new Account(name = 'TEST ACCOUNT');
            Database.insert(a);

            c = new Contact(AccountId = a.id, lastname = 'lastname');
            Database.insert(c);

        }

        /* Get any profile for the given type.*/
        Profile p = [
                select id
                from profile
                where usertype = :portalType
                limit 1
        ];

        String testemail = 'puser000@amamama.com';
        User pu = new User(profileId = p.id, username = testemail, email = testemail,
                emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                alias = 'cspu', lastname = 'lastname', contactId = c.id);

        if (doInsert) {
            Database.insert(pu);
        }
        return pu;
    }

}