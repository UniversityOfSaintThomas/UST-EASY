import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRequirementItemConfig from '@salesforce/apex/EasyRelatedObjectController.getRequirementItemConfig';
import getExistingRelatedRecords from '@salesforce/apex/EasyRelatedObjectController.getExistingRelatedRecords';
import saveRelatedRecord from '@salesforce/apex/EasyRelatedObjectController.saveRelatedRecord';
import deleteRelatedRecord from '@salesforce/apex/EasyRelatedObjectController.deleteRelatedRecord';
import uploadSupportingDocument from '@salesforce/apex/EasyRelatedObjectController.uploadSupportingDocument';

/** Field types considered "numeric" for lightning-input type="number". */
const NUMERIC_FIELD_TYPES = new Set(['Number', 'Currency', 'Percent', 'Decimal', 'Integer', 'Double']);

/** Field types that use a multi-value (semicolon-delimited) storage. */
const MULTI_PICKLIST_TYPES = new Set(['MultiPicklist', 'Multi_Select_Picklist', 'MultiSelect']);

/** Field types that render a lightning-textarea. */
const TEXT_AREA_TYPES = new Set(['TextArea', 'LongTextArea', 'RichText']);

/**
 * Range validations available via Question__c.Additional_Field_Validation__c.
 * Mirrors the minMaxMap in EasyAppResources/js/easyFormValidation.js, which drives the
 * equivalent CSS-class-based validation for the VF-rendered (non-related-object) forms.
 * Keep these two maps in sync if the allowed range values ever change.
 */
const ADDITIONAL_VALIDATION_RANGES = {
    validateACT: { min: 0, max: 36 },
    validateSATComposite: { min: 0, max: 1600 },
    validateSATSubject: { min: 0, max: 800 },
    validateAge: { min: 0, max: 120 }
};

/**
 * @description Checks whether a single Question_Dependency rule is satisfied by the current draft values.
 *
 * @param {object} dep                  - QuestionDependencyDTO from Apex
 * @param {object} questionFieldMap     - Map of questionId -> fieldApiName for all questions in the form
 * @param {object} draftValues          - Current draft values keyed by fieldApiName
 * @returns {boolean} True when the dependency condition is met
 */
function checkDependencySatisfied(dep, questionFieldMap, draftValues) {
    const controllingFieldApiName = questionFieldMap[dep.controllingQuestionId];
    if (!controllingFieldApiName) {
        // Controlling question not in this form — do not block visibility
        return true;
    }
    const currentValue = draftValues[controllingFieldApiName];

    if (dep.dependencyType === 'Checkbox') {
        return Boolean(currentValue) === Boolean(dep.valueCheckbox);
    }
    if (dep.dependencyType === 'Picklist' || dep.dependencyType === 'Radio') {
        const currentString = currentValue !== null && currentValue !== undefined ? String(currentValue) : '';
        return currentString !== '' && currentString === (dep.value || '');
    }
    if (dep.dependencyType === 'Multi_Select_Picklist') {
        if (currentValue && dep.value) {
            const currentItems = new Set(String(currentValue).split(';'));
            return String(dep.value).split(';').some(depValue => currentItems.has(depValue));
        }
        return false;
    }
    // Unknown dependency type — do not block
    return true;
}

/**
 * @description Computes a visibility map for all questions based on their dependency rules
 *              and the current draft/field values.  Mirrors ApplicationQuestion.getShowQuestion()
 *              AND/OR/Behavior logic from the VF implementation.
 *
 * @param {Array} questions   - Array of QuestionConfigDTO
 * @param {object} fieldValues - Current field values keyed by fieldApiName
 * @returns {object} Object keyed by questionId; value is boolean (true = visible)
 */
function computeQuestionVisibility(questions, fieldValues) {
    // Build questionId -> fieldApiName map for controlling-question lookups
    const questionFieldMap = {};
    for (const question of questions) {
        if (question.questionId && question.fieldApiName) {
            questionFieldMap[question.questionId] = question.fieldApiName;
        }
    }

    const visibility = {};
    for (const question of questions) {
        if (!question.dependencies || question.dependencies.length === 0) {
            visibility[question.questionId] = true;
            continue;
        }

        const isAndLogic = !question.dependencyLogic || question.dependencyLogic === 'AND';
        let satisfied;

        if (isAndLogic) {
            satisfied = true;
            for (const dep of question.dependencies) {
                if (!checkDependencySatisfied(dep, questionFieldMap, fieldValues)) {
                    satisfied = false;
                    break;
                }
            }
        } else {
            // OR logic
            satisfied = false;
            for (const dep of question.dependencies) {
                // Controlling question not in this form -> treat as satisfied
                if (!questionFieldMap[dep.controllingQuestionId]) {
                    satisfied = true;
                    break;
                }
                if (checkDependencySatisfied(dep, questionFieldMap, fieldValues)) {
                    satisfied = true;
                    break;
                }
            }
        }

        // Apply behavior: 'Show' (default) -> show when satisfied; 'Hide' -> show when NOT satisfied
        const isShowBehavior = !question.dependencyBehavior || question.dependencyBehavior === 'Show';
        visibility[question.questionId] = isShowBehavior ? satisfied : !satisfied;
    }
    return visibility;
}

