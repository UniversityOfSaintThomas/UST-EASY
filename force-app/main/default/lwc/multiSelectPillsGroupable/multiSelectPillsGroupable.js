/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 6/15/2023.
 * Based off the work in this repo https://github.com/rapsacnz/MultiSelect
 */

import {LightningElement, api, track} from 'lwc';

export default class MultiSelectPillsGroupable extends LightningElement {
    @api width = 100;
    @api variant = '';
    @api label = '';
    @api name = '';
    @api dropdownLength = 5;
    @api max;
    @api hint;
    @api alert;
    @api help;
    @api required;
    @api selectedPills = [];  //separate from values, because for some reason pills use {label,name} while values uses {label:value}

    @track value_ = ''; //serialized value - ie 'CA;FL;IL' used when / if options have not been set yet
    @track isOpen = false;
    @track displayHelp = false;
    @track displayError = false;

    rendered = false;

    @api
    checkValidity() {
        let isSelfValidated = false;
        isSelfValidated = [
            ...this.template.querySelectorAll("input")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            let validCheck = validSoFar && inputField.checkValidity();
            if (!validCheck) {
                this.template.querySelector('.slds-form-element').classList.add('slds-has-error');
                this.displayError = true;
            }
            return validSoFar && inputField.checkValidity();
        }, true);
        return isSelfValidated;
    }

    @api
    get options() {
        return this.options_
    }

    set options(options) {
        this.rendered = false;
        this.parseOptions(options);
        this.parseValue(this.value_);
    }

    @api
    get value() {
        let selectedValues = this.selectedValues();
        return selectedValues.length > 0 ? selectedValues.join(";") : "";
    }

    set value(value) {
        this.value_ = value;
        this.parseValue(value);

    }

    parseValue(value) {
        if (!value || !this.options_ || this.options_.length < 1) {
            return;
        }
        let values = value.split(";");
        let valueSet = new Set(values);

        this.options_ = this.options_.map(function (option) {
            if (valueSet.has(option.value)) {
                option.selected = true;
            }
            return option;
        });
        this.selectedPills = this.getPillArray();
    }

    parseOptions(options) {
        if (options !== undefined && Array.isArray(options)) {
            this.options_ = JSON.parse(JSON.stringify(options)).map((option, i) => {
                option.key = i;
                return option;
            });
        }
    }


    //private called by getter of 'value'
    selectedValues() {
        let values = [];

        //if no options set yet or invalid, just return value
        if (this.options_.length < 1) {
            return this.value_;
        }

        this.options_.forEach(function (option) {
            if (option.selected === true) {
                values.push(option.value);
            }
        });
        return values;
    }

    get labelStyle() {
        return this.variant === 'label-hidden' ? ' slds-hide' : ' slds-form-element__label ';
    }

    get dropdownOuterStyle() {
        return 'slds-dropdown slds-dropdown_fluid slds-dropdown_length-' + this.dropdownLength;
    }

    get mainDivClass() {
        let style = ' slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
        return this.isOpen ? ' slds-is-open ' + style : style;
    }

    get hintText() {
        if (this.selectedPills.length === 0) {
            if (this.hint) {
                return this.hint;
            } else {
                return "Select an option...";
            }
        }
        return "";
    }

    openDropdown() {
        this.isOpen = true;
    }

    closeDropdown() {
        this.isOpen = false;
    }

    /* following pair of functions are a clever way of handling a click outside,
       despite us not having access to the outside dom.
       see: https://salesforce.stackexchange.com/questions/255691/handle-click-outside-element-in-lwc
       I made a slight improvement - by calling stopImmediatePropagation, I avoid the setTimeout call
       that the original makes to break the event flow.
    */
    handleClick(event) {
        event.stopImmediatePropagation();
        this.openDropdown();
        window.addEventListener('click', this.handleClose);
    }

    handleClose = (event) => {
        event.stopPropagation();
        this.closeDropdown();
        window.removeEventListener('click', this.handleClose);
    }

    handlePillRemove(event) {
        event.preventDefault();
        event.stopPropagation();
        this.displayHelp = false;
        const name = event.detail.item.name;

        this.options_.forEach(function (element) {
            if (element.value === name) {
                element.selected = false;
            }
        });
        this.selectedPills = this.getPillArray();
        this.dispatchChangeEvent();

    }

    handleSelectedClick(event) {

        let num_values = this.selectedValues().length;
        let max_reached = false;
        this.displayHelp = false;
        if (this.max) {
            if (num_values + 1 > this.max) {
                max_reached = true;
            }
        }

        let value;
        let selected;
        event.preventDefault();
        event.stopPropagation();

        const listData = event.detail;

        value = listData.value;
        selected = listData.selected;

        this.options_.forEach(function (option) {
            if (option.value === value) {
                if (selected === true) {
                    option.selected = false;
                } else if (!max_reached) {
                    option.selected = true;
                }
            }
        });

        if (max_reached) {
            this.displayHelp = true;
            this.closeDropdown();
        }

        // shift key ADDS to the list (unless clicking on a previously selected item)
        // also, shift key does not close the dropdown.
        if (!listData.shift) {
            this.closeDropdown();
        }

        this.selectedPills = this.getPillArray();
        this.dispatchChangeEvent();

    }

    dispatchChangeEvent() {
        let values = this.selectedValues();
        let valueString = values.length > 0 ? values.join(";") : "";
        let idInput = this.template.querySelector("input");
        idInput.value = valueString;
        idInput.closest('.slds-form-element').classList.remove('slds-has-error');
        this.template.querySelector("input").value = valueString;
        const eventDetail = {value: valueString.split(';')};
        const changeEvent = new CustomEvent('change', {detail: eventDetail});
        this.dispatchEvent(changeEvent);
    }

    getPillArray() {
        let pills = [];
        this.options_.forEach(function (element) {
            let iterator = 0;
            if (element.selected) {
                pills.push({label: element.label, name: element.value, key: iterator++});
            }
        });
        return pills;
    }

}