/**
 * Created by nguy0092 on 10/6/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getDocumentsRecordId from '@salesforce/apex/ApplicationDocumentsLwcController.getDocumentsRecordId'
import LightningModal from 'lightning/modal';
import ModalPopup from 'c/applicationDocumentsModalLwc';
import {gql, graphql} from 'lightning/uiGraphQLApi';

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

    @wire(getDocumentsRecordId, {recordId: "$appRecordId"})
    getDocumentsRecordIdWire({error, data}) {
        if (data) {
            this.documentFiles = JSON.parse(JSON.stringify(data));
            console.log("data file: " + JSON.stringify(this.documentFiles));
            this.documentFiles.forEach(file => {
                const documentDisplay = {
                    title: file.Title,
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
        console.log("Event documentFind: " + JSON.stringify(documentFind));

        if (documentFind) {
            documentBlobUrl = this.createFileBlobUrl(documentFind);
        }

        if (documentBlobUrl) {
            if (clickType === "view") {
                window.open(documentBlobUrl, '_blank');
                URL.revokeObjectURL(documentBlobUrl);
                setTimeout(() => {
                    URL.revokeObjectURL(documentBlobUrl);
                }, 100);
            }

            if (clickType === "download") {
                const downLoadLink = document.createElement('a');
                downLoadLink.href = documentBlobUrl;
                downLoadLink.download = documentFind.Title;
                document.body.appendChild(downLoadLink);
                downLoadLink.click();
                document.body.removeChild(downLoadLink);
                URL.revokeObjectURL(documentBlobUrl);
                // setTimeout(() => {
                //     document.body.removeChild(downLoadLink);
                //     URL.revokeObjectURL(documentBlobUrl);
                // }, 100);
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