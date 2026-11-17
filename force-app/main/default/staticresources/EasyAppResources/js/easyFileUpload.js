/* ============================================================
   easyFileUpload.js — file drop zones, document upload save, file-type validation, and file delete.
   ============================================================ */

function fileUploadAreas() {

    document.querySelectorAll('.slds-file-selector__dropzone').forEach(upload => {
        if (upload.dataset.eventsAdded) {
            return; // Skip this element if the events have already been added
        }

        let fileInput = upload.querySelector('input');
        let fileCard = upload.closest('.slds-card');
        let currentFile = fileCard.querySelector('.currentlySelectedFile');
        const fileChangeEvent = new Event("change");

        ['drag', 'dragstart', 'dragend', 'dragover', 'dragenter', 'dragleave', 'drop'].forEach(evt => {
            upload.addEventListener(evt, function (e) {
                e.preventDefault();
                e.stopPropagation();
            });
        });

        ['dragover', 'dragenter'].forEach(evt => {
            upload.addEventListener(evt, function () {
                upload.classList.add('slds-has-drag-over');
            });
        });

        ['dragleave', 'dragend', 'drop'].forEach(evt => {
            upload.addEventListener(evt, function () {
                upload.classList.remove('slds-has-drag-over');
            });
        });

        upload.addEventListener('drop', function (e) {
            fileInput.files = e.dataTransfer.files;
            currentFile.innerHTML = findFileName(fileInput.value);
            fileInput.dispatchEvent(fileChangeEvent);
        });


        fileInput.addEventListener('change', function () {
            let clearSelectFileIcon = upload.closest('.file_selector_wrapper').querySelector('.clearSelectFileIcon');

            currentFile.innerHTML = findFileName(fileInput.value);

            if (currentFile.innerHTML === "<strong>Selected File:</strong> None") {

                clearSelectFileIcon.style.display = "none";
            } else {

                clearSelectFileIcon.style.display = "";

                if (clearSelectFileIcon) {

                    clearSelectFileIcon.addEventListener('click', function (e) {

                        if (fileInput.value) {
                            fileInput.value = "";
                            fileInput.dispatchEvent(fileChangeEvent);
                        }
                    })
                }
            }
        });

        upload.addEventListener('click', function () {
            fileInput.click();
        });

        upload.dataset.eventsAdded = true;
    });
}

function findFileName(filePath) {
    if (filePath) {
        filePath = filePath.split('\\');
        filePath = filePath[filePath.length - 1];
    } else {
        filePath = 'None';
    }
    filePath = '<strong>Selected File:</strong> ' + filePath;
    return filePath;
}

//Makes sure all labels have id associations to the inputs
function performDocUploadSave(redirectTo) {
    let docUploadPromiseArr = [];
    ensureRichTextContent();

    document.querySelectorAll('.docUploadInput').forEach(function (docUpload, idx) {
        if (docUpload.files) {
            let fbody = docUpload.files[0];
            if (fbody) {
                docUploadPromiseArr.push(getAsText(fbody, docUpload.getAttribute('data-respid')));
            }
        } else {
        }
    });

    Promise.all(docUploadPromiseArr).then(docUploads => {
        let docUploadObj = {};
        docUploads.forEach(function (docUpload) {
            docUploadObj[docUpload.itemId] = {"attData": docUpload};
        });
        saveWithDocs(JSON.stringify(docUploadObj), redirectTo);
    }).catch(function () {
    });
}

function getAsText(readFile, respId) {
    return new Promise((resolve, reject) => {
        //var reader = new FileReader();
        let reader = new FileReader();
        reader.onload = (function (theFile) {
            let fileName = theFile.name;
            return function (e) {
                resolve({"fileName": fileName, "data": e.target.result, "itemId": respId});
            };
        })(readFile);
        reader.readAsDataURL(readFile);
    });
}


function validateFileType(obj) {
    if (Boolean(obj.title)) {
        let acceptedTypes = obj.title.split(';');
        let inputArray = obj.value.split('.');
        let inputType = inputArray[inputArray.length - 1].toUpperCase();
        if (!acceptedTypes.includes(inputType)) {
            obj.value = null;
            let fileTypeMessage = 'File type not accepted. Please upload one of the following: ';
            for (const type of acceptedTypes) {
                fileTypeMessage += type + ', ';
            }
            fileTypeMessage = fileTypeMessage.slice(0, fileTypeMessage.length - 2) + '.';
            document.getElementById('error-108' + String(obj.name)).innerHTML = fileTypeMessage;
            return false;
        } else {
            document.getElementById('error-108' + String(obj.name)).innerHTML = '';
        }
    }
    return true;
}

function deletePrevious(contentDocId, reqResponseId, fileTitle) {

    activateModal('Confirm',
        '<strong>Delete Saved File: </strong>' + fileTitle,
        'Delete',
        function () {
            appShowLoadingSpinner();
            deletePreviousFile(contentDocId, reqResponseId);
        })

    return true;
}
