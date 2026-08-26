/**
 * Created by nguy0092 on 10/6/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import applicationInformation from '@salesforce/apex/ApplicationDocumentsLwcController.applicationInformation';
import getDocumentsRecordId from '@salesforce/apex/ApplicationDocumentsLwcController.getDocumentsRecordId';

export default class ApplicationDocumentsLwc extends LightningElement {

    @api recordId;
    @api appId;

    termName;
    @track documentsToDisplayKeywords = {};
    @track documentFiles = [];
    @track documentFilesDisplay = [];
    @track acceptedExtensionTypes = [
        {extension: "pdf", mimeType: "application/pdf"},
        {extension: "txt", mimeType: "text/plain"}
    ];

    get appRecordId() {
        return this.appId ? this.appId : this.recordId;
    }

    @wire(applicationInformation, {recordId: "$appRecordId"})
    async appInfo({error, data}) {
        if (error) {
            console.error("termName error:", error);
            this.handleError(error);
            return;
        }

        if (!data) return;

        if (!data.termName) {
            console.warn("No term name found in data");
            return;
        }

        this.termName = data.termName;
        this.documentsToDisplayKeywords = data.documentsToDisplayKeywords;
        await this.loadAndCategorizeDocuments();
    }

    async loadAndCategorizeDocuments() {
        try {
            const documents = await getDocumentsRecordId({recordId: this.appRecordId, titleKeywords: this.documentsToDisplayKeywords});

            if (!documents?.length) {
                console.log("No documents found");
                this.documentFiles = [];
                this.documentFilesDisplay = [];
                return;
            }

            this.documentFiles = documents;
            // console.log("documents stringify:", JSON.stringify(documents));

            const counters = {};
            this.documentFilesDisplay = documents
                .map(doc => {
                    const baseTitle = this.buildDocumentTitle(doc);
                    if (!baseTitle) return null;

                    const count = counters[baseTitle] ?? 0;
                    const title = count === 0 ? baseTitle : `${baseTitle} ${count}`;
                    counters[baseTitle] = count + 1;

                    return {title, documentId: doc.ContentDocumentId};
                })
                .filter(doc => doc !== null);

            // console.log("Categorized documents stringify:", JSON.stringify(this.documentFilesDisplay));
        } catch (error) {
            console.error("Error loading documents:", error);
            this.handleError(error);
        }
    }

    buildDocumentTitle(doc) {
        for (const [keyword, displayValue] of Object.entries(this.documentsToDisplayKeywords ?? {})) {
            if (doc.Title?.toLowerCase().includes(keyword.toLowerCase())) {
                return `${this.termName} ${displayValue}`;
            }
        }
        return null;
    }

    handleError(error) {
        this.documentFilesDisplay = [];
        this.documentFiles = [];
    }

    documentHandler(event) {
        event.preventDefault();
        const { id: documentId, clicktype: clickType } = event.currentTarget.dataset;
        // console.log("Event documentId: " + documentId);
        const documentFind = this.documentFiles.find(document => document.ContentDocumentId === documentId);
        // console.log("Event documentFind: " + JSON.stringify(documentFind));

        if (!documentFind) {
            console.error("Document not found:", documentId);
            return;
        }

        const documentBlobUrl = this.createFileBlobUrl(documentFind);
        if (!documentBlobUrl) return;

        if (clickType === "view") {
            this.triggerLink(documentBlobUrl, { target: '_blank', rel: 'noopener noreferrer' });
            setTimeout(() => URL.revokeObjectURL(documentBlobUrl), 300000);
        } else if (clickType === "download") {
            this.triggerLink(documentBlobUrl, { download: documentFind.Title });
            setTimeout(() => URL.revokeObjectURL(documentBlobUrl), 1000);
        }

    }

    createFileBlobUrl(documentFind) {
        if (!documentFind.VersionDataEncode) {
            console.error("No version data found for document:", documentFind.Title);
            return null;
        }

        const binaryString = atob(documentFind.VersionDataEncode);
        const bytes = new Uint8Array(binaryString.length);
        for (let i = 0; i < bytes.length; i++) {
            bytes[i] = binaryString.charCodeAt(i);
        }

        const mimeType = this.acceptedExtensionTypes.find(type => type.extension === documentFind.FileExtension)?.mimeType || "application/octet-stream";
        // console.log("type2: " + documentFind.FileExtension + " " + mimeType);

        const documentBlob = new Blob([bytes], {type: mimeType});
        const documentBlobUrl = URL.createObjectURL(documentBlob);
        // console.log("url: " + documentBlobUrl);
        return documentBlobUrl;
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