let ready = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

ready(() => {
    document.querySelectorAll("#e1upload, #e1input, #e2upload, #e2input").forEach(function (el) {
        el.style.display = "none";
    });

    document.querySelectorAll(".essayInputWrapper").forEach(function (essayWrap) {
        essayWrap.querySelectorAll(".essayTypeSelection").forEach(function(essayType) {
            essayType.addEventListener("change", function () {
                let selectedType = this.value;
                if(selectedType === 'upload') {
                    essayWrap.querySelector(".essayInput").style.display = "none";
                    essayWrap.querySelector(".essayUpload").style.display = "block";
                } else if (selectedType === 'input') {
                    essayWrap.querySelector(".essayUpload").style.display = "none";
                    essayWrap.querySelector(".essayInput").style.display = "block";
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
    let alertMessage = "", testScore = 0, gpa = 0.00;
    removePreviousErrors();
    let declaredTest = document.querySelector("[id$=Declared_Test]");
    if (declaredTest) {
        testScore = declaredTest.value;
        if (testScore < 10) {
            alertMessage += "<li>Please enter a valid ACT/SAT score (example 27).</li>";
            declaredTest.classList.add("validationError");
        }
    }

    let declaredGPA = document.querySelector("[id$=Declared_GPA]");
    if (declaredGPA) {
        gpa = declaredGPA.value;
        if (gpa < 1.0) {
            alertMessage += "<li>Please enter a valid gpa (example 3.5).</li>";
            declaredGPA.classList.add("validationError");
        }
    }

    let criteriaChecked = document.querySelector("[id$=confirmCriteria]");
    if (criteriaChecked) {
        if (!criteriaChecked.checked) {
            alertMessage += "<li>You must acknowledge you understand and meet the criteria outlined on this page to proceed. Signify this by checking the confirmation checkbox.</li>";
            criteriaChecked.closest(".slds-form-element").querySelector("label").classList.add("validationError");
        }
    }

    if (alertMessage != "") {
        let errorMessages = document.querySelector(".errorMessages");
        let errorList = document.createElement("div");
        errorMessages.style.display = "block";
        errorList.id = "validationErrorList";
        errorList.innerHTML = "<ul>" + alertMessage + "</ul>";
        errorMessages.appendChild(errorList);
        document.querySelector('.errorMessages').scrollIntoView({behavior: 'smooth'});
        return false;
    }
    return true;
}

function checkForfile(fileSelctor) {
    removePreviousErrors();
    let file = document.querySelector("[id$=" + fileSelctor + "]");
    if (file) {
        if (file.value) {
            return true;
        }
    } else {
        file.classList.add("validationError");
        let errorMessages = document.querySelector(".errorMessages");
        if (errorMessages) {
            let errorList = document.createElement("div");
            errorList.id = "validationErrorList";
            errorList.innerHTML = "<ul><li>Select a file to upload.</li></ul>";
            errorMessages.appendChild(errorList);
            document.querySelector('.errorMessages').scrollIntoView({behavior: 'smooth'});
        }
    }
    return false;
}

function validateRecommender(recId) {
    let recInfo = document.querySelector("[id$=" + recId + "]").closest(".recommender");
    let recEmail = recInfo.find(".recEmail");
    let recError = recInfo.find(".errorMessages2");
    let recName = recInfo.find(".recName");
    recEmail.classList.remove("validationError");
    recName.classList.remove("validationError");
    recError.hide();
    if (!isValidEmailAddress(recEmail.value) || !recName.value) {
        recError.innerHTML("Please enter a name and a valid email.").show();
        recEmail.classList.add("validationError");
        recName.classList.add("validationError");
        return false;
    }
    return true;
}

function isValidEmailAddress(emailAddress) {
    const pattern = /^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
    return pattern.test(emailAddress);
}

function validateApplication() {
    let alertMessage = "", essaySelector = "";
    removePreviousErrors();

    let hasError = false;
    document.querySelectorAll('.ScholarshipAppForm input, .ScholarshipAppForm textarea:not(.essayInput)').forEach(function (input) {
        if (!input.value) {
            hasError = true;
            input.classList.add("validationError");
        }
    });
    if (hasError) {
        alertMessage += "<li>All questions require an answer. Please fill in your answers for the highlighted text areas.</li>";
    }

    document.querySelectorAll(".essay1input, .essay2input").forEach(function (essay) {
        alert(this.value);

    });

    //Check Essay for input
    /*    if ($(".essay1input").length > 0) {
            if ($(".essay1Uploaded").length === 0) {
                let essay1Id = $(".essay1").attr("id");
                console.log(essay1Id);
                if (!CKEDITOR.instances[$(".essay1").attr("id")].getData()) {
                    alertMessage += "<li>Please input an answer to essay one.</li>";
                    $(".essay1input").addClass("validationErrorRich");
                }
            }
        }

        if ($(".essay2input").length > 0) {
            if ($(".essay2Uploaded").length === 0) {
                if (!CKEDITOR.instances[$(".essay2").attr("id")].getData()) {
                    alertMessage += "<li>Please input an answer to essay two.</li>";
                    $(".essay2input").addClass("validationErrorRich");
                }
            }
        }*/


    if (alertMessage != "") {
        let errorMessages = document.querySelector(".errorMessages");
        errorMessages.style.display = "block";
        errorMessages.innerHTML = errorMessages.innerHTML + "<div id='validationErrorList'><ul>" + alertMessage + "</ul></div>";
        document.querySelector('.errorMessages').scrollIntoView({behavior: 'smooth'});
        return false;
    }
    return true;
}

function displayError(error) {
    let errorMessages = document.querySelector(".errorMessages");
    let errorList = document.createElement("div");
    errorMessages.style.display = "block";
    errorList.id = "validationErrorList";
    errorList.innerHTML = "<ul>" + alertMessage + "</ul>";
    errorMessages.appendChild(errorList);
    document.querySelector('.errorMessages').scrollIntoView({behavior: 'smooth'});
    return false;
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
