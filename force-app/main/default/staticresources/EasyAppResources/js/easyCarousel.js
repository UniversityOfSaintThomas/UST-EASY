/* Carousel Script */
let carouselReady = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

let mainBody, carouselItems, carouselTotalItems, saveAndAdvance, saveAndGoBack, carouselPrev, carouselNext;
carouselReady(() => {
    mainBody = document.getElementById('mainBody');
    carouselItems = mainBody.getElementsByClassName("carousel__item");
    carouselTotalItems = carouselItems.length;
    saveAndAdvance = mainBody.querySelector('[id$="saveAndAdvance"]');
    saveAndGoBack = document.getElementById('saveAndGoBack');
    carouselNext = document.getElementById('carouselNextButton');
    carouselPrev = document.getElementById("carouselPreviousButton");
    carouselNext.addEventListener('click', function () {
        moveNext();
    });
    carouselPrev.addEventListener('click', function () {
        movePrevious();
    });
    activateCarousel();
});


function activateCarousel(slideMoveTo) {
    if (carouselTotalItems) {
        // Set click events to navigation buttons
        if (slideMoveTo) {
            moveCarouselTo(slideMoveTo);
        } else if (!slideMoveTo) {
            slideMoveTo = getCurrentSlide();
            moveCarouselTo(slideMoveTo);
        }
    }
}


function movePrevious() {
    let currentSlide = parseInt(getCurrentSlide());
    let nextSlide = 0;
    if (currentSlide !== 0) {
        nextSlide = currentSlide - 1;
    }
    unsavedRecords(nextSlide);
}

function moveNext() {
    let currentSlide = parseInt(getCurrentSlide());
    let nextSlide = 0;
    if (currentSlide !== (carouselTotalItems - 1)) {
        nextSlide = currentSlide + 1;
    }
    unsavedRecords(nextSlide);
}

function getCurrentSlide() {
    let currentSlide = mainBody.querySelector('.carousel__item.active').dataset.slide;
    if (!currentSlide) {
        currentSlide = 0;
    }
    return currentSlide;
}

function unsavedRecords(nextSlide) {

    let closeOpenRecord = function () {
        mainBody.querySelectorAll('.cancel-records-button').forEach(cancelBtn => {
            cancelBtn.click();
        });
        moveCarouselTo(nextSlide);
    }

    if (document.querySelector('.carousel__item.active .add-record-button') !== null) {
        activateModal(
            'Unsaved records',
            '<p>It appears you have unsaved records. If this is intended click "Continue Anyway". Otherwise, hit "Cancel" and add or cancel your record.</p>',
            'Continue Anyway',
            closeOpenRecord
        );
        return false;
    } else {
        moveCarouselTo(nextSlide);
    }

}

function moveCarouselTo(slide) {

    console.log('slide: ' + slide);
    slide = parseInt(slide);
    let newPrevious = slide - 1;
    let newNext = slide + 1;

    if (carouselTotalItems > 1) {
        if (slide === 0) {
            carouselPrev.style.display = "none";
            if (previousRequirement) {
                saveAndGoBack.style.display = 'inline-flex';
            }
            newPrevious = (carouselTotalItems - 1);
        } else if (slide === 1) {
            saveAndGoBack.style.display = "none";
            newPrevious = 0;
        } else if (slide === (carouselTotalItems - 1)) {
            newPrevious = (slide - 1);
            newNext = 0;
        }

        for (let i = 0; i < carouselItems.length; i++) {
            carouselItems[i].classList.remove('prev');
            carouselItems[i].classList.remove('next');
            carouselItems[i].classList.remove('active');
        }
        if (carouselItems[newPrevious]) {
            carouselItems[newPrevious].classList.add("prev");
        }
        if (carouselItems[slide]) {
            carouselItems[slide].classList.add("active");
        }
        if (carouselItems[newNext]) {
            carouselItems[newNext].classList.add("next");
        }

        if (slide + 1 === carouselTotalItems || carouselTotalItems === 1) {
            saveAndAdvance.style.display = "inline-flex";
            carouselNext.style.display = "none";
        } else {
            saveAndAdvance.style.display = "none";
            carouselNext.style.display = "inline-flex";
        }

        if (slide > 0) {
            carouselPrev.style.display = "inline-flex";
        } else {
            carouselPrev.style.display = "none";
        }
    }
}


function isCarousel() {
    let items = document.getElementsByClassName("carousel__item");
    return items.length > 0;
}