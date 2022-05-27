/**
 * Created by jjheaney on 5/12/2022.
 */

public with sharing class ScholarshipApplicationPage2Controller {
    public String pageURL { get; set; }
    public Scholarship__c scholarship { get; set; }
    public Scholarship_Applicant__c applicant { get; set; }
    public boolean essay1HasText { get; set; }
    public boolean essay2HasText { get; set; }
    public String essay1Filename { get; set; }
    public String essay2Filename { get; set; }
    public Attachment essay1 { get {if (essay1 == null) essay1 = new Attachment(); return essay1;} set; }
    public Attachment essay2 { get {if (essay2 == null) essay2 = new Attachment(); return essay2;} set; }
    public Datetime recommendRequestDate1 { get; set; }
    public Datetime recommendRequestDate2 { get; set; }

    public PageReference initialize() {
        String sId = ApexPages.currentPage().getParameters().get('sid');
        System.debug('page2.initialize(): sID: ' + sId);
        String scholarshipId = null;

        if (!String.isBlank(sId)) {
            scholarshipId = sId;
            this.scholarship = ScholarshipSharedUtilities.getScholarshipInfo(sId);
            System.debug('Ln26scholarship' + this.scholarship);
            this.applicant = ScholarshipSharedUtilities.getApplicantInfo(this.scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
            essay1HasText = !String.isEmpty(this.applicant.Essay_1_Answer__c);
            essay2HasText = !String.isEmpty(this.applicant.Essay_2_Answer__c);
            if (this.applicant.Recommendation_Request_Date__c != null) {
                recommendRequestDate1 = ScholarshipSharedUtilities.adjustForCentralTime(this.applicant.Recommendation_Request_Date__c);
            }
            if (this.applicant.Recommendation2_Request_Date__c != null) {
                recommendRequestDate2 = ScholarshipSharedUtilities.adjustForCentralTime(this.applicant.Recommendation2_Request_Date__c);
            }
        }

        return redirectCheck(scholarshipId);
    }

    public PageReference redirectCheck(String scholarshipId) {
        PageReference result;

        // Need a scholarshipId.
        if (String.isEmpty(scholarshipId)) {
            result = Page.ScholarshipHome.setRedirect(true);

        // Need a scholarship.
        } else if (this.scholarship == null) { // It's unclear whether this is reachable in practice, but I hesitate to change it.
            System.debug('Ln50scholarship' + this.scholarship);
            result = Page.ScholarshipHome.setRedirect(true);

        // Need an incomplete applicant.
        } else if (this.applicant == null) {
            result = Page.ScholarshipApplicationPage1.setRedirect(true);

        // Need an incomplete application.
        } else if (this.applicant.Scholarship_Complete__c) {
            result = new PageReference('/ScholarshipApplicationComplete?sid=' + scholarshipId); //return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationComplete, false, scholarshipId); // This looks to me like it should work, but is commented out in the original, so I won't mess with it YET. -JJH

        // Need scholarship to be open currently.
        } else if (!ScholarshipSharedUtilities.isScholarshipOpen(this.scholarship)) {
            result = ScholarshipSharedUtilities.setSid(Page.ScholarshipClosed, false, scholarshipId);

        // Okay, we're good. Return null and there will be no redirect out of here.
        } else {
            result = null;
        }
        return result;
    }

    private boolean uploadEssay(Attachment essay, Integer essayNum, String filename) {
        boolean result;

        String ext = getFileExtension(filename);
        System.debug('ext/essay:' + ext + '::' + essay + '::' + essay.Id);
        essay.OwnerId = UserInfo.getUserId();
        System.debug('essay.ParentId BEFORE:' + essay.ParentId);
        essay.ParentId = this.applicant.Id; // the record the file is attached to
        System.debug('essay.ParentId AFTER:' + essay.ParentId);
        essay.IsPrivate = false;
        essay.name = 'Essay' + essayNum + ext;
        essay.Description = 'Essay ' + essayNum + ' Upload. Original Filename was ' + filename;

        try {
            insert essay;

            // I'm sure these field names can be accessed programmatically at some point, but for now we're just doing
            // straight adaptation from the original code until it's working! Until then, I know, kinda grody. -JJH
            if (essayNum == 1) {
                this.applicant.Essay_1_Uploaded__c = true;
                this.applicant.Essay_1_Uploaded_Orig_Filename__c = filename;
            } else if (essayNum == 2) {
                this.applicant.Essay_2_Uploaded__c = true;
                this.applicant.Essay_2_Uploaded_Orig_Filename__c = filename;
            }
            upsert this.applicant;
            result = true;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading essay' + essayNum + ' attachment'));
            result = false;
        } finally {
            essay = new Attachment();
        }

        if (result == true) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Essay ' + essayNum + ' uploaded successfully'));
        }
        return result;
    }

    public PageReference UploadEssay1() {
        uploadEssay(this.essay1, 1, this.essay1Filename);
        return null;
    }
    public PageReference UploadEssay2() {
        uploadEssay(this.essay2, 2, this.essay2Filename);
        return null;
    }

    private void deleteEssay(Integer essayNum) {
        String essaySearch = 'Essay' + essayNum + '.%';
        List<Attachment> att1 = [select id, name from Attachment where parent.id = :this.applicant.id AND name LIKE :essaySearch];
        try {
            for (Attachment att : att1) {
                delete att;
            }
            if (essayNum == 1) {
                this.applicant.Essay_1_Uploaded__c = false;
            } else if (essayNum == 2) {
                this.applicant.Essay_2_Uploaded__c = false;
            }
            upsert this.applicant;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No attachment to delete'));
        }
    }

    public void DeleteEssay1() {
        deleteEssay(1);
    }
    public void DeleteEssay2() {
        deleteEssay(2);
    }

    public void SendRecommenderEmail() {
        String RecEmail = '';
        String RecName = '';
        String RecLink = '';
        String RecMessage = '';
        String RecSubject = 'University of St. Thomas ' + this.scholarship.Name;
        String styledP = '<p style="margin: 10px 0;padding: 0;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: rgb(85, 85, 85);font-family: Palatino Linotype, Georgia, serif;font-size: 16px;line-height: 150%;text-align: left;">';
        for (Integer xx = 1; xx < 3; xx++) {
            RecEmail = '';
            RecName = '';
            RecLink = Site.getBaseSecureUrl() + '/ScholarshipRecommender';
            recMessage = styledP + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' has applied for the ' + this.scholarship.Name + ' at the University of St. Thomas and indicated that you would be willing to write a recommendation. </p>';
            if (this.scholarship.Description__c != null) {
                recMessage += styledP + '<strong>Scholarship Description</strong><br/>' + this.scholarship.Description__c + '</p>';
            }

            if (xx == 1
                    && this.scholarship.Recommender_Auto_Send__c
                    && String.isNotBlank(this.applicant.Recommender_Email__c)
                    && String.isNotBlank(this.applicant.Recommender_Name__c)
                    && this.applicant.Recommendation_Request_Date__c == null
                    ) {

                RecEmail = this.applicant.Recommender_Email__c;
                RecName = this.applicant.Recommender_Name__c;
                RecLink += '?recid=' + this.applicant.Id + '1';
                if (this.scholarship.Recommender_Question__c != null) {
                    recMessage += styledP + this.scholarship.Recommender_Question__c + '</p>';
                }
                recMessage += styledP + '<a href="' + RecLink + '" class="button">Submit your recommendation</a></p>';
            }
            if (xx == 2
                    && this.scholarship.Recommender2_Auto_Send__c
                    && String.isNotBlank(this.applicant.Recommender2_Email__c)
                    && String.isNotBlank(this.applicant.Recommender2_Name__c)
                    && this.applicant.Recommendation2_Request_Date__c == null
                    ) {
                RecEmail = this.applicant.Recommender2_Email__c;
                RecName = this.applicant.Recommender2_Name__c;
                RecLink += '?recid=' + this.applicant.Id + '2';
                if (this.scholarship.Recommender2_Question__c != null) {
                    recMessage += styledP + this.scholarship.Recommender2_Question__c + '</p>';
                }
                recMessage += styledP + '<a href="' + RecLink + '" class="button">Submit your recommendation</a></p>';
            }


            if (!String.isEmpty(RecEmail)) {
                ScholarshipSharedUtilities.sendEmail(RecName, RecEmail, RecSubject, RecMessage, RecMessage, this.scholarship.Name);
                if (String.isNotBlank(this.applicant.Recommender_Name__c) && String.isNotBlank(this.applicant.Recommender_Email__c)) {
                    this.applicant.Recommendation_Request_Date__c = Datetime.now();
                    recommendRequestDate1 = ScholarshipSharedUtilities.adjustForCentralTime(Datetime.now());
                }
                if (String.isNotBlank(this.applicant.Recommender2_Name__c) && String.isNotBlank(this.applicant.Recommender2_Email__c)) {
                    this.applicant.Recommendation2_Request_Date__c = Datetime.now();
                    recommendRequestDate2 = ScholarshipSharedUtilities.adjustForCentralTime(Datetime.now());
                }
                upsert this.applicant;
            }
        }
    }

    public void SaveFinishLater() {
        try {
            upsert this.applicant;
            this.essay1HasText = !String.isEmpty(this.applicant.Essay_1_Answer__c);
            this.essay2HasText = !String.isEmpty(this.applicant.Essay_2_Answer__c);
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        String msgComplete = 'Your scholarship application has been saved and you can return to it at any time.';
        msgComplete += ' It has not been completed and will not be considered for an award until you complete it by clicking \"Save & Complete\" below.';

        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, msgComplete));
    }

    public PageReference SaveComplete() {
        try {
            this.applicant.Scholarship_Complete__c = true;
            this.applicant.Scholarship_Status__c = 'Submitted App';
            this.applicant.Scholarship_Date_Submitted__c = Datetime.now();
            upsert this.applicant;
            sendRecommenderEmail();
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        } finally {
            String styledP = '<p style="margin: 10px 0;padding: 0;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: rgb(85, 85, 85);font-family: Palatino Linotype, Georgia, serif;font-size: 16px;line-height: 150%;text-align: left;">';
            String cMessage = '<h2>Your scholarship application has been received!</h2>';

            List<Contact> contactMatches = [select Id, Name, FirstName, LastName, Email from Contact where id = :this.applicant.Contact__c];
            Contact applicantContactRecord = null;
            for (Contact contact : contactMatches) {
                applicantContactRecord = contact;
            }

            cMessage += styledP + applicantContactRecord.FirstName + ' ' + applicantContactRecord.LastName + ',</p>';
            cMessage += styledP + 'Your application to the ' + this.scholarship.Name + ' has been received.</p>';
            if (this.scholarship.Description__c != null) {
                cMessage += styledP + '<strong>Scholarship Description</strong><br/>' + this.scholarship.Description__c + '</p>';
            }
            if (this.scholarship.Review_Award_Process_Description__c != null) {
                cMessage += styledP + '<strong>What happens next?</strong><br/>' + this.scholarship.Review_Award_Process_Description__c + '</p>';
            }
            ScholarshipSharedUtilities.sendEmail(applicantContactRecord.FirstName + ' ' + applicantContactRecord.LastName, applicantContactRecord.Email, 'University of St. Thomas Scholarship', cMessage, cMessage, this.scholarship.Name);
        }
        ScholarshipSharedUtilities.setHistoryPage(this.scholarship.Scholarship_ID__c);
        return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationComplete, false, this.scholarship.Scholarship_ID__c);
    }

    public PageReference GoCriteria() {
        ScholarshipSharedUtilities.setHistoryPage(this.scholarship.Scholarship_ID__c);
        return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage1, false, this.scholarship.Scholarship_ID__c);
    }

    private string getFileExtension(String fn) {
        if (fn != null && fn.contains('.')) {
            fn = fn.substring(fn.lastIndexOf('.'), fn.length());
            return fn;
        }
        return '';
    }
}