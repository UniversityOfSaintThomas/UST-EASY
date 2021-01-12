/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 11/12/2020.
 */


public with sharing class CommunityAssignmentController {

    public String nextURL1 { get; set; }
    public String nextURL { get; set; }
    public String referURL1 { get; set; }
    public String userInfoJSON { get; set; }
    public String community { get; set; }

    public CommunityAssignmentController() {
        nextURL1 = UserInfo.getUserType();// userInfo.getUserType();
        referURL1 = ApexPages.currentPage().getHeaders().get('Referer');
        community = '';
        ApexPages.currentPage().getParameters().get('audience');
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('community'))) {
            community = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('community')).toLowerCase();
        }
        // userInfo = JSON.serializePretty(UserInfo);
    }

    public PageReference assign() {

        PageReference pr;
        //String nextURL = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('url'));
        String referURL = ApexPages.currentPage().getHeaders().get('Referer');
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('community'))) {
            community = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('community')).toLowerCase();
        }
        Boolean addNewPermissionSet = false;

        userInfoJSON = JSON.serializePretty(UserInfo.getUserType());
        List<String> acceptableUserTypes = new List<String>{
                'Standard', 'PowerPartner', 'CspLitePortal', 'CustomerSuccess', 'PowerCustomerSuccess'
        };

        if (acceptableUserTypes.contains(UserInfo.getUserType()) && String.isNotBlank(community)) {
            System.debug('GOT through to the assign permissions. User type: ' + UserInfo.getUserType() + ', community: ' + community);
            Map<String, String> permissionsByLabel = getCommunityPermissionsetsByLabel();
            System.debug(JSON.serializePretty(permissionsByLabel));

            User currentUser = [
                    SELECT Id, ContactId, Community_Permissions__c
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
            ];

            System.debug(JSON.serializePretty(currentUser));

            //Check if user record already has permission set assigned
            String permissionSetId = '';
            if (currentUser != null) {
                switch on community.toLowerCase() {
                    when 'applicant' {
                        System.debug('made it to the applicant switch');
                        //Everyone can apply so no checks here, for other community do check for valid user
                        Application_Setting__c applicationSettings = Application_Setting__c.getOrgDefaults();
                        nextURL = applicationSettings.Community_URL__c;
                        permissionSetId = permissionsByLabel.get('Applicant');
                        if (String.isNotBlank(permissionSetId)) {
                            if (String.isBlank(currentUser.Community_Permissions__c)) {
                                addNewPermissionSet = true;
                            } else if (!currentUser.Community_Permissions__c.contains(permissionSetId)) {
                                addNewPermissionSet = true;
                            }
                            if (!nextURL.endsWith('/')) {
                                nextURL += '/';
                            }
                            nextURL += 'ApplicationPortal';
                        }
                    }
                    when else {
                        //Nothing matched
                    }
                }

                if (addNewPermissionSet) {
                    System.debug('made it to the add new permission set');
                    Id newPermissionSetId = convertTo18Id(permissionSetId);
                    if (newPermissionSetId != null) {
                        if (String.isEmpty(currentUser.Community_Permissions__c) && String.isNotBlank(permissionSetId)) {
                            currentUser.Community_Permissions__c = permissionSetId;
                        } else if (!currentUser.Community_Permissions__c.contains(community)) {
                            currentUser.Community_Permissions__c = currentUser.Community_Permissions__c + ';' + permissionSetId;
                        }
                        update currentUser;
                        addNewPermissionSet = true;
                    } else {
                        addNewPermissionSet = false;
                    }

                }

                if (addNewPermissionSet) {
                    System.debug('update success!');
                    pr = new PageReference(nextURL);
                    Map<String, String> parameters = ApexPages.currentPage().getParameters();
                    for (String s : parameters.keySet()) {
                        if (!s.equalsIgnoreCase('url') && !s.equalsIgnoreCase('community')) {
                            pr.getParameters().put(s, ApexPages.currentPage().getParameters().get(s));
                        }
                        pr.setRedirect(true);
                    }
                } else {
                    //go to login with parameters in place
                }
            }
        } else {
            //go to login with parameters in place
        }
        //return null;
        return pr;
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

    Map<String, String> getCommunityPermissionsetsByLabel() {
        Map<String, String> foundPermissions = new Map<String, String>();
        Schema.DescribeFieldResult field = User.Community_Permissions__c.getDescribe();
        for (Schema.PicklistEntry f : field.getPicklistValues()) {
            foundPermissions.put(f.getLabel(), f.getValue());

        }
        return foundPermissions;
    }


}