// $(document).keypress(function (event) {
//     if (event.which == '13') {
//         event.preventDefault();
//     }
// });

let ready = (callback) => {
    if (document.readyState != "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

let placeholders = {};
let maxLengths = {};

ready(() => {

    for (let inputId in placeholders) {
        if (inputId) {
            document.querySelectorAll('.' + inputId).forEach(field => {
                field.setAttribute('aria-describedby', "error-message-" + inputId);
                if (placeholders[inputId]) {
                    field.setAttribute('placeholder', placeholders[inputId])
                }
            });
        }
    }

    for (let inputId2 in maxLengths) {
        if (inputId2) {
            document.querySelectorAll('.' + inputId2).forEach(field => {
                if (maxLengths[inputId2]) {
                    field.setAttribute('maxlength', maxLengths[inputId2])
                }
            });
        }
    }

    document.querySelectorAll('.fieldNotEditable,.fieldNotEditable input,.fieldNotEditable select,.fieldNotEditable textarea').forEach(field => {
        field.setAttribute('disabled', 'disabled');
    });



});

let observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
        console.log(mutation);
    });
});

// // Notify us when any node within the document is modified, added removed, etc.
// document.addEventListener("DOMSubtreeModified", function(e) {
//     // Notify of change!
//     console.warn("change!", e);
// }, false);


function appShowLoadingSpinner() {
    document.getElementById("apploadingspinner").style.display = "block";
}

function appHideLoadingSpinner() {
    document.getElementById("apploadingspinner").style.display = "none";
}

function appShowConfimation() {
    document.getElementById("confirmation").style.display = "block";
}

// By default, replaceAll runs on ALL textarea fields.
// modified to run only on the class defined 'ckeditor'
//CKEDITOR.replaceAll = function(){for(var a=document.getElementsByClassName("ckeditor"),b=0;b<a.length;b++){var d=null,k=a[b];if(k.name||k.id){if("string"==typeof arguments[0]){if(!(new RegExp("(?:^|\\s)"+arguments[0]+"(?:$|\\s)")).test(k.className))continue}else if("function"==typeof arguments[0]&&(d={},!1===arguments[0](k,d)))continue;this.replace(k,d)}}};

// destroys and rebuilds the rich text fields after rerender
function afterRerenderRTF() {
    for (name in CKEDITOR.instances) {
        delete CKEDITOR.instances[name];
    }

    CKEDITOR.replaceAll('ckeditor');
}

// I use this before save as I've observed situations where changes are lost,
// particularly after the fields have already been rerendered.
// More of a safeguard than anything
function ensureRichTextContent() {

    document.querySelectorAll('.ckeditor').forEach(function (el) {
        let id = el.id || el.getAttribute('name');
        let data = CKEDITOR.instances[id].getData().trim();

        if (CKEDITOR.instances[id].checkDirty()) {
            el.textContent = data;
        }

    });
}

function performDocUploadSave(redirectTo) {
    let docUploadPromiseArr = [];
    ensureRichTextContent();

    document.querySelectorAll('.docUploadInput').forEach(function (el, docUpload) {
        if (docUpload.files) {
            let fbody = docUpload.files[0];
            if (fbody) {
                docUploadPromiseArr.push(getAsText(fbody, docUpload.getAttribute('data-respid')));
            }
        } else {
        }

    });

    document.querySelectorAll('.docUploadInput').forEach(function (idx, docUpload) {
        if (docUpload.files) {
            let fbody = docUpload.files[0];
            if (fbody) {
                docUploadPromiseArr.push(getAsText(fbody, docUpload.getAttribute('data-respid')));
            }
        } else {
        }
    });

    Promise.all(docUploadPromiseArr).then(docUploads => {
        var docUploadObj = {};
        docUploads.forEach(function (docUpload) {
            docUploadObj[docUpload.itemId] = {"attData": docUpload};
        });
        saveWithDocs(JSON.stringify(docUploadObj), redirectTo);
        //console.log(redirectTo);
    }).catch(function () {
    });
}

function getAsText(readFile, respId) {
    return new Promise((resolve, reject) => {
        //var reader = new FileReader();
        let reader = new FileReader();
        reader.onload = (function (theFile) {
            var fileName = theFile.name;
            return function (e) {
                resolve({"fileName": fileName, "data": e.target.result, "itemId": respId});
            };
        })(readFile);
        reader.readAsDataURL(readFile);
    });
}


