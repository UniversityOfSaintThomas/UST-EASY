let ready = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}
let loadSpinner, formSpinner;
ready(() => {
    loadSpinner = document.getElementById('loadSpinner');
    formSpinner = document.getElementById("form-spinner");
    appHideLoadingSpinner();
    pageLoadReRendered();
});

function pageLoadReRendered() {

    //Disable fields that are set to not be editable
    let sldsScope = document.querySelector('.slds-scope');
    sldsScope.querySelectorAll('.fieldNotEditable, .fieldNotEditable input, .fieldNotEditable select, .fieldNotEditable textarea').forEach(field => {
        field.setAttribute('disabled', 'disabled');
    });

    sldsScope.querySelector('form').onkeypress = checkEnter;

    //Make sure inputs are typed with HTML5 standards
    sldsScope.querySelectorAll(".slds-is-required .slds-input, .slds-is-required .slds-textarea, .slds-is-required .slds-select").forEach(item => {
        item.required = true;
    });

    sldsScope.querySelectorAll(".validateDecimal, .validateInteger, .validateNumber, .validateCurrency, .validatePercent, .validateACT, .validateSATComposite, .validateSATSubject").forEach(item => {
        item.type = "number";
        if (item.classList.contains('validateACT')) {
            item.setAttribute('min', '0');
            item.setAttribute('max', '36');
        }
        if (item.classList.contains('validateSATComposite')) {
            item.setAttribute('min', '0');
            item.setAttribute('max', '1600');
        }
        if (item.classList.contains('validateSATSubject')) {
            item.setAttribute('min', '0');
            item.setAttribute('max', '800');
        }
    });

    sldsScope.querySelectorAll(".validatePhone").forEach(item => {
        item.type = "tel";
    });

    //Arranging Visualforce inputs to achieve SLDS accessibility
    activateCarousel();
    vfCountryPicklist();
    summaryDetail();
    radioCheckBox();
    checkbox();
    adjustLabelsFor();
    activateAutoComplete();
    activateTooltips();
    fileUploadAreas();
    checkForm(null, true);
    //Hide the form spinner if it is active
    hideFormSpinner();
}

function checkEnter(e) {
    e = e || event;
    let txtArea = /textarea/i.test((e.target || e.srcElement).tagName);
    return txtArea || (e.keyCode || e.which || e.charCode || 0) !== 13;
}

//Clicks buttons that save data and re-renders action areas
function reRenderAllGroups(rerenderName) {
    if (rerenderName && rerenderName !== 'none') {
        showFormSpinner();
        if (rerenderName === 'rerenderTheTable') {
            document.querySelector("[id$=reRenderTheTable]").click();
        } else if (rerenderName === 'reRenderTheTableLight') {
            document.querySelector("[id$=reRenderTheTableLight]").click();
        } else {
            document.querySelector("[id$=reRenderGroups]").click();
        }
    }
}

// SLDS Summary/Detail functionality https://www.lightningdesignsystem.com/components/summary-detail/
function summaryDetail() {
    document.querySelectorAll('.slds-summary-detail').forEach(item => {
        item.querySelector("button.slds-button").addEventListener('click', function (e) {
            e.preventDefault();
            let content = item.querySelector('.slds-summary-detail__content');
            if (content.style.display === 'none') {
                item.classList.add('slds-is-open')
                content.style.display = 'block';
            } else {
                item.classList.remove('slds-is-open')
                content.style.display = 'none';
            }
        });
    });
}


//Creates droppable file upload areas
function fileUploadAreas() {

    document.querySelectorAll('.slds-file-selector__dropzone').forEach(upload => {
        let fileInput = upload.querySelector('input');
        let fileCard = upload.closest('.slds-card');
        let currentFile = fileCard.querySelector('.currentlySelectedFile');

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
        });

        upload.addEventListener('click', function () {
            fileInput.click();
        });

        fileInput.addEventListener('change', function () {
            currentFile.innerHTML = findFileName(fileInput.value);
        });
    })
}

