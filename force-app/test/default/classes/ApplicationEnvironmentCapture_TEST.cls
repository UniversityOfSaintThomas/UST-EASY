/**
 * Unit tests for ApplicationEnvironmentCapture.cls (ECRMSF-5511 / ECRMSF-5529). Covers
 * parseUserAgent's browser/OS/device-type classification across common User-Agent strings
 * (including the token-ordering gotchas - Edge/Opera/Samsung must not be misclassified as
 * Chrome/Safari, and tablets must not be misclassified as Mobile), major browser version
 * extraction (including Safari's special-cased "Version/" token and the no-version-parseable
 * fallback), and mergeServerSignals' Referer/User-Agent-mismatch merge logic including its
 * graceful handling of null/malformed input.
 */
@isTest
private class ApplicationEnvironmentCapture_TEST {

    private static final String CHROME_WINDOWS_UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    private static final String SAFARI_MAC_UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15';
    private static final String FIREFOX_LINUX_UA = 'Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0';
    private static final String EDGE_WINDOWS_UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0';
    private static final String OPERA_UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 OPR/106.0.0.0';
    private static final String SAMSUNG_BROWSER_UA = 'Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/23.0 Chrome/115.0.0.0 Mobile Safari/537.36';
    private static final String IPHONE_UA = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
    private static final String IPAD_UA = 'Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
    private static final String ANDROID_PHONE_UA = 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
    private static final String ANDROID_TABLET_UA = 'Mozilla/5.0 (Linux; Android 13; SM-T870) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

    // ==================== parseUserAgent ====================

    @isTest
    static void blankUserAgentReturnsAllUnknown() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent('');

