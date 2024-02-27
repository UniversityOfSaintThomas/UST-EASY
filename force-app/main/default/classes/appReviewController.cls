/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */


public with sharing class appReviewController {

    @AuraEnabled(Cacheable=true)
    public static Application__c getApplicantInfo(String appId) {
        return [
                SELECT Id,
                        Name, Contact__r.FirstName, Contact__r.LastName
                FROM Application__c
                WHERE Id = :appId
                LIMIT 1
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static EASYAppWrapper getApplicationControl(String appId) {
        EASYAppWrapper appWrapper = new EASYAppWrapper();
        Application_Control__c appControl = [SELECT Id, Name, Academic_Level__c, Active__c, Degree_Levels__c, School_College__c FROM Application_Control__c WHERE Id IN (SELECT Application_Control__c FROM Application__c WHERE Id = :appId) AND Active__c = TRUE LIMIT 1];
        appWrapper.appControl = appControl;
        appWrapper.requirements = new List<EASYAppRequirementWrapper>();

        if (appControl != null) {
            Map<Id, Requirement__c> requirements = new Map<Id, Requirement__c>([
                    SELECT Id, Name, Active__c, Display_on_Admin_Review_Pages__c, Label__c, Display_Order__c
                    FROM Requirement__c
                    WHERE Application_Control__c = :appControl.Id AND Active__c = TRUE AND Display_on_Admin_Review_Pages__c = TRUE
                    ORDER BY Display_Order__c
            ]);
            Map<Id, Requirement_Item__c> requirementItems = new Map<Id, Requirement_Item__c>(
            [
                    SELECT Id, Name, Requirement__c, Active__c, Instructions__c, Label__c, Required__c, Display_Order__c
                    FROM Requirement_Item__c
                    WHERE Requirement__c IN :requirements.keySet() AND Active__c = TRUE AND Display_on_Admin_Review_Pages__c = TRUE
                    ORDER BY Display_Order__c
            ]);
            Map<Id, Question__c> questions = new Map<Id, Question__c>([
                    SELECT Id, Name, Requirement_Item__c, Active__c, Additional_Field_Validation__c, Application_Field__c, Assistive_Text__c,
                            Dependency_Behavior__c, Dependency_Logic__c, Display_as_Picklist__c, Display_on_Admin_Review_Pages__c,
                            Display_Order__c, Help_Text__c, Label__c, Static_Text__c
                    FROM Question__c
                    WHERE Requirement_Item__c IN :requirementItems.keySet() AND Display_on_Admin_Review_Pages__c = TRUE AND Active__c = TRUE
                    ORDER BY Display_Order__c
            ]);
            Map<Id, Requirement_Response__c> requirementResponses = new Map<Id, Requirement_Response__c>([
                    SELECT Id, Name, Requirement_Item__c, Viewed__c, Status__c, ValueTextEntry__c, Has_Child_Requirement__c,
                            HasDocument__c, Related_Record__c
                    FROM Requirement_Response__c
                    WHERE Requirement_Item__c IN :requirementItems.keySet()
            ]);
            Map<Id, Question_Response__c> questionResponses = new Map<Id, Question_Response__c>([
                    SELECT Id, Name, Question_Label__c, IsShown__c, IsComplete__c, IsPopulated__c, IsRequired__c, Application__c,
                            Requirement_Response__r.Requirement_Item__c, Question__c, ValueText__c, ValueCheckbox__c,
                            ValueCurrency__c, ValueDate__c, ValueDateTime__c, ValueEmail__c, ValueLongTextArea__c,
                            ValueNumber__c, ValuePercent__c, ValuePhone__c, ValueTextArea__c, ValueTextEncrypted__c,
                            ValueURL__c, Street__c, State__c, City__c, PostalCode__c, Country__c
                    FROM Question_Response__c
                    WHERE Requirement_Response__r.Requirement_Item__c IN :requirementItems.keySet()
            ]);

            Map<Id, Question_Response__c> questionResponsesByQuestionId = new Map<Id, Question_Response__c>();
            for (Question_Response__c qr : questionResponses.values()) {
                questionResponsesByQuestionId.put(qr.Question__c, qr);
            }

            //Now process dependencies across the entire application
            //Question dependencies have 4 record types: Picklist, Checkbox, Multi-select picklist, and Radio
            List<Question_Dependency__c> questionDependencies = [
                    SELECT Id, Name, Question__c, Controlling_Question__c, ValueCheckbox__c, Value__c, RecordType.Name
                    FROM Question_Dependency__c
                    WHERE Question__c IN :questions.keySet()
            ];

            Map<Id, Question_Dependency__c> questionDependenciesByQuestionId = new Map<Id, Question_Dependency__c>();
            for (Question_Dependency__c qd : questionDependencies) {
                questionDependenciesByQuestionId.put(qd.Question__c, qd);
            }

            appWrapper.requirements = buildRequirements(requirements, requirementItems, questions, requirementResponses, questionResponses, questionResponsesByQuestionId, questionDependenciesByQuestionId);

        }
        return appWrapper;
    }

    private static List<EASYAppRequirementWrapper> buildRequirements(Map<Id, Requirement__c> requirements, Map<Id, Requirement_Item__c> requirementItems, Map<Id, Question__c> questions, Map<Id, Requirement_Response__c> requirementResponses, Map<Id, Question_Response__c> questionResponses, Map<Id, Question_Response__c> questionResponsesByQuestionId, Map<Id, Question_Dependency__c> questionDependenciesByQuestionId) {
        List<EASYAppRequirementWrapper> reqWrapperList = new List<EASYAppRequirementWrapper>();
        for (Id reqKey : requirements.keySet()) {
            EASYAppRequirementWrapper reqWrapper = new EASYAppRequirementWrapper();
            reqWrapper.requirement = requirements.get(reqKey);
            reqWrapper.requirementItems = buildRequirementItems(reqKey, requirementItems, questions, requirementResponses, questionResponses, questionResponsesByQuestionId, questionDependenciesByQuestionId);
            reqWrapperList.add(reqWrapper);
        }
        return reqWrapperList;
    }

    private static List<EASYAppRequirementItemWrapper> buildRequirementItems(Id reqKey, Map<Id, Requirement_Item__c> requirementItems, Map<Id, Question__c> questions, Map<Id, Requirement_Response__c> requirementResponses, Map<Id, Question_Response__c> questionResponses, Map<Id, Question_Response__c> questionResponsesByQuestionId, Map<Id, Question_Dependency__c> questionDependenciesByQuestionId) {
        List<EASYAppRequirementItemWrapper> requirementItemsList = new List<EASYAppRequirementItemWrapper>();
        for (Requirement_Item__c ri : requirementItems.values()) {
            if (ri.Requirement__c == reqKey) {
                EASYAppRequirementItemWrapper newRIWrap = new EASYAppRequirementItemWrapper();
                newRIWrap.requirementItem = ri;
                newRIWrap.questions = buildQuestions(ri.Id, questions, questionResponses, questionResponsesByQuestionId, questionDependenciesByQuestionId);
                newRIWrap.requirementResponse = buildRequirementResponses(ri.Id, requirementResponses);
                requirementItemsList.add(newRIWrap);
            }
        }
        return requirementItemsList;
    }

    private static List<EASYAppQuestionResponseWrapper> buildQuestions(Id reqItemId, Map<Id, Question__c> questions, Map<Id, Question_Response__c> questionResponses, Map<Id, Question_Response__c> questionResponsesByQuestionId, Map<Id, Question_Dependency__c> questionDependenciesByQuestionId) {
        List<EASYAppQuestionResponseWrapper> questionsList = new List<EASYAppQuestionResponseWrapper>();
        for (Question__c q : questions.values()) {
            if (q.Requirement_Item__c == reqItemId) {
                //Evaluate if question dependencies are met
                EASYAppQuestionResponseWrapper qrWrapper = new EASYAppQuestionResponseWrapper();
                qrWrapper.question = q;
                qrWrapper.questionResponses = buildQuestionResponses(q.Id, questionResponses);
                qrWrapper.dependencies_met = true;
                if (questionDependenciesByQuestionId.containsKey(q.Id)) {
                    Question_Dependency__c qd = questionDependenciesByQuestionId.get(q.Id);
                    if (questionResponsesByQuestionId.get(qd.Controlling_Question__c) == null) {
                        qrWrapper.dependencies_met = false;
                    } else if (qd.RecordType.Name == 'Picklist') {
                        if (qd.Value__c != questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueText__c) {
                            qrWrapper.dependencies_met = false;
                        }
                    } else if (qd.RecordType.Name == 'Checkbox') {
                        if (Boolean.valueOf(qd.ValueCheckbox__c) != questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueCheckbox__c) {
                            qrWrapper.dependencies_met = false;
                        }
                    } else if (qd.RecordType.Name == 'Multi-select picklist') {
//                        if (!questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueText__c.contains(qd.Value__c)) {
//                            qrWrapper.dependenciesMet = false;
//                        }
                    } else if (qd.RecordType.Name == 'Radio') {
                        if (qd.Value__c != questionResponsesByQuestionId.get(qd.Controlling_Question__c).ValueText__c) {
                            qrWrapper.dependencies_met = false;
                        }
                    }
                }
                questionsList.add(qrWrapper);
            }
        }
        return questionsList;
    }

    private static List<Requirement_Response__c> buildRequirementResponses(Id reqItemId, Map<Id, Requirement_Response__c> requirementResponses) {
        List<Requirement_Response__c> requirementResponsesList = new List<Requirement_Response__c>();
        for (Requirement_Response__c r : requirementResponses.values()) {
            if (r.Requirement_Item__c == reqItemId) {
                requirementResponsesList.add(r);
            }
        }
        return requirementResponsesList;
    }

    private static List<Question_Response__c> buildQuestionResponses(Id questionId, Map<Id, Question_Response__c> questionResponses) {
        List<Question_Response__c> questionResponsesList = new List<Question_Response__c>();
        for (Question_Response__c qr : questionResponses.values()) {
            if (qr.Question__c == questionId) {
                questionResponsesList.add(qr);
            }
        }
        return questionResponsesList;
    }
}