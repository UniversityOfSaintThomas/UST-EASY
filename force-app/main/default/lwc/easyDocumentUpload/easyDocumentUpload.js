import { LightningElement, api, track } from 'lwc';
import getDocumentUploadConfig from '@salesforce/apex/EasyDocumentUploadController.getDocumentUploadConfig';
import saveDocumentFile from '@salesforce/apex/EasyDocumentUploadController.saveDocumentFile';
import saveTextEntry from '@salesforce/apex/EasyDocumentUploadController.saveTextEntry';
import deleteDocumentFile from '@salesforce/apex/EasyDocumentUploadController.deleteDocumentFile';

/** Delay (ms) before auto-saving rich text after the user stops typing */
const RICH_TEXT_SAVE_DELAY_MS = 1500;

/** Regex to strip the data: prefix added by FileReader.readAsDataURL */
const DATA_URL_PREFIX_REGEX = /^data:[^;]+;base64,/;

/** Regex to strip HTML tags from rich-text values for plain-text counting */
const HTML_TAG_REGEX = /<[^>]*>/g;

/**
 * Strips HTML tags from a rich-text value and collapses whitespace, for
 * word/character counting purposes only (not used for display or storage).
 *
 * @param {string} htmlValue - HTML string from the rich-text editor
 * @return {string} Plain text with tags removed and whitespace collapsed
 */
function stripHtmlForCounting(htmlValue) {
    if (!htmlValue) {
        return '';
    }
    return htmlValue.replace(HTML_TAG_REGEX, ' ').replace(/&nbsp;/g, ' ').replace(/\s+/g, ' ').trim();
}

export default class EasyDocumentUpload extends LightningElement {

    // ─── Public API Properties ────────────────────────────────────────────────

    @api requirementItemId;
    @api applicationId;
    @api applicationStatus = '';

    /**
     * Whether the current user/applicant can make changes.
     * Receives a Boolean or the string 'true'/'false' from Lightning Out.
     */
    @api
    get isEditable() {
        return this._isEditable;
    }
    set isEditable(value) {
        this._isEditable = value === true || value === 'true';
    }

    /**
     * When true, changes to the form are blocked (read-only override).
     * Receives a Boolean or the string 'true'/'false' from Lightning Out.
     */
    @api
    get preventUpdates() {
        return this._preventUpdates;
    }
    set preventUpdates(value) {
        this._preventUpdates = value === true || value === 'true';
    }

    // ─── Private Reactive State ───────────────────────────────────────────────

    @track config = {};
    @track isLoading = true;
    @track isSaving = false;
    @track isSavingText = false;
    @track errorMessage = null;
    @track fileTypeError = null;
    @track requiredError = null;
    @track selectedFileName = null;
    @track richTextDraftValue = '';

    _isEditable = false;
    _preventUpdates = false;
    _richTextSaveTimer = null;

    // ─── Lifecycle ────────────────────────────────────────────────────────────

    connectedCallback() {
        this.loadConfig();
    }

    renderedCallback() {
        // Inject HTML content into the manual DOM node for read-only text display
        const readonlyNode = this.template.querySelector('.easy-du-text-readonly');
        if (readonlyNode && this.config && this.config.textEntryValue) {
            // eslint-disable-next-line @lwc/lwc/no-inner-html
            readonlyNode.innerHTML = this.config.textEntryValue;
        }
    }

    // ─── Getters ──────────────────────────────────────────────────────────────

    /**
     * Whether the user can interact with the form (editable and not prevented).
     * Use this in the template instead of the raw isEditable @api prop.
     *
     * @return True when edits are allowed
     */
    get canEdit() {
        return this._isEditable && !this._preventUpdates;
    }

    /**
     * True when the file upload card should be visible.
     * Show always when a file exists so applicants can see/download their upload,
     * or when the form is editable so they can upload a file.
     *
     * @return True when the file section should render
     */
    get showFileSection() {
        return this.canEdit || !!(this.config && this.config.existingFileName);
    }

    /**
     * Builds the Salesforce content version download URL.
     *
     * @return Download URL string, or '#' when no version exists
     */
    get downloadUrl() {
        if (this.config && this.config.existingFileVersionId) {
            return '/sfc/servlet.shepherd/version/download/' + this.config.existingFileVersionId;
        }
        return '#';
    }

