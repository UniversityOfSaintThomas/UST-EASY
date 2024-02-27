public class ScholarshipRecommenderController {

    public Id recId { get; set; }
    public Integer incomingRecNum { get; set; }
    public Scholarship_Applicant__c ScholarshipApplicant { get; set; }
    public Contact scholarshipApplicantContactRecord { get; set; }
    public boolean recComplete { get; set; }

    public ScholarshipRecommenderController() {
        String incomingRecId = '';

        //get rec id from the url
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('recid'))) {
            incomingRecId = ApexPages.currentPage().getParameters().get('recid');
        }

        //get recommendation number from last character in rec id in url
        try {
            incomingRecNum = Integer.valueOf(incomingRecId.substring(incomingRecId.length() - 1, incomingRecId.length()));
        } catch (Exception ex) {
            incomingRecNum = 0;
        }

        //If rec number isn't 1 or 2 then error
        if (incomingRecNum <= 0 || incomingRecNum > 2) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not determine recommender number. -- ' + incomingRecId));
        }

        //Check the rest of the recId in url minus the last character to make sure it is an Id
        if(incomingRecId.length() > 2) {
            incomingRecId = incomingRecId.substring(0, incomingRecId.length() - 1);
        }

        try {
            recId = (Id) incomingRecId;
        } catch (Exception ex) {
            recId = null;
        }

        if (recId != null) {
            //get scholarship and applicant object object
            Scholarship_Applicant__c[] applicants = [
                    SELECT Contact__c, Scholarship__c, Recommendation2__c, Recommendation__c, Recommender2_Email__c,
                            Recommender2_Name__c, Recommender_Email__c, Recommender_Name__c, Recommendation_Received__c, Recommendation2_Received__c,
                            Scholarship__r.Description__c, Scholarship__r.Name, Scholarship__r.Recommender2_Question__c, Scholarship__r.Recommender_Question__c,
                            Scholarship__r.Short_Description__c
                    FROM Scholarship_Applicant__c
                    WHERE Id = :recId
                    WITH SECURITY_ENFORCED
            ];
            if (applicants.size() > 0) {
                this.ScholarshipApplicant = applicants.get(0);
                this.ScholarshipApplicant.Id = null;
                if (this.ScholarshipApplicant != null) {
                    this.scholarshipApplicantContactRecord = ScholarshipSharedUtilities.getContactRecord(this.ScholarshipApplicant.Contact__c);
                }

                System.debug(JSON.serializePretty(ScholarshipApplicant));
                if (incomingRecNum == 1) {
                    if (ScholarshipApplicant.Recommendation_Received__c != null) {
                        recComplete = true;
                    }
                } else if (incomingRecNum == 2) {
                    if (ScholarshipApplicant.Recommendation2_Received__c != null) {
                        recComplete = true;
                    }
                }
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not find scholarship applicant record.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not find scholarship applicant record.'));
        }

    }

    public PageReference Save() {
        if (this.ScholarshipApplicant != null) {
            doCRUD CRUDToDo = new doCRUD();
            if (this.incomingRecNum == 1) {
                this.ScholarshipApplicant.Recommendation_Received__c = Datetime.now();
            } else if (this.incomingRecNum == 2) {
                this.ScholarshipApplicant.Recommendation2_Received__c = Datetime.now();
            }
            If (String.isNotBlank(this.recId)) {
                CRUDToDo.saveRecommendation(this.ScholarshipApplicant, this.recId);
                this.recComplete = true;
            }
        }
        return null;
    }

    private without sharing class doCRUD {

        public void saveRecommendation(Scholarship_Applicant__c scholar, Id scholarshipId) {
            scholar.Id = scholarshipId;
            update scholar;
        }

    }

}