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
                'applicationportal'
        };

        Map<String, Integer> onlyOneWidgetPerPage = new Map<String, Integer>{
                'Application Finder' => 0,
                'User Info Login/Logout' => 0
        };

        Set<Id> appInfoIds = new Set<Id>();
        Map<String, Set<String>> atStatusMap = new Map<String, Set<String>>();
        Map<String, Set<String>> atSubStatusMap = new Map<String, Set<String>>();
        Map<String, Set<String>> atCitizenshipMap = new Map<String, Set<String>>();
        currentPageName = currentPageName.toLowerCase();
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

        List<Application__c> apps = new List<Application__c>();
        Map<String, EASYPersonalDataTags> dataTagsMap = new Map<String, EASYPersonalDataTags>();
        if (String.isNotBlank(appInfoParam.contactId)) {
            if (pagesWithMultipleAppInfo.contains(currentPageName)) {
                apps = [
                        SELECT Application_Control__r.Id, Application_Control__r.URL_Parameter__c, Application_Status__c, Application_Substatus__c,
                                Intended_Term_of_Entry__r.Name, Intended_Program__r.Name, Citizenship__c, Applicant_Banner_Id__c,
                                Aquinas_Scholars_Portal_Text__c, Contact_Email__c, Account_Claimed_Portal_Text__c, Documents_Missing_Text__c
                        FROM Application__c
                        WHERE Contact__c = :appInfoParam.contactId
                        AND Application_Status__c != 'Wrong Application'
                ];
            } else {
                apps = [
                        SELECT Application_Control__r.Id, Application_Control__r.URL_Parameter__c, Application_Status__c, Application_Substatus__c,
                                Intended_Term_of_Entry__r.Name, Intended_Program__r.Name, Citizenship__c, Applicant_Banner_Id__c,
                                Aquinas_Scholars_Portal_Text__c, Contact_Email__c, Account_Claimed_Portal_Text__c, Documents_Missing_Text__c
                        FROM Application__c
                        WHERE Id = :appInfoParam.appId
                        AND Application_Status__c != 'Wrong Application'
                ];
            }

            //Create map of application control URLs and tag data associated with them for processing below.
            for (Application__c app : apps) {
                EASYPersonalDataTags dataTags = new EASYPersonalDataTags();
                if (dataTagsMap.containsKey(app.Application_Control__r.URL_Parameter__c)) {
                    //Some tag data will be additive if a person has two apps of the same type. This will become an issue to explain, ugh.
                    dataTags = dataTagsMap.get(app.Application_Control__r.URL_Parameter__c);
                    dataTags.UGAQUSCHLRS = dataTags.UGAQUSCHLRS + ', ' + app.Aquinas_Scholars_Portal_Text__c;
                    dataTags.UGAcctClaimTxt = dataTags.UGAcctClaimTxt + ', ' + app.Account_Claimed_Portal_Text__c;
                } else {
                    dataTags.Banner_ID = app.Applicant_Banner_Id__c;
                    dataTags.UGAQUSCHLRS = app.Aquinas_Scholars_Portal_Text__c;
                    dataTags.Applicant_Email = app.Contact_Email__c;
                    dataTags.UGAcctClaimTxt = app.Account_Claimed_Portal_Text__c;
                }
                dataTagsMap.put(app.Application_Control__r.URL_Parameter__c, dataTags);
            }

        }

        /* Some pages may have multiple app contexts */
        if (pagesWithMultipleAppInfo.contains(currentPageName)) {
            for (Application__c app : apps) {
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
                            Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Widget_Time_Zone__c, Display_Widget_On_Citizenship__c,
                            Only_One_Widget_Key__c
                    FROM EASY_Widget__c
                    WHERE Application_Control__c IN :appInfoIds
                    AND Display_Widget_On_Pages__c INCLUDES (:currentPageName)
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
                Datetime nowDateTime = ApplicationUtilities.adjustForTimeZone(Datetime.now(), widget.Widget_Time_Zone__c);
                if (String.isNotBlank(widget.Widget_Time_Zone__c)) {
                    if (widget.Start_Date__c != null && widget.Start_Time__c != null) {
                        Datetime widgetStartDateTime = ApplicationUtilities.convertDateToDatetime(widget.Start_Date__c, widget.Start_Time__c, null);
                        if (nowDateTime <= widgetStartDateTime) {
                            skipWidget = true;
                        }
                    }
                    if (widget.End_Date__c != null && widget.End_Time__c != null) {
                        Datetime widgetEndDateTime = ApplicationUtilities.convertDateToDatetime(widget.End_Date__c, widget.End_Time__c, null);
                        if (nowDateTime >= widgetEndDateTime) {
                            skipWidget = true;
                        }
                    }
                }
            }

            //If it is a custom widget and there is nothing in the widget don't show it
            if (widget.Widget_Type__c.equalsIgnoreCase('custom')) {
                if (String.isBlank(removeHTML(widget.Display_Heading__c)) && String.isBlank(removeHTML(widget.Display_Text__c)) && String.isBlank(widget.Scripts__c)) {
                    skipWidget = true;
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

                if (String.isNotBlank(widget.Only_One_Widget_Key__c) & !skipWidget) {
                    if (onlyOneWidgetPerPage.containsKey(widget.Only_One_Widget_Key__c)) {
                        skipWidget = true;
                    } else {
                        onlyOneWidgetPerPage.put(widget.Only_One_Widget_Key__c, 1);
                    }
                }

                if (!skipWidget && String.isNotBlank(widget.Application_Control__r.URL_Parameter__c)) {

                    String widgetUrlParam = widget.Application_Control__r.URL_Parameter__c;
                    String widgetStatus = String.isNotBlank(widget.Display_Widget_On_Status__c) ? widget.Display_Widget_On_Status__c : '';
                    String widgetSubStatus = String.isNotBlank(widget.Display_Widget_On_Sub_Status__c) ? widget.Display_Widget_On_Sub_Status__c : '';
                    String widgetCitizen = String.isNotBlank(widget.Display_Widget_On_Citizenship__c) ? widget.Display_Widget_On_Citizenship__c : '';

                    if (String.isNotBlank(widgetStatus) && String.isBlank(widgetSubStatus)) {
                        if (atStatusMap.get(widgetUrlParam) == null) {
                            skipWidget = true;
                        } else {
                            if (!doesListContainItem(new List<String>(atStatusMap.get(widgetUrlParam)), widgetStatus.split(';'))) {
                                skipWidget = true;
                            }
                        }
                    }

                    /* Sub Status filter */
                    if (String.isNotBlank(widgetStatus) && String.isNotBlank(widgetSubStatus) && !skipWidget) {
                        if (atSubStatusMap.get(widgetUrlParam) == null) {
                            skipWidget = true;
                        } else {
                            if (!doesListContainItem(new List<String>(atSubStatusMap.get(widgetUrlParam)), widgetSubStatus.split(';'))) {
                                skipWidget = true;
                            }
                        }
                    }

                    /* Citizenship filter */
                    if (String.isNotBlank(widgetCitizen)) {
                        if (atCitizenshipMap.get(widgetUrlParam) != null) {
                            if (!doesListContainItem(new List<String>(atCitizenshipMap.get(widgetUrlParam)), widgetCitizen.split(';'))) {
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
            }


            if (!skipWidget) {

                //Process data tags here
                if (dataTagsMap.containsKey(widget.Application_Control__r.URL_Parameter__c)) {
                    if (String.isNotBlank(widget.Display_Text__c)) {
                        widget.Display_Text__c = replaceDataTags(widget.Display_Text__c, dataTagsMap.get(widget.Application_Control__r.URL_Parameter__c));
                    }
                    if (String.isNotBlank(widget.Display_Heading__c)) {
                        widget.Display_Heading__c = replaceDataTags(widget.Display_Heading__c, dataTagsMap.get(widget.Application_Control__r.URL_Parameter__c));
                    }
                }

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

    public String replaceDataTags(String widgetContent, EASYPersonalDataTags tagWrapper) {
        //widgetContent = 'This is a {{Banner <strong>Id</strong>}} in the middle of something. {<strong>{Nothing here</strong>}}. asdfsdfa {{Banner Id}}. Then what if you find a tag like {{This one<strong>}</strong>}';

        //Serialize EASYPersonalDataTags data so we can get field names and retrieve with get method
        Map<String, Object> tagMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(tagWrapper));

        //Create lower/uppercase of EASYPersonalDataTags fields so that we can find them case insensitive
        Map<String, String> lowerCaseUppercaseTagMap = new Map<String, String>();
        for (String k : tagMap.keySet()) {
            lowerCaseUppercaseTagMap.put(k.toLowerCase(), k);
        }

        //Get all tags in content that start with {{ and end with }} even if interrupted with html
        Pattern tagPattern = Pattern.compile('\\{.(.*?)\\}(.*?|)[\\}\\s]');
        Matcher tagMatcher = tagPattern.matcher(widgetContent);
        Set<String> matchingTags = new Set<String>();
        while (tagMatcher.find()) {
            matchingTags.add(tagMatcher.group().trim());
        }

        //Loop through tag matches set to sanitize and replace all
        for (String tag : matchingTags) {

            //Remove all HTML elements from the tag to avoid things like this {<em>{</em>Tag}}
            String tab_data = tag.replaceAll('<[^>]*>', '');

            //Remove tag delineators to get at data identifier
            tab_data = tab_data.removeStart('{{');
            tab_data = tab_data.removeEnd('}}');
            tab_data = tab_data.trim();

            //Add underscore to space in so that user can be agnostic of the need
            tab_data = tab_data.replace(' ', '_');

            //Find if lowercase version of tag is in our map of lower/uppercase tags and use uppercase to grab data
            if (lowerCaseUppercaseTagMap.keySet().contains(tab_data.toLowerCase())) {
                String caseSensitiveTag = lowerCaseUppercaseTagMap.get(tab_data.toLowerCase());

                //If the value is blank we want to replace tag with an empty string
                String valueForTag = String.isNotBlank((String) tagMap.get(caseSensitiveTag)) ? (String) tagMap.get(caseSensitiveTag) : '' ;

                //Replace the original tag (as it may contain html,ect, with the found value)
                widgetContent = widgetContent.replace(tag, valueForTag);
            }
        }

        return widgetContent;
    }


    public Boolean doesListContainItem(List<String> list1, List<String> list2) {
        for (String l : list1) {
            if (list2.contains(l)) {
                return true;
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