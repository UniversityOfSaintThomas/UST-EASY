// AppReviewUtility.js
import {publish} from "lightning/messageService";

export function adjustURLParams(parameter, parameterValue) {
    let queryParams = new URLSearchParams(window.location.search);
    queryParams.set(parameter, parameterValue);
    history.replaceState(null, null, "?" + queryParams.toString());
}

export function setAppIdFromURL(context, chanel, pageRef, currentAppId) {
    console.log(currentAppId);
    if (!currentAppId && pageRef?.state?.c__appId) {
        const payload = {appId: pageRef?.state?.c__appId};
        publish(context, chanel, payload);
    }
}
