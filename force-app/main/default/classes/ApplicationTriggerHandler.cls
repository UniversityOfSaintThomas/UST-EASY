/**
 * Handles the after-update trigger on Application__c for the fraud monitoring feature
 * (ECRMSF-5511 / ECRMSF-5529). Detects when Application_Status__c changed to the value
 * configured as that application's "submitted" status
 * (Application_Control__r.Submit_Status__c) and dispatches an asynchronous fraud-monitoring
 * capture (reCAPTCHA + environmental variables + geolocation) for that submission event.
 *
 * The calling call sites (ApplicationRequirement.cls, ApplicationChecklist.cls,
 * ApplicationChecklistComponentController.cls) all perform sparse updates - only Id and
 * Application_Status__c are populated on the sObject passed to update - so Application_Control__c
 * and Contact__c are NOT available on Trigger.new/Trigger.oldMap and must be re-queried here.
 *
 * See docs/fraud-monitoring-recaptcha-ip-geo.md ("Application submission trigger point") for the
 * full design rationale, including why this reacts to the data change itself rather than
 * instrumenting the individual call sites, and why the callout-dependent work below is deferred
 * to @future rather than run synchronously (same uncommitted-DML constraint documented for
 * ApplicationRegistration.cls's registration path).
 */
public without sharing class ApplicationTriggerHandler {

    /**
     * @description Entry point called by ApplicationTrigger. Identifies rows whose
     * Application_Status__c changed in this update, re-queries them for the fields needed to
     * determine whether the new status is that application's configured submission status, and
     * dispatches one async capture per genuine submission event. Never throws - a fraud-monitoring
     * failure must never surface as an error on the triggering DML.
     *
     * @param newRecords Trigger.new - the updated Application__c records (sparse; may only have
     *        Id and Application_Status__c populated depending on the calling code path).
     * @param oldRecordsById Trigger.oldMap - the pre-update Application__c records, keyed by Id.
     */
    public static void handleAfterUpdate(List<Application__c> newRecords, Map<Id, Application__c> oldRecordsById) {
        try {
            Set<Id> statusChangedIds = new Set<Id>();
            for (Application__c newRecord : newRecords) {
                Application__c oldRecord = oldRecordsById.get(newRecord.Id);
                if (oldRecord != null && newRecord.Application_Status__c != oldRecord.Application_Status__c) {
                    statusChangedIds.add(newRecord.Id);
                }
            }

            if (statusChangedIds.isEmpty()) {
                return;
            }

            // Capture request headers HERE, synchronously, while this trigger is still running in
            // the original Visualforce request context. ApexPages.currentPage() is confirmed
            // accessible from inside a trigger fired synchronously by a VF controller's DML (see
            // docs/fraud-monitoring-recaptcha-ip-geo.md's live spike write-up), but that context
            // does NOT carry over into the later @future transaction - the future method must
            // receive these as primitive parameters rather than reading headers itself.
            String ipAddress = null;
            String userAgent = null;
            String refererHeader = null;
            try {
                Map<String, String> headers = ApexPages.currentPage().getHeaders();
                String sip = headers.get('X-Salesforce-SIP');
                String forwardedFor = headers.get('X-Forwarded-For');
                ipAddress = String.isNotBlank(sip) ? sip : (String.isNotBlank(forwardedFor) ? forwardedFor.split(',')[0].trim() : null);
                userAgent = headers.get('User-Agent');
                refererHeader = headers.get('Referer');
            } catch (Exception headerEx) {
                // No Visualforce request context available (e.g. a REST/Bulk API-driven update,
                // or an update originating outside a VF page request) - proceed with null
                // header-derived values rather than failing the whole capture.
                System.debug(LoggingLevel.WARN, 'ApplicationTriggerHandler: no request context available for submission capture. ' + headerEx.getMessage());
            }

            List<Application__c> candidates = [
                    SELECT Id, Contact__c, Application_Status__c, Application_Control__r.Submit_Status__c
                    FROM Application__c
                    WHERE Id IN :statusChangedIds
                    AND Application_Control__c != NULL
            ];

            for (Application__c app : candidates) {
                if (app.Contact__c == null) {
                    continue;
                }
                if (String.isBlank(app.Application_Control__r.Submit_Status__c)) {
                    continue;
                }
                if (app.Application_Status__c == app.Application_Control__r.Submit_Status__c) {
                    logSubmissionAttemptAsync(app.Contact__c, app.Id, ipAddress, userAgent, refererHeader);
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN, 'ApplicationTriggerHandler: fraud monitoring dispatch failed, continuing. ' + ex.getTypeName() + ': ' + ex.getMessage());
        }
    }

    /**
     * @description Captures a reCAPTCHA score and environmental variables for a Submission event,
     * inserting a single Application_Login__c record scoped to the Contact and Application that
     * were just submitted.
     *
     * MUST run as @future(callout=true), not synchronously from the trigger. The trigger fires
     * from an update DML (Application_Status__c) that is still uncommitted when the trigger body
     * runs; Apex forbids making an HTTP callout in a transaction with uncommitted prior DML (see
     * ApplicationRegistration.cls's logRegistrationAttemptAsync for the same constraint discovered
     * and fixed on the Registration event path). Deferring to @future runs this in a new
     * transaction after the triggering update has committed.
     *
     * IP/User-Agent/Referer are passed in as primitives already captured synchronously by
     * handleAfterUpdate - ApexPages.currentPage() is NOT available inside this future method
     * itself, since the future transaction runs later and outside any HTTP request context.
     * There is no reCAPTCHA token or client-JS env JSON blob available at all for Submission
     * events (no Visualforce page in this design currently performs the client-side JS collection
     * for the submission flow - see docs/fraud-monitoring-recaptcha-ip-geo.md's open item on this)
     * - reCAPTCHA gracefully degrades to Unavailable per the existing contract, and
     * Client_Env_JSON__c is populated with only the server-merged Referer/UA-mismatch signals.
     *
     * Unlike the Login event path, there is no LoginHistory row relevant to a submission event
     * (submission is not a login), so geolocation uses the third-party ApplicationGeolocation
     * utility, same as the Registration event path.
     *
     * @param contactId The Id of the Contact who owns the just-submitted Application__c.
     * @param applicationId The Id of the Application__c that was just submitted.
     * @param ipAddress The resolved client IP address captured synchronously in the trigger.
     * @param userAgent The raw User-Agent header value captured synchronously in the trigger.
     * @param refererHeader The raw Referer header value captured synchronously in the trigger.
     */
    @future(callout=true)
    public static void logSubmissionAttemptAsync(Id contactId, Id applicationId, String ipAddress, String userAgent, String refererHeader) {
        if (contactId == null || applicationId == null) {
            return;
        }

        ApplicationReCaptcha.ReCaptchaResult recaptchaResult = ApplicationReCaptcha.isReCAPTCHAValid(null);
        ApplicationEnvironmentCapture.ParsedUserAgent parsedUA = ApplicationEnvironmentCapture.parseUserAgent(userAgent);
        String mergedClientEnvJson = ApplicationEnvironmentCapture.mergeServerSignals(null, refererHeader, userAgent);
        String geolocation = ApplicationGeolocation.getGeolocation(ipAddress);

        Application_Login__c logEntry = new Application_Login__c();
        logEntry.Contact__c = contactId;
        logEntry.Application__c = applicationId;
        logEntry.Event_Type__c = 'Submission';
        logEntry.ReCAPTCHA_Score__c = recaptchaResult.score;
        logEntry.ReCAPTCHA_Score_Status__c = recaptchaResult.status;
        logEntry.ReCAPTCHA_Error_Detail__c = truncate(recaptchaResult.errorDetail, 255);
        logEntry.IP_Address__c = ipAddress;
        logEntry.Geolocation__c = geolocation;
        logEntry.Browser__c = parsedUA.browser;
        logEntry.Operating_System__c = parsedUA.operatingSystem;
        logEntry.Device_Type__c = parsedUA.deviceType;
        logEntry.User_Agent_Raw__c = userAgent;
        logEntry.Client_Env_JSON__c = mergedClientEnvJson;

        try {
            insert logEntry;
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN, 'ApplicationTriggerHandler: failed to insert Application_Login__c record. ' + ex.getMessage());
        }

        // Shared IP 30-day count: pure Apex aggregate only - the Shared_IP_Warning__c threshold
        // decision belongs to an admin-tunable Flow, not this class. Scoped to Submission events
        // only, matching this feature's "compare against submission IP only" design decision. Runs
        // after the insert above so this new row is itself included in the trailing-30-day count.
        ApplicationSharedIpCount.updateSharedIpCount(applicationId, ipAddress);
    }

    /**
     * @description Truncates val to at most maxLen characters. Returns val unchanged if it fits
     * or is blank. Used to defensively guard against DML failures when writing exception messages
     * into fixed-length diagnostic text fields.
     */
    private static String truncate(String val, Integer maxLen) {
        if (String.isBlank(val)) {
            return val;
        }
        return val.length() > maxLen ? val.left(maxLen) : val;
    }
}
