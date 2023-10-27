/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/16/2023.
 */


public with sharing class appReviewController {

    @AuraEnabled(cacheable=true)
    public static Application__c getApplicantInfo(String appId) {
        return [
                SELECT Id, Name, Contact__r.FirstName, Contact__r.LastName
                FROM Application__c
                WHERE Id = :appId
                WITH USER_MODE
                LIMIT 1
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static EASYAppWrapper getApplicationControl(String appId) {

        EASYAppWrapper appWrapper = new EASYAppWrapper();
        Application_Control__c appControl = [
                SELECT Id, Name, Academic_Level__c, Active__c, Degree_Levels__c, School_College__c
                FROM Application_Control__c
                WHERE Id IN (SELECT Application_Control__c FROM Application__c WHERE Id = :appId)
                AND Active__c = TRUE
                WITH USER_MODE
                LIMIT 1
        ];
        appWrapper.appControl = appControl;
        appWrapper.requirements = new List<EASYAppRequirementWrapper>();

        if (appControl != null) {

            //Requirements
            Map<Id, Requirement__c> requirements = new Map<Id, Requirement__c>([
                    SELECT Id, Name, Active__c, Display_on_Admin_Review_Pages__c, Label__c, Display_Order__c
                    FROM Requirement__c
                    WHERE Application_Control__c = :appControl.Id
                    AND Active__c = TRUE
                    AND Display_on_Admin_Review_Pages__c = TRUE
                    ORDER BY Display_Order__c
            ]);

            //Requirement items
            Map<Id, Requirement_Item__c> requirementItems = new Map<Id, Requirement_Item__c>([
                    SELECT Id, Name, Requirement__c, Active__c, Instructions__c, Label__c, Required__c, Display_Order__c
                    FROM Requirement_Item__c
                    WHERE Requirement__c IN :requirements.keySet()
                    AND Active__c = TRUE
                    ORDER BY Display_Order__c
            ]);

            //Questions
            Map<Id, Question__c> questions = new Map<Id, Question__c>([
                    SELECT Id, Name, Requirement_Item__c, Active__c, Additional_Field_Validation__c, Application_Field__c, Assistive_Text__c, Dependency_Behavior__c,
                            Dependency_Logic__c, Display_as_Picklist__c, Display_on_Admin_Review_Pages__c, Display_Order__c, Help_Text__c, Label__c
                    FROM Question__c
                    WHERE Requirement_Item__c IN :requirementItems.keySet()
                    AND Display_on_Admin_Review_Pages__c = TRUE
                    AND Active__c = TRUE
                    ORDER By Display_Order__c
            ]);

            //Requirement Response
            Map<Id, Requirement_Response__c> requirementResponses = new Map<id, Requirement_Response__c>([
                    SELECT Id, Name, Requirement_Item__c, Viewed__c, Status__c, ValueTextEntry__c, Has_Child_Requirement__c, HasDocument__c, Related_Record__c
                    FROM Requirement_Response__c
                    WHERE Requirement_Item__c IN :requirementItems.keySet()
            ]);

            //Question Responses
            Map<Id, Question_Response__c> questionResponses = new Map<Id, Question_Response__c>([
                    SELECT Id, Name, Question_Label__c, IsShown__c, IsComplete__c, IsPopulated__c, IsRequired__c, Application__c,
                            Requirement_Response__r.Requirement_Item__c, Question__c, ValueText__c, ValueCheckbox__c,
                            ValueCurrency__c, ValueDate__c, ValueDateTime__c, ValueEmail__c, ValueLongTextArea__c, ValueNumber__c, ValuePercent__c,
                            ValuePhone__c, ValueTextArea__c, ValueTextEncrypted__c, ValueURL__c, Street__c, State__c
                    FROM Question_Response__c
                    WHERE Requirement_Response__r.Requirement_Item__c IN :requirementItems.keySet()
            ]);


            //Map the requirement item to its requirement
            Map<Id, List<Requirement_Item__c>> reqIdMapReqItem = new Map<Id, List<Requirement_Item__c>>();
            for (Id reqKey : requirementItems.keySet()) {
                if (reqIdMapReqItem.containsKey(requirementItems.get(reqKey).Requirement__c)) {
                    reqIdMapReqItem.get(requirementItems.get(reqKey).Requirement__c).add(requirementItems.get(reqKey));
                } else {
                    reqIdMapReqItem.put(requirementItems.get(reqKey).Requirement__c, new List<Requirement_Item__c>{
                            requirementItems.get(reqKey)
                    });
                }
            }

            //Map the requirement item to its requirement
            Map<Id, List<Question__c>> reqItemIdMapQuestion = new Map<Id, List<Question__c>>();
            for (Id qKey : questions.keySet()) {
                if (reqItemIdMapQuestion.containsKey(questions.get(qKey).Requirement_Item__c)) {
                    reqItemIdMapQuestion.get(questions.get(qKey).Requirement_Item__c).add(questions.get(qKey));
                } else {
                    reqItemIdMapQuestion.put(questions.get(qKey).Requirement_Item__c, new List<Question__c>{
                            questions.get(qKey)
                    });
                }
            }

            //Map requirement response to its requirement item
            Map<Id, List<Requirement_Response__c>> reqItemIdMapReqResponses = new Map<Id, List<Requirement_Response__c>>();
            for (id rrKey : requirementResponses.keySet()) {
                if (reqItemIdMapReqResponses.containsKey(requirementResponses.get(rrKey).Requirement_Item__c)) {
                    reqItemIdMapReqResponses.get(requirementResponses.get(rrKey).Requirement_Item__c).add(requirementResponses.get(rrKey));
                } else {
                    reqItemIdMapReqResponses.put(requirementResponses.get(rrKey).Requirement_Item__c, new List<Requirement_Response__c>{
                            requirementResponses.get(rrKey)
                    });
                }
            }

            //Map Question response to requirement item
            Map<Id, List<Question_Response__c>> reqItemIdMapQuestionResponses = new Map<Id, List<Question_Response__c>>();

            for (id qKey : questionResponses.keySet()) {
                Id reqItemId = questionResponses.get(qKey).Requirement_Response__r.Requirement_Item__c;
                if (reqItemIdMapQuestionResponses.containsKey(reqItemId)) {
                    reqItemIdMapQuestionResponses.get(reqItemId).add(questionResponses.get(qKey));
                } else {
                    reqItemIdMapQuestionResponses.put(reqItemId, new List<Question_Response__c>{
                            questionResponses.get(qKey)
                    });
                }
            }


            List<EASYAppRequirementWrapper> reqWrapperList = new List<EASYAppRequirementWrapper>();

            for (Id reqKey : requirements.keySet()) {
                EASYAppRequirementWrapper reqWrapper = new EASYAppRequirementWrapper();
                reqWrapper.requirement = requirements.get(reqKey);
                //get req items
                reqWrapper.requirementItems = new List<EASYAppRequirementItemWrapper>();

                //Check if the map of requirement items has the requirement Id
                if (reqIdMapReqItem.containsKey(reqKey)) {

                    //Get the requirement items
                    for (Requirement_Item__c ri : reqIdMapReqItem.get(reqKey)) {
                        EASYAppRequirementItemWrapper newRIWrap = new EASYAppRequirementItemWrapper();
                        newRIWrap.requirementItem = ri;
                        newRIWrap.questions = new List<EASYAppQuestionResponseWrapper>();
                        newRIWrap.requirementResponse = new List<Requirement_Response__c>();

                        //Get the questions
                        if (reqItemIdMapQuestion.containsKey(ri.Id)) {
                            for (Question__c q : reqItemIdMapQuestion.get(ri.Id)) {
                                EASYAppQuestionResponseWrapper qrWrapper = new EASYAppQuestionResponseWrapper();
                                qrWrapper.question = q;
                                //Add question responses if they exist
                                qrWrapper.questionResponses = new List<Question_Response__c>();
                                if (reqItemIdMapQuestionResponses.containsKey(ri.Id)) {
                                    for (Question_Response__c qr : reqItemIdMapQuestionResponses.get(ri.Id)) {
                                        if(qr.Question__c == q.Id) {
                                            qrWrapper.questionResponses.add(qr);
                                        }
                                    }
                                }
                                newRIWrap.questions.add(qrWrapper);
                            }
                        }

                        if (reqItemIdMapReqResponses.containsKey(ri.Id)) {
                            for (Requirement_Response__c r : reqItemIdMapReqResponses.get(ri.Id)) {
                                newRIWrap.requirementResponse.add(r);
                            }
                        }

                        reqWrapper.requirementItems.add(newRIWrap);
                    }
                }
                //get req items question
                reqWrapperList.add(reqWrapper);
            }
            appWrapper.requirements.addAll(reqWrapperList);


        }
        //System.debug(JSON.serializePretty(appWrapper));
        return appWrapper;
    }


}