// $(document).keypress(function (event) {
//     if (event.which == '13') {
//         event.preventDefault();
//     }
// });

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
    document.querySelectorAll('.fieldNotEditable,.fieldNotEditable input,.fieldNotEditable select,.fieldNotEditable textarea').forEach(field => {
        field.setAttribute('disabled', 'disabled');
    });

    // SLDS Summary/Detail functionality https://www.lightningdesignsystem.com/components/summary-detail/
    document.querySelectorAll('.slds-summary-detail').forEach(item => {
        item.querySelector("button.slds-button").addEventListener('click', function (e) {
            let content = item.querySelector('.slds-summary-detail__content');
            item.classList.remove('slds-is-open')
            if (content.style.display === 'none') {
                item.classList.add('slds-is-open')
                content.style.display = 'block';
            } else {
                content.style.display = 'none';
            }
        });
    });

    let allPhones = document.querySelectorAll('.validPhone');
    allPhones.forEach(function (ph) {
        ph.addEventListener('change', function (e) {
            formatPhone(ph);
        });
    });
    adjustLabelsFor();
    radioCheckBox();
    activateAutoComplete();
    hideFormSpinner();
    activateTooltips();
}

function adjustLabelsFor() {
    document.querySelectorAll('.slds-input, .slds-select').forEach(inputFound => {
        let inputWrapper = inputFound.closest('.slds-form-element'),
            inputLabel = inputWrapper.querySelector('label'),
            helpText = inputWrapper.querySelector('.slds-form-element__help');

        if (inputLabel) {
            inputLabel.htmlFor = inputFound.getAttribute('id');
        }
        if (inputFound && helpText) {
            if (helpText) {
                inputFound.setAttribute('aria-describedby', helpText.getAttribute('id'));
                inputFound.setAttribute('aria-invalid', 'false');
            }
            if (inputWrapper.dataset.placeholder) {
                field.setAttribute('placeholder', placeholders[inputId])
                inputFound.setAttribute('placeholder', inputWrapper.dataset.placeholder);
            }
            if (inputWrapper.dataset.maxlength) {
                inputFound.setAttribute('maxlength', inputWrapper.dataset.maxlength);
            }
        }
    });
}

