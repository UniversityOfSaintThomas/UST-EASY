/**
 * Created by nguy0092 on 3/27/2024.
 */

@IsTest
private class EasyWidgetController_TEST {
    @TestSetup
    static void dataSetup() {

        EASY_Widget__c buttonData = new EASY_Widget__c();

        buttonData.Name = 'Button Test';
        buttonData.Widget_Type__c = 'Custom';
        buttonData.Activation_State__c = 'Active';
        buttonData.Application_Control__c = 'a0a8N000001LJA1QAO';
        buttonData.Widget_Screen_Location__c = 'Left';
        buttonData.Button_Code__c = '[{"id":0,' +
                '"buttonType":"URL",' +
                '"buttonLabel":"St. Thomas Home",' +
                '"buttonUrl":"https://www.stthomas.edu",' +
                '"buttonRequirementId":"",' +
                '"buttonStyle":"brand",' +
                '"buttonSize":"6-of-8",' +
                '"buttonPosition":"center",' +
                '"buttonIcon":"home"},' +
                '{"id":1,' +
                '"buttonType":"Requirement",' +
                '"buttonLabel":"Requirement 1",' +
                '"buttonUrl":"",' +
                '"buttonRequirementId":"111111111111111111",' +
                '"buttonStyle":"brand",' +
                '"buttonSize":"6-of-8",' +
                '"buttonPosition":"center",' +
                '"buttonIcon":"activity"},' +
                '{"id":2,' +
                '"buttonType":"Requirement",' +
                '"buttonLabel":"Requirement 2",' +
                '"buttonUrl":"",' +
                '"buttonRequirementId":"111111111111111",' +
                '"buttonStyle":"brand",' +
                '"buttonSize":"6-of-8",' +
                '"buttonPosition":"center",' +
                '"buttonIcon":"activity"}]';

        insert buttonData;
    }

    @IsTest
    static void getButtonsTest() {

        EasyWidgetController widget = new EasyWidgetController();

        widget.widgetDetails = [
                SELECT Button_Code__c
                FROM EASY_Widget__c
                WHERE Name = 'Button Test'
                LIMIT 1
        ];

        List<EasyWidgetController.widgetButton> buttons = new List<EasyWidgetController.widgetButton> ();

        buttons = widget.getButtons();

        System.assertEquals('0|URL|St. Thomas Home|https://www.stthomas.edu||brand|6-of-8|center|home|https://www.stthomas.edu',
                buttons[0].id + '|'
                + buttons[0].buttonType + '|'
                + buttons[0].buttonLabel + '|'
                + buttons[0].buttonUrl + '|'
                + buttons[0].buttonRequirementId + '|'
                + buttons[0].buttonStyle + '|'
                + buttons[0].buttonSize + '|'
                + buttons[0].buttonPosition + '|'
                + buttons[0].buttonIcon + '|'
                + buttons[0].buttonLink,
                'Error: Button Mis-Match!'
        );
    }
}