/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/3/2022.
 * Last Modified By: nicole.b@digitalmass.com 07/13/2022
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
        
        Contact student = new Contact(LastName = 'TestStudent');
        insert student;

        List<Application__c> apps = new List<Application__c>();
        Application__c app = new Application__c(
            Contact__c = student.Id, 
            Application_Status__c = Application__c.Application_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Application_Control__c = appControl.Id,
            Application_Substatus__c = 'Hold',
            Citizenship__c = 'U.S. Citizen'
        );
        apps.add(app);

        Application__c app2 = new Application__c(
            Contact__c = student.Id, 
            Application_Status__c = Application__c.Application_Status__c.getDescribe().getPicklistValues()[0].getValue(),
            Application_Control__c = appControl.Id,
            Application_Substatus__c = 'Hold',
            Citizenship__c = 'U.S. Citizen'
        );
        apps.add(app2);

        insert apps;

        List<EASY_Widget__c> widgets = new List<EASY_Widget__c>();
        EASY_Widget__c topWidget = new EASY_Widget__c(
            Name = 'Test Top Widget',
            Widget_Screen_Location__c = 'Top',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id,
            Activation_State__c = 'Active',
            Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(topWidget);

        EASY_Widget__c topWidget2 = new EASY_Widget__c(
            Name = 'Test Top Widget 2',
            Widget_Screen_Location__c = 'Top',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id,
            Activation_State__c = 'Date Activated',
            Display_Widget_On_Pages__c = 'ApplicationPortal',
            Widget_Time_Zone__c = 'Central Daylight Time (America/Chicago)',
            Start_Date__c = System.today().addDays(1),
            Start_Time__c = System.now().time(),
            End_Date__c = System.today().addDays(20),
            End_Time__c = System.now().time().addHours(20)
        );
        widgets.add(topWidget2);

        EASY_Widget__c bottomWidget = new EASY_Widget__c(
            Name = 'Test Bottom Widget',
            Widget_Screen_Location__c = 'Bottom',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id,
            Activation_State__c = 'Active',
            Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(bottomWidget);

        EASY_Widget__c leftWidget = new EASY_Widget__c(
            Name = 'Test Left Widget',
            Widget_Screen_Location__c = 'Left',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id,
            Activation_State__c = 'Active',
            Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(leftWidget);

        EASY_Widget__c rightWidget = new EASY_Widget__c(
            Name = 'Test Right Widget',
            Widget_Screen_Location__c = 'Right',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id,
            Activation_State__c = 'Active',
            Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(rightWidget);

        EASY_Widget__c contentTopWidget = new EASY_Widget__c(
            Name = 'Test Content Top Widget',
            Widget_Screen_Location__c = 'Content Top',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id,
            Activation_State__c = 'Active',
            Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(contentTopWidget);

        EASY_Widget__c contentTopWidget2 = new EASY_Widget__c(
            Name = 'Test Content Top Widget',
            Widget_Screen_Location__c = 'Content Top',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id,
            Activation_State__c = 'Active',
            Display_Widget_On_Pages__c = 'ApplicationPortal',
            Display_Widget_On_Citizenship__c = 'U.S. Dual Citizen'
        );
        widgets.add(contentTopWidget2);

        EASY_Widget__c contentBottomWidget = new EASY_Widget__c(
            Name = 'Test Content Bottom Widget',
            Widget_Screen_Location__c = 'Content Bottom',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id,
            Activation_State__c = 'Active',
            Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(contentBottomWidget);

        EASY_Widget__c contentBottomWidget2 = new EASY_Widget__c(
            Name = 'Test Content Bottom Widget',
            Widget_Screen_Location__c = 'Content Bottom',
            Widget_Type__c = 'Custom',
            Application_Control__c = appControl.Id,
            Activation_State__c = 'Active',
            Display_Widget_On_Pages__c = 'ApplicationPortal',
            Display_Widget_On_Status__c = 'Submitted App'
        );
        widgets.add(contentBottomWidget2);

        insert widgets;
    }

    @isTest 
    public static void testGetWidgets() {
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        PageReference pr = new PageReference('/apex/ApplicationPortal');
        pr.getParameters().put('contactId', student.Id);
        pr.getParameters().put('applicationId', app.Id);
        pr.getParameters().put('at', 'st');

        Test.setCurrentPage(pr);

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appControlId = appControl.Id;
        appInfo.contactId = student.Id;
        appInfo.citizenship = 'U.S. Citizen';

        ApplicationBodyController controller = new ApplicationBodyController();
        controller.appInfoParam = appInfo;
        controller.currentPageName = 'TestPageName';

        Test.startTest();
        ApplicationBodyController.allWidgets allWidgets = controller.getWidgets();
        Test.stopTest();

        System.assertEquals(1, allWidgets.topWidgets.size());
        System.assertEquals(1, allWidgets.rightWidgets.size());
        System.assertEquals(1, allWidgets.bottomWidgets.size());
        System.assertEquals(1, allWidgets.leftWidgets.size());
        System.assertEquals(1, allWidgets.contentTopWidgets.size());
        System.assertEquals(2, allWidgets.contentBottomWidgets.size());
    }
}