$(document).ready(function() {
    $("#e1upload, #e1input, #e2upload, #e2input").hide();

    //
    if (typeof(e1Text) !== "undefined") {
        if (e1Text) {$("#e1input").show(); $("#Essay1delivery").val("input");}
        if (e2Text) {$("#e2input").show(); $("#Essay2delivery").val("input");}
    }

    $("#Essay1delivery").change(function() {
        $("#e1upload, #e1input").hide();
        if($(this).val() === "upload") {
            $("#e1upload").show();
        } else if ($(this).val() === "input") {
            $("#e1input").show();
        }
    });

    $("#Essay2delivery").change(function() {
        $("#e2upload, #e2input").hide();
        if($(this).val() === "upload") {
            $("#e2upload").show();
        } else if ($(this).val() === "input") {
            $("#e2input").show();
        }
    });

    (function(window, location) {
        var sid = getParameterByName('sid');
        if (!historyPage) {
            historyPage =" /applicantportal/ScholarshipHome";
            if (sid) {
                historyPage += "?sid=" + sid;
            }
        }
        history.replaceState(null, document.title, location.pathname+"#!/stealingyourhistory");
        history.pushState(null, document.title, location.pathname);
        window.addEventListener("popstate", function() {
            if(location.hash === "#!/stealingyourhistory") {
                history.replaceState(null, document.title, location.pathname);
                setTimeout(function(){
                    location.replace(historyPage);
                },0);
            }
        }, false);
    }(window, location));

    $('.question1, .question2, .question3, .question4').textcounter({
	type                     : "character",   
	max                      : 7000,
	countContainerClass      : "text-count-wrapper",  
	maximumErrorText         : "Maximum exceeded",
	displayErrorText         : true,
	stopInputAtMaximum       : true,
	countSpaces              : true, 
	countDown                : true, 
	countDownText            : "Characters remaining: %d", 
	countExtendedCharacters  : true
});
});

function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function validateCriteria() {
    var alertMessage = "", criteriaChecked = false, testScore=0, gpa=0.00;
    $(".validationError").removeClass("validationError");
    $("#validationErrorList").remove();
    criteriaChecked = $("[id$=confirmCriteria]").is(":checked");
    if ($("[id$=selfReportGA]").length > 0) {
        testScore = $("[id$=Declared_Test]").val();
        gpa = $("[id$=Declared_GPA]").val();
        if (gpa < 1.0) {
            alertMessage+="<li>Please enter a valid gpa (example 3.5).</li>";
            $("[id$=Declared_GPA]").addClass("validationError");
        }
        if (testScore < 10) {
            alertMessage+="<li>Please enter a valid ACT/SAT score (example 27).</li>";
            $("[id$=Declared_Test]").addClass("validationError");
        }
    }
    if(!criteriaChecked) {
        alertMessage+="<li>You must acknowledge you understand and meet the criteria outlined on this page to proceed. Signify this by checking the confirmation checkbox.</li>";
        $("[id$=confirmCriteria]").closest(".column").find("label").addClass("validationError");
    }
    if (alertMessage != "") {
        $(".errorMessages").append("<div id='validationErrorList'><ul>" + alertMessage + "</ul></div>");
        $('html,body').animate({ scrollTop: $(".errorMessages").first().offset().top},  'slow');


        return false;
    }
    return true;
}

function checkForfile(fileSelctor) {
    $(".validationError").removeClass("validationError");
    $("#validationErrorList").remove();
    if($("[id$=" + fileSelctor+"]").val()) {
        return true;
    } else {
        $("[id$=" + fileSelctor+"]").addClass("validationError");
        $(".errorMessages").append("<div id='validationErrorList'><ul><li>Select a file to upload.</li></ul></div>");
        $('html,body').animate({ scrollTop: $(".errorMessages").first().offset().top},  'slow');
    }
    return false;
}

