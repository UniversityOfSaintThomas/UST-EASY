/* ============================================================
   easyCarousel.js — multi-step carousel: enable/disable, slide navigation, scroll-to-top, and pre-advance record checks.
   ============================================================ */

function navigateRequirementGroup(redirectTo) {
    appShowLoadingSpinner();

    if (redirectTo === 'forwards' && !checkForm()) {
        appHideLoadingSpinner();
        hideFormSpinner();
        return;
    }

    function save() {
        if (redirectTo === 'forwards') {
            performDocUploadSave(nextRequirement);
        } else if (redirectTo === 'back') {
            performDocUploadSave(previousRequirement);
        } else {
            performDocUploadSave(redirectTo);
        }
    }

    recordCheckAndAdvance(save);
}

// ── Carousel state (module-level so init and navigation stay in sync) ──────────
let carouselOn = false;
let carouselBound = false;   // nav listeners attached exactly once
let carouselMoving = false;  // interaction lock during a transition
let currentSlide = 0;

// Keep in sync with the .carousel__item opacity transition in styles.css.
const SLIDE_TRANSITION_MS = 400;

/**
 * Live NodeList of carousel panels. Re-queried on each use (rather than cached)
 * so it survives Visualforce partial re-renders of the question groups.
 */
function getCarouselItems() {
    return document.querySelectorAll(".carousel-wrapper .carousel__item");
}

function disableCarousel() {
    carouselOn = false;

    let killerButton = document.getElementById('carousel-killer');
    if (killerButton) {
        killerButton.innerText = "Restore Form";
        killerButton.removeEventListener('click', disableCarousel);
        killerButton.addEventListener('click', enableCarousel);
    }

    // Show every panel at once (single-page form).
    getCarouselItems().forEach(item => item.classList.add('carousel__disable'));

    document.querySelectorAll('.questionGroupCount, .questionGroupWarning')
        .forEach(el => { el.style.display = "none"; });
    document.querySelectorAll('.carousel__button--next, .carousel__button--prev')
        .forEach(btn => { btn.style.display = "none"; });

    let saveAndAdvance = document.querySelector('[id$="saveAndAdvance"]');
    if (saveAndAdvance) {
        saveAndAdvance.style.display = "inline-flex";
    }

    if (typeof previousRequirement !== 'undefined' && previousRequirement) {
        let saveAndGoBack = document.getElementById('saveAndGoBack');
        if (saveAndGoBack) {
            saveAndGoBack.style.display = "inline-flex";
        }
    }
}

function enableCarousel() {
    let killerButton = document.getElementById('carousel-killer');
    if (killerButton) {
        killerButton.innerText = "Single-Page Form";
        killerButton.removeEventListener('click', enableCarousel);
        killerButton.addEventListener('click', disableCarousel);
    }

    getCarouselItems().forEach(item => item.classList.remove('carousel__disable'));

    document.querySelectorAll('.questionGroupCount, .questionGroupWarning')
        .forEach(el => { el.style.display = ""; });

    currentSlide = 0;
    activateCarousel(0);
}

/**
 * Smoothly scrolls the carousel area back to the top so each new slide starts
 * at the top of the form instead of wherever the previous slide was scrolled to.
 */
