/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 9/29/2022.
 */

@RestResource(urlMapping='/applicaitonpaymentreceive/*')
global with sharing class ApplicationPaymentRest {

    private static Map<String, String> parameters { get; set; }

    @HttpPost
    global static String receiptDeposit() {
        RestRequest req = RestContext.request;

        if (req.requestBody.size() > 0) {

            String contentBody = EncodingUtil.base64Decode(EncodingUtil.base64Encode(req.requestBody)).toString();
            parameters = (Map<String, String>) JSON.deserialize(contentBody, Map<String, String>.class);

            //Debug all passed values
            for (String key : parameters.keySet()) {
                System.debug(key + ' : ' + parameters.get(key));
            }

            if (parameters.containsKey('pmt_status')) {
                if (String.isNotBlank(parameters.get('pmt_status'))) {

                    //TouchNet returns success, not sure if would every return anything else.
                    if (parameters.get('pmt_status').equalsIgnoreCase('success')) {

                        //EASY_APP is a encrypted string and needs to be decrypted and Ids confirmed
                        String protectedIds = evaluateResponse('EASY_APP');
                        Id appId = null;
                        Id responseId = null;
                        Id questionId = null;
                        if (String.isNotBlank(protectedIds)) {
                            protectedIds = ApplicationUtilities.decryptString(protectedIds, true);
                            Map<String, String> appIds = (Map<String, String>) JSON.deserialize(protectedIds, Map<String, String>.class);
                            appId = evaluateIdResponse(appIds.get('appId'));
                            responseId = evaluateIdResponse(appIds.get('responseId'));
                            questionId = evaluateIdResponse(appIds.get('questionId'));
                        }

                        crudToDo crudToDo = new crudToDo();
                        Question_Response__c questionResponse = new Question_Response__c();
                        if (responseId != null && appId != null) {
                            //create a question response
                            questionResponse.ValueText__c = 'Deposit successfully received on ' + parameters.get('pmt_date') + ' for $' + parameters.get('pmt_amt') + '.';
                            questionResponse.Requirement_Response__c = responseId;
                            questionResponse.Question__c = questionId;
                            questionResponse.Application__c = appId;
                            questionResponse.PopulatedOn__c = evaluateDateResponse('pmt_date');
                            questionResponse.ValueCurrency__c = evaluateDecimalResponse('pmt_amt');
                            questionResponse.ValueCheckbox__c = true;
                            questionResponse = crudToDo.saveQuestionResponse(questionResponse);
                        }

                        Requirement_Response__c currentResponse = new Requirement_Response__c();
                        currentResponse.Id = responseId;
                        currentResponse.Viewed__c = true;
                        currentResponse.Status__c = 'Received';
                        crudToDo.updateRequirementResponse(currentResponse);

                        //Create a new payment object
                        Application_Payment__c payment = new Application_Payment__c();

                        //Ids from encrypted string above
                        payment.Admissions_Application__c = appId;
                        payment.Question__c = questionId;
                        payment.Requirement_Response__c = responseId;

                        //acct_addr : 123 Electric Ave
                        payment.Address_1__c = evaluateResponse('acct_addr');
                        payment.Address_2__c = evaluateResponse('acct_addr2');
                        //acct_city : Minneapolis
                        payment.City__c = evaluateResponse('acct_city');
                        //acct_state : ID
                        payment.State__c = evaluateResponse('acct_state');
                        //acct_zip : 55418
                        payment.Zip__c = evaluateResponse('acct_zip');
                        //acct_country : US
                        payment.Country__c = evaluateResponse('acct_country');
                        //acct_email_address : thad@valleyhill.net
                        payment.Payment_Email_Address__c = evaluateResponse('acct_email_address');
                        //acct_phone_day : +1 555-555-5555
                        payment.Phone__c = evaluateResponse('acct_phone_day');
                        //BILL_EMAIL_ADDRESS : thad@valleyhill.net"
                        payment.Email_Address__c = evaluateResponse('BILL_EMAIL_ADDRESS');
                        //BILL_NAME : Thad Dahlberg
                        payment.Name_On_Account__c = evaluateResponse('BILL_NAME');
                        //card_type : Visa
                        payment.Card_Type__c = evaluateResponse('card_type');
                        //name_on_acct : Thad Dahlberg
                        payment.Name_On_Account__c = evaluateResponse('name_on_acct');
                        //pmt_amt : 123.45
                        payment.Payment_Amount__c = evaluateDecimalResponse('pmt_amt');
                        //pmt_date : 10/21/2022
                        payment.Payment_Received_Date__c = evaluateDateResponse('pmt_date');
                        //sys_tracking_id : 2075
                        payment.Gateway_Session_Identifier__c = evaluateResponse('sys_tracking_id');
                        //tpg_trans_id : 20221021000008
                        payment.TouchnetReceiptNumber__c = evaluateResponse('tpg_trans_id');
                        //UPAY_SITE_ID : 2
                        payment.Method_of_Payment__c = 'Credit Card';
                        //EXT_TRANS_ID : Johnny Applicant | A-0122222 | Fall 2023
                        payment.TouchNet_Ext_Trans_Id__c = evaluateResponse('EXT_TRANS_ID');
                        payment.Payment_Status__c = 'Received';

                        if (crudToDo.savePayment(payment)) {
                            return 'HTTP_OK';
                        } else {
                            return 'HTTP_ERROR';
                        }
                    }
                }
            }
        }
        return 'HTTP_ERROR';
    }

    private static Date evaluateDateResponse(String key) {
        Date d = null;
        String value = evaluateResponse(key);
        if (String.isNotBlank(value)) {
            try {
                d = Date.parse(value);
            } catch (TypeException e) {
            }
        }
        return d;
    }

    private static Id evaluateIdResponse(String value) {
        Id d = null;
        if (String.isNotBlank(value)) {
            try {
                d = (Id) value;
            } catch (Exception e) {
            }
        }
        return d;
    }

    private static Decimal evaluateDecimalResponse(String key) {
        Decimal d = 0.0;
        String value = evaluateResponse(key);
        if (String.isNotBlank(value)) {
            try {
                d = Decimal.valueOf(value);
            } catch (TypeException e) {
            }
        }
        return d;
    }

    private static String evaluateResponse(String key) {
        if (parameters.containsKey(key)) {
            if (String.isNotBlank(parameters.get(key))) {
                return parameters.get(key);
            }
        }
        return '';
    }

    private without sharing class crudToDo {
        public Boolean savePayment(Application_Payment__c payment) {
            try {
                insert payment;
            } catch (Exception e) {
                return false;
            }
            return true;
        }
        public Question_Response__c saveQuestionResponse(Question_Response__c qr) {
            try {
                insert qr;
            } catch (Exception e) {
                return new Question_Response__c();
            }
            return qr;
        }
        public Boolean updateRequirementResponse(Requirement_Response__c rr) {
            try {
                update rr;
            } catch (Exception e) {
                return false;
            }
            return true;
        }

    }

}