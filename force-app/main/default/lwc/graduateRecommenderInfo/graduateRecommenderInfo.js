/**
 * @description       : 
 * @author            : nicole.b@digitalmass.com
 * @group             : 
 * @last modified on  : 08-10-2022
 * @last modified by  : nicole.b@digitalmass.com
**/

import { LightningElement, wire } from 'lwc';

import getObjectIds from '@salesforce/apex/graduateRecommenderInfoController.getObjectIds';
import getQuestions from '@salesforce/apex/graduateRecommenderInfoController.getQuestions';

export default class GraduateRecommenderInfo extends LightningElement {

    recommendationId = '';
    applicationId = '';
    requirementId = '';
    requirementItemId = '';

    @wire(getObjectIds)
    objects(result) {
        if (result.data) {
            if (Boolean(result.data)) {
                this.recommendationId = result.data.recommendationId;
                this.applicationId = result.data.applicationId;
                this.requirementId = result.data.recommendarequirementIdtionId;
                this.requirementItemId = result.data.requirementItemId;
                getQuestions({requirement_item_id: this.requirementItemId})
                .then(questions => {
                    console.log(questions);
                })
                .catch(error => {
                    console.log(error);
                })
            }
        } else {
            console.log(result.error);
        }
    }
}