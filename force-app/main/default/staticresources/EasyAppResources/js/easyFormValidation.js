/* ============================================================
   easyFormValidation.js — form/field validation, error-state wiring, and add-record validation.
   ============================================================ */

// Tracks which elements already have formatting/validation listeners so repeated
// textValidations() calls don't stack duplicate handlers.
const listenersAttached = new WeakSet();

const minMaxMap = {
    validateACT: {min: 0, max: 36},
    validateSATComposite: {min: 0, max: 1600},
    validateSATSubject: {min: 0, max: 800},
    validateAge: {min: 0, max: 120}
};

// Sets numeric fields to type="number", applies min/max attributes for
// ACT/SAT/age fields, and wires live blur/change range validation as the
// user fills out the form. Called from pageLoadReRendered() in easyCore.js.
function numericFieldValidation(scope) {
    scope.querySelectorAll(".validateDecimal, .validateInteger, .validateNumber, .validateCurrency, .validatePercent, .validateACT, .validateSATComposite, .validateSATSubject, .validateAge").forEach(item => {
        item.type = "number";
        if (item.value === '' || item.value === null) {
            item.value = null;
        }
        item.classList.add('slds-number');

        for (const cls in minMaxMap) {
            if (item.classList.contains(cls)) {
                item.setAttribute('min', minMaxMap[cls].min);
                item.setAttribute('max', minMaxMap[cls].max);
            }
        }

        item.addEventListener('blur', () => checkMinMax(item));
        item.addEventListener('change', () => checkMinMax(item));

        function checkMinMax(item) {
            const min = parseFloat(item.getAttribute('min'));
            const max = parseFloat(item.getAttribute('max'));
            const value = parseFloat(item.value);

            // Limit input length to max digits
            if (item.value.length > String(max).length) {
                item.value = item.value.substring(0, String(max).length);
            }

            if (value < min || value >= max) {
                activateErrorStateWrap(item, 'change');
                item.value = null;
            }
        }
    });
}

function addRecordValidation(elem) {
    showFormSpinner();
    let recWrap = elem.closest('.slds-card');
    hideFormSpinner();
    window.scrollTo(0, 0);
    if (textValidations(true, recWrap) === 0) {
        return true;
    }
    return false;
}

function checkForm() {
    let errorCount = 0;
    errorCount = errorCount + textValidations(true);

    if (errorCount > 0) {
        const foundErrors = document.querySelector(".slds-has-error");
        if (foundErrors) {
            if (isCarousel()) {
                const carouselItem = foundErrors.closest('.carousel__item');
                activateCarousel(carouselItem.dataset.slide);
            }
            const errorInputs = foundErrors.querySelector("select, input");
            if (errorInputs) {
                errorInputs.focus();
                spinnerFocusElement = errorInputs.id;
                // checkForm() MAY be happening while the appSpinner is up; if so,
                // you might set focus here but will lose it again when appSpinner goes
                // down, as focus reverts to whatever was focused when appSpinner started.
                // So hijack the appSpinner's memory to make sure it sticks.
            }
        }
        window.scrollTo(0, 0);
        return false;
    }

    //Sets back all fields with class validate{!inputType}=validateTextEncrypted back to type "password" for submit.
    document.querySelectorAll('.validateTextEncrypted').forEach(encryptedFieldWrap => {
        encryptedFieldWrap.type = 'password';
    });

    return true;
}

function checkForACTSATValidation(item) {
    for (let key in minMaxMap) {
        if (item.classList.contains(key)) {
            return true;
        }
    }
    return false;
}

