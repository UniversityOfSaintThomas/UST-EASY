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

        Contact student = new Contact(LastName = 'TestStudent', FirstName = 'TestFirst', Email = 'test@email.com', University_Banner_ID__c = '111111111');
        insert student;

        Opportunity opp = new Opportunity(
                Contact__c = student.id,
                Name = student.LastName + '||',
                StageName = 'Started App',
                CloseDate = Date.today().addDays(30)
        );
        insert opp;

        List<Application__c> apps = new List<Application__c>();
        Application__c app = new Application__c(
                Contact__c = student.Id,
                Application_Status__c = Application__c.Application_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Application_Control__c = appControl.Id,
                Citizenship__c = 'U.S. Citizen',
                Generic_Filter_1__c = Application__c.Generic_Filter_1__c.getDescribe().getPicklistValues()[0].getValue(),
                Generic_Filter_2__c = Application__c.Generic_Filter_2__c.getDescribe().getPicklistValues()[0].getValue(),
                Generic_Filter_3__c = Application__c.Generic_Filter_3__c.getDescribe().getPicklistValues()[0].getValue(),
                Generic_Filter_4__c = Application__c.Generic_Filter_4__c.getDescribe().getPicklistValues()[0].getValue()
        );
        apps.add(app);

        Application__c app2 = new Application__c(
                Contact__c = student.Id,
                Application_Status__c = Application__c.Application_Status__c.getDescribe().getPicklistValues()[0].getValue(),
                Application_Control__c = appControl.Id,
                Citizenship__c = 'U.S. Citizen'
        );
        apps.add(app2);

        insert apps;

        List<EASY_Widget__c> widgets = new List<EASY_Widget__c>();

        EASY_Widget__c topWidget = new EASY_Widget__c(
                Name = 'Test Top Widget',
                Widget_Screen_Location__c = 'Top',
                Widget_Type__c = 'Custom',
                Display_Heading__c = 'Heading {<em>{</em>Banner Id}}',
                Display_Text__c = 'Display Text {{Banner_id}}',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Active',
                Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(topWidget);

        EASY_Widget__c topWidget2 = new EASY_Widget__c(
                Name = 'Test Top Widget 2',
                Widget_Screen_Location__c = 'Top',
                Widget_Type__c = 'Custom',
                Display_Heading__c = 'Heading {<em>{</em>Banner Id}}',
                Display_Text__c = 'Display Text {{Banner_id}}',
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

        EASY_Widget__c topWidget3 = new EASY_Widget__c(
                Name = 'Test Top Widget 3',
                Widget_Screen_Location__c = 'Top',
                Widget_Type__c = 'Custom',
                Display_Heading__c = 'Heading {<em>{</em>Banner Id}}',
                Display_Text__c = 'Display Text {{Banner_id}}',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Date Activated',
                Display_Widget_On_Pages__c = 'ApplicationPortal',
                Display_Widget_On_Sub_Status__c = Application__c.Application_Substatus__c.getDescribe().getPicklistValues()[0].getValue()
        );
        widgets.add(topWidget3);

        EASY_Widget__c topWidget4 = new EASY_Widget__c(
                Name = 'Test Top Widget 3',
                Widget_Screen_Location__c = 'Top',
                Widget_Type__c = 'Custom',
                Display_Heading__c = 'Heading {<em>{</em>Banner Id}}',
                Display_Text__c = 'Display Text {{Banner_id}}',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Date Activated',
                Display_Widget_On_Pages__c = 'ApplicationPortal',
                Generic_Filter_1__c = Application__c.Generic_Filter_1__c.getDescribe().getPicklistValues()[0].getValue(),
                Generic_Filter_2__c = Application__c.Generic_Filter_2__c.getDescribe().getPicklistValues()[0].getValue(),
                Generic_Filter_3__c = Application__c.Generic_Filter_3__c.getDescribe().getPicklistValues()[0].getValue(),
                Generic_Filter_4__c = Application__c.Generic_Filter_4__c.getDescribe().getPicklistValues()[0].getValue(),
                Display_Widget_On_Sub_Status__c = Application__c.Application_Substatus__c.getDescribe().getPicklistValues()[0].getValue()
        );
        widgets.add(topWidget4);

        EASY_Widget__c bottomWidget = new EASY_Widget__c(
                Name = 'Test Bottom Widget',
                Widget_Screen_Location__c = 'Bottom',
                Widget_Type__c = 'Custom',
                Display_Heading__c = 'Heading',
                Display_Text__c = 'Display Text',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Active',
                Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(bottomWidget);

        EASY_Widget__c leftWidget = new EASY_Widget__c(
                Name = 'Test Left Widget',
                Widget_Screen_Location__c = 'Left',
                Widget_Type__c = 'Custom',
                Display_Heading__c = 'Heading',
                Display_Text__c = 'Display Text',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Active',
                Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(leftWidget);

        EASY_Widget__c rightWidget = new EASY_Widget__c(
                Name = 'Test Right Widget',
                Widget_Screen_Location__c = 'Right',
                Widget_Type__c = 'Custom',
                Display_Heading__c = 'Heading',
                Display_Text__c = 'Display Text',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Active',
                Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(rightWidget);

        //Only one widget test
        EASY_Widget__c rightWidgetLogin = new EASY_Widget__c(
                Name = 'Test Right Widget',
                Widget_Screen_Location__c = 'Right',
                Widget_Type__c = 'User Info Login/Logout',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Active',
                Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(rightWidgetLogin);

        EASY_Widget__c rightWidgetLogin2 = new EASY_Widget__c(
                Name = 'Test Right Widget',
                Widget_Screen_Location__c = 'Right',
                Widget_Type__c = 'User Info Login/Logout',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Active',
                Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(rightWidgetLogin2);


        EASY_Widget__c contentTopWidget = new EASY_Widget__c(
                Name = 'Test Content Top Widget',
                Widget_Screen_Location__c = 'Content Top',
                Widget_Type__c = 'Custom',
                Display_Heading__c = 'Heading',
                Display_Text__c = 'Display Text',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Active',
                Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(contentTopWidget);

        EASY_Widget__c contentTopWidget2 = new EASY_Widget__c(
                Name = 'Test Content Top Widget',
                Widget_Screen_Location__c = 'Content Top',
                Widget_Type__c = 'Custom',
                Display_Heading__c = 'Heading',
                Display_Text__c = 'Display Text',
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
                Display_Heading__c = 'Heading',
                Display_Text__c = 'Display Text',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Active',
                Display_Widget_On_Pages__c = 'ApplicationPortal'
        );
        widgets.add(contentBottomWidget);

        EASY_Widget__c contentBottomWidget2 = new EASY_Widget__c(
                Name = 'Test Content Bottom Widget',
                Widget_Screen_Location__c = 'Content Bottom',
                Widget_Type__c = 'Custom',
                Display_Heading__c = 'Heading',
                Display_Text__c = 'Display Text',
                Application_Control__c = appControl.Id,
                Activation_State__c = 'Active',
                Display_Widget_On_Pages__c = 'ApplicationPortal',
                Display_Widget_On_Status__c = 'Submitted App'
        );
        widgets.add(contentBottomWidget2);

        insert widgets;
    }

    @IsTest
    public static void testGetWidgets() {
        Application_Control__c appControl = [SELECT Id FROM Application_Control__c LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        PageReference pr = new PageReference('/apex/ApplicationPortal');
        //pr.getParameters().put('contactId', student.Id);
        pr.getParameters().put('applicationId', app.Id);
        pr.getParameters().put('at', 'st');

        Test.setCurrentPage(pr);

        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appControlId = appControl.Id;
        appInfo.appId = app.Id;
        appInfo.contactId = student.Id;
        appInfo.citizenship = 'U.S. Citizen';

        ApplicationBodyController controller = new ApplicationBodyController();
        controller.appInfoParam = appInfo;
        controller.noApplication = false;
        controller.currentPageName = 'ApplicationPortal';

        User testUser = ApplicationTESTUtilities.userToRunWith('Customer Community Login User', 'Application_Community_Guest', student.Id);
        testUser.ContactId = student.Id;
        update testUser;
        System.runAs(testUser) {

            Test.startTest();
            ApplicationBodyController.allWidgets allWidgets = controller.getWidgets();
            Test.stopTest();

            System.debug(JSON.serializePretty(allWidgets));

            System.assertEquals(3, allWidgets.topWidgets.size());
            System.assertEquals('Display Text 111111111', allWidgets.topWidgets[0].Display_Text__c);
            //Right includes one login widget
            System.assertEquals(2, allWidgets.rightWidgets.size());
            System.assertEquals(1, allWidgets.bottomWidgets.size());
            System.assertEquals(1, allWidgets.leftWidgets.size());
            System.assertEquals(2, allWidgets.contentTopWidgets.size());
            System.assertEquals(1, allWidgets.contentBottomWidgets.size());
        }
    }
}