/**
 * Created by jjheaney on 5/2/2022.
 */

public class ScholarshipClosedController {
    public Scholarship__c scholarship { get; set; }
    public boolean scholarshipNotYetOpen {get; set;}
    public boolean scholarshipAlreadyClosed {get; set;}

    public ScholarshipClosedController() {
        String sId = ApexPages.currentPage().getParameters().get('sid');
        if (!String.isBlank(sId)) {
            this.scholarship = ScholarshipSharedUtilities.getScholarshipInfo(sId);

            if (this.scholarship.Open_Date__c >= ScholarshipSharedUtilities.adjustForCentralTime(Datetime.now())) {
                this.scholarshipNotYetOpen = true;
            } else if (this.scholarship.Close_Date__c <= ScholarshipSharedUtilities.adjustForCentralTime(Datetime.now())) {
                this.scholarshipAlreadyClosed = false;
            }
        }
    }
}