/**
 * Shared IP 30-day count utility for the EASY admissions portal fraud monitoring feature
 * (ECRMSF-5511 / ECRMSF-5529). Calculates a pure aggregate count only - the decision of whether
 * that count is "high enough to warn" belongs to an admin-tunable Flow, not this class (see
 * Shared_IP_Warning__c on Application__c and docs/fraud-monitoring-recaptcha-ip-geo.md's fraud
 * alerting section). This class never sets Shared_IP_Warning__c itself.
 *
 * Scoped to Submission-type Application_Login__c rows only, matching this feature's existing
 * "compare against submission IP only, not login IP" decision (see the design doc's resolved
 * Jira comment thread on ECRMSF-5532) - the same rationale applies here: login activity from
 * shared networks (campus labs, VPNs) is expected and noisy, while a shared IP across multiple
 * distinct applicants' actual submissions is the more meaningful fraud signal.
 */
public with sharing class ApplicationSharedIpCount {

    /**
     * @description Calculates the count of distinct Contacts who have a Submission-type
     * Application_Login__c row sharing the given IP address within the trailing 30 days, and
     * writes that count to Shared_IP_User_Count_30Day__c on the given Application__c. Never
     * throws - a fraud-monitoring calculation failure must never surface as an error to the
     * caller. Does nothing (no-op) if applicationId or ipAddress is blank, since a null IP means
     * there is nothing meaningful to count against.
     *
     * @param applicationId The Id of the Application__c to update with the calculated count.
     * @param ipAddress The submission IP address to count shared usage for.
     */
    public static void updateSharedIpCount(Id applicationId, String ipAddress) {
        if (applicationId == null || String.isBlank(ipAddress)) {
            return;
        }

        try {
            Integer sharedCount = countDistinctContactsForIp(ipAddress);

            update new Application__c(
                    Id = applicationId,
                    Shared_IP_User_Count_30Day__c = sharedCount
            );
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN, 'ApplicationSharedIpCount: failed to update Shared_IP_User_Count_30Day__c. ' + ex.getTypeName() + ': ' + ex.getMessage());
        }
    }

    /**
     * @description Pure aggregate calculation: counts distinct Contacts across all Submission-type
     * Application_Login__c rows sharing the given IP address, created in the trailing 30 days.
     * Exposed as its own method (rather than inlined into updateSharedIpCount) so it can be
     * called and asserted on independently of the Application__c update side effect.
     *
     * @param ipAddress The IP address to count shared usage for.
     * @return The count of distinct Contacts sharing that IP in the trailing 30 days. Zero if
     *         ipAddress is blank or no matching rows exist.
     */
    public static Integer countDistinctContactsForIp(String ipAddress) {
        if (String.isBlank(ipAddress)) {
            return 0;
        }

        DateTime thirtyDaysAgo = DateTime.now().addDays(-30);

        List<AggregateResult> results = [
                SELECT COUNT_DISTINCT(Contact__c) contactCount
                FROM Application_Login__c
                WHERE IP_Address__c = :ipAddress
                AND Event_Type__c = 'Submission'
                AND CreatedDate >= :thirtyDaysAgo
        ];

        if (results.isEmpty() || results[0].get('contactCount') == null) {
            return 0;
        }

        return (Integer) results[0].get('contactCount');
    }
}
