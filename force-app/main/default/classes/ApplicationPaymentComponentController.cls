/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/4/2022.
 */


public with sharing class ApplicationPaymentComponentController {
    public Map<String, String> parameterMap { get; set; }
    public EASYApplicationInfo appInfoParam { get; set; }
    public ApplicationQuestion question { get; set; }
    public String paymentAmount { get; set; }
    public String configurationMessage { get; set; }
    public String gatewayURL { get; set; }

    public ApplicationPaymentComponentController() {
    }

    public String getFormParameters() {
        String parameterString = '';
        parameterMap = new Map<String, String>();

        if (appInfoParam != null) {
            if (String.isNotBlank(appInfoParam.appId)) {

                //Get current URL for return from touchnet

                Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
                String currentUrl = AppSettings.Community_URL__c;
                if (!currentUrl.endsWith('/')) {
                    currentUrl += '/';
                }
                currentUrl += 'ApplicationRequirement?at=' + appInfoParam.at + '&requirementId=' + appInfoParam.requirementId;

                if (!currentUrl.startsWith('http')) {
                    currentUrl = 'https://' + currentUrl;
                }

                //Get application for details to add to ticket
                Application__c app = [
                        SELECT Id, Name, Contact__r.FirstName, Contact__r.LastName,
                                Contact__r.Email,
                                Intended_Program__r.Application_Fee_Amount__c,
                                Intended_Program__c,
                                Contact__r.MailingStreet,
                                Contact__r.MailingCountry,
                                Contact__r.MailingState,
                                Contact__r.MailingPostalCode,
                                Application_Control__r.URL_Parameter__c,
                                Intended_Term_of_Entry__r.Term__r.Name
                        FROM Application__c
                        WHERE Id = :appInfoParam.appId
                ];

                if (String.isNotBlank(question.question.Payment_Gateway__c)) {

                    //Get custom metadata for requested payment gateway (added to picklist on question)
                    List<Application_Payment_Gateway__mdt> gatewayInfo = [
                            SELECT Id, Label, DeveloperName, UPay_Site_Id__c, Validation_Key__c, Gateway_URL__c
                            FROM Application_Payment_Gateway__mdt
                            WHERE DeveloperName = :question.question.Payment_Gateway__c
                    ];

                    if (gatewayInfo.size() > 0) {
                        //Set the payment amount by program or custom
                        String paymentType = question.question.Payment_Type__c;
                        gatewayURL = gatewayInfo[0].Gateway_URL__c;
                        paymentAmount = '0.00';
                        if (paymentType.equalsIgnoreCase('Program Application Fee Amount')) {
                            if (app.Intended_Program__r.Application_Fee_Amount__c != null) {
                                paymentAmount = String.valueOf(app.Intended_Program__r.Application_Fee_Amount__c.format());
                            }
                            if (paymentAmount.equals('0.00')) {
                                String protectedIds = ApplicationUtilities.createEncryptedString('{"appId":"' + app.Id + '","responseId":"' + question.reqResponse.Id + '","questionId":"' + question.question.Id + '"}'); configurationMessage = 'Program Application Fee is not set program: ' + app.Intended_Program__c;
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
                        String billName = app.Contact__r.FirstName;
                        billName += ' ' + app.Contact__r.LastName;
                        billName = billName.escapeHtml4();

                        String exTransId = billName + ' | ' + app.Name + ' | ' + app.Intended_Term_of_Entry__r.Term__r.Name;
                        if (String.isNotBlank(question.question.Payment_Name__c)) {
                            exTransId = exTransId + ' | ' + question.question.Payment_Name__c;
                        }

                        if (String.isNotBlank(gatewayInfo[0].UPay_Site_Id__c)) {
                            parameterMap.put('UPAY_SITE_ID', gatewayInfo[0].UPay_Site_Id__c);
                        }

                        parameterMap.put('EXT_TRANS_ID', exTransId);

                        if (String.isNotBlank(gatewayInfo[0].Validation_Key__c)) {
                            String valCode = gatewayInfo[0].Validation_Key__c;
                            // EXT_TRANS_ID passed from payment form and can be used to track in our business office
                            valCode += exTransId;//ac.appInfo.appId;

                            // Amount passed from VF payment form to set amount requested.
                            valCode += paymentAmount;

                            //All the above in one string, MD5 hashed, converted to base64 string. Checked at gateway for access to the uPay site
                            Blob requestBlob = Blob.valueOf(valCode);
                            Blob hash = Crypto.generateDigest('MD5', requestBlob);
                            valCode = EncodingUtil.base64Encode(hash);
                            parameterMap.put('VALIDATION_KEY', valCode);
                        }

                        String protectedIds = ApplicationUtilities.createEncryptedString('{"appId":"' + app.Id + '","responseId":"' + question.reqResponse.Id + '","questionId":"' + question.question.Id + '"}');
                        parameterMap.put('EASY_APP', protectedIds);
                        parameterMap.put('EXT_TRANS_ID_LABEL', 'University of St. Thomas Application');
                        parameterMap.put('BILL_NAME', billName);
                        parameterMap.put('BILL_EMAIL_ADDRESS', app.Contact__r.Email);
                        parameterMap.put('BILL_STREET1', app.Contact__r.MailingStreet);
                        parameterMap.put('BILL_STATE', app.Contact__r.MailingState);
                        parameterMap.put('BILL_POSTAL_CODE', app.Contact__r.MailingPostalCode);
                        parameterMap.put('ERROR_LINK', currentUrl);
                        parameterMap.put('CANCEL_LINK', currentUrl);
                        parameterMap.put('CANCEL_LINK_TEXT', 'Cancel Deposit');
                        parameterMap.put('SUCCESS_LINK', currentUrl);

                        parameterString = JSON.serialize(parameterMap);
                    } else {
                        configurationMessage = 'Payment custom metadata settings could not be found.';
                    }
                } else {
                    configurationMessage = 'Payment gateway settings have not been configured in settings.';
                }
            }
        }
        return parameterString;

    }


}