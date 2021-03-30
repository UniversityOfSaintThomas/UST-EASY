// $(document).keypress(function (event) {
//     if (event.which == '13') {
//         event.preventDefault();
//     }
// });

let ready = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

let placeholders = {};
let maxLengths = {};

ready(() => {
    pageLoadReRendered();
    activateCarousel();
});

function pageLoadReRendered() {
    for (let inputId in placeholders) {
        if (inputId) {
            document.querySelectorAll('.' + inputId).forEach(field => {
                field.setAttribute('aria-describedby', "error-message-" + inputId);
                if (placeholders[inputId] && !field.classList.contains('field-TextEncrypted')) {
                    field.setAttribute('placeholder', placeholders[inputId])
                }
            });
        }
    }

    for (let inputId2 in maxLengths) {
        if (inputId2) {
            document.querySelectorAll('.' + inputId2).forEach(field => {
                if (maxLengths[inputId2]) {
                    field.setAttribute('maxlength', maxLengths[inputId2])
                }
            });
        }
    }

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

    activateAutoComplete();
    radioCheckBox();

}

function radioCheckBox() {
    document.querySelectorAll('.slds-radio_button-group').forEach(radioGroup => {
        let radioGroupValue = radioGroup.querySelector("[id$='radioField1']");
        radioGroup.querySelectorAll('.faux-radio-value').forEach(faux => {
            faux.checked = false;
            if (faux.value === radioGroupValue.value) {
                faux.checked = true;
            }
        });
        document.querySelectorAll('.slds-radio_button').forEach(radioButton => {
            radioButton.addEventListener('click', (e) => {
                radioGroupValue.value = radioButton.dataset.radiovalue;
                rerenderTheTable();
            })
        });
    });
}


function appShowLoadingSpinner() {
    document.getElementById("apploadingspinner").style.display = "block";
}

function appHideLoadingSpinner() {
    document.getElementById("apploadingspinner").style.display = "none";
}

function appShowConfimation() {
    document.getElementById("confirmation").style.display = "block";
}

// By default, replaceAll runs on ALL textarea fields.
// modified to run only on the class defined 'ckeditor'
//CKEDITOR.replaceAll = function(){for(var a=document.getElementsByClassName("ckeditor"),b=0;b<a.length;b++){var d=null,k=a[b];if(k.name||k.id){if("string"==typeof arguments[0]){if(!(new RegExp("(?:^|\\s)"+arguments[0]+"(?:$|\\s)")).test(k.className))continue}else if("function"==typeof arguments[0]&&(d={},!1===arguments[0](k,d)))continue;this.replace(k,d)}}};

// destroys and rebuilds the rich text fields after rerender
function afterRerenderRTF() {
    for (name in CKEDITOR.instances) {
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
        var docUploadObj = {};
        docUploads.forEach(function (docUpload) {
            docUploadObj[docUpload.itemId] = {"attData": docUpload};
        });
        saveWithDocs(JSON.stringify(docUploadObj), redirectTo);
        //console.log(redirectTo);
    }).catch(function () {
    });
}

function getAsText(readFile, respId) {
    return new Promise((resolve, reject) => {
        //var reader = new FileReader();
        let reader = new FileReader();
        reader.onload = (function (theFile) {
            var fileName = theFile.name;
            return function (e) {
                resolve({"fileName": fileName, "data": e.target.result, "itemId": respId});
            };
        })(readFile);
        reader.readAsDataURL(readFile);
    });
}

function formatPhone(phone) {
    let intr = false;
    let digits = 0;
    let inValue = phone.value;
    if (inValue.startsWith("+")) {
        intr = true;
    }
    digits = inValue.replace(/\D/g, '');
    if (intr) {
        if (digits.startsWith("0")) {
            digits = digits.substring(1);
        }
        phone.value = "+" + digits;
    } else {
        phone.value = digits.replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3");
    }
}

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
    let comboBox = originObject.closest('.slds-combobox');
    let fullWrapper = originObject.closest('.referenceLookup');
    let hiddenInput = fullWrapper.querySelector('.inputHidden');
    comboBox.classList.remove('slds-is-open');
    hiddenInput.value = resultId;
    originObject.value = selectedValue;
}

