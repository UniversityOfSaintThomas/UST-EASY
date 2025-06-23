/**
 * Created by nguy0092 on 2/26/2024.
 */
@SuppressWarnings('InconsistentSalesforceApiVersion')
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

        Program__c testMajor = new Program__c(Name = 'Biology', Major_Code__c = 'BIOL');
        insert testMajor;

        Program__c testCpfMajor = new Program__c(Name = 'Nursing', Major_Code__c = 'NRSG');
        insert testCpfMajor;

        RecordType scholarshipRecordType = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Scholarship__c'
                AND DeveloperName = 'Scholarship'
        ];

        Scholarship__c scholarship = new Scholarship__c(RecordTypeId = scholarshipRecordType.Id, Name = 'Test Scholarship');
        insert scholarship;

        summit__Summit_Events__c event = new summit__Summit_Events__c(Name = '2099 First Year Orientation',
                summit__Event_Name__c = '2099 First Year Orientation',
                summit__Template__c = 'GeneralSLDS',
                O_R_SGA_Term__c = testTerm.Id,
                O_R_SGA_Scholarship__c = scholarship.Id);
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

        List<String> hostCourseName = new List<String>{
                'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S'
        };

        List<summit__Summit_Events_Host__c> listHost = new List<summit__Summit_Events_Host__c>();

        for (String h : hostCourseName) {

            summit__Summit_Events_Host__c templateHost = new summit__Summit_Events_Host__c();
            templateHost.summit__Course_Name__c = h;
            templateHost.summit__Preferred_Title__c = h;
            templateHost.summit__Assigned__c = 0;
            templateHost.summit__Event_Instance__c = eventInstance.Id;

            switch on h {
                when 'A' {
                    templateHost.O_R_Advisor_Core_Major__c = 'ATHLETE';
                }
                when 'B', 'C', 'E', 'F', 'H', 'I' {
                    templateHost.O_R_Advisor_Additional_Majors__c = 'ALL';
                }
                when 'D' {
                    templateHost.O_R_Advisor_Secondary_Major__c = 'NRSG';
                    templateHost.O_R_Advisor_Additional_Majors__c = 'ALL';
                }
                when 'G' {
                    templateHost.O_R_Advisor_Core_Major__c = 'MUSC;MUBA;MUPE;MEIN;MEVO';
                    templateHost.O_R_Advisor_Additional_Majors__c = 'ALL';
                }
                when 'J' {
                    templateHost.O_R_Advisor_Core_Major__c = 'XCHR;XDEN;XMED;XOCT;XOPT;XPHA;XPPT;XPPA;XVET;PUBH';
                    templateHost.O_R_Advisor_Secondary_Major__c = 'BCH1;BIOL;BOGH;CHEM;ESCI;EXSC;GEOL;PEH1;NSCI;ENVR';
                }
                when 'K' {
                    templateHost.O_R_Advisor_Core_Major__c = 'CENG;COEN;EEE1;EGM1';
                    templateHost.O_R_Advisor_Secondary_Major__c = 'ACSC;CSBS;BSDA;MATH;PHYS;STAT;DSCI';
                }
                when 'L' {
                    templateHost.O_R_Advisor_Core_Major__c = 'NSCI;PSYC';
                    templateHost.O_R_Advisor_Secondary_Major__c = 'BCH1;BIOL;BOGH;CHEM;ESCI;EXSC;GEOL;PEH1;ENVR;XCHR;XDEN;XMED;XOCT;XOPT;XPHA;XPPT;XPPA;XVET;PUBH';
                }
                when 'M' {
                    templateHost.O_R_Advisor_Core_Major__c = 'NRSG';
                    templateHost.O_R_Advisor_Secondary_Major__c = 'XCHR;XDEN;XMED;XOCT;XOPT;XPHA;XPPT;XPPA;XVET;PUBH';
                }
                when 'N', 'O' {
                    templateHost.O_R_Advisor_Core_Major__c = 'BUGB;BURE;ECON;BSAC;BSBC;BSEN;BSFI;BSHR;BSIB;BSLC;BSLM;BSMK;BSOM';
                }
                when 'P', 'Q' {
                    templateHost.O_R_Advisor_Core_Major__c = 'ARTH;CATH;CLAC;CLAL;COMM;SOCJ;DMAT;ENGL;ENPW;ENWR;FAST;FILM;FREN;GGIS;GEOG;GERM;HIST;INTS;JOUR;JPST;PHIL;POLS;XLAW;PSYC;SOWK;SOCI;SPAN;STCM;THEO;UNDC;WGSS;ELEM;ESME;MSED';
                }
                when 'R' {
                    templateHost.O_R_Advisor_Core_Major__c = 'SCHOLARSHIP';
                    templateHost.O_R_Advisor_Additional_Majors__c = 'ALL';
                }
                when 'S' {
                    templateHost.O_R_Advisor_Core_Major__c = 'OVERFLOW';
                    templateHost.O_R_Advisor_Additional_Majors__c = 'ALL';
                }
            }
            listHost.add(templateHost);
        }
        insert listHost;

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
        List<Application__c> listApplication = new List<Application__c>();
        List<Scholarship_Applicant__c> listScholarshipApplicants = new List<Scholarship_Applicant__c>();
        Integer toggleApplicationEthnicity = 1;
        Integer ToggleApplicationMajors = 1;
        Integer toggleFirstGeneration = 1;
        Integer toggleScholarshipApplicant = 1;

        for (Contact c : contacts) {

            summit__Summit_Events_Registration__c newRegistration = new summit__Summit_Events_Registration__c();
            newRegistration.summit__Contact__c = c.Id;
            newRegistration.summit__Event__c = event.Id;
            newRegistration.summit__Event_Instance__c = eventInstance.Id;
            newRegistration.summit__Status__c = 'Confirmed';
            newRegistration.summit__Guest_Host_Status__c = '';
            listRegistration.add(newRegistration);

            Application__c newApplication = new Application__c();
            newApplication.Contact__c = c.Id;
            newApplication.Application_Status__c = 'Confirmed';
            newApplication.Primary_High_School_Account__c = testAccount.Id;
            if (toggleApplicationEthnicity > 0 && toggleApplicationEthnicity <= 5) {

                newApplication.Ethnicity__c = 'Asian';
                toggleApplicationEthnicity++;
            }
            if (toggleApplicationEthnicity > 5 && toggleApplicationEthnicity <= 10) {

                newApplication.First_Generation__c = 'Yes, I am';
                toggleFirstGeneration++;
            }
            if (ToggleApplicationMajors > 25 && ToggleApplicationMajors <= 40) {

                newApplication.Major_1__c = testMajor.Id;
                newApplication.CPF_Major__c = testCpfMajor.Id;
            }
            listApplication.add(newApplication);

            if (toggleScholarshipApplicant > 10 && toggleScholarshipApplicant <= 15) {
                Scholarship_Applicant__c applicant = new Scholarship_Applicant__c(Contact__c = c.Id, Scholarship__c = scholarship.Id, Scholarship_Status__c = 'Accepted');
                listScholarshipApplicants.add(applicant);
                toggleScholarshipApplicant++;
            }
        }
        insert listRegistration;
        insert listApplication;
        insert listScholarshipApplicants;

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
                        summit__Event__r.O_R_SGA_Term__c,
                        summit__Event__r.O_R_SGA_Scholarship__c
                FROM summit__Summit_Events_Instance__c
                WHERE summit__Event__r.summit__Event_Name__c = '2099 First Year Orientation'
                LIMIT 1
        ];

        String eventInstanceId = eventInstance.Id;
        String registrationTerm = eventInstance.summit__Event__r.O_R_SGA_Term__c;
        String scholarshipId = eventInstance.summit__Event__r.O_R_SGA_Scholarship__c;

        ORSmallGroupAssignment.eventRegistrationCriteria(eventInstanceId, scholarshipId, registrationTerm);
        ORSmallGroupAssignment.assignAppointmentTypes(eventInstanceId);
        ORSmallGroupAssignment.recordAppointmentAssignment(eventInstanceId);
        ORSmallGroupAssignment.appointmentDataDisplay(eventInstanceId);
        ORRegistrationAdvisorAssignment.assignAppointmentHost(eventInstanceId);

        summit__Summit_Events_Appointment_Type__c appointmentType = [
                SELECT Id
                FROM summit__Summit_Events_Appointment_Type__c
                WHERE summit__Restrict_To_Instance_Title__c = :eventInstanceId
                LIMIT 1
        ];

        String appointmentTypeId = appointmentType.Id;
        ORRegistrationAdvisorAssignment.hostAssignDataDisplay(appointmentTypeId);

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