function findFileName(filePath) {
    if (filePath) {
        filePath = filePath.split('\\');
        filePath = filePath[filePath.length - 1];
    } else {
        filePath = 'None';
    }
    filePath = '<strong>Currently Selected:</strong> ' + filePath;
    return filePath;
}

//Makes sure all labels have id associations to the inputs
function adjustLabelsFor() {
    document.querySelectorAll('.slds-input, .slds-select, .slds-radio').forEach(inputFound => {
        let inputWrapper = inputFound.closest('.slds-form-element');
        let isElement = inputWrapper instanceof Element || inputWrapper instanceof HTMLDocument;
        let inputLabel = '';
        let helpText = '';
        if (isElement) {
            inputLabel = inputWrapper.querySelector('label');
            helpText = inputWrapper.querySelector('.slds-form-element__help');
        }
        if (inputLabel) {
            inputLabel.htmlFor = inputFound.getAttribute('id');
            if (inputWrapper.dataset.placeholder) {
                inputFound.setAttribute('placeholder', inputWrapper.dataset.placeholder);
            }
            if (inputWrapper.dataset.maxlength) {
                inputFound.setAttribute('maxlength', inputWrapper.dataset.maxlength);
            }
        }

        if (inputFound && helpText) {
            inputFound.setAttribute('aria-describedby', helpText.getAttribute('id'));
            inputFound.setAttribute('aria-invalid', 'false');
        }
    });
}

//SLDS Radio Group Button https://www.lightningdesignsystem.com/components/radio-button-group
function radioCheckBox() {
    document.querySelectorAll('.slds-radio_button-group').forEach(radioGroup => {
        let radioGroupValue = radioGroup.querySelector("[id$='radioField1']");
        radioGroup.querySelectorAll('.faux-radio-value').forEach(faux => {
            faux.checked = faux.value === radioGroupValue.value;
        });
        document.querySelectorAll('.slds-radio_button').forEach(radioButton => {
            radioButton.addEventListener('click', () => {
                radioGroupValue.value = radioButton.dataset.radiovalue;
                reRenderAllGroups(radioButton.dataset.rerendergroup);
            })
        });
    });
}

// SLDS Checkbox https://www.lightningdesignsystem.com/components/checkbox/
function checkbox() {
    document.querySelectorAll('.slds-checkbox.single-checkbox').forEach(cb => {
        cb.addEventListener('click', () => {
            let cbInput = cb.querySelector('input');
            cbInput.click();
        });
    });
}

// By default, replaceAll runs on ALL textarea fields.
// modified to run only on the class defined 'ckeditor'
//CKEDITOR.replaceAll = function(){for(var a=document.getElementsByClassName("ckeditor"),b=0;b<a.length;b++){var d=null,k=a[b];if(k.name||k.id){if("string"==typeof arguments[0]){if(!(new RegExp("(?:^|\\s)"+arguments[0]+"(?:$|\\s)")).test(k.className))continue}else if("function"==typeof arguments[0]&&(d={},!1===arguments[0](k,d)))continue;this.replace(k,d)}}};

