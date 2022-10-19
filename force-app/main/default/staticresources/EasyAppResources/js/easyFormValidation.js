//Validate form elements on submit

// Validation for record only (not whole form)
function addRecordValidation(elem) {
    let isElement = elem instanceof Element || elem instanceof HTMLDocument;
    let recWrap = null;
    let noErrors = true;
    if (elem && isElement) {
        recWrap = elem.closest('.slds-card');
        noErrors = checkForm(recWrap);
    }
    return noErrors;
}

function checkForm(elem, errorsOff) {
    // let theForm = document.querySelector('form');
    // theForm.reportValidity();
    let formWrap;
    let scopedDoc = false;
    if (elem) {
        formWrap = elem;
        scopedDoc = true;
    } else {
        formWrap = document.querySelector('.slds-scope');
    }

    let error_count = 0;
    error_count = error_count + textValidations(formWrap, errorsOff);

    if (error_count > 0) {
        let foundErrors = formWrap.querySelector(".slds-has-error");
        if (foundErrors && isCarousel() && !scopedDoc) {
            let carouselItem = foundErrors.closest('.carousel__item');
            activateCarousel(carouselItem.dataset.slide);
        }
        hideFormSpinner();
        window.scrollTo(0, 0);
        return false;
    }
    hideFormSpinner();
    return true;
}

//Input validations
function textValidations(formWrap, errorsOff) {
    let errors = 0;
    let allPhones = formWrap.querySelectorAll('.validatePhone');
    let allSSN = formWrap.querySelectorAll('.validateSSN');
    let allNamCharacters = formWrap.querySelectorAll('.validateName');
    let allEmails = formWrap.querySelectorAll('.validateEmail');
    let allUrls = formWrap.querySelectorAll('.validateURL');
    let allTestScores = formWrap.querySelectorAll('.validateACT, .validateSATComposite, .validateSATSubject');
    let allRequiredInputs = formWrap.querySelectorAll(".slds-is-required .slds-input, .slds-is-required .slds-textarea, .slds-is-required .slds-select, .slds-is-required .slds-radio_button-group .slds-radio_button-value");


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

    allRequiredInputs.forEach(item => {
        if (item) {
            if (!item.value) {
                activateErrorState(item, 'change')
            }
        }
    });

    formWrap.querySelectorAll(".selectableOL").forEach(sel => {
        let selWrap = sel.closest('.slds-form-element');
        let hiddenData = formWrap.querySelector('[id$="' + sel.dataset.hiddendataid + '"]').id;
        if (selWrap.classList.contains("slds-is-required")) {
            if (!formWrap.getElementById(hiddenData).value) {
                activateErrorState(sel, 'click')
            }
        }
    });

    formWrap.querySelectorAll('.docUploadInput').forEach(docUpload => {
            if (String(docUpload.placeholder) == 'true' && !Boolean(docUpload.value)) {
                doc.getElementById('error-108' + String(docUpload.name)).innerHTML = 'Upload required.';
                activateErrorState(docUpload, 'change');
            } else {
                doc.getElementById('error-108' + String(docUpload.name)).innerHTML = '';
            }
        });

    //ACT/SAT Test score validation
    allTestScores.forEach(testScore => {
        let minScore = parseInt(testScore.getAttribute('min'));
        let maxScore = parseInt(testScore.getAttribute('max'));
        testScore.addEventListener('keyup', function () {
            let maxLength = testScore.getAttribute('max').length;
            if (testScore.value.length > maxLength) {
                testScore.value = testScore.value.substring(0, maxLength);
            }
        })

        //if (testScore.value) {
        if (testScore.value > maxScore || testScore.value < minScore) {
            activateErrorState(testScore, 'change');
        }
        // }
    })

    //Format and validate phone numbers
    allPhones.forEach(phone => {

        //format directly after input
        //Don't allow anything but phone number characters on key-up
        phone.addEventListener('keyup', function () {
            phone.value = phone.value.replace(re_phoneIllegals, '');
        })

        phone.addEventListener('change', function () {
            let cleaned = String(phone.value).replace(/\D/g, "");
            let match = cleaned.match(re_phoneFormat);
            if (match) {
                let intlCode = match[1] ? "+1 " : "";
                phone.value = [intlCode, "(", match[2], ") ", match[3], "-", match[4]].join("");
            }
        });

        //Check if the final phone number matches correctly before submit
        if (phone.value) {
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

        if (nameInput.value) {
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

        if (ssn.value) {
            if (!ssn.value.match(re_snn)) {
                activateErrorState(ssn, 'change');
            }
        }
    });

    //Email Validation
    allEmails.forEach(email => {
        if (email.value) {
            if (!email.value.match(re_email)) {
                activateErrorState(email, 'change');
            }
        }
    });

    //URL validation
    allUrls.forEach(inputUrl => {
        inputUrl.value = inputUrl.value.replace(' ', '').trim();
        if (inputUrl.value) {
            if (!inputUrl.value.startsWith('http')) {
                inputUrl.value = 'https://' + inputUrl.value;
            }
            if (inputUrl.value) {
                if (!inputUrl.value.match(re_url)) {
                    activateErrorState(inputUrl, 'change');
                }
            }
        }
    })

    function activateErrorState(errorInput, eventType) {
        if (!errorsOff) {
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
    }

    return errors;
}

function validateFileType(obj) {
    if (Boolean(obj.title)) {
        console.log(obj);
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
            console.log(document.getElementById('error-108' + String(obj.name)));
            return false;
        } else {
            document.getElementById('error-108' + String(obj.name)).innerHTML = '';
        }
    }
    return true;
}