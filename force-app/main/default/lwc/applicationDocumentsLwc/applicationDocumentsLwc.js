/**
 * Created by nguy0092 on 10/6/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {getFieldValue, getRecord} from "lightning/uiRecordApi";
import TERM_NAME from '@salesforce/schema/Application__c.Generic_Filter_4__c';
import getDocumentsRecordId from '@salesforce/apex/ApplicationDocumentsLwcController.getDocumentsRecordId'

const FIELDS = [
    TERM_NAME
];

export default class ApplicationDocumentsLwc extends LightningElement {

    @api recordId;
    @api appId;

    get appRecordId() {
        return this.appId ? this.appId : this.recordId;
    }

    @track documentFiles = [];
    @track documentFilesDisplay = [];
    acceptedExtensionTypes = [
        {extension: "pdf", mimeType: "application/pdf"},
        {extension: "txt", mimeType: "text/plain"}
    ];

    @wire(getRecord, {recordId: "$appRecordId", fields: FIELDS})
    ApplicationRecord;

    get termName() {
        return getFieldValue(this.ApplicationRecord.data, TERM_NAME) ? getFieldValue(this.ApplicationRecord.data, TERM_NAME) : "";
    }

    @wire(getDocumentsRecordId, {recordId: "$appRecordId"})
    getDocumentsRecordIdWire({error, data}) {
        let fileTitleSeq = 0;
        if (data) {
            this.documentFiles = JSON.parse(JSON.stringify(data));
            // console.log("data file: " + JSON.stringify(this.documentFiles));
            this.documentFiles.forEach(file => {
                let title = "";
                const admissionLetterExp = new RegExp(`_AdmissionLetter_`, "i");
                const intendedTermEntryExp = new RegExp(`${this.termName}`, "i");

                if (admissionLetterExp.test(file.Title) && intendedTermEntryExp.test(file.Title)) {
                    title = fileTitleSeq === 0 ? this.termName + " Admissions Letter" : this.termName + " Admissions Letter " + fileTitleSeq;
                    fileTitleSeq++;
                } else if (admissionLetterExp.test(file.Title)) {
                    title = fileTitleSeq === 0 ? "Admissions Letter" : "Admissions Letter " + fileTitleSeq;
                    fileTitleSeq++;
                } else {
                    title = file.Title;
                }

                const documentDisplay = {
                    title: title,
                    documentId: file.ContentDocumentId,
                }

                this.documentFilesDisplay.push(documentDisplay);
            })
            console.log("data options: " + JSON.stringify(this.documentFilesDisplay));
        }

        if (error) {
            console.log("getDocumentsRecordIdWire error: " + error);
        }
    }

    documentHandler(event) {
        event.preventDefault();
        const documentId = event.target.dataset.id;
        const clickType = event.target.dataset.clicktype;
        console.log("Event documentId: " + documentId);
        let documentBlobUrl = "";
        const documentFind = this.documentFiles.find(document => document.ContentDocumentId === documentId);
        // console.log("Event documentFind: " + JSON.stringify(documentFind));

        if (documentFind) {
            documentBlobUrl = this.createFileBlobUrl(documentFind);
        }

        if (documentBlobUrl) {
            if (clickType === "view") {
                const viewLink = document.createElement('a');
                viewLink.href = documentBlobUrl;
                viewLink.target = '_blank';
                viewLink.rel = "noopener noreferrer";
                document.body.appendChild(viewLink);
                viewLink.click();
                document.body.removeChild(viewLink);
                setTimeout(() => {
                    URL.revokeObjectURL(documentBlobUrl);
                }, 300000);
            }

            if (clickType === "download") {
                const downLoadLink = document.createElement('a');
                downLoadLink.href = documentBlobUrl;
                downLoadLink.download = documentFind.Title;
                document.body.appendChild(downLoadLink);
                downLoadLink.click();
                document.body.removeChild(downLoadLink);
                URL.revokeObjectURL(documentBlobUrl);
            }
        }
    }

    createFileBlobUrl(documentFind) {
        const binaryString = atob(documentFind.VersionDataEncode);
        const len = binaryString.length;
        const bytes = new Uint8Array(len);
        for (let i = 0; i < len; i++) {
            bytes[i] = binaryString.charCodeAt(i);
        }

        let mimeType = "";
        const findMimeType = this.acceptedExtensionTypes.find(type => type.extension === documentFind.FileExtension);
        console.log("type1: " + documentFind.FileExtension);
        if (findMimeType) {
            mimeType = findMimeType.mimeType;
        }
        console.log("type2: " + documentFind.FileExtension + " " + mimeType);

        const documentBlob = new Blob([bytes.buffer], {type: mimeType});
        console.log("url: " + URL.createObjectURL(documentBlob));
        return URL.createObjectURL(documentBlob);
    }

}