function scrollCarouselToTop() {
    let wrapper = document.querySelector('.carousel-wrapper');
    if (wrapper) {
        wrapper.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

/**
 * Entry point (called from page bootstrap, checkForm, and enableCarousel).
 * Idempotent: binds nav listeners once, then renders the requested slide.
 * Pass a slide index to jump to it; omit to (re)render the current slide.
 */
function activateCarousel(slideMoveTo) {
    const items = getCarouselItems();
    const totalItems = items.length;
    const killerButton = document.getElementById('carousel-killer');

    if (totalItems === 0) {
        return;
    }

    if (totalItems === 1) {
        // Single panel: no carousel navigation, just present Save & Continue.
        if (killerButton) {
            killerButton.style.display = 'none';
        }
        const next = document.getElementsByClassName('carousel__button--next')[0];
        const prev = document.getElementsByClassName('carousel__button--prev')[0];
        const saveAndAdvance = document.querySelector('[id$="saveAndAdvance"]');
        if (next) next.style.display = 'none';
        if (prev) prev.style.display = 'none';
        if (saveAndAdvance) saveAndAdvance.style.display = 'inline-flex';
        carouselOn = true;
        return;
    }

    bindCarouselControls();
    carouselMoving = false;
    carouselOn = true;

    const target = parseInt(slideMoveTo, 10);
    goToSlide(Number.isNaN(target) ? currentSlide : target);
}

/** Attaches the nav/killer click handlers exactly once. */
function bindCarouselControls() {
    if (carouselBound) {
        return;
    }
    const next = document.getElementsByClassName('carousel__button--next')[0];
    const prev = document.getElementsByClassName('carousel__button--prev')[0];
    const killerButton = document.getElementById('carousel-killer');
    if (next) next.addEventListener('click', carouselNext);
    if (prev) prev.addEventListener('click', carouselPrev);
    if (killerButton) killerButton.addEventListener('click', disableCarousel);
    carouselBound = true;
}

/**
 * Renders the panel at `index` as the active one and updates nav-button
 * visibility. Pure state -> DOM; the crossfade is driven entirely by the
 * `active` class in styles.css. Does not move focus or scroll — see
 * carouselNext/carouselPrev for the user-initiated side effects.
 */
function goToSlide(index) {
    const items = getCarouselItems();
    const totalItems = items.length;
    if (totalItems <= 1) {
        return;
    }

    carouselMoving = true;
    setTimeout(function () { carouselMoving = false; }, SLIDE_TRANSITION_MS);

    currentSlide = index;
    const isFirst = index === 0;
    const isLast = index === totalItems - 1;

    const next = document.getElementsByClassName('carousel__button--next')[0];
    const prev = document.getElementsByClassName('carousel__button--prev')[0];
    const saveAndAdvance = document.querySelector('[id$="saveAndAdvance"]');
    const saveAndGoBack = document.getElementById('saveAndGoBack');

    if (prev) prev.style.display = isFirst ? 'none' : 'inline-flex';
    if (next) next.style.display = isLast ? 'none' : 'inline-flex';
    if (saveAndAdvance) saveAndAdvance.style.display = isLast ? 'inline-flex' : 'none';
    if (saveAndGoBack && typeof previousRequirement !== 'undefined' && previousRequirement) {
        saveAndGoBack.style.display = isFirst ? 'inline-flex' : 'none';
    }

    for (let i = 0; i < items.length; i++) {
        items[i].classList.toggle('active', i === index);
    }
}

function carouselNext() {
    if (carouselMoving) {
        return;
    }
    const totalItems = getCarouselItems().length;
    const target = currentSlide === totalItems - 1 ? 0 : currentSlide + 1;
    recordCheckAndAdvance(function () { advanceToSlide(target); });
}

function carouselPrev() {
    if (carouselMoving) {
        return;
    }
    const totalItems = getCarouselItems().length;
    const target = currentSlide === 0 ? totalItems - 1 : currentSlide - 1;
    recordCheckAndAdvance(function () { advanceToSlide(target); });
}

/** User-initiated slide change: render, move focus into the panel, scroll to top. */
function advanceToSlide(index) {
    goToSlide(index);

    const items = getCarouselItems();
    if (items[index]) {
        const fields = items[index].querySelectorAll("input:not([type='hidden']), .slds-card h1");
        if (fields.length > 0) {
            // preventScroll so focusing the field doesn't fight scrollCarouselToTop()
            fields[0].focus({ preventScroll: true });
        }
    }

    // Each new slide starts at the top of the form, not mid-scroll.
    scrollCarouselToTop();
}

function recordCheckAndAdvance(callback) {
    let activeCarouselItem = document.querySelector('.carousel__item.active');
    let activeItem = activeCarouselItem ? activeCarouselItem.querySelector('.related-records') : null;
    let validationPopup = false;

    if (activeItem) {
        let card = activeItem.closest('.slds-card');
        let maxRecords = card.dataset.maxrecords;
        let minRecords = card.dataset.minrecords;
        let recordCount = activeItem.querySelectorAll('.related-record').length;

        if (maxRecords && recordCount > maxRecords) {
            showValidationModal('Related Record Limit Reached',
                `You have reached the maximum of ${maxRecords} records.`, callback);
            validationPopup = true;
        }

        if (minRecords && recordCount < minRecords) {
            let plural = minRecords == 1 ? '' : 's';
            showValidationModal('Related Record Requirement',
                `You need at least ${minRecords} record${plural} to proceed.`, callback);
            validationPopup = true;
        }
    }

    // Check LWC-managed related-object groups (easyRelatedObjectForm components) in the active carousel item.
    if (!validationPopup && activeCarouselItem) {
        activeCarouselItem.querySelectorAll('.easy-ro-container[data-minrecords], .easy-ro-container[data-maxrecords]').forEach(function (container) {
            if (validationPopup) { return; }
            const recordCount = lwcRelatedRecordCounts[container.id] || 0;
            const maxRecords = parseInt(container.dataset.maxrecords, 10);
            const minRecords = parseInt(container.dataset.minrecords, 10);
            if (!isNaN(maxRecords) && recordCount > maxRecords) {
                showValidationModal('Related Record Limit Reached',
                    `You have reached the maximum of ${maxRecords} records.`, callback);
                validationPopup = true;
            }
            if (!isNaN(minRecords) && recordCount < minRecords) {
                const plural = minRecords === 1 ? '' : 's';
                showValidationModal('Related Record Limit Reached',
                    `You need at least ${minRecords} record${plural} to proceed.`, callback);
                validationPopup = true;
            }
        });
    }

    // Check LWC-managed document upload groups (easyDocumentUpload components) in the active carousel item.
    if (!validationPopup && activeCarouselItem) {
        activeCarouselItem.querySelectorAll('.easy-du-container[data-required="true"]').forEach(function (container) {
            if (validationPopup) { return; }
            const uploadState = lwcDocumentUploadStates[container.id];
            const hasDocument = uploadState && uploadState.hasDocument;
            if (!hasDocument) {
                showValidationModal('Document Required',
                    'A required document has not been uploaded. Please upload a document before proceeding.',
                    callback);
                validationPopup = true;
            }
        });
    }

    if (!validationPopup && document.querySelector('.save-record-button')) {
        showValidationModal('Unsaved Records',
            'You have unsaved records. Save or cancel them before proceeding.',
            () => {
                document.querySelectorAll('.cancel-records-button').forEach(btn => btn.click());
                callback();
            });
        validationPopup = true;
    }

    if (!validationPopup) {
        callback();
    } else {
        appHideLoadingSpinner(false);
    }
}

function isCarousel() {
    return getCarouselItems().length > 0 && carouselOn;
}
