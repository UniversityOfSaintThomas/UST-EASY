/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 9/29/2022.
 */

@RestResource(urlMapping='/applicaitondepositreceive/*')
global with sharing class ApplicationDepositRest {

    @HttpPost
    global static String receiptDeposit() {
        RestRequest req = RestContext.request;
        System.debug('TouchNet Postback request headers: ' + JSON.serializePretty(req.headers));
        System.debug('TouchNet Postback parameters: ' + JSON.serializePretty(req.params));
        Map<String, String> params = req.params;
        System.debug(params);
        return 'Success here!!';
    }

}