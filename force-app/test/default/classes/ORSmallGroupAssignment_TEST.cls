/**
 * Created by nguy0092 on 2/26/2024.
 */
@IsTest
public with sharing class ORSmallGroupAssignment_TEST {

    @TestSetup
    static void dataSetup() {

        Account testAccount = new Account (Name = 'Test Account');

        insert testAccount;

        hed__Term__c testTerm = new hed__Term__c(Name = 'Fall 2023', hed__Account__c = testAccount.Id);

        insert testTerm;

        Program__c testProgram = new Program__c(Name = 'Undergraduate First-Year', Admit_Type__c = 'First-Year');

        insert testProgram;

        summit__Summit_Events__c event = new summit__Summit_Events__c(Name = '2099 First Year Orientation',
                summit__Event_Name__c = '2099 First Year Orientation',
                summit__Template__c = 'GeneralSLDS',
                O_R_SGA_Term__c = testTerm.Id);

        insert event;

        Date instanceDate = Date.parse('01/01/2099');
        String dateString = instanceDate.format();
        Time instanceStart = Time.newInstance(8, 30, 0, 0);
        Time instanceEnd = Time.newInstance(12, 30, 0, 0);

        summit__Summit_Events_Instance__c eventInstance = new summit__Summit_Events_Instance__c(
                summit__Instance_Title__c = 'Online Session 1 ' + dateString,
                summit__Instance_Short_Description__c = 'OR1001',
                summit__Event__c = event.Id,
                summit__Instance_Start_Date__c = instanceDate,
                summit__Instance_Start_Time__c = instanceStart,
                summit__Instance_End_Date__c = instanceDate,
                summit__Instance_End_Time__c = instanceEnd,
                summit__Capacity__c = 155,
                summit__Active_Status__c = 'Active'
        );

        insert eventInstance;

        List<summit__Summit_Events_Appointment_Type__c> appointmentTypeList = new List<summit__Summit_Events_Appointment_Type__c>();

        for (Integer i = 1; i < 13; i++) {

            summit__Summit_Events_Appointment_Type__c appointmentType = new summit__Summit_Events_Appointment_Type__c();

            appointmentType.summit__Summit_Events__c = event.Id;
            appointmentType.summit__Restrict_To_Instance_Title__c = eventInstance.Id;
            appointmentType.summit__Appointment_Type_Status__c = 'Active';
            appointmentType.summit__Title__c = String.valueOf(i);
            appointmentType.summit__Sort_Order__c = i;

            appointmentTypeList.add(appointmentType);
        }

        insert appointmentTypeList;

        List<Contact> listContact = new List<Contact>();

        for (Integer i = 1; i <= 20; i++) {

            Contact newContact1 = new Contact(FirstName = 'Hello' + i + 'A', LastName = 'TestWorld', hed__Gender__c = 'Female');
            Contact newContact2 = new Contact(FirstName = 'Hello' + i + 'B', LastName = 'TestWorld', hed__Gender__c = 'Male');

            if (Math.mod(i, 2) == 0) {

                newContact1.MailingState = 'MN';
                newContact2.MailingState = 'MN';
            } else {

                newContact1.MailingState = 'WI';
                newContact2.MailingState = 'WI';
            }

            listContact.add(newContact1);
            listContact.add(newContact2);
        }

        insert listContact;

        List<Contact> contacts = [
                SELECT Id
                FROM Contact
                WHERE LastName = 'TestWorld'
        ];

        List<summit__Summit_Events_Registration__c> listRegistration = new List<summit__Summit_Events_Registration__c>();

        for (Contact c : contacts) {

            summit__Summit_Events_Registration__c newRegistration = new summit__Summit_Events_Registration__c();

            newRegistration.summit__Contact__c = c.Id;
            newRegistration.summit__Event__c = event.Id;
            newRegistration.summit__Event_Instance__c = eventInstance.Id;
            newRegistration.summit__Status__c = 'Confirmed';
            newRegistration.summit__Guest_Host_Status__c = '';

            listRegistration.add(newRegistration);
        }

        insert listRegistration;

        List<Application__c> listApplication = new List<Application__c>();

        Integer toggleApplication = 1;

        for (Contact c : contacts) {

            Application__c newApplication = new Application__c();

            newApplication.Contact__c = c.Id;
            newApplication.Application_Status__c = 'Confirmed';
            newApplication.Primary_High_School_Account__c = testAccount.Id;

            if (toggleApplication > 0 && toggleApplication <= 5) {

                newApplication.Ethnicity__c = 'Asian';
            }

            listApplication.add(newApplication);

            toggleApplication++;
        }

        insert listApplication;

        List<Application__c> applications = [
                SELECT Id,
                        Contact__c
                FROM Application__c
                WHERE Contact__r.LastName = 'TestWorld'
        ];

        List<Opportunity> listOpportunity = new List<Opportunity>();
        Date stageDate = Date.parse('12/01/2099');
        Integer toggleOpportunity = 1;

        for (Application__c a : applications) {

            Opportunity newOpportunity = new Opportunity();

            newOpportunity.Contact__c = a.Contact__c;
            newOpportunity.Name = 'TEST|TEST|TEST';
            newOpportunity.StageName = 'Confirmed';
            newOpportunity.CloseDate = stageDate;
            newOpportunity.Admissions_Application__c = a.Id;
            newOpportunity.Term__c = testTerm.Id;
            newOpportunity.Academic_Program__c = testProgram.Id;

            if (toggleOpportunity > 10 && toggleOpportunity <= 15) {

                newOpportunity.Athlete_Sport_1__c = 'Women\'s Varsity Basketball';
            }

            if (toggleOpportunity > 20 && toggleOpportunity <= 25) {

                newOpportunity.Housing_Requirement_Exception_Request__c = 'Approved';
            }

            listOpportunity.add(newOpportunity);

            toggleOpportunity++;
        }

        insert listOpportunity;
    }

    @IsTest
    static void assignAppointments() {

        summit__Summit_Events_Instance__c eventInstance = [
                SELECT Id,
                        summit__Event__r.O_R_SGA_Term__c
                FROM summit__Summit_Events_Instance__c
                WHERE summit__Event__r.summit__Event_Name__c = '2099 First Year Orientation'
                LIMIT 1
        ];

        String eventInstanceId = eventInstance.Id;
        String registrationTerm = eventInstance.summit__Event__r.O_R_SGA_Term__c;

        ORSmallGroupAssignment.eventRegistrationCriteria(eventInstanceId, registrationTerm);
        ORSmallGroupAssignment.assignAppointmentTypes(eventInstanceId);
        ORSmallGroupAssignment.recordAppointmentAssignment(eventInstanceId);
        ORSmallGroupAssignment.appointmentDataDisplay(eventInstanceId);

        List<summit__Summit_Events_Registration__c> registrations = [
                SELECT Id
                FROM summit__Summit_Events_Registration__c
                WHERE summit__Event_Instance__c = :eventInstanceId
        ];

        List<String> registrationIds = new List<Id>();

        for (summit__Summit_Events_Registration__c r : registrations) {

            registrationIds.add(r.Id);
        }

        List<summit__Summit_Events_Appointments__c> appointments = [
                SELECT Id
                FROM summit__Summit_Events_Appointments__c
                WHERE summit__Event_Registration__c IN :registrationIds
        ];

        System.assertEquals(40, appointments.size(), 'Mis-match number of Appointments created!');
    }

}