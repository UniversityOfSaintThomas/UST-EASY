/**
 * Shared environmental variable capture utility for the EASY admissions portal fraud
 * monitoring feature (ECRMSF-5511 / ECRMSF-5529).
 *
 * Apex/Visualforce only has access to the HTTP request headers a browser sends - it cannot see
 * client-only signals like screen resolution, timezone, or browser language (those require
 * client-side JS, collected separately and passed through as a JSON blob - see
 * Client_Env_JSON__c on Application_Login__c). This class covers the server-side-visible half:
 * parsing the User-Agent header into a rough browser (including major version, when
 * determinable)/OS/device-type breakdown for reporting.
 *
 * This is intentionally a lightweight, best-effort parser (common browsers/platforms only) -
 * the raw User-Agent string is always stored separately (User_Agent_Raw__c) so parsing can be
 * improved later without losing data already captured.
 *
 * See docs/fraud-monitoring-recaptcha-ip-geo.md for the full design.
 */
public with sharing class ApplicationEnvironmentCapture {

    public class ParsedUserAgent {
        public String browser { get; private set; }
        public String operatingSystem { get; private set; }
        public String deviceType { get; private set; }

        public ParsedUserAgent(String browser, String operatingSystem, String deviceType) {
            this.browser = browser;
            this.operatingSystem = operatingSystem;
            this.deviceType = deviceType;
        }
    }

    /**
     * @description Parses a raw User-Agent header string into a rough browser/OS/device-type
     * breakdown. Never throws - returns "Unknown" for any field it cannot confidently determine.
     * When a major browser version can be confidently determined, it is appended to the browser
     * name (e.g. "Chrome 128"); when it cannot, the browser name is returned alone (e.g.
     * "Chrome") rather than guessing or defaulting to a placeholder version.
     *
     * @param userAgent The raw User-Agent header value. May be null or blank.
     * @return ParsedUserAgent with browser, operatingSystem, and deviceType populated (never null,
     *         falling back to "Unknown" when undeterminable).
     */
    public static ParsedUserAgent parseUserAgent(String userAgent) {
        if (String.isBlank(userAgent)) {
            return new ParsedUserAgent('Unknown', 'Unknown', 'Unknown');
        }

        String ua = userAgent.toLowerCase();

        String deviceType = 'Desktop';
        if (ua.contains('ipad') || ua.contains('tablet') || (ua.contains('android') && !ua.contains('mobile'))) {
            deviceType = 'Tablet';
        } else if (ua.contains('mobi') || ua.contains('iphone') || ua.contains('ipod') || ua.contains('android')) {
            deviceType = 'Mobile';
        }

        String operatingSystem = 'Unknown';
        if (ua.contains('windows')) {
            operatingSystem = 'Windows';
        } else if (ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod')) {
            operatingSystem = 'iOS';
        } else if (ua.contains('mac os') || ua.contains('macintosh')) {
            operatingSystem = 'macOS';
        } else if (ua.contains('android')) {
            operatingSystem = 'Android';
        } else if (ua.contains('linux')) {
            operatingSystem = 'Linux';
        }

        // Order matters: Edge/Opera/Samsung UAs also contain "chrome" or "safari" tokens, so
        // check the more specific browser tokens first.
        String browser = 'Unknown';
        String versionToken = null;
        if (ua.contains('edg/') || ua.contains('edge/')) {
            browser = 'Edge';
            versionToken = extractVersionAfter(ua, ua.contains('edg/') ? 'edg/' : 'edge/');
        } else if (ua.contains('opr/') || ua.contains('opera')) {
            browser = 'Opera';
            versionToken = ua.contains('opr/') ? extractVersionAfter(ua, 'opr/') : extractVersionAfter(ua, 'opera/');
        } else if (ua.contains('samsungbrowser')) {
            browser = 'Samsung Internet';
            versionToken = extractVersionAfter(ua, 'samsungbrowser/');
        } else if (ua.contains('firefox')) {
            browser = 'Firefox';
            versionToken = extractVersionAfter(ua, 'firefox/');
        } else if (ua.contains('crios')) {
            browser = 'Chrome';
            versionToken = extractVersionAfter(ua, 'crios/');
        } else if (ua.contains('chrome')) {
            browser = 'Chrome';
            versionToken = extractVersionAfter(ua, 'chrome/');
        } else if (ua.contains('fxios')) {
            browser = 'Firefox';
            versionToken = extractVersionAfter(ua, 'fxios/');
        } else if (ua.contains('safari')) {
            browser = 'Safari';
            // Safari's real version is in a separate "Version/x.y" token - "Safari/605.1.15" is
            // the WebKit build number, not the browser version, so it cannot be used here.
            versionToken = extractVersionAfter(ua, 'version/');
        }

        if (String.isNotBlank(versionToken)) {
            browser = browser + ' ' + versionToken;
        }

        return new ParsedUserAgent(browser, operatingSystem, deviceType);
    }

    /**
     * @description Extracts the major version number immediately following the given lowercase
     * token (e.g. "chrome/") from a lowercase User-Agent string, e.g. "chrome/128.0.6613.137"
     * with token "chrome/" returns "128". Never throws - returns null if the token isn't present
     * or no leading digits follow it.
     *
     * @param lowerCaseUserAgent The full User-Agent string, already lowercased.
     * @param token The lowercase token to search for, including its trailing "/".
     * @return The major version number as a String, or null if it cannot be determined.
     */
    private static String extractVersionAfter(String lowerCaseUserAgent, String token) {
        Integer tokenIndex = lowerCaseUserAgent.indexOf(token);
        if (tokenIndex < 0) {
            return null;
        }

        String afterToken = lowerCaseUserAgent.substring(tokenIndex + token.length());
        Integer i = 0;
        while (i < afterToken.length() && afterToken.substring(i, i + 1).isNumeric()) {
            i++;
        }

        return i > 0 ? afterToken.substring(0, i) : null;
    }

    /**
     * @description Merges server-only signals (the Referer header, and whether the server-seen
     * User-Agent header disagrees with the client-JS-reported navigator.userAgent) into the
     * client-collected environmental JSON blob. Both signals are cheap fraud-relevant additions
     * discovered during manual testing of this feature - a mismatched Referer/UA pairing is a
     * classic automation/spoofing tell, and the client JSON blob (Client_Env_JSON__c) is the
     * existing catch-all field for "log more, it's free"-style signals rather than adding new
     * dedicated columns for each one. Never throws - returns clientEnvJson unchanged (or an empty
     * object) if the blob cannot be parsed as JSON.
     *
     * @param clientEnvJson The raw JSON blob collected by client-side JS (may be null/blank).
     * @param refererHeader The raw Referer request header value (may be null).
     * @param serverUserAgent The raw User-Agent request header value (may be null).
     * @return The merged JSON string, always valid JSON, safe to store as-is.
     */
    public static String mergeServerSignals(String clientEnvJson, String refererHeader, String serverUserAgent) {
        Map<String, Object> envMap;
        try {
            envMap = String.isNotBlank(clientEnvJson) ? (Map<String, Object>) JSON.deserializeUntyped(clientEnvJson) : new Map<String, Object>();
        } catch (Exception ex) {
            envMap = new Map<String, Object>();
        }

        envMap.put('referer', refererHeader);

        Object clientReportedUA = envMap.get('userAgentJs');
        Boolean uaMismatch = null;
        if (clientReportedUA instanceof String && String.isNotBlank(serverUserAgent)) {
            uaMismatch = !((String) clientReportedUA).equals(serverUserAgent);
        }
        envMap.put('userAgentMismatch', uaMismatch);

        return JSON.serialize(envMap);
    }
}
