/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 9/28/2022.
 */


public with sharing class ApplicationDepositController {

    public Map<String, String> parameterMap { get; set; }

    public ApplicationDepositController(ApplicationRequirement ac) {
        String headerData = ApexPages.currentPage().getHeaders().get('Host');
        String urlValue = ApexPages.currentPage().getUrl();
        String currentUrl = 'https://' + headerdata + urlvalue;
        parameterMap = new Map<String, String>();
        parameterMap.put('UPAY_SITE_ID', '2');
        parameterMap.put('VALIDATION_KEY', createValidationKey(ac));
        parameterMap.put('EXT_TRANS_ID', ac.appInfo.appId);
        parameterMap.put('EXT_TRANS_ID_LABEL', 'AppId');
        parameterMap.put('AMT', '350.00');

        parameterMap.put('BILL_NAME', 'Thad Dahlberg');
        parameterMap.put('BILL_EMAIL_ADDRESS', 'thad@valleyhill.net');
        parameterMap.put('BILL_STREET1', '123 Electric Ave.');
        parameterMap.put('BILL_STATE', 'MN.');
        parameterMap.put('BILL_POSTAL_CODE', '55418');

        parameterMap.put('ERROR_LINK', currentUrl);
        parameterMap.put('CANCEL_LINK', currentUrl);
        parameterMap.put('CANCEL_LINK_TEXT', 'Cancel Deposit');
        parameterMap.put('SUCCESS_LINK', currentUrl);
    }

    public String createValidationKey(ApplicationRequirement ac) {

        // Set in Touchnet Marketplace Passed Amount Validation Key for each site
        String valCode = 'TommiesValidate';

        // EXT_TRANS_ID passed from payment form and can be used to track in our business office
        valCode += ac.appInfo.appId;

        // Amount passed from VF payment form to set amout requested.
        valCode += '350.00';

        //All the above in one string, MD5 hashed, converted to base64 string. Checked at gateway for access to the uPay site
        Blob requestBlob = Blob.valueOf(valCode);
        Blob hash = Crypto.generateDigest('MD5', requestBlob);
        valCode = EncodingUtil.base64Encode(hash);

        return valCode;
    }
}