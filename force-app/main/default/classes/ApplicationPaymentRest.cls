/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 9/29/2022.
 */

@RestResource(urlMapping='/applicaitonpaymentreceive/*')
global with sharing class ApplicationPaymentRest {

    @HttpPost
    global static String receiptDeposit() {
        RestRequest req = RestContext.request;
        Map<String, String> params = req.params;

        if(String.isNotBlank(params.get('session_identifier'))) {
            System.debug('TouchNet Postback request headers: ' + JSON.serializePretty(req.headers));
            System.debug('TouchNet Postback parameters: ' + JSON.serializePretty(req.params));
            System.debug(params);
            system.debug(params.get('name_on_acct'));
        }

        return 'HTTP_OK';
    }

}