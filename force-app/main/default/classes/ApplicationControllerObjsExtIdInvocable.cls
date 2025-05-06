/**
 * Created by nguy0092 on 4/10/2025.
 * Update external Id fields for Application Control and related objects to use for upsert.
 */

public with sharing class ApplicationControllerObjsExtIdInvocable {
    @InvocableMethod(Label='Application Controller related objects external Id field update' Description='Finds Application Controller and related objects and updates external Id field.')
    public static void ApplicationControllerObjsExtIdInvocable() {

        List<Application_Control__c> applicationController = [
                SELECT Id,
                        Application_Control_External_ID__c
                FROM Application_Control__c
                WHERE NOT Application_Control_External_ID__c LIKE 'AppCtrUuid-%'
        ];
        System.debug('What is applicationController size 1: '+applicationController.size());

        for(Application_Control__c a : applicationController) {
            a.Application_Control_External_ID__c = 'AppCtrUuid-'+UUID.randomUUID();
        }

        if(!applicationController.isEmpty()) {
            System.debug('What is applicationController size 2: '+applicationController.size());
            update applicationController;
        }

        List<Requirement__c> requirement = [
                SELECT Id,
                        Requirement_Integration_External_Id__c
                FROM Requirement__c
                WHERE NOT Requirement_Integration_External_Id__c LIKE 'ReqmntUuid-%'
        ];
        System.debug('What is requirements size 1: '+requirement.size());

        for(Requirement__c r : requirement) {
            r.Requirement_Integration_External_Id__c = 'ReqmntUuid-'+UUID.randomUUID();
        }

        if(!requirement.isEmpty()) {
            System.debug('What is requirements size 2: '+requirement.size());
            update requirement;
        }

        List<Requirement_Item__c> requirementItem = [
                SELECT Id,
                        Requirement_Item_Integration_Ext_Id__c
                FROM Requirement_Item__c
                WHERE NOT Requirement_Item_Integration_Ext_Id__c LIKE 'ReqItemUuid-%'
        ];
        System.debug('What is requirementItem size 1: '+requirementItem.size());

        for(Requirement_Item__c ri : requirementItem) {
            ri.Requirement_Item_Integration_Ext_Id__c = 'ReqItemUuid-'+UUID.randomUUID();
        }

        if(!requirementItem.isEmpty()) {
            System.debug('What is requirementItem size 2: '+requirementItem.size());
            update requirementItem;
        }
    }
}