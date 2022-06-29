/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/17/2021.
 */


public with sharing class ApplicationBodyController {

    public EASYApplicationInfo appInfoParam { get; set; }
    public String currentPageName { get; set; }
    public String appStatusAttribute { get; set; }

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
                'ApplicationPortal',
                'ApplicationCreate',
                'ApplicationRegistration'
        };
        Set<Id> appInfoIds = new Set<Id>();
        currentPageName = getVFPageName();
        allWidgets foundWidgets = new allWidgets();
        foundWidgets.topWidgets = new List<EASY_Widget__c>();
        foundWidgets.rightWidgets = new List<EASY_Widget__c>();
        foundWidgets.bottomWidgets = new List<EASY_Widget__c>();
        foundWidgets.leftWidgets = new List<EASY_Widget__c>();
        foundWidgets.contentTopWidgets = new List<EASY_Widget__c>();
        foundWidgets.contentBottomWidgets = new List<EASY_Widget__c>();
        List<EASY_Widget__c> allPositionWidgets = new List<EASY_Widget__c>();
        if (String.isBlank(appStatusAttribute)) {
            appStatusAttribute = 'none';
        }

        // if (appInfoParam.appControl != null && String.isNotBlank(appInfoParam.appControlId)) {
        if (pagesWithMultipleAppInfo.contains(currentPageName)) {
            for (Application__c app : [
                    SELECT Application_Control__r.Id
                    FROM Application__c
                    WHERE contact__c = :appInfoParam.contactId
            ]) {
                appInfoIds.add(app.Application_Control__r.Id);
            }
            System.debug(appInfoIds);
        } else {
            appInfoIds.add(appInfoParam.appControlId);
        }

        try {
            allPositionWidgets = [
                    SELECT Id, Name, Display_Text__c, Scripts__c, Widget_Screen_Location__c, Display_Heading__c,
                            Widget_Type__c, Sort_Order__c, Display_Widget_On_Pages__c, Display_Widget_On_Status__c
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

        for (EASY_Widget__c widget : allPositionWidgets) {
            Boolean skipWidget = false;
            if (String.isNotBlank(widget.Display_Widget_On_Status__c) && !appStatusAttribute.equalsIgnoreCase('none')) {
                if (!widget.Display_Widget_On_Pages__c.containsIgnoreCase(currentPageName)) {
                    skipWidget = true;
                }
            }
            if (!widget.Display_Widget_On_Pages__c.containsIgnoreCase(currentPageName) && !String.isBlank(widget.Display_Widget_On_Pages__c)) {
                skipWidget = true;
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
                        foundWidgets.contentTopWidgets.add(widget);
                    }
                }

            }
        }
        //  }
        return foundWidgets;
    }

    public string getVFPageName() {
        String pageName = ApexPages.CurrentPage().getUrl();
        pageName = pageName.replaceFirst('/apex/', '');
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
        string[] pageNameExtra = pageName.split('%3F', 0);
        pageName = pageNameExtra[0];
        return pageName;
    }

}