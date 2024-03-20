/**
 * Created by nguy0092 on 3/12/2024.
 */

public with sharing class EasyWidgetController {

    public EASY_Widget__c widgetDetails { get; set; }

    public class widgetButton {

        public String id { get; set; }
        public String buttonType { get; set; }
        public String buttonLabel { get; set; }
        public String buttonUrl { get; set; }
        public String buttonRequirementId { get; set; }
        public String buttonStyle { get; set; }
        public String buttonSize { get; set; }
        public String buttonPosition { get; set; }
        public String buttonIcon { get; set; }
        public String buttonLink { get; set; }
    }

    public EasyWidgetController() {

    }

    public List<widgetButton> getButtons() {

        List<widgetButton> returnButtonList = new List<widgetButton>();

        if (String.isNotBlank(widgetDetails.Button_Code__c)) {

            returnButtonList = (List<widgetButton>) JSON.deserialize(widgetDetails.Button_Code__c, List<widgetButton>.class);
        }

        for (widgetButton b : returnButtonList) {

            switch on b.buttonType {

                when 'Requirement' {

                    b.buttonLink = 'applicationlink?requirementId=' + b.buttonRequirementId;
                }
                when 'URL' {

                    b.buttonLink = b.buttonUrl;
                }
            }
        }

        return returnButtonList;
    }
}