/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 11/2/2023.
 */

import {api, LightningElement} from 'lwc';

export default class EasyAppReviewNav extends LightningElement {

    selectedNav;

    // Small {id, label}[] list built by the parent (easyAppReview) — this component only
    // renders a vertical nav menu, so it doesn't need the full EASYAppWrapper graph.
    _items = [];

    @api
    get items() {
        return this._items;
    }

    set items(value) {
        const newItems = value || [];
        const newIds = newItems.map(item => item.id);
        const isSameItemSet = newIds.length === this._items.length
            && newIds.every((id, index) => id === this._items[index].id);

        this._items = newItems;

        if (isSameItemSet) {
            // Same requirement list (e.g. parent re-rendered for an unrelated reason) —
            // keep whatever the user currently has selected instead of resetting it.
            return;
            }

        if (this._items.length > 0) {
            // A genuinely new list loaded (e.g. a new application was selected) —
            // reset to the first requirement and notify the parent.
            this.selectedNav = this._items[0].id;
            this.dispatchEvent(new CustomEvent('newrequirement', {
                detail: this.selectedNav
            }));
        } else {
            this.selectedNav = undefined;
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


}