/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/17/2021.
 */


public with sharing class ApplicationBodyController {

    public EASYApplicationInfo appInfoParam { get; set; }
    public String currentPageName { get; set; }

    public ApplicationBodyController() {
    }

    public class allWidgets {
        public List<EASY_Widget__c> topWidgets { get; set; }
        public List<EASY_Widget__c> rightWidgets { get; set; }
        public List<EASY_Widget__c> bottomWidgets { get; set; }
        public List<EASY_Widget__c> leftWidgets { get; set; }
        public List<EASY_Widget__c> contentTopWidgets { get; set; }
        public List<EASY_Widget__c> contentBottomWidgets { get; set; }
    }

    public allWidgets getWidgets() {
        List<String> pagesWithMultipleAppInfo = new List<String>{
                'ApplicationPortal'
        };

        Map<String, Integer> onlyOneWidgetPerPage = new Map<String, Integer>{
                'Application Finder' => 0
        };

        Set<Id> appInfoIds = new Set<Id>();
        Map<String, Set<String>> atStatusMap = new Map<String, Set<String>>();
        Map<String, Set<String>> atSubStatusMap = new Map<String, Set<String>>();
        Map<String, Set<String>> atCitizenshipMap = new Map<String, Set<String>>();
        currentPageName = getVFPageName();
        allWidgets foundWidgets = new allWidgets();
        foundWidgets.topWidgets = new List<EASY_Widget__c>();
        foundWidgets.rightWidgets = new List<EASY_Widget__c>();
        foundWidgets.bottomWidgets = new List<EASY_Widget__c>();
        foundWidgets.leftWidgets = new List<EASY_Widget__c>();
        foundWidgets.contentTopWidgets = new List<EASY_Widget__c>();
        foundWidgets.contentBottomWidgets = new List<EASY_Widget__c>();
        List<EASY_Widget__c> allPositionWidgets = new List<EASY_Widget__c>();

        if (String.isBlank(appInfoParam.appStatus)) {
            appInfoParam.appStatus = 'none';
        }

        /* Some pages may have multiple app contexts */
        if (pagesWithMultipleAppInfo.contains(currentPageName)) {
            System.debug('has multiple apps');
            for (Application__c app : [
                    SELECT Application_Control__r.Id, Application_Control__r.URL_Parameter__c, Application_Status__c, Application_Substatus__c,
                            Intended_Term_of_Entry__r.Name, Intended_Program__r.Name, Citizenship__c
                    FROM Application__c
                    WHERE Contact__c = :appInfoParam.contactId
            ]) {
                appInfoIds.add(app.Application_Control__r.Id);
                String atURL = app.Application_Control__r.URL_Parameter__c;

                //atStatusMap.put(app.Application_Control__r.URL_Parameter__c, null);
                if (String.isNotBlank(app.Application_Status__c)) {
                    if (atStatusMap.containsKey(app.Application_Control__r.URL_Parameter__c)) {
                        atStatusMap.get(atURL).addAll(new Set<String>(app.Application_Status__c.split(';')));
                    } else {
                        atStatusMap.put(atURL, new Set<String>(app.Application_Status__c.split(';')));
                    }
                }

                //atSubStatusMap.put(app.Application_Control__r.URL_Parameter__c, null);
                if (String.isNotBlank(app.Application_Substatus__c)) {
                    if (atSubStatusMap.containsKey(atURL)) {
                        atSubStatusMap.get(atURL).addAll(new Set<String>(app.Application_Substatus__c.split(';')));
                    } else {
                        atSubStatusMap.put(atURL, new Set<String>(app.Application_Substatus__c.split(';')));
                    }
                }

                if (String.isNotBlank(app.Citizenship__c)) {
                    if (atCitizenshipMap.containsKey(atURL)) {
                        atCitizenshipMap.get(atURL).add(app.Citizenship__c);
                    } else {
                        atCitizenshipMap.put(atURL, new Set<String>{
                                app.Citizenship__c
                        });
                    }
                }
            }
        } else {
            atStatusMap.put(appInfoParam.at, new Set<String>{
                    appInfoParam.appStatus
            });
            atSubStatusMap.put(appInfoParam.at, new Set<String>{
                    appInfoParam.appSubStatus
            });
            atCitizenshipMap.put(appInfoParam.at, new Set<String>{
                    appInfoParam.citizenship
            });
            appInfoIds.add(appInfoParam.appControlId);
        }

        /* Gather up all the widgets */
        try {
            allPositionWidgets = [
                    SELECT Id, Name, Display_Text__c, Scripts__c, Widget_Screen_Location__c, Display_Heading__c,
                            Widget_Type__c, Sort_Order__c, Display_Widget_On_Pages__c, Display_Widget_On_Status__c,
                            Display_Widget_On_Sub_Status__c, Application_Control__r.URL_Parameter__c, Activation_State__c,
                            Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Widget_Time_Zone__c, Display_Widget_On_Citizenship__c
                    FROM EASY_Widget__c
                    WHERE Application_Control__c IN :appInfoIds
                    WITH SECURITY_ENFORCED
                    ORDER BY Sort_Order__c
            ];
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        /* Start/End date filter if defined */
        for (EASY_Widget__c widget : allPositionWidgets) {
            Boolean skipWidget = false;
            if (widget.Activation_State__c.equalsIgnoreCase('Inactive')) {
                skipWidget = true;
            } else if (widget.Activation_State__c.equalsIgnoreCase('Date activated')) {
                Datetime nowDateTime = adjustForTimeZone(Datetime.now(), widget.Widget_Time_Zone__c);
                if (String.isNotBlank(widget.Widget_Time_Zone__c)) {
                    if (widget.Start_Date__c != null && widget.Start_Time__c != null) {
                        Datetime widgetStartDateTime = convertDateToDatetime(widget.Start_Date__c, widget.Start_Time__c, null);
                        if (nowDateTime <= widgetStartDateTime) {
                            skipWidget = true;
                        }
                    }
                    if (widget.End_Date__c != null && widget.End_Time__c != null) {
                        Datetime widgetEndDateTime = convertDateToDatetime(widget.End_Date__c, widget.End_Time__c, null);
                        if (nowDateTime >= widgetEndDateTime) {
                            skipWidget = true;
                        }
                    }
                }
            }

            if (!skipWidget) {
                /* Only show one widget of type hard coded above. Admission App finder should only show once on a portal even if defined for several apps */
                if (onlyOneWidgetPerPage.containsKey(widget.Widget_Type__c)) {
                    if (onlyOneWidgetPerPage.get(widget.Widget_Type__c) > 0) {
                        skipWidget = true;
                    } else {
                        onlyOneWidgetPerPage.put(widget.Widget_Type__c, onlyOneWidgetPerPage.get(widget.Widget_Type__c) + 1);
                    }
                }

                /* Status filter */
                if (String.isNotBlank(widget.Display_Widget_On_Status__c) && !appInfoParam.appStatus.equalsIgnoreCase('none')) {
                    if (atStatusMap.get(widget.Application_Control__r.URL_Parameter__c) != null) {
                        if (!doesListContainItem(new List<String>(atStatusMap.get(widget.Application_Control__r.URL_Parameter__c)), widget.Display_Widget_On_Status__c.split(';'))) {
                            skipWidget = true;
                        }
                    }
                }

                /* Sub Status filter */
                if (String.isNotBlank(widget.Display_Widget_On_Sub_Status__c) && !appInfoParam.appSubStatus.equalsIgnoreCase('none')) {
                    if (atSubStatusMap.get(widget.Application_Control__r.URL_Parameter__c) != null) {
                        if (!doesListContainItem(new List<String>(atSubStatusMap.get(widget.Application_Control__r.URL_Parameter__c)), widget.Display_Widget_On_Sub_Status__c.split(';'))) {
                            skipWidget = true;
                        }
                    }
                }

                /* Citizenship filter */
                if (String.isNotBlank(widget.Display_Widget_On_Citizenship__c) && String.isNotBlank(appInfoParam.citizenship)) {
                    if (atCitizenshipMap.get(widget.Application_Control__r.URL_Parameter__c) != null) {
                        if (!doesListContainItem(new List<String>(atCitizenshipMap.get(widget.Application_Control__r.URL_Parameter__c)), widget.Display_Widget_On_Citizenship__c.split(';'))) {
                            skipWidget = true;
                        }
                    }
                }

                /* Display on pages filter */
                if (String.isNotBlank(widget.Display_Widget_On_Pages__c) && !skipWidget) {
                    if (!widget.Display_Widget_On_Pages__c.containsIgnoreCase(currentPageName) && !String.isBlank(widget.Display_Widget_On_Pages__c)) {
                        skipWidget = true;
                    }
                }
            }


            if (!skipWidget) {

                switch on widget.Widget_Screen_Location__c.toLowerCase() {
                    when 'left' {
                        foundWidgets.leftWidgets.add(widget);
                    }
                    when 'right' {
                        foundWidgets.rightWidgets.add(widget);
                    }
                    when 'top' {
                        foundWidgets.topWidgets.add(widget);
                    }
                    when 'bottom' {
                        foundWidgets.bottomWidgets.add(widget);
                    }
                    when 'content top' {
                        foundWidgets.contentTopWidgets.add(widget);
                    }
                    when 'content bottom' {
                        foundWidgets.contentBottomWidgets.add(widget);
                    }
                }

            }
        }

        return foundWidgets;
    }


    public Boolean doesListContainItem(List<String> list1, List<String> list2) {
        for (String l : list1) {
            if (list2.contains(l)) {
                return true;
            }
        }
        return false;
    }

    public String getVFPageName() {
        String pageName = ApexPages.currentPage().getUrl();
        pageName = pageName.replaceFirst('/apex/', '');
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
        String[] pageNameExtra = pageName.split('%3F', 0);
        pageName = pageNameExtra[0];
        return pageName;
    }

    public Datetime adjustForTimeZone(Datetime dt, String timezoneString) {
        timezoneString = getTimeZonePick(timezoneString);
        //Get the current GMT time and adjust for our timezone
        //tz = TimeZone.getTimeZone('America/Chicago');
        //Timezone adjustment example below:
        //Datetime NowDate = Datetime.now();
        //NowDate = NowDate.addSeconds(tz.getOffset(NowDate)/1000);
        //Central Daylight Time (America/Chicago)
        TimeZone tz = TimeZone.getTimeZone(timezoneString);
        dt = dt.addSeconds(tz.getOffset(dt) / 1000);
        return dt;
    }

    public String getTimeZonePick(String pickListTimeZone) {
        if (String.isNotBlank(pickListTimeZone)) {
            if (pickListTimeZone.length() > 4) {
                pickListTimeZone = pickListTimeZone.substring(pickListTimeZone.indexOf('(') + 1, pickListTimeZone.indexOf(')'));
                return pickListTimeZone;
            }
        }
        return '';
    }

    public Datetime convertDateToDatetime(Date dateIn, Time timeIn, String timezoneString) {
        if (timeIn == null) {
            timeIn = Time.newInstance(1, 12, 3, 4);
        }
        Datetime converted = Datetime.newInstance(dateIn.year(), dateIn.month(), dateIn.day(), timeIn.hour(), timeIn.minute(), timeIn.second());
        if (String.isNotBlank(timezoneString)) {
            converted = adjustForTimeZone(converted, timezoneString);
        }
        return converted;
    }

}