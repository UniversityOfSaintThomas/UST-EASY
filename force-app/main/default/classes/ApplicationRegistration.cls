/*******************************************************************************
@description This controller is used to create a new contact, account, and application for a user without community access
@author Huron Consulting Group
*******************************************************************************/
public class ApplicationRegistration {

    public ApplicationCreate appCreate { get; set; }
    public Interaction__c interaction { get; set; }
    public Interaction__c extraFields { get; set; }
    private User loginUser { get; set; }
    private String loginPassword { get; set; }
    private String loginUrl { get; set; }
    public EASYApplicationInfo appInfo { get; set; }
    public Boolean cookieKeyPresent { get; set; }
    public String userType { get; set; }

    /*******************************************************************************
    * @description Initialize the page - Sets up all of the requirements and pulls Requirements with the flag (Show on Application Creation)
    ********************************************************************************/
    public ApplicationRegistration() {
        userType = UserInfo.getUserType();
        appInfo = ApplicationUtilities.createShellAppInfo();
        cookieKeyPresent = ApplicationUtilities.cookieKeyPresent();
        if (cookieKeyPresent) {

            // Initialize objects
            appCreate = new ApplicationCreate();
            interaction = new Interaction__c();
            extraFields = new Interaction__c();

            // Exit if there is no Application Control to reference
            if (String.isBlank(appInfo.appControlId)) {
                return;
            }

            // Create questions for first name, middle name, last name, email, password, and password confirmation
            // Required__c is usually tied to Required__c = appCreate.app.Application_Status__c, but that won't work here, since the app isn't created properly until appCreate.applicationCreateSetup(). -JJH
            ApplicationQuestion firstName = new ApplicationQuestion(appCreate.con, appCreate.app, '', interaction, 'First_Name__c');
            firstName.addQuestionObject(new Question__c(Label__c = 'First Name', Required__c = 'yep', Active__c = true));

            ApplicationQuestion middleName = new ApplicationQuestion(appCreate.con, appCreate.app, '', interaction, 'Middle_Name__c');
            middleName.addQuestionObject(new Question__c(Label__c = 'Middle Name', Active__c = true));

            ApplicationQuestion lastName = new ApplicationQuestion(appCreate.con, appCreate.app, '', interaction, 'Last_Name__c');
            lastName.addQuestionObject(new Question__c(Label__c = 'Last Name', Required__c = 'yep', Active__c = true));

            ApplicationQuestion email = new ApplicationQuestion(appCreate.con, appCreate.app, '', interaction, 'Email__c');
            email.addQuestionObject(new Question__c(Label__c = 'Email', Required__c = 'yep', Active__c = true));

            ApplicationQuestion portalPassword = new ApplicationQuestion(appCreate.con, appCreate.app, '', extraFields, 'Last_Name__c', Schema.DisplayType.ENCRYPTEDSTRING, true);
            portalPassword.addQuestionObject(new Question__c(Label__c = 'What password would you like to use for saving your application?', Required__c = 'yep', Active__c = true, Length__c = 40));

            ApplicationQuestion portalPasswordConfirmation = new ApplicationQuestion(appCreate.con, appCreate.app, '', extraFields, 'First_Name__c', Schema.DisplayType.ENCRYPTEDSTRING, true);
            portalPasswordConfirmation.addQuestionObject(new Question__c(Label__c = 'Please enter your password again.', Required__c = 'yep', Active__c = true, Length__c = 40));

            // Create question groups
            ApplicationQuestionGroup firstGroup = new ApplicationQuestionGroup(new List<ApplicationQuestion>{
                    firstName, middleName, lastName, email
            });
            ApplicationQuestionGroup lastGroup = new ApplicationQuestionGroup(new List<ApplicationQuestion>{
                    portalPassword, portalPasswordConfirmation
            });

            // Setup other questions
            appCreate.applicationCreateSetup(firstGroup, lastGroup);
        }
    }

    public PageReference applicationRegistrationInit() {
        ApplicationUtilities.getCookieKey();
        userType = UserInfo.getUserType();
        if (!userType.endsWithIgnoreCase('guest')) {
            PageReference createApp;
            If (String.isNOtBlank(ApexPages.currentPage().getParameters().get('at'))) {
                createApp = Page.ApplicationCreate;
                createApp.getParameters().put('at', ApexPages.currentPage().getParameters().get('at'));
            } else {
                createApp = Page.ApplicationPortal;
            }
            createApp.setRedirect(true);
            return createApp;
        }
        return null;
    }

    public PageReference testCookieKey() {
        ApplicationUtilities.getCookieKey();
        PageReference pageRef = ApexPages.CurrentPage();
        ApexPages.currentPage().getParameters().put('at', ApexPages.currentPage().getParameters().get('at'));
        pageRef.setRedirect(true);
        return pageRef;
    }

