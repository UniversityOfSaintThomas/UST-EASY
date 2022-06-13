/**
 * author: nicole.b@digitalmass.com
 * created-date: 2022-06-01
 * last-modified: 2022-06-06
 */

//built-ins
import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/uiRecordApi';

import LEAD_OBJECT from '@salesforce/schema/Lead';

//controller
import getRFIController from '@salesforce/apex/requestForInformationFormController.getRFIController';
import getAcademicPrograms from '@salesforce/apex/requestForInformationFormController.getAcademicPrograms';
import getAcademicTerms from '@salesforce/apex/requestForInformationFormController.getAcademicTerms';
import searchHighSchools from '@salesforce/apex/requestForInformationFormController.searchHighSchools';

export default class RequestForInformationForm extends LightningElement {
    // RFI controller info
    @api rfi_controller = 'RFI Controller 0001';
    academic_level;
    applicant_type;
    fields_to_display; //use to determine which fields on form to display

    // lead info
    lead_default_record_type;

    // maps to populate picklists, where label is name and value is id of object
    program_id_to_name_map; // for Recruitment_Program__c
    term_id_to_name_map; // for Term__c
    account_id_to_name_map; // for Affiliated_Account__c

    //front-end display
    @track show_spinner = true;
    @track manually_enter_high_school = false;
    @track modal_open = false;
    @track high_school_data = false;
    @track high_school_attended_value;

    //RFI controller determined booleans
    @track show_name_fields = true;
    @track show_phone_fields = true;
    @track show_address_fields = true;
    @track show_admit_type = true;
    @track show_citizenship = true;
    @track show_academic_interest = true;
    @track show_email = true;
    @track show_birthdate = true;
    @track show_academic_term = true;
    @track show_high_school = true;

    record_input = {
        'apiName': 'Lead',
        'fields': {
            'Admit_Type__c': '',
            'hed__Citizenship__c': '',
            'Recruitment_Program__c': '', //lookup
            'FirstName': '',
            'LastName': '',
            'Email': '',
            'Phone': '',
            'MobilePhone': '',
            'hed__SMS_Opt_Out__c': '',
            'Birthdate__c': '',
            'hed__Preferred_Enrollment_Date__c': '',
            'Term__c': '',
            'Street': '',
            'City': '',
            'State': '',
            'PostalCode': '',
            'Country': '',
            'Affiliated_Account__c': '', //lookup
            'Term__c': '' //lookup
        }
    }

    //field labels
    admit_type_label = 'I will apply to St. Thomas as a';
    citizenship_label = 'Citizenship';
    academic_interest_label = 'Academic Interest';
    first_name_label = 'First Name';
    last_name_label = 'Last Name';
    email_label = 'Email';
    home_phone_label = 'Home Phone';
    mobile_phone_label = 'Mobile Phone';
    text_messages_label = 'I would like to receive text messages';
    birthdate_label = 'Birthdate';
    address1_label = 'Address 1';
    address2_label = 'Address 2';
    city_label = 'City';
    state_label = 'State';
    zipcode_label = 'Zip Code';
    country_label = 'Country';
    academic_term_label = 'Expected Start Term at St. Thomas';
    high_school_search_label = 'High School Attended';
    high_school_not_found_label = 'I can\'t find my High School';
    high_school_search_modal_label = 'High School Search';
    high_school_datatable_name = 'High School Datatable';
    confirm_button_label = 'Confirm';

    //picklist values
    @track state_picklist_values;
    @track country_picklist_values;
    @track citizenship_picklist_values;
    @track admit_type_picklist_values;
    @track academic_interest_picklist_values = [];
    @track academic_term_picklist_values;
    @track high_school_search_results; // populate via SOSL


    //intermediate values
    address1; //concat w/ address 2 before submit (address combined field only has one 'Street' label)
    address2;

