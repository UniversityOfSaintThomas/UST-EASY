/**
 * Created by nguy0092 on 3/12/2024.
 */

public with sharing class EasyWidgetController {

    public EASY_Widget__c widgetDetails { get; set; }

    public class WidgetButton {

        public String id { get; set; }
        public String buttonLabel { get; set; }
        public String buttonLink { get; set; }
        public String buttonStyle { get; set; }
        public String buttonSize { get; set; }
        public String buttonPosition { get; set; }
//        public String buttonTarget { get; set; }
    }

    public EasyWidgetController() {

    }

    public List<WidgetButton> getButtons() {

        List<WidgetButton> returnButtonList = new List<WidgetButton>();

        if (String.isNotBlank(widgetDetails.Button_Code__c)) {

            returnButtonList = (List<WidgetButton>) JSON.deserialize(widgetDetails.Button_Code__c, List<WidgetButton>.class);
        }

        return returnButtonList;
    }
}