/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/17/2021.
 */


public with sharing class ApplicationBodyController {

    public EASYApplicationInfo appInfoParam { get; set; }
    public Map<String, EASYApplicationInfo> mapAtAppInfo { get; set; }
    public String currentPageName { get; set; }
    public Boolean noApplication { get; set; }
    public Map<String, EASYPersonalDataTags> dataTagsMap{ get; set; }

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
                'applicationportal'
        };

        Map<String, Integer> onlyOneWidgetPerPage = new Map<String, Integer>{
                'Application Finder' => 0,
                'User Info Login/Logout' => 0,
                'List of Applications' => 0,
                'Application Checklist Multiple' => 0
        };

        Map<String, Set<String>> atStatusMap = new Map<String, Set<String>>();
        Map<String, Set<String>> atSubStatusMap = new Map<String, Set<String>>();
        Map<String, Set<String>> atCitizenshipMap = new Map<String, Set<String>>();
        // create a map of generic filters 1-8
        Map<String, Set<String>> atGenericFilter1Map = new Map<String, Set<String>>();
        Map<String, Set<String>> atGenericFilter2Map = new Map<String, Set<String>>();
        Map<String, Set<String>> atGenericFilter3Map = new Map<String, Set<String>>();
        Map<String, Set<String>> atGenericFilter4Map = new Map<String, Set<String>>();
        Map<String, Set<String>> atGenericFilter5Map = new Map<String, Set<String>>();
        Map<String, Set<String>> atGenericFilter6Map = new Map<String, Set<String>>();
        Map<String, Set<String>> atGenericFilter7Map = new Map<String, Set<String>>();
        Map<String, Set<String>> atGenericFilter8Map = new Map<String, Set<String>>();

        Map<String, Set<String>> atApplicationTypeMap = new Map<String, Set<String>>();

        mapAtAppInfo = new Map<String, EASYApplicationInfo>();
        if (String.isNotBlank(currentPageName)) {
            currentPageName = currentPageName.toLowerCase();
        } else {
            currentPageName = 'applicationhome';
        }
        allWidgets foundWidgets = new allWidgets();
        foundWidgets.topWidgets = new List<EASY_Widget__c>();
        foundWidgets.rightWidgets = new List<EASY_Widget__c>();
        foundWidgets.bottomWidgets = new List<EASY_Widget__c>();
        foundWidgets.leftWidgets = new List<EASY_Widget__c>();
        foundWidgets.contentTopWidgets = new List<EASY_Widget__c>();
        foundWidgets.contentBottomWidgets = new List<EASY_Widget__c>();
        List<EASY_Widget__c> allPositionWidgets = new List<EASY_Widget__c>();
        Map<Id, Application__c> apps = new Map<Id, Application__c>();
        dataTagsMap = new Map<String, EASYPersonalDataTags>();

        if (appInfoParam != null) {
            if (currentPageName.equalsIgnoreCase('applicationregistration')) {
                mapAtAppInfo.put(appInfoParam.at, appInfoParam);
                dataTagsMap.put(appInfoParam.at, new EASYPersonalDataTags());
            } else {
                String appsQuery = ' SELECT Application_Control__r.Id, Application_Control__r.URL_Parameter__c, Application_Status__c, Application_Substatus__c, OwnerId,';
                appsQuery += ' Intended_Term_of_Entry__r.Name, Intended_Program__r.Name, Citizenship__c, Applicant_Banner_Id__c, Id,';
                appsQuery += ' Aquinas_Scholars_Portal_Text__c, Contact__r.Id, Contact_Email__c, Account_Claimed_Portal_Text__c, Documents_Missing_Text__c,';
                appsQuery += ' Contact_Mailing_First_Name__c, Contact__r.LastName, Contact__r.hed__UniversityEmail__c, Intended_Program__r.Program_Name_on_Application__c,';
                appsQuery += ' Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c, Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c, Applicant_Type__c';
                appsQuery += ' FROM Application__c';
                appsQuery += ' WHERE Application_Status__c != \'Wrong Application\'';
                appsQuery += ' AND (NOT(Application_Status__c = \'Withdrawn\' AND Application_Substatus__c = \'Wrong App\'))';
                appsQuery += ' AND (NOT(Application_Status__c = \'Withdrawn\' AND Application_Substatus__c = \'Multiple App\'))';
                appsQuery += ' AND Contact__c IN (SELECT ContactId FROM User WHERE Id = \'' + UserInfo.getUserId() + '\') ';
                if (pagesWithMultipleAppInfo.contains(currentPageName)) {
                    appsQuery += ' AND Contact__c = \'' + appInfoParam.contactId + '\'';
                } else {
                    appsQuery += ' AND Id = \'' + appInfoParam.appId + '\'';
                }

                try {
                    apps = new Map<Id, Application__c>((List<Application__c>) Database.query(appsQuery));
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }

                //Create map of application control URLs and tag data associated with them for processing below.
                for (Application__c app : apps.values()) {

                    EASYPersonalDataTags dataTags = new EASYPersonalDataTags();
                    if (dataTagsMap.containsKey(app.Application_Control__r.URL_Parameter__c)) {
                        //Some tag data will be additive if a person has two apps of the same type. This will become an issue to explain, ugh.
                        dataTags = dataTagsMap.get(app.Application_Control__r.URL_Parameter__c);
                        dataTags.UGAQUSCHLRS = dataTags.UGAQUSCHLRS + '<br/><br/>' + app.Aquinas_Scholars_Portal_Text__c;
                        dataTags.Documents_Missing = dataTags.Documents_Missing + '<br/><br/>' + app.Documents_Missing_Text__c;
                    } else {
                        dataTags.Banner_ID = app.Applicant_Banner_Id__c;
                        dataTags.Contact_Id = app.Contact__r.Id;
                        dataTags.UGAQUSCHLRS = app.Aquinas_Scholars_Portal_Text__c;
                        dataTags.Applicant_Email = app.Contact_Email__c;
                        dataTags.UGAcctClaimTxt = app.Account_Claimed_Portal_Text__c;
                        dataTags.Documents_Missing = app.Documents_Missing_Text__c;
                        dataTags.First_Name = app.Contact_Mailing_First_Name__c;
                        dataTags.Last_Name = app.Contact__r.LastName;
                        dataTags.Portal_University_email = app.Contact__r.hed__UniversityEmail__c;
                        dataTags.LastTranscript = '';
                        dataTags.Course_Pref = '';
                        dataTags.Housing_Pref = '';
                        dataTags.UGFYClass = '';
                        dataTags.Application_ID = app.Id;
                        dataTags.AppOwner_ID = app.OwnerId;
                    }

                    dataTagsMap.put(app.Application_Control__r.URL_Parameter__c, dataTags);

                    //Create appInfo per appControl
                    //Query App Controls
                    Map<Id, Application_Control__c> appControlsByAppIds = new Map<Id, Application_Control__c>([
                            SELECT Id, Hide_Term_Program__c, Application_Start_Status__c, Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c,
                                    Cancel_Status__c, Submit_Status__c, Withdraw_Status__c, URL_Parameter__c, Default__c, Academic_Level__c,
                                    School_College__c, Degree_Levels__c, Template__c, Confirm_Status__c, Allow_Confirm_From__c
                            FROM Application_Control__c
                            WHERE Id IN (
                                    SELECT Application_Control__c
                                    FROM Application__c
                                    WHERE Id = :apps.keySet()
                            )
                    ]);

                    //setApplicationInfo
                    if (!mapAtAppInfo.containsKey(app.Application_Control__r.URL_Parameter__c)) {
                        EASYApplicationInfo tempAppInfo = ApplicationUtilities.setApplicationInfo(appControlsByAppIds.get(app.Application_Control__c), app);
                        if (pagesWithMultipleAppInfo.contains(currentPageName)) {
                            mapAtAppInfo.put(app.Application_Control__r.URL_Parameter__c, tempAppInfo);
                        } else {
                            mapAtAppInfo.put(app.Application_Control__r.URL_Parameter__c, appInfoParam);
                        }
                    }

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

                    /* Filter maps use application at value and apply applicable multi-select data strings to them to parse below */
                    atCitizenshipMap = createFilterMap(app.Citizenship__c, atCitizenshipMap, atURL);
                    atGenericFilter1Map = createFilterMap(app.Generic_Filter_1__c, atGenericFilter1Map, atURL);
                    atGenericFilter2Map = createFilterMap(app.Generic_Filter_2__c, atGenericFilter2Map, atURL);
                    atGenericFilter3Map = createFilterMap(app.Generic_Filter_3__c, atGenericFilter3Map, atURL);
                    atGenericFilter4Map = createFilterMap(app.Generic_Filter_4__c, atGenericFilter4Map, atURL);
                    atGenericFilter5Map = createFilterMap(app.Generic_Filter_5__c, atGenericFilter5Map, atURL);
                    atGenericFilter6Map = createFilterMap(app.Generic_Filter_6__c, atGenericFilter6Map, atURL);
                    atGenericFilter7Map = createFilterMap(app.Generic_Filter_7__c, atGenericFilter7Map, atURL);
                    atGenericFilter8Map = createFilterMap(app.Generic_Filter_8__c, atGenericFilter8Map, atURL);
                    atApplicationTypeMap = createFilterMap(app.Applicant_Type__c, atApplicationTypeMap, atURL);

                }

                if (apps.size() > 0) {
                    noApplication = false;
                } else {
                    mapAtAppInfo.put('noapp', appInfoParam);
                    dataTagsMap.put('noapp', new EASYPersonalDataTags());
                    noApplication = true;
                }
            }

            /* Gather up all the widgets */
            try {
                allPositionWidgets = [
                        SELECT Id, Name, Display_Text__c, Scripts__c, Widget_Screen_Location__c, Display_Heading__c,
                                Widget_Type__c, Sort_Order__c, Display_Widget_On_Pages__c, Display_Widget_On_Status__c,
                                Display_Widget_On_Sub_Status__c, Application_Control__r.URL_Parameter__c, Activation_State__c,
                                Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Widget_Time_Zone__c, Display_Widget_On_Citizenship__c,
                                Only_One_Widget_Key__c, Generic_Filter_1__c, Generic_Filter_2__c, Generic_Filter_3__c, Generic_Filter_4__c,
                                Generic_Filter_5__c, Generic_Filter_6__c, Generic_Filter_7__c, Generic_Filter_8__c,
                                Applicant_Type__c, Button_Code__c
                        FROM EASY_Widget__c
                        WHERE Application_Control__r.URL_Parameter__c IN :mapAtAppInfo.keySet()
                        AND Display_Widget_On_Pages__c INCLUDES (:currentPageName)
                        AND Activation_State__c != 'Inactive'
                        ORDER BY Sort_Order__c
                ];
            } catch (DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }

            Boolean applicationListWidgetPresent = false;
            Boolean applicationChecklistPresent = false;
            if (allPositionWidgets.size() > 0) {
                for (EASY_Widget__c widget : allPositionWidgets) {
                    if (widget.Widget_Type__c.equalsIgnoreCase('Application Checklist')) {
                        applicationChecklistPresent = true;
                    }
                    if (widget.Widget_Type__c.equalsIgnoreCase('List of Applications') || widget.Widget_Type__c.equalsIgnoreCase('Application Checklist Multiple')) {
                        applicationListWidgetPresent = true;
                    }
                }
            }

            if (currentPageName.equalsIgnoreCase('applicationhome') && !applicationChecklistPresent && !noApplication) {
                EASY_Widget__c checklistWidget = new EASY_Widget__c();
                checklistWidget.Name = 'Temp Application Checklist';
                checklistWidget.Widget_Type__c = ('Application Checklist');
                checklistWidget.Application_Control__r = ApplicationUtilities.getApplicationControls(appInfoParam.at);
                checklistWidget.Sort_Order__c = 0;
                checklistWidget.Display_Widget_On_Pages__c = 'ApplicationHome';
                checklistWidget.Activation_State__c = 'Active';
                checklistWidget.Widget_Screen_Location__c = 'Content Top';
                allPositionWidgets.add(checklistWidget);
            }

            if (currentPageName.equalsIgnoreCase('applicationportal') && !applicationListWidgetPresent && !noApplication) {
                EASY_Widget__c checklistWidget = new EASY_Widget__c();
                checklistWidget.Application_Control__r = ApplicationUtilities.getApplicationControls(appInfoParam.at);
                checklistWidget.Activation_State__c = '';
                checklistWidget.Name = 'Temp Application List';
                checklistWidget.Widget_Type__c = 'List of Applications';
                checklistWidget.Sort_Order__c = 0;
                checklistWidget.Display_Widget_On_Pages__c = 'ApplicationPortal';
                checklistWidget.Activation_State__c = 'Active';
                checklistWidget.Widget_Screen_Location__c = 'Content Top';
                allPositionWidgets.add(checklistWidget);
            }

            /* Start/End date filter if defined */
            for (EASY_Widget__c widget : allPositionWidgets) {

                String skipReason = '';
                Boolean skipWidget = false;

                if (widget.Activation_State__c.equalsIgnoreCase('Date activated')) {
                    Datetime nowDateTime = ApplicationUtilities.adjustForTimeZone(Datetime.now(), widget.Widget_Time_Zone__c);
                    if (String.isNotBlank(widget.Widget_Time_Zone__c)) {
                        if (!skipWidget && widget.Start_Date__c != null && widget.Start_Time__c != null) {
                            Datetime widgetStartDateTime = ApplicationUtilities.convertDateToDatetime(widget.Start_Date__c, widget.Start_Time__c, null);
                            if (nowDateTime <= widgetStartDateTime) {
                                skipWidget = true;
                                //skipReason += 'DateTime, ';
                            }
                        }
                        if (!skipWidget && widget.End_Date__c != null && widget.End_Time__c != null) {
                            Datetime widgetEndDateTime = ApplicationUtilities.convertDateToDatetime(widget.End_Date__c, widget.End_Time__c, null);
                            if (nowDateTime >= widgetEndDateTime) {
                                skipWidget = true;
                                //skipReason += 'DateTime, ';
                            }
                        }
                    }
                }

                if (!skipWidget) {
                    /* Only show one widget of type hard coded above. Admission App finder should only show once on a portal even if defined for several apps */

                    if (!skipWidget && onlyOneWidgetPerPage.containsKey(widget.Widget_Type__c)) {
                        if (onlyOneWidgetPerPage.get(widget.Widget_Type__c) > 0) {
                            skipWidget = true;
                            skipReason += 'One widget hardcoded, ';
                        } else {
                            onlyOneWidgetPerPage.put(widget.Widget_Type__c, onlyOneWidgetPerPage.get(widget.Widget_Type__c) + 1);
                        }
                    }

                    if (!skipWidget && String.isNotBlank(widget.Only_One_Widget_Key__c)) {
                        if (onlyOneWidgetPerPage.containsKey(widget.Only_One_Widget_Key__c)) {
                            skipWidget = true;
                            skipReason += 'One widget key, ';
                        } else {
                            onlyOneWidgetPerPage.put(widget.Only_One_Widget_Key__c, 1);
                        }
                    }

                    if (!skipWidget && String.isNotBlank(widget.Application_Control__r.URL_Parameter__c)) {

                        String widgetUrlParam = widget.Application_Control__r.URL_Parameter__c;
                        String widgetStatus = String.isNotBlank(widget.Display_Widget_On_Status__c) ? widget.Display_Widget_On_Status__c : '';
                        String widgetSubStatus = String.isNotBlank(widget.Display_Widget_On_Sub_Status__c) ? widget.Display_Widget_On_Sub_Status__c : '';
                        String widgetCitizen = String.isNotBlank(widget.Display_Widget_On_Citizenship__c) ? widget.Display_Widget_On_Citizenship__c : '';
                        String genericFilter1 = String.isNotBlank(widget.Generic_Filter_1__c) ? widget.Generic_Filter_1__c : '';
                        String genericFilter2 = String.isNotBlank(widget.Generic_Filter_2__c) ? widget.Generic_Filter_2__c : '';
                        String genericFilter3 = String.isNotBlank(widget.Generic_Filter_3__c) ? widget.Generic_Filter_3__c : '';
                        String genericFilter4 = String.isNotBlank(widget.Generic_Filter_4__c) ? widget.Generic_Filter_4__c : '';
                        String genericFilter5 = String.isNotBlank(widget.Generic_Filter_5__c) ? widget.Generic_Filter_5__c : '';
                        String genericFilter6 = String.isNotBlank(widget.Generic_Filter_6__c) ? widget.Generic_Filter_6__c : '';
                        String genericFilter7 = String.isNotBlank(widget.Generic_Filter_7__c) ? widget.Generic_Filter_7__c : '';
                        String genericFilter8 = String.isNotBlank(widget.Generic_Filter_8__c) ? widget.Generic_Filter_8__c : '';
                        String widgetApplicantType = String.isNotBlank(widget.Applicant_Type__c) ? widget.Applicant_Type__c : '';

                        EASYApplicationInfo widgetAppInfo = mapAtAppInfo.get(widgetUrlParam);

                        /* Display on pages filter */
                        if (!skipWidget && String.isNotBlank(widget.Display_Widget_On_Pages__c)) {
                            if (!widget.Display_Widget_On_Pages__c.containsIgnoreCase(currentPageName) && !String.isBlank(widget.Display_Widget_On_Pages__c)) {
                                skipWidget = true;
                                //skipReason += 'Wrong Page, ';
                            }
                        }

                        if (!skipWidget && String.isNotBlank(widgetStatus) && String.isBlank(widgetSubStatus)) {
                            if (String.isBlank(widgetAppInfo.appStatus)) {
                                skipWidget = true;
                                skipReason += 'App Status on app is blank, but widget has one, ';
                            } else {
                                if (!doesListContainItem(widgetStatus.split(';'), widgetAppInfo.appStatus.split(';'))) {
                                    skipWidget = true;
                                    //skipReason += 'status not met, ';
                                }
                            }
                        }

                        /* Sub Status filter */
                        if (!skipWidget && String.isNotBlank(widgetStatus) && String.isNotBlank(widgetSubStatus)) {
                            if (String.isBlank(widgetAppInfo.appSubStatus)) {
                                skipWidget = true;
                                skipReason += 'App substatus on app is blank but widget has one, ';
                            } else {
                                if (!doesListContainItem(widgetSubStatus.split(';'), widgetAppInfo.appSubStatus.split(';'))) {
                                    skipWidget = true;
                                    //skipReason += 'substatus not met, ';
                                }
                            }
                        }

                        /* Citizenship filter */
                        if (!skipWidget && String.isNotBlank(widgetCitizen)) {
                            if (String.isNotBlank(widgetAppInfo.citizenship)) {
                                if (!doesListContainItem(widgetCitizen.split(';'), widgetAppInfo.citizenship.split(';'))) {
                                    skipWidget = true;
                                    //skipReason += 'citizenship status not met, ';
                                }
                            }
                        }

                        /* Generic filter 1 */
                        skipWidget = filterWidget(skipWidget, atGenericFilter1Map, genericFilter1, widgetUrlParam);

                        /* Generic filter 2 */
                        skipWidget = filterWidget(skipWidget, atGenericFilter2Map, genericFilter2, widgetUrlParam);

                        /* Generic filter 3 */
                        skipWidget = filterWidget(skipWidget, atGenericFilter3Map, genericFilter3, widgetUrlParam);

                        /* Generic filter 4 */
                        skipWidget = filterWidget(skipWidget, atGenericFilter4Map, genericFilter4, widgetUrlParam);

                        /* Generic filter 5 */
                        skipWidget = filterWidget(skipWidget, atGenericFilter5Map, genericFilter5, widgetUrlParam);

                        /* Generic filter 6 */
                        skipWidget = filterWidget(skipWidget, atGenericFilter6Map, genericFilter6, widgetUrlParam);

                        /* Generic filter 7 */
                        skipWidget = filterWidget(skipWidget, atGenericFilter7Map, genericFilter7, widgetUrlParam);

                        /* Generic filter 8 */
                        skipWidget = filterWidget(skipWidget, atGenericFilter8Map, genericFilter8, widgetUrlParam);

                        /* Applicant Type filter */
                        skipWidget = filterWidget(skipWidget, atApplicationTypeMap, widgetApplicantType, widgetUrlParam);

                    }
                }


                if (!skipWidget) {

                    //Process data tags here
                    if (dataTagsMap.containsKey(widget.Application_Control__r.URL_Parameter__c)) {
                        if (String.isNotBlank(widget.Display_Text__c)) {
                            widget.Display_Text__c = ApplicationUtilities.replaceDataTags(widget.Display_Text__c, dataTagsMap.get(widget.Application_Control__r.URL_Parameter__c));
                        }
                        if (String.isNotBlank(widget.Display_Heading__c)) {
                            widget.Display_Heading__c = ApplicationUtilities.replaceDataTags(widget.Display_Heading__c, dataTagsMap.get(widget.Application_Control__r.URL_Parameter__c));
                        }
                        if (String.isNotBlank(widget.Scripts__c)) {
                            widget.Scripts__c = ApplicationUtilities.replaceDataTags(widget.Scripts__c, dataTagsMap.get(widget.Application_Control__r.URL_Parameter__c));
                        }
                    }
                }

                //If it is a custom widget and there is nothing in the widget don't show it
                if (!skipWidget && widget.Widget_Type__c.equalsIgnoreCase('custom')) {
                    if (String.isBlank(removeHTML(widget.Display_Heading__c)) && String.isBlank(removeHTML(widget.Display_Text__c)) && String.isBlank(widget.Scripts__c)) {
                        skipWidget = true;
                        //skipReason += 'Blank content on custom, ';
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
        }

        return foundWidgets;
    }

    public Boolean filterWidget(Boolean skipWidget, Map<String, Set<String>> filterMap, String filterString, String widgetUrlParam) {

        if (!skipWidget) {
            if (String.isNotBlank(filterString)) {
                if (filterMap.isEmpty()) {
                    return true;
                }
                if (filterMap.containsKey(widgetUrlParam)) {
                    if (!doesListContainItem(filterString.split(';'), new List<String>(filterMap.get(widgetUrlParam)))) {
                        return true;
                    }
                }
            }
        }
        return skipWidget;
    }

    public Map<String, Set<String>> createFilterMap(String filterValue, Map<String, Set<String>> filterMap, String atURL) {
        if (String.isNotBlank(filterValue)) {
            List<String> filterMapList = filterValue.split(';');
            //Change filterMapList to a set
            Set<String> filterMapSet = new Set<String>(filterMapList);
            if (filterMap.containsKey(atURL)) {
                filterMap.get(atURL).addAll(filterMapSet);
            } else {
                filterMap.put(atURL,
                        filterMapSet
                );
            }
        }
        return filterMap;
    }

    public Boolean doesListContainItem(List<String> list1, List<String> list2) {
        for (String l : list1) {
            if (String.isNotBlank(l)) {
                if (list2.contains(l)) {
                    return true;
                }
            }
        }
        return false;
    }

    public String removeHTML(String q) {
        if (String.isNotBlank(q)) {
            q = q.replaceAll('<[^>]+>', '').trim();
        }
        return q;
    }

}