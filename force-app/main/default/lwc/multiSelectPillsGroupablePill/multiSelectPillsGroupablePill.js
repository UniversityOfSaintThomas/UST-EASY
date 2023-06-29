/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 6/15/2023.
 */

import {LightningElement, api, track} from 'lwc';

export default class MultiSelectPillsGroupablePill extends LightningElement {
    @track items_ = [];
    rendered = false;

    @api
    get items() {
        return this.items_;
    }

    set items(values) {

        let tempItems = JSON.parse(JSON.stringify(values));
        tempItems.forEach((pill, index) => {
            pill.internalKey = index;
        });

        this.items_ = tempItems;

    }

    deletePill = (event) => {
        let key = event.target.dataset.key;
        this.items_.some((pill, index) => {
            if (parseInt(pill.internalKey) === parseInt(key)) {
                event.stopImmediatePropagation();
                this.items_.splice(index, 1);
                this.dispatchItemRemoveEventEvent(pill);
                return true;
            }
            return false;
        });
    }

    dispatchItemRemoveEventEvent(pill) {
        const eventDetail = {item: pill};
        const changeEvent = new CustomEvent("itemremove", {detail: eventDetail});
        this.dispatchEvent(changeEvent);
    }
}