/**
 * @description Derives a boolean type flag map from a question fieldType string.
 *
 * @param {string} fieldType - The DeveloperName of the question record type (e.g. "Text", "Picklist")
 * @returns {object} Map of isText, isPhone, isTextArea, isNumeric, isDate, isCheckbox,
 *                   isPicklist, isMultiPicklist, isReference, isAddress flags
 */
function buildFieldTypeFlags(fieldType) {
    return {
        isText: fieldType === 'Text' || fieldType === 'TextSingle',
        isPhone: fieldType === 'Phone',
        isTextArea: TEXT_AREA_TYPES.has(fieldType),
        isNumeric: NUMERIC_FIELD_TYPES.has(fieldType),
        isDate: fieldType === 'Date' || fieldType === 'DateTime',
        isCheckbox: fieldType === 'Checkbox' || fieldType === 'Boolean',
        isPicklist: fieldType === 'Picklist' || fieldType === 'Select' || fieldType === 'Radio',
        isMultiPicklist: MULTI_PICKLIST_TYPES.has(fieldType),
        isReference: fieldType === 'Reference' || fieldType === 'Lookup',
        isAddress: fieldType === 'Address'
    };
}

/**
 * @description Converts a raw field value from Apex into a display-safe string.
 *
 * @param {*} rawValue - The value from fieldValues map
 * @param {string} fieldType - The question field type DeveloperName
 * @returns {string} A human-readable string for view mode
 */
function formatDisplayValue(rawValue, fieldType) {
    if (rawValue === null || rawValue === undefined) {
        return '';
    }
    if (fieldType === 'Checkbox' || fieldType === 'Boolean') {
        return rawValue ? 'Yes' : 'No';
    }
    if (fieldType === 'Date') {
        // Apex serialises Date fields as a bare "YYYY-MM-DD" string with no time/timezone.
        // new Date("YYYY-MM-DD") parses that as UTC midnight, so toLocaleDateString() in any
        // timezone behind UTC rolls it back a day. Parse the components as a local date instead.
        const dateMatch = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(rawValue));
        if (dateMatch) {
            const [, year, month, day] = dateMatch;
            return new Date(Number(year), Number(month) - 1, Number(day)).toLocaleDateString();
        }
        return String(rawValue);
    }
    if (fieldType === 'DateTime') {
        try {
            return new Date(rawValue).toLocaleDateString();
        } catch {
            return String(rawValue);
        }
    }
    return String(rawValue);
}

/**
 * @description Builds an array of view-mode rows for a related record,
 *              one row per visible question (excluding hardcoded questions, Address sub-fields,
 *              and questions hidden by dependency rules).
 *
 * @param {object} relatedRecord     - RelatedRecordDTO from Apex
 * @param {Array} questions          - Array of QuestionConfigDTO
 * @param {object} questionVisibility - Map of questionId -> boolean from computeQuestionVisibility
 * @returns {Array} Array of { fieldApiName, label, displayValue } objects
 */
function buildViewRows(relatedRecord, questions, questionVisibility) {
    const visibility = questionVisibility || {};
    const rows = [];
    let hasAddressQuestion = false;

    for (const question of questions) {
        if (question.hardcodedValue) {
            continue; // Hidden from applicant
        }
        if (question.isNewReferenceField) {
            continue;
        }
        // Skip questions hidden by dependency rules
        if (Object.prototype.hasOwnProperty.call(visibility, question.questionId)
                && visibility[question.questionId] === false) {
            continue;
        }

        const typeFlags = buildFieldTypeFlags(question.fieldType);

        if (typeFlags.isAddress) {
            if (!hasAddressQuestion) {
                hasAddressQuestion = true;
                const streetValue = relatedRecord.fieldValues['Street__c'] || '';
                const cityValue = relatedRecord.fieldValues['City__c'] || '';
                const stateValue = relatedRecord.fieldValues['State__c'] || '';
                const postalCodeValue = relatedRecord.fieldValues['PostalCode__c'] || '';
                const countryValue = relatedRecord.fieldValues['Country__c'] || '';
                const addressParts = [streetValue, cityValue, stateValue, postalCodeValue, countryValue]
                    .filter(part => part !== '');
                rows.push({
                    fieldApiName: question.fieldApiName,
                    label: question.label,
                    displayValue: addressParts.join(', ')
                });
            }
            continue;
        }

        if (typeFlags.isReference) {
            const lookupNames = relatedRecord.lookupDisplayNames || {};
            const displayValue = lookupNames[question.fieldApiName]
                || relatedRecord.holdingName
                || formatDisplayValue(relatedRecord.fieldValues[question.fieldApiName], question.fieldType);
            rows.push({ fieldApiName: question.fieldApiName, label: question.label, displayValue });
            continue;
        }

        rows.push({
            fieldApiName: question.fieldApiName,
            label: question.label,
            displayValue: formatDisplayValue(relatedRecord.fieldValues[question.fieldApiName], question.fieldType)
        });
    }

    return rows;
}