function radioCheckBox() {
    document.querySelectorAll('.slds-radio_button-group').forEach(radioGroup => {
        let radioGroupValue = radioGroup.querySelector("[id$='radioField1']");
        radioGroup.querySelectorAll('.faux-radio-value').forEach(faux => {
            faux.checked = faux.value === radioGroupValue.value;
        });
        document.querySelectorAll('.slds-radio_button').forEach(radioButton => {
            radioButton.addEventListener('click', (e) => {
                showFormSpinner();
                radioGroupValue.value = radioButton.dataset.radiovalue;
                rerenderTheTable();
            })
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

function formatPhone(phone) {
    let internationalNum = false;
    let inValue = phone.value;
    if (inValue.startsWith("+")) {
        internationalNum = true;
    }
    let digits = inValue.replace(/\D/g, '');
    if (internationalNum) {
        if (digits.startsWith("0")) {
            digits = digits.substring(1);
        }
        phone.value = "+" + digits;
    } else {
        phone.value = digits.replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3");
    }
}

/* Remote reference lookup */
const resultListTemplate = (title, subtitle, icon, originObjId, resultId) => `
    <li role="presentation" class="slds-listbox__item">
        <div id="option1" class="slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta" role="option" onclick="assignLookupValue('${title} ${subtitle}','${originObjId}', '${resultId}');">
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

function assignLookupValue(selectedValue, originObjId, resultId) {
    let originObject = document.getElementById(originObjId);
    let recordIdWrap = originObject.closest('.record-id');
    let comboBox = originObject.closest('.slds-combobox');
    let fullWrapper = originObject.closest('.referenceLookup');
    let hiddenInput = fullWrapper.querySelector('.inputHidden');
    let groupId = comboBox.dataset.groupitemid;
    let recordId = recordIdWrap.dataset.recid;
    comboBox.classList.remove('slds-is-open');
    hiddenInput.value = resultId;
    originObject.value = selectedValue;
    console.log('groupId : ' + groupId);
    console.log('recordId : ' + recordId);
    console.log('resultId : ' + resultId);
    //For creation of a new record ui.item.value == '**createnew**'
    /*
    if (typeof window['setCreatingNewRelatedRecordAF' + groupId] === "function" && recordId && resultId) {
        window['setCreatingNewRelatedRecordAF' + groupId](recordId,resultId)
        console.log('result function called!');
    }
    */
}

function lookupResultsFormatter(data, originObjId) {
    let outputList = '';
    let originObject = document.getElementById(originObjId);
    let comboBox = originObject.closest('.slds-combobox');
    let resultList = comboBox.querySelector('.slds-listbox');
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
}

function activateAutoComplete() {
    document.querySelectorAll('.bind-autocomplete').forEach(autoItem => {
        autoItem.addEventListener('keyup', (e) => {
            let comboBox = autoItem.closest('.slds-combobox');
            let objectType = comboBox.dataset.objtype;
            let objectTypeFilter = comboBox.dataset.objtypefilter;
            let objectTypeNameField = comboBox.dataset.objtypenamefield;
            let searchTerm = autoItem.value;
            let originObjId = autoItem.id;
            if (objectType && objectTypeFilter && objectTypeNameField && searchTerm.length > 2) {
                lookupSearchJS(objectType, objectTypeFilter, objectTypeNameField, searchTerm, lookupResultsFormatter, originObjId);
            }
        })
    });
}


function navigateRequirementGroup(redirectTo) {
    appShowLoadingSpinner();
    if (redirectTo === 'forwards') {
        performDocUploadSave(nextRequirement);
    } else if (redirectTo === 'back') {
        performDocUploadSave(previousRequirement);
    } else {
        performDocUploadSave(redirectTo);
    }
}

/* Carousel Script */
function activateCarousel() {
    // Variables to target our base class,  get carousel items, count how many carousel items there are, set the slide to 0 (which is the number that tells us the frame we're on), and set motion to true which disables interactivity.
    const itemClassName = "carousel__item";
    let items = document.getElementsByClassName(itemClassName),
        totalItems = items.length,
        slide = 0,
        moving = true,
        saveAndAdvance = document.getElementById('saveAndAdvance'),
        saveAndGoBack = document.getElementById('saveAndGoBack'),
        next = document.getElementsByClassName('carousel__button--next')[0],
        prev = document.getElementsByClassName('carousel__button--prev')[0];

    function setInitialClasses() {
        items[0].classList.add("active");
        if (totalItems === 2) {
            items[1].classList.add("next");
        } else if (totalItems > 2) {
            items[totalItems - 1].classList.add("prev");
            items[1].classList.add("next");
        }
    }

    // Set click events to navigation buttons
    function setEventListeners() {
        console.log(totalItems);
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

    function moveCarouselTo(slide) {
        if (!moving) {
            disableInteraction();
            let newPrevious = slide - 1,
                newNext = slide + 1,
                oldPrevious = slide - 2,
                oldNext = slide + 2;

            if (totalItems > 1) {

                if (newPrevious <= 0) {
                    oldPrevious = (totalItems - 1);
                } else if (newNext >= (totalItems - 1)) {
                    oldNext = 0;
                }

                if (slide === 0) {
                    prev.style.display = "none";
                    if (previousRequirement) {
                        saveAndGoBack.style.display = 'inline-flex';
                    }
                    newPrevious = (totalItems - 1);
                    oldPrevious = (totalItems - 2);
                    oldNext = (slide + 1);
                } else if (slide === 1) {
                    newPrevious = 0;
                    oldPrevious = (totalItems - 1);
                    oldNext = (slide + 1);
                } else if (slide === (totalItems - 1)) {
                    newPrevious = (slide - 1);
                    newNext = 0;
                    oldNext = 1;
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

                items[oldPrevious].className = itemClassName;
                items[oldNext].className = itemClassName;
                items[newPrevious].className = itemClassName + " prev";
                items[slide].className = itemClassName + " active";
                items[newNext].className = itemClassName + " next";
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
        setInitialClasses();
        setEventListeners();
        moving = false;
    }

    initCarousel();
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

function appShowConfirmation() {
    document.getElementById("confirmation").style.display = "block";
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
        item.addEventListener('mouseleave', function (e) {
            toolTipElement.classList.remove('slds-rise-from-ground');
            toolTipElement.classList.add('slds-fall-into-ground');
        });
    });
}

