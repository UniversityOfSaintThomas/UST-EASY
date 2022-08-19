/*******************************************************************************
@description This controller is used to allow internal users the ability to edit an application.
@author Huron Consulting Group

Revision (s):
*******************************************************************************/
public class ApplicationAdminView {

    public transient Id applicationId { get; set; }
    public List<Requirement__c> reqs { get; set; }
    public Application__c app { get; set; }
    public List<ApplicationRequirement> arLst { get; set; }
    public transient String additionalDataString { get; set; }
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

    public ApplicationAdminView() {
    }

    /*******************************************************************************
    * @description Initialize the page - Creates ApplicationRequirement for each requirement that is applicible to this application
    ********************************************************************************/
    public void ApplicationAdminViewInit() {
        applicationId = Id.valueOf(ApexPages.currentPage().getParameters().get('applicationId'));

        app = ApplicationHelper.getMinimalAppById(applicationId);

        Application_Control__c appControl = ApplicationUtilities.getApplicationControls(app.Application_Control__r.URL_Parameter__c);

        appInfo = ApplicationUtilities.setApplicationInfo(appControl, app);

        arLst = ApplicationHelper.getApplicationRequirements(appInfo);

    }

    /*******************************************************************************
    * @description Updates all of the Question_Response__c, Requirement_Response__c and Application__c based on what is populated on the VisualForce page
    * @return The application record to return to when the page is saved, null if there is an error.
    *******************************************************************************/
    public PageReference submit() {
        List<Requirement_Response__c> responses = new List<Requirement_Response__c>();
//        for (ApplicationRequirement ar : arLst) {
//            if (ar.newResponses != null && ar.newResponses.size() > 0) {
//                responses.addAll(ar.newResponses);
//            }
//        }
        if (responses.size() > 0) {
            insert responses;
        }
        try {
            Map<Question_Response__c, Requirement_Response__c> questionToResponseMap = new Map<Question_Response__c, Requirement_Response__c>();
            List<Requirement_Response__c> rrLst = new List<Requirement_Response__c>();
            List<Question_Response__c> qResponses = new List<Question_Response__c>();
            transient Map<String, Object> additionalData;
            if (String.isNotBlank(additionalDataString)) {
                additionalData = (Map<String, Object>) JSON.deserializeUntyped(additionalDataString);
            }
            for (ApplicationRequirement r : arLst) {
                r.section.processValues(additionalData);
                for (ApplicationQuestionGroup aqg : r.section.groups) {
                    if (aqg.response != null) {
                        rrLst.add(aqg.response);
                    }
                    if (aqg.questionGroup == true && aqg.questions != null) {
                        for (ApplicationQuestion q : aqg.questions) {
                            if (q.response != null) {
                                questionToResponseMap.put(q.response, aqg.response);
                                qResponses.add(q.response);
                            }
                        }
                    }
                }
            }
            if (rrLst.size() > 0) {
                update rrLst;
            }
            for (Question_Response__c qr : questionToResponseMap.keySet()) {
                if (qr.Requirement_Response__c == null) {
                    qr.Requirement_Response__c = questionToResponseMap.get(qr).Id;
                }
            }
            upsert qResponses;

            pushValuesToObjects();

            if (con != null) update con;
            update app;
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

    public void pushValuesToObjects() {

        if (con == null && app == null) return;

        Set<String> allContactFields = new Set<String>();
        Set<String> allApplicationFields = new Set<String>();
        Map<String, Object> contactValues = new Map<String, Object>();
        Map<String, Object> applicationValues = new Map<String, Object>();
        for (ApplicationRequirement ar : arLst) {
            for (ApplicationQuestionGroup g : ar.section.groups) {
                if (g.questionGroup) {
                    for (ApplicationQuestion q : g.questions) {
                        if (q.question != null && (String.isNotBlank(q.question.Contact_Field__c) || String.isNotBlank(q.question.Application_Field__c))) {

                            if (con != null && String.isNotBlank(q.question.Contact_Field__c)) {
                                allContactFields.add(q.question.Contact_Field__c.toLowerCase());
                            }
                            if (app != null && String.isNotBlank(q.question.Application_Field__c)) {
                                allApplicationFields.add(q.question.Application_Field__c.toLowerCase());
                            }

                            Boolean shown = q.getShowQuestion();

                            if (shown && q.fieldType.equals('Address') && (q.question.Contact_Field__c == 'MailingAddress' || q.question.Contact_Field__c == 'OtherAddress')) {

                                String prefix = q.question.Contact_Field__c.equals('MailingAddress') ? 'Mailing' : 'Other';
                                con.put(prefix + 'Street', q.response.Street__c);
                                con.put(prefix + 'City', q.response.City__c);
                                con.put(prefix + 'PostalCode', q.response.PostalCode__c);
                                con.put(prefix + (ApplicationQuestion.stateAndCountryPicklistEnabled ? 'StateCode' : 'State'), q.response.State__c);
                                con.put(prefix + (ApplicationQuestion.stateAndCountryPicklistEnabled ? 'CountryCode' : 'Country'), q.response.Country__c);

                            } else if (q.resp != null) {
                                if (con != null && String.isNotBlank(q.question.Contact_Field__c)) {
                                    contactValues.put(q.question.Contact_Field__c.toLowerCase(), q.resp);
                                }
                                if (app != null && String.isNotBlank(q.question.Application_Field__c)) {
                                    applicationValues.put(q.question.Application_Field__c.toLowerCase(), q.resp);
                                }
                            }
                        }
                    }
                }
            }
        }

        for (String f : allContactFields) {
            try {
                con.put(f, contactValues.get(f));
            } catch (Exception e) {
            }
        }

        for (String f : allApplicationFields) {
            try {
                app.put(f, applicationValues.get(f));
            } catch (Exception e) {
            }
        }
    }

    /*******************************************************************************
    * @description Returns a list of sobjects based on a search term
    * @return List of sobjects based on a search term.
    *******************************************************************************/
    @RemoteAction
    public static List<SObject> lookupSearch(String sObj, String sObjFilter, String sObjNameField, String term) {

        return new ApplicationRequirement.ActionWithSharing().lookupSearchWithSharing(sObj, sObjFilter, sObjNameField, term);
    }
}