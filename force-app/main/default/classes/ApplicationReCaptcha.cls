/**
 * Shared Google reCAPTCHA v3 validation utility for the EASY admissions portal.
 *
 * Used by ApplicationRegistration.cls (account registration), ApplicationLoginController.cls
 * (every login), and application-submission capture (ECRMSF-5511 / ECRMSF-5529). Pattern
 * mirrors the Summit-Events-App summitEventsRecaptcha implementation, with one deliberate
 * difference: this class distinguishes "score unavailable" from "low score" via an explicit
 * status enum, rather than relying on a single sentinel numeric value. This is required
 * because reCAPTCHA v3's free tier can run out of request quota, and a quota failure must
 * never be interpreted as "confirmed high risk" by any downstream Flow or LWC logic.
 *
 * See docs/fraud-monitoring-recaptcha-ip-geo.md for the full fraud monitoring design.
 *
 * @description Validates Google reCAPTCHA v3 tokens against the configured siteverify endpoint,
 *              failing gracefully (never throwing, never blocking the caller) on any failure.
 */
public with sharing class ApplicationReCaptcha {

    /**
     * @description Status values mirroring the Application_Login__c.ReCAPTCHA_Score_Status__c
     * picklist. Kept as constants (not an Apex enum) so callers can compare directly against
     * the picklist value they will persist to the sObject field.
     */
    public static final String STATUS_SCORED = 'Scored';
    public static final String STATUS_UNAVAILABLE = 'Unavailable';
    public static final String STATUS_ERROR = 'Error';

    /**
     * @description Result wrapper for a reCAPTCHA v3 validation attempt. score is null unless
     * status == STATUS_SCORED. Callers must never treat a null score as a low/suspicious score.
     */
    public class ReCaptchaResult {
        public Decimal score { get; private set; }
        public String status { get; private set; }
        public String errorDetail { get; private set; }

        public ReCaptchaResult(Decimal score, String status, String errorDetail) {
            this.score = score;
            this.status = status;
            this.errorDetail = errorDetail;
        }
    }

    /**
     * @description Client-facing reCAPTCHA v3 configuration for Visualforce page binding
     * (site key + library URL only - never the secret key, which stays server-side). Mirrors
     * the Summit-Events-App recaptchaInfo pattern.
     */
    public class RecaptchaSettings {
        public String publicKey { get; private set; }
        public String apiUrl { get; private set; }

        public RecaptchaSettings(String publicKey, String apiUrl) {
            this.publicKey = publicKey;
            this.apiUrl = apiUrl;
        }
    }

    /**
     * @description Validates a reCAPTCHA v3 client token against Google's siteverify endpoint.
     * Never throws - all callout, parsing, and configuration failures are caught and returned
     * as a ReCaptchaResult with an Unavailable or Error status instead. Callers must never block
     * a user's registration, login, or submission based on the outcome of this method; it is a
     * monitoring signal only.
     *
     * @param token The client-side reCAPTCHA v3 token to validate (from grecaptcha.execute()).
     * @return ReCaptchaResult containing a nullable score and a status distinguishing a real
     *         score from an unavailable/failed check.
     */
    public static ReCaptchaResult isReCAPTCHAValid(String token) {
        if (String.isBlank(token)) {
            return new ReCaptchaResult(null, STATUS_UNAVAILABLE, 'No reCAPTCHA token was provided by the client.');
        }

        Application_Setting__c appSettings = Application_Setting__c.getOrgDefaults();

        if (String.isBlank(appSettings.reCAPTCHA_Secret_Key__c) || String.isBlank(appSettings.reCAPTCHA_Endpoint__c)) {
            return new ReCaptchaResult(null, STATUS_UNAVAILABLE, 'reCAPTCHA is not fully configured (missing secret key or endpoint in Application_Setting__c).');
        }

        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(appSettings.reCAPTCHA_Endpoint__c);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setTimeout(10000);

            String body = 'secret=' + EncodingUtil.urlEncode(appSettings.reCAPTCHA_Secret_Key__c, 'UTF-8')
                    + '&response=' + EncodingUtil.urlEncode(token, 'UTF-8');
            req.setBody(body);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() != 200) {
                return new ReCaptchaResult(null, STATUS_UNAVAILABLE, 'reCAPTCHA endpoint returned HTTP ' + res.getStatusCode() + '. This may indicate free-tier quota exhaustion or a service outage.');
            }

            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            Object successObj = responseMap.get('success');
            Boolean success = successObj instanceof Boolean ? (Boolean) successObj : false;

            if (!success) {
                // Google returns success=false for invalid/expired tokens AND for some quota/rate
                // limit conditions communicated via error-codes; treat all of these as Unavailable
                // rather than Error, since we cannot reliably distinguish "definitely a bot" from
                // "quota exhausted" from this response shape alone, and the graceful-degradation
                // contract requires us not to assume the worst case.
                Object errorCodesObj = responseMap.get('error-codes');
                String errorCodes = errorCodesObj != null ? String.valueOf(errorCodesObj) : 'unknown';
                return new ReCaptchaResult(null, STATUS_UNAVAILABLE, 'reCAPTCHA verification did not succeed. error-codes: ' + errorCodes);
            }

            Object scoreObj = responseMap.get('score');
            if (scoreObj == null) {
                return new ReCaptchaResult(null, STATUS_UNAVAILABLE, 'reCAPTCHA response did not include a score.');
            }

            Decimal score = Decimal.valueOf(String.valueOf(scoreObj));
            return new ReCaptchaResult(score, STATUS_SCORED, null);

        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN, 'ApplicationReCaptcha: verification failed, treating as Unavailable. ' + ex.getTypeName() + ': ' + ex.getMessage());
            return new ReCaptchaResult(null, STATUS_UNAVAILABLE, ex.getTypeName() + ': ' + ex.getMessage());
        }
    }
}