// destroys and rebuilds the rich text fields after rerender
function afterRerenderRTF() {
    for (let name in CKEDITOR.instances) {
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


function activateAutoComplete() {

    document.querySelectorAll('.bind-autocomplete').forEach(autoItem => {
        let comboBoxContainer = autoItem.closest('.slds-combobox_container');
        let comboBox = comboBoxContainer.querySelector('.slds-combobox');
        let spinner = comboBox.querySelector('.slds-modal');
        let hiddenInput = comboBoxContainer.querySelector('.inputHidden');
        let removeButton = comboBox.querySelector('.refRemoveButton');
        let magGlass = comboBox.querySelector('.refMagGlass');
        let resultList = comboBox.querySelector('.slds-listbox');
        let originObjId = autoItem.id;
        let objectType = comboBox.dataset.objtype;
        let objectTypeFilter = comboBox.dataset.objtypefilter;
        let objectTypeNameField = comboBox.dataset.objtypenamefield;

        let clearField = document.createElement('li');
        clearField.classList.add('clear-search-field');
        clearField.classList.add('slds-listbox__item');
        let clearFieldLInk = document.createElement('a');
        clearFieldLInk.innerText = ' Clear search. '
        clearFieldLInk.addEventListener('click', function () {
            refValueRemoved()
        });

        /* Remote reference lookup */
        const resultListTemplate = (title, subtitle, icon, originObjId, resultId) => `
            <li role="presentation" class="slds-listbox__item" data-title="${title}, ${subtitle}" data-origId="${originObjId}" data-resultId="${resultId}">
                <div id="option1" class="slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta" role="option">
                  <span class="slds-media__figure slds-listbox__option-icon">
                    <span class="slds-icon_container slds-icon-standard-account">
                      <svg class="slds-icon slds-icon_small" aria-hidden="true">
                        <use xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="${icon}"></use>
                      </svg>
                    </span>
                  </span>
                  <span class="slds-media__body">
                    <span class="slds-listbox__option-text slds-listbox__option-text_entity">${title}</span>
                    <span class="slds-listbox__option-meta slds-listbox__option-meta_entity">${subtitle}</span>
                  </span>
                </div>
            </li>
        `;

        function refValueAdded() {
            comboBox.classList.remove('slds-is-open');
            autoItem.classList.add('slds-combobox__input-value');
            comboBoxContainer.classList.add('slds-has-selection');
            removeButton.style.display = 'inline-flex';
            magGlass.style.display = 'none';
        }

        function refValueRemoved() {
            comboBox.classList.remove('slds-is-open');
            autoItem.classList.remove('slds-combobox__input-value');
            comboBoxContainer.classList.remove('slds-has-selection');
            removeButton.style.display = 'none';
            magGlass.style.display = 'inline-flex';
            autoItem.value = '';
            hiddenInput.value = '';
            resultList.innerHTML = '';
        }

        async function fetchLookupResults(objectType, objectTypeFilter, objectTypeNameField, searchTerm) {
            try {
                let data = await lookupSearchJS(objectType, objectTypeFilter, objectTypeNameField, searchTerm);
                updateLookupUI(data);
            } catch (ex) {
                if (ex.name === 'AbortError') {
                    return; // Continuation logic has already been skipped, so return normally
                }
                resultList.innerHTML = ex.message;
            }
            setTimeout(() => {
                spinner.classList.remove('slds-fade-in-open');
                spinner.style.zIndex = '-1'
            }, 1000);
        }

        const updateLookupUI = (data) => {
            let outputList = ''
            if (data.length) {

                let fieldNames = comboBox.dataset.objtypenamefield.replace(' ', '').split(',');

                data.forEach(result => {
                    let resultName = '', subTitle = '', resultId = '';

                    if (result['Id']) {
                        resultId = result['Id'];
                    }

                    for (let x = 0; x < fieldNames.length; x++) {
                        let fieldName = fieldNames[x].trim();
                        if (x === 0) {
                            resultName = result[fieldName];
                        } else {
                            if (result[fieldName]) {
                                subTitle += result[fieldName] + ', ';
                            }
                        }
                    }

                    if (subTitle) {
                        subTitle = subTitle.substr(0, subTitle.length - 2);
                    }
                    subTitle = removeStartTrailComma(subTitle);
                    resultName = removeStartTrailComma(resultName);
                    outputList += resultListTemplate(resultName, subTitle, comboBox.dataset.listicon, originObjId, resultId);
                });

                resultList.innerHTML = '';

                comboBox.classList.remove('slds-is-open');
                if (outputList) {
                    comboBox.classList.add('slds-is-open');
                }

                resultList.innerHTML = outputList;

                resultList.querySelectorAll('li').forEach(refItem => {
                    refItem.addEventListener('click', function () {
                        if (refItem.dataset.title === '**createnew**') {
                            if (typeof window['setCreatingNewRelatedRecordAF' + groupId] === "function" && recordId && resultId) {
                                window['setCreatingNewRelatedRecordAF' + groupId](recordId, resultId)
                            }
                        } else {
                            hiddenInput.value = refItem.dataset.resultid;
                            autoItem.value = removeStartTrailComma(refItem.dataset.title);
                            refValueAdded();
                        }
                    });
                });

                clearField.innerText = ''
                clearField.appendChild(clearFieldLInk);
                resultList.appendChild(clearField);

            } else {
                resultList.innerHTML = '';
                clearField.innerText = 'No matching results...'
                clearField.appendChild(clearFieldLInk);
                resultList.appendChild(clearField);
            }
        }

        if (autoItem.value) {
            autoItem.classList.remove('slds-has-focus');
            comboBox.classList.remove('slds-is-open');
            refValueAdded();
        }

        autoItem.addEventListener('focusin', () => {
            autoItem.classList.add('slds-has-focus');
            comboBox.classList.add('slds-is-open');
        });

        removeButton.addEventListener('click', function (e) {
            e.preventDefault();
            refValueRemoved();
        });

        autoItem.addEventListener('keyup', () => {
            spinner.style.zIndex = null;
            spinner.classList.add('slds-fade-in-open');
            let searchTerm = autoItem.value;
            if (searchTerm.length > 2) {
                fetchLookupResults(objectType, objectTypeFilter, objectTypeNameField, searchTerm);
            }
        });

    });
}

function removeStartTrailComma(stringIn) {
    stringIn = stringIn.trim();
    stringIn = stringIn.replace(/(^,)|(,$)/g, '');
    return stringIn;
}

//Visualforce state/country picklist enabled does not style correctly. This observes mutations and styles the picklsit.
function vfCountryPicklist() {
    let vfPicklists = document.querySelectorAll('.vfStatePicklist span');
    vfPicklists.forEach(pl => {
        pl.querySelector('select').classList.add('slds-select');
    });
    let obs = new MutationObserver(function (mutations, observer) {
        mutations.forEach(mut => {
            mut.addedNodes.forEach(mutNode => {
                if (mutNode.tagName.toLowerCase() === 'select') {
                    mutNode.classList.add('slds-select');
                }
            });
        });
    });
    vfPicklists.forEach(pl => {
        obs.observe(pl, {attributes: true, childList: true, characterData: true});
    });
}

function navigateRequirementGroup(redirectTo) {
    appShowLoadingSpinner();
    if (redirectTo === 'forwards') {
        if (checkForm()) {
            performDocUploadSave(nextRequirement);
        } else {
            appHideLoadingSpinner();
            hideFormSpinner();
        }
    } else if (redirectTo === 'back') {
        performDocUploadSave(previousRequirement);
    } else {
        performDocUploadSave(redirectTo);
    }
}

/* Tooltip */
function activateTooltips() {
    document.querySelectorAll('.aria-describedby-tooltip').forEach(item => {
        let toolTipElement = document.getElementById(item.getAttribute('aria-describedby'));
        item.addEventListener('mousemove', function (e) {
            let toolTipOffsetElem = toolTipElement.offsetParent;
            toolTipElement.classList.remove('slds-fall-into-ground', 'slds-nubbin_left', 'slds-nubbin_right');
            toolTipElement.classList.add('slds-rise-from-ground');
            let leftPosition = (e.clientX - toolTipOffsetElem.getBoundingClientRect().x);
            let topPosition = ((e.clientY - toolTipOffsetElem.getBoundingClientRect().y) + 25);
            if (document.body.clientWidth < toolTipElement.clientWidth + e.clientX) {
                toolTipElement.classList.add('slds-nubbin_top-right');
                leftPosition = leftPosition - (toolTipElement.clientWidth - 10);
            } else {
                toolTipElement.classList.add('slds-nubbin_top-left');
                leftPosition = leftPosition - 10;
            }
            toolTipElement.style.left = leftPosition + 'px';
            toolTipElement.style.top = topPosition + 'px';
        });
        item.addEventListener('mouseleave', function () {
            toolTipElement.classList.remove('slds-rise-from-ground');
            toolTipElement.classList.add('slds-fall-into-ground');
        });
    });
}

/* Spinners on/off */
function appHideLoadingSpinner() {
    loadSpinner.style.display = "none";
}

function appShowLoadingSpinner() {
    loadSpinner.style.display = "block";
}

function hideFormSpinner() {
    formSpinner.style.display = 'none';
}

function showFormSpinner() {
    formSpinner.style.display = 'block';
}


