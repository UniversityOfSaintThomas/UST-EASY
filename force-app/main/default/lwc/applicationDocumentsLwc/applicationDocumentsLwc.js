/**
 * Created by nguy0092 on 10/6/2025.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getDocumentsRecordId from '@salesforce/apex/ApplicationDocumentsLwcController.getDocumentsRecordId'
import LightningModal from 'lightning/modal';
import ModalPopup from 'c/applicationDocumentsModalLwc';

export default class ApplicationDocumentsLwc extends LightningElement {
    result;

    filePreview(event) {
        event.preventDefault();
        const blobData = event.target.dataset.versiondatablob;
        const binaryString = atob(blobData);
        const len = binaryString.length;
        const bytes = new Uint8Array(len);
        for (let i = 0; i < len; i++) {
            bytes[i] = binaryString.charCodeAt(i);
        }

        // Create a Blob from the binary data
        // You might need to determine the correct MIME type (e.g., 'application/pdf', 'image/jpeg')
        // For this example, let's assume it's a PDF.
        const fileBlob = new Blob([bytes.buffer], {type: 'application/pdf'});
        const fileBlobUrl = URL.createObjectURL(fileBlob);
        window.open(fileBlobUrl, '_blank');
        setTimeout(() => {
            URL.revokeObjectURL(fileBlobUrl);
        }, 100);
    }

    get downloadBlob() {
        const data = "This is the content of your downloadable file.";
        const blob = new Blob([data], { type: "text/plain" }); // Example for a plain text file

        const blobUrl = URL.createObjectURL(blob);

        return blobUrl;
    }

    // async handleClick() {
    //     const result = await ModalPopup.open({
    //         size: "Large",
    //         description: "This is a modal popup"
    //     })
    //
    //     this.result = result;
    //     console.log("This result: "+this.result);
    // }

    @api recordId = 'a0qRL000008XHALYA4';

    @track documentFiles = [];
    @track documentFilesOptions = [];

    @wire(getDocumentsRecordId, {recordId: "$recordId"})
    getDocumentsRecordIdWire({error, data}) {
        if (data) {
            this.documentFiles = JSON.parse(JSON.stringify(data));
            console.log("data file: "+JSON.stringify(this.documentFiles));
            this.documentFiles.forEach(file => {
                let documentInfo = {
                    label: file.Title,
                    value: file.ContentDocumentId,
                    // url: "/sfc/servlet.shepherd/document/download/"+file.ContentDocumentId,
                    VersionDataBlob: ""
                }
                if(file.VersionDataBlob) {
                    documentInfo.VersionDataBlob = file.VersionDataBlob;
                }

                this.documentFilesOptions.push(documentInfo);
            })
            console.log("data options: "+JSON.stringify(this.documentFilesOptions));
        }

        if(error) {
            console.log("getDocumentsRecordIdWire error: "+error);
        }
    }
    //
    // previewHandler(event) {
    //     const documentId = event.target.dataset.id;
    //     console.log("preview id: "+documentId);
    //
    //     const url = `/lightning/r/ContentDocument/${documentId}/view`;
    //     window.open(url, '_blank');
    //
    //     // return `/lightning/r/ContentDocument/${documentId}/view`;
    //
    //     // this[NavigationMixin.Navigate](
    //     //     {
    //     //         type: "standard__namedPage",
    //     //         attributes: {
    //     //             pageName: "filePreview"
    //     //         },
    //     //         state:{
    //     //             selectedRecordId: documentId
    //     //         }
    //     //     })
    // }
    //
    // handleOkay() {
    //     this.close('okay');
    // }
    //
    // get filePreviewUrl() {
    //     if (this.contentDocumentId) {
    //         return `/lightning/r/ContentDocument/${this.contentDocumentId}/view`;
    //     }
    //     return '#';
    // }
    //
    // handlePreviewClick() {
    //     window.open(this.filePreviewUrl, '_blank');
    // }
}