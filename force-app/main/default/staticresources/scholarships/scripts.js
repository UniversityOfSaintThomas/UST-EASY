let ready = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

ready(() => {

    document.querySelectorAll(".essayInputWrapper").forEach(function (essayWrap) {
        let essayNo = essayWrap.dataset.essayno;
        essayWrap.querySelectorAll(".essayType").forEach(function (essayType) {
            let uploaded = essayInfo['essayUploaded' + essayNo];
            let textInput = essayInfo['essayInput' + essayNo];
            essayWrap.querySelector(".essayInputWrap").style.display = "none";
            essayWrap.querySelector(".essayUpload").style.display = "none"
            if (uploaded) {
                essayType.value = "upload";
                essayWrap.querySelector(".essayUpload").style.display = "block";
            } else if (textInput) {
                essayType.value = "input";
                essayWrap.querySelector(".essayInputWrap").style.display = "block";
            }
            essayType.addEventListener("change", function () {
                let selectedType = this.value;
                //remove all slds-has-error classes
                essayWrap.querySelectorAll(".slds-has-error").forEach(function (errorWrap) {
                    errorWrap.classList.remove("slds-has-error");
                });
                if (selectedType === 'upload') {
                    essayInfo['essayUploaded' + essayNo] = true;
                    essayWrap.querySelector(".essayInputWrap").style.display = "none";
                    essayWrap.querySelector(".essayUpload").style.display = "block";
                } else if (selectedType === 'input') {
                    essayInfo['essayInput' + essayNo] = true;
                    essayWrap.querySelector(".essayUpload").style.display = "none";
                    essayWrap.querySelector(".essayInputWrap").style.display = "block";
                }
            });
        });
    });

    document.querySelectorAll("input, textarea").forEach(function (input) {
        if (input.maxLength > 0) {
            let textCounter = input.parentNode.querySelector(".text-count-wrapper");
            if (textCounter === null) {
                textCounter = document.createElement("div");
                textCounter.classList.add("text-count-wrapper");
                input.parentNode.appendChild(textCounter);
                textCounter.textContent = countWords(input);
            }
            input.addEventListener("keyup", function () {
                textCounter.textContent = countWords(input);
            });
        }
    });

    function countWords(input) {
        let max = input.maxLength;
        let current = input.value.length;
        // Line breaks count as 2 characters so count them separately and add the amount to the total
        let linebreaks = (input.value.match(/\n/g) || []).length;
        current = current + linebreaks;
        let remaining = max - current;
        let countString = '';
        if (remaining <= 0) {
            input.value = input.value.substring(0, max - linebreaks);
        }
        let wordcount = input.value.split(' ').length - 1;
        if (wordcount === 1 && input.value.length > 0) {
            countString = wordcount + ' word.'
        } else if (wordcount > 1) {
            countString = wordcount + ' words.'
        }
        if (remaining < 0) {
            remaining = 0;
        }
        countString += ' Characters remaining: ' + remaining;
        return countString;
    }

    document.querySelectorAll(".validateRecommender").forEach(function (rec) {
        rec.addEventListener("click", function (evt) {
            evt.preventDefault();
            let recWrap = rec.closest(".recommender");
            let errorFound = false;
            recWrap.querySelectorAll(".recName, .recEmail").forEach(function (input) {
                if (input.classList.contains(".recEmail")) {
                    if (!isValidEmailAddress(input.value)) {
                        errorFound = true;
                        addHasError(input);
                    }
                }
                if (!input.value) {
                    errorFound = true;
                    addHasError(input);
                }
            });
            console.log(!errorFound);
            return !errorFound;
        });
    });
});

function addHasError(elem) {
    elem.closest(".slds-form-element").classList.add("slds-has-error");
    elem.addEventListener("change", function () {
        elem.closest(".slds-form-element").classList.remove("slds-has-error");
    });
}

function isValidEmailAddress(emailAddress) {
    const pattern = /^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
    return pattern.test(emailAddress);
}

function validateCriteria() {

    let declaredTest = document.querySelector("[id$=Declared_Test]");
    if (declaredTest) {
        if (declaredTest.value < 10) {
            addHasError(declaredTest);
        }
    }

    let declaredGPA = document.querySelector("[id$=Declared_GPA]");
    if (declaredGPA) {
        if (declaredGPA.value < 1.0) {
            addHasError(declaredGPA);
        }
    }

    let criteriaChecked = document.querySelector("[id$=confirmCriteria]");
    if (criteriaChecked) {
        if (!criteriaChecked.checked) {
            addHasError(criteriaChecked);
        }
    }

    return document.querySelectorAll(".slds-has-error").length <= 0;

}

function checkForFile(fileSelector) {
    let file = document.querySelector("[id$=" + fileSelector + "]");
    if (file) {
        //get file extension
        let fileExt = file.value.split('.').pop();
        console.log(fileExt);
        if (!file.value || (fileExt !== "pdf" && fileExt !== "doc" && fileExt !== "docx" && fileExt !== "rtf" && fileExt !== "txt")) {
            file.closest(".slds-form-element").classList.add("slds-has-error");
            file.addEventListener("change", function () {
                file.closest(".slds-form-element").classList.remove("slds-has-error");
            });
            return false
        }
    }
    return true;
}

function validateApplication() {

    document.querySelectorAll(".ScholarshipAppForm input[type=text], .ScholarshipAppForm textarea").forEach(function (formInput) {
        if (formInput) {
            if (!formInput.value) {
                let inputWrap = formInput.closest(".slds-form-element");
                if (inputWrap) {
                    if (inputWrap.classList.contains("slds-is-required")) {
                        inputWrap.classList.add("slds-has-error");
                        formInput.addEventListener("change", function () {
                            inputWrap.classList.remove("slds-has-error");
                        });
                    }
                }
            }
        }
    });

    document.querySelectorAll(".essayInputWrapper").forEach(function (essayWrap) {
        let essayType = essayWrap.querySelector(".essayType");
        let errorElement;
        let errorFound = false;
        if (essayType) {
            if (essayType.value === 'input') {
                let essayInput = essayWrap.querySelector(".essayInput");
                if (essayInput) {
                    let essayInputId = essayInput.id;
                    if (CKEDITOR.instances[essayInputId].getData() === "") {
                        errorElement = essayInput;
                        errorFound = true;
                    }
                }
            } else if (essayType.value === 'upload') {
                let essayFile = essayWrap.querySelector(".essayFile");
                if (essayFile) {
                    if (!essayFile.value) {
                        errorElement = essayFile;
                        errorFound = true;
                    }
                }
            } else {
                errorElement = essayType;
                errorFound = true;
            }
            if (errorFound) {
                addHasError(errorElement);
            }
        }
    });

    return document.querySelectorAll(".slds-has-error").length <= 0;

}