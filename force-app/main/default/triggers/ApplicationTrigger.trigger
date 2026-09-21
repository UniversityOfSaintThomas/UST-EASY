/**
 * Detects when an Application__c's Application_Status__c changes to the value configured as
 * that application's "submitted" status (Application_Control__r.Submit_Status__c), and dispatches
 * fraud-monitoring capture (reCAPTCHA + environmental variables) for that submission event.
 *
 * Deliberately reacts to the DATA CHANGE itself rather than any particular Apex call site -
 * ApplicationRequirement.cls, ApplicationChecklist.cls, and ApplicationChecklistComponentController.cls
 * all set Application_Status__c to a submission value through different code paths, and this
 * trigger is resilient to all of them (and to any future call site) without requiring changes to
 * any of them.
 *
 * Kept deliberately lightweight to avoid slowing down the object's existing triggered Flows: no
 * SOQL, no DML, and no synchronous callouts happen in this trigger context - it only compares
 * already-loaded field values and, on a genuine match, dispatches a fire-and-forget
 * @future(callout=true) method (see ApplicationTriggerHandler.captureSubmissionAsync) that runs
 * in its own transaction after this one commits. See docs/fraud-monitoring-recaptcha-ip-geo.md
 * ("Application submission trigger point") for the full design rationale.
 */
trigger ApplicationTrigger on Application__c (after update) {
    ApplicationTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
}
