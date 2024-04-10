/**
 * Created by jjheaney on 5/12/2022.
 */

public with sharing class ScholarshipApplicationCompleteController {
    public Scholarship__c scholarship { get; set; }

    public ScholarshipApplicationCompleteController() {
        String sId = ApexPages.currentPage().getParameters().get('sid');
        if (!String.isBlank(sId)) {
            scholarship = ScholarshipSharedUtilities.getScholarshipInfo(sId);
        }
    }

}