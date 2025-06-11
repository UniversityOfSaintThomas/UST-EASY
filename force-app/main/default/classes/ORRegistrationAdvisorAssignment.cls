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

    public class EventHostGroupsClass {

        List<summit__Summit_Events_Host__c> hostAthletes = new List<summit__Summit_Events_Host__c>();
        List<summit__Summit_Events_Host__c> hostScholarship = new List<summit__Summit_Events_Host__c>();
        List<summit__Summit_Events_Host__c> hostOverflow = new List<summit__Summit_Events_Host__c>();
        List<summit__Summit_Events_Host__c> hostAdditionalMajor = new List<summit__Summit_Events_Host__c>();
        List<summit__Summit_Events_Host__c> hostCoreMajor = new List<summit__Summit_Events_Host__c>();
        List<summit__Summit_Events_Host__c> hostSecondaryMajor = new List<summit__Summit_Events_Host__c>();

        public EventHostGroupsClass(List<summit__Summit_Events_Host__c> hosts) {

            for (summit__Summit_Events_Host__c h : hosts) {
                if (h.O_R_Advisor_Core_Major__c != null && h.O_R_Advisor_Core_Major__c.toUpperCase().contains('ATHLE')) {
                    hostAthletes.add(h);
                }
                if (h.O_R_Advisor_Core_Major__c != null && h.O_R_Advisor_Core_Major__c.toUpperCase().contains('SCHOLAR')) {
                    hostScholarship.add(h);
                }
                if (h.O_R_Advisor_Core_Major__c != null && h.O_R_Advisor_Core_Major__c.toUpperCase().contains('OVER')) {
                    hostOverflow.add(h);
                }
                if (h.O_R_Advisor_Additional_Majors__c != null && h.O_R_Advisor_Additional_Majors__c.toUpperCase().contains('ALL')) {
                    hostAdditionalMajor.add(h);
                }
                if (h.O_R_Advisor_Core_Major__c != null && !h.O_R_Advisor_Core_Major__c.toUpperCase().contains('ATHLE') && !h.O_R_Advisor_Core_Major__c.toUpperCase().contains('SCHOLAR') && !h.O_R_Advisor_Core_Major__c.toUpperCase().contains('OVER')) {
                    hostCoreMajor.add(h);
                }
                if (h.O_R_Advisor_Secondary_Major__c != null) {
                    hostSecondaryMajor.add(h);
                }
            }
        }

    }

    public class EventsHostSort implements Comparator<summit__Summit_Events_Host__c> {

        public Integer compare(summit__Summit_Events_Host__c host1, summit__Summit_Events_Host__c host2) {
            Integer returnValue = 0;

            if(host1 == null && host2 == null) {
                returnValue = 0;
            } else if(host1 == null) {
                returnValue = -1;
            } else if(host2== null) {
                returnValue = 1;
            } else if ((host1.summit__Assigned__c == null) && (host2.summit__Assigned__c == null)) {
                returnValue = 0;
            } else if (host1.summit__Assigned__c == null){
                returnValue = -1;
            } else if (host2.summit__Assigned__c == null){
                returnValue = 1;
            } else if (host1.summit__Assigned__c < host2.summit__Assigned__c) {
                returnValue = -1;
            } else if (host1.summit__Assigned__c > host2.summit__Assigned__c) {
                returnValue = 1;
            }

            return returnValue;
        }
    }

    @AuraEnabled(Cacheable=false)
    public static Integer assignAppointmentHost(String eventInstance) {

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
                        summit__Event_Registration__r.O_R_SGA_Aquinas_Scholars__c,
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

        Map<Id, summit__Summit_Events_Host__c> eventHostsMap = new Map<Id, summit__Summit_Events_Host__c>([
                SELECT Id,
                        O_R_Advisor_Core_Major__c,
                        O_R_Advisor_Secondary_Major__c,
                        O_R_Advisor_Additional_Majors__c,
                        summit__Assigned__c
                FROM summit__Summit_Events_Host__c
                WHERE summit__Event_Instance__c <> NULL
                AND summit__Event_Instance__c = :eventInstance
                ORDER BY summit__Course_Name__c
        ]);

        for (Id i : eventHostsMap.keySet()) {
            eventHostsMap.get(i).summit__Assigned__c = 0;
        }

        for (String appointmentTypeId : mapAppointments.keySet()) {
            EventHostGroupsClass eventHostGroups = new EventHostGroupsClass(eventHostsMap.values());

            for (summit__Summit_Events_Appointments__c appointment : mapAppointments.get(appointmentTypeId)) {
                Boolean skipHost = false;
                String major = appointment.summit__Event_Registration__r.O_R_SGA_Application__r.CPF_Major__r.Major_Code__c != null ? appointment.summit__Event_Registration__r.O_R_SGA_Application__r.CPF_Major__r.Major_Code__c : appointment.summit__Event_Registration__r.O_R_SGA_Application__r.Major_1__r.Major_Code__c;
                String preProfMajor = appointment.summit__Event_Registration__r.O_R_SGA_Application__r.CPF_Pre_Professional_Program__r.Name != null ? appointment.summit__Event_Registration__r.O_R_SGA_Application__r.CPF_Pre_Professional_Program__r.Name : appointment.summit__Event_Registration__r.O_R_SGA_Application__r.Pre_Professional_Program__r.Name;

                if (!skipHost) {
                    for (summit__Summit_Events_Host__c host : eventHostGroups.hostAthletes) {
                        if (appointment.summit__Event_Registration__r.O_R_SGA_Athlete__c) {
                            recordHostUpdate(appointment, host, 'ATH:'+major, preProfMajor, appointmentHostList, registrationHostList);
                            host.summit__Assigned__c++;
                            skipHost = !skipHost;
                            break;
                        }
                    }
                }

                if (!skipHost) {
                    for (summit__Summit_Events_Host__c host : eventHostGroups.hostScholarship) {
                        if (String.isNotBlank(appointment.summit__Event_Registration__r.O_R_SGA_Aquinas_Scholars__c)) {
                            recordHostUpdate(appointment, host, major, preProfMajor, appointmentHostList, registrationHostList);
                            host.summit__Assigned__c++;
                            hostRemoval(host, eventHostGroups.hostScholarship, eventHostGroups.hostCoreMajor, eventHostGroups.hostSecondaryMajor, eventHostGroups.hostAdditionalMajor);
                            skipHost = !skipHost;
                            break;
                        }
                    }
                }

                if (!skipHost) {
                    eventHostGroups.hostCoreMajor.sort(new EventsHostSort());
                    for (summit__Summit_Events_Host__c host : eventHostGroups.hostCoreMajor) {
                        List<String> coreMajor = host.O_R_Advisor_Core_Major__c?.split(';');
                        if (coreMajor != null) {
                            for (String cm : coreMajor) {
                                if (major == cm.trim()) {
                                    recordHostUpdate(appointment, host, major, preProfMajor, appointmentHostList, registrationHostList);
                                    host.summit__Assigned__c++;
                                    hostRemoval(host, eventHostGroups.hostScholarship, eventHostGroups.hostCoreMajor, eventHostGroups.hostSecondaryMajor, eventHostGroups.hostAdditionalMajor);
                                    skipHost = !skipHost;
                                    break;
                                }
                            }
                        }
                        if (skipHost) {
                            break;
                        }
                    }
                }

                if (!skipHost) {
                    eventHostGroups.hostSecondaryMajor.sort(new EventsHostSort());
                    for (summit__Summit_Events_Host__c host : eventHostGroups.hostSecondaryMajor) {
                        List<String> secondaryMajor = host.O_R_Advisor_Secondary_Major__c?.split(';');
                        if (secondaryMajor != null) {
                            for (String sm : secondaryMajor) {
                                if (major == sm.trim()) {
                                    recordHostUpdate(appointment, host, major, preProfMajor, appointmentHostList, registrationHostList);
                                    host.summit__Assigned__c++;
                                    hostRemoval(host, eventHostGroups.hostScholarship, eventHostGroups.hostCoreMajor, eventHostGroups.hostSecondaryMajor, eventHostGroups.hostAdditionalMajor);
                                    skipHost = !skipHost;
                                    break;
                                }
                            }
                        }
                        if (skipHost) {
                            break;
                        }
                    }
                }

                if (!skipHost) {
                    eventHostGroups.hostAdditionalMajor.sort(new EventsHostSort());
                    for (summit__Summit_Events_Host__c host : eventHostGroups.hostAdditionalMajor) {
                        List<String> additionalMajor = host.O_R_Advisor_Additional_Majors__c?.split(';');
                        if (additionalMajor != null) {
                            for (String am : additionalMajor) {
                                if (am == 'ALL') {
                                    recordHostUpdate(appointment, host, major, preProfMajor, appointmentHostList, registrationHostList);
                                    host.summit__Assigned__c++;
                                    hostRemoval(host, eventHostGroups.hostScholarship, eventHostGroups.hostCoreMajor, eventHostGroups.hostSecondaryMajor, eventHostGroups.hostAdditionalMajor);
                                    skipHost = !skipHost;
                                    break;
                                }
                            }
                        }
                        if (skipHost) {
                            break;
                        }
                    }
                }

                if (!skipHost) {
                    for (summit__Summit_Events_Host__c host : eventHostGroups.hostOverflow) {
                        recordHostUpdate(appointment, host, major, preProfMajor, appointmentHostList, registrationHostList);
                        host.summit__Assigned__c++;
                        skipHost = !skipHost;
                        break;
                    }
                }
            }

            updateAppointmentTypes.add(new summit__Summit_Events_Appointment_Type__c(Id = appointmentTypeId,
                                                                                    O_R_Advisor_Assignment_Date__c = Date.today()));
        }

        try {
            update appointmentHostList;
            update registrationHostList;
            update eventHostsMap.values();
            update updateAppointmentTypes;
        } catch (DmlException e) {
            appointmentHostList.clear();
        }

        return appointmentHostList.size();
    }

    public static void recordHostUpdate(summit__Summit_Events_Appointments__c appointment,
                                        summit__Summit_Events_Host__c host,
                                        String major,
                                        String preProfMajor,
                                        List<summit__Summit_Events_Appointments__c> appointmentHostList,
                                        List<summit__Summit_Events_Registration__c> registrationHostList) {
        appointmentHostList.add(new summit__Summit_Events_Appointments__c(Id = appointment.Id,
                                                                            summit__Event_Host__c = host.Id));
        registrationHostList.add(new summit__Summit_Events_Registration__c(Id = appointment.summit__Event_Registration__c,
                                                                            O_R_Major_Assignment__c = major,
                                                                            O_R_Preprofessional_Program__c = preProfMajor));
    }

    public static void hostRemoval(summit__Summit_Events_Host__c host,
                                    List<summit__Summit_Events_Host__c> hostScholarshipRemove,
                                    List<summit__Summit_Events_Host__c> hostCoreMajorRemove,
                                    List<summit__Summit_Events_Host__c> hostSecondaryMajorRemove,
                                    List<summit__Summit_Events_Host__c> hostAdditionalMajorRemove) {

        Integer hostScholarshipIndex = hostScholarshipRemove.indexOf(host);
        Integer hostCoreMajorIndex = hostCoreMajorRemove.indexOf(host);
        Integer hostSecondaryMajorIndex = hostSecondaryMajorRemove.indexOf(host);
        Integer hostAdditionalMajorIndex = hostAdditionalMajorRemove.indexOf(host);

        if (hostScholarshipIndex <> -1) {
            hostScholarshipRemove.remove(hostScholarshipIndex);
        }
        if (hostCoreMajorIndex <> -1) {
            hostCoreMajorRemove.remove(hostCoreMajorIndex);
        }
        if (hostSecondaryMajorIndex <> -1) {
            hostSecondaryMajorRemove.remove(hostSecondaryMajorIndex);
        }
        if (hostAdditionalMajorIndex <> -1) {
            hostAdditionalMajorRemove.remove(hostAdditionalMajorIndex);
        }
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