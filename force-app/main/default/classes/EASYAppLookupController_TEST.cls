@IsTest
private class EASYAppLookupController_TEST {

    @TestSetup
    static void setup() {
        Application_Control__c activeControl = new Application_Control__c(
                Name = 'Undergraduate 2026',
                Active__c = true,
                Application_Start_Status__c = 'Started App',
                Submit_Status__c = 'Submitted App'
        );
        // Active, but with no requirement shown on the review pages (like a shell control)
        Application_Control__c noReviewContentControl = new Application_Control__c(
                Name = 'Shell Control',
                Active__c = true,
                Application_Start_Status__c = 'Started App'
        );
        Application_Control__c inactiveControl = new Application_Control__c(
                Name = 'Retired Control',
                Active__c = false,
                Application_Start_Status__c = 'Started App'
        );
        insert new List<Application_Control__c>{activeControl, inactiveControl, noReviewContentControl};

        insert new Requirement__c(
                Name = 'Personal Information',
                Label__c = 'Personal Information',
                Application_Control__c = activeControl.Id,
                Active__c = true,
                Display_on_Admin_Review_Pages__c = true,
                Show_on_Application_Creation__c = false
        );
        // Requirements that do not count as review content for the shell control
        insert new List<Requirement__c>{
                new Requirement__c(Name = 'Hidden', Application_Control__c = noReviewContentControl.Id,
                        Active__c = true, Display_on_Admin_Review_Pages__c = false, Show_on_Application_Creation__c = false),
                new Requirement__c(Name = 'Creation only', Application_Control__c = noReviewContentControl.Id,
                        Active__c = true, Display_on_Admin_Review_Pages__c = true, Show_on_Application_Creation__c = true)
        };

        Academic_Term__c term = new Academic_Term__c(
                Name = 'Fall 2026',
                Term_Start_Date__c = Date.newInstance(2026, 9, 1)
        );
        insert term;

        Contact con1 = new Contact(LastName = 'Smith', FirstName = 'Jane');
        Contact con2 = new Contact(LastName = 'Jones', FirstName = 'John');
        insert new List<Contact>{con1, con2};

        Application__c app1 = new Application__c(
                Contact__c = con1.Id,
                Application_Control__c = activeControl.Id,
                Intended_Term_of_Entry__c = term.Id,
                Application_Status__c = 'Submitted App'
        );
        Application__c app2 = new Application__c(
                Contact__c = con2.Id,
                Application_Control__c = activeControl.Id,
                Intended_Term_of_Entry__c = term.Id,
                Application_Status__c = 'Started App'
        );
        insert new List<Application__c>{app1, app2};
    }

    // ── getApplicationControls: Positive / Negative ────────────────────────

    @IsTest
    static void getApplicationControls_returnsOnlyActiveControlsWithReviewContent() {
        Test.startTest();
        List<EASYAppLookupController.OptionWrapper> results = EASYAppLookupController.getApplicationControls();
        Test.stopTest();

        System.assertEquals(1, results.size(),
                'Inactive controls and controls with no review content (shells) should not be listed');
        System.assertEquals('Undergraduate 2026', results[0].label);
        System.assertEquals('Submitted App', results[0].submitStatus, 'The control carries its Submit Status');
    }

    // ── getApplicationStatuses ─────────────────────────────────────────────

    @IsTest
    static void getApplicationStatuses_returnsPicklistValuesInOrder() {
        Test.startTest();
        List<EASYAppLookupController.OptionWrapper> results = EASYAppLookupController.getApplicationStatuses();
        Test.stopTest();

        List<Schema.PicklistEntry> entries = Application__c.Application_Status__c.getDescribe().getPicklistValues();
        System.assert(!results.isEmpty(), 'Expected the Application Status picklist values');
        System.assertEquals(entries[0].getValue(), results[0].value);
        System.assertEquals(null, results[0].submitStatus);
    }

    // ── getTermsForControl: Positive / Negative ────────────────────────────

    @IsTest
    static void getTermsForControl_returnsTermsWithApplications() {
        Application_Control__c control = [SELECT Id FROM Application_Control__c WHERE Name = 'Undergraduate 2026' LIMIT 1];

        Test.startTest();
        List<EASYAppLookupController.OptionWrapper> results = EASYAppLookupController.getTermsForControl(control.Id);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('Fall 2026', results[0].label);
    }