    /**
     * Converts the semicolon-separated File_Types__c value to a comma-separated
     * accept attribute for the file input, with leading dots.
     * e.g. "PDF;DOCX" -> ".PDF,.DOCX"
     *
     * @return Accept attribute string, or empty string when no types configured
     */
    get acceptAttribute() {
        if (!this.config || !this.config.acceptedFileTypes) {
            return '';
        }
        return this.config.acceptedFileTypes
            .split(';')
            .map(extension => '.' + extension.trim())
            .join(',');
    }

    /**
     * Human-readable list of accepted file extensions shown to the applicant
     * before they pick a file, e.g. "PDF, DOCX, DOC".
     * Empty when no File_Types__c restriction is configured (all types allowed).
     *
     * @return Comma-separated, uppercased extension list, or empty string
     */
    get acceptedFileTypesDisplay() {
        if (!this.config || !this.config.acceptedFileTypes) {
            return '';
        }
        return this.config.acceptedFileTypes
            .split(';')
            .map(extension => extension.trim().toUpperCase())
            .filter(extension => extension !== '')
            .join(', ');
    }

    /**
     * Plain-text character count of the current rich-text draft (tags stripped).
     *
     * @return Character count
     */
    get characterCount() {
        return stripHtmlForCounting(this.richTextDraftValue).length;
    }

    /**
     * Plain-text word count of the current rich-text draft (tags stripped).
     *
     * @return Word count
     */
    get wordCount() {
        const plainText = stripHtmlForCounting(this.richTextDraftValue);
        return plainText === '' ? 0 : plainText.split(' ').length;
    }

    // ─── Data Loading ─────────────────────────────────────────────────────────

    loadConfig() {
        this.isLoading = true;
        this.errorMessage = null;

        getDocumentUploadConfig({
            requirementItemId: this.requirementItemId,
            applicationId: this.applicationId,
            applicationStatus: this.applicationStatus
        })
            .then(result => {
                this.config = result || {};
                this.richTextDraftValue = this.config.textEntryValue || '';
                this.isLoading = false;
                this.fireChangeEvent();
            })
            .catch(loadError => {
                this.errorMessage = 'Failed to load document upload. ' + this.extractErrorMessage(loadError);
                this.isLoading = false;
            });
    }

    // ─── Event Handlers ───────────────────────────────────────────────────────

    /**
     * Validates and reads the selected file, then uploads it.
     *
     * @param {Event} event - The file input change event
     */
    handleFileChange(event) {
        const fileInput = event.target;
        const file = fileInput.files && fileInput.files[0];
        if (!file) {
            return;
        }

        this.fileTypeError = null;
        this.requiredError = null;

        // Validate file type against accepted extensions
        if (this.config.acceptedFileTypes) {
            const acceptedTypes = this.config.acceptedFileTypes.split(';').map(ext => ext.trim().toUpperCase());
            const parts = file.name.split('.');
            const fileExtension = parts[parts.length - 1].toUpperCase();
            if (!acceptedTypes.includes(fileExtension)) {
                this.fileTypeError = 'File type not accepted. Please upload one of the following: '
                    + acceptedTypes.join(', ') + '.';
                fileInput.value = '';
                return;
            }
        }

        this.selectedFileName = file.name;
        this.readFileAndUpload(file);
    }

