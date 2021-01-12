/*******************************************************************************
@description This controller is used to display a list of applications available to the contact
@author Huron Consulting Group

Revision (s): 
*******************************************************************************/
public class ApplicationPortal {

    public Id contactId { get; set; }
    public List<Application__c> apps { get; set; }

    public Application_Control__c appControl {
        get {
            if (appControl == null) {
                appControl = ApplicationUtilities.getApplicationControls(ApexPages.currentPage().getParameters().get('at'));
            }
            return appControl;
        }
        set;
    }

    public PageReference init() {
        crudToDo doCrud = new crudToDo();
        PageReference pr;
        Id applicationCommunityId = doCrud.getApplicationCommunityId();
        User currentUser = [
                SELECT Id, Community_Permissions__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
        ];
        if (currentUser != null && applicationCommunityId != null) {
            if (String.isEmpty(currentUser.Community_Permissions__c)) {
                pr = doCrud.checkPermissionSetAssignment(currentUser, applicationCommunityId);
            } else if (!currentUser.Community_Permissions__c.contains(applicationCommunityId)) {
                pr = doCrud.checkPermissionSetAssignment(currentUser, applicationCommunityId);
            }
            return pr;
        }
        return pr;
    }


    public ApplicationPortal() {

        if (UserInfo.getUserType().equals('Standard')) {

            User currentUser = [
                    SELECT Id, ContactId, Community_Permissions__c
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
            ];

            contactId = currentUser.ContactId;

//            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('contactId'))) {
//                contactId = Id.valueOf(ApexPages.currentPage().getParameters().get('contactId'));
//            } else {
//                contactId = [
//                        SELECT Id, ContactId, Community_Permissions__c
//                        FROM User
//                        WHERE Id = :UserInfo.getUserId()
//                ].ContactId;
//            }
            if (String.isNotBlank(contactId)) {
                apps = [
                        SELECT Id, Name,Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c,
                                Intended_Term_of_Entry__r.Name, Application_Status__c
                        FROM Application__c
                        WHERE Contact__c = :contactId
                        ORDER BY Intended_Term_of_Entry__r.Activate_Application_Date__c
                ];
            }
        }


//            apps = [
//                    SELECT Id, Name,Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c,
//                            Intended_Term_of_Entry__r.Name, Application_Status__c
//                    FROM Application__c WHERE Application_Control__c = :appControl.Id
//                    AND Contact__c = :contactId ORDER BY Intended_Term_of_Entry__r.Activate_Application_Date__c
//            ];


    }


    private without sharing class crudToDo {

        public Id getApplicationCommunityId() {
            Id permissionSetId = null;
            List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Application_Community'];
            if (permissionSets.size() > 0) {
                permissionSetId = permissionSets[0].Id;
            }
            return permissionSetId;
        }

        public PageReference checkPermissionSetAssignment(User CurrentUser, Id applicationCommunityId) {
            System.debug('Reached Permission set check.');
            PageReference pr;
            Boolean permissionChangeMade = false;
            if (String.isEmpty(currentUser.Community_Permissions__c)) {
                currentUser.Community_Permissions__c = currentUser.Community_Permissions__c;
                permissionChangeMade = true;
            } else if (!currentUser.Community_Permissions__c.contains(applicationCommunityId)) {
                currentUser.Community_Permissions__c = currentUser.Community_Permissions__c + ';' + applicationCommunityId;
                permissionChangeMade = true;
            }
            System.debug('Permissions Changed : ' + permissionChangeMade);
            if (permissionChangeMade) {

                update currentUser;
                System.debug('update success!');
                pr = Page.ApplicationPortal;
                pr.setRedirect(true);
                for (String s : new Set<String>{
                        'contactId', 'applicationId', 'at'
                }) {
                    pr.getParameters().put(s, ApexPages.currentPage().getParameters().get(s));
                }

            }
            return pr;
        }


    }

}