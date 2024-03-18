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
                textCounter.textContent = 'Characters remaining: ' + input.maxLength;
                input.parentNode.appendChild(textCounter);
            }
            input.addEventListener("keyup", function () {
                let counter = input.parentNode.querySelector(".text-count-wrapper");
                let max = input.maxLength;
                let current = input.value.length;
                counter.textContent = 'Characters remaining: ' + (max - current);
            });
        }
    });

});

function validateCriteria() {

    let declaredTest = document.querySelector("[id$=Declared_Test]");
    if (declaredTest) {
        let formWrap = declaredTest.closest(".slds-form-element");
        let hepText = formWrap.querySelector(".slds-form-element__help");
        if (declaredTest.value < 10) {
            formWrap.classList.add("slds-has-error");
        }
        declaredTest.addEventListener("change", function () {
            formWrap.classList.remove("slds-has-error");
        });
    }

    let declaredGPA = document.querySelector("[id$=Declared_GPA]");
    if (declaredGPA) {
        let formWrap = declaredGPA.closest(".slds-form-element");
        let hepText = formWrap.querySelector(".slds-form-element__help");
        if (declaredGPA.value < 1.0) {
            formWrap.classList.add("slds-has-error");
        }
        declaredGPA.addEventListener("change", function () {
            formWrap.classList.remove("slds-has-error");
        });
    }

    let criteriaChecked = document.querySelector("[id$=confirmCriteria]");
    if (criteriaChecked) {
        let formWrap = criteriaChecked.closest(".slds-form-element");
        let hepText = formWrap.querySelector(".slds-form-element__help");
        if (!criteriaChecked.checked) {
            formWrap.classList.add("slds-has-error");
        }
        criteriaChecked.addEventListener("change", function () {
            if (criteriaChecked.checked) {
                formWrap.classList.remove("slds-has-error");
            }
        });
    }

    if (document.querySelectorAll(".slds-has-error").length > 0) {
        return false
    }
    return true;
}

function checkForFile(fileSelector) {
    removePreviousErrors();
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

//
// function validateRecommender(recId) {
//     alert(recId);
//     let recInfo = document.getElementById(recId).closest(".recommender");
//     let recEmail = recInfo.find(".recEmail");
//     let recError = recInfo.find(".errorMessages2");
//     let recName = recInfo.find(".recName");
//     recEmail.classList.remove("validationError");
//     recName.classList.remove("validationError");
//     recError.hide();
//     if (!isValidEmailAddress(recEmail.value) || !recName.value) {
//         recError.innerHTML("Please enter a name and a valid email.").show();
//         recEmail.classList.add("validationError");
//         recName.classList.add("validationError");
//         return false;
//     }
//     return true;
// }

function isValidEmailAddress(emailAddress) {
    const pattern = /^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
    return pattern.test(emailAddress);
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
                errorElement.closest(".slds-form-element").classList.add("slds-has-error");
                errorElement.addEventListener("change", function () {
                    errorElement.closest(".slds-form-element").classList.remove("slds-has-error");
                });
            }
        }
    });


    if (document.querySelectorAll(".slds-has-error").length > 0) {
        return false
    }
    return true;

}


function removePreviousErrors() {
    document.querySelectorAll(".validationError").forEach(function (err) {
        err.classList.remove("validationError");
    });
    let errorList = document.getElementById("validationErrorList");
    if (errorList) {
        errorList.remove();
    }
}