function validateRecommender(recId) {
    let recInfo = $("[id$=" + recId + "]").closest(".recommender");
    let recEmail = recInfo.find(".recEmail");
    let recError = recInfo.find(".errorMessages2");
    let recName = recInfo.find(".recName");
    recEmail.removeClass("validationError");
    recName.removeClass("validationError");
    recError.hide();
    if(!isValidEmailAddress(recEmail.val()) || !recName.val()) {
        recError.html("Please enter a name and a valid email.").show();
        recEmail.addClass("validationError");
        recName.addClass("validationError");
        return false;
    }
    return true;
}

function isValidEmailAddress(emailAddress) {
    const pattern = /^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
    return pattern.test(emailAddress);
}

function validateApplication() {
    var alertMessage = "", essaySelector = "";
    $(".validationError").removeClass("validationError");
    $("#validationErrorList").remove();
    $.each($(".ScholarshipAppForm :text, .ScholarshipAppForm textarea:not(.essayInput)"), function() {
        if (!$(this).val()) {
            alertMessage="<li>All questions require an answer. Please fill in your answers for the highlighted text areas.</li>"
            $(this).addClass("validationError");
        }
    });

    //Check Essay for input
    if($(".essay1input").length > 0) {
         if ($(".essay1Uploaded").length === 0) {
            if(!CKEDITOR.instances[$(".essay1").attr("id")].getData()) {
                alertMessage+="<li>Please input an answer to essay one.</li>";
                $(".essay1input").addClass("validationErrorRich");
            }
        }
    }

    if($(".essay2input").length > 0) {
         if ($(".essay2Uploaded").length === 0) {
            if(!CKEDITOR.instances[$(".essay2").attr("id")].getData()) {
                alertMessage+="<li>Please input an answer to essay two.</li>";
                $(".essay2input").addClass("validationErrorRich");
            }
        }
    }


    if (alertMessage != "") {
        $(".errorMessages").append("<div id='validationErrorList'><ul>" + alertMessage + "</ul></div>");
        $('html,body').animate({ scrollTop: $(".errorMessages").first().offset().top},  'slow');
        return false;
    }
    return true;
    
}

