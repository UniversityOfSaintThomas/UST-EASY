/*******************************************************************************
@description This class is a set of helpful utility methods
@author Huron Consulting Group
*******************************************************************************/
public class ApplicationUtilities {

    public static Id checkUpdateIds(String urlParameter, Id cookieId) {
        Id urlId = null;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get(urlParameter))) {
            try {
                urlId = (Id) ApexPages.currentPage().getParameters().get(urlParameter);
            } catch (Exception ex) {

            }
        }
        if (urlId != null && urlId != cookieId) {
            return urlId;
        }
        return cookieId;
    }

    public static EasyApplicationInfo setApplicationInfo(Application_Control__c appControl, Application__c app) {
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appControl = appControl;
        appInfo.contactId = app.Contact__c;
        appInfo.appControlId = appControl.Id;
        appInfo.at = appControl.URL_Parameter__c;
        appInfo.appId = app.Id;
        appInfo.isExternalUser = isExternalUser();
        appInfo.allowSubmit = true;
        appInfo.nextRequirement = null;
        appInfo.prevRequirement = null;
        appInfo.requirementId = null;
        return appInfo;
    }

    public static Boolean isExternalUser() {
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('h')) && String.isNotBlank(ApexPages.currentPage().getParameters().get('r'))) {
            return true;
        }
        return false;
    }

    public static EASYApplicationInfo getApplicationInfo() {
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        appInfo.appControl = new Application_Control__c();

        // Get and decrypt cookie if it exist
        String testDecrypt = getDecryptCookie();
        if (String.isNotBlank(testDecrypt)) {
            try {
                appInfo = (EASYApplicationInfo) JSON.deserialize(testDecrypt, EASYApplicationInfo.class);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        // Get application Id from URL and check against cookie Id
        appInfo.appId = checkUpdateIds('applicationId', appInfo.appId);

        // Get requirement Id from URL anc check against cookie Id
        appInfo.requirementId = checkUpdateIds('requirementId', appInfo.requirementId);

        // Contact Id of Applicant
        if (UserInfo.getUserType().equals('Standard') || UserInfo.getUserType().equals('CspLitePortal')) {
            try {
                appInfo.contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
            } catch (Exception ex) {

            }
        } else {
            appInfo.contactId = checkUpdateIds('contactId', appInfo.contactId);
        }

        // Get application type from URL and check against cookie Id
        appInfo.at = checkUpdateIds('at', appInfo.requirementId);

        // if Application type is blank than get it from appId
        if (String.isBlank(appInfo.at) && String.isNotBlank(appInfo.appId)) {
            //Get the application type from the application id
            Application__c currentApp = [
                    SELECT Id, Application_Control__r.URL_Parameter__c
                    FROM Application__c
                    WHERE Id = :appInfo.appId
            ];
            appInfo.at = currentApp.Application_Control__r.URL_Parameter__c;
        }

        //Get application control from application type
        if (String.isNotBlank(appInfo.at)) {
            appInfo.appControl = getApplicationControls(appInfo.at);
            appInfo.appControlId = appInfo.appControl.Id;
        }

        //Get a list of requirement ids
        List<Id> reqsIds = getRequirementIds(appInfo.appControlId);
        if (String.isBlank(appInfo.requirementId) && reqsIds.size() > 0) {
            appInfo.requirementId = reqsIds[0];
        }

        if (reqsIds.size() > 0) {
            Integer reqIndex = 0;
            for (Integer i = 0; i < reqsIds.size(); i++) {
                if (appInfo.requirementId == reqsIds.get(i)) {
                    reqIndex = i;
                }
            }
            if (reqIndex == 0) {
                appInfo.nextRequirement = reqsIds.get(reqIndex + 1);
                appInfo.prevRequirement = null;
            } else if (reqIndex == (reqsIds.size() - 1)) {
                appInfo.nextRequirement = null;
                appInfo.prevRequirement = reqsIds.get(reqIndex - 1);
            } else {
                appInfo.nextRequirement = reqsIds.get(reqIndex + 1);
                appInfo.prevRequirement = reqsIds.get(reqIndex - 1);
            }
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

        //Generate new cookie
        createEncryptedCookie(JSON.serialize(appInfo));
        return appInfo;
    }

    public static List<Id> getRequirementIds(Id appControlId) {
        List<Id> reqsIds = new List<Id>();
        List<Requirement__c> reqs = [
                SELECT Id, Application_Control__c, Active__c, Show_on_Application_Creation__c, Display_Order__c, Label__c
                FROM Requirement__c
                WHERE Application_Control__c = :appControlId
                AND Active__c = TRUE
                AND Show_on_Application_Creation__c = FALSE
                ORDER BY Display_Order__c, Label__c ASC NULLS LAST

        ];

//        for (Requirement_Item__c ri : riList) {
//            if (ApplicationFilter.filter(app, ri)) {
//                reqMap.get(ri.Requirement__c).reqItemMap.put(ri.Id, new RequirementItemWrapper(ri));
//                riIds.add(ri.Id);
//            }
//        }

        System.debug(JSON.serializePretty(reqs));
        for (Requirement__c r : reqs) {
            reqsIds.add(r.Id);
        }
        System.debug(reqsIds);
        return reqsIds;
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
                        Template__c FROM Application_Control__c WHERE Active__c = :true AND (URL_Parameter__c = :param OR Default__c = :true)]) {
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
                } catch(DmlException  ex) {

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