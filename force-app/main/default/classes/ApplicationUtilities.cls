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
        if (appControl != null) {
            appInfo.hideTermProgram = appControl.Hide_Term_Program__c;
            appInfo.allowWithdrawFrom = appControl.Allow_Withdraw_From__c;
            appInfo.allowSubmitFrom = appControl.Allow_Submit_From__c;
            appInfo.submitStatus = appControl.Submit_Status__c;
            appInfo.allowConfirmFrom = appControl.Allow_Confirm_From__c;
            appInfo.confirmStatus = appControl.Confirm_Status__c;
            appInfo.withdrawStatus = appControl.Withdraw_Status__c;
            appInfo.academicLevel = appControl.Academic_Level__c;
            appInfo.schoolCollege = appControl.School_College__c;
            appInfo.appControlId = appControl.Id;
            appInfo.template = appControl.Template__c;
            appInfo.at = appControl.URL_Parameter__c;
            appInfo.appStartStatus = appControl.Application_Start_Status__c;
            appInfo.allowCancelFrom = appControl.Allow_Cancel_From__c;
        }
        return appInfo;
    }

    public static EASYApplicationInfo createShellAppInfo() {
        EASYApplicationInfo appInfo = new EASYApplicationInfo();
        Application_Control__c appControl = getApplicationControls(ApexPages.currentPage().getParameters().get('at'));
        appInfo = flattenAppControl(appControl, appInfo);
        appInfo.contactId = ApplicationUtilities.getAppContactId();
        appInfo.isExternalUser = ApplicationUtilities.isExternalUser();
        appInfo.appSubStatus = 'none';
        appInfo.appStatus = 'none';
        appInfo.allowSubmit = false;
        appInfo.allowCancelFrom = '';
        appInfo.allowWithdrawFrom = '';
        if (String.isBlank(appControl.Template__c)) {
            Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
            appInfo.template = AppSettings.Default_Template__c;
        }
        return appInfo;
    }

    public static Boolean isExternalUser() {
        // Is external may be guest user like recommender
//        if (!UserInfo.getUserType().equals('Standard') && String.isNotBlank(ApexPages.currentPage().getParameters().get('h')) && String.isNotBlank(ApexPages.currentPage().getParameters().get('r'))) {
//            return false;
//        }
        String userType = UserInfo.getUserType();
        if (!userType.equalsIgnoreCase('CSPLitePortal') && !userType.equalsIgnoreCase('standard')) {
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
                            Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name,
                            Applicant_Type__c
                    FROM Application__c
                    WHERE Contact__c = :appInfo.contactId
                    AND Application_Status__c != 'Wrong Application'
                    AND (NOT (Application_Status__c = 'Withdrawn' AND Application_Substatus__c = 'Wrong App'))
                    AND (NOT (Application_Status__c = 'Withdrawn' AND Application_Substatus__c = 'Multiple App'))
                    ORDER BY Name DESC
            ];
            if (lastApps.size() > 0) {
                Application_Control__c appControl = getApplicationControls(lastApps[0].Application_Control__r.URL_Parameter__c);
                Application__c app = lastApps[0];
                appInfo = setApplicationInfo(appControl, app);
            }
        }

        //Contact did not find app so now we need to set the appControl to 'noapp' application control
        if (String.isBlank(appInfo.appId) && String.isBlank(appInfo.at)) {
            Application_Control__c appControl = getApplicationControls('noapp');
            appInfo = flattenAppControl(appControl, appInfo);
            appInfo.contactId = ApplicationUtilities.getAppContactId();
            appInfo.isExternalUser = ApplicationUtilities.isExternalUser();
            appInfo.appSubStatus = 'none';
            appInfo.appStatus = 'none';
            appInfo.allowSubmit = false;
            appInfo.allowCancelFrom = '';
            appInfo.allowWithdrawFrom = '';
        }

        //No template is selected for the application control so use the default
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
                            Intended_Program__r.Name, Intended_Program__r.Program_Name_on_Application__c, Intended_Term_of_Entry__r.Name, Contact__c, Applicant_Type__c
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
            Id applicationControlId = Id.valueOf(param);
            return [
                    SELECT Id, Hide_Term_Program__c, Application_Start_Status__c, Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c,
                            Cancel_Status__c, Submit_Status__c, Withdraw_Status__c, URL_Parameter__c, Default__c, Academic_Level__c,
                            School_College__c, Degree_Levels__c, Template__c, Confirm_Status__c, Allow_Confirm_From__c, External_App_Claim_Id_Question__c,
                            External_App_Found_Statement__c, External_Application_Type__c
                    FROM Application_Control__c
                    WHERE Id = :applicationControlId
            ];
        } catch (Exception e) {
        }

        for (Application_Control__c ac : [
                SELECT Id, Hide_Term_Program__c, Application_Start_Status__c, Allow_Cancel_From__c, Allow_Submit_From__c, Allow_Withdraw_From__c,
                        Cancel_Status__c, Submit_Status__c, Withdraw_Status__c, URL_Parameter__c, Default__c, Academic_Level__c, School_College__c, Degree_Levels__c,
                        Template__c, Confirm_Status__c, Allow_Confirm_From__c, External_App_Claim_Id_Question__c,
                        External_App_Found_Statement__c, External_Application_Type__c
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
        String encodedCipherText = createEncryptedString(stringToEncrypt);
        Integer cookieLife = 60 * 60 * 4;//60 * 60 * 24 * 365; // 1 year
        Cookie EASYCookie = new Cookie('EASY_INFO', encodedCipherText, null, cookieLife, true, 'Strict');
        ApexPages.currentPage().setCookies(new Cookie[]{
                EASYCookie
        });
        return encodedCipherText;
    }

    public static String createEncryptedString(String stringToEncrypt) {
        String encryptedString = '';
        String key = getCookieKey();
        if (String.isNotBlank(String.valueOf(key))) {
            Blob data = Blob.valueOf(stringToEncrypt);
            Blob encrypted = Crypto.encryptWithManagedIV('AES256', Blob.valueOf(key), data);
            encryptedString = EncodingUtil.base64Encode(encrypted);
            encryptedString = EncodingUtil.urlEncode(encryptedString, 'UTF-8');
        }
        return encryptedString;
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

    public static Datetime adjustForTimeZone(Datetime dt, String timezoneString) {
        timezoneString = ApplicationUtilities.getTimeZonePick(timezoneString);
        //Get the current GMT time and adjust for our timezone
        //tz = TimeZone.getTimeZone('America/Chicago');
        //Timezone adjustment example below:
        //Datetime NowDate = Datetime.now();
        //NowDate = NowDate.addSeconds(tz.getOffset(NowDate)/1000);
        //Central Daylight Time (America/Chicago)
        TimeZone tz = TimeZone.getTimeZone(timezoneString);
        dt = dt.addSeconds(tz.getOffset(dt) / 1000);
        return dt;
    }

    public static String getTimeZonePick(String pickListTimeZone) {
        if (String.isNotBlank(pickListTimeZone)) {
            if (pickListTimeZone.length() > 4 && pickListTimeZone.contains('(')) {
                pickListTimeZone = pickListTimeZone.substring(pickListTimeZone.indexOf('(') + 1, pickListTimeZone.indexOf(')'));
                return pickListTimeZone;
            }
            return pickListTimeZone;
        }
        return '';
    }

    public static Datetime convertDateToDatetime(Date dateIn, Time timeIn, String timezoneString) {
        if (timeIn == null) {
            timeIn = Time.newInstance(1, 12, 3, 4);
        }
        Datetime converted = Datetime.newInstance(dateIn.year(), dateIn.month(), dateIn.day(), timeIn.hour(), timeIn.minute(), timeIn.second());
        if (String.isNotBlank(timezoneString)) {
            converted = adjustForTimeZone(converted, timezoneString);
        }
        return converted;
    }

    public static String replaceDataTags(String widgetContent, EASYPersonalDataTags tagWrapper) {
        //widgetContent = 'This is a {{Banner <strong>Id</strong>}} in the middle of something. {<strong>{Nothing here</strong>}}. asdfsdfa {{Banner Id}}. Then what if you find a tag like {{This one<strong>}</strong>}';

        //Serialize EASYPersonalDataTags data so we can get field names and retrieve with get method
        Map<String, Object> tagMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(tagWrapper));

        //Create lower/uppercase of EASYPersonalDataTags fields so that we can find them case insensitive
        Map<String, String> lowerCaseUppercaseTagMap = new Map<String, String>();
        for (String k : tagMap.keySet()) {
            lowerCaseUppercaseTagMap.put(k.toLowerCase(), k);
        }

        //Get all tags in content that start with {{ and end with }} even if interrupted with html
        Pattern tagPattern = Pattern.compile('\\{.(.*?)\\}(.*?|)[\\}\\s]');
        Matcher tagMatcher = tagPattern.matcher(widgetContent);
        Set<String> matchingTags = new Set<String>();
        while (tagMatcher.find ()) {
            matchingTags.add(tagMatcher.group() .trim());
        }

        //Loop through tag matches set to sanitize and replace all
        for (String tag : matchingTags) {

            //Remove all HTML elements from the tag to avoid things like this {<em>{</em>Tag}}
            String tab_data = tag.replaceAll('<[^>]*>', '');

            //Remove tag delineators to get at data identifier
            tab_data = tab_data.removeStart('{{');
            tab_data = tab_data.removeEnd('}}');
            tab_data = tab_data.trim();

            //Add underscore to space in so that user can be agnostic of the need
            tab_data = tab_data.replace(' ', '_');

            //Find if lowercase version of tag is in our map of lower/uppercase tags and use uppercase to grab data
            if (lowerCaseUppercaseTagMap.keySet().contains(tab_data.toLowerCase())) {
                //find if the tag is Documents_Missing
                String caseSensitiveTag = lowerCaseUppercaseTagMap.get(tab_data.toLowerCase());

                //If the value is blank we want to replace tag with an empty string
                String valueForTag = String.isNotBlank((String) tagMap.get(caseSensitiveTag)) ? (String) tagMap.get(caseSensitiveTag) : '' ;

                if (tab_data.toLowerCase() == 'documents_missing' && String.isNotBlank(valueForTag)) {
                    //The documents_missing tab contains a comma seperated list inside brackets I want to turn into a bulleted list
                    String documentsMissing = (String) tagMap.get(lowerCaseUppercaseTagMap.get(tab_data.toLowerCase()));
                    if (String.isNotBlank(documentsMissing)) {
                        //System.debug('documentsMissing: ' + documentsMissing);
                        //remove <p>[ from front of tag and ]</p> from end of tag added by flow creation
                        documentsMissing = documentsMissing.removeStart('<p>');
                        documentsMissing = documentsMissing.removeStart('[');
                        documentsMissing = documentsMissing.removeEnd('</p>');
                        documentsMissing = documentsMissing.removeEnd(']');
                        String[] documentsMissingList = documentsMissing.split(',');
                        String documentsMissingListHTML = '<ul>';
                        for (String document : documentsMissingList) {
                            documentsMissingListHTML += '<li>' + document + '</li>';
                        }
                        documentsMissingListHTML += '</ul>';
                        valueForTag = documentsMissingListHTML;
                    }
                }

                //Replace the original tag (as it may contain html,ect, with the found value)
                widgetContent = widgetContent.replace(tag, valueForTag);
            }
        }

        return widgetContent;
    }
}