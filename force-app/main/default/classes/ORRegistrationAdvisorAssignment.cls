/**
 * Created by nguy0092 on 2/5/2024.
 *
 * USAGE: Assigns Registration Advisors (Summit Event Hosts) to each Small Groups (Summit Event Appointments) for Student Orientation & Registration Event Instance.
 * Process flow is triggered by Lightning Web Component Assign Button on Event Instance record and should be invoked after Small Groups have been assigned.
 * Advisors are assigned based on major criteria indicated on the Summit Event Host record and the registrants major on the Course Preference Form or admission application.
 * Setup Summit Events Hosts records with appropriate majors (seperated by ; with no space in between) in O_R_Advisor_Core_Major__c, O_R_Advisor_Secondary_Major__c, O_R_Advisor_Additional_Majors__c.
 */

public with sharing class ORRegistrationAdvisorAssignment {

    public with sharing class HostAssignWrapper {
        @AuraEnabled
        public String Appointment_Id { get; set; }
        @AuraEnabled
        public String Appointment_Name { get; set; }
        @AuraEnabled
        public String Host_Name { get; set; }
        @AuraEnabled
        public String Contact_Name { get; set; }
        @AuraEnabled
        public String Major_Assignment { get; set; }
    }

    public with sharing class HostAssignDataWrapper {
        @AuraEnabled
        public String Host_Name_Key { get; set; }
        @AuraEnabled
        public List<HostAssignWrapper> Host_Assign_Information { get; set; }
    }

    @AuraEnabled(Cacheable=false)
    public static void assignAppointmentHost(String eventInstance) {

        List<summit__Summit_Events_Appointments__c> appointmentHostList = new List<summit__Summit_Events_Appointments__c>();
        List<summit__Summit_Events_Registration__c> registrationHostList = new List<summit__Summit_Events_Registration__c>();
        List<summit__Summit_Events_Appointment_Type__c> updateAppointmentTypes = new List<summit__Summit_Events_Appointment_Type__c>();
        Map<String, List<summit__Summit_Events_Appointments__c>> mapAppointments = new Map<String, List<summit__Summit_Events_Appointments__c>>();

        List<summit__Summit_Events_Appointment_Type__c> appointmentTypeInstance = [
                SELECT Id
                FROM summit__Summit_Events_Appointment_Type__c
                WHERE summit__Restrict_To_Instance_Title__c <> NULL
                AND summit__Restrict_To_Instance_Title__c = :eventInstance
        ];

        List<summit__Summit_Events_Appointments__c> listAppointments = [
                SELECT Id,
                        summit__Event_Registration__c,
                        summit__Event_Registration__r.summit__Contact__r.Name,
                        summit__Event_Registration__r.O_R_SGA_Application__r.Major_1__r.Major_Code__c,
                        summit__Event_Registration__r.O_R_SGA_Application__r.CPF_Major__r.Major_Code__c,
                        summit__Event_Registration__r.O_R_SGA_Application__r.Pre_Professional_Program__r.Name,
                        summit__Event_Registration__r.O_R_SGA_Application__r.CPF_Pre_Professional_Program__r.Name,
                        summit__Event_Registration__r.O_R_SGA_Athlete__c,
                        summit__Event_Appointment_Type__c
                FROM summit__Summit_Events_Appointments__c
                WHERE summit__Event_Appointment_Type__c = :appointmentTypeInstance
        ];

        for (summit__Summit_Events_Appointments__c appt : listAppointments) {

            if (!mapAppointments.containsKey(appt.summit__Event_Appointment_Type__c)) {

                mapAppointments.put(appt.summit__Event_Appointment_Type__c, new List<summit__Summit_Events_Appointments__c>());
            }

            mapAppointments.get(appt.summit__Event_Appointment_Type__c).add(appt);
        }

        List<summit__Summit_Events_Host__c> hosts = [
                SELECT Id,
                        summit__Course_Name__c,
                        summit__Preferred_Title__c,
                        O_R_Advisor_Core_Major__c,
                        O_R_Advisor_Secondary_Major__c,
                        O_R_Advisor_Additional_Majors__c,
                        summit__Assigned__c,
                        summit__Event_Instance__c
                FROM summit__Summit_Events_Host__c
                WHERE summit__Event_Instance__c <> NULL
                AND summit__Event_Instance__c = :eventInstance
                ORDER BY summit__Course_Name__c
        ];

        for (String key : mapAppointments.keySet()) {

            String appointmentType = key;
            Map<String, List<String>> hostAthlete = new Map<String, List<String>>();
            Map<String, List<String>> hostOverflow = new Map<String, List<String>>();
            Map<String, List<String>> hostCoreMajor = new Map<String, List<String>>();
            Map<String, Decimal> hostCoreMajorSort = new Map<String, Decimal>();
            Map<String, List<String>> hostSecondaryMajor = new Map<String, List<String>>();
            Map<String, Decimal> hostSecondaryMajorSort = new Map<String, Decimal>();
            Map<String, List<String>> hostAdditionalMajor = new Map<String, List<String>>();
            Map<String, Decimal> hostAdditionalMajorSort = new Map<String, Decimal>();

            for (summit__Summit_Events_Host__c h : hosts) {

                List<String> coreMajor = h.O_R_Advisor_Core_Major__c?.split(';');
                List<String> secondaryMajor = h.O_R_Advisor_Secondary_Major__c?.split(';');
                List<String> additionalMajor = h.O_R_Advisor_Additional_Majors__c?.split(';');

                if (h.O_R_Advisor_Core_Major__c != null && h.O_R_Advisor_Core_Major__c.toUpperCase().contains('ATHLE')) {

                    hostAthlete.put(h.Id, coreMajor);
                }

                if (h.O_R_Advisor_Core_Major__c != null && h.O_R_Advisor_Core_Major__c.toUpperCase().contains('OVER')) {

                    hostOverflow.put(h.Id, coreMajor);
                }

                if (h.O_R_Advisor_Additional_Majors__c != null && h.O_R_Advisor_Additional_Majors__c.toUpperCase().contains('ALL')) {

                    hostAdditionalMajor.put(h.Id, additionalMajor);
                    hostAdditionalMajorSort.put(h.Id, h.summit__Assigned__c);
                }

                if (h.O_R_Advisor_Core_Major__c != null && !h.O_R_Advisor_Core_Major__c.toUpperCase().contains('ATHLE') && !h.O_R_Advisor_Core_Major__c.toUpperCase().contains('OVER')) {

                    hostCoreMajor.put(h.Id, coreMajor);
                    hostCoreMajorSort.put(h.Id, h.summit__Assigned__c);
                }

                if (h.O_R_Advisor_Secondary_Major__c != null) {

                    hostSecondaryMajor.put(h.Id, secondaryMajor);
                    hostSecondaryMajorSort.put(h.Id, h.summit__Assigned__c);
                }
            }

            for (summit__Summit_Events_Appointments__c a : mapAppointments.get(key)) {

                Boolean skipHost = false;

                String major = a.summit__Event_Registration__r.O_R_SGA_Application__r.CPF_Major__r.Major_Code__c != null ? a.summit__Event_Registration__r.O_R_SGA_Application__r.CPF_Major__r.Major_Code__c : a.summit__Event_Registration__r.O_R_SGA_Application__r.Major_1__r.Major_Code__c;
                String preProfMajor = a.summit__Event_Registration__r.O_R_SGA_Application__r.CPF_Pre_Professional_Program__r.Name != null ? a.summit__Event_Registration__r.O_R_SGA_Application__r.CPF_Pre_Professional_Program__r.Name : a.summit__Event_Registration__r.O_R_SGA_Application__r.Pre_Professional_Program__r.Name;

                if (!skipHost) {

                    for (String k : hostAthlete.keySet()) {

                        if (a.summit__Event_Registration__r.O_R_SGA_Athlete__c) {

                            recordHostUpdate(a, k, 'ATHLETE', preProfMajor, appointmentHostList, registrationHostList);
                            hostAssignCount(k, hosts);
                            skipHost = !skipHost;

                            break;
                        }
                    }
                }

                if (!skipHost) {

                    for (String k : sortHostMapKey(hostCoreMajorSort)) {

                        for (String s : hostCoreMajor.get(k)) {

                            if (major == s.trim()) {

                                recordHostUpdate(a, k, major, preProfMajor, appointmentHostList, registrationHostList);
                                hostAssignCount(k, hosts);
                                hostMapSortRemove(k, hostCoreMajorSort, hostSecondaryMajorSort, hostAdditionalMajorSort);
                                skipHost = !skipHost;

                                break;
                            }
                        }

                        if (skipHost) {

                            break;
                        }
                    }
                }

                if (!skipHost) {

                    for (String k : sortHostMapKey(hostSecondaryMajorSort)) {

                        for (String s : hostSecondaryMajor.get(k)) {

                            if (major == s.trim()) {

                                recordHostUpdate(a, k, major, preProfMajor, appointmentHostList, registrationHostList);
                                hostAssignCount(k, hosts);
                                hostMapSortRemove(k, hostCoreMajorSort, hostSecondaryMajorSort, hostAdditionalMajorSort);
                                skipHost = !skipHost;

                                break;
                            }
                        }

                        if (skipHost) {

                            break;
                        }
                    }
                }

                if (!skipHost) {

                    for (String k : sortHostMapKey(hostAdditionalMajorSort)) {

                        for (String s : hostAdditionalMajor.get(k)) {

                            if (s == 'ALL') {

                                recordHostUpdate(a, k, major, preProfMajor, appointmentHostList, registrationHostList);
                                hostAssignCount(k, hosts);
                                hostMapSortRemove(k, hostCoreMajorSort, hostSecondaryMajorSort, hostAdditionalMajorSort);
                                skipHost = !skipHost;

                                break;
                            }
                        }

                        if (skipHost) {

                            break;
                        }
                    }
                }

                if (!skipHost) {

                    for (String k : hostOverflow.keySet()) {

                        for (String s : hostOverflow.get(k)) {

                            recordHostUpdate(a, k, major, preProfMajor, appointmentHostList, registrationHostList);
                            hostAssignCount(k, hosts);
                            skipHost = !skipHost;

                            break;
                        }
                    }
                }
            }

            updateAppointmentTypes.add(new summit__Summit_Events_Appointment_Type__c(Id = appointmentType,
                                                                                    O_R_Advisor_Assignment_Date__c = Date.today()));
        }

        update appointmentHostList;
        update registrationHostList;
        update hosts;
        update updateAppointmentTypes;
        update new summit__Summit_Events_Instance__c(Id = eventInstance,
                                                    O_R_Advisor_Assignment_Date__c = Date.today());
    }

    public static List<String> sortHostMapKey(Map<String, Decimal> hostMap) {

        Map<String, Decimal> hostMapClone = hostMap.clone();

        List<Decimal> keySort = new List<Decimal>();
        List<String> hostMapKeySort = new List<String>();

        for (String key : hostMapClone.keySet()) {

            keySort.add(hostMapClone.get(key));
        }

        keySort.sort();

        for (Decimal d : keySort) {

            for (String key : hostMapClone.keySet()) {

                if (hostMapClone.get(key) == d) {

                    hostMapKeySort.add(key);
                    hostMapClone.remove(key);
                }
            }
        }

        return hostMapKeySort;
    }

    public static void recordHostUpdate(summit__Summit_Events_Appointments__c appointment,
                                        String Id,
                                        String major,
                                        String preProfMajor,
                                        List<summit__Summit_Events_Appointments__c> appointmentHostList,
                                        List<summit__Summit_Events_Registration__c> registrationHostList) {

        summit__Summit_Events_Appointments__c updateAppointment = new summit__Summit_Events_Appointments__c();
        summit__Summit_Events_Registration__c updateRegistration = new summit__Summit_Events_Registration__c();

        updateAppointment.Id = appointment.Id;
        updateAppointment.summit__Event_Host__c = Id;

        appointmentHostList.add(updateAppointment);

        updateRegistration.Id = appointment.summit__Event_Registration__c;
        updateRegistration.O_R_Major_Assignment__c = major;
        updateRegistration.O_R_Preprofessional_Program__c = preProfMajor;
        registrationHostList.add(updateRegistration);
    }

    public static void hostAssignCount(String Id, List<summit__Summit_Events_Host__c> hostList) {

        for (summit__Summit_Events_Host__c h : hostList) {

            if (h.Id == Id) {

                h.summit__Assigned__c++;
            }
        }
    }

    public static void hostMapSortRemove(String key,
                                        Map<String, Decimal> hostCoreMajorSort,
                                        Map<String, Decimal> hostSecondaryMajorSort,
                                        Map<String, Decimal> hostAdditionalMajorSort) {

        hostCoreMajorSort.remove(key);
        hostSecondaryMajorSort.remove(key);
        hostAdditionalMajorSort.remove(key);
    }

    @AuraEnabled(Cacheable=true)
    public static List<summit__Summit_Events_Appointments__c> instanceHostAssignCheck(String eventInstance) {

        List<summit__Summit_Events_Appointments__c> hostCheck = [
                SELECT Id
                FROM summit__Summit_Events_Appointments__c
                WHERE summit__Event_Host__r.Name <> NULL
                AND summit__Event_Appointment_Type__r.summit__Restrict_To_Instance_Title__c = :eventInstance
        ];

        return hostCheck;
    }

    @AuraEnabled(Cacheable=true)
    public static List<HostAssignDataWrapper> hostAssignDataDisplay(String appointmentTypeId) {

        List<HostAssignWrapper> hostAssignWrapList = new List<HostAssignWrapper>();
        Map<String, List<HostAssignWrapper>> hostAssignWrapMap = new Map<String, List<HostAssignWrapper>>();
        List<HostAssignDataWrapper> hostAssignData = new List<HostAssignDataWrapper>();

        List<summit__Summit_Events_Appointments__c> hostAssign = [
                SELECT Id,
                        Name,
                        summit__Event_Host__r.Name,
                        summit__Event_Host__r.summit__Course_Name__c,
                        summit__Event_Registration__r.summit__Contact__r.Name,
                        summit__Event_Registration__r.O_R_Major_Assignment__c
                FROM summit__Summit_Events_Appointments__c
                WHERE summit__Event_Host__r.Name <> NULL
                AND summit__Event_Appointment_Type__c = :appointmentTypeId
                ORDER BY summit__Event_Host__r.summit__Course_Name__c,
                        summit__Event_Registration__r.summit__Contact__r.LastName
        ];

        for (summit__Summit_Events_Appointments__c a : hostAssign) {

            HostAssignWrapper hostAssignWrap = new HostAssignWrapper();

            hostAssignWrap.Appointment_Id = a.Id;
            hostAssignWrap.Appointment_Name = a.Name;
            hostAssignWrap.Host_Name = a.summit__Event_Host__r.summit__Course_Name__c + ' (' + a.summit__Event_Host__r.Name + ')';
            hostAssignWrap.Contact_Name = a.summit__Event_Registration__r.summit__Contact__r.Name;
            hostAssignWrap.Major_Assignment = a.summit__Event_Registration__r.O_R_Major_Assignment__c;

            hostAssignWrapList.add(hostAssignWrap);
        }

        for (HostAssignWrapper a : hostAssignWrapList) {

            if (!hostAssignWrapMap.containsKey(a.Host_Name)) {

                hostAssignWrapMap.put(a.Host_Name, new List<HostAssignWrapper>());
            }

            hostAssignWrapMap.get(a.Host_Name).add(a);
        }

        for (String key : hostAssignWrapMap.keySet()) {

            HostAssignDataWrapper HostAssignDataWrap = new HostAssignDataWrapper();

            HostAssignDataWrap.Host_Name_Key = key;
            HostAssignDataWrap.Host_Assign_Information = hostAssignWrapMap.get(key);

            hostAssignData.add(HostAssignDataWrap);
        }

        return hostAssignData;
    }

}