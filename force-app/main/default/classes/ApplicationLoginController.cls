global with sharing class ApplicationLoginController {

    global String username { get; set; }
    global String password { get; set; }
    public String template { get; set; }
    public String recaptchaResponse { get; set; }
    public String clientEnvJson { get; set; }
    public Boolean recaptchaEnabled { get; set; }
    public ApplicationReCaptcha.RecaptchaSettings recaptcha { get; set; }

    global PageReference login() {

        String startUrl = System.currentPageReference().getParameters().get('startURL');

        //String startUrl = 'apex/ApplicationPortal';
        PageReference loginResult = Site.login(username, password, startUrl);

        // Fraud monitoring: capture a reCAPTCHA score and environmental variables for every
        // login attempt (not just registration), since a bad actor may act on a compromised
        // account after legitimate registration. This must never block or delay login - all
        // failures degrade gracefully rather than blocking the user. Runs AFTER Site.login()
        // so that, on success, Salesforce's own LoginHistory/LoginGeo rows already exist and
        // can be used for Login-event geolocation (see docs/fraud-monitoring-recaptcha-ip-geo.md).
        // A failed login (loginResult == null) still gets a record - a repeated failed-login
        // pattern is itself a fraud signal worth capturing, per the "surface suspicious activity"
        // goal - just without the LoginHistory/LoginGeo lookup, since no login actually succeeded.
        try {
            logLoginAttempt(loginResult != null);
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN, 'ApplicationLoginController: fraud monitoring capture failed, continuing login. ' + ex.getTypeName() + ': ' + ex.getMessage());
        }

        return loginResult;

    }

    global ApplicationLoginController() {
        Application_Setting__c AppSettings = Application_Setting__c.getOrgDefaults();
        template = AppSettings.Default_Template__c;
        recaptchaEnabled = String.isNotBlank(AppSettings.reCAPTCHA_Site_Key__c) && String.isNotBlank(AppSettings.reCAPTCHA_Library_Url__c);
        recaptcha = new ApplicationReCaptcha.RecaptchaSettings(AppSettings.reCAPTCHA_Site_Key__c, AppSettings.reCAPTCHA_Library_Url__c);
    }

    public PageReference checkIfLoggedIn() {
        String userType = UserInfo.getUserType();
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        PageReference pageRef = null;
        if (userType.equalsIgnoreCase('CSPLitePortal')) {
            if (String.isNotBlank(startUrl)) {
                pageRef = new PageReference(Site.getPathPrefix() + '/' + EncodingUtil.urlEncode(startUrl, 'UTF-8'));
            } else {
                pageRef = Page.ApplicationPortal;
            }
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }

    /**
     * @description Resolves the Contact behind the entered username, validates the reCAPTCHA
     * token, captures environmental variables from the request headers and client env JSON, looks
     * up Salesforce's own LoginHistory/LoginGeo for city/state/country (login attempts only, and
     * only when the login actually succeeded), and inserts one Application_Login__c record per
     * active application the Contact has. Never throws out of this method's caller context in a
     * way that would block login - all exceptions are caught by the caller (login()).
     *
     * @TestVisible: Site.login() cannot be invoked from a standard Apex test context, so this
     * method is exposed to tests directly rather than only being exercised indirectly through
     * login() - the fraud-monitoring logic here has no dependency on Site.login() having actually
     * run; it only reads whether login succeeded as a boolean parameter.
     *
     * @param loginSucceeded Whether Site.login() returned a non-null PageReference. Determines
     *        whether a LoginHistory/LoginGeo lookup is attempted - a failed login still gets a
     *        fraud-monitoring record (repeated failures are themselves a signal), just without
     *        geolocation, since no LoginHistory row was created for a failed attempt.
     */
    @TestVisible
    private void logLoginAttempt(Boolean loginSucceeded) {
        if (String.isBlank(username)) {
            return;
        }

        loginCrudHelper helper = new loginCrudHelper();
        Id contactId = helper.getContactIdForUsername(username);
        if (contactId == null) {
            return;
        }

        ApplicationReCaptcha.ReCaptchaResult recaptchaResult = ApplicationReCaptcha.isReCAPTCHAValid(recaptchaResponse);

        String ipAddress = resolveIpAddress();
        String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        String refererHeader = ApexPages.currentPage().getHeaders().get('Referer');
        String mergedClientEnvJson = ApplicationEnvironmentCapture.mergeServerSignals(clientEnvJson, refererHeader, userAgent);
        ApplicationEnvironmentCapture.ParsedUserAgent parsedUA = ApplicationEnvironmentCapture.parseUserAgent(userAgent);

        String geolocation = null;
        if (loginSucceeded) {
            geolocation = helper.getGeolocationForUsername(username);
        }

        List<Application__c> activeApplications = helper.getActiveApplicationsForContact(contactId);
        if (activeApplications.isEmpty()) {
            return;
        }

        List<Application_Login__c> logsToInsert = new List<Application_Login__c>();
        for (Application__c app : activeApplications) {
            Application_Login__c logEntry = new Application_Login__c();
            logEntry.Contact__c = contactId;
            logEntry.Application__c = app.Id;
            logEntry.Event_Type__c = 'Login';
            logEntry.ReCAPTCHA_Score__c = recaptchaResult.score;
            logEntry.ReCAPTCHA_Score_Status__c = recaptchaResult.status;
            logEntry.ReCAPTCHA_Error_Detail__c = truncate(recaptchaResult.errorDetail, 255);
            logEntry.IP_Address__c = ipAddress;
            logEntry.Geolocation__c = geolocation;
            logEntry.Browser__c = parsedUA.browser;
            logEntry.Operating_System__c = parsedUA.operatingSystem;
            logEntry.Device_Type__c = parsedUA.deviceType;
            logEntry.User_Agent_Raw__c = userAgent;
            logEntry.Client_Env_JSON__c = mergedClientEnvJson;
            logsToInsert.add(logEntry);
        }

        helper.insertLoginRecords(logsToInsert);
    }

    /**
     * @description Truncates val to at most maxLen characters. Returns val unchanged if it fits
     * or is blank. Used to defensively guard against DML failures when writing exception messages
     * into fixed-length diagnostic text fields.
     */
    private static String truncate(String val, Integer maxLen) {
        if (String.isBlank(val)) {
            return val;
        }
        return val.length() > maxLen ? val.left(maxLen) : val;
    }

    /**
     * @description Resolves the client IP from Salesforce's own detected source IP header first
     * (more reliable, not attacker-controllable), falling back to X-Forwarded-For.
     */
    private static String resolveIpAddress() {
        Map<String, String> headers = new Map<String, String>();
        String sip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        if (String.isNotBlank(sip)) {
            return sip;
        }
        String forwardedFor = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        if (String.isNotBlank(forwardedFor)) {
            // X-Forwarded-For can contain a comma-separated hop list; the first entry is the
            // original client.
            return forwardedFor.split(',')[0].trim();
        }
        return null;
    }

    /**
     * @description Guest/portal users do not have direct access to query User or insert
     * Application_Login__c across arbitrary Contacts under standard sharing, so this CRUD helper
     * runs without sharing, mirroring the crudToDo pattern in ApplicationRegistration.cls. Scope
     * is deliberately narrow: only the two lookups and one insert needed for fraud monitoring.
     */
    private without sharing class loginCrudHelper {

        public Id getContactIdForUsername(String usernameValue) {
            List<User> matchingUsers = [
                    SELECT ContactId
                    FROM User
                    WHERE Username = :usernameValue
                    LIMIT 1
            ];
            if (matchingUsers.isEmpty() || matchingUsers[0].ContactId == null) {
                return null;
            }
            return matchingUsers[0].ContactId;
        }

        /**
         * @description Looks up the most recent LoginHistory row for this username and, if it has
         * a LoginGeo association, formats "City, Subdivision, Country" per the ticket's required
         * format. Only call this AFTER Site.login() has returned successfully - the LoginHistory
         * row for the current login does not exist until authentication completes. Returns null
         * (never throws) if no LoginHistory/LoginGeo data is found, which is a documented Salesforce
         * behavior for a small percentage of logins, not necessarily an error.
         */
        public String getGeolocationForUsername(String usernameValue) {
            List<User> matchingUsers = [
                    SELECT Id
                    FROM User
                    WHERE Username = :usernameValue
                    LIMIT 1
            ];
            if (matchingUsers.isEmpty()) {
                return null;
            }

            List<LoginHistory> recentLogins = [
                    SELECT LoginGeoId
                    FROM LoginHistory
                    WHERE UserId = :matchingUsers[0].Id
                    AND LoginGeoId != NULL
                    ORDER BY LoginTime DESC
                    LIMIT 1
            ];
            if (recentLogins.isEmpty()) {
                return null;
            }

            List<LoginGeo> geoRecords = [
                    SELECT City, Subdivision, Country
                    FROM LoginGeo
                    WHERE Id = :recentLogins[0].LoginGeoId
                    LIMIT 1
            ];
            if (geoRecords.isEmpty()) {
                return null;
            }

            LoginGeo geo = geoRecords[0];
            List<String> parts = new List<String>();
            if (String.isNotBlank(geo.City)) {
                parts.add(geo.City);
            }
            if (String.isNotBlank(geo.Subdivision)) {
                parts.add(geo.Subdivision);
            }
            if (String.isNotBlank(geo.Country)) {
                parts.add(geo.Country);
            }
            return parts.isEmpty() ? null : String.join(parts, ', ');
        }

        public List<Application__c> getActiveApplicationsForContact(Id contactId) {
            // Mirrors ApplicationListController.getAllApplications()'s active-application
            // filter so fraud monitoring's definition of "active" stays consistent with what
            // the portal itself shows the user. See docs/fraud-monitoring-recaptcha-ip-geo.md.
            return [
                    SELECT Id
                    FROM Application__c
                    WHERE Contact__c = :contactId
                    AND Application_Control__r.Active__c = TRUE
                    AND (
                            (
                                    (Intended_Term_of_Entry__r.Term_10th_Day__c >= TODAY OR Intended_Term_of_Entry__r.Term_10th_Day__c = NULL)
                                    AND Application_Control__r.Current_Student_Application__c = FALSE
                            ) OR (
                                    Term_Start_Date__c <= TODAY AND Application_Control__r.Current_Student_Application__c = TRUE
                            )
                    )
                    AND Application_Status__c != 'Wrong App'
                    AND Application_Status__c != 'Withdrawn'
            ];
        }

        public void insertLoginRecords(List<Application_Login__c> logsToInsert) {
            if (logsToInsert.isEmpty()) {
                return;
            }
            try {
                insert logsToInsert;
            } catch (Exception ex) {
                System.debug(LoggingLevel.WARN, 'ApplicationLoginController: failed to insert Application_Login__c records. ' + ex.getMessage());
            }
        }
    }

}
