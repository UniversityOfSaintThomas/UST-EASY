/**
 * @description       :
 * @author            : nicole.b@digitalmass.com
 * @group             :
 * @last modified on  : 08-15-2022
 * @last modified by  : nicole.b@digitalmass.com
 **/


//built-ins
import {LightningElement, api, track, wire} from 'lwc';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import {getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import {generateRecordInputForCreate, getFieldValue, getRecord, getRecordCreateDefaults} from 'lightning/uiRecordApi';

// lead object and fields
import LEAD_OBJECT from '@salesforce/schema/Lead';
import RFI_OBJECT from '@salesforce/schema/RFI_Controller__c'; //using to get Country global picklist value set
import RFI_CONTROLLER_NAME from '@salesforce/schema/RFI_Controller__c.Name';
import RFI_CONTROLLER_ID from '@salesforce/schema/RFI_Controller__c.Id';
import LEAD_FIRST_NAME from '@salesforce/schema/Lead.FirstName';
import LEAD_TITLE from '@salesforce/schema/Lead.Title';
import LEAD_ADMIT_TYPE from '@salesforce/schema/Lead.Admit_Type__c';
import LEAD_CITIZENSHIP from '@salesforce/schema/Lead.Citizenship_Type__c';
import LEAD_RECRUITMENT_PROGRAM from '@salesforce/schema/Lead.Recruitment_Program__c';
import LEAD_MAJOR1 from '@salesforce/schema/Lead.Major_Program__c';
import LEAD_MAJOR2 from '@salesforce/schema/Lead.Major_Program_2__c';
import LEAD_MAJOR3 from '@salesforce/schema/Lead.Major_Program_3__c';
import LEAD_MAJOR4 from '@salesforce/schema/Lead.Major_Program_4__c';
import LEAD_EMAIL from '@salesforce/schema/Lead.Email';
import LEAD_PHONE from '@salesforce/schema/Lead.Phone';
import LEAD_MOBILE_PHONE from '@salesforce/schema/Lead.MobilePhone';
import LEAD_TEXTS from '@salesforce/schema/Lead.Receive_Texts__c';
import LEAD_BIRTHDATE from '@salesforce/schema/Lead.Birthdate__c';
import LEAD_PREFERRED_ENROLLMENT from '@salesforce/schema/Lead.hed__Preferred_Enrollment_Date__c';
import LEAD_INTENDED_START_TERM from '@salesforce/schema/Lead.Intended_Start_Term__c';
import LEAD_STREET from '@salesforce/schema/Lead.Street';
import LEAD_CITY from '@salesforce/schema/Lead.City';
import LEAD_STATE from '@salesforce/schema/Lead.State';
import LEAD_POSTAL_CODE from '@salesforce/schema/Lead.PostalCode';
import LEAD_COUNTRY from '@salesforce/schema/Lead.Country';
import LEAD_COUNTRY_CODE from '@salesforce/schema/Lead.CountryCode';
import LEAD_HIGH_SCHOOL_OR_COLLEGE from '@salesforce/schema/Lead.High_School_or_College__c';
import LEAD_HIGH_SCHOOL_GRAD_YEAR from '@salesforce/schema/Lead.Expected_Graduate_Date__c';
import LEAD_TIMELINE from '@salesforce/schema/Lead.Timeline__c';
import LEAD_QUESTION from '@salesforce/schema/Lead.Has_Question__c';
import LEAD_DESCRIPTION from '@salesforce/schema/Lead.Description';
import LEAD_MAIL_INFO from '@salesforce/schema/Lead.Mail_Information_Requested__c';
import LEAD_ST_THOMAS_COLLEGE_SCHOOL from '@salesforce/schema/Lead.St_Thomas_College_School__c';
import LEAD_RECENT_SCHOOL from '@salesforce/schema/Lead.hed__Most_Recent_School__c';
import LEAD_HEARD_ABOUT_US from '@salesforce/schema/Lead.Heard_About_Us__c';
import LEAD_SCHOLARSHIP_OF_INTEREST from '@salesforce/schema/Lead.Scholarship_of_Interest__c';

//controller
import getRFIController from '@salesforce/apex/requestForInformationFormController.getRFIController';
import getCountries from '@salesforce/apex/requestForInformationFormController.getCountries';
import getPrograms from '@salesforce/apex/requestForInformationFormController.getPrograms';
import getTerms from '@salesforce/apex/requestForInformationFormController.getTerms';
import getAcademicLevelValue from '@salesforce/apex/requestForInformationFormController.getAcademicLevelValue';
import createLead from '@salesforce/apex/requestForInformationFormController.createLead';
import getPresetValues from '@salesforce/apex/requestForInformationFormController.getPresetValues';
import getSchoolCollegeAccount from '@salesforce/apex/requestForInformationFormController.getSchoolCollegeAccount';
import getRecruitmentProgram from '@salesforce/apex/requestForInformationFormController.getRecruitmentProgram';
import getProgramIds from '@salesforce/apex/requestForInformationFormController.getProgramIds';

const RFI_CONTROLLER_FIELDS = [
    RFI_CONTROLLER_NAME,
    RFI_CONTROLLER_ID
];

const ADDITIONAL_FIELDS = [
    LEAD_FIRST_NAME,
    LEAD_TITLE,
    LEAD_ADMIT_TYPE,
    LEAD_CITIZENSHIP,
    LEAD_RECRUITMENT_PROGRAM,
    LEAD_MAJOR1,
    LEAD_MAJOR2,
    LEAD_MAJOR3,
    LEAD_MAJOR4,
    LEAD_EMAIL,
    LEAD_PHONE,
    LEAD_MOBILE_PHONE,
    LEAD_TEXTS,
    LEAD_BIRTHDATE,
    LEAD_PREFERRED_ENROLLMENT,
    LEAD_INTENDED_START_TERM,
    LEAD_STREET,
    LEAD_CITY,
    LEAD_STATE,
    LEAD_POSTAL_CODE,
    LEAD_COUNTRY,
    LEAD_COUNTRY_CODE,
    LEAD_HIGH_SCHOOL_OR_COLLEGE,
    LEAD_HIGH_SCHOOL_GRAD_YEAR,
    LEAD_TIMELINE,
    LEAD_QUESTION,
    LEAD_DESCRIPTION,
    LEAD_MAIL_INFO,
    LEAD_ST_THOMAS_COLLEGE_SCHOOL,
    LEAD_RECENT_SCHOOL,
    LEAD_HEARD_ABOUT_US,
    LEAD_SCHOLARSHIP_OF_INTEREST
];


export default class RequestForInformationForm extends LightningElement {

    utm_campaign;
    utm_medium;
    utm_source;
    utm_content;
    utm_term;
    utm_id;
    utm_creative_format;
    utm_marketing_topic;
    utm_source_platform;
    gclid;
    sfcid;

    //connectedCallback() is a lifecycle hook that fires when the component is inserted into the DOM so we can gather URL parameters at this point
    connectedCallback() {
        this.utm_campaign = this.getUrlParamValue(window.location.href, 'utm_campaign');
        this.utm_medium = this.getUrlParamValue(window.location.href, 'utm_medium');
        this.utm_source = this.getUrlParamValue(window.location.href, 'utm_source');
        this.utm_content = this.getUrlParamValue(window.location.href, 'utm_content');
        this.utm_term = this.getUrlParamValue(window.location.href, 'utm_term');
        this.utm_id = this.getUrlParamValue(window.location.href, 'utm_id');
        this.utm_creative_format = this.getUrlParamValue(window.location.href, 'utm_creative_format');
        this.utm_marketing_topic = this.getUrlParamValue(window.location.href, 'utm_marketing_topic');
        this.utm_source_platform = this.getUrlParamValue(window.location.href, 'utm_source_platform');
        this.gclid = this.getUrlParamValue(window.location.href, 'gclid');
        this.sfcid = this.getUrlParamValue(window.location.href, 'sfcid');
        if(!this.sfcid) {
            this.sfcid = this.getUrlParamValue(window.location.href, 'c__sfcid');
        }
    }

    //Gets url parameters to populate utm fields
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    // RFI controller info
    @api rfi_controller = 'RFI Controller 0000';

    @api recordId;

    //If a recordId is found we can assume we are on a record page and we can get the RFI controller name from the record
    @wire(getRecord, {recordId: "$recordId", fields: RFI_CONTROLLER_FIELDS})
    rfiController({error, data}) {
        if (error) {
            console.log(error);
        } else if (data) {
            this.rfi_controller = getFieldValue(data, RFI_CONTROLLER_NAME);
        }
    }

    academic_level;
    academic_level_api;
    school_college_title;
    school_college;
    citizenship_type;
    lead_owner;
    lead_source;

    redirect_url;
    fields_to_display;
    required_fields;
    multi_select_standard;
    multi_select_single = false;

    // lead info
    lead_default_record_type;
    rfi_controller_default_record_type;
    all_lead_field_api_names = [];

    // maps to populate picklists, where value is name and key is id of object
    program_id_to_name_map; // for Recruitment_Program__c
    term_id_to_name_map; // for Intended_Start_Term__c
    single_selected_program; // store id for undecided program if in play
    academic_max_select = "4";
    academic_max_select_help = "You can only choose up to " + this.academic_max_select + " options";
    //front-end display

    @track hide_form_title = true;
    @track manually_enter_high_school = false;
    @track high_school_data = false;
    @track form_submitted_successfully = false;
    @track international_citizen_type = false;
    @track is_undergraduate = false;
    @track text_message_requested = false;
    @track is_transfer = false;
    @track academic_undecided_selected = false;

    //@track mobile_phone_value;

    //RFI controller determined booleans
    @track show_fields = {
        'data_loaded': false,
        'show_spinner': true,
        'I_will_apply_to_St_Thomas_as_a': false,
        'Citizenship': false,
        'Academic_Interest': false,
        'Title': false,
        'Email': false,
        'Home_and_Mobile_Phone': false,
        'I_would_like_to_receive_text_messages': false,
        'Birthdate': false,
        'Employer': false,
        'Expected_Start_Term_at_St_Thomas': false,
        'High_School_Attended': false,
        'Address_1': false,
        'Address_2': false,
        'Address_3': false,
        'City': false,
        'State': false,
        'Zipcode': false,
        'Country': false,
        'High_School_Graduation_Year': false,
        'Timeline_to_Enrollment': false,
        'I_have_a_question': false,
        'Description': false,
        'I_would_like_program_information_to_be_mailed_to_me': false,
        'Phone': false,
        'How_did_you_hear_about_us': false,
        'Tell_us_about_yourself': false,
        'St_Thomas_Colleges': false,
        'Scholarship_of_Interest': false
    }

    @track require_fields = {
        'I_will_apply_to_St_Thomas_as_a': false,
        'Citizenship': false,
        'Academic_Interest': false,
        'Title': false,
        'Email': false,
        'Home_Phone': false,
        'Mobile_Phone': false,
        'Birthdate': false,
        'Employer': false,
        'Expected_Start_Term_at_St_Thomas': false,
        'High_School_Attended': false,
        'Address_1': false,
        'Address_2': false,
        'Address_3': false,
        'City': false,
        'State': false,
        'Zipcode': false,
        'Country': false,
        'High_School_Graduation_Year': false,
        'Timeline_to_Enrollment': false,
        'I_have_a_question': false,
        'Phone': false,
        'How_did_you_hear_about_us': false,
        'Tell_us_about_yourself': false,
        'St_Thomas_Colleges': false,
        'Scholarship_of_Interest': false,
    }

    record_input; // stores user entered form information

    //field labels
    field_labels = {
        'admit_type_label': 'I will apply to St. Thomas as a',
        'citizenship_label': 'Citizenship',
        'academic_interest_label': 'Academic Interest (Max 4)',
        'first_name_label': 'First Name',
        'last_name_label': 'Last Name',
        'email_label': 'Email',
        'home_phone_label': 'Home Phone',
        'mobile_phone_label': 'Mobile Phone',
        'text_messages_label': 'I would like to receive text messages',
        'birthdate_label': 'Birthday (MM/DD/YYYY)',
        'address1_label': 'Address 1',
        'address2_label': 'Address 2',
        'address3_label': 'Address 3',
        'city_label': 'City',
        'state_label': 'State',
        'region_label': 'Region, Province, or State',
        'zipcode_label': 'Zip Code',
        'country_label': 'Country',
        'academic_term_label': 'Expected Start Term at St. Thomas',
        'high_school_search_label': 'High School Attended',
        'college_search_label': 'Last College Attended',
        'high_school_not_found_label': 'I can\'t find my High School',
        'college_not_found_label': 'I can\'t find my College',
        'high_school_datatable_name': 'High School Datatable',
        'employer_label': 'Employer',
        'title_label': 'Title',
        'high_school_graduation_year_label': 'High School Graduation (YYYY)',
        'timeline_label': 'Timeline to Enrollment',
        'has_question_label': 'I have a question',
        'description_label': 'Questions/Comments',
        'mail_info_label': 'I would like program information to be mailed to me',
        'phone_label': 'Phone',
        'tell_us_about_yourself': 'Tell us about yourself and why you are interested in this program. (150 words or less)',
        'st_thomas_colleges': 'College\\School',
        'scholarship_of_interest': 'Scholarship of Interest',
        'how_did_you_hear_about_us': 'How did you hear about us?'
    }

    //picklist values
    @track state_picklist_values;
    @track country_picklist_values;
    @track citizenship_picklist_values;
    @track admit_type_picklist_values;
    @track academic_level_picklist_values;
    @track academic_term_picklist_values;
    @track academic_interest_picklist_values;
    @track academic_interest_picklist_values_no_undecided;
    @track high_school_search_results; // populate via SOSL
    @track timeline_picklist_values;
    @track scholarship_picklist;
    @track heard_about_us_picklist;


    //intermediate values
    address1;
    address2;
    address3;
    academic_interest_id_list = [];
    school_picklist;
    tell_us_about;
    have_a_question;
    has_additional_questions_top = false;
    has_additional_questions_bottom = false;
    additional_questions_top;
    additional_questions_bottom;
    disable_standard_fields;
    additional_questions;

    /**
     ******************************************
     * Begin WIRES
     ******************************************
     */

    // Use the Apex class getRFIController to get the RFI controller information
    @wire(getRFIController, {rfi_controller_name: '$rfi_controller'}) async rfi(result) {
        this.show_fields.show_spinner = true;
        if (result.data) {
            if (Boolean(result.data)) {
                //Assign values from RFI controller to local variables
                this.academic_level_api = result.data.Academic_Level__c;
                if (this.academic_level_api === 'U') {
                    this.is_undergraduate = true;
                }
                if (Boolean(result.data.School_College__c)
                    && result.data.School_College__c !== 'Graduate'
                    && result.data.School_College__c !== 'Undergraduate') {
                    this.school_college_title = 'from the ' + result.data.School_College__c;
                }
                this.school_college = result.data.School_College__c;
                this.citizenship_type = result.data.Citizenship_Type__c;
                this.fields_to_display = result.data.Fields_to_Display__c;
                this.required_fields = result.data.Required_Fields__c;
                this.lead_owner = result.data.Lead_Owner__c;
                this.lead_source = result.data.Lead_Source__c;
                this.redirect_url = result.data.Redirect_URL__c;
                this.hide_form_title = result.data.Hide_Form_Title__c;
                this.redirect_after_submit = result.data.Redirect_After_Form_Submission__c;
                this.academic_interest_codes = result.data.Academic_Interests_To_Display__c;
                this.disable_standard_fields = result.data.Disable_fields_to_display__c;
                if (result.data.Multi_Select_Display_Type__c === 'SLDS Dueling Picklists' || !result.data.Multi_Select_Display_Type__c) {
                    this.multi_select_standard = true;
                } else {
                    this.multi_select_standard = false
                }
                if (result.data.Academic_Interest_Max_Selection__c) {
                    this.academic_max_select = result.data.Academic_Interest_Max_Selection__c;
                    if (this.academic_max_select == "1") {
                        this.multi_select_single = true;
                        this.field_labels.academic_interest_label = 'Academic Interest';
                    } else {
                        this.field_labels.academic_interest_label = 'Academic Interest (Max ' + this.academic_max_select + ')';
                        this.academic_max_select_help = "You can only choose up to " + this.academic_max_select + " options";
                    }
                }

                if (result.data.Additional_Questions__c) {
                    this.additional_questions = JSON.parse(result.data.Additional_Questions__c);
                    //get all data with position top
                    this.additional_questions_top = this.additional_questions.filter(question => question.position === 'top');
                    //get all data with position bottom or empty
                    this.additional_questions_bottom = this.additional_questions.filter(question => question.position === 'bottom' || !question.position);
                    if (this.additional_questions_top.length > 0) {
                        this.has_additional_questions_top = true;
                    }
                    if (this.additional_questions_bottom.length > 0) {
                        this.has_additional_questions_bottom = true;
                    }
                }

                // sets boolean values for front-end display i.e. which fields on are form, which are required
                this.handleFieldsToDisplay();
                this.handleRequiredFields();
                //gets value/label of picklist by api name to use in form title
                await getAcademicLevelValue({api_name: result.data.Academic_Level__c})
                    .then((level) => {
                        this.academic_level = level;
                    })
                    .catch(error => {
                        console.log(error);
                    });
                await getTerms({account_name: this.school_college})
                    .then(terms => {
                        if (Boolean(terms)) {
                            this.term_id_to_name_map = terms;
                            let values = [];
                            for (const term in terms) {
                                values.push(
                                    {label: terms[term].Name, value: terms[term].Id}
                                );
                            }
                            this.academic_term_picklist_values = values;
                        }
                    })
                    .catch(error => {
                        console.log(error);
                    })
                await getCountries().then(countries => {
                    let values = [];
                    for (let key in countries) {
                        values.push(
                            {label: key, value: countries[key]}
                        );
                    }
                    this.country_picklist_values = values
                });

                if (!this.show_fields.Academic_Interest && this.academic_interest_codes) {
                    getProgramIds({academic_interest_codes: this.academic_interest_codes})
                        .then((programIds) => {
                            this.academic_interest_id_list = programIds;
                        })
                        .catch(error => {
                            console.log('ERROR: ' + error);
                        });
                }

                if (Boolean(this.academic_level_api)) {
                    // gets programs based on academic level
                    await getPrograms({
                        academic_level: this.academic_level_api,
                        school_college: this.school_college,
                        academic_interest_codes: this.academic_interest_codes,
                        multi_select_standard: this.multi_select_standard
                    })
                        .then((programs) => {
                            this.program_id_to_name_map = programs;
                            const values = [];
                            let last_group = '';

                            if (this.academic_level === 'U' || this.academic_level === 'Undergraduate') {
                                for (const program in programs) {
                                    values.push(
                                        {
                                            label: programs[program].Program_Name_on_Application__c,
                                            value: programs[program].Id
                                        }
                                    );
                                }
                            } else {
                                //Check for any programs that have Program_Name_on_Application__c = 'Undecided'
                                for (const program in programs) {
                                    if (programs[program].Program_Name_on_Application__c.toLowerCase().includes('undecided') || this.academic_max_select === "1") {
                                        this.academic_max_select = "1";
                                        this.multi_select_single = true;
                                        this.field_labels.academic_interest_label = 'Academic Interest';
                                        this.academic_max_select_help = "Only one program of interest can be selected.";
                                    }
                                }

                                for (const program in programs) {
                                    let label_value = programs[program].Program_Name_on_Application__c;
                                    if (label_value.toLowerCase().includes('undecided')) {
                                        this.multi_select_standard = false;
                                    }
                                    if (!this.single_selected_program) {
                                        if (last_group === '' || last_group !== programs[program].Degree__c) {
                                        last_group = programs[program].Degree__c
                                            if (label_value && programs[program].Degree__c) {
                                        values.push(
                                            {
                                                label: programs[program].Degree__c,
                                                value: programs[program].Degree__c,
                                                description: programs[program].Degree__c,
                                                is_group: true
                                            }
                                        );
                                    }
                                        }
                                    }
                                    if (label_value && programs[program].Id) {
                                    values.push(
                                        {
                                            label: label_value,
                                            value: programs[program].Id,
                                            description: programs[program].Degree__c,
                                            is_group: false
                                        }
                                    );
                                }
                            }
                            }

                            this.academic_interest_picklist_values = values;

                            //if multi_select_standard is true remove items with is_group true
                            if (this.multi_select_standard) {
                                this.academic_interest_picklist_values = this.academic_interest_picklist_values.filter(function (el) {
                                    return !el.is_group;
                                });
                            }

                            //remove undecided value from academic_interest_picklist_values and apply to academic_interest_picklist_values_no_undecided
                            this.academic_interest_picklist_values_no_undecided = this.academic_interest_picklist_values.filter(function (el) {
                                return !el.label.toLowerCase().includes('undecided');
                            });

                        })
                        .catch(error => {
                            console.log(error);
                        });
                }
                this.text_message_requested = this.require_fields.Mobile_Phone
                this.show_fields.data_loaded = true;
                this.show_fields.show_spinner = false;
            }
        } else {
            if (result.error) {
                console.log(result.error);
            }
            this.show_fields.show_spinner = false;
        }
    }

    @wire(getObjectInfo, {objectApiName: LEAD_OBJECT})
    object_info(result) {
        if (result.data) {
            this.lead_default_record_type = result.data.defaultRecordTypeId;
            let fields = new Map(Object.entries(result.data.fields));
            for (const field of fields) {
                this.all_lead_field_api_names.push(field[0]);
            }
        } else {
            if (result.error) {
                console.log(result.error + ' LEAD OBJECT RECORD TYPE');
            }
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: LEAD_OBJECT,
        recordTypeId: '$lead_default_record_type'
    })
    picklist_values(result) {
        if (result.data) {
            this.citizenship_picklist_values = result.data.picklistFieldValues.Citizenship_Type__c.values;
            this.admit_type_picklist_values = result.data.picklistFieldValues.Admit_Type__c.values;
            this.timeline_picklist_values = result.data.picklistFieldValues.Timeline__c.values;
            this.scholarship_picklist = result.data.picklistFieldValues.Scholarship_of_Interest__c.values;
            this.heard_about_us_picklist = result.data.picklistFieldValues.Heard_About_Us__c.values;
        } else {
            if (result.error) {
                console.log(result.error + ' LEAD OBJECT');
            }
        }
    }

    @wire(getObjectInfo, {objectApiName: RFI_OBJECT})
    object_info2(result) {
        if (result.data) {
            this.rfi_controller_default_record_type = result.data.defaultRecordTypeId;
        } else {
            if (result.error) {
                console.log(result.error + ' LEAD OBJECT RECORD TYPE');
            }
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: RFI_OBJECT,
        recordTypeId: '$rfi_controller_default_record_type'
    })
    picklist_values2(result) {
        if (result.data) {
            this.state_picklist_values = result.data.picklistFieldValues.State__c.values;
            this.school_picklist = result.data.picklistFieldValues.School_College__c.values;
        } else {
            if (result.error) {
                console.log(result.error + ' RFI CONTROLLER OBJECT');
            }
        }
    }

    @wire(getRecordCreateDefaults, {objectApiName: LEAD_OBJECT, optionalFields: ADDITIONAL_FIELDS})
    output(result) {
        if (result.data) {
            this.record_input = generateRecordInputForCreate(result.data.record);
            getPresetValues({rfi_controller_name: this.rfi_controller})
                .then(preset_values => {
                    for (const preset_value of preset_values) {
                        if (this.all_lead_field_api_names.includes(preset_value.Field_API_Name__c)) {
                            this.record_input.fields[preset_value.Field_API_Name__c] = preset_value.Value__c;
                        }
                    }
                })
                .catch(error => {
                    console.log(error);
                });
        } else {
            if (result.error) {
                console.log(result.error);
            }
        }
    }

    /**
     ******************************************
     * END Wires
     ******************************************
     ******************************************
     * Begin OnChange
     ******************************************
     */

    onChange(event) {
        if (event.detail.addquestion) {
            if (this.additional_questions[event.detail.questionid].questionType.toLowerCase() !== 'static content') {
                //console.log(JSON.stringify(this.additional_questions[event.detail.questionid], null, 2))
                let fieldToApplyTo = this.additional_questions[event.detail.questionid].fieldToApplyTo;
                this.record_input.fields[fieldToApplyTo] = event.detail.value;
            }
        } else {
        switch (event.target.label) {
            case this.field_labels.first_name_label:
                this.record_input.fields.FirstName = event.target.value;
                break;
            case this.field_labels.last_name_label:
                this.record_input.fields.LastName = event.target.value;
                break;
            case this.field_labels.email_label:
                this.record_input.fields.Email = event.target.value;
                break;
            case this.field_labels.home_phone_label:
                this.record_input.fields.Phone = event.target.value;
                break;
            case this.field_labels.mobile_phone_label:
                this.record_input.fields.MobilePhone = event.target.value;
                break;
            case this.field_labels.phone_label:
                this.record_input.fields.MobilePhone = event.target.value;
                break;
            case this.field_labels.address1_label:
                this.address1 = event.target.value;
                break;
            case this.field_labels.address2_label:
                this.address2 = event.target.value;
                break;
            case this.field_labels.address3_label:
                this.address3 = event.target.value;
                break;
            case this.field_labels.city_label:
                this.record_input.fields.City = event.target.value;
                break;
            case this.field_labels.state_label:
                this.record_input.fields.State = event.target.value;
                break;
            case this.field_labels.region_label:
                this.record_input.fields.State = ''; //event.target.value;
                break;
            case this.field_labels.zipcode_label:
                this.record_input.fields.PostalCode = event.target.value;
                if (String(event.target.value).length === 5
                    && String(event.target.value).match(/^[0-9]+$/) != null
                    && !this.international_citizen_type
                ) {
                    this.populateUSCityStateAndCountry(event.target.value);
                }
                break;
            case this.field_labels.country_label:
                this.record_input.fields.Country = event.target.options.find(opt => opt.value === event.detail.value).label;
                this.record_input.fields.CountryCode = event.target.value;
                    this.international_citizen_type = !this.record_input.fields.Country.toLowerCase().startsWith('united states') && this.record_input.fields.Country.toLowerCase() !== 'us';
                break;
            case this.field_labels.text_messages_label:
                if (event.target.checked) {
                    this.record_input.fields.Receive_Texts__c = 'Yes';
                    this.text_message_requested = true;
                } else {
                    this.record_input.fields.Receive_Texts__c = 'No';
                    this.text_message_requested = this.require_fields.Mobile_Phone;
                }
                break;
            case this.field_labels.birthdate_label:
                this.record_input.fields.Birthdate__c = event.target.value;
                break;
            case this.field_labels.citizenship_label:
                this.record_input.fields.Citizenship_Type__c = event.target.value;
                    this.international_citizen_type = event.target.value === 'International';
                break;
            case this.field_labels.admit_type_label:
                this.record_input.fields.Admit_Type__c = event.target.value;
                    this.is_transfer = this.record_input.fields.Admit_Type__c === 'Transfer';
                break;
            case this.field_labels.academic_interest_label:
                    let academic_value = event.detail.value.toString();
                    //if the multi select pills groupable finds undecided it will append it to the front of the id
                    if (academic_value.toLowerCase().includes("undecided|")) {
                        academic_value = academic_value.replace("undecided|", "");
                        this.academic_undecided_selected = true;
                        this.single_selected_program = academic_value;
                    } else if (!academic_value) {
                        this.academic_undecided_selected = false;
                        this.single_selected_program = '';
                        this.academic_interest_id_list = null;
                    }
                    //if academic_value value is not a list assign the value to single selected program
                    if (!Array.isArray(event.detail.value) && academic_value) {
                        this.single_selected_program = academic_value;
                    } else {
                this.academic_interest_id_list = event.detail.value;
                    }
                break;
                case "What programs are you considering (max 3)?":
                    //Hard coded label for undecided academic interest. First value blank=
                    this.academic_interest_id_list = event.detail.value;
                    break
            case this.field_labels.academic_term_label:
                this.record_input.fields.Intended_Start_Term__c = event.target.value;
                this.record_input.fields.hed__Preferred_Enrollment_Date__c = this.term_id_to_name_map[event.target.value].Term_Start_Date__c;
                break;
            case this.field_labels.high_school_not_found_label:
                this.manually_enter_high_school = event.target.checked;
                if (event.target.checked) {
                    this.record_input.fields.High_School_or_College__c = '';
                    this.high_school_search_results = null;
                    this.high_school_data = false;
                }
                break;
            case this.field_labels.college_not_found_label:
                this.manually_enter_high_school = event.target.checked;
                if (event.target.checked) {
                    this.record_input.fields.High_School_or_College__c = '';
                    this.high_school_search_results = null;
                    this.high_school_data = false;
                }
                break;
            case this.field_labels.high_school_search_label:
                if (this.manually_enter_high_school) {
                    this.record_input.fields.hed__Most_Recent_School__c = event.detail.value;
                } else {
                this.record_input.fields.High_School_or_College__c = event.detail.id;
                    this.record_input.fields.hed__Most_Recent_School__c = event.detail.mainField;
                }
                break;
            case this.field_labels.college_search_label:
                if(this.manually_enter_high_school) {
                    this.record_input.fields.hed__Most_Recent_School__c = event.detail.value;
                } else {
                    this.record_input.fields.High_School_or_College__c = event.detail.id;
                    this.record_input.fields.hed__Most_Recent_School__c = event.detail.mainField;
                }
                break;
            case this.field_labels.employer_label:
                this.record_input.fields.Company = event.target.value;
                break;
            case this.field_labels.title_label:
                this.record_input.fields.Title = event.target.value;
                break;
            case this.field_labels.high_school_graduation_year_label:
                this.record_input.fields.Expected_Graduate_Date__c = event.target.value;
                break;
            case this.field_labels.timeline_label:
                this.record_input.fields.Timeline__c = event.target.value;
                break;
            case this.field_labels.has_question_label:
                this.record_input.fields.Has_Question__c = event.target.checked;
                this.show_fields.Description = event.target.checked;
                break;
            case this.field_labels.description_label:
                this.have_a_question = event.target.value;
                break;
            case this.field_labels.how_did_you_hear_about_us:
                this.record_input.fields.Heard_About_Us__c = event.target.value;
                    break;
            case this.field_labels.mail_info_label:
                this.record_input.fields.Mail_Information_Requested__c = event.target.checked;
                break;
            case this.field_labels.st_thomas_colleges:
                this.school_college = event.target.value;
                break;
            case this.field_labels.scholarship_of_interest:
                this.record_input.fields.Scholarship_of_Interest__c = event.target.value;
                break;
            case this.field_labels.tell_us_about_yourself:
                this.tell_us_about = event.target.value;
                break;
            default:
                break;
        }

        if (event.target.name === this.field_labels.high_school_datatable_name) {
            let selected_row = this.template.querySelector('lightning-datatable').getSelectedRows();
            this.record_input.fields.High_School_or_College__c = selected_row[0].account_id;
            this.template.querySelector('lightning-input[data-id="high_school"]').value = selected_row[0].name;
        }
    }
    }

    errors = [];

    checkForErrors() {
        this.errors = [];
        const selection = this.template.querySelector('c-lookup').getSelection();
        // Custom validation rule
        if (this.isMultiEntry && selection.length > this.maxSelectionSize) {
            this.errors.push({message: `You may only select up to ${this.maxSelectionSize} items.`});
        }
        // Enforcing required field
        if (selection.length === 0) {
            this.errors.push({message: 'Please make a selection.'});
        }
    }

    /**
     ******************************************
     * END OnChange
     ******************************************
     ******************************************
     * Begin OnClick
     ******************************************
     */

    handleSubmit() {

        if (this.validateInput()) {
            this.show_fields.show_spinner = true;
            this.record_input.fields.OwnerId = this.lead_owner;
            this.record_input.fields.LeadSource = this.lead_source;

            //Marketing google analytic data from URL params
            this.record_input.fields.utm_campaign__c = this.utm_campaign;
            this.record_input.fields.utm_medium__c = this.utm_medium;
            this.record_input.fields.utm_term__c = this.utm_term;
            this.record_input.fields.utm_source__c = this.utm_source;
            this.record_input.fields.utm_content__c = this.utm_content;
            this.record_input.fields.utm_id__c = this.utm_id;
            this.record_input.fields.utm_creative_format__c = this.utm_creative_format;
            this.record_input.fields.utm_marketing_topic__c = this.utm_marketing_topic;
            this.record_input.fields.utm_source_platform__c = this.utm_source_platform;
            this.record_input.fields.nominator_contact__c = this.sfcid;
            this.record_input.fields.gclid__c = this.gclid;
            this.record_input.fields.Lead_Website__c = window.location.href;
            this.record_input.fields.Lead_Website_Referrer__c = document.referrer;

            //Populate the description field for long answers
            if (!Boolean(this.record_input.fields.Company)) {
                this.record_input.fields.Company = 'No Company';
            }

            this.record_input.fields.Description = '';
            if (Boolean(this.have_a_question)) {
                this.record_input.fields.Description += '\n\nQuestions/Comments from RFI: \n' + this.have_a_question;
            }
            if (Boolean(this.tell_us_about)) {
                this.record_input.fields.Description += '\n\nTell us about yourself from RFI: \n' + this.tell_us_about;
            }

            this.record_input.fields.Inquiry_Date__c = this.getTodaysDate();
            this.handleStreetAddress();

            getSchoolCollegeAccount({school_college_name: this.school_college})
                .then(school_college_account_id => {
                    if (Boolean(school_college_account_id)) {
                        this.record_input.fields.St_Thomas_College_School__c = school_college_account_id;
                    }
                })
                .catch(error => {
                    console.log(error);
                })
            this.handleRecruitmentProgram();
        }
    }

    /**
     ******************************************
     * END OnClick
     ******************************************
     */

    /**
     ******************************************
     * BEGIN Helper Methods
     ******************************************
     */

    handleRecruitmentProgram() {
        //if (this.is_undergraduate) {
        let count = 0;
        //Apply the single record if undecided in play
        if (this.single_selected_program) {
            this.record_input.fields.Major_Program__c = this.single_selected_program;
            count = 1;
        }
        for (const program_id of this.academic_interest_id_list) {
            //If undecided is selected assign to recruitment program (Major_Program__c)
            if (count === 0) {
                this.record_input.fields.Major_Program__c = program_id;
            } else if (count === 1) {
                this.record_input.fields.Major_Program_2__c = program_id;
            } else if (count === 2) {
                this.record_input.fields.Major_Program_3__c = program_id;
            } else {
                this.record_input.fields.Major_Program_4__c = program_id;
            }
            count++;
        }
        getRecruitmentProgram({
            academic_level: this.academic_level_api,
            citizenship_type: this.record_input.fields.Citizenship_Type__c,
            admit_type: this.record_input.fields.Admit_Type__c,
            major_id: this.record_input.fields.Major_Program__c,
            school_name: this.school_college
        })
            .then(program => {
                if (Boolean(program)) {
                    this.record_input.fields.Recruitment_Program__c = String(program);
                }
                this.createLead();
            })
            .catch(error => {
                console.log(error);
                this.createLead();
            });
    }

    // Create the lead record
    createLead() {
        createLead({
            record: JSON.stringify(this.record_input.fields),
            objectApiName: 'Lead',
            rfiController: this.rfi_controller
        })
            .then(() => {
                if (this.redirect_after_submit) {
                    window.open(this.redirect_url, '_self');
                }
                this.show_fields.show_spinner = false;
                this.form_submitted_successfully = true;
            })
            .catch(error => {
                console.log(error);
                this.show_fields.show_spinner = false;
            });
    }

    // used Fields_to_Display__c field on RFI_Controller__c to determine which fields to display on form
    handleFieldsToDisplay() {
        let fields = this.fields_to_display.split(';');
        for (const field of fields) {
            let object_property = field.replaceAll(' ', '_');
            this.show_fields[object_property] = true;
        }
    }

    handleRequiredFields() {
        const fields = this.required_fields.split(';');
        for (const field of fields) {
            const object_property = field.replaceAll(' ', '_');
            this.require_fields[object_property] = true;
        }
    }

    validateInput() {
        return this.validateFields();
    }

    validateFields() {
        let isChildValidated = true;
        [...this.template.querySelectorAll("c-reusable-lookup, c-multi-select-pills-groupable")].forEach((element) => {
            if (element.checkValidity() === false) {
                isChildValidated = false;
            }
        });

        const allValid = [
            ...this.template.querySelectorAll('lightning-combobox, lightning-dual-listbox, lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid && isChildValidated) {
            return true;
        } else {
            this.template.querySelector('.slds-has-error').scrollIntoView();
            return false;
        }
    }

    handleStreetAddress() {
        if (Boolean(this.address1) && Boolean(this.address2) && Boolean(this.address3)) {
            this.record_input.fields.Street = this.address1 + ', ' + this.address2 + ', ' + this.address3;
        } else if (Boolean(this.address1) && Boolean(this.address2)) {
            this.record_input.fields.Street = this.address1 + ', ' + this.address2;
        } else if (Boolean(this.address1)) {
            this.record_input.fields.Street = this.address1;
        }
    }

    getTodaysDate() {
        const date = new Date();
        let day = String(date.getDate());
        let month = String(date.getMonth() + 1);
        let year = String(date.getFullYear());
        return year + '-' + month + '-' + day;
    }

    handleSelectionChange(event) {
        event.stopPropagation();
        const detail = event.detail;
        //semi-colon seperated string
        const selectedValue = detail.value;
    }

    // Openstreetmap API to get city, state, and country from zipcode
    populateUSCityStateAndCountry(zipcode) {
        this.show_fields.show_spinner = true;
        let url = 'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&addressdetails=1&postalcode=' + String(zipcode) + '&countrycodes=US';
        fetch(url)
            .then((response) => response.json())
            .then((result) => {
                let city = result[0].address.city;
                if (city == null) {
                    city = result[0].address.hamlet;
                }
                if (city == null) {
                    city = result[0].address.town;
                }
                if (city == null) {
                    city = result[0].address.municipality;
                }

                let state = result[0].address.state;
                if (state == null) {
                    state = result[0].address.county;
                }

                if (this.show_fields.City) {
                    this.template.querySelector('lightning-input[data-id="city"]').value = city;
                    this.record_input.fields.City = city;
                }
                if (this.show_fields.State) {
                    let state_map = this.getStateMap();
                    this.template.querySelector('lightning-combobox[data-id="state"]').value = state_map.get(state);
                    this.record_input.fields.State = state_map.get(state);
                }
                if (this.show_fields.Country) {
                    this.template.querySelector('lightning-combobox[data-id="country"]').value = 'United States of America';
                    this.record_input.fields.Country = 'United States of America';
                }
                this.show_fields.show_spinner = false;
            })
            .catch((error) => {
                console.log(error);
                this.show_fields.show_spinner = false;
            })
    }

    // Map of US states to abbreviations to match Openstreetmap API
    getStateMap() {
        let state_map = new Map();
        state_map.set('Alabama', 'AL');
        state_map.set('Alaska', 'AK');
        state_map.set('American Samoa', 'AS');
        state_map.set('Arizona', 'AZ');
        state_map.set('Arkansas', 'AK');
        state_map.set('Armed Forces the Americas', 'AA');
        state_map.set('Armed Forces Europe', 'AE');
        state_map.set('Armed Forces Pacific', 'AP');
        state_map.set('California', 'CA');
        state_map.set('Colorado', 'CO');
        state_map.set('Connecticut', 'CT');
        state_map.set('Delaware', 'DE');
        state_map.set('District of Columbia', 'DC');
        state_map.set('Micronesia', 'FM');
        state_map.set('Florida', 'FL');
        state_map.set('Georgia', 'GA');
        state_map.set('Guam', 'Guam');
        state_map.set('Hawaii', 'HI');
        state_map.set('Idaho', 'ID');
        state_map.set('Illinois', 'IL');
        state_map.set('Indiana', 'IN');
        state_map.set('Iowa', 'IA');
        state_map.set('Kansas', 'KS');
        state_map.set('Kentucky', 'KY');
        state_map.set('Louisiana', 'LA');
        state_map.set('Maine', 'ME');
        state_map.set('Marshall Islands', 'MH');
        state_map.set('Maryland', 'MD');
        state_map.set('Massachusetts', 'MA');
        state_map.set('Michigan', 'MI');
        state_map.set('Minnesota', 'MN');
        state_map.set('Mississippi', 'MS');
        state_map.set('Missouri', 'MO');
        state_map.set('Montana', 'MT');
        state_map.set('Nebraska', 'NE');
        state_map.set('Nevada', 'NV');
        state_map.set('New Hampshire', 'NH');
        state_map.set('New Jersey', 'NJ');
        state_map.set('New Mexico', 'NM');
        state_map.set('New York', 'NY');
        state_map.set('North Carolina', 'NC');
        state_map.set('North Dakota', 'ND');
        state_map.set('Northern Mariana Islands', 'MP');
        state_map.set('Ohio', 'OH');
        state_map.set('Oklahoma', 'OK');
        state_map.set('Oregon', 'OR');
        state_map.set('Palau', 'PW');
        state_map.set('Pennsylvania', 'PA');
        state_map.set('Puerto Rico', 'PR');
        state_map.set('Rhode Island', 'RI');
        state_map.set('South Carolina', 'SC');
        state_map.set('South Dakota', 'SD');
        state_map.set('Tennessee', 'TN');
        state_map.set('Texas', 'TX');
        state_map.set('Utah', 'UT');
        state_map.set('Vermont', 'VT');
        state_map.set('Virgin Islands', 'VI');
        state_map.set('Virginia', 'VA');
        state_map.set('Washington', 'WA');
        state_map.set('West Virginia', 'WV');
        state_map.set('Wisconsin', 'WI');
        state_map.set('Wyoming', 'WY');
        return state_map;
    }

    /**
     ******************************************
     * END Helper Methods
     ******************************************
     */
}