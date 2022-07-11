/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/3/2022.
 */
@IsTest
public class ApplicationBodyController_TEST {
    @TestSetup
    public static void testSetup() {
        Application_Control__c appControl = new Application_Control__c(
            Application_Start_Status__c = Application_Control__c.Application_Start_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Active__c = true,
            Allow_Cancel_From__c = Application_Control__c.Allow_Cancel_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Allow_Withdraw_From__c = Application_Control__c.Allow_Withdraw_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Allow_Submit_From__c = Application_Control__c.Allow_Submit_From__c.getDescribe().getPicklistValues()[0].getValue(),
            Cancel_Status__c = Application_Control__c.Cancel_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Default__c = true,
            URL_Parameter__c = 'st',
            Submit_Status__c = Application_Control__c.Submit_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Withdraw_Status__c = Application_Control__c.Withdraw_Status__c.getDescribe().getPicklistValues()[0].getValue()
        );
        insert appControl;

        List<EASY_Widget__c> widgets = new List<EASY_Widget__c>();
        EASY_Widget__c topWidget = new EASY_Widget__c(
            Name = 'Test Top Widget',
            Widget_Screen_Location__c = 'Top',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id
        );
        widgets.add(topWidget);

        List<EASY_Widget__c> widgets = new List<EASY_Widget__c>();
        EASY_Widget__c bottomWidget = new EASY_Widget__c(
            Name = 'Test Bottom Widget',
            Widget_Screen_Location__c = 'Bottom',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id
        );
        widgets.add(bottomWidget);

        List<EASY_Widget__c> widgets = new List<EASY_Widget__c>();
        EASY_Widget__c leftWidget = new EASY_Widget__c(
            Name = 'Test Left Widget',
            Widget_Screen_Location__c = 'Left',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id
        );
        widgets.add(leftWidget);

        List<EASY_Widget__c> widgets = new List<EASY_Widget__c>();
        EASY_Widget__c rightWidget = new EASY_Widget__c(
            Name = 'Test Right Widget',
            Widget_Screen_Location__c = 'Right',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id
        );
        widgets.add(rightWidget);

        List<EASY_Widget__c> widgets = new List<EASY_Widget__c>();
        EASY_Widget__c contentTopWidget = new EASY_Widget__c(
            Name = 'Test Content Top Widget',
            Widget_Screen_Location__c = 'Content Top',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id
        );
        widgets.add(contentTopWidget);

        List<EASY_Widget__c> widgets = new List<EASY_Widget__c>();
        EASY_Widget__c contentBottomWidget = new EASY_Widget__c(
            Name = 'Test Content Bottom Widget',
            Widget_Screen_Location__c = 'Content Bottom',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id
        );
        widgets.add(contentBottomWidget);

        insert widgets;
    }

    @isTest 
    pubclis static void testGetWidgets() {
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];

        EASYApplicationInfo appInfo = new EASYApplicationInfo(
            appControlId = appControl.Id,
            appControl = appControl
        );

        ApplicationBodyController controller = new ApplicationBodyController(
            appInfoParam = appInfo,
            currentPageName = 'TestPageName',
            skipWidgetsPages = false
        );

        Test.startTest();
        ApplicationBodyController.allWidgets allWidgets = controller.getWidgets();
        Test.stopTest();

        System.assertEquals(1, allWidgets.topWidgets.size());
        System.assertEquals(1, allWidgets.rightWidgets.size());
        System.assertEquals(1, allWidgets.bottomWidgets.size());
        System.assertEquals(1, allWidgets.leftWidgets.size());
        System.assertEquals(1, allWidgets.contentTopWidgets.size());
        System.assertEquals(1, allWidgets.contentBottomWidgets.size());
    }