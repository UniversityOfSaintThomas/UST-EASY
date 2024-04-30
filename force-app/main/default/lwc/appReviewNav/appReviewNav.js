/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 11/2/2023.
 */

import {api, LightningElement} from 'lwc';

export default class AppReviewNav extends LightningElement {

    selectedNav;

    _app = {};
    menu = {};
    requirement;

    @api
    get app() {
        return this._app;
    }

    set app(value) {
        this._app = value;
        this.createMenu();
    }

    createMenu() {
        this.menu = this._app;
        if(this.menu) {
            if (!this.selectedNav) {
                this.selectedNav = this.menu.requirements[0].requirement.Id;
            }
        }
    }

    handleMenuClick(event) {
        this.selectedNav = event.detail.name;
        event.preventDefault();
        const selectEvent = new CustomEvent('newrequirement', {
            detail: event.detail.name
        });
        this.dispatchEvent(selectEvent);
    }

    renderedCallback() {

    }

}