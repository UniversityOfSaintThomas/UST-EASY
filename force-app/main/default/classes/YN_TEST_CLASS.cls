/**
 * Created by nguy0092 on 12/1/2023.
 */

public with sharing class YN_TEST_CLASS {

    private Map<String, OpportunityStage> oppStageMap {
        get {
            List<OpportunityStage> stages = [SELECT ApiName, DefaultProbability, ForecastCategoryName FROM OpportunityStage];
            Map<String, OpportunityStage> oppStageMap = new Map<String, OpportunityStage>();
            for (OpportunityStage stage : stages) {
                oppStageMap.put(stage.ApiName, stage);
            }
            return oppStageMap;
        }
        set;
    }

    private String determineOpportunityStage(String newStageName, String previousStageName) {
        OpportunityStage newStage = oppStageMap.get(newStageName);
        OpportunityStage previousStage = oppStageMap.get(previousStageName);
        System.debug('new stage (' + newStageName + '): ' + newStage.DefaultProbability + ', previous stage: (' + previousStageName + '): ' + previousStage.DefaultProbability);
        if (newStage.DefaultProbability >= previousStage.DefaultProbability) {
            System.debug('new stage assigned');
            return newStageName;
        } else if (newStage.ForecastCategoryName == 'Omitted') {
            System.debug('new stage assigned');
            return newStageName;
        } else {
            System.debug('previous stage assigned');
            return previousStageName;
        }
    }

}