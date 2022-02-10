/*******************************************************************************
@description This class is a set of helpful utility methods
@author Huron Consulting Group
*******************************************************************************/
public class ApplicationUtilities {
    
    /* ******************************************************************************
    * @description Returns the application control based on urlParameter or the default one if no param is found.
    ********************************************************************************/
    public static Application_Control__c getApplicationControls(String param) {
        
        Application_Control__c appControl;
        Application_Control__c defaultControl;
        
        if (String.isBlank(param)) {
            param = '';
        }
        
        try {
            Id acId = Id.valueOf(param);
            return [SELECT Id, Hide_Term_Program__c, Application_Start_Status__c, Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c, Arrow_Color__c, Button_Color__c, Button_Text_Color__c, Cancel_Status__c, Line_Color__c, Link_Color__c, Logo_Static_Resource__c, Logo_Static_Resource_Path__c, Submit_Status__c, Withdraw_Status__c, Text_Color__c, URL_Parameter__c, Default__c, Academic_Level__c, School_College__c, Degree_Levels__c FROM Application_Control__c WHERE Id = :acId];
        } catch (Exception e) {}
        
        for (Application_Control__c ac:[SELECT Id, Hide_Term_Program__c, Application_Start_Status__c, Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c, Arrow_Color__c, Button_Color__c, Button_Text_Color__c, Cancel_Status__c, Line_Color__c, Link_Color__c, Logo_Static_Resource__c, Logo_Static_Resource_Path__c, Submit_Status__c, Withdraw_Status__c, Text_Color__c, URL_Parameter__c, Default__c, Academic_Level__c, School_College__c, Degree_Levels__c FROM Application_Control__c WHERE Active__c = :true AND (URL_Parameter__c = :param OR Default__c = :true)]) {
            if (ac.Default__c) {
                defaultControl = ac;
            } else if (ac.URL_Parameter__c.equals(param)) {
                appControl = ac;
            }
        }
        
        return appControl == null ? defaultControl : appControl;
    }
    
    public static Boolean containsValue(String multiPicklistValue, String value) {
        return String.isNotBlank(multiPicklistValue) && (new Set<String>(multiPicklistValue.split(';'))).contains(value);
    }
    
    public class AdditionalDataWrapper {
        Map<String, Map<String,Object>> additionalData;
    }

    public String createEncryptedCookie(String audience, String instanceId, String eventId, String registrationId) {

        //Check everything to not let nulls through to JSON string
        audience = (String.isNotBlank(audience) && !audience.equalsIgnoreCase('null')) ? audience : '';
        instanceId = (String.isNotBlank(instanceId) && !instanceId.equalsIgnoreCase('null')) ? instanceId : '';
        eventId = (String.isNotBlank(eventId) && !eventId.equalsIgnoreCase('null')) ? eventId : '';
        registrationId = (String.isNotBlank(registrationId) && !registrationId.equalsIgnoreCase('null')) ? registrationId : '';
        String CookieValue = '{"audience":"' + audience + '","instanceId":"' + instanceId + '","eventId":"' + eventId + '","registrationId":"' + registrationId + '","dt":"' + String.valueOf(Datetime.now()) + '"}';
        String encodedCipherText = '';
        String key = getCookieKey();
        if (String.isNotBlank(String.valueOf(key))) {
            Blob data = Blob.valueOf(CookieValue);
            Blob encrypted = Crypto.encryptWithManagedIV('AES256', Blob.valueOf(key), data);
            encodedCipherText = EncodingUtil.base64Encode(encrypted);
            encodedCipherText = EncodingUtil.urlEncode(encodedCipherText, 'UTF-8');
            Cookie SummitEventsCookie = new Cookie('SummitEvents', encodedCipherText, null, -1, false);
            ApexPages.currentPage().setCookies(new Cookie[]{
                    SummitEventsCookie
            });
        }
        return encodedCipherText;
    }

    public String getDecryptCookie() {
        String CookieName = 'SummitEvents';
        Cookie encodedCipherText = ApexPages.currentPage().getCookies().get(CookieName);
        if (encodedCipherText != null) {
            return decryptString(encodedCipherText.getValue(), true);
        }
        return '';
    }

    public String decryptString(String encryptedString, Boolean urlDecodeString) {
        String key = getCookieKey();
        if (String.isNotBlank(encryptedString) && String.isNotBlank(String.valueOf(key))) {
            if (urlDecodeString) {
                encryptedString = EncodingUtil.urlDecode(encryptedString, 'UTF-8');
            }
            try {
                Blob decrypted = Crypto.decryptWithManagedIV(
                        'AES256',
                        Blob.valueOf(key),
                        EncodingUtil.base64Decode(encryptedString)
                );
                return decrypted.toString();
            } catch (Exception e) {
                return '';
            }
        }
        return '';
    }

    public String getCookieKey() {
        String key = '';
        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        if (String.isNotBlank(AppSettings.Cookie_Encryption_Key__c)) {
            key = AppSettings.Cookie_Encryption_Key__c;
        }
        return key;
    }

    private without sharing class crudToDo {
        public void setCookieKey() {
            Application_Setting__c SummitEventsSettings = Application_Setting__c.getOrgDefaults();
            if (String.isBlank(SummitEventsSettings.Cookie_Encryption_Key__c)) {
                Blob cryptoKey = Crypto.generateAesKey(256);
                String encryptionString = EncodingUtil.base64Encode(cryptoKey).substring(0, 32);
                SummitEventsSettings.Cookie_Encryption_Key__c = encryptionString;
                update SummitEventsSettings;
            }
        }
    }

    public String getTemplate(String templateName) {
        List<String> namespaceTemplate = new List<String>{
                'GeneralSLDS',
                'crowncollege2020',
                'OPUSTemplate2018',
                'CastorTemplate2017'
        };
        if (String.isNotBlank(templateName)) {
            if (!namespaceTemplate.contains(templateName)) {
                templateName = 'c__' + templateName;
            }
        } else {
            templateName = 'GeneralSLDS';
        }
        return templateName;
    }


    // Custom exception class for validation
    public class ApplicationException extends Exception {
        
        public Boolean doRollback = false;
        public Boolean isError = true;

        
        public ApplicationException(String e, Boolean doRollback) {
            this(e);
            this.doRollback = doRollback;
        }
        
        public ApplicationException(String e, Boolean doRollback, Boolean isError) {
            this(e, doRollback);
            this.isError = isError;
        }
    }

    public static String getUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }
}