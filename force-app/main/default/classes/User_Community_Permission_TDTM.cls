/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 11/6/2020.
 */


global class User_Community_Permission_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        List<PermissionSetAssignment> permissionsToAssign = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> permissionsToRemove = new List<PermissionSetAssignment>();
        System.debug('Community Permission assignment trigger reached!');

        //Get ids of permission sets in play in the Community_Permissions__c multi picklist
        List<String> communityPermissionsIds = new List<String>();
        List<Schema.PicklistEntry> PicklistValues = User.Community_Permissions__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry PicklistValue : PicklistValues) {
            communityPermissionsIds.add(convertTo18Id(PicklistValue.getValue()));
        }

        if (communityPermissionsIds.size() > 0) {

            //Create Map with a key of concatenated userId and assigned permission set id
            //key has id of permission set assignment for deletion purposes
            //Map contains only permission sets in play as defined by multi picklist above and currently triggered users records
            Map<String, String> userIDPermissionSetId = new Map<String, String>();
            for (PermissionSetAssignment permission : [SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :newList AND PermissionSetId IN :communityPermissionsIds]) {
                userIDPermissionSetId.put(String.valueOf(permission.AssigneeId) + String.valueOf(permission.PermissionSetId), permission.Id);
            }

            Map<Id, PermissionSet> allPermissionSets = new Map<Id, PermissionSet>([SELECT Id, Name FROM PermissionSet]);

            //If the user is now add any permissions that exist in their Community Permission picklist
            if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
                for (User u : (List<User>) newList) {
                    if (String.isNotBlank(u.Community_Permissions__c)) {
                        List<Id> newPermissions = u.Community_Permissions__c.split(';');
                        permissionsToAssign = sanitizePermissionSetAssignment(newPermissions, u.Id, userIDPermissionSetId, allPermissionSets, false);
                    }
                }
            }

            //If the user record is updated
            if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {

                //Map old record data with user id for comparison later
                Map<Id, User> oldListMap = new Map<Id, User>();
                for (User oldU : (List<User>) oldList) {
                    oldListMap.put(oldU.Id, oldU);
                }

                //Loop through all the newly affect user records
                for (User u : (List<User>) newList) {

                    //Get all the old community permissions settings from the old community permissions picklist
                    List<String> oldPermissions = new List<String>();
                    if (String.isNotEmpty(oldListMap.get(u.Id).Community_Permissions__c)) {
                        oldPermissions = oldListMap.get(u.Id).Community_Permissions__c.split(';');
                    }

                    if (String.isNotEmpty(u.Community_Permissions__c)) {
                        List<String> newPermissions = new List<String>();
                        if (String.isNotEmpty(u.Community_Permissions__c)) {
                            newPermissions = u.Community_Permissions__c.split(';');
                            //Remove overlapping permissions from old and new
                            if (oldPermissions.size() > 0) {
                                for (Integer i = (oldPermissions.size() - 1); i >= 0; i--) {
                                    if (newPermissions.contains(oldPermissions[i])) {
                                        oldPermissions.remove(i);
                                    }
                                }
                            }
                        }

                        //If the old community permission multi picklist does not match than something changed so lets adjust permissions
                        if (!u.Community_Permissions__c.equals(oldListMap.get(u.Id).Community_Permissions__c)) {
                            permissionsToAssign = sanitizePermissionSetAssignment(newPermissions, u.Id, userIDPermissionSetId, allPermissionSets, false);
                            permissionsToRemove = sanitizePermissionSetAssignment(oldPermissions, u.Id, userIDPermissionSetId, allPermissionSets, true);
                        }
                    } else {
                        //If the community permission field is empty any old permissions in play should be removed
                        permissionsToRemove = sanitizePermissionSetAssignment(oldPermissions, u.Id, userIDPermissionSetId, allPermissionSets, true);
                    }
                }
            }

            if (permissionsToAssign.size() > 0) {
                try {
                    insert permissionsToAssign;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }

            if (permissionsToRemove.size() > 0) {
                try {
                    delete permissionsToRemove;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
        }

        return dmlWrapper;
    }

    private Id convertTo18Id(String stringId) {
        //This method converts short ids that might have been entered into the community permissions multi picklist by mistake.
        Id sID = null;
        try {
            sID = stringId;
        } catch (System.StringException e) {
            System.debug(e.getMessage());
        }
        return sID;
    }

    private List<PermissionSetAssignment> sanitizePermissionSetAssignment(List<String> newPermissions, String userId, Map<String, String> userIDPermissionSetId, Map<Id, PermissionSet> allPermissionSets, Boolean toRemove) {
        List<PermissionSetAssignment> permissionsOut = new List<PermissionSetAssignment>();
        for (String permissionID : newPermissions) {
            Id permissionId18 = convertTo18Id(permissionID);
            if (permissionId18 != null) {
                //Check if the mapped permission set exists so we don't add or delete permissions sets that are already in place

                System.debug('PERMISSION SET MATCH: ' + permissionId18);
                if (userIDPermissionSetId.containsKey(String.valueOf(userId) + String.valueOf(permissionId18)) == toRemove) {
                    if (allPermissionSets.containsKey(permissionId18)) {
                        PermissionSetAssignment permissionSetChange = new PermissionSetAssignment();
                        permissionSetChange.AssigneeId = userId;
                        permissionSetChange.PermissionSetId = permissionId18;
                        //Add id to allow deletion if permission set is to be removed.
                        if (toRemove) {
                            permissionSetChange.Id = userIDPermissionSetId.get(String.valueOf(userId) + String.valueOf(permissionId18));
                        }
                        permissionsOut.add(permissionSetChange);
                    }
                }
            }
        }

        return permissionsOut;
    }


}