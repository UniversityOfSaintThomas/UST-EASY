/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 11/2/2023.
 */

import {api, LightningElement} from 'lwc';

export default class AppReviewNav extends LightningElement {

    @api app;

    renderedCallback() {
        console.log('THIS: ' + JSON.stringify(this.app));
    }

}