/**
 * Created by nguy0092 on 3/12/2024.
 */

public with sharing class EasyWidgetController {

    public EASY_Widget__c widgetDetails { get; set; }
    public EASYPersonalDataTags dataTagsDetails { get; set; }

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

        if(dataTagsDetails == null){
            dataTagsDetails = new EASYPersonalDataTags();
        }

        if (String.isNotBlank(widgetDetails.Button_Code__c)) {

            returnButtonList = (List<widgetButton>) JSON.deserialize(widgetDetails.Button_Code__c, List<widgetButton>.class);
        }

        for (widgetButton b : returnButtonList) {

            b.buttonLabel = ApplicationUtilities.replaceDataTags(b.buttonLabel, dataTagsDetails);

            switch on b.buttonType {

                when 'Requirement' {
                    Id buttonRequirementIdTo18;

                    try {
                        buttonRequirementIdTo18 = b.buttonRequirementId;
                    } catch (Exception e) {
                        b.buttonLabel = b.buttonLabel + ' **INVALID REQUIREMENT ID**';
                        System.debug('Requirement ID Error: ' + e.getMessage());
                    }

                    if (buttonRequirementIdTo18 != null) {
                        b.buttonLink = 'applicationlink?requirementId=' + buttonRequirementIdTo18.toString();
                    }
                }
                when 'URL' {
                    if (b.buttonUrl != null) {
                        b.buttonLink = ApplicationUtilities.replaceDataTags(b.buttonUrl, dataTagsDetails);
                    }
                }
            }
        }

        return returnButtonList;
    }
}