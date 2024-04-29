/**
 * Created by nguy0092 on 4/18/2024.
 */

public with sharing class YnSummitEventsList {

    public with sharing class EventRegistrationWrapper {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String EventName { get; set; }
        @AuraEnabled
        public Date EventDate { get; set; }
        @AuraEnabled
        public Time EventTime { get; set; }
        @AuraEnabled
        public String EventDateTime { get; set; }
        @AuraEnabled
        public String randomString { get; set;}
    }

    @AuraEnabled(Cacheable=true)
    public static List<EventRegistrationWrapper> eventsRegistrations(String contactId) {

        List<EventRegistrationWrapper> registrationList = new List<EventRegistrationWrapper>();


        List<summit__Summit_Events_Registration__c> registrations = [
                SELECT Id,
                        Name,
                        summit__Event_Name__c,
                        summit__Event_Instance__c,
                        summit__Event_Instance__r.Name,
                        summit__Event_Instance__r.summit__Instance_Start_Date__c,
                        summit__Event_Instance__r.summit__Instance_Start_Time__c,
                        summit__Event_Instance__r.summit__Instance_End_Date__c,
                        summit__Event_Instance__r.summit__Instance_End_Time__c,
                        summit__Contact__c
                FROM summit__Summit_Events_Registration__c
                WHERE summit__Contact__c = :contactId
                ORDER BY summit__Event_Instance__r.summit__Instance_Start_Date__c,
                        summit__Event_Instance__r.summit__Instance_Start_Time__c
        ];

        for (summit__Summit_Events_Registration__c r : registrations) {

            EventRegistrationWrapper registrationWrapper = new EventRegistrationWrapper();

            Datetime startDatetime = Datetime.newInstance(r.summit__Event_Instance__r.summit__Instance_Start_Date__c, r.summit__Event_Instance__r.summit__Instance_Start_Time__c);
            Datetime endDatetime = Datetime.newInstance(r.summit__Event_Instance__r.summit__Instance_Start_Date__c, r.summit__Event_Instance__r.summit__Instance_End_Time__c);

            String formatStartDate = startDatetime.format('EEEE, MMMM dd, y');
            String formatStartTime = startDatetime.format('hh:mm a');
            String formatEndDate = endDatetime.format('EEEE, MMMM dd, y');
            String formatEndTime = endDatetime.format('hh:mm a');

            registrationWrapper.Id = r.Id;
            registrationWrapper.EventName = r.summit__Event_Name__c;
            registrationWrapper.EventDate = r.summit__Event_Instance__r.summit__Instance_Start_Date__c;
            registrationWrapper.EventTime = r.summit__Event_Instance__r.summit__Instance_Start_Time__c;
            registrationWrapper.EventDateTime = formatStartDate + ' ' + formatStartTime + ' - ' + formatEndTime;
            registrationWrapper.randomString = 'Now this is different';

            System.debug('This is registration wrapper: ' + registrationWrapper);

            registrationList.add(registrationWrapper);

        }

        System.debug('This is registration list: ' + registrationList);

        return registrationList;

    }

}