    //regex
    phone_pattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}';
    invalid_phone_message = 'Phone # must match format: 000-000-0000';

    //datatable columns
    high_school_columns = [
        { label: 'Name', fieldName: 'name', type: 'text' },
    ];

    @wire(getRFIController, { rfi_controller_name: '$rfi_controller' })
    rfi(result) {
        if (result.data) {
            if (result.data.length != 0) {
                this.academic_level = result.data.Academic_Level__c;
                this.applicant_type = result.data.Applicant_Type__c;
                this.fields_to_display = result.data.Fields_to_Display__c;
                console.log(this.fields_to_display);
                for (const field in this.fields_to_display) {
                    continue;
                }
                if (this.academic_level != undefined) {
                    getAcademicPrograms({academic_level: this.academic_level})
                    .then((programs) => {
                        console.log(JSON.stringify(programs));
                        this.program_id_to_name_map = programs;
                        var values = [];
                        for (const program in programs) {
                            values.push(
                                {label: programs[program].Name, value: programs[program].Id}
                            );
                        }
                        this.academic_interest_picklist_values = values;
                    })
                    .catch(error => {
                        console.log(error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error retreiving Academic Programs',
                                message: error.body.message,
                                variant: 'error'
                            })
                        )
                    });
                }
                this.show_spinner = false;
            }
        } else {
            console.log(result.error);
            this.show_spinner = false;
        }
    }

    @wire(getAcademicTerms)
    academic_terms(result) {
        if (result.data) {
            if (result.data.length != 0) {
                this.term_id_to_name_map = result.data;
                var values = [];
                for (const term in result.data) {
                    values.push(
                        {label: result.data[term].Name, value: result.data[term].Id}
                    );
                }
                this.academic_term_picklist_values = values;
            }
        } else {
            console.log(result.error);
        }
    }

    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    object_info(result) {
        if (result.data) {
            this.lead_default_record_type = result.data.defaultRecordTypeId;
        } else {
            console.log(result.error);
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: LEAD_OBJECT, recordTypeId: '$lead_default_record_type' })
    picklist_values(result) {
        if (result.data) {
            this.citizenship_picklist_values = result.data.picklistFieldValues.hed__Citizenship__c.values;
            this.country_picklist_values = result.data.picklistFieldValues.hed__Citizenship__c.values;
            this.admit_type_picklist_values = result.data.picklistFieldValues.Admit_Type__c.values;
        } else {
            console.log(result.error);
        }
    }

    onChange(event) {
        switch (event.target.label) {
            case this.first_name_label:
                this.record_input.FirstName = event.target.value;
                break;
            case this.last_name_label:
                this.record_input.LastName = event.target.value;
                break;
            case this.email_label:
                this.record_input.Email = event.target.value;
                break;
            case this.home_phone_label:
                this.record_input.Phone = event.target.value;
                break;
            case this.mobile_phone_label:
                this.record_input.MobilePhone = event.targenull
                break;
            case this.address2_label:
                this.address2 = event.target.value; // combine two address fields into Street before submit
                break;
            case this.city_label:
                this.record_input.City = event.target.value;
                break;
            case this.state_label:
                this.record_input.State = event.target.value;
                break;
            case this.zipcode_label:
                this.record_input.PostalCode = event.target.value;
                break;
            case this.country_label:
                this.record_input.Country = event.target.value;
                break;
            case this.text_messages_label:
                this.record_input.hed__SMS_Opt_Out__c = event.target.checked;
                break;
            case this.birthdate_label:
                this.record_input.Birthdate__c = event.target.value;
                break;
            case this.citizenship_label:
                this.record_input.hed__Citizenship__c = event.target.value;
                break;
            case this.admit_type_label:
                this.record_input.Admit_Type__c = event.target.value;
                break;
            case this.academic_interest_label:
                this.record_input.Recruitment_Program__c = event.target.value;
                break;
            case this.academic_term_label:
                this.record_input.Term__c = event.target.value; // set hed__Preferred_Enrollment_Date__c before submit (get Start Date on Term__c)
                break;
            case this.high_school_not_found_label:
                this.manually_enter_high_school = event.target.checked;
                break;
            default:
                break;
        }

        if (event.target.name == this.high_school_datatable_name) {
            var selected_row = this.template.querySelector('lightning-datatable').getSelectedRows();
            this.record_input.Affiliated_Account__c = selected_row[0].account_id;
            //this.high_school_attended_value = selected_row[0].name;
        }

        console.log(JSON.stringify(this.record_input));
    }

    handleSearch(event) {
        if (JSON.stringify(event.target.value).length > 4) {
            searchHighSchools({ search_term : event.target.value})
            .then((high_schools) => {
                if (high_schools.length > 2) {
                    this.high_school_data = true;
                    this.account_id_to_name_map = high_schools;
                    var values = [];
                    for (const school in high_schools) {
                        values.push(
                            {name: high_schools[school].Name, account_id: high_schools[school].Id}
                        );
                    }
                    this.high_school_search_results = values;
                }
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error retreiving High Schools',
                        message: error.body.message,
                        variant: 'error'
                    })
                )
            });
        } else {
            this.high_school_search_results = null;
            this.high_school_data = false;
        }
    }

    handleModal(event) {
        console.log(JSON.stringify(event.target.tagName));
        if (event.target.tagName == 'LIGHTNING-ICON') { // x button at top of modal
            this.modal_open = false;
            this.high_school_search_results = null;
            this.high_school_data = false;
            this.record_input.Affiliated_Account__c = null;
            this.high_school_attended_value = null;
        } else if (event.target.tagName == "LIGHTNING-BUTTON") { // confirm button
            this.modal_open = false;
            this.high_school_search_results = null;
            this.high_school_data = false;
            this.high_school_attended_value = this.account_id_to_name_map[this.record_input.Affiliated_Account__c].Name;
        } else {
            this.modal_open = true;
        }
    }   

    get setDataTableHeight() {
        if (this.high_school_search_results.length > 6) {
            return "height: 210px"
        }
    }

    get stateOptions() {
        return [
            { label: 'MN', value: 'MN' },
            { label: 'NY', value: 'NY' },
            { label: 'WA', value: 'WA' },
        ];
    }

}