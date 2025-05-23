/*******************************************************************************
@description This controller is used to create a new application for a user who already has a community account
@author Huron Consulting Group
*******************************************************************************/
public class ApplicationCreate {

    public Id contactId { get; set; }
    public Contact con { get; set; }
    public Application__c app { get; set; }
    public ApplicationQuestionSection section { get; set; }
    public List<RequirementWrapper> checklistItems { get; set; }
    public List<Requirement_Item__c> items { get; set; }
    public Map<Id, Program__c> intendedPrograms { get; set; }
    public String additionalDataString { get; set; }
    public Set<String> contactFields { get; set; }
    public String degreeType { get; set; }
    public EASYApplicationInfo appInfo { get; set; }
    public String template { get; set; }
    public Boolean noApplication { get; set; }

    /* ******************************************************************************
    * @description Initialize the page - Sets up requirements
    ********************************************************************************/

    public ApplicationCreate() {
        if (appInfo == null) {
            appInfo = ApplicationUtilities.createShellAppInfo();
        }
    }

    public PageReference ApplicationCreateInit() {

        String userType = UserInfo.getUserType();
        if (userType.endsWithIgnoreCase('guest')) {
            PageReference regPage = Page.ApplicationRegistration;
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('at'))) {
                regPage.getParameters().put('at', ApexPages.currentPage().getParameters().get('at'));
            }
            regPage.setRedirect(true);
            return regPage;
        }
        //return null;

        appInfo = ApplicationUtilities.createShellAppInfo();

        // Exit if there is no Application Control to reference
        if (String.isBlank(appInfo.appControlId)) {
            return null;
        }

        applicationCreateSetup(null, null); // Do setup of all objects
        app.Contact__c = appInfo.contactId; // Assign contact to application

        // Take user straight to checklist if we don't want to ask any questions
        if (section.groups.isEmpty()) {
            return save();
        }

        return null; // Return null by default
    }

    /*******************************************************************************
    * @description
    ********************************************************************************/
    public void applicationCreateSetup(ApplicationQuestionGroup firstGroup, ApplicationQuestionGroup lastGroup) {
        applicationCreateSetup(firstGroup, lastGroup, false);
    }

    public void applicationCreateSetup(ApplicationQuestionGroup firstGroup, ApplicationQuestionGroup lastGroup, Boolean noApp) {

        // Initialize contact and application
        Id appControlId = appInfo.appControlId;
        Id contactId = appInfo.contactId;
        noApplication = noApp;

        con = new Contact();
        app = new Application__c(Application_Control__c = appControlId, Application_Status__c = appInfo.appStartStatus);
        appInfo.appId = app.Id;

        // List of question groups to display
        List<ApplicationQuestionGroup> groups = new List<ApplicationQuestionGroup>();

        Map<Id, List<Question_Dependency__c>> dQuestions = new Map<Id, List<Question_Dependency__c>>();
        ApplicationQuestion programQuestion;

        // Add first group to beginning
        if (firstGroup != null) {
            firstGroup = addDependencyToQuestions(firstGroup);
            groups.add(firstGroup);
        }

        if (!noApplication) {
            // Query for Requirement Items and Questions to display on Application Creation
            items = [
                    SELECT Id, File_Types__c, Requirement__r.Application_Creation_Display_Order__c, Active__c, Required__c, Required_Number_of_Children__c, Maximum_Number_of_Children__c, Requirement__r.Name, Name, Label__c,
                            Instructions__c, Intended_Program__c, Application_Status__c, Applicant_Type__c, Citizenship__c, Degree_Type__c, Delivery_Type__c,
                            Residency__c, School_College__c, Student_Type__c, RecordType.DeveloperName, Allow_Text_Entry__c, Related_List_Object__c, Related_List_Object_Master__c, Related_Object_Record_Type_ID__c,
                            Related_List_Object_Master_Field__c, Related_List_Where_Clause__c, Holding_Record_Id__c, Internal_Requirement_Item__c, Editable_Application_Status__c,
                            Internal_Only__c, Requirement__r.Internal_Only__c, Internal_Only_Applicant_Instructions__c, Allow_Supporting_Documentation_Upload__c, Required_Supporting_Documentation__c,
                            Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c,
                            Uploaded_Document_Object__c, File_Name_Prefix__c, Internal_Only_Show_on_Checklist__c, Display_on_Checklist__c, Requirement__c, (
                            SELECT Id, Active__c, Required__c, Label__c, Intended_Program__c, Application_Status__c, Applicant_Type__c, Citizenship__c,
                                    Degree_Type__c, Delivery_Type__c, Residency__c, School_College__c, Student_Type__c, RecordType.DeveloperName,
                                    Picklist_Values__c, Placeholder__c, Length__c, Help_Text__c, Dependency_Logic__c, Dependency_Behavior__c, Related_Object_Field__c, Name_Field_API_Name__c,
                                    Lookup_Object__c, Lookup_Where_Clause__c, URL_Parameter__c, New_Reference_Field__c, Contact_Field__c, Application_Field__c, External_Email_Field__c, Hardcoded_Value__c, Static_Text__c,
                                    Editable_Application_Status__c, Display_as_Picklist__c, Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c,
                                    Assistive_Text__c, RecordType.Name, Related_Object__c, Additional_Field_Validation__c
                            FROM Questions__r
                            WHERE Active__c = TRUE
                            ORDER BY Display_Order__c ASC NULLS LAST
                    )
                    FROM Requirement_Item__c
                    WHERE Requirement__r.Application_Control__c = :appControlId
                    AND Requirement__r.Show_on_Application_Creation__c = TRUE
                    AND Requirement__r.Active__c = TRUE AND Active__c = TRUE
                    ORDER BY Display_Order__c ASC NULLS LAST
            ];

            // Get map of requirement responses
            Map<Id, Requirement_Response__c> responses = new Map<Id, Requirement_Response__c>();
            Map<String, Map<String, SObjectField>> fields = new Map<String, Map<String, SObjectField>>();
            for (Requirement_Item__c i : items) {
                responses.put(i.Id, new Requirement_Response__c(Requirement_Item__c = i.Id));
                if (i.RecordType.DeveloperName == 'Related_Object') {
                    fields.put(i.Related_List_Object__c, Schema.getGlobalDescribe().get(i.Related_List_Object__c).getDescribe().fields.getMap());
                }
            }

            // Create question groups for requirements we should display
            for (Requirement_Item__c i : items) {
                if ((String.isBlank(i.Requirement__r.Application_Creation_Display_Order__c) || i.Requirement__r.Application_Creation_Display_Order__c.equals('Before Term/Program Questions')) && ApplicationFilter.filter(app, i)) {
                    ApplicationQuestionGroup middleGroup = ApplicationQuestionSection.createQuestionGroup(con, app, i, null, responses.get(i.Id), null, fields, true);
                    middleGroup = addDependencyToQuestions(middleGroup);
                    groups.add(middleGroup);
                }
            }

            // Add term and program questions if not hidden
            if (!appInfo.hideTermProgram) {

                // Get map of intended programs with id as key, and only for a specific Application Control
                List<Program__c> programs = [
                        SELECT Id, Name, Academic_Level__c, Program_Name_on_Application__c, Active__c, Applicant_Type__c, Citizenship__c, Degree_Type__c, Degree__c,
                                Delivery_Type__c, Residency__c, School_College__c, Student_Type__c, Hide_Applicant_Type__c, Hide_Citizenship__c,
                                Hide_Student_Type__c, Number_of_Applications_Limit__c, Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c,
                                Generic_Filter_4__c, Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c, Application_Control__c
                        FROM Program__c
                        WHERE Hide_from_Application__c = :false
                        AND Active__c = :true
                        AND Application_Control__c = :appControlId
                        //AND Degree__c = :degreeType
                        ORDER BY Name ASC
                ];

                intendedPrograms = new Map<Id, Program__c>(programs);

                // Create new program question and add to list
                programQuestion = new ApplicationQuestion(con, app, '', app, 'Intended_Program__c');
                programQuestion.addQuestionObject(new Question__c(Label__c = 'What program are you applying to?', Required__c = app.Application_Status__c, Active__c = true, URL_Parameter__c = 'Program', Assistive_Text__c = 'You must select the program you are applying for.'));
                programQuestion.addIntendedProgramFilteringList(programs);
                programQuestion.hasDependentQuestions = true;

                // Get map of term names with id as key - updated by FDF 12/17/2021 to pull a unique list of Academic Terms that have an Intended Program Term for that Application Control
                List<Academic_Term__c> aTermList = new List<Academic_Term__c>();
                List<Id> termIds = new List<Id>();
                List<String> termNames = new List<String>();

                //pull a list of all Academic_Term__c records that are associated to the Application Control
                AggregateResult[] at = [
                        SELECT Academic_Term__r.Id, Academic_Term__r.Name, Academic_Term__r.Term_Start_Date__c, Academic_Term__r.Term_End_Date__c
                        FROM Intended_Program_Term__c
                        WHERE Intended_Program__r.Application_Control__c = :appControlId
                        AND Intended_Program__c IN :programs
                        AND Academic_Term__r.Application_Status__c = 'Active'
                        AND Application_Status__c = 'Active'
                        GROUP BY Academic_Term__r.Id, Academic_Term__r.Name, Academic_Term__r.Term_Start_Date__c, Academic_Term__r.Term_End_Date__c
                        ORDER BY Academic_Term__r.Term_Start_Date__c
                ];

                for (AggregateResult ar : at) {
                    Academic_Term__c aTerm = new Academic_Term__c();
                    aTerm.Id = (Id) ar.get('Id');
                    String formattedName = '';

                    //TODO: Assuming CST here. Maybe make time zone setting for application control to set this or academic term
                    if ((Date) ar.get('Term_Start_Date__c') != null && (Date) ar.get('Term_End_Date__c') != null) {
                        //Parenthesis around the time zone string because class is used to parsing that out of a generated picklist that includes it.
                        Time endDayTime = Time.newInstance(23, 59, 59, 59);
                        Datetime startTermDateTime = ApplicationUtilities.convertDateToDatetime((Date) ar.get('Term_Start_Date__c'), endDayTime, '(America/Chicago)');
                        Datetime endTermDateTime = ApplicationUtilities.convertDateToDatetime((Date) ar.get('Term_End_Date__c'), endDayTime, '(America/Chicago)');
                        formattedName = ' (Start Date: ' + startTermDateTime.format('MMM dd, yyyy') + ')';
                    }

//                    aTerm.Name = (String) ar.get('Name') + formattedName;
                    aTerm.Name = (String) ar.get('Name');

                    aTermList.add(aTerm);

                    termIds.add(aTerm.Id);
                    termNames.add(aTerm.Name);

                }

                // Create new term question and add to list
                ApplicationQuestion termQuestion = new ApplicationQuestion(con, app, '', app, 'Intended_Term_of_Entry__c');
                termQuestion.addQuestionObject(new Question__c(Label__c = 'What term are you applying for?', Required__c = app.Application_Status__c, Active__c = true, URL_Parameter__c = 'Term', Assistive_Text__c = 'You must select the term you are applying for.'));
                termQuestion.setReferenceOptions(termIds, termNames);
                termQuestion.hasDependentQuestions = true;

                // Create question group out of term/program questions and add to list
                ApplicationQuestionGroup termProgramQuestionGroup = new ApplicationQuestionGroup(new List<ApplicationQuestion>{
                        termQuestion, programQuestion
                });
                termProgramQuestionGroup = addDependencyToQuestions(termProgramQuestionGroup);
                groups.add(termProgramQuestionGroup);
            }


            // Create question groups for requirements we should display
            for (Requirement_Item__c i : items) {
                if (String.isNotBlank(i.Requirement__r.Application_Creation_Display_Order__c) && i.Requirement__r.Application_Creation_Display_Order__c.equals('After Term/Program Questions') && ApplicationFilter.filter(app, i)) {
                    groups.add(ApplicationQuestionSection.createQuestionGroup(con, app, i, null, responses.get(i.Id), null, fields, true));
                }
            }
            // Get map of Question Dependencies with Question ids as key

            for (Question_Dependency__c dq : [
                    SELECT Id, Question__c, Controlling_Question__c, Value__c, ValueCheckbox__c, RecordType.DeveloperName
                    FROM Question_Dependency__c
                    WHERE Question__r.Requirement_Item__r.Requirement__r.Application_Control__c = :appControlId
                    AND Question__r.Requirement_Item__r.Requirement__r.Show_on_Application_Creation__c = :true
            ]) {

                // Add new list to map if we don't have one yet
                if (!dQuestions.containsKey(dq.Question__c)) {
                    dQuestions.put(dq.Question__c, new List<Question_Dependency__c>());
                }

                // Add Question Dependency to list
                dQuestions.get(dq.Question__c).add(dq);
            }
        }

        // Query for contact if we have one
        if (contactId != null) {

            // Loop over questions and get contact fields
            contactFields = new Set<String>();
            if (items != null) {
                for (Requirement_Item__c ri : items) {
                    for (Question__c q : ri.Questions__r) {
                        if (String.isNotBlank(q.Contact_Field__c)) {
                            contactFields.add(q.Contact_Field__c.toLowerCase());
                        }
                    }
                }
            }
            // Query for contact
            if (!contactFields.isEmpty()) {
                String query = 'SELECT ' + applicationHelper.getApplicationContactFields(items) + ' FROM Contact WHERE Id = :contactId';
                con = ((List<Contact>) Database.query(query)).get(0);
            }
        }

        // Add last group to end
        if (lastGroup != null) {
            groups.add(lastGroup);
        }

        // Create new section out of groups
        section = new ApplicationQuestionSection(groups);
        section.addDependencies(dQuestions, null);

        if (programQuestion != null) {
            programQuestion.section = section;
        }
    }

    public ApplicationQuestionGroup addDependencyToQuestions(ApplicationQuestionGroup appQuestionGroup) {
        if (appQuestionGroup.questions.size() > 0) {
            for (Integer x = 0; x < appQuestionGroup.questions.size(); x++) {
                String inputType = appQuestionGroup.questions[x].fieldType;
                if (inputType.equalsIgnoreCase('picklist') || inputType.equalsIgnoreCase('checkbox')) {
                    appQuestionGroup.questions[x].hasDependentQuestions = true;
                }
            }
        }
        return appQuestionGroup;
    }

    /* ******************************************************************************
    * @description Saves a new application based on the answers from the VisualForce page
    ********************************************************************************/
    public PageReference save() {

        section.pushValuesToObjects();
        Savepoint sp = Database.setSavepoint(); // Set savepoint in case we need to roll-back
        Boolean dmlException = false;

        // Try to do save and catch exceptions
        try {

            // Throw exception if not all required fields have been filled-out
            String errorMessage = '';
            if (!noApplication) {
                errorMessage = checkFields();
            }

            if (String.isNotBlank(errorMessage)) {
                throw new ApplicationUtilities.ApplicationException(errorMessage, false, true);
            }

            return new PageReference(saveApplication());

        } catch (DmlException err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getDmlMessage(0)));
            dmlException = true;
            Database.rollback(sp);
        } catch (ApplicationUtilities.ApplicationException err) {

            ApexPages.addMessage(new ApexPages.Message(err.isError ? ApexPages.Severity.ERROR : ApexPages.Severity.CONFIRM, err.getMessage()));
            if (err.doRollback) {
                Database.rollback(sp);
            }

        } catch (Exception err) {
            if (!dmlException) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage()));
                Database.rollback(sp);
            }
            dmlException = false;
        }

        return null; // Return null if exception caught
    }

    /* ******************************************************************************
    * @description Returns error message if not all fields required fields are filled-out, null otherwise
    ********************************************************************************/
    public String checkFields() {

        // Populates the application based on answers from the visualforce page
        for (ApplicationQuestionGroup aqg : section.groups) {
            if (aqg.questionGroup) {
                for (ApplicationQuestion question : aqg.questions) {
                    if (String.isNotBlank(question.fieldName) && question.response != null) {

                        question.processValue();

                        if (question.question != null && String.isNotBlank(question.question.Required__c) && question.showQuestion && String.isBlank(String.valueOf(question.resp))) {
                            return question.label + ' is required to start your application.';
                        }
                    }
                }
            } else if (aqg.relatedObject) {
                if (ApplicationUtilities.containsValue(aqg.item.Required__c, app.Application_Status__c) && aqg.item.Required_Number_of_Children__c != null && (aqg.relatedObjects == null || aqg.relatedObjects.size() < aqg.item.Required_Number_of_Children__c)) {
                    return 'At least ' + aqg.item.Required_Number_of_Children__c + ' ' + (String.isBlank(aqg.item.Label__c) ? aqg.item.Name : aqg.item.Label__c) + ' record' + (aqg.item.Required_Number_of_Children__c > 1 ? 's are' : ' is') + ' required to start your application.';
                }
            }
        }

        section.pushValuesToObjects();

        // Check to see if term/program are valid if not hidden
        if (!appInfo.hideTermProgram) {

            // Throw exception if invalid program was selected
            String programError = 'The selected program is not available.';
            if (!noApplication) {
                Program__c ip = intendedPrograms.get(app.Intended_Program__c);
                if (!ApplicationFilter.filter(app, ip, false)) {
                    return programError;
                }
                if (String.isNotBlank(ip.Hide_Applicant_Type__c) && String.isNotBlank(app.Applicant_Type__c) && (new Set<String>(ip.Hide_Applicant_Type__c.split(';'))).contains(app.Applicant_Type__c)) {
                    return programError;
                }
                if (String.isNotBlank(ip.Hide_Student_Type__c) && String.isNotBlank(app.Student_Type__c) && (new Set<String>(ip.Hide_Student_Type__c.split(';'))).contains(app.Student_Type__c)) {
                    return programError;
                }
                if (String.isNotBlank(ip.Hide_Citizenship__c) && String.isNotBlank(app.Citizenship__c) && (new Set<String>(ip.Hide_Citizenship__c.split(';'))).contains(app.Citizenship__c)) {
                    return programError;
                }

                // Throw exception if invalid term was selected
                Boolean termLocked = false;
                for (Intended_Program_Term__c ipt : [
                        SELECT Id, Applicant_Type__c, Application_Status__c, Citizenship__c, Degree_Type__c, Delivery_Type__c,
                                Residency__c, School_College__c, Student_Type__c, Intended_Program__c, Generic_Filter_1__c,
                                Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c
                        FROM Intended_Program_Term__c
                        WHERE Academic_Term__c = :app.Intended_Term_of_Entry__c
                        AND Application_Status__c = :'Inactive'
                        AND (Intended_Program__c = :app.Intended_Program__c
                        OR Intended_Program__c = :null)
                ]) {

                    if (ApplicationFilter.filter(app, ipt, false)) {
                        return 'The selected program is not available for this term.';
                    }
                }

                // Check to make sure selections are valid for number of applications limit
                if (app.Contact__c != null && String.isNotBlank(ip.Number_of_Applications_Limit__c)) {
                    for (Application__c a : [
                            SELECT Id, Intended_Program__c, Intended_Term_of_Entry__c, Application_Status__c, Application_Substatus__c, Applicant_Type__c
                            FROM Application__c
                            WHERE Contact__c = :app.Contact__c
                            AND Application_Status__c != 'Wrong Application'
                            AND (NOT (Application_Status__c = 'Withdrawn' AND Application_Substatus__c = 'Wrong App'))
                            AND (NOT (Application_Status__c = 'Withdrawn' AND Application_Substatus__c = 'Multiple App'))
                    ]) {
                        if (ip.Number_of_Applications_Limit__c.equals('One Application')) {
                            return 'You already have an application. Only one application is allowed.';
                        } else if ((ip.Number_of_Applications_Limit__c.equals('One Application Per Term') || ip.Number_of_Applications_Limit__c.equals('One Application Per Term Per Program')) && app.Intended_Term_of_Entry__c == a.Intended_Term_of_Entry__c) {
                            return 'You already have an application for this term. Only one application per term is allowed.';
                        } else if (ip.Number_of_Applications_Limit__c.equals('One Application Per Program') && app.Intended_Program__c == a.Intended_Program__c) {
                            return 'You already have an application for this program. Only one application per program is allowed.';
                        } else if (ip.Number_of_Applications_Limit__c.equals('One Application Per Term and Program') && app.Intended_Program__c == a.Intended_Program__c && app.Intended_Term_of_Entry__c == a.Intended_Term_of_Entry__c) {
                            return 'You already have an application for this program and term. Only one application per program and term is allowed.';
                        }
                    }
                }
            }
        }

        return '';
    }

    public String saveApplication(Boolean createInteraction) {
        return saveApplicationHelper(createInteraction);
    }

    public String saveApplication() {
        return saveApplicationHelper(true);
    }

    /* ******************************************************************************
    * @description Saves application and returns URL to new application checklist
    ********************************************************************************/
    public String saveApplicationHelper(Boolean createInteraction) {

        if (con.Id != null) update con; // Update contact

        if (!noApplication) {
            app.Id = null;

            //Set the generic filter 4 with the term value
            if (String.isNotBlank(app.Intended_Term_of_Entry__c)) {
                Academic_Term__c termInfo = [SELECT Id, Name FROM Academic_Term__c WHERE Id = :app.Intended_Term_of_Entry__c];
                if (termInfo != null) {
                    app.Generic_Filter_4__c = termInfo.Name;
                }
            }

            //Get the email value out of the question group response
            if (String.isNotBlank(app.Contact__c)) {
                Contact contactEmail = [SELECT Id, Email FROM Contact WHERE Id = :app.Contact__c];
                app.Applicant_Email__c = contactEmail.Email;
            } else {
                for (ApplicationQuestionGroup aqg : section.groups) {
                    for (ApplicationQuestion question : aqg.questions) {
                        if (String.isNotBlank(question.fieldName)) {
                            if (question.fieldName.equalsIgnoreCase('Email__c')) {
                                if (String.isNotBlank(String.valueOf(question.resp))) {
                                    app.Applicant_Email__c = String.valueOf(question.resp);
                                }
                            }
                        }
                    }
                }
            }


            insert app; // Insert application


            // Serialize additionalData if we have it
            transient Map<String, Object> additionalData;
            if (String.isNotBlank(additionalDataString)) {
                additionalData = (Map<String, Object>) JSON.deserializeUntyped(additionalDataString);
            }

            // Process all values for section
            section.processValues(additionalData);

            // Get list of requirement responses to insert
            List<Requirement_Response__c> rrLst = new List<Requirement_Response__c>();
            List<List<Question_Response__c>> qrReqList = new List<List<Question_Response__c>>();
            for (ApplicationQuestionGroup aqg : section.groups) {
                if (aqg.response != null) {
                    aqg.response.Application__c = app.Id;
                    rrLst.add(aqg.response.clone(false, true, false, false));

                    List<Question_Response__c> reqQuestionResponses = new List<Question_Response__c>();
                    qrReqList.add(reqQuestionResponses);

                    if (aqg.questionGroup && aqg.questions != null) {
                        for (ApplicationQuestion q : aqg.questions) {
                            if (q.response != null) {
                                reqQuestionResponses.add(q.response.clone(false, true, false, false));
                            }
                        }
                    }
                }
            }

            upsert rrLst; // Insert requirement responses

            // Get list of question responses to insert
            List<Question_Response__c> qResponses = new List<Question_Response__c>();
            for (Integer i = 0; i < rrLst.size(); i++) {

                Id rrId = rrLst[i].Id;

                for (Question_Response__c qr : qrReqList[i]) {
                    qr.Requirement_Response__c = rrId;
                    qr.Application__c = app.Id;
                    qr.PopulatedOn__c = Datetime.now();
                }

                qResponses.addAll(qrReqList[i]);
            }

            upsert qResponses; // Insert question responses
        }
        //create interaction
        if (createInteraction) {
            Interaction__c interaction = populateInteraction(new Interaction__c());
            if (interaction.Email__c != null) {
                insert interaction;
            }
        } else {
            updateInteraction();
        }

        // Return URL for checklist page for new application
        String returnUrl = '/apex/ApplicationPortal';
        if (!noApplication) {
            returnURL += '?applicationId=' + app.Id + (String.isBlank(appInfo.at) ? '' : ('&at=' + appInfo.at));
            appInfo = ApplicationUtilities.setApplicationInfo(appInfo, app);
        } else {
            appInfo = new EASYApplicationInfo();
        }
        ApplicationUtilities.createEncryptedCookie(JSON.serialize(appInfo));
        return returnURL;
    }

    public Interaction__c populateInteraction(Interaction__c interaction) {
        Id application_opp_RT_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Applicant_Opportunity').getRecordTypeId();
        interaction.Id = null;
        interaction.Contact__c = null;
        interaction.OwnerId = Test.isRunningTest() ? UserInfo.getUserId() : Site.getAdminId();
        // populate interaction with contact, application, program, and term information
        if (app != null && app.Id != null) {
            Application__c currentApplication = [
                    SELECT Id,
                            Generic_Filter_2__c,
                            Degree_Level__c,
                            Major_1__c,
                            Major_2__c,
                            Major_3__c,
                            Contact__c,
                            Contact__r.FirstName,
                            Contact__r.MiddleName,
                            Contact__r.LastName,
                            Contact__r.Email,
                            Contact__r.Birthdate,
                            Contact__r.MailingCountry,
                            Contact__r.MailingCity,
                            Contact__r.MailingPostalCode,
                            Contact__r.MailingStreet,
                            Contact__r.MailingState,
                            Contact__r.HomePhone,
                            Intended_Term_of_Entry__c,
                            Intended_Program__c,
                            Intended_Program__r.Program_College_of_Interest__c,
                            Intended_Program__r.Program_Applicant_Type__c,
                            Intended_Term_of_Entry__r.Term__c,
                            Applicant_Type__c
                    FROM Application__c
                    WHERE Id = :app.Id
                    LIMIT 1
            ];
            interaction.Admissions_Application__c = app.Id;
            interaction.Citizenship__c = app.Citizenship__c;
            interaction.Gender__c = currentApplication.Generic_Filter_2__c;
            interaction.Degree_Level__c = currentApplication.Degree_Level__c;
            interaction.Major_Program_1__c = currentApplication.Major_1__c;
            interaction.Major_Program_2__c = currentApplication.Major_2__c;
            interaction.Major_Program_3__c = currentApplication.Major_3__c;
            interaction.First_Name__c = currentApplication.Contact__r.FirstName;
            interaction.Middle_Name__c = currentApplication.Contact__r.MiddleName;
            interaction.Last_Name__c = currentApplication.Contact__r.LastName;
            interaction.Email__c = currentApplication.Contact__r.Email;
            interaction.Birthdate__c = currentApplication.Contact__r.Birthdate;
            interaction.Mailing_Country__c = currentApplication.Contact__r.MailingCountry;
            interaction.Mailing_City__c = currentApplication.Contact__r.MailingCity;
            interaction.Mailing_Postal_Code__c = currentApplication.Contact__r.MailingPostalCode;
            interaction.Mailing_Street__c = currentApplication.Contact__r.MailingStreet;
            interaction.Mailing_State__c = currentApplication.Contact__r.MailingState;
            interaction.Home_Phone__c = currentApplication.Contact__r.HomePhone;
            interaction.Intended_Start_Term__c = currentApplication.Intended_Term_of_Entry__c;
            interaction.Academic_Program__c = currentApplication.Intended_Program__c;
            interaction.College_of_Interest__c = currentApplication.Intended_Program__r.Program_College_of_Interest__c;
            interaction.Admit_Type__c = currentApplication.Intended_Program__r.Program_Applicant_Type__c;
            interaction.Term__c = currentApplication.Intended_Term_of_Entry__r.Term__c;
            List<Plan__c> relatedPlan = [SELECT Id FROM Plan__c WHERE Program__c = :currentApplication.Intended_Program__c LIMIT 1];
            if (!relatedPlan.isEmpty()) {
                interaction.Recruitment_Interest__c = relatedPlan[0].Id;
            }
            interaction.Contact__c = currentApplication.Contact__c;
        }

        interaction.Opportunity_Stage__c = 'Started App';
        interaction.Opportunity_Record_Type__c = application_opp_RT_ID;
        interaction.Interaction_Source__c = 'Application';
        interaction.Date_Started_App__c = System.today();
        interaction.Lead_Source__c = 'Application';

        return interaction;
    }

    public void updateInteraction() {
        // get previously created interaction (from ApplicationRegistration) and update with info on application and contact
        Interaction__c interaction;
        Id currentContactId;
        Id intendedStartTermId;
        Id academicProgramId;
        if (app != null && app.Id != null) {
            Application__c currentApplication = [
                    SELECT Id,
                            Intended_Term_of_Entry__c,
                            Intended_Program__c,
                            Generic_Filter_2__c,
                            Degree_Level__c,
                            Major_1__c,
                            Major_2__c,
                            Major_3__c,
                            Contact__c,
                            Contact__r.Birthdate,
                            Contact__r.MailingCountry,
                            Contact__r.MailingCity,
                            Contact__r.MailingPostalCode,
                            Contact__r.MailingStreet,
                            Contact__r.MailingState,
                            Contact__r.HomePhone,
                            Applicant_Type__c
                    FROM Application__c
                    WHERE Id = :app.Id
                    LIMIT 1
            ];

            interaction = [
                    SELECT Id
                    FROM Interaction__c
                    WHERE Contact__c = :currentApplication.Contact__c
                    AND Intended_Start_Term__c = :currentApplication.Intended_Term_of_Entry__c
                    AND Academic_Program__c = :currentApplication.Intended_Program__c
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];
            interaction.Admissions_Application__c = app.Id;
            interaction.Gender__c = currentApplication.Generic_Filter_2__c;
            interaction.Degree_Level__c = currentApplication.Degree_Level__c;
            interaction.Major_Program_1__c = currentApplication.Major_1__c;
            interaction.Major_Program_2__c = currentApplication.Major_2__c;
            interaction.Major_Program_3__c = currentApplication.Major_3__c;
            interaction.Birthdate__c = currentApplication.Contact__r.Birthdate;
            interaction.Mailing_Country__c = currentApplication.Contact__r.MailingCountry;
            interaction.Mailing_City__c = currentApplication.Contact__r.MailingCity;
            interaction.Mailing_Postal_Code__c = currentApplication.Contact__r.MailingPostalCode;
            interaction.Mailing_Street__c = currentApplication.Contact__r.MailingStreet;
            interaction.Mailing_State__c = currentApplication.Contact__r.MailingState;
            interaction.Home_Phone__c = currentApplication.Contact__r.HomePhone;
            interaction.Interaction_Status__c = 'New';
            update interaction;
        }
    }

    @RemoteAction
    public static List<SObject> lookupSearch(String sObj, String sObjFilter, String sObjNameField, String term) {
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

            String query = 'Select Id, ' + fieldList;
            query += ' FROM ' + sObj;
            query += ' WHERE ' + likeStatement;
            if (String.isNotBlank(sObjFilter)) {
                query += ' AND (' + sObjFilter + ')';
            }
            query += ' ORDER BY ' + fieldList + ' ASC';
            query += ' LIMIT 50';
            try {
                return Database.query(query);
            } catch (Exception e) {
                return new List<SObject>();
            }
        }
        return new List<SObject>();
    }
}