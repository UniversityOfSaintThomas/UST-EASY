/*******************************************************************************
@description This class allows a student to fill out answers to questions and requirement items
@author Huron Consulting Group

Revision (s):
*******************************************************************************/
public class ApplicationRequirement {

    public List<Requirement_Item__c> items { get; set; }
    public String title {
        get {
            return items.isEmpty() ? '' : (String.isBlank(items[0].Requirement__r.Label__c) ? items[0].Requirement__r.Name : items[0].Requirement__r.Label__c);
        }
    }
    public ApplicationQuestionSection section { get; set; }
    public Contact con { get; set; }
    public Application__c app { get; set; }
    public List<Question_Response__c> qResponses { get; set; }
    private Boolean queryItems = true;
    List<Requirement_Response__c> requirementResponses { get; set; }
    List<Question_Response__c> questionResponses { get; set; }
    List<Question_Dependency__c> questionDependencies { get; set; }
    public List<RequirementWrapper> checklistItems { get; set; }
    public Boolean preventUpdates { get; set; }
    public List<Requirement_Response__c> newResponses { get; set; }
    public Boolean showSuccess { get; set; }
    public Boolean isInvalid { get; set; }
    public Boolean ignoreExternalFilter { get; set; }
    public EASYApplicationInfo appInfo { get; set; }

    public Boolean allowSubmit { get; set; }
    public transient String additionalDataString { get; set; }
    public String redirectPage { get; set; }
    public String userType { get; set; }
    public Boolean isStandardUser { get; set; }

    public Application_Control__c appControl { get; set; }

    public Id nextReqId {
        get {
            if (appInfo != null && String.isNotBlank(appInfo.requirementId)) {
                for (Integer i = 0; i < checklistItems.size() - 1; i++) {
                    if (checklistItems[i].req.Id == appInfo.requirementId) {
                        nextReqId = checklistItems[i + 1].req.Id;
                        return nextReqId;
                    }
                }
            }
            return null;
        }
        set;
    }
    public Id prevReqId {
        get {
            if (appInfo != null && String.isNotBlank(appInfo.requirementId)) {
                for (Integer i = 1; i < checklistItems.size(); i++) {
                    if (checklistItems[i].req.Id == appInfo.requirementId) {
                        prevReqId = checklistItems[i - 1].req.Id;
                        return prevReqId;
                    }
                }
            }
            return null;
        }
        set;
    }

    public ApplicationRequirement(Id requirementId, Application__c app, Boolean preventUpdates) {
        this();
        appInfo = this.appInfo;
        appInfo.requirementId = requirementId;
        ApplicationUtilities.createEncryptedCookie(JSON.serialize(appInfo));
        this.preventUpdates = preventUpdates;
        this.app = app;
    }

    public ApplicationRequirement() {
        //Need to get appInfo on constructor to know which template to use
        if(appInfo == null) {
            appInfo = ApplicationUtilities.gatherApplicationInfo();
        }
    }

    public ApplicationRequirement(Id contactId, Id applicationId, Id requirementId, List<Requirement_Item__c> items, List<Requirement_Response__c> requirementResponses, List<Question_Response__c> questionResponses, List<Question_Dependency__c> questionDependencies) {
/*
        appInfo = this.appInfo;
        appInfo.contactId = contactId;
        appInfo.appId = applicationId;
        appInfo.requirementId = requirementId;
        ApplicationUtilities.createEncryptedCookie(JSON.serialize(appInfo));*/
        this.items = items;
        this.requirementResponses = requirementResponses;
        this.questionResponses = questionResponses;
        this.questionDependencies = questionDependencies;
        this.preventUpdates = true;
        queryItems = false;
        isInvalid = false;
    }

