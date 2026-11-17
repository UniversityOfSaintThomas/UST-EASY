// AppReviewUtility.js
import {publish} from "lightning/messageService";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import upsertAppReviewData from '@salesforce/apex/EASYAppInfoController.upsertAppReviewData';

export function adjustURLParams(parameter, parameterValue) {
    let queryParams = new URLSearchParams(window.location.search);
    // Remove any case-insensitive match first to avoid duplicate params
    // (e.g. Salesforce may lowercase c__appId to c__appid in the URL)
    const lowerParam = parameter.toLowerCase();
    for (const key of [...queryParams.keys()]) {
        if (key.toLowerCase() === lowerParam) {
            queryParams.delete(key);
        }
    }
    queryParams.set(parameter, parameterValue);
    history.replaceState(null, null, "?" + queryParams.toString());
}

// App Id waiting to be published from the URL. Every review component calls setAppIdFromURL when it connects, so
// without this they would each publish the same message and each component would reload its data several times.
let pendingPreloadAppId = null;

export function setAppIdFromURL(context, chanel, pageRef, currentAppId) {
    const appId = pageRef?.state?.c__appId ?? pageRef?.state?.c__appid;
    if (!currentAppId && appId && pendingPreloadAppId !== appId) {
        pendingPreloadAppId = appId;
        // Publish once, after the page's components have all connected and subscribed in the same pass.
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            pendingPreloadAppId = null;
            publish(context, chanel, {appId: appId});
        }, 0);
    }
    }

// Review record requests that are still running, by application id.
const reviewRecordRequests = new Map();

/**
 * Gets (creating or refreshing it if needed) the Application_Review__c record for an application.
 * The information panel and the review form both need that record when an application is selected. This shares one
 * server call between them while it is running, so the two components cannot each create a review record.
 *
 * @param appId The Application__c Id
 * @returns Promise of the Application_Review__c record
 */
export function ensureReviewRecord(appId) {
    if (!reviewRecordRequests.has(appId)) {
        const request = upsertAppReviewData({appId}).finally(() => {
            reviewRecordRequests.delete(appId);
        });
        reviewRecordRequests.set(appId, request);
    }
    return reviewRecordRequests.get(appId);
}

/**
 * Shared error-toast helper so every component reports Apex failures the same way
 * instead of each reinventing (or skipping) its own error UX.
 */
export function showErrorToast(component, title, error) {
    console.error(title, error);
    component.dispatchEvent(new ShowToastEvent({
        title,
        message: error?.body?.message ?? error?.message ?? 'Unknown error',
        variant: 'error'
    }));
}