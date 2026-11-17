/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 6/15/2023.
 */

import {LightningElement, api} from 'lwc';

export default class MultiSelectPillsGroupableItem extends LightningElement {
    @api key = '';
    @api value = '';
    @api label = '';
    @api selected = false;
    @api focused = false;

    get listItemStyle() {
        let baseStyles = ' slds-media  slds-listbox__option_plain slds-media_small slds-listbox__option ';
        if (this.selected === true) {
            baseStyles += ' slds-is-selected ';
        }
        if (this.focused === true) {
            baseStyles += ' slds-has-focus ';
        }
        return baseStyles;
    }

    get isFocused() {
        return this.focused ? 'true' : null;
    }

    selectHandler(event) {
        // Prevents the anchor element from navigating to a URL.
        event.preventDefault();
        event.stopPropagation();
        const selectedEvent = new CustomEvent('selected', {
            detail: {
                label: this.label,
                value: this.value,
                selected: this.selected,
                shift: event.shiftKey
            }
        });
        this.dispatchEvent(selectedEvent);
    }
}