    /*******************************************************************************
    * @description Initializes the page - Pulls relevant requirement items, requirement responses, etc.
    ********************************************************************************/
    public PageReference applicationRequirementInit() {

        if(appInfo == null) {
            appInfo = ApplicationUtilities.gatherApplicationInfo();
        }

        if (String.isBlank(appInfo.appControlId)) {
            PageReference portalPage = Page.ApplicationPortal;
            return portalPage;
        }

        allowSubmit = true;
        //isExternalUser = appInfo.isExternalUser;
        userType = String.valueOf(UserInfo.getUserType());
        isStandardUser = userType.equalsIgnoreCase('standard');
        if (userType.equalsIgnoreCase('guest')) {
            String startUrl = System.currentPageReference().getParameters().get('startURL');
            return new PageReference(Site.getPathPrefix() + '/SiteLogin?startURL=' + EncodingUtil.urlEncode(startUrl, 'UTF-8'));
        }

        if (queryItems == true) {
            items = applicationHelper.getRequirementQuestions(new Set<Id>{
                    appInfo.requirementId
            }, appInfo.isExternalUser);
        }

        //Get the application values for this requirement
        if ((String.isBlank(appInfo.appId) || app == null)) {
            String query = applicationHelper.getApplicationFields(items);
            query = 'SELECT ' + query + ' FROM Application__c WHERE Contact__c = \'' + appInfo.contactId + '\' AND Id = \'' + appInfo.appId + '\'';
            app = ((List<Application__c>) Database.query(query)).get(0);
            //TODO:  appControl = appInfo.appControl;
        }

        if (queryItems == true) {
            checklistItems = checklistHelper.checklistRequirements(app, appInfo);
        }

        //Get needed values from Contact record
        if (con == null) {
            if (appInfo.contactId != null) {
                String query = applicationHelper.getApplicationContactFields(items);
                query = 'SELECT ' + query + ' FROM Contact WHERE Id = \'' + appInfo.contactId + '\'';
                con = ((List<Contact>) Database.query(query)).get(0);
            }
        }

        // Question Dependencies
        Map<Id, List<Question_Dependency__c>> dQuestions = new Map<Id, List<Question_Dependency__c>>();
        Map<Id, Set<Id>> dQuestionResponseMap = new Map<Id, Set<Id>>();
        if (questionDependencies == null) {
            questionDependencies = [
                    SELECT Id, Question__c, Question__r.Required__c, Question__r.Requirement_Item__c, Question__r.Requirement_Item__r.Requirement__c,
                            Controlling_Question__c, Controlling_Question__r.Requirement_Item__r.Requirement__c, Value__c, ValueCheckbox__c,
                            RecordType.DeveloperName
                    FROM Question_Dependency__c
                    WHERE Question__r.Requirement_Item__r.Requirement__c = :appInfo.requirementId
            ];
        }

        for (Question_Dependency__c dq : questionDependencies) {

            if (!dQuestions.containsKey(dq.Question__c)) {
                dQuestions.put(dq.Question__c, new List<Question_Dependency__c>());
            }
            if (dq.Question__r.Requirement_Item__r.Requirement__c != dq.Controlling_Question__r.Requirement_Item__r.Requirement__c) {

                if (!dQuestionResponseMap.containsKey(dq.Question__r.Requirement_Item__c)) {
                    dQuestionResponseMap.put(dq.Question__r.Requirement_Item__c, new Set<Id>());
                }

                dQuestionResponseMap.get(dq.Question__r.Requirement_Item__c).add(dq.Controlling_Question__c);
            }

            dQuestions.get(dq.Question__c).add(dq);
        }

        Map<Id, Requirement_Response__c> responses = new Map<Id, Requirement_Response__c>();
        Map<Id, List<Question_Response__c>> dResponses = new Map<Id, List<Question_Response__c>>();

        if (requirementResponses == null && String.isNotBlank(appInfo.appId)) {
            requirementResponses = applicationHelper.getRequirementResponses(new Set<Id>{
                    appInfo.requirementId
            }, appInfo.appId);
        } else if (requirementResponses == null) {
            requirementResponses = new List<Requirement_Response__c>();
        }

        // Requirement Responses
        for (Requirement_Response__c r : requirementResponses) {
            if (r.Hashcode__c != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('h')) && r.Hashcode__c == ApexPages.currentPage().getParameters().get('h') && r.Requirement_Item__c == ApexPages.currentPage().getParameters().get('r')) {
                isInvalid = false;
            }

            responses.put(r.Requirement_Item__c, r);
        }
        Set<Id> questionItemSet = new Set<Id>();
        for (Set<Id> setId : dQuestionResponseMap.values()) {
            questionItemSet.addAll(setId);
        }

        if (questionResponses == null && String.isNotBlank(appInfo.appId)) {
            questionResponses = [
                    SELECT Id, IsPopulated__c, PopulatedOn__c, Question__c, Question__r.Required__c, ValueText__c, ValueCheckbox__c, ValuePhone__c,
                            ValueEmail__c, ValueCurrency__c, ValueDate__c, ValueDateTime__c, ValueNumber__c, ValuePercent__c, ValueTextArea__c,
                            ValueTextEncrypted__c, ValueLongTextArea__c, ValueURL__c, Street__c, City__c, State__c, Country__c, PostalCode__c,
                            Requirement_Response__c, Requirement_Response__r.Has_Child_Requirement__c
                    FROM Question_Response__c
                    WHERE Question__c IN :questionItemSet
                    AND Requirement_Response__r.Application__c = :appInfo.appId
            ];
        } else if (questionResponses == null) {
            questionResponses = new List<Question_Response__c>();
        }

        for (Question_Response__c qr : questionResponses) {
            for (Id rId : dQuestionResponseMap.keySet()) {
                if (!dResponses.containsKey(rId)) {
                    dResponses.put(rId, new List<Question_Response__c>());
                }
                dResponses.get(rId).add(qr);
            }
        }