/**
 * @description Builds an array of edit-form rows for a question list and a set of draft values.
 *              Each row contains all metadata needed to render the appropriate input in the template.
 *              Questions hidden by dependency rules are excluded from the output.
 *
 * @param {Array} questions          - Array of QuestionConfigDTO
 * @param {object} draftValues       - Current draft values keyed by fieldApiName
 * @param {string} applicationStatus - Current application status (used for required-field computation)
 * @param {object} questionVisibility - Map of questionId -> boolean from computeQuestionVisibility
 * @returns {Array} Array of decorated question objects ready for the form template
 */
function buildEditRows(questions, draftValues, applicationStatus, questionVisibility) {
    const visibility = questionVisibility || {};
    const rows = [];

    for (const question of questions) {
        if (question.hardcodedValue) {
            continue; // Set server-side; not shown in the form
        }
        if (question.isNewReferenceField) {
            continue;
        }
        // Skip questions hidden by dependency rules
        if (Object.prototype.hasOwnProperty.call(visibility, question.questionId)
                && visibility[question.questionId] === false) {
            continue;
        }

        const typeFlags = buildFieldTypeFlags(question.fieldType);
        const currentRaw = draftValues[question.fieldApiName];
        const isRequired = question.requiredStatuses
            ? question.requiredStatuses.split(';').some(status => status.trim() === applicationStatus)
            : false;

        // The configured name field may be a comma-separated list (e.g. "Name, BillingCity, BillingState").
        // The reusable lookup treats field-api-name as a single searchable field and other-field-api-name
        // as the extra display fields, so split accordingly.
        const nameFieldParts = String(question.nameFieldApiName || 'Name')
            .split(',')
            .map(field => field.trim())
            .filter(field => field !== '');
        const lookupSearchField = nameFieldParts[0] || 'Name';
        const lookupDisplayFields = nameFieldParts.slice(1).join(', ');

        // Build the current multi-value as an array (split on semicolon)
        const currentMultiValue = typeFlags.isMultiPicklist && currentRaw
            ? String(currentRaw).split(';').filter(value => value.trim() !== '')
            : [];

        // Address sub-field values for Address type
        const streetValue = typeFlags.isAddress ? (draftValues['Street__c'] || '') : '';
        const cityValue = typeFlags.isAddress ? (draftValues['City__c'] || '') : '';
        const stateValue = typeFlags.isAddress ? (draftValues['State__c'] || '') : '';
        const postalCodeValue = typeFlags.isAddress ? (draftValues['PostalCode__c'] || '') : '';
        const countryValue = typeFlags.isAddress ? (draftValues['Country__c'] || '') : '';

        rows.push({
            questionId: question.questionId,
            label: question.label,
            helpText: question.helpText,
            fieldApiName: question.fieldApiName,
            fieldType: question.fieldType,
            isRequired,
            lookupObjectType: question.lookupObjectType,
            nameFieldApiName: question.nameFieldApiName || 'Name',
            lookupSearchField,
            lookupDisplayFields,
            picklistOptions: question.picklistOptions || [],
            currentValue: currentRaw !== null && currentRaw !== undefined ? String(currentRaw) : '',
            currentValueChecked: Boolean(currentRaw),
            currentMultiValue,
            streetValue,
            cityValue,
            stateValue,
            postalCodeValue,
            countryValue,
            ...typeFlags
        });
    }

    return rows;
}

/**
 * @description Initialises a blank draft-values object from a question list.
 *              Sets empty strings / false for each question field so the form starts clean.
 *
 * @param {Array} questions - Array of QuestionConfigDTO
 * @returns {object} Object keyed by fieldApiName with empty/default values
 */
function buildEmptyDraftValues(questions) {
    const draft = {};
    for (const question of questions) {
        if (question.hardcodedValue || question.isNewReferenceField) {
            continue;
        }
        const typeFlags = buildFieldTypeFlags(question.fieldType);
        if (typeFlags.isCheckbox) {
            draft[question.fieldApiName] = false;
        } else {
            draft[question.fieldApiName] = '';
        }
    }
    return draft;
}

/**
 * @description Validates the draft values against the required questions for the given status.
 *              Questions hidden by dependency rules are excluded from validation.
 *              Returns an array of missing field labels.
 *
 * @param {Array} questions          - Array of QuestionConfigDTO
 * @param {object} draftValues       - Current draft values
 * @param {string} applicationStatus - Current application status
 * @param {object} questionVisibility - Map of questionId -> boolean from computeQuestionVisibility
 * @returns {string[]} Array of labels for fields that fail validation
 */
function validateDraftValues(questions, draftValues, applicationStatus, questionVisibility) {
    const visibility = questionVisibility || {};
    const missingLabels = [];
    for (const question of questions) {
        if (question.hardcodedValue || question.isNewReferenceField) {
            continue;
        }
        // Skip validation for dependency-hidden questions
        if (Object.prototype.hasOwnProperty.call(visibility, question.questionId)
                && visibility[question.questionId] === false) {
            continue;
        }
        const isRequired = question.requiredStatuses
            ? question.requiredStatuses.split(';').some(status => status.trim() === applicationStatus)
            : false;

        if (!isRequired) {
            continue;
        }

        const value = draftValues[question.fieldApiName];
        if (value === null || value === undefined || value === '' || value === false) {
            missingLabels.push(question.label);
        }
    }
    return missingLabels;
}