/*!
* jQuery Text Counter Plugin v0.7.0
* https://github.com/ractoon/jQuery-Text-Counter
*
* Copyright 2014 ractoon
* Released under the MIT license
*/
!function(t){t.textcounter=function(n,o){var e=this;e.$el=t(n),e.el=n,e.$el.data("textcounter",e),e.init=function(){e.options=t.extend({},t.textcounter.defaultOptions,o);var n=e.options.countDown?e.options.countDownText:e.options.counterText,r=e.options.countDown?e.options.max:0,s=t("<div/>").addClass(e.options.textCountMessageClass).html(n.replace("%d",'<span class="'+e.options.textCountClass+'">'+r+"</span>")),i=t("<div/>").addClass(e.options.countOverflowContainerClass);e.hideMessage(i),e.$container=t("<"+e.options.countContainerElement+"/>").addClass(e.options.countContainerClass).append(s).append(i),e.$text_counter=e.$container.find("span"),e.$el.after(e.$container),e.$el.bind("keyup.textcounter click.textcounter blur.textcounter focus.textcounter change.textcounter paste.textcounter",e.checkLimits).trigger("click.textcounter"),e.options.init(e.el)},e.checkLimits=function(n){var o=e.$el,r=(e.$container,o.val()),s=0,i=0,a=void 0!==n.originalEvent;if(t.isEmptyObject(r)||(s=e.textCount(r)),"auto"==e.options.max){var u=e.$el.attr("maxlength");void 0!==u&&!1!==u?e.options.max=u:e.$container.text("error: [maxlength] attribute not set")}if(i=e.options.countDown?e.options.max-s:s,e.setCount(i),e.options.min>0&&a&&(s<e.options.min?(e.setErrors("min"),e.options.minunder(e.el)):s>=e.options.min&&(e.options.mincount(e.el),e.clearErrors("min"))),-1!==e.options.max)if(s===e.options.max&&0!==e.options.max)e.options.maxcount(e.el),e.clearErrors("max");else if(s>e.options.max&&0!==e.options.max)if(e.options.stopInputAtMaximum){var c="";if("word"==e.options.type)for(var l=r.split(/[^\S\n]/g),p=0;p<l.length&&!(p>=e.options.max);)void 0!==l[p]&&(c+=l[p]+" ",p++);else{var x=e.options.twoCharCarriageReturn?e.options.max-e.twoCharCarriageReturnCount(r):e.options.max;if(e.options.countSpaces)c=r.substring(0,x);else for(var m=r.split(""),C=m.length,d=0,p=0;d<x&&p<C;)" "!==m[p]&&d++,c+=m[p++]}o.val(c.trim()),s=e.textCount(o.val()),i=e.options.countDown?e.options.max-s:s,e.setCount(i)}else e.setErrors("max");else e.options.maxunder(e.el),e.clearErrors("max")},e.textCount=function(t){return"word"==e.options.type?e.wordCount(t):e.characterCount(t)},e.wordCount=function(t){return t.trim().replace(/\s+/gi," ").split(" ").length},e.characterCount=function(t){var n=0,o=0;if(e.options.twoCharCarriageReturn&&(o=e.twoCharCarriageReturnCount(t)),n=e.options.countSpaces?t.replace(/[^\S\n|\r|\r\n]/g," ").length:t.replace(/\s/g,"").length,e.options.countExtendedCharacters){var r=t.match(/[^\x00-\xff]/gi);n=null==r?t.length:t.length+r.length}return e.options.twoCharCarriageReturn&&(n+=o),n},e.twoCharCarriageReturnCount=function(t){var n=t.match(/(\r\n|\n|\r)/g),o=0;return null!==n&&(o=n.length),o},e.setCount=function(t){e.$text_counter.text(t)},e.setErrors=function(t){var n=e.$el,o=e.$container,r="";switch(n.addClass(e.options.inputErrorClass),o.addClass(e.options.counterErrorClass),t){case"min":r=e.options.minimumErrorText;break;case"max":r=e.options.maximumErrorText,e.options.countOverflow&&e.setOverflowMessage()}e.options.displayErrorText&&(o.children(".error-text-"+t).length||o.append("<"+e.options.errorTextElement+' class="error-text error-text-'+t+'">'+r+"</"+e.options.errorTextElement+">"))},e.setOverflowMessage=function(){e.hideMessage(e.$container.find("."+e.options.textCountMessageClass)),e.removeOverflowMessage();var t=e.options.countOverflowText.replace("%d",e.textCount(e.$el.val())-e.options.max).replace("%type",e.options.type+"s"),n=e.$container.find("."+e.options.countOverflowContainerClass).append(t);e.showMessage(n)},e.removeOverflowMessage=function(){e.$container.find("."+e.options.countOverflowContainerClass).empty()},e.showMessage=function(t){t.css("display","inline")},e.hideMessage=function(t){t.css("display","none")},e.clearErrors=function(t){var n=e.$el,o=e.$container;o.children(".error-text-"+t).remove(),0==o.children(".error-text").length&&(e.removeOverflowMessage(),e.showMessage(e.$container.find("."+e.options.textCountMessageClass)),n.removeClass(e.options.inputErrorClass),o.removeClass(e.options.counterErrorClass))},e.init()},t.textcounter.defaultOptions={type:"character",min:0,max:200,countContainerElement:"div",countContainerClass:"text-count-wrapper",textCountMessageClass:"text-count-message",textCountClass:"text-count",inputErrorClass:"error",counterErrorClass:"error",counterText:"Total Count: %d",errorTextElement:"div",minimumErrorText:"Minimum not met",maximumErrorText:"Maximum exceeded",displayErrorText:!0,stopInputAtMaximum:!0,countSpaces:!1,countDown:!1,countDownText:"Remaining: %d",countExtendedCharacters:!1,twoCharCarriageReturn:!1,countOverflow:!1,countOverflowText:"Maximum %type exceeded by %d",countOverflowContainerClass:"text-count-overflow-wrapper",maxunder:function(t){},minunder:function(t){},maxcount:function(t){},mincount:function(t){},init:function(t){}},t.fn.textcounter=function(n){return this.each(function(){new t.textcounter(this,n)})}}(jQuery);



