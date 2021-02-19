/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/17/2021.
 */


public with sharing class ApplicationBodyController {

    public Application_Control__c applicationControlValue { get; set; }
    public List<EASY_Widget__c> allWidgets { get; set; }
    public List<EASY_Widget__c> rightWidgets { get; set; }
    public List<EASY_Widget__c> leftWidgets { get; set; }
    public List<EASY_Widget__c> topWidgets { get; set; }
    public List<EASY_Widget__c> bottomWidgets { get; set; }
    public Boolean init {
        get {
            getWidgets();
            return false;
        }
    }


    public ApplicationBodyController() {
    }

    public void getWidgets() {
        allWidgets = new List<EASY_Widget__c>();
        rightWidgets = new List<EASY_Widget__c>();
        leftWidgets = new List<EASY_Widget__c>();
        topWidgets = new List<EASY_Widget__c>();
        bottomWidgets = new List<EASY_Widget__c>();

        if (String.isNotBlank(applicationControlValue.Id)) {

            try {
                allWidgets = [
                        SELECT
                                Id, Name, Display_Text__c, Scripts__c, Widget_Screen_Location__c
                        FROM EASY_Widget__c
                        WHERE Application_Control__c = :applicationControlValue.Id
                        WITH SECURITY_ENFORCED
                ];
            } catch (DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDMLMessage(0)));
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            }


            for (EASY_Widget__c widget : allWidgets) {
                switch on widget.Widget_Screen_Location__c {
                    when 'left' {
                        leftWidgets.add(widget);
                    }
                    when 'right' {
                        rightWidgets.add(widget);
                    }
                    when 'top' {
                        topWidgets.add(widget);
                    }
                    when 'bottom' {
                        bottomWidgets.add(widget);
                    }
                }
            }
        }
    }

}