/**
 * author: nicole.b@digitalmass.com
 * created-date: 2022-06-01
 * last-modified: 2022-06-01
 */
import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class RequestForInformationForm extends LightningElement {
    @track program_type;

    @track show_spinner;

    @wire(CurrentPageReference)
    pageRef(result) {
        console.log('here');
        if (result.data && result.data.length != 0) {
            console.log(JSON.stringify(result.data));
        }
    }

}