function lookupResultsFormatter(data, originObjId) {
    let outputList = '';
    let originObject = document.getElementById(originObjId);
    let listObjectId = originObjId.replace('combobox-', 'listbox-');
    let listObject = document.getElementById(listObjectId);
    let resultList = listObject.querySelector('.slds-listbox');
    let comboBox = originObject.closest('.slds-combobox');
    let fieldNames = originObject.dataset.objtypenamefield.replace(' ', '').split(',');
    //console.log(JSON.stringify(data));
    data.forEach(result => {
        let resultName = '';
        let subTitle = '';
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
        outputList += resultListTemplate(resultName, subTitle, originObject.dataset.listicon, originObjId, result.Id);
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
            let objectType = autoItem.dataset.objtype;
            let objectTypeFilter = autoItem.dataset.objtypefilter;
            let objectTypeNameField = autoItem.dataset.objtypenamefield;
            let searchTerm = autoItem.value;
            let originObjId = autoItem.id;
            if (objectType && objectTypeFilter && objectTypeNameField && searchTerm.length > 2) {
                lookupSearchJS(objectType, objectTypeFilter, objectTypeNameField, searchTerm, lookupResultsFormatter, originObjId);
            }
        })
    });
}

function activateCarousel() {

    // Variables to target our base class,  get carousel items, count how many carousel items there are, set the slide to 0 (which is the number that tells us the frame we're on), and set motion to true which disables interactivity.
    const itemClassName = "carousel__item";
    let items = document.getElementsByClassName(itemClassName),
        totalItems = items.length,
        slide = 0,
        moving = true;

    // To initialise the carousel we'll want to update the DOM with our own classes
    function setInitialClasses() {

        // Target the last, initial, and next items and give them the relevant class.
        // This assumes there are three or more items.
        items[totalItems - 1].classList.add("prev");
        items[0].classList.add("active");
        items[1].classList.add("next");

    }

    // Set click events to navigation buttons

    function setEventListeners() {
        let next = document.getElementsByClassName('carousel__button--next')[0],
            prev = document.getElementsByClassName('carousel__button--prev')[0];

        next.addEventListener('click', moveNext);
        prev.addEventListener('click', movePrev);
    }

    // Disable interaction by setting 'moving' to true for the same duration as our transition (0.5s = 500ms)
    function disableInteraction() {
        moving = true;
        setTimeout(function () {
            moving = false
        }, 500);
    }

    function moveCarouselTo(slide) {

        // Check if carousel is moving, if not, allow interaction
        if (!moving) {

            // temporarily disable interactivity
            disableInteraction();

            // Preemptively set variables for the current next and previous slide, as well as the potential next or previous slide.
            let newPrevious = slide - 1,
                newNext = slide + 1,
                oldPrevious = slide - 2,
                oldNext = slide + 2;

            //console.log('Total Items: ' + totalItems);
            // Test if carousel has more than three items
            //  if ((totalItems - 1) > 3) {

            // Checks if the new potential slide is out of bounds and sets slide numbers
            if (newPrevious <= 0) {
                oldPrevious = (totalItems - 1);
            } else if (newNext >= (totalItems - 1)) {
                oldNext = 0;
            }

            // Check if current slide is at the beginning or end and sets slide numbers
            if (slide === 0) {
                newPrevious = (totalItems - 1);
                oldPrevious = (totalItems - 2);
                oldNext = (slide + 1);
            } else if (slide === (totalItems - 1)) {
                newPrevious = (slide - 1);
                newNext = 0;
                oldNext = 1;
            }

            // Now we've worked out where we are and where we're going, by adding and removing classes, we'll be triggering the carousel's transitions.

            // Based on the current slide, reset to default classes.
            console.log('old previous: ' + oldPrevious + ', new previous: ' + newPrevious + ', active: ' + slide);

            items[oldPrevious].className = itemClassName;
            items[oldNext].className = itemClassName;

            // Add the new classes
            items[newPrevious].className = itemClassName + " prev";
            items[slide].className = itemClassName + " active";
            items[newNext].className = itemClassName + " next";
            //   }
        }
    }

    // Next navigation handler
    function moveNext() {
        // Check if moving
        if (!moving) {
            // If it's the last slide, reset to 0, else +1
            if (slide === (totalItems - 1)) {
                slide = 0;
            } else {
                slide++;
            }
            // Move carousel to updated slide
            moveCarouselTo(slide);
        }
    }

    // Previous navigation handler
    function movePrev() {
        // Check if moving
        if (!moving) {
            // If it's the first slide, set as the last slide, else -1
            if (slide === 0) {
                slide = (totalItems - 1);
            } else {
                slide--;
            }
            // Move carousel to updated slide
            moveCarouselTo(slide);
        }
    }

    // Initialise carousel
    function initCarousel() {
        setInitialClasses();
        setEventListeners();
        // Set moving to false now that the carousel is ready
        moving = false;
    }

    // make it rain
    initCarousel();
}