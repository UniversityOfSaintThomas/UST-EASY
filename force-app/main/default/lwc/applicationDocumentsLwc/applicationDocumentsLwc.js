/**
 * Created by nguy0092 on 10/6/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import applicationTermName from '@salesforce/apex/ApplicationDocumentsLwcController.applicationTermName';
import getDocumentsRecordId from '@salesforce/apex/ApplicationDocumentsLwcController.getDocumentsRecordId'

export default class ApplicationDocumentsLwc extends LightningElement {

    @api recordId;
    @api appId;

    termName;

    @track documentFiles = [];
    @track documentFilesDisplay = [];
    @track acceptedExtensionTypes = [
        {extension: "pdf", mimeType: "application/pdf"},
        {extension: "txt", mimeType: "text/plain"}
    ];

    get appRecordId() {
        return this.appId ? this.appId : this.recordId;
    }

    get documentPatterns() {
        return {
            termNameRegExp: new RegExp(this.termName, "i"),
            admissionLetterRegExp: /_AdmissionLetter_/i,
            waitlistLetterRegExp: /_DecisionLetter_/i,
            denyLetterRegExp: /_DenyLetter_/i,
            bsnProgramRegExp: /_BSNDirectAdmit_/i
        };
    }

    @wire(applicationTermName, {recordId: "$appRecordId"})
    async termNameWire({error, data}) {
        if (error) {
            console.error("termName error:", error);
            this.handleError(error);
            return;
        }

        if (!data?.Generic_Filter_4__c) {
            console.warn("No term name found in data");
            return;
        }

        this.termName = data.Generic_Filter_4__c;
        await this.loadAndCategorizeDocuments();
    }

    async loadAndCategorizeDocuments() {
        try {
            const documents = await getDocumentsRecordId({recordId: this.appRecordId});

            if (!documents?.length) {
                console.log("No documents found");
                return;
            }

            this.documentFiles = documents;
            this.documentFilesDisplay = this.categorizeDocuments(documents);

            console.log("Categorized documents stringify:", JSON.stringify(this.documentFilesDisplay));
        } catch (error) {
            console.error("Error loading documents:", error);
            this.handleError(error);
        }
    }

    categorizeDocuments(documents) {
        const counters = {
            standard: 0,
            bsnAdmission: 0,
            bsnWaitlist: 0,
            bsnDeny: 0
        };

        return documents
            .map(file => this.categorizeDocument(file, counters))
            .filter(doc => doc !== null);
    }

    categorizeDocument(file, counters) {
        const {termNameRegExp, admissionLetterRegExp, waitlistLetterRegExp, denyLetterRegExp, bsnProgramRegExp} = this.documentPatterns;

        if (!termNameRegExp.test(file.Title)) {
            return null;
        }

        const isBSN = bsnProgramRegExp.test(file.Title);
        let title = "";

        if (isBSN) {
            if (admissionLetterRegExp.test(file.Title)) {
                title = this.buildTitle("Nursing Direct Admission Letter", counters.bsnAdmission);
                counters.bsnAdmission++;
            } else if (waitlistLetterRegExp.test(file.Title)) {
                title = this.buildTitle("Nursing Waitlist Letter", counters.bsnWaitlist);
                counters.bsnWaitlist++;
            } else if (denyLetterRegExp.test(file.Title)) {
                title = this.buildTitle("Nursing Decision Letter", counters.bsnDeny);
                counters.bsnDeny++;
            }
        } else if (admissionLetterRegExp.test(file.Title)) {
            title = this.buildTitle("Admissions Letter", counters.standard);
            counters.standard++;
        }

        return title ? {
            title,
            documentId: file.ContentDocumentId
        } : null;
    }

    buildTitle(baseTitle, counter) {
        const fullTitle = `${this.termName} ${baseTitle}`;
        return counter === 0 ? fullTitle : `${fullTitle} ${counter}`;
    }

    handleError(error) {
        this.documentFilesDisplay = [];
    }

    documentHandler(event) {
        event.preventDefault();
        const { id: documentId, clicktype: clickType } = event.target.dataset;
        console.log("Event documentId: " + documentId);
        const documentFind = this.documentFiles.find(document => document.ContentDocumentId === documentId);
        // console.log("Event documentFind: " + JSON.stringify(documentFind));

        if (!documentFind) {
            console.error("Document not found:", documentId);
            return;
        }

        const documentBlobUrl = this.createFileBlobUrl(documentFind);

        if (clickType === "view") {
            this.triggerLink(documentBlobUrl, { target: '_blank', rel: 'noopener noreferrer' });
            setTimeout(() => URL.revokeObjectURL(documentBlobUrl), 300000);
        } else if (clickType === "download") {
            this.triggerLink(documentBlobUrl, { download: documentFind.Title });
            URL.revokeObjectURL(documentBlobUrl);
        }

    }

    createFileBlobUrl(documentFind) {
        const binaryString = atob(documentFind.VersionDataEncode);
        const bytes = new Uint8Array(binaryString.length);
        for (let i = 0; i < bytes.length; i++) {
            bytes[i] = binaryString.charCodeAt(i);
        }

        const mimeType = this.acceptedExtensionTypes.find(type => type.extension === documentFind.FileExtension)?.mimeType || "application/octet-stream";
        console.log("type2: " + documentFind.FileExtension + " " + mimeType);

        const documentBlob = new Blob([bytes], {type: mimeType});
        console.log("url: " + URL.createObjectURL(documentBlob));
        return URL.createObjectURL(documentBlob);
    }

    triggerLink(href, attributes = {}) {
        const link = document.createElement('a');
        link.href = href;

        Object.entries(attributes).forEach(([key, value]) => {
            link[key] = value;
        });

        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

}