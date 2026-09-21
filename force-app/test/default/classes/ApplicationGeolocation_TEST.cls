/**
 * Unit tests for ApplicationGeolocation.cls (ECRMSF-5511 / ECRMSF-5529). Covers the
 * graceful-degradation contract for the ip-api.com free-tier integration: every failure mode
 * (blank IP, rate limiting, non-200 status, status=fail, malformed response, missing fields)
 * must return null, never throw. Only a genuinely successful response with usable location data
 * returns a formatted "City, Region, Country" string.
 */
@isTest
private class ApplicationGeolocation_TEST {

    /**
     * @description Simple HttpCalloutMock that returns a fixed status code and body, used to
     * simulate every ip-api.com response shape under test without making a real callout.
     */
    private class StaticResponseMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        StaticResponseMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }

    @isTest
    static void blankIpAddressReturnsNull() {
        String result = ApplicationGeolocation.getGeolocation('');
        Assert.isNull(result, 'A blank IP address must return null without attempting a callout.');
    }

    @isTest
    static void nullIpAddressReturnsNull() {
        String result = ApplicationGeolocation.getGeolocation(null);
        Assert.isNull(result, 'A null IP address must return null without attempting a callout.');
    }

    @isTest
    static void successfulLookupReturnsFormattedString() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(200, '{"status":"success","city":"Minneapolis","regionName":"Minnesota","country":"United States","query":"24.152.140.219"}'));

        Test.startTest();
        String result = ApplicationGeolocation.getGeolocation('24.152.140.219');
        Test.stopTest();

        Assert.areEqual('Minneapolis, Minnesota, United States', result, 'The formatted string must be City, Region, Country in that order.');
    }

    @isTest
    static void statusFailReturnsNull() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(200, '{"status":"fail","message":"private range","query":"192.168.1.1"}'));

        Test.startTest();
        String result = ApplicationGeolocation.getGeolocation('192.168.1.1');
        Test.stopTest();

        Assert.isNull(result, 'A status=fail response (e.g. private/reserved IP) must return null, not throw, even though the HTTP status is 200.');
    }

    @isTest
    static void rateLimitedResponseReturnsNull() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(429, 'Too Many Requests'));

        Test.startTest();
        String result = ApplicationGeolocation.getGeolocation('24.152.140.219');
        Test.stopTest();

        Assert.isNull(result, 'An HTTP 429 rate-limit response must return null immediately without retrying.');
    }

    @isTest
    static void nonSuccessHttpStatusReturnsNull() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(500, 'Internal Server Error'));

        Test.startTest();
        String result = ApplicationGeolocation.getGeolocation('24.152.140.219');
        Test.stopTest();

        Assert.isNull(result, 'A non-200 HTTP status other than 429 must also return null gracefully.');
    }

    @isTest
    static void malformedJsonResponseReturnsNull() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(200, 'not valid json{{{'));

        Test.startTest();
        String result = ApplicationGeolocation.getGeolocation('24.152.140.219');
        Test.stopTest();

        Assert.isNull(result, 'A malformed JSON response must be caught and return null rather than throwing.');
    }

    @isTest
    static void partialLocationDataOmitsMissingParts() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(200, '{"status":"success","city":"Minneapolis","country":"United States","query":"24.152.140.219"}'));

        Test.startTest();
        String result = ApplicationGeolocation.getGeolocation('24.152.140.219');
        Test.stopTest();

        Assert.areEqual('Minneapolis, United States', result, 'When a middle part (region) is missing, the joined string must skip it rather than leaving an empty segment.');
    }

    @isTest
    static void successStatusWithNoUsableFieldsReturnsNull() {
        Test.setMock(HttpCalloutMock.class, new StaticResponseMock(200, '{"status":"success","query":"24.152.140.219"}'));

        Test.startTest();
        String result = ApplicationGeolocation.getGeolocation('24.152.140.219');
        Test.stopTest();

        Assert.isNull(result, 'A success response with no city/region/country fields at all must return null rather than an empty string.');
    }
}