        // Creates new responses for "new" requirements
        newResponses = new List<Requirement_Response__c>();
        Map<String, Map<String, Schema.SObjectField>> relatedFieldDescribes = new Map<String, Map<String, SObjectField>>();
        Set<String> relatedObjects = new Set<String>();
        List<Requirement_Item__c> riLst = new List<Requirement_Item__c>();
        for (Requirement_Item__c i : items) {
            if (ApplicationFilter.filter(app, i)) {

                if (!responses.containsKey(i.Id) && String.isNotBlank(appInfo.appId)) {
                    Requirement_Response__c r = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = i.Id);
                    newResponses.add(r);
                    responses.put(i.Id, r);
                }

                if (String.isNotBlank(i.Related_List_Object__c)) {
                    relatedObjects.add(i.Related_List_Object__c);
                }


                // Filter out external requirements based on the hashcode
                if ((ignoreExternalFilter != null && ignoreExternalFilter) || !(i.Internal_Requirement_Item__c != null && UserInfo.getUserType() != 'Standard' && !ApexPages.currentPage().getParameters().containsKey('h'))) {
                    riLst.add(i);
                }
            }
        }

        if (!relatedObjects.isEmpty()) {
            for (Schema.DescribeSObjectResult result : Schema.describeSObjects(new List<String>(relatedObjects))) {
                relatedFieldDescribes.put(result.getName(), result.fields.getMap());
            }
        }
