@IsTest
private class EASYAppReviewController_TEST {

    @TestSetup
    static void setup() {
        Contact con = new Contact(LastName = 'Applicant');
        insert con;

        Application_Control__c appControl = new Application_Control__c(
                Name = 'Undergraduate 2026',
                Active__c = true,
                Application_Start_Status__c = 'Started App'
        );
        insert appControl;

        Application__c app = new Application__c(
                Contact__c = con.Id,
                Application_Control__c = appControl.Id
        );
        insert app;

        Id questionGroupRtId = rtId('Requirement_Item__c', 'Question_Group');
        Id textQuestionRtId = rtId('Question__c', 'Text');

        Requirement__c requirement = new Requirement__c(
                Name = 'Personal Information',
                Label__c = 'Personal Information',
                Application_Control__c = appControl.Id,
                Active__c = true,
                Display_on_Admin_Review_Pages__c = true,
                Show_on_Application_Creation__c = false,
                Display_Order__c = 1
        );
        insert requirement;

        Requirement_Item__c requirementItem = new Requirement_Item__c(
                Name = 'Basic Info',
                Label__c = 'Basic Info',
                Requirement__c = requirement.Id,
                RecordTypeId = questionGroupRtId,
                Active__c = true,
                Display_on_Admin_Review_Pages__c = true,
                Display_Order__c = 1
        );
        insert requirementItem;

        Question__c question = new Question__c(
                Name = 'Favorite Color',
                Label__c = 'Favorite Color',
                Requirement_Item__c = requirementItem.Id,
                RecordTypeId = textQuestionRtId,
                Active__c = true,
                Display_on_Admin_Review_Pages__c = true,
                Display_Order__c = 1
        );
        insert question;

        Requirement_Response__c requirementResponse = new Requirement_Response__c(
                Application__c = app.Id,
                Requirement_Item__c = requirementItem.Id
        );
        insert requirementResponse;

        Question_Response__c questionResponse = new Question_Response__c(
                Requirement_Response__c = requirementResponse.Id,
                Question__c = question.Id,
                Application__c = app.Id,
                ValueText__c = 'Blue',
                IsShown__c = true,
                IsPopulated__c = true,
                IsRequired__c = false
        );
        insert questionResponse;
    }

    private static Id rtId(String sobjectType, String developerName) {
        return [
                SELECT Id FROM RecordType
                WHERE SobjectType = :sobjectType AND DeveloperName = :developerName
                LIMIT 1
        ].Id;
    }

    // ── Positive ────────────────────────────────────────────────────────────

    @IsTest
    static void getApplicationControl_returnsPopulatedWrapper() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(app.Id);
        Test.stopTest();

