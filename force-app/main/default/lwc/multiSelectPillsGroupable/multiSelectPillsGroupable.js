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
    @track focusedOptionIndex = -1; // Track focused option for keyboard navigation

    rendered = false;

    @api checkValidity() {
        // Check if required and no values selected
        if (this.required && this.selectedPills.length === 0) {
            return false;
        }
        return true;
    }

    @api reportValidity() {
        const isValid = this.checkValidity();
        const formElement = this.template.querySelector('.slds-form-element');

        if (!isValid) {
            // Show error state
            if (formElement) {
                formElement.classList.add('slds-has-error');
            }
                this.displayError = true;
        } else {
            // Clear error state
            if (formElement) {
                formElement.classList.remove('slds-has-error');
            }
            this.displayError = false;
        }

        return isValid;
            }

    /**
     * Reset the multi-select component to its initial state
     * Clears all selected values and pills
     */
    @api reset() {
        // Clear the internal value
        this.value_ = '';

        // Deselect all options
        if (this.options_ && Array.isArray(this.options_)) {
            this.options_ = this.options_.map(option => ({
                ...option,
                selected: false,
                selectedAt: undefined
            }));
        }

        // Clear selected pills
        this.selectedPills = [];

        // Clear the hidden input value
        const idInput = this.template.querySelector("input");
        if (idInput) {
            idInput.value = '';
        }

        // Clear any error state
        this.displayError = false;
        this.displayHelp = false;
        const formElement = this.template.querySelector('.slds-form-element');
        if (formElement) {
            formElement.classList.remove('slds-has-error');
        }
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

    /**
     * Get options with focused state for display
     * Computes which option should be highlighted based on focusedOptionIndex
     */
    get displayOptions() {
        if (!this.options_ || this.options_.length === 0) {
            return [];
        }

        let selectableIndex = 0;
        return this.options_.map(option => {
            if (option.is_group) {
                return { ...option, focused: false };
            }
            const isFocused = selectableIndex === this.focusedOptionIndex;
            selectableIndex++;
            return { ...option, focused: isFocused };
        });
    }

    @api get value() {
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
            if (valueSet.size > 0) {
                if (valueSet.has(option.value)) {
                    option.selected = true;
                }
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
        // If no options set yet or invalid, just return value
        if (this.options_.length < 1) {
            return this.value_;
        }

        return this.options_
            .filter(option => option.selected === true)
            .sort((a, b) => a.selectedAt - b.selectedAt)
            .map(option =>
                option.label.toLowerCase().includes('undecided')
                    ? 'undecided|' + option.value
                    : option.value
            );
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

    get ariaExpanded() {
        return this.isOpen ? 'true' : 'false';
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
        this.focusedOptionIndex = -1;
    }

    closeDropdown() {
        this.isOpen = false;
        this.focusedOptionIndex = -1;
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

    /**
     * Handle keyboard events for accessibility
     * Enter/Space: Toggle dropdown open/close or select focused option
     * Escape: Close dropdown
     * Arrow Down: Open dropdown or move to next option
     * Arrow Up: Move to previous option
     */
    handleKeyDown(event) {
        const key = event.key;

        // Get selectable options (non-group items)
        const selectableOptions = this.options_?.filter(opt => !opt.is_group) || [];

        switch (key) {
            case 'Enter':
            case ' ':
                event.preventDefault();
                event.stopPropagation();
                if (this.isOpen && this.focusedOptionIndex >= 0) {
                    // Select the focused option
                    const focusedOption = selectableOptions[this.focusedOptionIndex];
                    if (focusedOption) {
                        this._selectOption(focusedOption.value, focusedOption.selected);
                    }
                } else if (this.isOpen) {
                    this.closeDropdown();
                    window.removeEventListener('click', this.handleClose);
                    this.focusedOptionIndex = -1;
                } else {
                    this.openDropdown();
                    window.addEventListener('click', this.handleClose);
                    this.focusedOptionIndex = 0;
                    this._scrollToFocusedOption();
                }
                break;
            case 'Escape':
                event.preventDefault();
                if (this.isOpen) {
                    this.closeDropdown();
                    window.removeEventListener('click', this.handleClose);
                    this.focusedOptionIndex = -1;
                }
                break;
            case 'ArrowDown':
                event.preventDefault();
                if (!this.isOpen) {
                    this.openDropdown();
                    window.addEventListener('click', this.handleClose);
                    this.focusedOptionIndex = 0;
                } else if (this.focusedOptionIndex < selectableOptions.length - 1) {
                    this.focusedOptionIndex++;
                }
                this._scrollToFocusedOption();
                break;
            case 'ArrowUp':
                event.preventDefault();
                if (!this.isOpen) {
                    this.openDropdown();
                    window.addEventListener('click', this.handleClose);
                    this.focusedOptionIndex = selectableOptions.length - 1;
                } else if (this.focusedOptionIndex > 0) {
                    this.focusedOptionIndex--;
                }
                this._scrollToFocusedOption();
                break;
            case 'Tab':
                // Close dropdown on tab and allow normal tab behavior
                if (this.isOpen) {
                    this.closeDropdown();
                    window.removeEventListener('click', this.handleClose);
                    this.focusedOptionIndex = -1;
                }
                break;
            default:
                break;
        }
    }

    /**
     * Select an option programmatically (used by keyboard navigation)
     */
    _selectOption(value, currentlySelected) {
        let num_values = this.selectedValues().length;
        let max_reached = false;
        this.displayHelp = false;

        if (this.max) {
            if (num_values + 1 > this.max && !currentlySelected) {
                max_reached = true;
            }
        }

        this.options_.forEach(option => {
            if (option.value === value) {
                if (currentlySelected === true) {
                    option.selected = false;
                    option.selectedAt = undefined;
                } else if (!max_reached) {
                    option.selected = true;
                    option.selectedAt = Date.now();
                }
            }
        });

        if (max_reached) {
            this.displayHelp = true;
        }

        this.selectedPills = this.getPillArray();
        this.dispatchChangeEvent();
    }

    /**
     * Scroll the dropdown to keep the focused option visible
     */
    _scrollToFocusedOption() {
        // Use setTimeout to allow DOM to update
        setTimeout(() => {
            const listbox = this.template.querySelector('.slds-listbox');
            if (!listbox) return;

            // Get all the item components
            const items = this.template.querySelectorAll('c-multi-select-pills-groupable-item');
            if (items && items.length > this.focusedOptionIndex && this.focusedOptionIndex >= 0) {
                const focusedItem = items[this.focusedOptionIndex];
                if (focusedItem) {
                    // Scroll the item into view within the dropdown
                    focusedItem.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
                }
            }
        }, 0);
    }

    /**
     * Handle focus event for visual feedback
     */
    handleFocus() {
        // Add focus styling if needed
        const comboboxDiv = this.template.querySelector('#combobox-div-1');
        if (comboboxDiv) {
            comboboxDiv.classList.add('slds-has-focus');
        }
    }

    /**
     * Handle blur event
     */
    handleBlur() {
        // Remove focus styling
        const comboboxDiv = this.template.querySelector('#combobox-div-1');
        if (comboboxDiv) {
            comboboxDiv.classList.remove('slds-has-focus');
        }
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

        // In handleSelectedClick, set selectedAt when selecting
        this.options_.forEach(function (option) {
            if (option.value === value) {
                if (selected === true) {
                    option.selected = false;
                    option.selectedAt = undefined;
                } else if (!max_reached) {
                    option.selected = true;
                    option.selectedAt = Date.now(); // or use a counter
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

        // Clear error state when user makes a selection
        const formElement = idInput.closest('.slds-form-element');
        if (formElement) {
            formElement.classList.remove('slds-has-error');
        }
        this.displayError = false;

        this.template.querySelector("input").value = valueString;
        const eventDetail = {value: valueString.split(';')};
        const changeEvent = new CustomEvent('change', {detail: eventDetail});
        this.dispatchEvent(changeEvent);
    }

    // In getPillArray, sort by selectedAt
    getPillArray() {
        let pills = this.options_
            .filter(element => element.selected)
            .sort((a, b) => a.selectedAt - b.selectedAt)
            .map((element, iterator) => ({
                label: element.label, name: element.value, key: iterator
            }));
        return pills;
    }

}