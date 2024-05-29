function checkAppSelection(element) {
    let appForm = element.closest('form');
    let appSelection = appForm.querySelector('.appSelectList');
    if (appSelection.value === '') {
        appSelection.closest('.slds-form-element').classList.add('slds-has-error');
        appSelection.addEventListener('change', function () {
            appSelection.closest('.slds-form-element').classList.remove('slds-has-error');
        });
        return false;
    }
    return true;
}