/**
 * @description Validates the numeric range configured via Question__c.Additional_Field_Validation__c
 *              (validateACT, validateSATComposite, validateSATSubject, validateAge). Only checks
 *              fields that currently have a value — blank optional fields are left to
 *              validateDraftValues() for required-field checking. Questions hidden by dependency
 *              rules are excluded, matching validateDraftValues().
 *
 * @param {Array} questions           - Array of QuestionConfigDTO
 * @param {object} draftValues        - Current draft values keyed by fieldApiName
 * @param {object} questionVisibility - Map of questionId -> boolean from computeQuestionVisibility
 * @returns {string[]} Human-readable error messages for out-of-range values
 */
function validateRangeValues(questions, draftValues, questionVisibility) {
    const visibility = questionVisibility || {};
    const errors = [];
    // eslint-disable-next-line no-console
    console.log('DEBUG validateRangeValues CALLED, questionCount=', questions ? questions.length : 'null');
    for (const question of questions) {
        const range = ADDITIONAL_VALIDATION_RANGES[question.additionalFieldValidation];
        if (!range) {
            continue;
        }
        // eslint-disable-next-line no-console
        console.log('DEBUG validateRangeValues question=', question.label,
            'afv=', question.additionalFieldValidation,
            'hardcodedValue=', question.hardcodedValue,
            'isNewReferenceField=', question.isNewReferenceField,
            'visibility=', visibility[question.questionId],
            'rawValue=', draftValues[question.fieldApiName],
            'fieldApiName=', question.fieldApiName);
        if (question.hardcodedValue || question.isNewReferenceField) {
            continue;
        }
        if (Object.prototype.hasOwnProperty.call(visibility, question.questionId)
                && visibility[question.questionId] === false) {
            continue;
        }
        const rawValue = draftValues[question.fieldApiName];
        if (rawValue === null || rawValue === undefined || rawValue === '') {
            continue;
        }
        const numericValue = Number(rawValue);
        // eslint-disable-next-line no-console
        console.log('DEBUG validateRangeValues numericValue=', numericValue, 'range=', JSON.stringify(range));
        if (Number.isNaN(numericValue) || numericValue < range.min || numericValue > range.max) {
            errors.push(question.label + ' must be between ' + range.min + ' and ' + range.max + '.');
        }
    }
    return errors;
}

export default class EasyRelatedObjectForm extends LightningElement {

    /** Id of the Requirement_Item__c record — passed from VF via apex:includeLightningComponent */
    @api requirementItemId;

    /** Id of the Application__c record */
    @api applicationId;

    /** Current Application_Status__c value (used to determine required fields) */
    @api applicationStatus = '';

    /** True when the overall form section is editable (group.isEditable) */
    @api isEditable = false;

    /** True when updates are blocked (e.g. application is submitted) */
    @api preventUpdates = false;

    // ── State ──────────────────────────────────────────────────────────────

    /** Configuration loaded from Apex (RequirementItemConfigDTO) */
    @track config = null;

    /** Existing related-object records, each decorated with UI state */
    @track relatedRecords = [];

    /** Whether the initial data load is in progress */
    isLoading = true;

    /** Top-level error message (load failures, delete errors) */
    errorMessage = '';

    /** Id of the record pending a delete confirmation; shows inline confirm UI when set */
    pendingDeleteRecordId = '';

    /** Whether the "new record" inline form is currently open */
    showNewRecordForm = false;

    /** Draft field values for the new-record form */
    @track newRecordDraftValues = {};

    /** Whether the new-record save is in progress */
    isNewRecordSaving = false;

    /** Top-level error for the new-record form */
    newRecordError = '';

    // ── Lifecycle ──────────────────────────────────────────────────────────

    connectedCallback() {
        this.loadData();
    }

    // ── Internal data loading ──────────────────────────────────────────────

    /**
     * @description Loads the requirement item config and existing records in parallel.
     */
    async loadData() {
        this.isLoading = true;
        this.errorMessage = '';
        try {
            const [configResult, recordsResult] = await Promise.all([
                getRequirementItemConfig({ requirementItemId: this.requirementItemId }),
                getExistingRelatedRecords({
                    requirementItemId: this.requirementItemId,
                    applicationId: this.applicationId
                })
            ]);
            // eslint-disable-next-line no-console
            console.log('DEBUG loadData raw configResult=', JSON.stringify(configResult));
            this.config = configResult;
            this.relatedRecords = this.buildInitialProcessedRecords(recordsResult || []);
        } catch (loadError) {
            this.errorMessage = this.extractErrorMessage(loadError);
        } finally {
            this.isLoading = false;
            this.fireRelatedObjectChangeEvent();
        }
    }

