/**
 * Created by nguy0092 on 1/19/2024.
 *
 * USAGE: Creates small groups (Summit Events Appointment records) based on criteria from Student Orientation and Registration (O&R).
 * Registrants for small groups are selected from Event Instances from the main O&R Event.
 *
 * Process flow is triggered by Lightning Web Component Assign Button on the Event Instance record:
 * 1.Queries registrants Contact/Opportunity/Admissions Application records to get base criteria information (First Gen students, Athlete, etc)
 * to update data fields on their registration record. [method eventRegistrationCriteria(String eventInstance)]
 * 2. Based on these data fields registrants are then put into criteria lists to be assigned Appointments [method assignAppointmentTypes(String eventInstance)]
 * 3. Assignment is done with method appointmentAssignment(List<summit__Summit_Events_Registration__c> registrantList, String assignmentType) passing in assignmentType as:
 *    -single - small group that is allowed to have just one student criteria in it.
 *    -pair - small group that must (if possible) have at least 2 or more students with the same criteria.
 * 4. Appointment assignment information is updated on registrant's registration record. [method recordAppointmentAssignment(String eventInstance)]
 *
 *
 * For LWC need to put @AuraEnabled(cacheable=false) on methods that have DML and call imperatively and not through @wire.
 */

public with sharing class ORSmallGroupAssignment {

    public static List<summit__Summit_Events_Appointments__c> appointmentsListInsert = new List<summit__Summit_Events_Appointments__c>();
    public static List<AppointmentTypeSort> appointmentTypeSortList = new List<AppointmentTypeSort>();

    public with sharing class AppointmentWrapper {
        @AuraEnabled
        public String Appointment_Status { get; set; }
        @AuraEnabled
        public String Appointment_Type_Id { get; set; }
        @AuraEnabled
        public String Appointment_Type_Name { get; set; }
        @AuraEnabled
        public String Instance_Id { get; set; }
        @AuraEnabled
        public String Registration_Id { get; set; }
        @AuraEnabled
        public String Registration_Name { get; set; }
        @AuraEnabled
        public String Contact_Id { get; set; }
        @AuraEnabled
        public String Contact_Name { get; set; }
//        @AuraEnabled
//        public Boolean Student_of_Color { get; set; }
        @AuraEnabled
        public Boolean First_Gen_Student { get; set; }
        @AuraEnabled
        public Boolean Athlete { get; set; }
        @AuraEnabled
        public Boolean Housing_Exception { get; set; }
        @AuraEnabled
        public Boolean Outside_of_Minnesota { get; set; }
        @AuraEnabled
        public String Gender { get; set; }
    }

    public with sharing class AppointmentDataDisplayWrapper {

        @AuraEnabled
        public String Appointment_Id { get; set; }
        @AuraEnabled
        public List<AppointmentWrapper> Appointment_Information { get; set; }
    }

    //Custom sort Class to sort the list of Appointment Types ASC by how many registrants are assigned.
    public class AppointmentTypeSort implements Comparable {
        public Id appointmentTypeId;
        public Integer appointmentTypeCount;

        public AppointmentTypeSort(Id id, Integer currentCount) {
            appointmentTypeId = id;
            appointmentTypeCount = currentCount;
        }

        public Integer compareTo(Object compareTo) {
            AppointmentTypeSort compareToAppointType = (AppointmentTypeSort)compareTo;
            if (appointmentTypeCount == compareToAppointType.appointmentTypeCount) return 0;
            if (appointmentTypeCount > compareToAppointType.appointmentTypeCount) return 1;
            return -1;
        }
    }

    //Custom sort Class to sort Summit Registrations by field names.
    public class SummitRegistrationSort implements Comparator<summit__Summit_Events_Registration__c> {
        String primaryField = '';
        String primaryNullDefault = '';

        String secondaryField = '';
        String secondaryNullDefault = '';

        public SummitRegistrationSort(String primaryFieldName, String primaryNullDefaultValue, String secondaryFieldName, String secondaryNullDefaultValue) {
            primaryField = primaryFieldName;
            primaryNullDefault = primaryNullDefaultValue;

            secondaryField = secondaryFieldName;
            secondaryNullDefault = secondaryNullDefaultValue;
        }

        public Integer compare(summit__Summit_Events_Registration__c r1, summit__Summit_Events_Registration__c r2) {
            String registration1_primaryFieldValue = primaryNullDefault;
            String registration1_secondaryFieldValue = secondaryNullDefault;

            String registration2_primaryFieldValue = primaryNullDefault;
            String registration2_secondaryFieldValue = secondaryNullDefault;

            if (String.isNotBlank(primaryField)) {
                registration1_primaryFieldValue = String.isBlank(r1.get(primaryField)?.toString()) ? primaryNullDefault : r1.get(primaryField).toString();
                registration2_primaryFieldValue = String.isBlank(r2.get(primaryField)?.toString()) ? primaryNullDefault : r2.get(primaryField).toString();
            } else {
                registration1_primaryFieldValue = primaryNullDefault;
                registration2_primaryFieldValue = secondaryNullDefault;
            }
            if(String.isNotBlank(secondaryField)) {
                registration1_secondaryFieldValue = String.isBlank(r1.get(secondaryField)?.toString()) ? secondaryNullDefault : r1.get(secondaryField).toString();
                registration2_secondaryFieldValue = String.isBlank(r2.get(secondaryField)?.toString()) ? secondaryNullDefault : r2.get(secondaryField).toString();
            } else {
                registration1_secondaryFieldValue = primaryNullDefault;
                registration2_secondaryFieldValue = secondaryNullDefault;
            }

            String registration1_combinedValue = registration1_primaryFieldValue+registration1_secondaryFieldValue;
            String registration2_combinedValue = registration2_primaryFieldValue+registration2_secondaryFieldValue;

            Integer returnValue = 0;

            if(r1 == null && r2 == null) {
                returnValue = 0;
            } else if(r1 == null) {
                returnValue = -1;
            } else if(r2 == null) {
                returnValue = 1;
            } else if ((registration1_combinedValue == null) && (registration2_combinedValue == null)) {
                returnValue = 0;
            } else if (registration1_combinedValue == null){
                returnValue = -1;
            } else if (registration2_combinedValue == null){
                returnValue = 1;
            } else if (registration1_combinedValue < registration2_combinedValue) {
                returnValue = -1;
            } else if (registration1_combinedValue > registration2_combinedValue) {
                returnValue = 1;
            }

            return returnValue;
        }
    }

    @AuraEnabled(Cacheable=false)
    public static void eventRegistrationCriteria(String eventInstance, String scholarshipId, String registrationTerm) {
        Map<Id, summit__Summit_Events_Registration__c> registrantInfo = new Map<Id, summit__Summit_Events_Registration__c>();
        Set<Id> contactId = new Set<Id>();

        List<summit__Summit_Events_Registration__c> registrations = [
                SELECT Id,
                        summit__Contact__c,
                        summit__Event_Instance__c
                FROM summit__Summit_Events_Registration__c
                WHERE summit__Status__c IN ('Registered', 'Confirmed', 'In Progress', 'Attended')
                AND O_R_SGA_Eligible__c = TRUE
                AND summit__Contact__c <> NULL
                AND summit__Event_Instance__c <> NULL
                AND summit__Event_Instance__c = :eventInstance
        ];

        for (summit__Summit_Events_Registration__c r : registrations) {
            contactId.add(r.summit__Contact__c);
            registrantInfo.put(r.summit__Contact__c, new summit__Summit_Events_Registration__c(Id=r.Id));
        }

        List<Scholarship_Applicant__c> scholarshipApplicants = [
                SELECT Id,
                        Contact__c,
                        Scholarship_Status__c,
                        Scholarship__r.Scholarship_ID__c
                FROM Scholarship_Applicant__c
                WHERE Scholarship__c = :scholarshipId
                AND Contact__c = :contactId
                AND Scholarship_Status__c = 'Accepted'
        ];

        List<Opportunity> opportunityContactApplication = [
                SELECT Contact__c,
                        Contact__r.FirstName,
                        Contact__r.LastName,
                        Contact__r.hed__Gender__c,
                        Contact__r.MailingState,
                        Admissions_Application__r.Id,
//                        Admissions_Application__r.Applicant_Student_of_Color__c,
                        Admissions_Application__r.First_Generation__c,
                        Admissions_Application__r.Application_Status__c,
                        Athlete_Sport_1__c,
                        Athlete_Sport_2__c,
                        Athlete_Sport_3__c,
                        Housing_Requirement_Exception_Request__c,
                        Admissions_Application__r.Primary_High_School_Account__c,
                        Admissions_Application__r.Primary_High_School_Account__r.Name
                FROM Opportunity
                WHERE Term__c = :registrationTerm
                AND Academic_Program_Admit_Type__c = 'First-Year'
                AND Admissions_Application__c <> NULL
                AND Application_Status__c IN ('Confirmed')
                AND Contact__c IN :contactId
        ];

        for (Opportunity o : opportunityContactApplication) {
            List<String> sportsList = new List<String>();

            for (String s : new List<String>{o.Athlete_Sport_1__c, o.Athlete_Sport_2__c, o.Athlete_Sport_3__c}) {
                if (String.isNotBlank(s)) {
                    sportsList.add(s);
                }
            }
            String sportsJoin = sportsList.size() > 0 ? String.join(sportsList, ';') : '';

            if (registrantInfo.containsKey(o.Contact__c)) {

                registrantInfo.get(o.Contact__r.Id).O_R_SGA_Application__c = o.Admissions_Application__r.Id;
                registrantInfo.get(o.Contact__r.Id).O_R_SGA_Gender__c = o.Contact__r.hed__Gender__c;
//                registrantInfo.get(o.Contact__r.Id).O_R_SAG_Student_of_Color__c = o.Admissions_Application__r.Applicant_Student_of_Color__c;
                registrantInfo.get(o.Contact__r.Id).O_R_SGA_First_Generation__c = o.Admissions_Application__r.First_Generation__c == 'Yes, I am' ? true : false;
                registrantInfo.get(o.Contact__r.Id).O_R_SGA_Athlete__c = String.isNotBlank(sportsJoin) ? true : false;
                registrantInfo.get(o.Contact__r.Id).O_R_SGA_Athlete_Sport__c = sportsJoin;
                registrantInfo.get(o.Contact__r.Id).O_R_SGA_High_School__c = o.Admissions_Application__r.Primary_High_School_Account__c;
                registrantInfo.get(o.Contact__r.Id).O_R_SGA_High_School_Name__c = o.Admissions_Application__r.Primary_High_School_Account__r.Name;
                registrantInfo.get(o.Contact__r.Id).O_R_SGA_Commuter_Housing_Exception__c = o.Housing_Requirement_Exception_Request__c == 'Approved' ? true : false;
                registrantInfo.get(o.Contact__r.Id).O_R_SGA_Outside_of_Minnesota__c = o.Contact__r.MailingState <> 'MN' ? true : false;

                for (Scholarship_Applicant__c s : scholarshipApplicants) {
                    if (registrantInfo.containsKey(s.Contact__c)) {
                        registrantInfo.get(s.Contact__c).O_R_SGA_Aquinas_Scholars__c = s.Scholarship__r.Scholarship_ID__c;
                    }
                }
            }
        }

        update registrantInfo.values();
    }

    @AuraEnabled(Cacheable=false)
    public static void assignAppointmentTypes(String eventInstance) {

        List<summit__Summit_Events_Appointment_Type__c> appointmentTypes = [
                SELECT Id,
                        summit__Restrict_To_Instance_Title__c,
                        summit__Sort_Order__c
                FROM summit__Summit_Events_Appointment_Type__c
                WHERE summit__Restrict_To_Instance_Title__c <> NULL
                AND summit__Restrict_To_Instance_Title__c = :eventInstance
                ORDER BY summit__Sort_Order__c
        ];

        for (summit__Summit_Events_Appointment_Type__c a : appointmentTypes) {
            appointmentTypeSortList.add(new AppointmentTypeSort(a.Id, 0));
        }

        List<summit__Summit_Events_Registration__c> registrants = [
                SELECT Id,
                        summit__Event_Instance__c,
                        O_R_SGA_Eligible__c,
//                        O_R_SAG_Student_of_Color__c,
                        O_R_SGA_First_Generation__c,
                        O_R_SGA_Athlete__c,
                        O_R_SGA_Athlete_Sport__c,
                        O_R_SGA_Commuter_Housing_Exception__c,
                        O_R_SGA_Outside_of_Minnesota__c,
                        O_R_SGA_Gender__c,
                        O_R_SGA_High_School__c,
                        O_R_SGA_High_School_Name__c
                FROM summit__Summit_Events_Registration__c
                WHERE O_R_SGA_Eligible__c = TRUE
                AND summit__Status__c IN ('Registered', 'Confirmed', 'In Progress')
                AND summit__Event_Instance__c <> NULL
                AND summit__Event_Instance__c = :eventInstance
        ];

//        List<summit__Summit_Events_Registration__c> studentOfColorList = new List<summit__Summit_Events_Registration__c>();
        List<summit__Summit_Events_Registration__c> firstGenList = new List<summit__Summit_Events_Registration__c>();
        Map<String, List<summit__Summit_Events_Registration__c>> athleteSportsMen = new Map<String, List<summit__Summit_Events_Registration__c>>();
        Map<String, List<summit__Summit_Events_Registration__c>> athleteSportsWomen = new Map<String, List<summit__Summit_Events_Registration__c>>();
        List<summit__Summit_Events_Registration__c> housingExemptionList = new List<summit__Summit_Events_Registration__c>();
        List<summit__Summit_Events_Registration__c> outOfStateList = new List<summit__Summit_Events_Registration__c>();
        List<summit__Summit_Events_Registration__c> otherList = new List<summit__Summit_Events_Registration__c>();

        for (summit__Summit_Events_Registration__c r : registrants) {
//            if (r.O_R_SAG_Student_of_Color__c) {
//                studentOfColorList.add(r);
            if (r.O_R_SGA_First_Generation__c) {
                firstGenList.add(r);
            } else if (r.O_R_SGA_Athlete__c) {
                String sport = String.isNotBlank(r.O_R_SGA_Athlete_Sport__c) ? r.O_R_SGA_Athlete_Sport__c.split(';')[0] : '';

                if (sport.startsWithIgnoreCase('Men')) {
                    if (athleteSportsMen.containsKey(sport)) {
                        athleteSportsMen.get(sport).add(r);
                    } else {
                        athleteSportsMen.put(sport, new List<summit__Summit_Events_Registration__c>{r});
                    }
                } else if (sport.startsWithIgnoreCase('Women')){
                    if (athleteSportsWomen.containsKey(sport)) {
                        athleteSportsWomen.get(sport).add(r);
                    } else {
                        athleteSportsWomen.put(sport, new List<summit__Summit_Events_Registration__c>{r});
                    }
                } else {
                    if (athleteSportsWomen.containsKey('No Sport')) {
                        athleteSportsWomen.get(sport).add(r);
                    } else {
                        athleteSportsWomen.put(sport, new List<summit__Summit_Events_Registration__c>{r});
                    }
                }

            } else if (r.O_R_SGA_Commuter_Housing_Exception__c) {
                housingExemptionList.add(r);
            } else if (r.O_R_SGA_Outside_of_Minnesota__c) {
                outOfStateList.add(r);
            } else {
                otherList.add(r);
            }
        }

        otherList?.sort(new SummitRegistrationSort('O_R_SGA_Gender__c', 'Male', 'O_R_SGA_High_School_Name__c', 'zzzzzz'));
//        studentOfColorList?.sort(new SummitRegistrationSort('O_R_SGA_Gender__c', 'Male', 'O_R_SGA_High_School_Name__c', 'zzzzzz'));
        firstGenList?.sort(new SummitRegistrationSort('O_R_SGA_Gender__c', 'Male', 'O_R_SGA_High_School_Name__c', 'zzzzzz'));

        Map<String, List<summit__Summit_Events_Registration__c>> athleteSportsMap = new Map<String, List<summit__Summit_Events_Registration__c>>();
        List<String> athleteSportsMenKeys = new List<String>(athleteSportsMen.keySet());
        List<String> athleteSportsWomenKeys = new List<String>(athleteSportsWomen.keySet());
        Integer sportsIndex = athleteSportsMenKeys.size() >= athleteSportsWomenKeys.size() ? athleteSportsMenKeys.size() : athleteSportsWomenKeys.size();

        athleteSportsMenKeys.sort();
        athleteSportsWomenKeys.sort();

        for (Integer i = 0; i < sportsIndex; i++) {
            if (i < athleteSportsMenKeys.size()) {
                athleteSportsMap.put(athleteSportsMenKeys[i], athleteSportsMen.get(athleteSportsMenKeys[i]));
            }
            if (i < athleteSportsWomenKeys.size()) {
                athleteSportsMap.put(athleteSportsWomenKeys[i], athleteSportsWomen.get(athleteSportsWomenKeys[i]));
            }
        }

        for (String k : athleteSportsMap.keySet()) {
            athleteSportsMap.get(k).sort(new SummitRegistrationSort('O_R_SGA_High_School_Name__c', 'zzzzzz', '', ''));
        }

        housingExemptionList?.sort(new SummitRegistrationSort('O_R_SGA_Gender__c', 'Male', 'O_R_SGA_High_School_Name__c', 'zzzzzz'));
        outOfStateList?.sort(new SummitRegistrationSort('O_R_SGA_Gender__c', 'Male', 'O_R_SGA_High_School_Name__c', 'zzzzzz'));

        for (String k : athleteSportsMap.keySet()) {
            System.debug('Athlete Sport: '+ k +' '+athleteSportsMap.get(k).size());
        }
        System.debug('otherList '+otherList.size());
//        System.debug('studentOfColorList '+studentOfColorList.size());
        System.debug('firstGenList '+firstGenList.size());
        System.debug('housingExemptionList '+housingExemptionList.size());
        System.debug('outOfStateList '+outOfStateList.size());

        for (String k : athleteSportsMap.keySet()) {
            appointmentAssignment(athleteSportsMap.get(k), 'single');
        }
        appointmentAssignment(otherList, 'single');
//        appointmentAssignment(studentOfColorList, 'pair');
        appointmentAssignment(firstGenList, 'pair');
        appointmentAssignment(housingExemptionList, 'pair');
        appointmentAssignment(outOfStateList, 'pair');

        insert appointmentsListInsert;
    }

    @AuraEnabled(Cacheable=false)
    public static Integer recordAppointmentAssignment(String eventInstance) {
        Date assignDate = Date.today();
        List<summit__Summit_Events_Registration__c> registrationList = new List<summit__Summit_Events_Registration__c>();

        List<summit__Summit_Events_Appointments__c> appointments = [
                SELECT Id,
                        summit__Event_Appointment_Type__c,
                        summit__Event_Appointment_Type__r.Name,
                        summit__Event_Registration__c
                FROM summit__Summit_Events_Appointments__c
                WHERE summit__Event_Appointment_Type__r.summit__Restrict_To_Instance_Title__c <> NULL
                AND summit__Event_Appointment_Type__r.summit__Restrict_To_Instance_Title__c = :eventInstance
        ];

        for (summit__Summit_Events_Appointments__c a : appointments) {
            summit__Summit_Events_Registration__c registration = new summit__Summit_Events_Registration__c();

            registration.Id = a.summit__Event_Registration__c;
            registration.O_R_SGA_Appointment__c = a.Id;
            registration.O_R_SGA_Date__c = assignDate;

            registrationList.add(registration);
        }

        try {
            update registrationList;
        } catch(DmlException e) {
            registrationList.clear();
        }

        return registrationList.size();
    }

    public static void appointmentAssignment(List<summit__Summit_Events_Registration__c> registrantList, String assignmentType) {
        appointmentTypeSortList.sort();

        Integer appointmentTypeSize = appointmentTypeSortList.size();
        Integer appointmentTypeLimit;
        Integer appointmentTypeIdx = 0;

        if (assignmentType == 'single') {
            appointmentTypeLimit = appointmentTypeSize - 1;
        } else if (assignmentType == 'pair') {
            appointmentTypeLimit = (registrantList.size() / 2 >= appointmentTypeSize ? appointmentTypeSize : registrantList.size() / 2) - 1;
        }

        for (summit__Summit_Events_Registration__c r : registrantList) {
            summit__Summit_Events_Appointments__c appointment = new summit__Summit_Events_Appointments__c(summit__Event_Appointment_Type__c = appointmentTypeSortList[appointmentTypeIdx].appointmentTypeId,
                                                                                                            summit__Event_Registration__c = r.Id,
                                                                                                            summit__Appointment_Status__c = 'Requested');

            appointmentsListInsert.add(appointment);
            appointmentTypeSortList[appointmentTypeIdx].appointmentTypeCount++;

            appointmentTypeIdx++;

            if (appointmentTypeIdx > appointmentTypeLimit) {
                appointmentTypeIdx = 0;
            }
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<AppointmentDataDisplayWrapper> appointmentDataDisplay(String eventInstance) {
        List<AppointmentWrapper> appointmentWrapList = new List<AppointmentWrapper>();
        Map<String, List<AppointmentWrapper>> appointmentWrapMap = new Map<String, List<AppointmentWrapper>>();
        List<AppointmentDataDisplayWrapper> appointmentData = new List<AppointmentDataDisplayWrapper>();

        List<summit__Summit_Events_Appointments__c> appointments = [
                SELECT summit__Appointment_Status__c,
                        summit__Event_Appointment_Type__c,
                        summit__Event_Appointment_Type__r.Name,
                        summit__Event_Appointment_Type__r.summit__Restrict_To_Instance_Title__c,
                        summit__Event_Registration__c,
                        summit__Event_Registration__r.Name,
                        summit__Event_Registration__r.summit__Contact__r.Id,
                        summit__Event_Registration__r.summit__Contact__r.Name,
                        summit__Event_Registration__r.summit__Contact__r.LastName,
//                        summit__Event_Registration__r.O_R_SAG_Student_of_Color__c,
                        summit__Event_Registration__r.O_R_SGA_First_Generation__c,
                        summit__Event_Registration__r.O_R_SGA_Athlete__c,
                        summit__Event_Registration__r.O_R_SGA_Commuter_Housing_Exception__c,
                        summit__Event_Registration__r.O_R_SGA_Outside_of_Minnesota__c,
                        summit__Event_Registration__r.O_R_SGA_Gender__c
                FROM summit__Summit_Events_Appointments__c
                WHERE summit__Event_Appointment_Type__r.summit__Restrict_To_Instance_Title__c <> NULL
                AND summit__Event_Appointment_Type__r.summit__Restrict_To_Instance_Title__c = :eventInstance
                ORDER BY summit__Event_Appointment_Type__r.Name,
                        summit__Event_Registration__r.summit__Contact__r.LastName
        ];

        for (summit__Summit_Events_Appointments__c a : appointments) {
            AppointmentWrapper appointmentWrap = new AppointmentWrapper();

            appointmentWrap.Appointment_Type_Id = a.summit__Event_Appointment_Type__c;
            appointmentWrap.Appointment_Type_Name = a.summit__Event_Appointment_Type__r.Name;
            appointmentWrap.Appointment_Status = a.summit__Appointment_Status__c;
            appointmentWrap.Instance_Id = a.summit__Event_Appointment_Type__r.summit__Restrict_To_Instance_Title__c;
            appointmentWrap.Registration_Id = a.summit__Event_Registration__c;
            appointmentWrap.Registration_Name = a.summit__Event_Registration__r.Name;
            appointmentWrap.Contact_Id = a.summit__Event_Registration__r.summit__Contact__r.Id;
            appointmentWrap.Contact_Name = a.summit__Event_Registration__r.summit__Contact__r.Name;
//            appointmentWrap.Student_of_Color = a.summit__Event_Registration__r.O_R_SAG_Student_of_Color__c;
            appointmentWrap.First_Gen_Student = a.summit__Event_Registration__r.O_R_SGA_First_Generation__c;
            appointmentWrap.Athlete = a.summit__Event_Registration__r.O_R_SGA_Athlete__c;
            appointmentWrap.Housing_Exception = a.summit__Event_Registration__r.O_R_SGA_Commuter_Housing_Exception__c;
            appointmentWrap.Outside_of_Minnesota = a.summit__Event_Registration__r.O_R_SGA_Outside_of_Minnesota__c;
            appointmentWrap.Gender = a.summit__Event_Registration__r.O_R_SGA_Gender__c;

            appointmentWrapList.add(appointmentWrap);
        }

        for (AppointmentWrapper a : appointmentWrapList) {
            if (!appointmentWrapMap.containsKey(a.Appointment_Type_Name)) {
                appointmentWrapMap.put(a.Appointment_Type_Name, new List<AppointmentWrapper>());
            }

            appointmentWrapMap.get (a.Appointment_Type_Name).add(a);
        }

        for (String key : appointmentWrapMap.keySet()) {
            AppointmentDataDisplayWrapper d = new AppointmentDataDisplayWrapper();

            d.Appointment_Id = key;
            d.Appointment_Information = appointmentWrapMap.get(key);

            appointmentData.add(d);
        }

        return appointmentData;
    }

}