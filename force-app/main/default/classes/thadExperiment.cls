/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/14/2022.
 */


public with sharing class thadExperiment {
    public Application__c application { get; set; }
    public Application_Control__c applicationControl { get; set; }
    public Map<Id, Requirement__c> requirements { get; set; }
    public List<Requirement_Item__c> requirementItems { get; set; }
    public Map<Id, Question__c> questions { get; set; }
    public List<Question_Dependency__c> questionDependencies { get; set; }
    public List<Question_Response__c> questionResponses { get; set; }
    public List<Requirement_Response__c> requirementResponses { get; set; }
    public String JSONObjects { get; set; }
    public Id applicationId { get; set; }

    public thadExperiment() {
        JSONObjects = '';


        //Get application Id from URL
        applicationId = ApexPages.currentPage().getParameters().get('applicationId');

        //Get Application

        application = [
                SELECT Id, Contact__c, Intended_Program__r.Program_Name_on_Application__c, Intended_Program__r.Name, Intended_Term_of_Entry__r.Name,
                        Intended_Term_of_Entry__r.Term_Start_Date__c, Intended_Program__c, Applicant_Type__c, Citizenship__c, Delivery_Type__c,
                        Student_Type__c, Residency__c, Application_Status__c, School_College__c, Degree_Type__c, Application_Control__c, Generic_Filter_1__c,
                        Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c
                FROM Application__c
                WHERE Id = :applicationId
        ];
        JSONObjects += '\n\nApplication:\n' + JSON.serializePretty(application);

        //Get Application control
        applicationControl = [
                SELECT Id, Hide_Term_Program__c, Application_Start_Status__c,
                        Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c, Arrow_Color__c, Button_Color__c, Button_Text_Color__c,
                        Cancel_Status__c, Line_Color__c, Link_Color__c, Logo_Static_Resource__c, Logo_Static_Resource_Path__c,
                        Submit_Status__c, Withdraw_Status__c, Text_Color__c, URL_Parameter__c, Default__c, Academic_Level__c, School_College__c, Degree_Levels__c,
                        Template__c
                FROM Application_Control__c
                WHERE Id = :application.Application_Control__c
        ];

        JSONObjects += '\n\n\n\nApplication Control:\n' + JSON.serializePretty(applicationControl);


        //Get Requirements
        requirements = new Map<Id, Requirement__c>([
                SELECT Id, Internal_Only__c, Name, Active__c, Intended_Program__c, Application_Status__c, Applicant_Type__c, Citizenship__c, Degree_Type__c, Delivery_Type__c, Residency__c, School_College__c, Student_Type__c, Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c
                FROM Requirement__c
                WHERE Application_Control__c = :applicationControl.Id
                AND Active__c = TRUE
                AND Show_on_Application_Creation__c = FALSE
                ORDER BY Display_Order__c, Label__c ASC NULLS LAST
        ]);

        JSONObjects += '\n\n\n\nRequirements:\n' + JSON.serializePretty(requirements);

        //Get Requirement Items
        String userType = String.valueOf(UserInfo.getUserType());
        Boolean isStandardUser = userType.equalsIgnoreCase('standard');
        requirementItems = [
                SELECT Id, File_Types__c, Internal_Only__c, Requirement__r.Internal_Only__c, Internal_Only_Applicant_Instructions__c, Active__c, Required__c,
                        Required_Number_of_Children__c, Maximum_Number_of_Children__c, Requirement__r.Name, Requirement__r.Label__c, Name, Label__c, Instructions__c, Intended_Program__c,
                        Application_Status__c, Applicant_Type__c, Citizenship__c, Degree_Type__c, Delivery_Type__c, Residency__c, School_College__c, Student_Type__c, RecordType.DeveloperName,
                        Allow_Text_Entry__c, Related_List_Object__c, Related_List_Object_Master__c, Related_List_Object_Master_Field__c, Related_List_Where_Clause__c, Related_Object_Record_Type_ID__c,
                        Internal_Requirement_Item__c, Editable_Application_Status__c, Holding_Record_Id__c, Allow_Supporting_Documentation_Upload__c, Required_Supporting_Documentation__c,
                        Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, Internal_Only_Show_on_Checklist__c, (
                        SELECT Id, Active__c, Required__c, Label__c, Intended_Program__c, Application_Status__c,
                                Applicant_Type__c, Citizenship__c, Degree_Type__c, Delivery_Type__c, Residency__c, School_College__c, Student_Type__c, RecordType.DeveloperName, Picklist_Values__c, Placeholder__c,
                                Length__c, Help_Text__c, Dependency_Logic__c, Dependency_Behavior__c, Related_Object_Field__c, Lookup_Object__c, Lookup_Where_Clause__c, Name_Field_API_Name__c, Contact_Field__c,
                                Application_Field__c, External_Email_Field__c, Hardcoded_Value__c, Editable_Application_Status__c, URL_Parameter__c, New_Reference_Field__c, Static_Text__c, Display_as_Picklist__c,
                                Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c
                        FROM Questions__r
                        WHERE Active__c = TRUE
                        ORDER BY Display_Order__c ASC NULLS LAST
                )
                FROM Requirement_Item__c
                WHERE Requirement__c IN :requirements.keySet()
                AND Requirement__r.Show_on_Application_Creation__c = FALSE
                AND Requirement__r.Active__c = TRUE
                AND Active__c = TRUE
                //If not standard user
                AND (
                        (Internal_Only__c = :isStandardUser AND Requirement__r.Internal_Only__c = :isStandardUser)
                        OR (
                                Internal_Only_Show_on_Checklist__c = :!isStandardUser AND Requirement__r.Internal_Only_Show_on_Checklist__c = :!isStandardUser
                        )
                )
                ORDER BY Display_Order__c ASC NULLS LAST
        ];

        JSONObjects += '\n\n\n\nRequirement Items:\n' + JSON.serializePretty(requirementItems);


        //Get Questions
        questions = new Map<Id, Question__c>([
                SELECT Id, Lookup_Object__c, Related_Object_Field__c, Requirement_Item__c, Requirement_Item__r.Related_List_Object__c, RecordType.DeveloperName,
                        New_Reference_Field__c, Static_Text__c
                FROM Question__c
                WHERE (Lookup_Object__c != NULL OR New_Reference_Field__c = TRUE)
                AND Active__c = TRUE AND Requirement_Item__r.Active__c = TRUE
                AND Requirement_Item__r.Requirement__r.Active__c = TRUE
                AND Requirement_Item__r.Requirement__r.Application_Control__c = :applicationControl.Id
                ORDER BY New_Reference_Field__c, Display_Order__c ASC NULLS LAST
        ]);

        JSONObjects += '\n\n\n\nQuestions:\n' + JSON.serializePretty(questions);


        //Get Question Dependencies
        questionDependencies = [
                SELECT Id, Question__c, Question__r.Required__c, Question__r.Requirement_Item__c, Question__r.Requirement_Item__r.Requirement__c,
                        Controlling_Question__c, Controlling_Question__r.Requirement_Item__r.Requirement__c, Value__c, ValueCheckbox__c, RecordType.DeveloperName
                FROM Question_Dependency__c
                WHERE Question__r.Requirement_Item__r.Requirement__c IN :requirements.keySet()
        ];

        JSONObjects += '\n\n\n\nQuestion dependencies:\n' + JSON.serializePretty(questionDependencies);


        //Get Question Responses
        questionResponses = [
                SELECT Id, IsPopulated__c, PopulatedOn__c, Question__c, Question__r.Required__c, ValueText__c, ValueCheckbox__c, ValuePhone__c,
                        ValueEmail__c, ValueCurrency__c, ValueDate__c, ValueDateTime__c, ValueNumber__c, ValuePercent__c, ValueTextArea__c,
                        ValueTextEncrypted__c, ValueLongTextArea__c, ValueURL__c, Street__c, City__c, State__c, Country__c, PostalCode__c,
                        Requirement_Response__c, Requirement_Response__r.Has_Child_Requirement__c, Application__c
                FROM Question_Response__c
                WHERE Requirement_Response__r.Application__c = :applicationId
//                        AND Question__c IN :questions.keySet()
//                AND Requirement_Response__r.Application__c = :applicationId
        ];

        JSONObjects += '\n\n\n\nQuestion responses:\n' + JSON.serializePretty(questionResponses);

        //Get Requirement Response
        requirementResponses = [
                SELECT Id, Requirement_Item__c, Requirement_Item__r.Internal_Only__c, ValueTextEntry__c, Fulfilled_On__c, Incomplete_Questions__c,
                        Question_Group_Requirement_Fulfilled_On__c, HasDocument__c, Waive_Requirement__c, Document_Requirement_Fulfilled_On__c,
                        Has_Child_Requirement__c, Child_Requirement_Fulfilled_On__c, Application__c, Application__r.Contact__c, External_Email__c,
                        Hashcode__c, Send_Reminder__c, (
                        SELECT Id, IsPopulated__c, PopulatedOn__c, Question__c, Question__r.Required__c,
                                ValueText__c, ValueCheckbox__c, ValuePhone__c, ValueEmail__c, ValueCurrency__c, ValueDate__c,
                                ValueDateTime__c, ValueNumber__c, ValuePercent__c, ValueTextArea__c, ValueTextEncrypted__c, ValueLongTextArea__c,
                                ValueURL__c, Street__c, City__c, State__c, Country__c, PostalCode__c, Requirement_Response__c,
                                Requirement_Response__r.Has_Child_Requirement__c
                        FROM Question_Responses__r
                ), (
                        SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title
                        FROM ContentDocumentLinks
                )
                FROM Requirement_Response__c
                WHERE Requirement_Item__r.Requirement__c IN :requirements.keySet()
                AND Application__c = :applicationId
        ];

        JSONObjects += '\n\n\n\nRequirement responses:\n' + JSON.serializePretty(requirementResponses);


    }

}