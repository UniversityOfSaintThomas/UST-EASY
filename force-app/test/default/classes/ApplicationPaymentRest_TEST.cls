/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/24/2022.
 */


@IsTest
private class ApplicationPaymentRest_TEST {
    @IsTest
    static void testBehavior() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/applicaitonpaymentreceive';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Blob resBody = Blob.valueOf('{"this":"that"}');
        req.requestBody = resBody;

        String result = ApplicationPaymentRest.receiptDeposit();
        Test.startTest();
        System.assertEquals('HTTP_ERROR', result);
        System.debug(JSON.serializePretty(res));
        Test.stopTest();
    }
}