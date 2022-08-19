/*******************************************************************************
@description This controller is used to allow internal users the ability to review an application
@author Huron Consulting Group

Revision (s):
*******************************************************************************/
public class ApplicationReview {

    public Id applicationId { get; set; }
    public List<Requirement__c> reqs { get; set; }
    public Application__c app { get; set; }
    public List<ApplicationRequirement> arLst { get; set; }
    public Application_Review__c review { get; set; }
    public Map<String, ApplicationQuestion> questionHolderMap { get; set; }
    public EASYApplicationInfo appInfo { get; set; }

    public Contact con {
        get {
            if (con == null) {
                for (ApplicationRequirement ar : arLst) {
                    if (ar.section.con != null) {
                        con = ar.section.con;
                        break;
                    }
                }
            }
            return con;
        }
        set;
    }

    public ApplicationReview() {
    }

    /*******************************************************************************
    * @description Initialize the page - Creates ApplicationRequirement for each requirement that is applicable to this application
    ********************************************************************************/
    public void ApplicationReviewInit() {

        applicationId = Id.valueOf(ApexPages.currentPage().getParameters().get('applicationId'));

        app = ApplicationHelper.getMinimalAppById(applicationId);

        Application_Control__c appControl = ApplicationUtilities.getApplicationControls(app.Application_Control__r.URL_Parameter__c);

        appInfo = ApplicationUtilities.setApplicationInfo(appControl, app);

        arLst = ApplicationHelper.getApplicationRequirements(appInfo);


        //Application_Review__c
        Set<String> fieldSetFields = new Set<String>();
        questionHolderMap = new Map<String, ApplicationQuestion>();
        for (FieldSetMember f : SObjectType.Application_Review__c.fieldSets.Application_Review_Header.getFields()) {
            fieldSetFields.add(f.getFieldPath());
            questionHolderMap.put(f.getFieldPath(), new ApplicationQuestion(f, review, Application_Review__c.SObjectType));
        }
        List<Application_Review__c> reviewLst = Database.query('SELECT Id ' + (fieldSetFields.size() > 0 ? ', ' : '') + String.join(new List<String>(fieldSetFields), ', ') + ' FROM Application_Review__c WHERE Application__c = :applicationId AND CreatedById = \'' + UserInfo.getUserId() + '\' LIMIT 1');
        try {
            if (reviewLst.size() > 0) {
                review = reviewLst[0];
            } else {
                review = new Application_Review__c(Application__c = applicationId);
                insert review;
            }
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0)));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    /* ******************************************************************************
    * @description Submits the ApplicationReivew Object
    ********************************************************************************/
    public PageReference submit() {
        try {
            update review;
            PageReference pr = new PageReference('/' + applicationId);
            pr.setRedirect(true);
            return pr;
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
}