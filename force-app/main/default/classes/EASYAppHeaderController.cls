/**
 * Controller for the easyAppHeader LWC.
 * Loads the header-strip data for a selected Application: applicant name/contact,
 * app status, related Opportunity, high-school-or-college, and city/state.
 *
 * @author Thaddaeus Dahlberg, University of St. Thomas
 */
public with sharing class EASYAppHeaderController {

    /**
     * Returns the header display data for the given Application Id.
     * Uses cacheable=false so reviewers always see the current status.
     */
    @AuraEnabled(Cacheable=false)
    public static AppHeaderData getHeaderData(String appId) {

        if (String.isBlank(appId)) {
            return null;
        }

        List<Application__c> apps = [
                SELECT Id,
                        Contact__c,
                        Contact__r.FirstName,
                        Contact__r.LastName,
                        Contact__r.Preferred_First_Name__c,
                        Contact__r.MailingCity,
                        Contact__r.MailingState,
                        OwnerId,
                        Citizenship__c,
                        Application_Status__c,
                        Application_Substatus__c,
                        Intended_Program__c,
                        Intended_Program__r.Name,
                        High_School_or_College__c,
                        High_School_or_College__r.Name,
                        (SELECT Id, Name FROM Opportunities__r ORDER BY CreatedDate DESC LIMIT 1)
                FROM Application__c
                WHERE Id = :appId
                WITH USER_MODE
                LIMIT 1
        ];

        if (apps.isEmpty()) {
            return null;
        }

        Application__c app = apps[0];
        AppHeaderData hd = new AppHeaderData();

        // ── Contact / applicant name ──────────────────────────────────────────
        hd.contactId = app.Contact__c;

        String first     = app.Contact__r.FirstName  != null ? app.Contact__r.FirstName  : '';
        String last      = app.Contact__r.LastName   != null ? app.Contact__r.LastName   : '';
        String preferred = app.Contact__r.Preferred_First_Name__c;
        // Reviewers see the preferred name when there is one, otherwise the legal first name.
        String displayFirst = String.isNotBlank(preferred) ? preferred : first;
        hd.contactName = (String.isNotBlank(last) ? last + ', ' : '') + displayFirst;
        // The legal name stays available (hover text in the header).
        hd.legalName = (first + ' ' + last).trim();

        // ── Owner and citizenship ────────────────────────────────────────────
        hd.ownerName = ownerNameFor(app.OwnerId);
        hd.citizenship = app.Citizenship__c;
        hd.citizenshipLabel = Schema.SObjectType.Application__c.fields.Citizenship__c.getLabel();

        // ── Status ────────────────────────────────────────────────────────────
        hd.appStatus    = app.Application_Status__c;
        hd.appSubStatus = app.Application_Substatus__c;

        // ── Opportunity (via Admissions_Application__c child relationship) ────
        List<SObject> oppSObjects = app.getSObjects('Opportunities__r');
        if (oppSObjects != null && !oppSObjects.isEmpty()) {
            Opportunity opp = (Opportunity) oppSObjects[0];
            hd.opportunityId   = opp.Id;
            hd.opportunityName = opp.Name;
        }

        // Intended Program as fallback label alongside opportunity
        if (app.Intended_Program__c != null) {
            hd.intendedProgramName = app.Intended_Program__r.Name;
        }

        // ── Primary institution ───────────────────────────────────────────────
        // The application's own institution when it has one, otherwise the institution on the applicant's
        // education history record flagged as primary (high school or bachelor institution).
        if (app.High_School_or_College__c != null) {
            hd.institutionId   = app.High_School_or_College__c;
            hd.institutionName = app.High_School_or_College__r.Name;
        } else if (app.Contact__c != null) {
            Id contactIdForHistory = app.Contact__c;
            List<hed__Education_History__c> histories = [
                    SELECT hed__Account__c, hed__Account__r.Name
                    FROM hed__Education_History__c
                    WHERE hed__Contact__c = :contactIdForHistory
                    AND hed__Account__c != NULL
                    AND (Primary_High_School__c = TRUE OR Primary_Bachelor_Institution__c = TRUE)
                    WITH USER_MODE
                    ORDER BY LastModifiedDate DESC
                    LIMIT 1
            ];
            if (!histories.isEmpty()) {
                hd.institutionId   = histories[0].hed__Account__c;
                hd.institutionName = histories[0].hed__Account__r.Name;
            }
        }

        // ── City / State ──────────────────────────────────────────────────────
        String city  = app.Contact__r.MailingCity;
        String state = app.Contact__r.MailingState;
        if (String.isNotBlank(city) && String.isNotBlank(state)) {
            hd.cityState = city + ', ' + state;
        } else if (String.isNotBlank(city)) {
            hd.cityState = city;
        } else if (String.isNotBlank(state)) {
            hd.cityState = state;
        }

        return hd;
    }

    // The owner is a user or a queue; the Id says which, so no name or type text is compared.
    private static String ownerNameFor(Id ownerId) {
        if (ownerId == null) {
            return null;
        }
        List<SObject> owners = ownerId.getSobjectType() == Schema.User.SObjectType
                ? (List<SObject>) [SELECT Name FROM User WHERE Id = :ownerId WITH USER_MODE]
                : (List<SObject>) [SELECT Name FROM Group WHERE Id = :ownerId WITH USER_MODE];
        return owners.isEmpty() ? null : String.valueOf(owners[0].get('Name'));
    }

    // ─── Inner wrapper ────────────────────────────────────────────────────────

    public class AppHeaderData {
        @AuraEnabled public String contactId          { get; set; }
        @AuraEnabled public String contactName        { get; set; }
        @AuraEnabled public String appStatus          { get; set; }
        @AuraEnabled public String appSubStatus       { get; set; }
        @AuraEnabled public String opportunityId      { get; set; }
        @AuraEnabled public String opportunityName    { get; set; }
        @AuraEnabled public String intendedProgramName { get; set; }
        @AuraEnabled public String institutionId      { get; set; }
        @AuraEnabled public String institutionName    { get; set; }
        @AuraEnabled public String legalName          { get; set; }
        @AuraEnabled public String ownerName          { get; set; }
        @AuraEnabled public String citizenship        { get; set; }
        @AuraEnabled public String citizenshipLabel   { get; set; }
        @AuraEnabled public String cityState          { get; set; }
    }
}