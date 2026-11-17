/**
 * Controller for the easyAppLookup LWC.
 * Drives the cascading Application Control → Term → Applicant search flow.
 *
 * @author Thaddaeus Dahlberg, University of St. Thomas
 */
public with sharing class EASYAppLookupController {

    /**
     * Returns the active Application Controls that have something to review, sorted by name. A control has something
     * to review when at least one of its requirements is active, shown on the review pages and not creation-only.
     * Controls with no review content (for example the shell controls) are left out, so there is no list of names to
     * maintain. Each option carries the control's Submit Status, which the finder uses as its default status.
     *
     * @return One option per Application Control with review content
     */
    @AuraEnabled(Cacheable=true)
    public static List<OptionWrapper> getApplicationControls() {
        List<OptionWrapper> options = new List<OptionWrapper>();
        for (Application_Control__c ac : [
                SELECT Id, Name, Submit_Status__c
                FROM Application_Control__c
                WHERE Active__c = TRUE
                AND Id IN (
                        SELECT Application_Control__c
                        FROM Requirement__c
                        WHERE Active__c = TRUE
                        AND Display_on_Admin_Review_Pages__c = TRUE
                        AND Show_on_Application_Creation__c = FALSE
                )
                WITH USER_MODE
                ORDER BY Name ASC
        ]) {
            options.add(new OptionWrapper(ac.Name, ac.Id, ac.Submit_Status__c));
        }
        return options;
    }

    /**
     * Returns the Application Status picklist values (label and value) in picklist order, so the finder can offer a
     * status filter without any status text living in code.
     *
     * @return One option per active Application Status value
     */
    @AuraEnabled(Cacheable=true)
    public static List<OptionWrapper> getApplicationStatuses() {
        List<OptionWrapper> options = new List<OptionWrapper>();
        for (Schema.PicklistEntry entry : Application__c.Application_Status__c.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                options.add(new OptionWrapper(entry.getLabel(), entry.getValue()));
            }
        }
        return options;
    }

    /**
     * Returns the distinct Academic Terms that have at least one Application for the
     * given Application Control, sorted most-recent first by term start date.
     */
    @AuraEnabled(Cacheable=true)
    public static List<OptionWrapper> getTermsForControl(String appControlId) {
        if (String.isBlank(appControlId)) {
            return new List<OptionWrapper>();
        }
        List<OptionWrapper> options = new List<OptionWrapper>();
        for (Academic_Term__c term : [
                SELECT Id, Name
                FROM Academic_Term__c
                WHERE Id IN (
                        SELECT Intended_Term_of_Entry__c
                        FROM Application__c
                        WHERE Application_Control__c = :appControlId
                        AND Intended_Term_of_Entry__c != NULL
                )
                WITH USER_MODE
                ORDER BY Term_Start_Date__c DESC NULLS LAST, Name ASC
        ]) {
            options.add(new OptionWrapper(term.Name, term.Id));
        }
        return options;
    }

    /**
     * Searches for applicants within the given Application Control and Term.
     * Matches on first name, last name, preferred first name, or a combined
     * "first last" / "preferred first last" pattern when the search contains a space.
     * Results include city/state, high school/college details and the application status. When a status is given,
     * only applications in that status are returned.
     *
     * @param appControlId The Application Control to search within
     * @param termId The Academic Term to search within
     * @param searchTerm What the user typed
     * @param status An Application Status value to limit the search to, or blank for every status
     * @return Up to 20 matching applicants
     */
    @AuraEnabled(Cacheable=true)
    public static List<ApplicantResult> searchApplicants(
            String appControlId,
            String termId,
            String searchTerm,
            String status) {

        if (String.isBlank(appControlId) || String.isBlank(termId) || String.isBlank(searchTerm)) {
            return new List<ApplicantResult>();
        }

        String trimmed = searchTerm.trim();
        String fullPattern = '%' + String.escapeSingleQuotes(trimmed) + '%';

        // Support "First Last" and "Preferred First Last" multi-token search
        String part1Pattern = null;
        String part2Pattern = null;
        if (trimmed.contains(' ')) {
            Integer spaceIdx = trimmed.indexOf(' ');
            String firstPart = trimmed.substring(0, spaceIdx).trim();
            String lastPart  = trimmed.substring(spaceIdx + 1).trim();
            if (String.isNotBlank(firstPart) && String.isNotBlank(lastPart)) {
                part1Pattern = '%' + String.escapeSingleQuotes(firstPart) + '%';
                part2Pattern = '%' + String.escapeSingleQuotes(lastPart)  + '%';
            }
        }

        String nameFilter;
        if (part1Pattern != null) {
            nameFilter = '(Contact__r.FirstName LIKE :fullPattern'
                + ' OR Contact__r.LastName LIKE :fullPattern'
                + ' OR Contact__r.Preferred_First_Name__c LIKE :fullPattern'
                + ' OR (Contact__r.FirstName LIKE :part1Pattern AND Contact__r.LastName LIKE :part2Pattern)'
                + ' OR (Contact__r.Preferred_First_Name__c LIKE :part1Pattern AND Contact__r.LastName LIKE :part2Pattern))';
        } else {
            nameFilter = '(Contact__r.FirstName LIKE :fullPattern'
                + ' OR Contact__r.LastName LIKE :fullPattern'
                + ' OR Contact__r.Preferred_First_Name__c LIKE :fullPattern)';
        }

        String query = 'SELECT Id, Name,'
            + ' Contact__r.FirstName, Contact__r.LastName, Contact__r.Preferred_First_Name__c,'
            + ' Contact__r.MailingCity, Contact__r.MailingState,'
            + ' Primary_High_School_Account__r.Name,'
            + ' School_College__c, Application_Status__c'
            + ' FROM Application__c'
            + ' WHERE Application_Control__c = :appControlId'
            + ' AND Intended_Term_of_Entry__c = :termId'
            + (String.isNotBlank(status) ? ' AND Application_Status__c = :status' : '')
            + ' AND ' + nameFilter
            + ' WITH USER_MODE'
            + ' ORDER BY Contact__r.LastName ASC, Contact__r.FirstName ASC'
            + ' LIMIT 20';

        List<ApplicantResult> results = new List<ApplicantResult>();
        for (Application__c app : Database.query(query)) {
            results.add(new ApplicantResult(app));
        }
        return results;
    }

    // ─── Inner wrapper classes ────────────────────────────────────────────────

    public class OptionWrapper {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        // Only set for Application Controls: the status an application takes on when it is submitted.
        @AuraEnabled public String submitStatus { get; set; }

        public OptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }

        public OptionWrapper(String label, String value, String submitStatus) {
            this(label, value);
            this.submitStatus = submitStatus;
        }
    }

    public class ApplicantResult {
        @AuraEnabled public String appId        { get; set; }
        @AuraEnabled public String firstName    { get; set; }
        @AuraEnabled public String lastName     { get; set; }
        @AuraEnabled public String fullName     { get; set; }
        @AuraEnabled public String cityState    { get; set; }
        @AuraEnabled public String highSchool   { get; set; }
        @AuraEnabled public String schoolCollege { get; set; }
        @AuraEnabled public String status        { get; set; }

        public ApplicantResult(Application__c app) {
            this.appId     = app.Id;
            this.firstName = app.Contact__r.FirstName  != null ? app.Contact__r.FirstName  : '';
            this.lastName  = app.Contact__r.LastName   != null ? app.Contact__r.LastName   : '';

            // Show the preferred first name when there is one, otherwise the legal first name (same as the header).
            String preferred = app.Contact__r.Preferred_First_Name__c;
            String displayFirst = String.isNotBlank(preferred) ? preferred : this.firstName;
            this.fullName = (String.isNotBlank(this.lastName) ? this.lastName + ', ' : '')
                + displayFirst;

            // City / State
            String city  = app.Contact__r.MailingCity;
            String state = app.Contact__r.MailingState;
            if (String.isNotBlank(city) && String.isNotBlank(state)) {
                this.cityState = city + ', ' + state;
            } else if (String.isNotBlank(city)) {
                this.cityState = city;
            } else if (String.isNotBlank(state)) {
                this.cityState = state;
            }

            // High School (lookup to Account)
            if (app.Primary_High_School_Account__r != null) {
                this.highSchool = app.Primary_High_School_Account__r.Name;
            }

            // School / College within the university (picklist)
            this.schoolCollege = app.School_College__c;

            this.status = app.Application_Status__c;
        }
    }
}