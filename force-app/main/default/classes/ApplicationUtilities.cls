/*******************************************************************************
@description This class is a set of helpful utility methods
@author Huron Consulting Group
*******************************************************************************/
public class ApplicationUtilities {

    //Checks passed URL parameters with those in encrypted cookie. Uses URL if different.
    public static String compareToCookie(String urlParameter, String cookieIdString, Boolean typeToId) {
        Id urlId = null;
        Id cookieId = null;
        String urlString = '';
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get(urlParameter))) {
            if (typeToId) {

                try {
                    urlId = (Id) ApexPages.currentPage().getParameters().get(urlParameter);
                    urlString = String.valueOf(urlId);
                } catch (Exception ex) {
                    urlString = '';
                }

                try {
                    cookieId = (Id) cookieIdString;
                    cookieIdString = String.valueOf(cookieId);
                } catch (Exception ex) {
                    cookieIdString = '';
                }

            } else {
                urlString = ApexPages.currentPage().getParameters().get(urlParameter);
            }
        }
        if (urlString != cookieIdString && String.isNotBlank(urlString)) {
            return urlString;
        }
        return cookieIdString;
    }

    public static EASYApplicationInfo setApplicationInfo(Application_Control__c appControl, Application__c app) {
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appControl = appControl;
        appInfo.contactId = app.Contact__c;
        appInfo.appControlId = appControl.Id;
        appInfo.at = appControl.URL_Parameter__c;
        appInfo.appId = app.Id;
        appInfo.isExternalUser = isExternalUser();
        appInfo.allowSubmit = true;
        appInfo.requirementId = null;
        return appInfo;
    }

    public static Boolean isExternalUser() {
        // Is external may be guest user like recommender
        if (!UserInfo.getUserType().equals('Standard') && String.isNotBlank(ApexPages.currentPage().getParameters().get('h')) && String.isNotBlank(ApexPages.currentPage().getParameters().get('r'))) {
            return false;
        }
        return true;
    }

    public static EASYApplicationInfo gatherApplicationInfo() {
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appControl = new Application_Control__c();
        EASYApplicationInfo oldInfo = new EASYApplicationInfo();

        // Get and decrypt cookie if it exist
        String testDecrypt = getDecryptCookie();
        if (String.isNotBlank(testDecrypt)) {
            try {
                appInfo = (EASYApplicationInfo) JSON.deserialize(testDecrypt, EASYApplicationInfo.class);
                oldInfo = appInfo;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        // Get application Id from URL and check against cookie Id
        appInfo.appId = compareToCookie('applicationId', appInfo.appId, true);

        // Get requirement Id from URL anc check against cookie Id
        appInfo.requirementId = compareToCookie('requirementId', appInfo.requirementId, true);

        // Get application type from URL and check against cookie Id
        appInfo.at = compareToCookie('at', appInfo.at, false);

        // Contact Id of Applicant
        if (String.isNotBlank(UserInfo.getUserType())) {
            try {
                appInfo.contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
            } catch (Exception ex) {

            }
        }
        appInfo.contactId = compareToCookie('contactId', appInfo.contactId, true);

        //if(oldInfo.at != appInfo.at || oldInfo.contactId != appInfo.contactId || String.isBlank(appInfo.at) || String.isBlank(appInfo.contactId) ) {
        // if Application type is blank than get it from appId
        if (String.isNotBlank(appInfo.appId)) {
            //Get the application type from the application id
            Application__c currentApp = [
                    SELECT Id, Application_Control__r.URL_Parameter__c, Application_Control__r.Id
                    FROM Application__c
                    WHERE Id = :appInfo.appId
            ];
            appInfo.at = currentApp.Application_Control__r.URL_Parameter__c;
            appInfo.appControlId = currentApp.Application_Control__r.Id;
        }


        if (String.isBlank(appInfo.appControlId)) {
            appInfo.appControl = getApplicationControls(appInfo.appControlId);
        }

        if (String.isNotBlank(appInfo.at) && String.isBlank(appInfo.appControlId)) {
            if (appInfo.appControl == null) {
                appInfo.appControl = getApplicationControls(appInfo.at);
            }
            appInfo.appControlId = appInfo.appControl.Id;
        }

        if (!String.isBlank(appInfo.appControl.Template__c)) {
            appInfo.template = appInfo.appControl.Template__c;
        } else {
            Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
            appInfo.template = AppSettings.Default_Template__c;
        }

        // Is user an external user
        appInfo.isExternalUser = isExternalUser();

        // Is user allowed to submit
        appInfo.allowSubmit = true;

        if (oldInfo != appInfo) {
            createEncryptedCookie(JSON.serialize(appInfo));
        }

        return appInfo;
    }

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
            return [
                    SELECT Id, Hide_Term_Program__c, Application_Start_Status__c, Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c,
                            Arrow_Color__c, Button_Color__c, Button_Text_Color__c, Cancel_Status__c, Line_Color__c, Link_Color__c, Logo_Static_Resource__c,
                            Logo_Static_Resource_Path__c, Submit_Status__c, Withdraw_Status__c, Text_Color__c, URL_Parameter__c, Default__c, Academic_Level__c,
                            School_College__c, Degree_Levels__c, Template__c
                    FROM Application_Control__c
                    WHERE Id = :acId
            ];
        } catch (Exception e) {
        }

        for (Application_Control__c ac : [
                SELECT Id, Hide_Term_Program__c, Application_Start_Status__c, Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c, Arrow_Color__c,
                        Button_Color__c, Button_Text_Color__c, Cancel_Status__c, Line_Color__c, Link_Color__c, Logo_Static_Resource__c, Logo_Static_Resource_Path__c,
                        Submit_Status__c, Withdraw_Status__c, Text_Color__c, URL_Parameter__c, Default__c, Academic_Level__c, School_College__c, Degree_Levels__c,
                        Template__c
                FROM Application_Control__c
                WHERE Active__c = TRUE
                AND (URL_Parameter__c = :param OR Default__c = TRUE)
        ]) {
            if (ac.Default__c) {
                defaultControl = ac;
            } else if (ac.URL_Parameter__c.equals(param)) {
                appControl = ac;
            }
        }

        //System.debug('app control: ' + appControl);

        return appControl == null ? defaultControl : appControl;
    }


    public static Boolean containsValue(String multiPicklistValue, String value) {
        return String.isNotBlank(multiPicklistValue) && (new Set<String>(multiPicklistValue.split(';'))).contains(value);
    }

    public class AdditionalDataWrapper {
        Map<String, Map<String, Object>> additionalData;
    }


    public static String createEncryptedCookie(String stringToEncrypt) {
        String encodedCipherText = '';
        String key = getCookieKey();
        if (String.isNotBlank(String.valueOf(key))) {
            Blob data = Blob.valueOf(stringToEncrypt);
            Blob encrypted = Crypto.encryptWithManagedIV('AES256', Blob.valueOf(key), data);
            encodedCipherText = EncodingUtil.base64Encode(encrypted);
            encodedCipherText = EncodingUtil.urlEncode(encodedCipherText, 'UTF-8');
            Cookie EASYCookie = new Cookie('EASY_INFO', encodedCipherText, null, -1, false);
            ApexPages.currentPage().setCookies(new Cookie[]{
                    EASYCookie
            });
        }
        return encodedCipherText;
    }

    public static String getDecryptCookie() {
        String CookieName = 'EASY_INFO';
        Cookie encodedCipherText = ApexPages.currentPage().getCookies().get(CookieName);
        if (encodedCipherText != null) {
            return decryptString(encodedCipherText.getValue(), true);
        }
        return '';
    }

    public static String decryptString(String encryptedString, Boolean urlDecodeString) {
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

    public static Boolean cookieKeyPresent() {
        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        if (String.isNotBlank(AppSettings.Cookie_Encryption_Key__c)) {
            return true;
        }
        return false;
    }

    public static String getCookieKey() {
        String key = '';
        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        if (String.isNotBlank(AppSettings.Cookie_Encryption_Key__c)) {
            key = AppSettings.Cookie_Encryption_Key__c;
        } else {
            crudToDo doCRUD = new crudToDo();
            key = doCRUD.setCookieKey();
        }
        return key;
    }

    private without sharing class crudToDo {
        public String setCookieKey() {
            String encryptionString = '';
            Application_Setting__c SummitEventsSettings = Application_Setting__c.getOrgDefaults();
            if (String.isBlank(SummitEventsSettings.Cookie_Encryption_Key__c)) {
                Blob cryptoKey = Crypto.generateAesKey(256);
                encryptionString = EncodingUtil.base64Encode(cryptoKey).substring(0, 32);
                SummitEventsSettings.Cookie_Encryption_Key__c = encryptionString;
                try {
                    update SummitEventsSettings;
                } catch (DmlException ex) {

                }
            }
            return encryptionString;
        }

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
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        String guid = h.substring(0, 8) + '-' + h.substring(8, 12) + '-' + h.substring(12, 16) + '-' + h.substring(16, 20) + '-' + h.substring(20);
        return guid;
    }
}