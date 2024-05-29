/**
 * Created by jjheaney on 5/12/2022.
 */

public with sharing class ScholarshipApplicationCompleteController {
    public Scholarship__c scholarship { get; set; }

    public ScholarshipApplicationCompleteController() {
        scholarship = ScholarshipSharedUtilities.getScholarshipInfo();
    }

}