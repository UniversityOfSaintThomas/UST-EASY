/**
 * Created by nguy0092 on 4/22/2024.
 */

public with sharing class YnSummitEventsListTEST1 {

    @AuraEnabled(Cacheable=true)
    public static List<String> eventsRegistrations() {

        List<String> s = new List<String>{'hello', 'world', 'good', 'bye'};

        return s;
    }

}