/*
        moved to checklist helper
        if (preventUpdates == false) {
            insert newResponses;
        }
*/

        section = new ApplicationQuestionSection(con, app, riLst, dQuestions, responses, dResponses, relatedFieldDescribes);

        // Clone Question Response records and store ID if this is an external user
        // in order to get around restriction of external users being able to edit objects
        if (appInfo.isExternalUser) {
            for (ApplicationQuestionGroup aqg : section.groups) {
                if (aqg.questionGroup && aqg.questions != null) {
                    for (ApplicationQuestion aq : aqg.questions) {
                        if (aq.response != null && aq.response.Id != null) {
                            aq.responseId = aq.response.Id;
                            aq.response = aq.response.clone(false, true, false, false);
                        }
                    }
                }
            }
        }
        return null;
    }


    /* ******************************************************************************
    * description: Allows the student to lookup existing records for related objects
    ******************************************************************************* */

    @RemoteAction
    public static List<SObject> lookupSearch(String sObj, String sObjFilter, String sObjNameField, String term) {
        return new ActionWithSharing().lookupSearchWithSharing(sObj, sObjFilter, sObjNameField, term);
    }
    public with sharing class ActionWithSharing {
        public List<SObject> lookupSearchWithSharing(String sObj, String sObjFilter, String sObjNameField, String term) {
            if (Schema.getGlobalDescribe().get(sObj).getDescribe().isAccessible()) {
                if (String.isBlank(sObjNameField)) {
                    sObjNameField = 'Name';
                }
                List<String> sObjNameFields = sObjNameField.split(',');

                for (Integer x = 0; x < sObjNameFields.size(); x++) {
                    sObjNameFields[x] = sObjNameFields[x].trim();
                }

                String fieldList = String.join(sObjNameFields, ', ');
                String likeStatement = '';

                for (String sField : sObjNameFields) {
                    likeStatement += sField + ' LIKE \'%' + String.escapeSingleQuotes(term) + '%\' OR ';
                }
                likeStatement = ' ( ' + likeStatement.removeEnd(' OR ') + ' )';

                String query = 'SELECT Id, ' + fieldList;
                query += ' FROM ' + sObj;
                query += ' WHERE ' + likeStatement;
                if (String.isNotBlank(sObjFilter)) {
                    query += ' AND ' + sObjFilter;
                }
                query += ' ORDER BY ' + fieldList + ' ASC';
                query += ' LIMIT 50';
                try {
                    List<SObject> lookupResults = Database.query(query);
                    return lookupResults;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    return new List<SObject>();
                }
            }
            return new List<SObject>();
        }
    }

    public class CustomReturn {
        public Boolean isSuccess { get; set; }
        public String message { get; set; }
    }

    /* ******************************************************************************
    * description: Saves question responses, requirement responses and the application. Takes the student back to the application checklist
    ******************************************************************************* */
    public PageReference submit() {
        PageReference pr = null;

        Boolean hasError = false;
        for (ApplicationQuestionGroup g : section.groups) {
            if (g.relatedObject == true) {
                if (g.creatingNewRelatedRecord == true) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please finish editing all ' + (String.isBlank(g.item.Label__c) ? g.item.Name : g.item.Label__c) + ' records'));
                    hasError = true;
                } else if (g.relatedObjects != null) {
                    for (ApplicationQuestionGroup.SObjectWrapper sow : g.relatedObjects) {
                        if (sow.isEditMode) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please finish editing all ' + (String.isBlank(g.item.Label__c) ? g.item.Name : g.item.Label__c) + ' records'));
                            hasError = true;
                        }
                    }
                }
            }
        }

        transient Map<String, Object> additionalData;
        if (String.isNotBlank(additionalDataString) && additionalDataString != '{}') {
            additionalData = (Map<String, Object>) JSON.deserializeUntyped(additionalDataString);
        }

        for (ApplicationQuestionGroup g : section.groups) {
            if (g.documentUpload == true) {
                Map<String, Object> addData;
                if (g.item != null && g.item.Id != null && additionalData != null && additionalData.containsKey(g.item.Id)) {
                    addData = (Map<String, Object>) additionalData.get(g.item.Id);
                }

                if (addData != null && addData.containsKey('attData')) {
                    Map<String, Object> attData = (Map<String, Object>) addData.get('attData');
                    if (attData != null && attData.containsKey('fileName')) {
                        String fileName = (String) attData.get('fileName');
                        if (String.isNotBlank(fileName) && String.isNotBlank(g.item.File_Types__c)) {
                            String ext = fileName.substringAfterLast('.').toUpperCase();
                            Set<String> allowedTypes = new Set<String>(g.item.File_Types__c.toUpperCase().split(';'));
                            if (!allowedTypes.contains(ext)) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'File type not allowed for ' + (String.isBlank(g.item.Label__c) ? g.item.Name : g.item.Label__c) + '. Allowed file types: ' + g.item.File_Types__c));
                                hasError = true;
                            }
                        }
                    }
                }
            }
        }

        if (hasError) {
            System.debug('Has Error: ');
            return pr;
        }

        section.processValues(additionalData);
        List<Requirement_Response__c> rrLst = new List<Requirement_Response__c>();
        for (ApplicationQuestionGroup aqg : section.groups) {
            if (aqg.response != null && aqg.isEditable) {
                aqg.response.Viewed__c = true;
                rrLst.add(aqg.response);
            }
        }
        try {
            upsert rrLst;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        qResponses = new List<Question_Response__c>();
        for (ApplicationQuestionGroup g : section.groups) {
            if (g.questionGroup == true && g.questions != null && g.isEditable) {
                for (ApplicationQuestion q : g.questions) {
                    if ((q.isEditable || UserInfo.getUserType() == 'Standard') && q.response != null) {

                        Question_Response__c qResp = q.response;

                        // Clone Question Response and apply ID if this is an external user
                        // in order to get around the restriction of external users not being
                        // able to edit objects.
                        if (appInfo.isExternalUser) {
                            qResp = q.response.clone(false, true, false, false);
                            qResp.Id = q.responseId;
                        }

                        qResponses.add(qResp);
                    }
                }
            }
        }

        try {
            upsert qResponses;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        section.pushValuesToObjects();

        try {
            update app;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        try {
            update con;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            System.debug(ex.getMessage());
        }

        try {

            if (!UserInfo.getUserType().equals('Standard') && String.isNotBlank(ApexPages.currentPage().getParameters().get('h')) && String.isNotBlank(ApexPages.currentPage().getParameters().get('r'))) {
                showSuccess = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your response has been submitted successfully. Thank you!'));
            }

            if (String.isNotBlank(redirectPage)) {
                if (redirectPage == 'checklist') {
                    pr = Page.ApplicationPortal;
                } else if (redirectPage == 'submit') {
                    if (allowSubmit && app != null) {
                        if (appControl != null && String.isNotBlank(appControl.Submit_Status__c)) {
                            update new Application__c(Id = app.Id, Application_Status__c = appControl.Submit_Status__c);
                            pr = Page.ApplicationPortal;
                            for (String s : new Set<String>{
                                    'contactId', 'applicationId', 'at'
                            }) {
                                pr.getParameters().put(s, ApexPages.currentPage().getParameters().get(s));
                            }
                        }
                    }
                } else {
                    pr = Page.ApplicationRequirement;
                    appInfo.requirementId = redirectPage;
                    ApplicationUtilities.createEncryptedCookie(JSON.serialize(appInfo));
//                    pr.getParameters().put('applicationId', appInfo.appId);
//                    pr.getParameters().put('contactId', appInfo.contactId);
                    pr.getParameters().put('at', appInfo.at);
                    pr.getParameters().put('requirementId', appInfo.requirementId);
                }
                pr.setRedirect(true);
            }

            System.debug(pr);


        } catch (DmlException e) {
            System.debug('DML error:' + e.getDmlMessage(0));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0) + ' ' + e.getMessage()));
        } catch (Exception e) {
            System.debug('Error:' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return pr;
    }
}