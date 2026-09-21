/**
 * Shared IP geolocation utility for the EASY admissions portal fraud monitoring feature
 * (ECRMSF-5511 / ECRMSF-5529), used for Registration and Submission events - the two event
 * types that have no Salesforce-native geolocation source (unlike Login events, which use
 * LoginHistory/LoginGeo directly in ApplicationLoginController - see
 * docs/fraud-monitoring-recaptcha-ip-geo.md for the full hybrid design).
 *
 * Uses ip-api.com's free, non-commercial JSON endpoint. Known constraints of that free tier,
 * designed around below:
 * - HTTP only (no SSL) on the free tier - the callout endpoint is plain http://, not https://.
 * - Rate limited to 45 requests/minute PER SOURCE IP. Since all Salesforce outbound callouts
 *   from this org share Salesforce's own outbound IP(s), this budget is shared across ALL
 *   registration/submission events org-wide, not per-user - a real constraint under burst load
 *   (e.g. an application deadline day). On HTTP 429 or any other failure, this class returns
 *   null rather than throwing - never blocks the calling registration/submission flow.
 * - Non-commercial use only, per ip-api.com's terms.
 *
 * @description Looks up City/Region/Country for an IP address via ip-api.com, formatted as
 *              "City, Region, Country" per the ticket's required format. Never throws.
 */
public with sharing class ApplicationGeolocation {

    private static final String ENDPOINT_BASE = 'http://ip-api.com/json/';
    private static final String FIELDS = 'status,message,city,regionName,country,query';

    /**
     * @description Looks up geolocation for the given IP address. Never throws - returns null
     * on any failure (blank IP, HTTP error, rate limit, private/reserved IP address, or any
     * exception), matching the graceful-degradation contract used elsewhere in fraud monitoring
     * (see ApplicationReCaptcha.cls). Callers must never block registration/submission on the
     * outcome of this method.
     *
     * @param ipAddress The IP address to look up. May be null or blank.
     * @return "City, Region, Country" formatted string, or null if unavailable for any reason.
     */
    public static String getGeolocation(String ipAddress) {
        if (String.isBlank(ipAddress)) {
            return null;
        }

        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(ENDPOINT_BASE + EncodingUtil.urlEncode(ipAddress, 'UTF-8') + '?fields=' + FIELDS);
            req.setTimeout(10000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 429) {
                System.debug(LoggingLevel.WARN, 'ApplicationGeolocation: rate limited (HTTP 429) by ip-api.com. Skipping geolocation for this event.');
                return null;
            }

            if (res.getStatusCode() != 200) {
                System.debug(LoggingLevel.WARN, 'ApplicationGeolocation: ip-api.com returned HTTP ' + res.getStatusCode());
                return null;
            }

            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            Object statusObj = responseMap.get('status');
            String status = statusObj != null ? String.valueOf(statusObj) : null;
            if (status != 'success') {
                // status=fail covers private/reserved IP ranges and invalid queries - expected
                // and common in sandbox/scratch org testing, not necessarily an error.
                Object messageObj = responseMap.get('message');
                System.debug(LoggingLevel.INFO, 'ApplicationGeolocation: lookup did not succeed for this IP. message: ' + messageObj);
                return null;
            }

            List<String> parts = new List<String>();
            addIfNotBlank(parts, responseMap.get('city'));
            addIfNotBlank(parts, responseMap.get('regionName'));
            addIfNotBlank(parts, responseMap.get('country'));

            return parts.isEmpty() ? null : String.join(parts, ', ');

        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN, 'ApplicationGeolocation: lookup failed, returning null. ' + ex.getTypeName() + ': ' + ex.getMessage());
            return null;
        }
    }

    private static void addIfNotBlank(List<String> parts, Object value) {
        if (value != null && String.isNotBlank(String.valueOf(value))) {
            parts.add(String.valueOf(value));
        }
    }
}
