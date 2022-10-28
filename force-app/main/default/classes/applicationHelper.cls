/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 5/1/2022.
 */


public with sharing class applicationHelper {

    public static List<Requirement_Item__c> getRequirementQuestions(Set<Id> requirementIds, Boolean IsStandardUser) {

        List<Requirement_Item__c> requirementItems = new List<Requirement_Item__c>();
        requirementItems = [
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
                                Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, RecordType.Name, Assistive_Text__c, Related_Object__c, Additional_Field_Validation__c,
                                Payment_Custom_Amount__c, Payment_Gateway__c, Payment_Type__c, Payment_Name__c
                        FROM Questions__r
                        WHERE Active__c = TRUE
                        ORDER BY Display_Order__c ASC NULLS LAST
                )
                FROM Requirement_Item__c
                WHERE Requirement__c IN :requirementIds
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

                //TODO: Figure out how to get this into the plain query rather than have to build a string query
                /*
                    if (isExternalUser) {
                        itemQuery += ' AND Internal_Requirement_Item__c=\'' + appInfo.requirementId + '\'';
                    }
                */
                ORDER BY Display_Order__c ASC NULLS LAST
        ];
        return requirementItems;
    }

    public static List<Requirement_Response__c> getRequirementResponses(Set<Id> requirementIds, Id ApplicationId) {
        List<Requirement_Response__c> requirementResponses = new List<Requirement_Response__c>();
        requirementResponses = [
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
                AND Application__c = :ApplicationId
        ];
        return requirementResponses;
    }


    public static Set<String> getStandardAppFields() {
        return new Set<String>{
                'id', 'intended_program__c', 'applicant_type__c', 'citizenship__c', 'delivery_type__c', 'student_type__c', 'contact__c',
                'school_college__c', 'residency__c', 'degree_type__c', 'application_status__c', 'Application_Substatus__c', 'application_control__c',
                'generic_filter_1__c', 'generic_filter_2__c', 'generic_filter_3__c', 'generic_filter_4__c', 'Intended_Program__r.Name',
                'Intended_Program__r.Program_Name_on_Application__c', 'Intended_Term_of_Entry__r.Name',
                'Intended_Term_of_Entry__r.Term_Status_Type__c'
        };
    }

    public static String getAllItemApplicationFieldsByAppControlId(List<Id> appControlIds) {

        List<String> appControlIds15 = new List<String>();
        String fields = '';
        Set<String> appFields = getStandardAppFields();

        for (Id a : appControlIds) {
            appControlIds15.add(a.to15());
        }

        List<Question__c> questions = [
                SELECT Id, Application_Control_Id__c, Application_Field__c
                FROM Question__c
                WHERE Application_Control_Id__c IN :appControlIds15
                AND Application_Field__c != NULL
        ];

        for (Question__c q : questions) {
            if (String.isNotBlank(q.Application_Field__c)) {
                appFields.add(q.Application_Field__c.toLowerCase());
            }
        }

        fields = String.join(new List<String>(appFields), ',');

        return fields;
    }

    public static String getApplicationFields(List<Requirement_Item__c> items) {
        String fields;
        Set<String> appFields = getStandardAppFields();
        for (Requirement_Item__c ri : items) {
            for (Question__c q : ri.Questions__r) {
                if (String.isNotBlank(q.Application_Field__c)) {
                    appFields.add(q.Application_Field__c.toLowerCase());
                }
            }
        }
        fields = String.join(new List<String>(appFields), ',');
        return fields;
    }


    public static String getApplicationContactFields(List<Requirement_Item__c> items) {
        String fields = '';
        Set<String> contactFields = new Set<String>{
                'id', 'mailingstreet', 'mailingcity', 'mailingpostalcode', 'otherstreet', 'othercity', 'otherpostalcode'
        };
        if (Account.SObjectType.getDescribe().fields.getMap().containsKey('BillingCountryCode')) {
            contactFields.addAll(new Set<String>{
                    'mailingstatecode', 'mailingcountrycode', 'otherstatecode', 'othercountrycode'
            });
        } else {
            contactFields.addAll(new Set<String>{
                    'mailingstate', 'mailingcountry', 'otherstate', 'othercountry'
            });
        }
        for (Requirement_Item__c ri : items) {
            for (Question__c q : ri.Questions__r) {
                if (String.isNotBlank(q.Contact_Field__c)) {
                    contactFields.add(q.Contact_Field__c.toLowerCase());
                }
            }
        }
        fields = String.join(new List<String>(contactFields), ',');
        return fields;
    }

}