    /* ******************************************************************************
    * @description populates fields on the contact and application through the interactions object.
    ********************************************************************************/
    public PageReference submit() {
        System.Savepoint sp = Database.setSavepoint();
        Boolean dmlException = false;
        populateInteraction();
        loginUser = null;
        loginPassword = null;
        loginUrl = null;
        crudToDo doCrud = new crudToDo();

        try {
            // Throw exception if not all required fields have been filled-out
            String errorMessage = appCreate.checkFields();
            if (errorMessage != null) {
                throw new ApplicationUtilities.ApplicationException(errorMessage, false, true);
            }

            // Insert interaction to create/update Contact
            insert interaction;
            interaction = [SELECT Id, Contact__c, First_Name__c, Middle_Name__c, Last_Name__c, Email__c FROM Interaction__c WHERE Id = :interaction.Id];
            Contact con = [SELECT Id, FirstName, MiddleName, LastName, Email, AccountId, Account.OwnerId FROM Contact WHERE Id = :interaction.Contact__c];
            appCreate.con.Id = con.Id;

            // Exit and roll-back if User with Email or Contact already exists
            if (![SELECT Id FROM User WHERE Username = :con.Email OR ContactId = :con.Id LIMIT 1].isEmpty()) {
                throw new ApplicationUtilities.ApplicationException(' An account with this email already exists. Please sign in with the button to the right for existing users."', true, true);
            }

            // Update Account owner to Site admin if owner is current user (guest user)
            if (con.Account.OwnerId == UserInfo.getUserId()) {
                update new Account(Id = con.AccountId, OwnerId = Test.isRunningTest() ? UserInfo.getUserId() : Site.getAdminId());
            }

            // Assign contact to application and save
            appCreate.app.Contact__c = con.Id;

            String checklistUrl = doCrud.returnAppURL(appCreate);

            // Create user object
            User u = new User();
            u.FirstName = con.FirstName;
            u.LastName = con.LastName;
            u.Email = con.Email;
            u.Username = con.Email;
            u.CommunityNickname = (u.Email.length() > 40) ? u.Email.substring(0, 40) : u.Email;
            u.ContactId = con.Id;

            // Create user
            String pass = extraFields.Last_Name__c;
            String passConfirm = extraFields.First_Name__c;
            if (!Test.isRunningTest()) Site.validatePassword(u, pass, passConfirm);

            // Throw exception to rollback if we found an error
            if (ApexPages.hasMessages(ApexPages.Severity.ERROR) && !Test.isRunningTest()) {
                throw new ApplicationUtilities.ApplicationException(null, true);
            }

            Id uId;
            if (!Test.isRunningTest() && pass.equals(passConfirm)) {
                uId = Site.createExternalUser(u, con.AccountId, pass, false);
                if (uId == null) {
                    throw new ApplicationUtilities.ApplicationException('Error occurred when creating user.', true, true);
                }
                loginUser = new User(Id = uId, Username = u.Username);
                loginPassword = pass;
                loginUrl = checklistUrl;
                return Site.login(loginUser.Username, loginPassword, loginUrl);
            }

        } catch (DmlException err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getDmlMessage(0)));
            dmlException = true;
            Database.rollback(sp);
        } catch (ApplicationUtilities.ApplicationException err) {
            if (String.isNotBlank(err.getMessage())) {
                ApexPages.addMessage(new ApexPages.Message(err.isError ? ApexPages.Severity.ERROR : ApexPages.Severity.CONFIRM, err.getMessage()));
            }
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
        return null;
    }

    public void populateInteraction() {
        Id application_opp_RT_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Applicant_Opportunity').getRecordTypeId();
        interaction.Id = null;
        interaction.Contact__c = null;
        for (ApplicationQuestionGroup questionGroup : appCreate.section.groups) {
            for (ApplicationQuestion question: questionGroup.questions) {
                if (question.label == 'What term are you applying for?' && question.resp != null) {
                        interaction.Intended_Start_Term__c = Id.valueOf(String.valueOf(question.resp));
                }
                if (question.label == 'What program are you applying to?' && question.resp != null) {
                    interaction.Academic_Program__c = Id.valueOf(String.valueOf(question.resp));
                }
            }
        }
        if (interaction.Academic_Program__c != null) {
            List<Program__c> program = [SELECT Id, Program_College_of_Interest__c, Program_Applicant_Type__c FROM Program__c WHERE Id =: interaction.Academic_Program__c LIMIT 1];
            if (!program.isEmpty()) {
                interaction.College_of_Interest__c = program[0].Program_College_of_Interest__c;
                interaction.Admit_Type__c = program[0].Program_Applicant_Type__c;
            }
            List<Plan__c> relatedPlan = [SELECT Id FROM Plan__c WHERE Program__c =: interaction.Academic_Program__c LIMIT 1];
            if (!relatedPlan.isEmpty()) {
                interaction.Recruitment_Interest__c = relatedPlan[0].Id;
            }
        }
        if (interaction.Intended_Start_Term__c != null) {
            List<Academic_Term__c> academicTerm = [SELECT Term__c FROM Academic_Term__c WHERE Id =: interaction.Intended_Start_Term__c LIMIT 1];
            if (!academicTerm.isEmpty()) {
                interaction.Term__c = academicTerm[0].Term__c;
            } 
        }
        interaction.Opportunity_Stage__c = 'Started App';
        interaction.Opportunity_Record_Type__c = application_opp_RT_ID;
        interaction.Citizenship__c = appCreate.app.Citizenship__c;
        interaction.Interaction_Source__c = 'Application';
        interaction.Date_Started_App__c = System.Today();
        interaction.Lead_Source__c = 'Application';
        interaction.Interaction_Status__c = 'New';
    }

    public PageReference login() {
        if (String.isNotBlank(loginUrl)) {
            return Site.login(loginUser.Username, loginPassword, loginUrl);
        }
        return null;
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

    private without sharing class crudToDo {
        public String returnAppURL(ApplicationCreate appCreate) {
            String nextURL = appCreate.saveApplication(false);
            return nextURL;
        }

    }
}