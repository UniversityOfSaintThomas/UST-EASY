/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/4/2022.
 */


public with sharing class ApplicationPaymentComponentController {
    public Map<String, String> parameterMap { get; set; }
    public EASYApplicationInfo appInfoParam { get; set; }
    public ApplicationQuestion question { get; set; }
    public String paymentAmount { get; set; }
    public String configurationMessage { get; set; }

    public ApplicationPaymentComponentController() {
    }

    public String getFormParameters() {
        String parameterString = '';
        parameterMap = new Map<String, String>();
        if (appInfoParam != null) {
            if (String.isNotBlank(appInfoParam.appId)) {

                //Get current URL for return from touchnet
                String headerData = ApexPages.currentPage().getHeaders().get('Host');
                String urlValue = ApexPages.currentPage().getUrl();
                String currentUrl = 'https://' + headerData + urlValue;
/*                String at = '';
                STring requirementId = '';
                if (String.isNotBlank(ApexPages.currentPage().getParameters().get('at'))) {
                    at = ApexPages.currentPage().getParameters().get('at');
                }
                if (String.isNotBlank(ApexPages.currentPage().getParameters().get('requirementId'))) {
                    requirementId = ApexPages.currentPage().getParameters().get('requirementId');
                }
                currentUrl += '?at=' + at + '&requirementId=' + requirementId;*/

                //Get application for dtails to add to ticket
                Application__c app = [
                        SELECT Id, Name, Contact__r.FirstName, Contact__r.LastName,
                                Contact__r.Email,
                                Intended_Program__r.Application_Fee_Amount__c,
                                Intended_Program__c,
                                Contact__r.MailingStreet,
                                Contact__r.MailingCountry,
                                Contact__r.MailingState,
                                Contact__r.MailingPostalCode,
                                Application_Control__r.URL_Parameter__c
                        FROM Application__c
                        WHERE Id = :appInfoParam.appId
                ];

                System.debug(JSON.serializePretty(app));

                if (String.isNotBlank(question.question.Payment_Gateway__c)) {

                    //Get custom metadata for requested payment gateway (added to picklist on question)
                    Application_Payment_Gateway__mdt gatewayInfo = [
                            SELECT Id, Label, DeveloperName, UPay_Site_Id__c, Validation_Key__c
                            FROM Application_Payment_Gateway__mdt
                            WHERE DeveloperName = :question.question.Payment_Gateway__c
                    ];

                    //Set the payment amount by program or custom
                    String paymentType = question.question.Payment_Type__c;
                    paymentAmount = '0.00';
                    if (paymentType.equalsIgnoreCase('Program Application Fee Amount')) {
                        if (app.Intended_Program__r.Application_Fee_Amount__c != null) {
                            paymentAmount = String.valueOf(app.Intended_Program__r.Application_Fee_Amount__c.format());
                        }
                        if (paymentAmount.equals('0.00')) {
                            configurationMessage = 'Program Application Fee is not set program: ' + app.Intended_Program__c;
                        }
                    } else if (paymentType.equalsIgnoreCase('Custom Amount')) {
                        if (question.question.Payment_Custom_Amount__c != null) {
                            paymentAmount = String.valueOf(question.question.Payment_Custom_Amount__c.format());
                        }
                        if (paymentAmount.equals('0.00')) {
                            configurationMessage = 'Custom amount is not set on question:  ' + question.question.Id;
                        }
                    }
                    parameterMap.put('AMT', paymentAmount);

                    String exTransId = app.Contact__r.FirstName + ' ' + app.Contact__r.LastName + ' | ' + app.Name + ' | ' + question.question.Id;

                    if (String.isNotBlank(gatewayInfo.UPay_Site_Id__c)) {
                        parameterMap.put('UPAY_SITE_ID', gatewayInfo.UPay_Site_Id__c);
                    }

                    parameterMap.put('EXT_TRANS_ID', exTransId);

                    if (String.isNotBlank(gatewayInfo.Validation_Key__c)) {
                        String valCode = gatewayInfo.Validation_Key__c;
                        // EXT_TRANS_ID passed from payment form and can be used to track in our business office
                        valCode += exTransId;//ac.appInfo.appId;

                        // Amount passed from VF payment form to set amout requested.
                        valCode += paymentAmount;

                        //All the above in one string, MD5 hashed, converted to base64 string. Checked at gateway for access to the uPay site
                        Blob requestBlob = Blob.valueOf(valCode);
                        Blob hash = Crypto.generateDigest('MD5', requestBlob);
                        valCode = EncodingUtil.base64Encode(hash);
                        parameterMap.put('VALIDATION_KEY', valCode);
                    }


                    parameterMap.put('EXT_TRANS_ID_LABEL', 'AppId');
                    parameterMap.put('BILL_NAME', app.Contact__r.FirstName + ' ' + app.Contact__r.LastName);
                    parameterMap.put('BILL_EMAIL_ADDRESS', app.Contact__r.Email);
                    parameterMap.put('BILL_STREET1', app.Contact__r.MailingStreet);
                    parameterMap.put('BILL_STATE', app.Contact__r.MailingState);
                    parameterMap.put('BILL_POSTAL_CODE', app.Contact__r.MailingPostalCode);

                    parameterMap.put('ERROR_LINK', currentUrl);
                    parameterMap.put('CANCEL_LINK', currentUrl);
                    parameterMap.put('CANCEL_LINK_TEXT', 'Cancel Deposit');
                    parameterMap.put('SUCCESS_LINK', currentUrl);

                    parameterString = JSON.serialize(parameterMap);
                }
            }
        }
        return parameterString;

    }


}