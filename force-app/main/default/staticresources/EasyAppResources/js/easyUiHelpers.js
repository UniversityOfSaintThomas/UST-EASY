/* ============================================================
   easyUiHelpers.js — spinners, validation modal, tooltips, autocomplete lookup, and encrypted-field toggles.
   ============================================================ */

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
        clearFieldLInk.href = '#'
        clearFieldLInk.addEventListener('click', function () {
            refValueRemoved()
            return false;
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
                    <a href="#" onclick="return false"> <!-- This a tag looks useless, but it's making the listbox item focusable, thus available to tabbing, arrows, and accessibility navigation in general. -->
                        <span class="slds-listbox__option-text slds-listbox__option-text_entity">${title}</span>
                        <span class="slds-listbox__option-meta slds-listbox__option-meta_entity">${subtitle}</span>
                    </a>
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
function showValidationModal(title, message, callback) {
    activateModal(title, `<p>${message}</p>`, 'Continue Anyway', callback);
}

/* Spinners on/off */
let spinnerFocusElement = null;

function appHideLoadingSpinner(restoreFocus = true) {
    if (document.getElementById('loadSpinner')) {
        document.getElementById('loadSpinner').style.display = "none";
    }
    if (restoreFocus == true && spinnerFocusElement != null) {
        document.getElementById(spinnerFocusElement).focus();
    }
    return true;
}

function appShowLoadingSpinner() {
    spinnerFocusElement = document.activeElement.id;
    if (document.getElementById('loadSpinner')) {
        document.getElementById('loadSpinner').style.display = "block";
    }
    return true;
}

function hideFormSpinner(restoreFocus = true, focusOnFirstInput = false) {
    if (document.getElementById('form-spinner')) {
        document.getElementById("form-spinner").style.display = 'none';
    }
    if (restoreFocus == true && spinnerFocusElement != null) {
        if (focusOnFirstInput == true) {
            let inputElements = document.getElementById(spinnerFocusElement.id).parentElement.parentElement.parentElement.querySelectorAll("select, input");
            if (inputElements.length > 0) {
                spinnerFocusElement = inputElements[0];
            }
            spinnerFocusElement.focus();
        }
    }
}

function showFormSpinner() {
    spinnerFocusElement = document.activeElement.id;
    if (document.getElementById('form-spinner')) {
        document.getElementById("form-spinner").style.display = 'block';
    }
}

function showFormSpinnerRelatedRecord() {
    if (document.getElementById('form-spinner')) {
        document.getElementById("form-spinner").style.display = 'block';
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

function encryptedFieldShow() {

    document.querySelectorAll('.textEncryptedWrap').forEach(function (encryptedFieldWrap) {

        const encryptField = encryptedFieldWrap.querySelector('.validateTextEncrypted'); //using class validate{!inputType}
        const iconPanel = encryptedFieldWrap.querySelector('.encryptShowHideIcon');
        const iconShow = encryptedFieldWrap.querySelector('span.encryptShowIcon');
        const iconHide = encryptedFieldWrap.querySelector('span.encryptHideIcon');
        const iconText = encryptedFieldWrap.querySelector('span.encryptHideIconText');

        if (encryptField) {

            if (iconPanel) {

                if (encryptField.value) {
                    iconPanel.style.display = 'none';
                } else {
                    iconHide.style.display = 'none';
                }

                let clickIntervalId;

                iconPanel.addEventListener('click', function () {

                    if (encryptField.value) {

                        if (encryptField.type === "password") {
                            encryptField.type = "text";
                            iconShow.style.display = 'none';
                            iconHide.style.display = '';

                            let timeLeft = 6;

                            clickIntervalId = setInterval(function () {
                                timeLeft--;

                                if (timeLeft > 0 && timeLeft <= 3) {
                                    iconText.innerHTML = 'hide in ' + timeLeft;
                                }

                                if (timeLeft === 0) {
                                    encryptField.type = "password";
                                    iconShow.style.display = '';
                                    iconHide.style.display = 'none';
                                    iconText.innerHTML = 'hide';
                                    clearInterval(clickIntervalId);
                                }
                            }, 1000);

                        } else {
                            encryptField.type = "password";
                            iconShow.style.display = '';
                            iconHide.style.display = 'none';
                            iconText.innerHTML = 'hide';
                            clearInterval(clickIntervalId);
                        }
                    }
                })
            }

            encryptField.addEventListener('keyup', function (e) {

                if (!e.target.value) {
                    iconPanel.style.display = '';
                    iconHide.style.display = 'none';
                }
            })
        }
    })
}
