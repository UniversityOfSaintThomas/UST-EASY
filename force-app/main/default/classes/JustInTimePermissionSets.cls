/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 1/25/2021.
 */

global without sharing class JustInTimePermissionSets {

    @InvocableMethod(
            Label='JIT Permission Sets'
            Description='Applies Permission Sets to qualified users on login'
            Category= 'User'
    )
    public static void jitPermission(List<userWithPermissionRequests> permissionRequests) {
        List<String> allRequestedPermissionSetNames = new List<String>();
        List<String> userIdsAffected = new List<String>();

        //Get list of requested permission set names
        for (userWithPermissionRequests userPermRequest : permissionRequests) {
            userPermRequest.permissionSetNames = userPermRequest.permissionSetNames.trim().removeEnd(';').trim().replace(' ', '_');
            allRequestedPermissionSetNames.addAll(userPermRequest.permissionSetNames.split(';'));
            userIdsAffected.add(userPermRequest.userId);
        }

        List<Id> contactAffectedIds = new List<Id>();

        List<User> usersAffected = 
        [
            SELECT 
                Id, 
                ContactId,
                Contact.Portal_User_First_Login__c,
                Contact.Portal_User_Latest_Login__c
            FROM User
            WHERE Id IN :userIdsAffected
        ];

        List<Contact> contactsToUpdate = new List<Contact>();
        //Populate Portal User First Login and Portal User Latest Login on Contact for each UserID
        for(User user : usersAffected) {
            Contact new_contact = new Contact(
                Id = user.ContactId,
                Portal_User_First_Login__c = user.Contact.Portal_User_First_Login__c,
                Portal_User_Latest_Login__c = user.Contact.Portal_User_Latest_Login__c
                );
            if (new_contact.Portal_User_First_Login__c == null) {
                new_contact.Portal_User_First_Login__c = System.today();
            }
            new_contact.Portal_User_Latest_Login__c = System.today();
            contactsToUpdate.add(new_contact);
        }

        if(contactsToUpdate.size() > 0){
            upsert contactsToUpdate;
        }

        //Map permission sets by name as key id as value
        List<PermissionSet> requestedPermissionSets = [
                SELECT Id, Name
                FROM PermissionSet
                WHERE Name IN :allRequestedPermissionSetNames
        ];

        Map<String, Id> requestedPermissionSetsByName = new Map<String, Id>();
        for (PermissionSet perm : requestedPermissionSets) {
            requestedPermissionSetsByName.put(perm.Name, perm.Id);
        }

        //Get the list of permission sets the user already has. Map it by user id with a list of permission ids as values.
        List<PermissionSetAssignment> currentPermissions = [
                SELECT PermissionSetId, Id,AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId IN :userIdsAffected
        ];

        //Get list of permission each user already has
        Map<Id, List<Id>> userAlreadyAssignedPermissionIds = new Map<Id, List<Id>>();
        for (PermissionSetAssignment currentPermission : currentPermissions) {
            List<Id> listOfPermissionIds = new List<Id>();
            //Check if user already has the permission set or not using mapped by name variable
            if (userAlreadyAssignedPermissionIds.containsKey(currentPermission.AssigneeId)) {
                if (String.isNotBlank(currentPermission.PermissionSetId)) {
                    List<Id> oldPermIds = userAlreadyAssignedPermissionIds.get(currentPermission.AssigneeId);
                    oldPermIds.add(currentPermission.PermissionSetId);
                    userAlreadyAssignedPermissionIds.put(currentPermission.AssigneeId, oldPermIds);
                }
            } else {
                listOfPermissionIds.add(currentPermission.PermissionSetId);
                userAlreadyAssignedPermissionIds.put(currentPermission.AssigneeId, listOfPermissionIds);
            }
        }

        List<PermissionSetAssignment> permissionsToInsert = new List<PermissionSetAssignment>();
        for (userWithPermissionRequests userPermRequest : permissionRequests) {
            userPermRequest.permissionSetNames = userPermRequest.permissionSetNames.trim().removeEnd(';').trim().replace(' ', '_');
            List<String> userPermissionSetNames = new List<String>(userPermRequest.permissionSetNames.split(';'));
            for (String permissionName : userPermissionSetNames) {
                List<Id> alreadyAssignedPermissions = userAlreadyAssignedPermissionIds.get(userPermRequest.userId);
                //Check if user already has permission set and don't add it
                if (!alreadyAssignedPermissions.contains(requestedPermissionSetsByName.get(permissionName))) {
                    if (String.isNotBlank(userPermRequest.userId) && String.isNotBlank(requestedPermissionSetsByName.get(permissionName))) {
                        PermissionSetAssignment permissionSetChange = new PermissionSetAssignment();
                        permissionSetChange.AssigneeId = userPermRequest.userId;
                        permissionSetChange.PermissionSetId = requestedPermissionSetsByName.get(permissionName);
                        permissionsToInsert.add(permissionSetChange);
                    }
                }
            }
        }

        if (permissionsToInsert.size() > 0) {
            try {
                upsert permissionsToInsert;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

    }

    global class userWithPermissionRequests {
        @InvocableVariable
        global String userId;

        @InvocableVariable
        global String permissionSetNames;
    }

}