    @IsTest
    static void getTermsForControl_blankControlId_returnsEmptyList() {
        Test.startTest();
        List<EASYAppLookupController.OptionWrapper> results = EASYAppLookupController.getTermsForControl(null);
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    // ── searchApplicants: Positive / Negative / Bulk ───────────────────────

    @IsTest
    static void searchApplicants_matchesByLastName() {
        Application_Control__c control = [SELECT Id FROM Application_Control__c WHERE Name = 'Undergraduate 2026' LIMIT 1];
        Academic_Term__c term = [SELECT Id FROM Academic_Term__c LIMIT 1];

        Test.startTest();
        List<EASYAppLookupController.ApplicantResult> results = EASYAppLookupController.searchApplicants(
                control.Id, term.Id, 'Smith', null
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('Smith, Jane', results[0].fullName);
    }

    @IsTest
    static void searchApplicants_matchesByFirstAndLastNameTogether() {
        Application_Control__c control = [SELECT Id FROM Application_Control__c WHERE Name = 'Undergraduate 2026' LIMIT 1];
        Academic_Term__c term = [SELECT Id FROM Academic_Term__c LIMIT 1];

        Test.startTest();
        List<EASYAppLookupController.ApplicantResult> results = EASYAppLookupController.searchApplicants(
                control.Id, term.Id, 'John Jones', null
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('Jones, John', results[0].fullName);
    }

    @IsTest
    static void searchApplicants_noMatch_returnsEmptyList() {
        Application_Control__c control = [SELECT Id FROM Application_Control__c WHERE Name = 'Undergraduate 2026' LIMIT 1];
        Academic_Term__c term = [SELECT Id FROM Academic_Term__c LIMIT 1];

        Test.startTest();
        List<EASYAppLookupController.ApplicantResult> results = EASYAppLookupController.searchApplicants(
                control.Id, term.Id, 'Nonexistent', null
        );
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    @IsTest
    static void searchApplicants_blankSearchTerm_returnsEmptyList() {
        Application_Control__c control = [SELECT Id FROM Application_Control__c WHERE Name = 'Undergraduate 2026' LIMIT 1];
        Academic_Term__c term = [SELECT Id FROM Academic_Term__c LIMIT 1];

        Test.startTest();
        List<EASYAppLookupController.ApplicantResult> results = EASYAppLookupController.searchApplicants(
                control.Id, term.Id, '', null
        );
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    @IsTest
    static void searchApplicants_respectsTwentyRecordLimit() {
        Application_Control__c control = [SELECT Id FROM Application_Control__c WHERE Name = 'Undergraduate 2026' LIMIT 1];
        Academic_Term__c term = [SELECT Id FROM Academic_Term__c LIMIT 1];

        List<Contact> bulkContacts = new List<Contact>();
        for (Integer i = 0; i < 25; i++) {
            bulkContacts.add(new Contact(LastName = 'BulkMatch', FirstName = 'Applicant' + i));
        }
        insert bulkContacts;

        List<Application__c> bulkApps = new List<Application__c>();
        for (Contact c : bulkContacts) {
            bulkApps.add(new Application__c(
                    Contact__c = c.Id,
                    Application_Control__c = control.Id,
                    Intended_Term_of_Entry__c = term.Id
            ));
        }
        insert bulkApps;

        Test.startTest();
        List<EASYAppLookupController.ApplicantResult> results = EASYAppLookupController.searchApplicants(
                control.Id, term.Id, 'BulkMatch', null
        );
        Test.stopTest();

        System.assertEquals(20, results.size(), 'Result set should be capped at 20');
    }

    @IsTest
    static void searchApplicants_preferredName_isShownInsteadOfTheLegalFirstName() {
        Contact preferredContact = [SELECT Id FROM Contact WHERE LastName = 'Smith'];
        preferredContact.Preferred_First_Name__c = 'Janie';
        update preferredContact;
        Application_Control__c control = [SELECT Id FROM Application_Control__c WHERE Name = 'Undergraduate 2026' LIMIT 1];
        Academic_Term__c term = [SELECT Id FROM Academic_Term__c LIMIT 1];

        Test.startTest();
        List<EASYAppLookupController.ApplicantResult> byLegalName = EASYAppLookupController.searchApplicants(
                control.Id, term.Id, 'Jane', null
        );
        List<EASYAppLookupController.ApplicantResult> byPreferredName = EASYAppLookupController.searchApplicants(
                control.Id, term.Id, 'Janie', null
        );
        Test.stopTest();

        System.assertEquals(1, byLegalName.size(), 'The legal first name still finds the applicant');
        System.assertEquals('Smith, Janie', byLegalName[0].fullName, 'The preferred name is the one shown');
        System.assertEquals(1, byPreferredName.size());
    }

    // ── searchApplicants: status filter ────────────────────────────────────

    @IsTest
    static void searchApplicants_withStatus_returnsOnlyApplicationsInThatStatus() {
        Application_Control__c control = [SELECT Id FROM Application_Control__c WHERE Active__c = TRUE AND Name = 'Undergraduate 2026'];
        Academic_Term__c term = [SELECT Id FROM Academic_Term__c LIMIT 1];

        Test.startTest();
        List<EASYAppLookupController.ApplicantResult> submitted = EASYAppLookupController.searchApplicants(
                control.Id, term.Id, 'J', 'Submitted App'
        );
        List<EASYAppLookupController.ApplicantResult> every = EASYAppLookupController.searchApplicants(
                control.Id, term.Id, 'J', null
        );
        Test.stopTest();

        System.assertEquals(1, submitted.size(), 'Only the Submitted App application matches the status');
        System.assertEquals('Smith, Jane', submitted[0].fullName);
        System.assertEquals('Submitted App', submitted[0].status, 'The result shows its status');
        System.assertEquals(2, every.size(), 'A blank status searches every status');
    }
}