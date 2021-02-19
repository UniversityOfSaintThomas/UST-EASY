// $(document).keypress(function (event) {
//     if (event.which == '13') {
//         event.preventDefault();
//     }
// });

let ready = (callback) => {
    if (document.readyState != "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

let placeholders = {};
let maxLengths = {};

ready(() => {

    document.querySelectorAll(".aria-describedby-tooltip").forEach(item => {
        console.log(JSON.stringify(item.classList));
        item.addEventListener("mouseover", event => {
            console.log('mouseover');
        });
        item.addEventListener("mouseout", event => {
            console.log('mouseout');
        });
    });

    for (let inputId in placeholders) {
        if (inputId) {
            document.querySelectorAll('.' + inputId).forEach(field => {
                field.setAttribute('aria-describedby', "error-message-" + inputId);
                if (placeholders[inputId]) {
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

    document.querySelectorAll(".slds-select_container span select").forEach(field => {
        field.classList.add('slds-select');
        alert(field.classList);
    });

});

const observer = new MutationObserver(mutation => {
    document.querySelectorAll(".slds-select_container span select").forEach(field => {
        field.classList.add('slds-select');
    });
    console.log('DOM mutation detected');
});