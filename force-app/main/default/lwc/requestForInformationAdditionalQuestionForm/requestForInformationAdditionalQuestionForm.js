/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/20/2024.
 */

import {api, LightningElement} from 'lwc';

export default class RequestForInformationAdditionalQuestionForm extends LightningElement {
    @api
    additional_questions = [];

    dispatchChange(event) {
        const targetValue = event.currentTarget.value;
        const questionId = event.currentTarget.dataset.questionid;
        const changeEvent = new CustomEvent('custevent', {
            detail: {
                value: targetValue,
                questionid: questionId,
                addquestion: true
            }
        });
        //console.log('change event created: ' + JSON.stringify(changeEvent.detail,null,2));
        this.dispatchEvent(changeEvent);
    }
}