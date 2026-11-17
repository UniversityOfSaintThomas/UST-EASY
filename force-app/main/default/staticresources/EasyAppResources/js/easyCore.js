/* ============================================================
   easyCore.js — page bootstrap, DOM-ready init, and shared field setup. Loaded FIRST (defines docReady, used at parse time by easyLwcBridge.js).
   ============================================================ */

function docReady(fn) {
    // see if DOM is already available
    if (document.readyState === "complete" || document.readyState === "interactive") {

        setTimeout(fn, 1);
    } else {
        document.addEventListener("DOMContentLoaded", fn);
    }
}

/**
 * Page bootstrap: runs once the DOM is ready. Hides the load spinner, wires up
 * all field/UX behaviour (pageLoadReRendered), then activates the carousel.
 * Functions called here live in the other easy*.js files, all loaded before DOMContentLoaded fires.
 */
docReady(function () {
    appHideLoadingSpinner();
    pageLoadReRendered();
    activateCarousel();
});

function pageLoadReRendered(isRelatedRecordReRender = false) {

    //Disable fields that are set to not be editable
    let sldsScope = document.querySelector('.slds-scope');

    sldsScope.querySelectorAll('.fieldNotEditable, .fieldNotEditable input, .fieldNotEditable select, .fieldNotEditable textarea').forEach(field => {
        field.setAttribute('disabled', 'disabled');
    });

    if (checkEnter) {
        sldsScope.querySelector('form').onkeypress = checkEnter;
    }

    //Make sure inputs are typed with HTML5 standards
    sldsScope.querySelectorAll(".slds-is-required .slds-input, .slds-is-required .slds-textarea, .slds-is-required .slds-select").forEach(item => {
        item.required = true;
    });


    numericFieldValidation(sldsScope);

    sldsScope.querySelectorAll(".validatePhone").forEach(item => {
        item.type = "tel";
    });

    sldsScope.querySelectorAll('.new-record-button').forEach(newRecButton => {
        let saveRec = newRecButton.closest('.slds-card').querySelector('.save-record-button');
        //If saveRec exists make the newRecButton hidden
        if (saveRec) {
            newRecButton.style.display = 'none';
        }
    });

    //Arranging Visualforce inputs to achieve SLDS accessibility
    findApplicationLinkTargetSelf();
    vfCountryPicklist();
    summaryDetail();
    adjustLabelsFor();
    textValidations();
    radioCheckBox();
    checkbox();
    activateAutoComplete();
    activateTooltips();
    fileUploadAreas();
    encryptedFieldShow();
    //Hide the form spinner if it is active
    hideFormSpinner(true, isRelatedRecordReRender);
}

function findApplicationLinkTargetSelf() {
    document.querySelectorAll('.slds-scope a').forEach(link => {
        if (link.href.toLowerCase().includes('/applicationlink?')) {
            link.setAttribute('target', '_self');
        }
    });
}


//Add record action
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
        item.querySelector(".slds-button, .summary-detail-toggle").addEventListener('click', function (e) {
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

function disableReminderEmailButton(button) {
    button.setAttribute('disabled', 'disabled');
    let elementWrap = button.closest('.slds-form-element');
    elementWrap.querySelector('.oneReminderPerDay').style.display = "block";
}

//Creates droppable file upload areas
function adjustLabelsFor() {
    document.querySelectorAll('.slds-input, .slds-select, .slds-radio').forEach(inputFound => {
        let inputWrapper = inputFound.closest('.slds-form-element');
        if (inputWrapper) {
            let inputLabel = inputWrapper.querySelector('label');
            let helpText = inputWrapper.querySelector('.slds-form-element__help');

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
    function checkboxListener(cb) {
        return function (e) {
            if (e.type === 'click' || (e.type === 'keypress' && e.keyCode === 13)) {
                let cbInput = cb.querySelector('input');
                cbInput.click();
            }
        };
    }

    document.querySelectorAll('.slds-checkbox.single-checkbox').forEach(cb => {
        cb.addEventListener('click', checkboxListener(cb));
        cb.addEventListener('keypress', checkboxListener(cb));
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