    /**
     * @description Reloads only the existing records (used after save/delete).
     *              Uses isLoading/errorMessage instead of ShowToastEvent because
     *              ShowToastEvent is silently dropped in this Lightning Out / VF page context.
     */
    async reloadRecords() {
        this.isLoading = true;
        this.errorMessage = '';
        try {
            const recordsResult = await getExistingRelatedRecords({
                requirementItemId: this.requirementItemId,
                applicationId: this.applicationId
            });
            this.relatedRecords = this.buildInitialProcessedRecords(recordsResult || []);
        } catch (reloadError) {
            this.errorMessage = this.extractErrorMessage(reloadError);
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * @description Converts raw RelatedRecordDTO array from Apex into decorated records
     *              with view/edit UI state.
     *
     * @param {Array} rawRecords - Array of RelatedRecordDTO from Apex
     * @returns {Array} Decorated record array
     */
    buildInitialProcessedRecords(rawRecords) {
        return rawRecords.map(rawRecord => ({
            ...rawRecord,
            isEditing: false,
            isSaving: false,
            editError: '',
            editDraftValues: { ...rawRecord.fieldValues },
            showUploadForm: false,
            isUploadLoading: false,
            uploadError: '',
            pendingFile: null
        }));
    }

    // ── Getters ────────────────────────────────────────────────────────────

    /**
     * @description True once the initial data load has completed without error.
     *
     * @returns {boolean}
     */
    get isLoaded() {
        return !this.isLoading && !this.errorMessage && this.config !== null;
    }

    /**
     * @description True when an error message is present.
     *
     * @returns {boolean}
     */
    get hasError() {
        return Boolean(this.errorMessage);
    }

    /**
     * @description Card title derived from the config item label or object API name.
     *
     * @returns {string}
     */
    get cardTitle() {
        if (!this.config) {
            return 'Loading\u2026';
        }
        return this.config.itemLabel || this.config.relatedObjectApiName || 'Related Records';
    }

    /**
     * @description True when instructions text is present and non-empty.
     *
     * @returns {boolean}
     */
    get hasInstructions() {
        return Boolean(this.config && this.config.instructions);
    }

    /**
     * @description True when a minimum child record count is configured.
     *
     * @returns {boolean}
     */
    get showRequiredCountMessage() {
        return this.config
            && this.config.requiredChildCount != null
            && this.config.requiredChildCount > 0;
    }

    /**
     * @description Pluralises "record" based on the required child count.
     *
     * @returns {string}
     */
    get requiredCountSuffix() {
        return this.config && this.config.requiredChildCount > 1 ? 's' : '';
    }

    /**
     * @description True when a maximum child record count is configured.
     *
     * @returns {boolean}
     */
    get showMaxCountMessage() {
        return this.config
            && this.config.maximumChildCount != null
            && this.config.maximumChildCount > 0;
    }

    /**
     * @description True when there are zero existing related records.
     *
     * @returns {boolean}
     */
    get hasZeroRecords() {
        return !this.isLoading && this.relatedRecords.length === 0;
    }

    /**
     * @description Current record count exposed for the hidden VF integration input.
     *
     * @returns {number}
     */
    get recordCount() {
        return this.relatedRecords.length;
    }

    /**
     * @description Builds a processed version of each record for template rendering.
     *              Includes viewRows, editRows, and UI state flags.
     *              Question visibility is computed from dependency rules on each call.
     *
     * @returns {Array}
     */
    get processedRecords() {
        if (!this.config || !this.relatedRecords) {
            return [];
        }
        return this.relatedRecords.map(record => {
            const editVisibility = computeQuestionVisibility(
                this.config.questions,
                record.editDraftValues || {}
            );
            const viewVisibility = computeQuestionVisibility(
                this.config.questions,
                record.fieldValues || {}
            );
            return {
                ...record,
                viewRows: buildViewRows(record, this.config.questions, viewVisibility),
                editRows: buildEditRows(this.config.questions, record.editDraftValues, this.applicationStatus, editVisibility),
                showEditActions: record.userCreated && this.isEditable && !this.preventUpdates,
                isPendingDelete: record.recordId === this.pendingDeleteRecordId,
                showUploadButton: (record.userCreated || record.recordId)
                    && this.config.allowSupportingDocumentationUpload
                    && (this.isEditable || Boolean(record.documentTitle))
            };
        });
    }

    /**
     * @description Builds form rows for the new-record form from current draft values.
     *              Question visibility is re-evaluated whenever draft values change.
     *
     * @returns {Array}
     */
    get newRecordRows() {
        if (!this.config) {
            return [];
        }
        const visibility = computeQuestionVisibility(this.config.questions, this.newRecordDraftValues);
        return buildEditRows(this.config.questions, this.newRecordDraftValues, this.applicationStatus, visibility);
    }

    /**
     * @description True when the "New Record" button should be visible.
     *
     * @returns {boolean}
     */
    get showNewRecordButton() {
        if (!this.isLoaded || !this.isEditable || this.preventUpdates || this.showNewRecordForm) {
            return false;
        }
        return this.config.maximumChildCount == null
            || this.relatedRecords.length < this.config.maximumChildCount;
    }

    /**
     * @description Accepted file type string for the file upload input.
     *
     * @returns {string}
     */
    get acceptedFileTypes() {
        return this.config ? (this.config.fileTypes || '') : '';
    }

    // ── Handlers: existing record CRUD ────────────────────────────────────

    /**
     * @description Enters edit mode for an existing record row.
     *
     * @param {Event} event - Click event; reads data-recordid from target
     */
    handleEditRecord(event) {
        const targetRecordId = event.target.dataset.recordid;
        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return {
                    ...record,
                    isEditing: true,
                    editDraftValues: { ...record.fieldValues },
                    editError: ''
                };
            }
            return record;
        });
    }

    /**
     * @description Cancels edit mode for a record, discarding draft changes.
     *
     * @param {Event} event - Click event; reads data-recordid from target
     */
    handleCancelEdit(event) {
        const targetRecordId = event.target.dataset.recordid;
        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return { ...record, isEditing: false, editError: '', editDraftValues: { ...record.fieldValues } };
            }
            return record;
        });
    }

    /**
     * @description Saves an existing record's draft values to Apex, then reloads the list.
     *
     * @param {Event} event - Click event; reads data-recordid from target
     */
    async handleSaveRecord(event) {
        const targetRecordId = event.target.dataset.recordid;
        const recordToSave = this.relatedRecords.find(record => record.recordId === targetRecordId);
        if (!recordToSave) {
            return;
        }

        const editVisibility = computeQuestionVisibility(this.config.questions, recordToSave.editDraftValues);
        const missingFieldLabels = validateDraftValues(
            this.config.questions,
            recordToSave.editDraftValues,
            this.applicationStatus,
            editVisibility
        );
        const rangeErrors = validateRangeValues(this.config.questions, recordToSave.editDraftValues, editVisibility);
        if (missingFieldLabels.length > 0 || rangeErrors.length > 0) {
            const errorMessages = [];
            if (missingFieldLabels.length > 0) {
                errorMessages.push('Please fill in required fields: ' + missingFieldLabels.join(', '));
            }
            errorMessages.push(...rangeErrors);
            this.relatedRecords = this.relatedRecords.map(record => {
                if (record.recordId === targetRecordId) {
                    return { ...record, editError: errorMessages.join(' ') };
                }
                return record;
            });
            return;
        }

        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return { ...record, isSaving: true, editError: '' };
            }
            return record;
        });

        try {
            await saveRelatedRecord({
                requirementItemId: this.requirementItemId,
                applicationId: this.applicationId,
                fieldValuesJson: JSON.stringify(recordToSave.editDraftValues),
                existingRecordId: targetRecordId
            });
            this.showToast('Success', 'Record saved successfully.', 'success');
            this.fireRelatedObjectChangeEvent();
            await this.reloadRecords();
        } catch (saveError) {
            this.relatedRecords = this.relatedRecords.map(record => {
                if (record.recordId === targetRecordId) {
                    return { ...record, isSaving: false, editError: this.extractErrorMessage(saveError) };
                }
                return record;
            });
        }
    }

    /**
     * @description Requests inline delete confirmation for a related record.
     *              Shows the confirm/cancel UI within the record row.
     *
     * @param {Event} event - Click event; reads data-recordid from target
     */
    handleDeleteRecord(event) {
        this.pendingDeleteRecordId = event.target.dataset.recordid;
    }

    /**
     * @description Cancels the pending delete without deleting.
     */
    handleCancelDelete() {
        this.pendingDeleteRecordId = '';
    }

    /**
     * @description Confirms and executes the pending delete operation.
     */
    async handleConfirmDelete() {
        const targetRecordId = this.pendingDeleteRecordId;
        this.pendingDeleteRecordId = '';
        try {
            await deleteRelatedRecord({
                recordId: targetRecordId,
                requirementItemId: this.requirementItemId,
                applicationId: this.applicationId
            });
            await this.reloadRecords();
            this.fireRelatedObjectChangeEvent();
        } catch (deleteError) {
            this.errorMessage = this.extractErrorMessage(deleteError);
        }
    }

    // ── Handlers: new record form ──────────────────────────────────────────

    /**
     * @description Opens the new-record inline form.
     */
    handleNewRecord() {
        this.newRecordDraftValues = buildEmptyDraftValues(this.config.questions);
        this.newRecordError = '';
        this.showNewRecordForm = true;
    }

    /**
     * @description Closes the new-record form without saving.
     */
    handleCancelNewRecord() {
        this.showNewRecordForm = false;
        this.newRecordDraftValues = {};
        this.newRecordError = '';
    }

    /**
     * @description Saves the new record to Apex, then reloads the list.
     */
    async handleSaveNewRecord() {
        const newRecordVisibility = computeQuestionVisibility(this.config.questions, this.newRecordDraftValues);
        const missingFieldLabels = validateDraftValues(
            this.config.questions,
            this.newRecordDraftValues,
            this.applicationStatus,
            newRecordVisibility
        );
        const rangeErrors = validateRangeValues(this.config.questions, this.newRecordDraftValues, newRecordVisibility);
        if (missingFieldLabels.length > 0 || rangeErrors.length > 0) {
            const errorMessages = [];
            if (missingFieldLabels.length > 0) {
                errorMessages.push('Please fill in required fields: ' + missingFieldLabels.join(', '));
            }
            errorMessages.push(...rangeErrors);
            this.newRecordError = errorMessages.join(' ');
            return;
        }

        this.isNewRecordSaving = true;
        this.newRecordError = '';
        try {
            await saveRelatedRecord({
                requirementItemId: this.requirementItemId,
                applicationId: this.applicationId,
                fieldValuesJson: JSON.stringify(this.newRecordDraftValues),
                existingRecordId: null
            });
            this.showToast('Success', 'Record saved successfully.', 'success');
            this.showNewRecordForm = false;
            this.newRecordDraftValues = {};
            await this.reloadRecords();
            this.fireRelatedObjectChangeEvent();
        } catch (saveError) {
            this.newRecordError = this.extractErrorMessage(saveError);
        } finally {
            this.isNewRecordSaving = false;
        }
    }

    // ── Handlers: field changes (existing record edit form) ───────────────

    /**
     * @description Updates the draft value for a text/select field in an existing record's edit form.
     *
     * @param {Event} event - Change event from lightning-input, lightning-textarea, or lightning-combobox
     */
    handleFieldChange(event) {
        const targetRecordId = event.target.dataset.recordid;
        const targetFieldName = event.target.dataset.fieldname;
        if (!targetRecordId || !targetFieldName) {
            return;
        }
        const newValue = event.target.value;
        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return {
                    ...record,
                    editDraftValues: { ...record.editDraftValues, [targetFieldName]: newValue }
                };
            }
            return record;
        });
    }

    /**
     * @description Updates the draft value for a checkbox in an existing record's edit form.
     *
     * @param {Event} event - Change event from lightning-input type="checkbox"
     */
    handleCheckboxChange(event) {
        const targetRecordId = event.target.dataset.recordid;
        const targetFieldName = event.target.dataset.fieldname;
        if (!targetRecordId || !targetFieldName) {
            return;
        }
        const newValue = event.target.checked;
        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return {
                    ...record,
                    editDraftValues: { ...record.editDraftValues, [targetFieldName]: newValue }
                };
            }
            return record;
        });
    }

    /**
     * @description Updates the draft value for a multi-picklist in an existing record's edit form.
     *              Converts the array value from lightning-dual-listbox to a semicolon-delimited string.
     *
     * @param {Event} event - Change event from lightning-dual-listbox
     */
    handleMultiPicklistChange(event) {
        const targetRecordId = event.target.dataset.recordid;
        const targetFieldName = event.target.dataset.fieldname;
        if (!targetRecordId || !targetFieldName) {
            return;
        }
        const newValue = Array.isArray(event.detail.value) ? event.detail.value.join(';') : '';
        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return {
                    ...record,
                    editDraftValues: { ...record.editDraftValues, [targetFieldName]: newValue }
                };
            }
            return record;
        });
    }

    /**
     * @description Handles a lookup selection from c-reusable-lookup inside an existing record's edit form.
     *              Stores the selected record's Id in the draft values.
     *
     * @param {CustomEvent} event - valueselected event from c-reusable-lookup
     */
    handleLookupValueSelected(event) {
        const targetRecordId = event.target.dataset.recordid;
        const targetFieldName = event.target.dataset.fieldname;
        if (!targetRecordId || !targetFieldName) {
            return;
        }
        const selectedId = event.detail.id || '';
        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return {
                    ...record,
                    editDraftValues: { ...record.editDraftValues, [targetFieldName]: selectedId }
                };
            }
            return record;
        });
    }

    // ── Handlers: field changes (new record form) ─────────────────────────

    /**
     * @description Updates a draft value in the new-record form for text/select fields.
     *
     * @param {Event} event - Change event from a form input
     */
    handleNewFieldChange(event) {
        const targetFieldName = event.target.dataset.fieldname;
        if (!targetFieldName) {
            return;
        }
        this.newRecordDraftValues = { ...this.newRecordDraftValues, [targetFieldName]: event.target.value };
    }

    /**
     * @description Updates a checkbox draft value in the new-record form.
     *
     * @param {Event} event - Change event from lightning-input type="checkbox"
     */
    handleNewCheckboxChange(event) {
        const targetFieldName = event.target.dataset.fieldname;
        if (!targetFieldName) {
            return;
        }
        this.newRecordDraftValues = { ...this.newRecordDraftValues, [targetFieldName]: event.target.checked };
    }

    /**
     * @description Updates a multi-picklist draft value in the new-record form.
     *
     * @param {Event} event - Change event from lightning-dual-listbox
     */
    handleNewMultiPicklistChange(event) {
        const targetFieldName = event.target.dataset.fieldname;
        if (!targetFieldName) {
            return;
        }
        const newValue = Array.isArray(event.detail.value) ? event.detail.value.join(';') : '';
        this.newRecordDraftValues = { ...this.newRecordDraftValues, [targetFieldName]: newValue };
    }

    /**
     * @description Handles a lookup selection in the new-record form.
     *
     * @param {CustomEvent} event - valueselected event from c-reusable-lookup
     */
    handleNewLookupValueSelected(event) {
        const targetFieldName = event.target.dataset.fieldname;
        if (!targetFieldName) {
            return;
        }
        const selectedId = event.detail.id || '';
        this.newRecordDraftValues = { ...this.newRecordDraftValues, [targetFieldName]: selectedId };
    }

    // ── Handlers: file upload ──────────────────────────────────────────────

    /**
     * @description Shows the upload form for a specific record.
     *
     * @param {Event} event - Click event; reads data-recordid from target
     */
    handleShowUploadForm(event) {
        const targetRecordId = event.target.dataset.recordid;
        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return { ...record, showUploadForm: true, uploadError: '' };
            }
            return record;
        });
    }

    /**
     * @description Stores the selected file for upload.
     *
     * @param {Event} event - Change event from lightning-input type="file"
     */
    handleFileSelected(event) {
        const targetRecordId = event.target.dataset.recordid;
        const selectedFile = event.target.files[0] || null;
        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return { ...record, pendingFile: selectedFile };
            }
            return record;
        });
    }

    /**
     * @description Cancels the upload form without uploading.
     *
     * @param {Event} event - Click event; reads data-recordid from target
     */
    handleCancelUpload(event) {
        const targetRecordId = event.target.dataset.recordid;
        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return { ...record, showUploadForm: false, pendingFile: null, uploadError: '' };
            }
            return record;
        });
    }

    /**
     * @description Reads the selected file as base64 and calls the Apex upload method.
     *
     * @param {Event} event - Click event; reads data-recordid from target
     */
    async handleUploadFile(event) {
        const targetRecordId = event.target.dataset.recordid;
        const recordToUpload = this.relatedRecords.find(record => record.recordId === targetRecordId);
        if (!recordToUpload || !recordToUpload.pendingFile) {
            this.relatedRecords = this.relatedRecords.map(record => {
                if (record.recordId === targetRecordId) {
                    return { ...record, uploadError: 'Please select a file first.' };
                }
                return record;
            });
            return;
        }

        this.relatedRecords = this.relatedRecords.map(record => {
            if (record.recordId === targetRecordId) {
                return { ...record, isUploadLoading: true, uploadError: '' };
            }
            return record;
        });

        try {
            const base64Data = await this.readFileAsBase64(recordToUpload.pendingFile);
            await uploadSupportingDocument({
                relatedRecordId: targetRecordId,
                requirementItemId: this.requirementItemId,
                fileName: recordToUpload.pendingFile.name,
                base64Data
            });
            this.showToast('Success', 'Document uploaded successfully.', 'success');
            await this.reloadRecords();
        } catch (uploadError) {
            this.relatedRecords = this.relatedRecords.map(record => {
                if (record.recordId === targetRecordId) {
                    return {
                        ...record,
                        isUploadLoading: false,
                        uploadError: this.extractErrorMessage(uploadError)
                    };
                }
                return record;
            });
        }
    }

    /**
     * @description Deletes a supporting document linked to a related record.
     *
     * @param {Event} event - Click event; reads data-recordid from target
     */
    handleDeleteDocument(event) {
        // deleteDocument is not yet exposed on the controller; show a not-implemented notice
        const targetRecordId = event.target.dataset.recordid;
        this.showToast('Info', 'To delete a document, contact your administrator. Record: ' + targetRecordId, 'info');
    }

    // ── Private helpers ────────────────────────────────────────────────────

    /**
     * @description Fires the composed lwcrelatedobjectchange DOM event so VF JavaScript
     *              can react to record count changes. Consumed by the VF-side listener in
     *              EasyAppResources/js/easyLwcBridge.js (lwcRelatedRecordCounts map), which
     *              recordCheckAndAdvance() in easyCarousel.js reads for min/max validation
     *              before carousel advance. See AGENTS.md "Visualforce Page JavaScript".
     */
    fireRelatedObjectChangeEvent() {
        this.dispatchEvent(new CustomEvent('lwcrelatedobjectchange', {
            bubbles: true,
            composed: true,
            detail: { recordCount: this.relatedRecords.length }
        }));
    }

    /**
     * @description Reads a File object and returns a Promise that resolves with the base64 string.
     *
     * @param {File} file - The file to read
     * @returns {Promise<string>} Resolves with the base64-encoded file content
     */
    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result);
            reader.onerror = () => reject(new Error('Failed to read file.'));
            reader.readAsDataURL(file);
        });
    }

    /**
     * @description Fires a ShowToastEvent.
     *
     * @param {string} title - Toast title
     * @param {string} message - Toast message
     * @param {string} variant - success | error | warning | info
     */
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    /**
     * @description Extracts a human-readable message from an Apex error or
     *              a generic Error object.
     *
     * @param {object|Error} error - The caught error
     * @returns {string} Human-readable error message
     */
    extractErrorMessage(error) {
        if (!error) {
            return 'An unknown error occurred.';
        }
        if (error.body && error.body.message) {
            return error.body.message;
        }
        if (error.message) {
            return error.message;
        }
        return JSON.stringify(error);
    }
}