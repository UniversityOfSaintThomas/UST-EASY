/*******************************************************************************
@description This class is a set of helpful utility methods
@author Huron Consulting Group
*******************************************************************************/
public class ApplicationUtilities {

    public static EASYApplicationInfo setApplicationInfo(Application_Control__c appControl, Application__c app) {
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo = flattenAppControl(appControl, appInfo);
        appInfo.isExternalUser = isExternalUser();
        appInfo.allowSubmit = false;
        appInfo.requirementId = null;
        appInfo.appId = app.Id;
        appInfo.contactId = app.Contact__c;
        appInfo.appStatus = app.Application_Status__c;
        appInfo.appSubStatus = app.Application_Substatus__c;
        appInfo.citizenship = app.Citizenship__c;
        appInfo.intendedProgram = app.Intended_Program__r.Program_Name_on_Application__c;
        appInfo.intendedTerm = app.Intended_Term_of_Entry__r.Name;
        return appInfo;
    }

    public static EASYApplicationInfo setApplicationInfo(EASYApplicationInfo appInfo, Application__c app) {
        appInfo.isExternalUser = isExternalUser();
        appInfo.allowSubmit = false;
        appInfo.requirementId = null;
        appInfo.appId = app.Id;
        appInfo.contactId = app.Contact__c;
        appInfo.appStatus = app.Application_Status__c;
        appInfo.appSubStatus = app.Application_Substatus__c;
        appInfo.citizenship = app.Citizenship__c;
        appInfo.intendedProgram = app.Intended_Program__r.Program_Name_on_Application__c;
        appInfo.intendedTerm = app.Intended_Term_of_Entry__r.Name;
        return appInfo;
    }

    public static EASYApplicationInfo flattenAppControl(Application_Control__c appControl, EASYApplicationInfo appInfo) {
        appInfo.hideTermProgram = appControl.Hide_Term_Program__c;
        appInfo.allowWithdrawFrom = appControl.Allow_Withdraw_From__c;
        appInfo.allowSubmitFrom = appControl.Allow_Submit_From__c;
        appInfo.submitStatus = appControl.Submit_Status__c;
        appInfo.withdrawStatus = appControl.Withdraw_Status__c;
        appInfo.academicLevel = appControl.Academic_Level__c;
        appInfo.schoolCollege = appControl.School_College__c;
        appInfo.appControlId = appControl.Id;
        appInfo.template = appControl.Template__c;
        appInfo.at = appControl.URL_Parameter__c;
        appInfo.appStartStatus = appControl.Application_Start_Status__c;
        appInfo.allowCancelFrom = appControl.Allow_Cancel_From__c;
        return appInfo;
    }

    public static EASYApplicationInfo createShellAppInfo() {
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        Application_Control__c appControl = getApplicationControls(ApexPages.currentPage().getParameters().get('at'));
        appInfo = flattenAppControl(appControl, appInfo);
        appInfo.contactId = ApplicationUtilities.getAppContactId();
        appInfo.isExternalUser = ApplicationUtilities.isExternalUser();
        appInfo.allowSubmit = false;
        if (String.isBlank(appControl.Template__c)) {
            Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
            appInfo.template = AppSettings.Default_Template__c;
        }
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
        String userType = UserInfo.getUserType();

        // Get and decrypt cookie if it exist
        String testDecrypt = getDecryptCookie();
        if (String.isNotBlank(testDecrypt)) {
            try {
                appInfo = (EASYApplicationInfo) JSON.deserialize(testDecrypt, EASYApplicationInfo.class);
            } catch (Exception e) {
                appInfo = new EASYApplicationInfo();
            }
        }

        //Check to see if the logged in (or url contact Id for standard user) equals the decrypted Id.
        Id requestedContact = getAppContactId();

        if (appInfo.contactId != requestedContact) {
            //If contactId from cookie doesn't match user contact id reset
            appInfo = new EASYApplicationInfo();
            appInfo.contactId = requestedContact;
        }

        if (userType.equalsIgnoreCase('standard')) {
            try {
                appInfo.at = ApexPages.currentPage().getParameters().get('at');
            } catch (Exception ex) {

            }
            if (String.isNotBlank(appInfo.at)) {
                Application_Control__c appControl = getApplicationControls(appInfo.at);
                appInfo = flattenAppControl(appControl, appInfo);
            }
            if (String.isBlank(appInfo.requirementId) && String.isNotBlank(ApexPages.currentPage().getParameters().get('requirementId'))) {
                appInfo.requirementId = ApexPages.currentPage().getParameters().get('requirementId');
            }
        }

        appInfo.isExternalUser = isExternalUser();

        if (String.isBlank(appInfo.appId) && String.isBlank(appInfo.at) && String.isNotBlank(appInfo.contactId)) {
            //If we've arrived with no cookie or parameters; Get last updated application
            List<Application__c> lastApps = [
                    SELECT Id, Application_Control__r.URL_Parameter__c, LastModifiedDate, Contact__c,
                            Application_Control__r.Id, Application_Status__c, Application_Substatus__c, Citizenship__c,
                            Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name
                    FROM Application__c
                    WHERE Contact__c = :appInfo.contactId
                    ORDER BY LastModifiedDate
            ];
            if (lastApps.size() > 0) {
                Application_Control__c appControl = getApplicationControls(lastApps[0].Application_Control__r.URL_Parameter__c);
                Application__c app = lastApps[0];
                appInfo = setApplicationInfo(appControl, app);
            }
        }

        if (String.isBlank(appInfo.template)) {
            Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
            appInfo.template = AppSettings.Default_Template__c;
        }

        return appInfo;

    }

    public static Application__c getApplicationInfo(Id appId, Id ContactId) {
        Application__c currentApp = null;
        try {
            currentApp = [
                    SELECT Id, Application_Control__r.URL_Parameter__c, Application_Control__r.Id, Application_Status__c, Application_Substatus__c, Citizenship__c,
                            Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name, Contact__c
                    FROM Application__c
                    WHERE Id = :appId
                    AND Contact__c = :contactId
                    ORDER BY LastModifiedDate
            ];
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        return currentApp;
    }


    public static Id getAppContactId() {
        Id contactId = null;

        if (String.isNotBlank(UserInfo.getUserType())) {
            String userType = UserInfo.getUserType();
            if (userType.equalsIgnoreCase('standard')) {
                //Standard users can pass contact Id through URL
                try {
                    contactId = ApexPages.currentPage().getParameters().get('contactId');
                } catch (Exception e) {

                }

            } else {
                // Everyone else gets contact through user record
                try {
                    contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
                } catch (Exception ex) {

                }
            }
        }
        return contactId;
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
            Cookie EASYCookie = new Cookie('EASY_INFO', encodedCipherText, null, -1, true, 'strict');
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