        System.assertNotEquals(null, result.appControl, 'Expected appControl to be populated');
        System.assertEquals(1, result.requirements.size(), 'Expected one requirement');
        EASYAppRequirementWrapper reqWrapper = result.requirements[0];
        System.assertEquals(1, reqWrapper.requirementItems.size(), 'Expected one requirement item');
        EASYAppRequirementItemWrapper itemWrapper = reqWrapper.requirementItems[0];
        System.assertEquals(1, itemWrapper.questions.size(), 'Expected one question');
        EASYAppQuestionResponseWrapper qWrapper = itemWrapper.questions[0];
        System.assertEquals(true, qWrapper.answered, 'Question should be marked answered');
        System.assertEquals('Blue', qWrapper.questionResponse.ValueText__c);
    }

    @IsTest
    static void getApplicantInfo_returnsApplication() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        Application__c result = EASYAppReviewController.getApplicantInfo(app.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(app.Id, result.Id);
    }

    // ── Negative ────────────────────────────────────────────────────────────

    @IsTest
    static void getApplicationControl_blankAppId_returnsEmptyWrapper() {
        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(null);
        Test.stopTest();

        System.assertEquals(null, result.appControl);
        System.assertEquals(null, result.requirements);
    }

    @IsTest
    static void getApplicationControl_unknownAppId_returnsEmptyWrapper() {
        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(
                '001000000000000AAA'
        );
        Test.stopTest();

        System.assertEquals(null, result.appControl);
    }

    @IsTest
    static void getApplicantInfo_blankAppId_returnsNull() {
        Test.startTest();
        Application__c result = EASYAppReviewController.getApplicantInfo(null);
        Test.stopTest();

        System.assertEquals(null, result);
    }

    // ── Bulk / reentrancy ───────────────────────────────────────────────────
    // Regression test for the static-state bug: calling getApplicationControl twice in the
    // same transaction for two different applications must not leak state between calls.

    @IsTest
    static void getApplicationControl_calledTwiceInSameTransaction_doesNotLeakState() {
        Contact con2 = new Contact(LastName = 'SecondApplicant');
        insert con2;

        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Application__c app1 = [SELECT Id FROM Application__c LIMIT 1];
        Application__c app2 = new Application__c(
                Contact__c = con2.Id,
                Application_Control__c = appControl.Id
        );
        insert app2;

        Test.startTest();
        EASYAppWrapper result1 = EASYAppReviewController.getApplicationControl(app1.Id);
        EASYAppWrapper result2 = EASYAppReviewController.getApplicationControl(app2.Id);
        Test.stopTest();

        // app1 has one answered question; app2 has no responses at all — if static state
        // leaked, result2 would incorrectly show app1's answered question too.
        System.assertEquals(1, result1.requirements.size());
        System.assertEquals(1, result1.requirements[0].requirementItems.size());
        System.assertEquals(true, result1.requirements[0].requirementItems[0].questions[0].answered);

        System.assertEquals(1, result2.requirements.size());
        System.assertEquals(1, result2.requirements[0].requirementItems.size());
        System.assertEquals(false, result2.requirements[0].requirementItems[0].questions[0].answered,
                'app2 has no question response — static-state leakage would make this incorrectly true');
    }

    // ── Address, headings and related records ───────────────────────────────

    private static Requirement__c newRequirement(String label, String name, Integer order) {
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Requirement__c requirement = new Requirement__c(
                Name = name,
                Label__c = label,
                Application_Control__c = appControl.Id,
                Active__c = true,
                Display_on_Admin_Review_Pages__c = true,
                Show_on_Application_Creation__c = false,
                Display_Order__c = order
        );
        insert requirement;
        return requirement;
    }

    private static Requirement_Item__c newItem(Requirement__c requirement, String label, String name, String recordTypeName) {
        Requirement_Item__c item = new Requirement_Item__c(
                Name = name,
                Label__c = label,
                Requirement__c = requirement.Id,
                RecordTypeId = rtId('Requirement_Item__c', recordTypeName),
                Active__c = true,
                Display_on_Admin_Review_Pages__c = true,
                Display_Order__c = 1
        );
        insert item;
        return item;
    }

    private static EASYAppRequirementWrapper requirementByTitle(EASYAppWrapper result, String title) {
        for (EASYAppRequirementWrapper candidate : result.requirements) {
            if (candidate.title == title) {
                return candidate;
            }
        }
        return null;
    }

    private static void addContactAddressQuestion(Contact con) {
        Requirement__c requirement = newRequirement('Contact Information', 'Contact Information', 2);
        Requirement_Item__c item = newItem(requirement, 'Address', 'Address', 'Question_Group');
        insert new Question__c(
                Name = 'Home Address',
                Label__c = 'Home Address',
                Requirement_Item__c = item.Id,
                RecordTypeId = rtId('Question__c', 'Address'),
                Contact_Field__c = 'MailingAddress',
                Active__c = true,
                Display_on_Admin_Review_Pages__c = true,
                Display_Order__c = 1
        );
    }

    @IsTest
    static void getApplicationControl_addressMappedToContact_showsContactAddressWithoutAResponse() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        con.MailingStreet = '1 Test Street';
        con.MailingCity = 'Saint Paul';
        con.MailingPostalCode = '55105';
        update con;
        addContactAddressQuestion(con);
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(app.Id);
        Test.stopTest();

        EASYAppQuestionResponseWrapper question = requirementByTitle(result, 'Contact Information')
                .requirementItems[0].questions[0];
        System.assertEquals(true, question.answered, 'The Contact address should count as the answer');
        System.assertEquals(true, question.show_question);
        System.assertEquals(true, question.hasAddress);
        System.assertEquals('1 Test Street', question.questionResponse.Street__c);
        System.assertEquals('Saint Paul', question.questionResponse.City__c);
    }

    @IsTest
    static void getApplicationControl_contactAddressWithoutStreet_stillShowsAddress() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        con.MailingCity = 'Minneapolis';
        update con;
        addContactAddressQuestion(con);
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(app.Id);
        Test.stopTest();

        EASYAppQuestionResponseWrapper question = requirementByTitle(result, 'Contact Information')
                .requirementItems[0].questions[0];
        System.assertEquals(true, question.hasAddress, 'An address with only a city is still an address');
        System.assertEquals(null, question.questionResponse.Street__c);
    }

    @IsTest
    static void getApplicationControl_contactWithoutAddress_doesNotShowTheAddressQuestion() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        addContactAddressQuestion(con);
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(app.Id);
        Test.stopTest();

        EASYAppQuestionResponseWrapper question = requirementByTitle(result, 'Contact Information')
                .requirementItems[0].questions[0];
        System.assertEquals(false, question.answered);
        System.assertEquals(false, question.show_question);
    }

    @IsTest
    static void getApplicationControl_blankLabel_headingFallsBackToName() {
        Requirement__c requirement = newRequirement(null, 'Requirement Name Only', 3);
        newItem(requirement, null, 'Item Name Only', 'Question_Group');
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(app.Id);
        Test.stopTest();

        EASYAppRequirementWrapper wrapper = requirementByTitle(result, 'Requirement Name Only');
        System.assertNotEquals(null, wrapper, 'A requirement with no Label should be titled with its Name');
        System.assertEquals('Item Name Only', wrapper.requirementItems[0].title);
        // A Label still wins when there is one
        System.assertNotEquals(null, requirementByTitle(result, 'Personal Information'));
    }

    private static void addRecommendationItem(String whereClause) {
        Requirement__c requirement = newRequirement('Recommendations', 'Recommendations', 4);
        Requirement_Item__c item = newItem(requirement, 'Recommendation', 'Recommendation', 'Related_Object');
        item.Related_List_Object__c = 'Recommendation__c';
        item.Related_List_Object_Master__c = 'Application';
        item.Related_List_Object_Master_Field__c = 'Application__c';
        item.Related_List_Where_Clause__c = whereClause;
        update item;
        insert new Question__c(
                Name = 'Recommender First Name',
                Label__c = 'Recommender First Name',
                Requirement_Item__c = item.Id,
                RecordTypeId = rtId('Question__c', 'Text'),
                Related_Object_Field__c = 'first_name__c',
                Active__c = true,
                Display_on_Admin_Review_Pages__c = true,
                Display_Order__c = 1
        );
    }

    @IsTest
    static void getApplicationControl_relatedRecordWithNothingToShow_isNotRenderedAsAnEmptyGroup() {
        addRecommendationItem(null);
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        insert new List<Recommendation__c>{
                new Recommendation__c(Application__c = app.Id, First_Name__c = 'Pat'),
                new Recommendation__c(Application__c = app.Id, Last_Name__c = 'OnlyLastName')
        };

        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(app.Id);
        Test.stopTest();

        EASYAppRequirementItemWrapper item = requirementByTitle(result, 'Recommendations').requirementItems[0];
        System.assertEquals(1, item.relatedObjectAnswers.size(), 'The record with no first name has nothing to show here');
        System.assertEquals('Pat', item.relatedObjectAnswers[0][0].answerValue);
        System.assertEquals(false, item.no_answers);
    }

    @IsTest
    static void getApplicationControl_relatedRecordsWithNothingToShow_reportsNoAnswers() {
        addRecommendationItem(null);
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        insert new Recommendation__c(Application__c = app.Id, Last_Name__c = 'OnlyLastName');

        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(app.Id);
        Test.stopTest();

        EASYAppRequirementItemWrapper item = requirementByTitle(result, 'Recommendations').requirementItems[0];
        System.assertEquals(0, item.relatedObjectAnswers.size());
        System.assertEquals(true, item.no_answers, 'An item with nothing to show should say so');
    }

    @IsTest
    static void getApplicationControl_recommendationItemWhereClause_limitsTheRecordsShown() {
        addRecommendationItem('First_Name__c = \'Match\'');
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        insert new List<Recommendation__c>{
                new Recommendation__c(Application__c = app.Id, First_Name__c = 'Match'),
                new Recommendation__c(Application__c = app.Id, First_Name__c = 'Other')
        };

        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(app.Id);
        Test.stopTest();

        EASYAppRequirementItemWrapper item = requirementByTitle(result, 'Recommendations').requirementItems[0];
        System.assertEquals(1, item.relatedObjectAnswers.size(), 'The where clause on the item should apply to recommendations');
        System.assertEquals('Match', item.relatedObjectAnswers[0][0].answerValue);
    }

    // ── Multi-select answers shown as separate choices (pills) ──────────────

    private static Question__c newMultiSelectQuestion(Requirement_Item__c item, String label, String contactField, Integer order) {
        Question__c question = new Question__c(
                Name = label,
                Label__c = label,
                Requirement_Item__c = item.Id,
                RecordTypeId = rtId('Question__c', 'MultiPicklist'),
                Contact_Field__c = contactField,
                Active__c = true,
                Display_on_Admin_Review_Pages__c = true,
                Display_Order__c = order
        );
        insert question;
        return question;
    }

    private static void answerWith(Question__c question, Requirement_Response__c requirementResponse, Question_Response__c answer) {
        answer.Question__c = question.Id;
        answer.Requirement_Response__c = requirementResponse.Id;
        answer.Application__c = requirementResponse.Application__c;
        answer.IsShown__c = true;
        answer.IsPopulated__c = true;
        answer.IsRequired__c = false;
        insert answer;
    }

    @IsTest
    static void getApplicationControl_multiSelectAnswers_areSplitIntoSeparateTrimmedChoices() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Requirement__c requirement = newRequirement('Choices', 'Choices', 5);
        Requirement_Item__c item = newItem(requirement, 'Choices', 'Choices', 'Question_Group');
        Requirement_Response__c requirementResponse = new Requirement_Response__c(Application__c = app.Id, Requirement_Item__c = item.Id);
        insert requirementResponse;

        Question__c savedInLongText = newMultiSelectQuestion(item, 'Saved in long text', null, 1);
        Question__c savedInText = newMultiSelectQuestion(item, 'Saved in text', null, 2);
        Question__c noValue = newMultiSelectQuestion(item, 'Nothing chosen', null, 3);
        answerWith(savedInLongText, requirementResponse, new Question_Response__c(ValueLongTextArea__c = 'Red;Blue'));
        answerWith(savedInText, requirementResponse, new Question_Response__c(ValueText__c = ' Green ; ;Yellow;'));
        answerWith(noValue, requirementResponse, new Question_Response__c(ValueCheckbox__c = true));

        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(app.Id);
        Test.stopTest();

        Map<String, EASYAppQuestionResponseWrapper> byLabel = new Map<String, EASYAppQuestionResponseWrapper>();
        for (EASYAppQuestionResponseWrapper candidate : requirementByTitle(result, 'Choices').requirementItems[0].questions) {
            byLabel.put(candidate.question.Label__c, candidate);
        }
        System.assertEquals(new List<String>{'Red', 'Blue'}, byLabel.get('Saved in long text').answerMultiValue);
        System.assertEquals(new List<String>{'Green', 'Yellow'}, byLabel.get('Saved in text').answerMultiValue,
                'Choices saved in another text field are split and trimmed too');
        System.assertEquals(null, byLabel.get('Nothing chosen').answerMultiValue,
                'No choices means no pills (an empty list would look present to the template)');
    }

    @IsTest
    static void getApplicationControl_multiSelectMappedToATextField_splitsTheSemicolonSeparatedText() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        con.Description = 'North;South;East';
        update con;
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Requirement__c requirement = newRequirement('Mapped choices', 'Mapped choices', 6);
        Requirement_Item__c item = newItem(requirement, 'Mapped choices', 'Mapped choices', 'Question_Group');
        newMultiSelectQuestion(item, 'Regions', 'Description', 1);

        Test.startTest();
        EASYAppWrapper result = EASYAppReviewController.getApplicationControl(app.Id);
        Test.stopTest();

        EASYAppQuestionResponseWrapper question = requirementByTitle(result, 'Mapped choices').requirementItems[0].questions[0];
        System.assertEquals(true, question.answered);
        System.assertEquals(new List<String>{'North', 'South', 'East'}, question.answerMultiValue);
    }
}