    /**
     * Handles rich-text editor changes with a debounced auto-save.
     *
     * @param {CustomEvent} event - The lightning-input-rich-text change event
     */
    handleRichTextChange(event) {
        const newValue = event.detail.value;
        this.richTextDraftValue = newValue;
        if (this._richTextSaveTimer) {
            clearTimeout(this._richTextSaveTimer);
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._richTextSaveTimer = setTimeout(() => {
            this.performSaveTextEntry(newValue);
        }, RICH_TEXT_SAVE_DELAY_MS);
    }

    /**
     * Prompts for confirmation and deletes the existing file.
     */
    handleDeleteFile() {
        if (!this.config.existingContentDocumentId || !this.config.responseId) {
            return;
        }
        // eslint-disable-next-line no-alert
        if (!window.confirm('Delete saved file "' + this.config.existingFileName + '"?')) {
            return;
        }
        this.performDeleteFile();
    }

    // ─── Private Methods ──────────────────────────────────────────────────────

    /**
     * Reads the file as a base64 data URL and calls the upload Apex method.
     *
     * @param {File} file - The File object from the input
     */
    readFileAndUpload(file) {
        this.isSaving = true;
        this.errorMessage = null;

        const reader = new FileReader();
        reader.onload = (loadEvent) => {
            const base64Data = loadEvent.target.result;
            this.uploadFile(file.name, base64Data);
        };
        reader.onerror = () => {
            this.errorMessage = 'Failed to read the selected file.';
            this.isSaving = false;
        };
        reader.readAsDataURL(file);
    }

    /**
     * Sends base64-encoded file data to Apex and refreshes state on success.
     *
     * @param {string} fileName  - Original file name
     * @param {string} base64Data - Data URL string (data:...;base64,...)
     */
    uploadFile(fileName, base64Data) {
        saveDocumentFile({
            requirementItemId: this.requirementItemId,
            applicationId: this.applicationId,
            fileName: fileName,
            base64Data: base64Data,
            applicationStatus: this.applicationStatus
        })
            .then(result => {
                this.config = result || {};
                this.selectedFileName = null;
                this.isSaving = false;
                this.fireChangeEvent();
            })
            .catch(uploadError => {
                this.errorMessage = 'Upload failed. ' + this.extractErrorMessage(uploadError);
                this.isSaving = false;
            });
    }

    /**
     * Saves the text entry value via Apex.
     *
     * @param {string} textValue - HTML string from the rich-text editor
     */
    performSaveTextEntry(textValue) {
        this.isSavingText = true;

        saveTextEntry({
            requirementItemId: this.requirementItemId,
            applicationId: this.applicationId,
            textValue: textValue,
            applicationStatus: this.applicationStatus
        })
            .then(result => {
                this.config = result || {};
                this.isSavingText = false;
                this.fireChangeEvent();
            })
            .catch(textSaveError => {
                this.errorMessage = 'Failed to save text. ' + this.extractErrorMessage(textSaveError);
                this.isSavingText = false;
            });
    }

    /**
     * Deletes the existing file attachment via Apex.
     */
    performDeleteFile() {
        this.isSaving = true;
        this.errorMessage = null;

        deleteDocumentFile({
            contentDocumentId: this.config.existingContentDocumentId,
            responseId: this.config.responseId,
            requirementItemId: this.requirementItemId,
            applicationId: this.applicationId,
            applicationStatus: this.applicationStatus
        })
            .then(result => {
                this.config = result || {};
                this.isSaving = false;
                this.fireChangeEvent();
            })
            .catch(deleteError => {
                this.errorMessage = 'Delete failed. ' + this.extractErrorMessage(deleteError);
                this.isSaving = false;
            });
    }

    /**
     * Fires a composed, bubbling custom event to notify the host page of the
     * current upload state. Consumed by the VF-side listener in
     * EasyAppResources/js/easyLwcBridge.js (lwcDocumentUploadStates map), which
     * recordCheckAndAdvance() in easyCarousel.js reads to drive required-upload
     * validation before carousel advance. See AGENTS.md "Visualforce Page JavaScript".
     */
    fireChangeEvent() {
        const hasDocument = !!(this.config && this.config.hasDocument);
        const isRequired = !!(this.config && this.config.isRequired);
        this.dispatchEvent(new CustomEvent('lwcdocumentuploadchange', {
            bubbles: true,
            composed: true,
            detail: {
                hasDocument: hasDocument,
                isRequired: isRequired
            }
        }));
    }

    /**
     * Extracts a human-readable message from an Apex or network error.
     *
     * @param {Object} error - Error object from a rejected Apex promise
     * @return Readable error string
     */
    extractErrorMessage(error) {
        if (error && error.body && error.body.message) {
            return error.body.message;
        }
        if (error && typeof error.message === 'string') {
            return error.message;
        }
        return 'An unexpected error occurred.';
    }
}