//Input validations
function textValidations(checkFormValidate, documentStart) {
    let doc;
    if (!documentStart) {
        doc = document;
    } else {
        doc = documentStart;
    }
    let errors = 0;
    let allPhones = doc.querySelectorAll('.validatePhone');
    let allSSN = doc.querySelectorAll('.validateSSN');
    let allNamCharacters = doc.querySelectorAll('.validateName');
    let allEmails = doc.querySelectorAll('.validateEmail');
    let allUrls = doc.querySelectorAll('.validateURL');
    let allRequiredInputs = doc.querySelectorAll(".slds-is-required .slds-input, .slds-is-required .slds-textarea, .slds-is-required .slds-select, .slds-is-required .slds-checkbox, .slds-is-required .slds-radio_button-group .slds-radio_button-value");


    const re_email = /^([a-zA-Z0-9_.\-.'.+])+@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    const re_url = /^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z0-9¡-￿][a-z0-9¡-￿_-]{0,62})?[a-z0-9¡-￿]\.)+(?:[a-z¡-￿]{2,}\.?))(?::\d{2,5})?(?:[/?#]\S*)?$/;
    const re_number = /[^\d-]/;
    const re_decimal = /[^\d-.]/;
    const re_phoneIllegals = /[^\d+-/(/)]/;
    const re_phoneFormat = /^(1|)?(\d{3})(\d{3})(\d{4})$/;
    const re_phone = /[\d+\-\(\) ]/;
    const re_ssn = /^\d{3}-\d{2}-\d{4}$/;
    const re_ssnFormat = /(\d{3})(\d{2})(\d{4})$/;
    const re_ssnIllegals = /[^\d+-]/;
    const re_nameIllegals = /[\d\(\)@#$,]/;

    //Required input check
    if (checkFormValidate) {
        allRequiredInputs.forEach(item => {
            if (item) {
                if (item.classList.contains('slds-checkbox') || item.classList.contains('field-MultiPicklist')) {
                    let checkBoxChecked = item.querySelectorAll('input');
                    let checkBoxCheckedCount = 0;
                    checkBoxChecked.forEach(checkBox => {
                        if (checkBox.checked) {
                            checkBoxCheckedCount++;
                        }
                    });
                    if (checkBoxCheckedCount < 1) {
                        activateErrorState(checkBoxChecked, 'change')
                    }
                } else if (checkForACTSATValidation(item)) {
                    const numericValue = parseFloat(item.value);
                    let rangeValid = false;
                    for (const key in minMaxMap) {
                        if (item.classList.contains(key)) {
                            rangeValid = !isNaN(numericValue)
                                && numericValue >= minMaxMap[key].min
                                && numericValue <= minMaxMap[key].max;
                            break;
                        }
                    }
                    if (!rangeValid) {
                        item.value = null;
                        activateErrorState(item, 'change');
                    }
                } else if (!item.value.trim()) {
                    activateErrorState(item, 'change')
                }
            }
        });

        doc.querySelectorAll(".selectableOL").forEach(sel => {
            let selWrap = sel.closest('.slds-form-element');
            let hiddenData = doc.querySelector('[id$="' + sel.dataset.hiddendataid + '"]').id;
            if (selWrap.classList.contains("slds-is-required")) {
                if (!doc.getElementById(hiddenData).value) {
                    activateErrorState(sel, 'click')
                }
            }
        });

        doc.querySelectorAll('.docUploadInput').forEach(docUpload => {
            if (String(docUpload.placeholder) === 'true' && !Boolean(docUpload.value)) {
                doc.getElementById('error-108' + String(docUpload.name)).innerHTML = 'Upload required.';
                activateErrorState(docUpload, 'change');
            } else {
                doc.getElementById('error-108' + String(docUpload.name)).innerHTML = '';
            }
        });

    }

    //Format and validate phone numbers
    allPhones.forEach(phone => {
        if (!listenersAttached.has(phone)) {
            phone.addEventListener('keyup', function () {
                phone.value = phone.value.replace(re_phoneIllegals, '');
            });

            phone.addEventListener('blur', handlePhoneChange);
            phone.addEventListener('change', handlePhoneChange);
            listenersAttached.add(phone);
        }

        function handlePhoneChange() {
            let cleaned = String(phone.value).replace(re_phoneIllegals, '');
            let match = cleaned.match(re_phoneFormat);
            if (match) {
                let intlCode = match[1] ? "+1 " : "";
                phone.value = [intlCode, "(", match[2], ") ", match[3], "-", match[4]].join("");
            }
        }

        //Check if the final phone number matches the expected format before submit
        if (checkFormValidate && phone.value) {
            const cleanedPhone = String(phone.value).replace(re_phoneIllegals, '');
            if (!cleanedPhone.match(re_phoneFormat)) {
                activateErrorState(phone, 'change');
            }
        }
    });


    allNamCharacters.forEach(nameInput => {
        if (!listenersAttached.has(nameInput)) {
            nameInput.addEventListener('keyup', function () {
                nameInput.value = nameInput.value.replace(re_nameIllegals, '');
            });
            listenersAttached.add(nameInput);
        }

        if (checkFormValidate && nameInput.value) {
            nameInput.value = nameInput.value.replace(re_nameIllegals, '');
        }
    });

    //Social Security Validation
    allSSN.forEach(ssn => {
        if (!listenersAttached.has(ssn)) {
            ssn.addEventListener('keyup', function () {
                ssn.value = ssn.value.replace(re_ssnIllegals, '');
            });

            ssn.addEventListener('blur', handleSSNChange);
            ssn.addEventListener('change', handleSSNChange);
            listenersAttached.add(ssn);
        }

        function handleSSNChange() {
            let cleaned = String(ssn.value).replace(/\D/g, "");
            if (cleaned.length === 9) {
                let match = cleaned.match(re_ssnFormat);
                if (match) {
                    ssn.value = [match[1], "-", match[2], "-", match[3]].join("");
                }
            }
        }

        if (checkFormValidate && ssn.value) {
            if (!ssn.value.match(re_ssn)) {
                activateErrorState(ssn, 'change');
            }
        }
    });

    //Email Validation
    allEmails.forEach(email => {
        if (checkFormValidate && email.value) {
            if (!email.value.match(re_email)) {
                activateErrorState(email, 'change');
            }
        }
    });

    //URL validation
    allUrls.forEach(inputUrl => {
        inputUrl.value = inputUrl.value.replace(/\s+/g, '').trim();
        if (inputUrl.value) {
            if (!inputUrl.value.startsWith('http')) {
                inputUrl.value = 'https://' + inputUrl.value;
            }
            if (checkFormValidate && inputUrl.value) {
                if (!inputUrl.value.match(re_url)) {
                    activateErrorState(inputUrl, 'change');
                }
            }
        }
    })

    function activateErrorState(errorInput, eventType) {
        activateErrorStateWrap(errorInput, eventType);
        errors++;
    }

    return errors;
}

function activateErrorStateWrap(errorInput, eventType) {
    let errorWrap;
    //if error input is not an array of inputs add it to an array of inputs
    if (!(errorInput instanceof NodeList || errorInput instanceof HTMLCollection)) {
        errorInput = [errorInput];
    }
    //If error input is an array
    errorWrap = errorInput[0].closest('.slds-form-element');
    errorWrap.classList.add("slds-has-error");
    errorWrap.querySelectorAll(".slds-form-element__help").forEach(errorHelp => {
        errorHelp.style.display = "block"
    });
    //add event listner to all the inputs
    errorInput.forEach(input => {
        input.addEventListener(eventType, () => {
            errorWrap.classList.remove("slds-has-error");
            errorWrap.querySelectorAll(".slds-form-element__help").forEach(errorHelp => {
                errorHelp.style.display = "none";
            });
        });
    });
}
