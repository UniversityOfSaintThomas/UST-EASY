/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/17/2021.
 */


public with sharing class ApplicationBodyController {

    public Application_Control__c applicationControlValue { set; get; }
    public String applicationIdValue { get; set; }
    public Id appContactId { get; set; }

    public ApplicationBodyController() {
    }

    public class allWidgets {
        public List<EASY_Widget__c> topWidgets { get; set; }
        public List<EASY_Widget__c> rightWidgets { get; set; }
        public List<EASY_Widget__c> bottomWidgets { get; set; }
        public List<EASY_Widget__c> leftWidgets { get; set; }
    }

    public allWidgets getWidgets() {
        allWidgets foundWidgets = new allWidgets();
        foundWidgets.topWidgets = new List<EASY_Widget__c>();
        foundWidgets.rightWidgets = new List<EASY_Widget__c>();
        foundWidgets.bottomWidgets = new List<EASY_Widget__c>();
        foundWidgets.leftWidgets = new List<EASY_Widget__c>();
        List<EASY_Widget__c> allPositionWidgets = new List<EASY_Widget__c>();

        if (String.isNotBlank(applicationControlValue.Id)) {
            try {
                allPositionWidgets = [
                        SELECT Id, Name, Display_Text__c, Scripts__c, Widget_Screen_Location__c, Display_Heading__c,
                                Widget_Type__c, Sort_Order__c
                        FROM EASY_Widget__c
                        WHERE Application_Control__c = :applicationControlValue.Id
                        WITH SECURITY_ENFORCED
                        ORDER BY Sort_Order__c
                ];
            } catch (DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }


            for (EASY_Widget__c widget : allPositionWidgets) {
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
                }
            }
        }
        return foundWidgets;
    }


}