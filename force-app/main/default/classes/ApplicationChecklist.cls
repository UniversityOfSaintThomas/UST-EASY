/*******************************************************************************
@description This controller is used to show which requirements/requirement items have been completed for this application
@author Huron Consulting Group

Revision (s):
*******************************************************************************/
public class ApplicationChecklist {
    public void init() {}
/*

    public Map<Id, RequirementWrapper> reqMap { get; set; }
    public List<RequirementWrapper> reqs { get {return reqMap.values();} }
    public Id contactId { get; set; }
    public Id applicationId { get; set; }
    public Contact con { get; set; }
    public Application__c app { get; set; }
    public Boolean allowSubmit { get; set; }
    public Boolean allowCancel { get; set; }
    public Boolean allowWithdraw { get; set; }
    public List<Requirement_Item__c> riList { get; set; }
    public Decimal progress { get; set; }
    public EASYApplicationInfo appInfo { get; set; }

    public Application_Control__c appControl {
        get {
            if (appControl == null) {
                appControl = ApplicationUtilities.getApplicationControls(ApexPages.currentPage().getParameters().get('at'));
            }
            return appControl;
        }
        set;
    }

    public ApplicationChecklist() {
        appInfo = ApplicationUtilities.gatherApplicationInfo();
    }

    */
/*******************************************************************************
    * @description Initialize the page - Checks if requirements have been completed
    ********************************************************************************//*

    public void init() {
        appInfo = ApplicationUtilities.gatherApplicationInfo();
        allowSubmit = true;
        allowCancel = false;
        allowWithdraw = false;

        contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        if (UserInfo.getUserType().equals('Standard')) {
            contactId = Id.valueOf(ApexPages.currentPage().getParameters().get('contactId'));
        }
        applicationId = Id.valueOf(ApexPages.currentPage().getParameters().get('applicationId'));

        app = [
                SELECT Id, Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name, Intended_Program__c, Applicant_Type__c,
                        Citizenship__c, Delivery_Type__c, Student_Type__c, Application_Status__c, School_College__c, Residency__c, Degree_Type__c,
                        Application_Control__c, Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c
                FROM Application__c
                WHERE Id = :applicationId
        ];
        appControl = ApplicationUtilities.getApplicationControls(app.Application_Control__c);

        allowCancel = String.isNotBlank(appControl.Allow_Cancel_From__c) && new Set<String>(appControl.Allow_Cancel_From__c.split(';')).contains(app.Application_Status__c);
        allowWithdraw = String.isNotBlank(appControl.Allow_Withdraw_From__c) && new Set<String>(appControl.Allow_Withdraw_From__c.split(';')).contains(app.Application_Status__c);

        reqMap = new Map<Id, RequirementWrapper>();
        Set<Id> reqIds = new Set<Id>();
        for (Requirement__c r : [
                SELECT Id, Internal_Only__c, Internal_Only_Show_on_Checklist__c, Display_on_Checklist__c, Name, Label__c, Active__c,
                        Intended_Program__c, Application_Status__c, Applicant_Type__c, Citizenship__c, Degree_Type__c, Delivery_Type__c,
                        Residency__c, School_College__c, Student_Type__c, Generic_Filter_1__c, Generic_Filter_2__c,
                        Generic_Filter_3__c, Generic_Filter_4__c
                FROM Requirement__c
                WHERE Application_Control__c = :appControl.Id
                AND Active__c = :true
                AND Show_on_Application_Creation__c = FALSE
                ORDER BY Display_Order__c ASC NULLS LAST
        ]) {
            if (ApplicationFilter.filter(app, r)) {
                reqIds.add(r.Id);
                reqMap.put(r.Id, new RequirementWrapper(r));
            }
        }

        Map<Id, Boolean> completedRequirement = new Map<Id, Boolean>();
        Map<Id, Boolean> viewedRequirement = new Map<Id, Boolean>();

        Set<Id> riIds = new Set<Id>();
        riList = [
                SELECT Id, File_Types__c, Internal_Only__c, Requirement__r.Internal_Only__c, Internal_Only_Applicant_Instructions__c, Active__c, Required__c,
                        Required_Number_of_Children__c, Maximum_Number_of_Children__c, Requirement__r.Name, Requirement__r.Label__c, Name, Label__c, Instructions__c, Intended_Program__c,
                        Application_Status__c, Applicant_Type__c, Citizenship__c, Degree_Type__c, Delivery_Type__c, Residency__c, School_College__c, Student_Type__c, RecordType.DeveloperName,
                        Allow_Text_Entry__c, Related_List_Object__c, Related_List_Object_Master__c, Related_List_Object_Master_Field__c, Related_List_Where_Clause__c, Related_Object_Record_Type_ID__c,
                        Internal_Requirement_Item__c, Editable_Application_Status__c, Holding_Record_Id__c, Allow_Supporting_Documentation_Upload__c, Required_Supporting_Documentation__c,
                        Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, Internal_Only_Show_on_Checklist__c, Display_on_Checklist__c, Requirement__c, (
                        SELECT Id, Active__c, Required__c, Label__c, Intended_Program__c, Application_Status__c,
                                Applicant_Type__c, Citizenship__c, Degree_Type__c, Delivery_Type__c, Residency__c, School_College__c, Student_Type__c, RecordType.DeveloperName, Picklist_Values__c, Placeholder__c,
                                Length__c, Help_Text__c, Dependency_Logic__c, Dependency_Behavior__c, Related_Object_Field__c, Lookup_Object__c, Lookup_Where_Clause__c, Name_Field_API_Name__c, Contact_Field__c,
                                Application_Field__c, External_Email_Field__c, Hardcoded_Value__c, Editable_Application_Status__c, URL_Parameter__c, New_Reference_Field__c, Static_Text__c, Display_as_Picklist__c,
                                Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, RecordType.Name, Assistive_Text__c, Related_Object__c, Additional_Field_Validation__c
                        FROM Questions__r
                        WHERE Active__c = TRUE
                        ORDER BY Display_Order__c ASC NULLS LAST
                )
                FROM Requirement_Item__c
                WHERE Requirement__c IN :reqIds
                ORDER BY Display_Order__c ASC NULLS LAST
        ];
        for (Requirement_Item__c ri : riList) {
            if (ApplicationFilter.filter(app, ri)) {
                reqMap.get(ri.Requirement__c).reqItemMap.put(ri.Id, new RequirementItemWrapper(ri));
                riIds.add(ri.Id);
            }
        }

        checkRequirementCompletion();
        for (Requirement_Response__c rr : [
                SELECT Id, Requirement_Item__r.Required__c, Requirement_Item__c, Requirement_Item__r.RecordType.DeveloperName, Requirement_Item__r.Requirement__c,
                        Fulfilled_On__c, Incomplete_Questions__c, Question_Group_Requirement_Fulfilled_On__c, HasDocument__c, Waive_Requirement__c,
                        Document_Requirement_Fulfilled_On__c, Has_Child_Requirement__c, Child_Requirement_Fulfilled_On__c, Send_Reminder__c,
                        External_Email__c, Viewed__c, Requirement_Item__r.Viewing_Requirement_Formula__c
                FROM Requirement_Response__c
                WHERE Application__c = :applicationId
                AND Requirement_Item__r.Requirement__c IN :reqIds
        ]) {
            if (riIds.contains(rr.Requirement_Item__c)) {
                Boolean itemCompleted = true;
                if (!completedRequirement.containsKey(rr.Requirement_Item__r.Requirement__c)) {
                    completedRequirement.put(rr.Requirement_Item__r.Requirement__c, true);
                }

                if (!rr.Waive_Requirement__c && !rr.Viewed__c && rr.Requirement_Item__r.Viewing_Requirement_Formula__c) {
                    completedRequirement.put(rr.Requirement_Item__r.Requirement__c, false);
                    viewedRequirement.put(rr.Requirement_Item__r.Requirement__c, false);
                    itemCompleted = false;
                }

                if (!rr.Waive_Requirement__c && rr.Incomplete_Questions__c > 0) {
                    completedRequirement.put(rr.Requirement_Item__r.Requirement__c, false);
                    itemCompleted = false;
                }

                if (!rr.Waive_Requirement__c && rr.Requirement_Item__r.RecordType.DeveloperName == 'Document_Upload' && rr.HasDocument__c == false && String.isNotBlank(rr.Requirement_Item__r.Required__c) && new Set<String>(rr.Requirement_Item__r.Required__c.split(';')).contains(app.Application_Status__c)) {
                    completedRequirement.put(rr.Requirement_Item__r.Requirement__c, false);
                    itemCompleted = false;
                }

                if (!rr.Waive_Requirement__c && rr.Requirement_Item__r.RecordType.DeveloperName == 'Related_Object' && rr.Has_Child_Requirement__c == false) {
                    completedRequirement.put(rr.Requirement_Item__r.Requirement__c, false);
                    itemCompleted = false;
                }

                reqMap.get(rr.Requirement_Item__r.Requirement__c).reqItemMap.get(rr.Requirement_Item__c).reqItemStatus = itemCompleted;
            }
        }

        for (Id rId : completedRequirement.keySet()) {
            if (completedRequirement.get(rId) && reqMap.containsKey(rId)) {
                reqMap.get(rId).reqStatus = true;
            }
        }

        for (Id rId : viewedRequirement.keySet()) {
            if (!viewedRequirement.get(rId) && reqMap.containsKey(rId)) {
                reqMap.get(rId).viewed = false;
            }
        }

        for (RequirementWrapper rw : reqMap.values()) {
            if (!rw.reqStatus) {
                allowSubmit = false;
                break;
            }
        }

        if (appControl != null && String.isNotBlank(appControl.Allow_Submit_From__c)) {
            if (!(new Set<String>(appControl.Allow_Submit_From__c.split(';'))).contains(app.Application_Status__c)) {
                allowSubmit = false;
            }

        } else if (appControl != null && String.isBlank(appControl.Allow_Submit_From__c) && String.isNotBlank(appControl.Submit_Status__c)) {

        } else {
            allowSubmit = false;
        }

        Decimal total = reqs == null || reqs.isEmpty() ? 1 : (Decimal) reqs.size();
        Decimal complete = 0;

        for (RequirementWrapper req : reqs) {
            if (req.reqStatus) {
                complete++;
            }
        }
        progress = (complete / total) * 100;

    }

    */
/*******************************************************************************
    * @description Checks to see if requirements have been completed. Checks related list items too (Even if they are not marked completed on the Requirement Response)
    ********************************************************************************//*

    public void checkRequirementCompletion() {

        Set<Id> requirementIds = new Set<Id>();

        // Requirement Items
        Map<Id, List<Requirement_Item__c>> riMap = new Map<Id, List<Requirement_Item__c>>();
        for (Requirement_Item__c ri : riList) {
            if (ApplicationFilter.filter(app, ri)) {

                requirementIds.add(ri.Requirement__c);

                if (!riMap.containsKey(ri.Requirement__c)) {
                    riMap.put(ri.Requirement__c, new List<Requirement_Item__c>());
                }
                riMap.get(ri.Requirement__c).add(ri);
            }
        }

        // Requirement Responses
        Map<Id, List<Requirement_Response__c>> rrMap = new Map<Id, List<Requirement_Response__c>>();
        for (Requirement_Response__c rr : [
                SELECT Id, Requirement_Item__r.Requirement__c, Requirement_Item__c, ValueTextEntry__c, Incomplete_Questions__c,
                        Question_Group_Requirement_Fulfilled_On__c, HasDocument__c, Waive_Requirement__c, Document_Requirement_Fulfilled_On__c,
                        Has_Child_Requirement__c, Child_Requirement_Fulfilled_On__c, Application__c, Application__r.Contact__c, External_Email__c,
                        Hashcode__c, Send_Reminder__c, (
                        SELECT Id, IsPopulated__c, PopulatedOn__c, Question__c, Question__r.Required__c, ValueText__c, ValueCheckbox__c,
                                ValuePhone__c, ValueEmail__c, ValueCurrency__c, ValueDate__c, ValueDateTime__c, ValueNumber__c,
                                ValuePercent__c, ValueTextArea__c, ValueTextEncrypted__c, ValueLongTextArea__c, ValueURL__c,
                                Street__c, City__c, State__c, Country__c, PostalCode__c, Requirement_Response__c
                        FROM Question_Responses__r
                ), (
                        SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title
                        FROM ContentDocumentLinks
                )
                FROM Requirement_Response__c
                WHERE Requirement_Item__r.Requirement__c IN :requirementIds
                AND Application__c = :applicationId
        ]) {

            if (!rrMap.containsKey(rr.Requirement_Item__r.Requirement__c)) {
                rrMap.put(rr.Requirement_Item__r.Requirement__c, new List<Requirement_Response__c>());
            }
            rrMap.get(rr.Requirement_Item__r.Requirement__c).add(rr);
        }

        //Question Dependencies
        Set<Id> questionItemSet = new Set<Id>();
        Map<Id, Id> qdReqMap = new Map<Id, Id>(); //Maps Question Dependencies to their original Requirement
        Map<Id, List<Question_Dependency__c>> qdMap = new Map<Id, List<Question_Dependency__c>>();
        for (Question_Dependency__c qd : [
                SELECT Id, Question__c, Question__r.Required__c, Question__r.Requirement_Item__c, Question__r.Requirement_Item__r.Requirement__c,
                        Controlling_Question__c, Controlling_Question__r.Requirement_Item__r.Requirement__c, Value__c, ValueCheckbox__c,
                        RecordType.DeveloperName
                FROM Question_Dependency__c
                WHERE Question__r.Requirement_Item__r.Requirement__c IN :requirementIds
        ]) {
            if (!qdMap.containsKey(qd.Question__r.Requirement_Item__r.Requirement__c)) {
                qdMap.put(qd.Question__r.Requirement_Item__r.Requirement__c, new List<Question_Dependency__c>());
            }
            qdMap.get(qd.Question__r.Requirement_Item__r.Requirement__c).add(qd);
            if (qd.Question__r.Requirement_Item__r.Requirement__c != qd.Controlling_Question__r.Requirement_Item__r.Requirement__c) {
                questionItemSet.add(qd.Controlling_Question__c);
                qdReqMap.put(qd.Controlling_Question__c, qd.Question__r.Requirement_Item__r.Requirement__c);
            }
        }

        //Question responses
        Map<Id, List<Question_Response__c>> qrMap = new Map<Id, List<Question_Response__c>>();
        for (Question_Response__c qr : [SELECT Id, IsPopulated__c, PopulatedOn__c, Question__r.Requirement_Item__r.Requirement__c, Question__c, Question__r.Required__c, ValueText__c, ValueCheckbox__c, ValuePhone__c, ValueEmail__c, ValueCurrency__c, ValueDate__c, ValueDateTime__c, ValueNumber__c, ValuePercent__c, ValueTextArea__c, ValueTextEncrypted__c, ValueLongTextArea__c, ValueURL__c, Street__c, City__c, State__c, Country__c, PostalCode__c, Requirement_Response__c FROM Question_Response__c WHERE Question__c IN :questionItemSet AND Requirement_Response__r.Application__c = :applicationId]) {
            if (!qrMap.containsKey(qdReqMap.get(qr.Question__c))) {
                qrMap.put(qdReqMap.get(qr.Question__c), new List<Question_Response__c>());
            }
            qrMap.get(qdReqMap.get(qr.Question__c)).add(qr);
        }
        List<ApplicationRequirement> arLst = new List<ApplicationRequirement>();
        List<Requirement_Response__c> responses = new List<Requirement_Response__c>();
        for (Id rid : requirementIds) {
            //Requirement Items
            List<Requirement_Item__c> items;
            if (riMap.containsKey(rid)) {
                items = riMap.get(rid);
            } else {
                items = new List<Requirement_Item__c>();
            }

            //Requirement Responses
            List<Requirement_Response__c> requirementResponses;
            if (rrMap.containsKey(rid)) {
                requirementResponses = rrMap.get(rid);
            } else {
                requirementResponses = new List<Requirement_Response__c>();
            }

            //Question Dependencies
            List<Question_Dependency__c> questionDependencies;
            if (qdMap.containsKey(rid)) {
                questionDependencies = qdMap.get(rid);
            } else {
                questionDependencies = new List<Question_Dependency__c>();
            }

            //Question Responses
            List<Question_Response__c> questionResponses;
            if (qrMap.containsKey(rid)) {
                questionResponses = qrMap.get(rid);
            } else {
                questionResponses = new List<Question_Response__c>();
            }

            ApplicationRequirement ar = new ApplicationRequirement(contactId, applicationId, rid, items, requirementResponses, questionResponses, questionDependencies);
            ar.preventUpdates = true;
            ar.ignoreExternalFilter = true;
            arLst.add(ar);
            ar.applicationRequirementInit();
            responses.addAll(ar.newResponses);
        }
        if (responses.size() > 0) {
            insert responses;
        }
        try {
            Map<Question_Response__c, Requirement_Response__c> questionToResponseMap = new Map<Question_Response__c, Requirement_Response__c>();
            List<Requirement_Response__c> rrLst = new List<Requirement_Response__c>();
            List<Question_Response__c> qResponses = new List<Question_Response__c>();
            for (ApplicationRequirement r : arLst) {
                r.section.processValues();
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
            update app;

        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

    }
    */
/* ******************************************************************************
    * @description Submits the application if the application is in the correct status
    ********************************************************************************//*

    public PageReference submit() {
        PageReference pr;
        if (allowSubmit && app != null) {
            if (appControl != null && String.isNotBlank(appControl.Submit_Status__c)) {
                update new Application__c(Id = app.Id, Application_Status__c = appControl.Submit_Status__c);
                pr = Page.ApplicationChecklist;
                pr.setRedirect(true);
                for (String s : new Set<String>{
                        'contactId', 'applicationId', 'at'
                }) {
                    pr.getParameters().put(s, ApexPages.currentPage().getParameters().get(s));
                }
            }
        }
        return pr;
    }
    */
/* ******************************************************************************
    * @description Cancels the application if the application is in the correct status
    ********************************************************************************//*

    public PageReference cancelApp() {
        PageReference pr;
        if (allowCancel && app != null) {
            if (appControl != null && String.isNotBlank(appControl.Cancel_Status__c)) {
                update new Application__c(Id = app.Id, Application_Status__c = appControl.Cancel_Status__c);
                pr = Page.ApplicationChecklist;
                pr.setRedirect(true);
                for (String s : new Set<String>{
                        'contactId', 'applicationId', 'at'
                }) {
                    pr.getParameters().put(s, ApexPages.currentPage().getParameters().get(s));
                }
            }
        }
        return pr;
    }
    */
/* ******************************************************************************
    * @description Withdraws the application if the application is in the correct status
    ********************************************************************************//*

    public PageReference withdrawApp() {
        PageReference pr;
        if (allowWithdraw && app != null) {
            if (appControl != null && String.isNotBlank(appControl.Withdraw_Status__c)) {
                update new Application__c(Id = app.Id, Application_Status__c = appControl.Withdraw_Status__c);
                pr = Page.ApplicationChecklist;
                pr.setRedirect(true);
                for (String s : new Set<String>{
                        'contactId', 'applicationId', 'at'
                }) {
                    pr.getParameters().put(s, ApexPages.currentPage().getParameters().get(s));
                }
            }
        }
        return pr;
    }
*/

}