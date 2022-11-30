/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/3/2022.
 * Last Modified By: nicole.b@digitalmass.com 07/13/2022
 */


@IsTest
public class JustInTimePermissionSets_TEST {

    @TestSetup
    public static void setup(){
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        System.runAs(new User(Id = UserInfo.getUserId())){  
            Contact newContact = new Contact(
                FirstName = 'User', 
                LastName = 'Test85920'
            );
            User newUser = new User(
                Username = 'usertest85920@test.com',
                Email = 'usertest85920@test.com',
                Alias = 'usert',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profileId,
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                FirstName = 'User', 
                LastName = 'Test85920',
                ContactId = newContact.Id
            );
            insert newUser;
          

        PermissionSet permSet1 = new PermissionSet(
            Name = 'Test_Perm_Set_14353',
            Label = 'Test Perm Set 14353'
        );
        PermissionSet permSet2 = new PermissionSet(
            Name = 'Test_Perm_Set_2234435',
            Label = 'Test Perm Set 2234435'
        );
        PermissionSet permSet3 = new PermissionSet(
            Name = 'Test_Perm_Set_334534',
            Label = 'Test Perm Set 334534'
        );
        insert new List<PermissionSet>{permSet1, permSet2, permSet3};

        PermissionSetAssignment permSetAssignment1 = new PermissionSetAssignment(
            AssigneeId = newUser.Id,
            PermissionSetId = permSet1.Id
        );
        PermissionSetAssignment permSetAssignment2 = new PermissionSetAssignment(
            AssigneeId = newUser.Id,
            PermissionSetId = permSet2.Id
        );
        insert new List<PermissionSetAssignment>{permSetAssignment1, permSetAssignment2};
    	}
    }

    @IsTest
    public static void testJitPermission() {
        User newUser = [SELECT Id FROM User WHERE Email = 'usertest85920@test.com' LIMIT 1];
        List<JustInTimePermissionSets.userWithPermissionRequests> userPermReqs = new List<JustInTimePermissionSets.userWithPermissionRequests>();
        JustInTimePermissionSets.userWithPermissionRequests userPermReq = new JustInTimePermissionSets.userWithPermissionRequests();
        userPermReq.userId = newUser.Id;
        userPermReq.permissionSetNames = 'Test Perm Set 14353;Test Perm Set 2234435;Test Perm Set 334534;';
        userPermReqs.add(userPermReq);

        Test.startTest();
        JustInTimePermissionSets.jitPermission(userPermReqs);
        Test.stopTest();

        List<PermissionSetAssignment> permSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: newUser.Id];
        // 4 instead of 3 as there is a default permission set created
        System.assertEquals(4, permSetAssignments.size());
    }
}