        Assert.areEqual('Unknown', result.browser, 'A blank User-Agent must resolve browser to Unknown.');
        Assert.areEqual('Unknown', result.operatingSystem, 'A blank User-Agent must resolve OS to Unknown.');
        Assert.areEqual('Unknown', result.deviceType, 'A blank User-Agent must resolve device type to Unknown, not Desktop, since it truly cannot be determined.');
    }

    @isTest
    static void nullUserAgentReturnsAllUnknown() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(null);

        Assert.areEqual('Unknown', result.browser, 'A null User-Agent must resolve browser to Unknown.');
        Assert.areEqual('Unknown', result.operatingSystem, 'A null User-Agent must resolve OS to Unknown.');
    }

    @isTest
    static void chromeOnWindowsParsedCorrectly() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(CHROME_WINDOWS_UA);

        Assert.areEqual('Chrome 120', result.browser, 'Chrome UA must be classified as Chrome with its major version appended.');
        Assert.areEqual('Windows', result.operatingSystem, 'Windows UA must be classified as Windows.');
        Assert.areEqual('Desktop', result.deviceType, 'A desktop Windows UA must be classified as Desktop.');
    }

    @isTest
    static void safariOnMacOsParsedCorrectly() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(SAFARI_MAC_UA);

        Assert.areEqual('Safari 17', result.browser, 'Safari UA must be classified as Safari with its major version appended, taken from the separate "Version/" token rather than the "Safari/605.1.15" WebKit build number.');
        Assert.areEqual('macOS', result.operatingSystem, 'Mac OS X UA must be classified as macOS.');
        Assert.areEqual('Desktop', result.deviceType, 'A desktop Mac UA must be classified as Desktop.');
    }

    @isTest
    static void firefoxOnLinuxParsedCorrectly() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(FIREFOX_LINUX_UA);

        Assert.areEqual('Firefox 120', result.browser, 'Firefox UA must be classified as Firefox with its major version appended.');
        Assert.areEqual('Linux', result.operatingSystem, 'Linux UA must be classified as Linux.');
        Assert.areEqual('Desktop', result.deviceType, 'A desktop Linux UA must be classified as Desktop.');
    }

    @isTest
    static void edgeUaNotMisclassifiedAsChrome() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(EDGE_WINDOWS_UA);

        Assert.areEqual('Edge 120', result.browser, 'An Edge UA contains "chrome" and "safari" tokens too, but the more specific "edg/" token must take priority and classify it as Edge with its own version, not Chrome\'s.');
    }

    @isTest
    static void operaUaNotMisclassifiedAsChrome() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(OPERA_UA);

        Assert.areEqual('Opera 106', result.browser, 'An Opera UA contains "chrome" too, but the more specific "opr/" token must take priority and classify it as Opera with its own version, not Chrome\'s.');
    }

    @isTest
    static void samsungBrowserUaNotMisclassifiedAsChrome() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(SAMSUNG_BROWSER_UA);

        Assert.areEqual('Samsung Internet 23', result.browser, 'A Samsung Internet UA contains "chrome" too, but the more specific "samsungbrowser" token must take priority and use its own version, not Chrome\'s.');
    }

    @isTest
    static void iphoneParsedAsMobileIos() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(IPHONE_UA);

        Assert.areEqual('Safari 17', result.browser, 'An iPhone Safari UA must include the major version from its "Version/" token.');
        Assert.areEqual('iOS', result.operatingSystem, 'An iPhone UA must be classified as iOS.');
        Assert.areEqual('Mobile', result.deviceType, 'An iPhone UA must be classified as Mobile, not Tablet.');
    }

    @isTest
    static void ipadParsedAsTabletNotMobile() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(IPAD_UA);

        Assert.areEqual('Safari 17', result.browser, 'An iPad Safari UA must include the major version from its "Version/" token.');
        Assert.areEqual('iOS', result.operatingSystem, 'An iPad UA must be classified as iOS.');
        Assert.areEqual('Tablet', result.deviceType, 'An iPad UA must be classified as Tablet, since tablet signals are checked before mobile signals.');
    }

    @isTest
    static void androidPhoneParsedAsMobile() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(ANDROID_PHONE_UA);

        Assert.areEqual('Chrome 120', result.browser, 'An Android Chrome UA must include the major version from its "Chrome/" token.');
        Assert.areEqual('Android', result.operatingSystem, 'An Android UA must be classified as Android.');
        Assert.areEqual('Mobile', result.deviceType, 'An Android phone UA (containing "mobile") must be classified as Mobile.');
    }

    @isTest
    static void androidTabletNotMisclassifiedAsMobile() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(ANDROID_TABLET_UA);

        Assert.areEqual('Chrome 120', result.browser, 'An Android tablet Chrome UA must include the major version from its "Chrome/" token.');
        Assert.areEqual('Android', result.operatingSystem, 'An Android tablet UA must be classified as Android.');
        Assert.areEqual('Tablet', result.deviceType, 'An Android UA WITHOUT the "mobile" token must be classified as Tablet, not Mobile - this is the key Android-tablet-vs-phone distinction.');
    }

    @isTest
    static void completelyUnrecognizedUaFallsBackToUnknown() {
        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent('SomeCustomBot/1.0');

        Assert.areEqual('Unknown', result.browser, 'An unrecognized UA must fall back to Unknown browser rather than guessing.');
        Assert.areEqual('Unknown', result.operatingSystem, 'An unrecognized UA must fall back to Unknown OS rather than guessing.');
        Assert.areEqual('Desktop', result.deviceType, 'An unrecognized UA defaults to Desktop device type, since no mobile/tablet signal was present.');
    }

    @isTest
    static void browserTokenWithNoParseableVersionOmitsVersionEntirely() {
        // A Chrome token with no trailing digits at all - version cannot be determined.
        String uaWithNoVersion = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/ Safari/537.36';

        ApplicationEnvironmentCapture.ParsedUserAgent result = ApplicationEnvironmentCapture.parseUserAgent(uaWithNoVersion);

        Assert.areEqual('Chrome', result.browser, 'When no major version can be parsed after the browser token, the browser name must be returned alone with no trailing space or placeholder version - never "Chrome " or "Chrome Unknown".');
    }

    // ==================== mergeServerSignals ====================

    @isTest
    static void mergeWithMatchingUserAgentSetsNoMismatch() {
        String clientJson = '{"userAgentJs":"SAME_UA_STRING"}';

        String result = ApplicationEnvironmentCapture.mergeServerSignals(clientJson, 'https://example.com/page', 'SAME_UA_STRING');
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(result);

        Assert.areEqual(false, parsed.get('userAgentMismatch'), 'Matching client and server User-Agent values must result in userAgentMismatch = false.');
        Assert.areEqual('https://example.com/page', parsed.get('referer'), 'The referer header must be merged into the blob as-is.');
        Assert.areEqual('SAME_UA_STRING', parsed.get('userAgentJs'), 'The original client-collected fields must be preserved in the merged blob.');
    }

    @isTest
    static void mergeWithMismatchedUserAgentSetsTrueMismatch() {
        String clientJson = '{"userAgentJs":"CLIENT_REPORTED_UA"}';

        String result = ApplicationEnvironmentCapture.mergeServerSignals(clientJson, 'https://example.com/page', 'DIFFERENT_SERVER_UA');
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(result);

        Assert.areEqual(true, parsed.get('userAgentMismatch'), 'A mismatch between client-reported and server-observed User-Agent must set userAgentMismatch = true - this is a bot/spoofing signal.');
    }

    @isTest
    static void mergeWithNullClientBlobStillProducesValidJson() {
        String result = ApplicationEnvironmentCapture.mergeServerSignals(null, 'https://example.com/page', 'SOME_UA');
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(result);

        Assert.areEqual('https://example.com/page', parsed.get('referer'), 'A null client blob must still result in a valid JSON object containing the referer.');
        Assert.isNull(parsed.get('userAgentMismatch'), 'With no client-reported UA to compare, userAgentMismatch must be null, not false or true - there is genuinely no data to compare.');
    }

    @isTest
    static void mergeWithMalformedClientBlobDoesNotThrow() {
        String result = ApplicationEnvironmentCapture.mergeServerSignals('not valid json{{{', 'https://example.com/page', 'SOME_UA');
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(result);

        Assert.areEqual('https://example.com/page', parsed.get('referer'), 'A malformed client blob must be gracefully discarded, not thrown - the referer must still be present in the fallback.');
    }

    @isTest
    static void mergeWithBlankRefererStillProducesValidJson() {
        String clientJson = '{"userAgentJs":"SOME_UA","timeZone":"America/Chicago"}';

        String result = ApplicationEnvironmentCapture.mergeServerSignals(clientJson, null, 'SOME_UA');
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(result);

        Assert.isNull(parsed.get('referer'), 'A null referer header must be preserved as null in the merged blob.');
        Assert.areEqual('America/Chicago', parsed.get('timeZone'), 'Other client-collected fields must be preserved unchanged.');
        Assert.areEqual(false, parsed.get('userAgentMismatch'), 'Matching UAs must still be correctly detected even when referer is absent.');
    }
}
