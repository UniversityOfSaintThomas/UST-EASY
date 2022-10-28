/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/1/2021.
 */


public with sharing class checklistHelper {
    public static Map<Id, RequirementWrapper> reqMap { get; set; }
    public static List<RequirementWrapper> reqs { get {return reqMap.values();} }
    public static Boolean allowSubmit { get; set; }
    public static Boolean allowCancel { get; set; }
    public static Boolean allowWithdraw { get; set; }
    public static Boolean allowConfirm { get; set; }
    public static List<Requirement_Item__c> riList { get; set; }
    public static Decimal progress { get; set; }
    public EASYApplicationInfo appInfo { get; set; }

    public static List<RequirementWrapper> checklistRequirements(Application__c app, EASYApplicationInfo appInfo) {
        allowSubmit = true;
        allowCancel = false;
        allowWithdraw = false;
        allowConfirm = false;

        allowCancel = String.isNotBlank(appInfo.allowCancelFrom) && new Set<String>(appInfo.allowCancelFrom.split(';')).contains(app.Application_Status__c);
        allowWithdraw = String.isNotBlank(appInfo.allowWithdrawFrom) && new Set<String>(appInfo.allowWithdrawFrom.split(';')).contains(app.Application_Status__c);

        reqMap = new Map<Id, RequirementWrapper>();
        Set<Id> reqIds = new Set<Id>();
        for (Requirement__c r : [
                SELECT Id, Internal_Only__c, Internal_Only_Show_on_Checklist__c, Display_on_Checklist__c, Name, Label__c, Active__c,
                        Intended_Program__c, Application_Status__c, Applicant_Type__c, Citizenship__c, Degree_Type__c, Delivery_Type__c,
                        Residency__c, School_College__c, Student_Type__c, Generic_Filter_1__c, Generic_Filter_2__c,
                        Generic_Filter_3__c, Generic_Filter_4__c
                FROM Requirement__c
                WHERE Application_Control__c = :appInfo.appControlId
                AND Active__c = :true
                AND Show_on_Application_Creation__c = FALSE
                ORDER BY Display_Order__c, Label__c ASC NULLS LAST
        ]) {
            if (ApplicationFilter.filter(app, r)) {
                reqIds.add(r.Id);
                reqMap.put(r.Id, new RequirementWrapper(r));
            }
        }

        Map<Id, Boolean> completedRequirement = new Map<Id, Boolean>();
        Map<Id, Boolean> viewedRequirement = new Map<Id, Boolean>();

        Set<Id> riIds = new Set<Id>();
        riList = applicationHelper.getRequirementQuestions(reqIds, appInfo.isExternalUser);

        for (Requirement_Item__c ri : riList) {
            if (ApplicationFilter.filter(app, ri)) {
                reqMap.get(ri.Requirement__c).reqItemMap.put(ri.Id, new RequirementItemWrapper(ri));
                riIds.add(ri.Id);
            }
        }

        checkRequirementCompletion(app.Id, app);

        for (Requirement_Response__c rr : [
                SELECT Id, Requirement_Item__r.Required__c, Requirement_Item__c, Requirement_Item__r.RecordType.DeveloperName, Requirement_Item__r.Requirement__c,
                        Fulfilled_On__c, Incomplete_Questions__c, Question_Group_Requirement_Fulfilled_On__c, HasDocument__c, Waive_Requirement__c,
                        Document_Requirement_Fulfilled_On__c, Has_Child_Requirement__c, Child_Requirement_Fulfilled_On__c, Send_Reminder__c,
                        External_Email__c, Viewed__c, Requirement_Item__r.Viewing_Requirement_Formula__c
                FROM Requirement_Response__c
                WHERE Application__c = :app.Id
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

        Decimal total = reqs == null || reqs.isEmpty() ? 1 : (Decimal) reqs.size();
        Decimal complete = 0;

        for (RequirementWrapper req : reqs) {
            if (req.reqStatus) {
                complete++;
            }
        }
        progress = (complete / total) * 100;

        return reqMap.values();
    }

    public static Boolean allowSubmit (List<RequirementWrapper> requirements, EASYApplicationInfo appInfo) {

        allowSubmit = false;

        for (RequirementWrapper rw : requirements) {
            if (!rw.reqStatus) {
                return allowSubmit;
            }
        }

        if (String.isNotBlank(appInfo.appControlId) && String.isNotBlank(appInfo.allowSubmitFrom)) {
            if (!(new Set<String>(appInfo.allowSubmitFrom.split(';'))).contains(appInfo.appStatus)) {
                return allowSubmit;
            }
        }
        allowSubmit = true;

        return allowSubmit;
    }

    public static Boolean allowConfirm (List<RequirementWrapper> requirements, EASYApplicationInfo appInfo) {

        allowConfirm = false;

        for (RequirementWrapper rw : requirements) {
            if (!rw.reqStatus) {
                return allowConfirm;
            }
        }

        if (String.isNotBlank(appInfo.appControlId) && String.isNotBlank(appInfo.allowConfirmFrom)) {
            if (!(new Set<String>(appInfo.allowConfirmFrom.split(';'))).contains(appInfo.appStatus)) {
                return allowConfirm;
            }
        }
        
        allowConfirm = true;

        return allowConfirm;
    }

    /*******************************************************************************
    * @description Checks to see if requirements have been completed. Checks related list items too (Even if they are not marked completed on the Requirement Response)
    ********************************************************************************/
    public static void checkRequirementCompletion(Id applicationId, Application__c app) {

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
        List<Requirement_Response__c> requirementResponses = applicationHelper.getRequirementResponses(requirementIds, applicationId);
        for (Requirement_Response__c rr : requirementResponses) {
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
        List<Requirement_Response__c> newResponses = new List<Requirement_Response__c>();
        for (Id rid : requirementIds) {
            //Requirement Items
            List<Requirement_Item__c> items;

            if (riMap.containsKey(rid)) {
                items = riMap.get(rid);
            } else {
                items = new List<Requirement_Item__c>();
            }

            //Requirement Responses
            List<Requirement_Response__c> AddRequirementResponses;
            if (rrMap.containsKey(rid)) {
                AddRequirementResponses = rrMap.get(rid);
            } else {
                AddRequirementResponses = new List<Requirement_Response__c>();
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

            // Creates new responses for "new" requirements
            Map<Id, Requirement_Response__c> mapResponses = new Map<Id, Requirement_Response__c>();
            for (Requirement_Response__c r : requirementResponses) {
                mapResponses.put(r.Requirement_Item__c, r);
            }

            for (Requirement_Item__c i : items) {
                if (ApplicationFilter.filter(app, i)) {
                    if (!mapResponses.containsKey(i.Id) && String.isNotBlank(applicationId)) {
                        Requirement_Response__c r = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = i.Id);
                        newResponses.add(r);
                    }
                }
            }

        }
        if (newResponses.size() > 0) {
            insert newResponses;
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

}