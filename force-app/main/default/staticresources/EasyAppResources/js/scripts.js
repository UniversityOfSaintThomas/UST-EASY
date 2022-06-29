let ready = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

ready(() => {
    appHideLoadingSpinner();
    pageLoadReRendered();
    activateCarousel();
});

function pageLoadReRendered() {
    //Disable fields that are set to not be editable
    document.querySelectorAll('.fieldNotEditable, .fieldNotEditable input, .fieldNotEditable select, .fieldNotEditable textarea').forEach(field => {
        field.setAttribute('disabled', 'disabled');
    });

    document.querySelector('form').onkeypress = checkEnter;

    //Make sure inputs are typed with HTML5 standards
    document.querySelectorAll(".slds-is-required .slds-input, .slds-is-required .slds-textarea, .slds-is-required .slds-select").forEach(item => {
        item.required = true;
    });

    document.querySelectorAll(".validateDecimal, .validateInteger, .validateNumber, .validateCurrency, .validatePercent").forEach(item => {
        item.type = "number";
    });

    document.querySelectorAll(".validatePhone").forEach(item => {
        item.type = "tel";
    });

    //Arranging Visualforce inputs to achieve SLDS accessibility
    vfCountryPicklist();
    summaryDetail();
    adjustLabelsFor();
    textValidations();
    radioCheckBox();
    checkbox();
    activateAutoComplete();
    activateTooltips();
    fileUploadAreas();
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
            upload.addEventListener(evt, function () {
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

        upload.addEventListener('drop', function () {
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
        let inputWrapper = inputFound.closest('.slds-form-element'),
            inputLabel = inputWrapper.querySelector('label'),
            helpText = inputWrapper.querySelector('.slds-form-element__help');

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


        let originObjId = autoItem.id;
        let comboBoxContainer = autoItem.closest('.slds-combobox_container');
        let hiddenInput = comboBoxContainer.querySelector('.inputHidden');
        let comboBox = comboBoxContainer.querySelector('.slds-combobox');
        let objectType = comboBox.dataset.objtype;
        let objectTypeFilter = comboBox.dataset.objtypefilter;
        let objectTypeNameField = comboBox.dataset.objtypenamefield;
        let removeButton = comboBox.querySelector('.refRemoveButton');
        let magGlass = comboBox.querySelector('.refMagGlass');
        let resultList = comboBox.querySelector('.slds-listbox');

        /* Remote reference lookup */
        const resultListTemplate = (title, subtitle, icon, originObjId, resultId) => `
            <li role="presentation" class="slds-listbox__item" data-title="${title} ${subtitle}" data-origId="${originObjId}" data-resultId="${resultId}">
                <div id="option1" class="slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta" role="option">
                  <span class="slds-media__figure slds-listbox__option-icon">
                    <span class="slds-icon_container slds-icon-standard-account">
                      <svg class="slds-icon slds-icon_small" aria-hidden="true">
                        <use xlink:href="${icon}"></use>
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

        function lookupResultsFormatter(data, originObjId) {
            let outputList = ''
            let fieldNames = comboBox.dataset.objtypenamefield.replace(' ', '').split(',');
            data.forEach(result => {
                let resultName = '';
                let subTitle = '';
                let resultId = '';
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
                outputList += resultListTemplate(resultName, subTitle, comboBox.dataset.listicon, originObjId, resultId);
            });
            resultList.innerHTML = '';

            comboBox.classList.remove('slds-is-open');
            if (outputList) {
                comboBox.classList.add('slds-is-open');
            }

            resultList.insertAdjacentHTML("beforeend", outputList);

            resultList.querySelectorAll('li').forEach(refItem => {
                refItem.addEventListener('click', function () {
                    if (refItem.dataset.title === '**createnew**') {
                        if (typeof window['setCreatingNewRelatedRecordAF' + groupId] === "function" && recordId && resultId) {
                            window['setCreatingNewRelatedRecordAF' + groupId](recordId, resultId)
                        }
                    } else {
                        hiddenInput.value = refItem.dataset.resultid;
                        autoItem.value = refItem.dataset.title;
                        refValueAdded();
                    }
                });
            });
        }

        if (autoItem.value) {
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
            let searchTerm = autoItem.value;
            if (objectType && objectTypeNameField && searchTerm.length > 2) {
                lookupSearchJS(objectType, objectTypeFilter, objectTypeNameField, searchTerm, lookupResultsFormatter, originObjId);
            }
        });


        // comboBox.addEventListener('focusout', (e) => {
        //     console.log('focus out of combo box');
        //     autoItem.classList.remove('slds-has-focus');
        //     comboBox.classList.remove('slds-is-open');
        // });
    });
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

/* Carousel Script */
function activateCarousel(slideMoveTo) {
    // Variables to target our base class,  get carousel items, count how many carousel items there are, set the slide to 0 (which is the number that tells us the frame we're on), and set motion to true which disables interactivity.
    let items = document.getElementsByClassName("carousel__item"),
        totalItems = items.length,
        slide = 0,
        moving = true,
        saveAndAdvance = document.querySelector('[id$="saveAndAdvance"]'),
        saveAndGoBack = document.getElementById('saveAndGoBack'),
        next = document.getElementsByClassName('carousel__button--next')[0],
        prev = document.getElementsByClassName('carousel__button--prev')[0];

    // Set click events to navigation buttons
    function setEventListeners() {
        next.addEventListener('click', moveNext);
        prev.addEventListener('click', movePrev);
        if (totalItems === 1) {
            next.style.display = 'none';
            prev.style.display = 'none';
            saveAndAdvance.style.dispay = 'inline-flex';
        } else {
            prev.style.display = 'none';
            saveAndAdvance.style.display = "none";
        }
        if (slide === 0 && previousRequirement) {
            saveAndGoBack.style.display = 'inline-flex';
        }
    }

    // Disable interaction by setting 'moving' to true for the same duration as our transition (0.5s = 500ms)
    function disableInteraction() {
        moving = true;
        setTimeout(function () {
            moving = false
        }, 500);
    }

    let moveCarouselTo = function (slide) {
        if (!moving) {
            disableInteraction();
            let newPrevious = slide - 1,
                newNext = slide + 1;

            if (totalItems > 1) {

                if (slide === 0) {
                    prev.style.display = "none";
                    if (previousRequirement) {
                        saveAndGoBack.style.display = 'inline-flex';
                    }
                    newPrevious = (totalItems - 1);
                } else if (slide === 1) {
                    saveAndGoBack.style.display = "none"
                    newPrevious = 0;
                } else if (slide === (totalItems - 1)) {
                    newPrevious = (slide - 1);
                    newNext = 0;
                }
                if (slide + 1 === totalItems || totalItems === 1) {
                    saveAndAdvance.style.display = "inline-flex"
                    next.style.display = "none"
                } else {
                    saveAndAdvance.style.display = "none"
                    next.style.display = "inline-flex"
                }

                if (slide > 0) {
                    prev.style.display = "inline-flex"
                } else {
                    prev.style.display = "none"
                }

                for (let i = 0; i < items.length; i++) {
                    items[i].classList.remove('prev');
                    items[i].classList.remove('next');
                    items[i].classList.remove('active');
                }
                if (items[newPrevious]) {
                    items[newPrevious].classList.add("prev");
                }
                if (items[slide]) {
                    items[slide].classList.add("active");
                }
                if (items[newNext]) {
                    items[newNext].classList.add("next");
                }

            }
        }
    }


    function moveNext() {
        if (!moving) {
            if (slide === (totalItems - 1)) {
                slide = 0;
            } else {
                slide++;
            }
            moveCarouselTo(slide);
        }
    }

    function movePrev() {
        if (!moving) {
            if (slide === 0) {
                slide = (totalItems - 1);
            } else {
                slide--;
            }
            moveCarouselTo(slide);
        }
    }

    function initCarousel() {
        setEventListeners();
        moving = false;
    }

    initCarousel();

    if (slideMoveTo) {
        if (!moving) {
            moveCarouselTo(parseInt(slideMoveTo));
        }
    }

}

/* Spinners on/off */
function appHideLoadingSpinner() {
    document.getElementById('loadSpinner').style.display = "none";
    return true;
}

function appShowLoadingSpinner() {
    document.getElementById('loadSpinner').style.display = "block";
    return true;
}

function hideFormSpinner() {
    document.getElementById("form-spinner").style.display = 'none';
}

function showFormSpinner() {
    document.getElementById("form-spinner").style.display = 'block';
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

//Validate form elements on submit
function checkForm() {
    // let theForm = document.querySelector('form');
    // theForm.reportValidity();
    let error_count = 0;

    error_count = error_count + textValidations(true);

    if (error_count > 0) {
        let foundErrors = document.querySelector(".slds-has-error");
        if (foundErrors) {
            let carouselItem = foundErrors.closest('.carousel__item');
            activateCarousel(carouselItem.dataset.slide);
        }
        window.scrollTo(0, 0);
        return false;
    }
    return true;
}

//Input validations
function textValidations(checkFormValidate) {
    let errors = 0;
    let allPhones = document.querySelectorAll('.validatePhone');
    let allSSN = document.querySelectorAll('.validateSSN');
    let allNamCharacters = document.querySelectorAll('.validateName');
    let allEmails = document.querySelectorAll('.validateEmail');
    let allUrls = document.querySelectorAll('.validateURL');
    let allRequiredInputs = document.querySelectorAll(".slds-is-required .slds-input, .slds-is-required .slds-textarea, .slds-is-required .slds-select");

    const re_email = /^([a-zA-Z0-9_.\-.'.+])+@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    const re_url = /^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z0-9\u00a1-\uffff][a-z0-9\u00a1-\uffff_-]{0,62})?[a-z0-9\u00a1-\uffff]\.)+(?:[a-z\u00a1-\uffff]{2,}\.?))(?::\d{2,5})?(?:[/?#]\S*)?$/;
    const re_number = /[^\d-]/;
    const re_decimal = /[^\d-.]/;
    const re_phoneIllegals = /[^\d+-/(/)]/;
    const re_phoneFormat = /^(1|)?(\d{3})(\d{3})(\d{4})$/;
    const re_phone = /[\d+\-\(\) ]/;
    const re_snn = /^\d{3}-\d{2}-\d{4}$/;
    const re_snnFormat = /(\d{3})(\d{2})(\d{4})$/;
    const re_ssnIllegals = /[^\d+-]/;
    const re_nameIllegals = /[\d\(\)@#$,]/;

    //Required input check
    if (checkFormValidate) {
        allRequiredInputs.forEach(item => {
            if (item) {
                if (!item.value) {
                    activateErrorState(item, 'change')
                }
            }
        });

        document.querySelectorAll(".selectableOL").forEach(sel => {
            let selWrap = sel.closest('.slds-form-element');
            let hiddenData = document.querySelector('[id$="' + sel.dataset.hiddendataid + '"]').id;
            if (selWrap.classList.contains("slds-is-required")) {
                if (!document.getElementById(hiddenData).value) {
                    activateErrorState(sel, 'click')
                }
            }
        });
    }

    //Format and validate phone numbers
    allPhones.forEach(phone => {

        //format directly after input
        phone.addEventListener('change', function () {
            let cleaned = String(phone.value).replace(/\D/g, "");
            let match = cleaned.match(re_phoneFormat);
            if (match) {
                let intlCode = match[1] ? "+1 " : "";
                phone.value = [intlCode, "(", match[2], ") ", match[3], "-", match[4]].join("");
            }
        });

        //Don't allow anything but phone number characters on key-up
        phone.addEventListener('keyup', function () {
            phone.value = phone.value.replace(re_phoneIllegals, '');
        })

        //Check if the final phone number matches correctly before submit
        if (checkFormValidate) {
            if (!phone.value.match(re_phone)) {
                activateErrorState(phone, 'change');
            }
        }

    });

    allNamCharacters.forEach(nameInput => {
        //Don't allow anything but phone number characters on key-up
        nameInput.addEventListener('keyup', function () {
            nameInput.value = nameInput.value.replace(re_nameIllegals, '');
        })

        if (checkFormValidate) {
            nameInput.value = nameInput.value.replace(re_nameIllegals, '');
        }
    });

    //Social Security Validation
    allSSN.forEach(ssn => {
        ssn.addEventListener('keyup', function () {
            ssn.value = ssn.value.replace(re_ssnIllegals, '');
        })

        ssn.addEventListener('change', function () {
            let cleaned = String(ssn.value).replace(/\D/g, "");
            if (cleaned.length === 9) {
                let match = cleaned.match(re_snnFormat);
                if (match) {
                    ssn.value = [match[1], "-", match[2], "-", match[3]].join("");
                }
            } else {
                activateErrorState(ssn, 'change');
            }
        });

        if (checkFormValidate && !ssn.value.match(re_snn)) {
            activateErrorState(ssn, 'change');
        }
    });

    //Email Validation
    allEmails.forEach(email => {
        if (checkFormValidate && !email.value.match(re_email)) {
            activateErrorState(email, 'change');
        }
    });

    //URL validation
    allUrls.forEach(inputUrl => {
        inputUrl.value = inputUrl.value.replace(' ', '').trim();
        if (inputUrl.value) {
            if (!inputUrl.value.startsWith('http')) {
                inputUrl.value = 'https://' + inputUrl.value;
            }
            if (checkFormValidate && !inputUrl.value.match(re_url)) {
                activateErrorState(inputUrl, 'change');
            }
        }
    })

    function activateErrorState(errorInput, eventType) {
        let errorWrap = errorInput.closest('.slds-form-element');
        errorWrap.classList.add("slds-has-error");
        errorWrap.querySelectorAll(".slds-form-element__help").forEach(errorHelp => {
            errorHelp.style.display = "block"
        });
        errorInput.addEventListener(eventType, () => {
            errorWrap.classList.remove("slds-has-error");
            errorWrap.querySelectorAll(".slds-form-element__help").forEach(errorHelp => {
                errorHelp.style.display = "none";
            });
        });

        errors++;
    }

    return errors;
}
