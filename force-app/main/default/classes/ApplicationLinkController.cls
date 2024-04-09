/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 11/21/2022.
 */


public with sharing class ApplicationLinkController {

    public ApplicationLinkController() {

    }

    public PageReference goToRequirement() {

        EASYApplicationInfo appInfo = ApplicationUtilities.gatherApplicationInfo();
        EASYApplicationInfo newAppInfo = new EASYApplicationInfo();
        PageReference requirementPage = null;

        Id urlRequirementId = null;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('requirementId'))) {
            try {
                urlRequirementId = ApexPages.currentPage().getParameters().get('requirementId');
            } catch (Exception ex) {

            }
        }

        if (String.isNotBlank(urlRequirementId)) {

            System.debug(urlRequirementId);

            Application_Control__c applicationControl = [
                    SELECT Id, Allow_Submit_From__c, Allow_Withdraw_From__c,
                            Hide_Term_Program__c, Submit_Status__c, Allow_Confirm_From__c, Confirm_Status__c,
                            Withdraw_Status__c, Academic_Level__c, School_College__c, Template__c, URL_Parameter__c,
                            Application_Start_Status__c, Allow_Cancel_From__c
                    FROM Application_Control__c
                    WHERE Id IN (SELECT Application_Control__c FROM Requirement__c WHERE Id = :urlRequirementId)
            ];

            if (applicationControl.URL_Parameter__c != appInfo.at) {
                List<Application__c> app = [
                        SELECT Id, Contact__c, Application_Status__c, Application_Substatus__c, Citizenship__c,
                                Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name
                        FROM Application__c
                        WHERE Contact__c = :appInfo.contactId
                        AND Application_Control__c = :applicationControl.Id
                        AND Application_Status__c != 'Wrong Application'
                        AND (NOT(Application_Status__c = 'Withdrawn' AND Application_Substatus__c = 'Wrong App'))
                        AND (NOT(Application_Status__c = 'Withdrawn' AND Application_Substatus__c = 'Multiple App'))
                        ORDER BY LastModifiedDate
                ];
                if(app.size() > 0 && applicationControl != null) {
                    newAppInfo = ApplicationUtilities.setApplicationInfo(applicationControl, app[0]);
                    newAppInfo.requirementId = urlRequirementId;
                }
            } else {
                newAppInfo = appInfo;
                newAppInfo.requirementId = urlRequirementId;
            }
            ApplicationUtilities.createEncryptedCookie(JSON.serialize(newAppInfo));
            requirementPage = Page.ApplicationRequirement;
            requirementPage.getParameters().put('at', applicationControl.URL_Parameter__c);
            requirementPage.getParameters().put('requirementId', urlRequirementId);
            requirementPage.setRedirect(true);
        }

        return requirementPage;
    }

}