/**
 * Created by jjheaney on 5/12/2022.
 */

public with sharing class ScholarshipApplicationPage2Controller {
    public Scholarship__c scholarship { get; set; }
    public Scholarship_Applicant__c applicant { get; set; }
    public Boolean essay1HasText { get; set; }
    public Boolean essay2HasText { get; set; }
    public String essay1Filename { get; set; }
    public String essay2Filename { get; set; }
    public Attachment essay1 {
        get {
            if (essay1 == null) {
                essay1 = new Attachment();
            }
            return essay1;
        }
        set;
    }
    public Attachment essay2 {
        get {
            if (essay2 == null) {
                System.debug('essay2 generated');
                essay2 = new Attachment();
            }
            return essay2;
        }
        set;
    }
    public Datetime recommendRequestDate1 { get; set; }
    public Datetime recommendRequestDate2 { get; set; }
    public String sId { get; set; }

    public ScholarshipApplicationPage2Controller() {
        sId = ApexPages.currentPage().getParameters().get('sid');
        String scholarshipId = null;
        if (!String.isBlank(sId)) {
            scholarshipId = sId;
            scholarship = ScholarshipSharedUtilities.getScholarshipInfo(sId);
            applicant = ScholarshipSharedUtilities.getApplicantInfo(scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
            essay1HasText = !String.isEmpty(applicant.Essay_1_Answer__c);
            essay2HasText = !String.isEmpty(applicant.Essay_2_Answer__c);
            if (applicant.Recommendation_Request_Date__c != null) {
                recommendRequestDate1 = ScholarshipSharedUtilities.adjustForCentralTime(applicant.Recommendation_Request_Date__c);
            }
            if (applicant.Recommendation2_Request_Date__c != null) {
                recommendRequestDate2 = ScholarshipSharedUtilities.adjustForCentralTime(applicant.Recommendation2_Request_Date__c);
            }
        }

    }

    public PageReference initialize() {
        return ScholarshipSharedUtilities.checkScholarshipAccess();
    }

    private PageReference uploadEssay(Attachment essay, Integer essayNum, String filename) {

        String ext = getFileExtension(filename);
        essay.Id = null;
        essay.OwnerId = UserInfo.getUserId();
        if (essay.ParentId != applicant.Id) { // If user deletes and re-uploads, and it tries writing this field, it will find it already written, then explode. This SHOULD therefore only pass on first upload, but it COULD in theory pass if the second uploader somehow doesn't have the same applicant ID as the first uploader. That will still cause it to explode, and rightly so.
            essay.ParentId = applicant.Id; // the scholarship applicant record the file is attached to
        }
        essay.IsPrivate = false;
        essay.Name = 'Essay' + essayNum + ext;
        essay.Description = 'Essay ' + essayNum + ' Upload. Original Filename was ' + filename;

        try {
            // I'm sure these field names can be accessed programmatically at some point, but for now we're just doing
            // straight adaptation from the original code until it's working! Until then, I know, kinda grody. -JJH
            if (essayNum == 1) {
                applicant.Essay_1_Uploaded__c = true;
                applicant.Essay_1_Uploaded_Orig_Filename__c = filename;
            } else if (essayNum == 2) {
                applicant.Essay_2_Uploaded__c = true;
                applicant.Essay_2_Uploaded_Orig_Filename__c = filename;
            }
            insert essay;
            upsert applicant;
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error uploading essay' + essayNum + ' attachment'));
        } finally {
            essay.Body = null; // If you don't explicitly erase the body, the Viewstate will crash (if the body is more than ~215KB). (Viewstate says 170KB but must be applying compression of some kind.)
            essay = new Attachment();
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Essay ' + essayNum + ' uploaded successfully'));
        return null;
    }

    public PageReference UploadEssay1() {
        uploadEssay(essay1, 1, essay1Filename);
        return null;
    }
    public PageReference UploadEssay2() {
        uploadEssay(essay2, 2, essay2Filename);
        return null;
    }

    private void deleteEssay(Integer essayNum) {
        String essaySearch = 'Essay' + essayNum + '.%';
        List<Attachment> att1 = [
                SELECT Id, Name
                FROM Attachment
                WHERE Parent.id = :applicant.Id
                AND Name LIKE :essaySearch
        ];
        try {
            for (Attachment att : att1) {
                delete att;
            }
            if (essayNum == 1) {
                applicant.Essay_1_Uploaded__c = false;
            } else if (essayNum == 2) {
                applicant.Essay_2_Uploaded__c = false;
            }
            upsert applicant;
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No attachment to delete'));
        }
    }

    public void DeleteEssay1() {
        deleteEssay(1);
    }
    public void DeleteEssay2() {
        deleteEssay(2);
    }

    public PageReference SendRecommenderEmail() {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        PageReference redirectPage = Page.ScholarshipApplicationPage2;
        redirectPage.setRedirect(true);
        redirectPage.getParameters().put('sid', sid);
        //return redirectPage;

        System.debug('applicant: ' + JSON.serializePretty(applicant));

        String recName1 = applicant.Recommender_Name__c;
        String recEmail1 = applicant.Recommender_Email__c;
        String recLink1 = applicant.Recommendation_Link__c;

        String recName2 = applicant.Recommender2_Name__c;
        String recEmail2 = applicant.Recommender2_Email__c;
        String recLink2 = applicant.Recommendation_Link_2__c;

        System.debug('recName1: ' + recName1 + ' recEmail1: ' + recEmail1 + ' recName2: ' + recName2 + ' recEmail2: ' + recEmail2);
        Boolean recSent = false;
        String RecSubject = 'University of St. Thomas ' + scholarship.Name;
        String styles = ' style="margin: 10px 0;padding: 0;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: rgb(85, 85, 85);font-family: Palatino Linotype, Georgia, serif;font-size: 16px;line-height: 150%;text-align: left;"';
        String styledP = '<p ' + styles + '>';
        String RecMessage = styledP + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' has applied for the ' + scholarship.Name + ' at the University of St. Thomas and indicated that you would be willing to write a recommendation. </p>';
        if (String.isNotBlank(scholarship.Description__c)) {
            String scholarshipDescription = scholarship.Description__c;
            scholarshipDescription = scholarshipDescription.replaceAll('<p>', styledP);
            scholarshipDescription = scholarshipDescription.replaceAll('<ul>', '<ul ' + styles + '>');
            scholarshipDescription = scholarshipDescription.replaceAll('<li>', '<li ' + styles + '>');
            RecMessage += styledP + '<strong>Scholarship Description</strong><br/>' + scholarshipDescription + '</p>';
        }
        if (String.isNotBlank(scholarship.Recommender_Question__c)) {
            RecMessage += styledP + scholarship.Recommender_Question__c + '</p>';
        }

        if (String.isNotBlank(recName1) && String.isNotBlank(recEmail1) && applicant.Recommendation_Request_Date__c == null) {
            RecMessage += styledP + '<a href="' + recLink1 + '" class="button">Submit your recommendation</a></p>';
            if (!String.isEmpty(recEmail1)) {
                emailsToSend.add(ScholarshipSharedUtilities.sendEmail(recName1, recEmail1, RecSubject, RecMessage, RecMessage, scholarship.Name));
                applicant.Recommendation_Request_Date__c = Datetime.now();
            }
        }

        if (String.isNotBlank(recName2) && String.isNotBlank(recEmail2) && applicant.Recommendation2_Request_Date__c == null) {
            RecMessage += styledP + '<a href="' + recLink2 + '" class="button">Submit your recommendation</a></p>';
            if (!String.isEmpty(recEmail2)) {
                emailsToSend.add(ScholarshipSharedUtilities.sendEmail(recName2, recEmail2, RecSubject, RecMessage, RecMessage, scholarship.Name));
            }
        }

        upsert applicant;

        if (emailsToSend.size() > 0) {
            try {
                Messaging.sendEmail(emailsToSend);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Recommendation request sent'));
            } catch (Exception ex) {
                //If the email fails, we want to add the error message to the activity task description
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No recommendation request sent' + ex.getMessage()));
                System.debug(ex.getMessage());
                return null;
            }
        }
        return redirectPage;
    }

    public PageReference SaveFinishLater() {
        try {
            upsert applicant;
            essay1HasText = !String.isEmpty(applicant.Essay_1_Answer__c);
            essay2HasText = !String.isEmpty(applicant.Essay_2_Answer__c);
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        String msgComplete = 'Your scholarship application has been saved and you can return to it at any time.';
        msgComplete += ' It has not been completed and will not be considered for an award until you complete it by clicking \"Save & Complete\" below.';

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, msgComplete));
        return null;
    }

    public PageReference SaveComplete() {
        try {
            applicant.Scholarship_Complete__c = true;
            applicant.Scholarship_Status__c = 'Submitted App';
            applicant.Scholarship_Date_Submitted__c = Datetime.now();
            upsert applicant;
        } catch (DmlException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        } finally {
            SendRecommenderEmail();
            String styledP = '<p style="margin: 10px 0;padding: 0;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: rgb(85, 85, 85);font-family: Palatino Linotype, Georgia, serif;font-size: 16px;line-height: 150%;text-align: left;">';
            String cMessage = '<h2>Your scholarship application has been received!</h2>';
            String firstName = 'FirstName';
            String lastName = 'LastName';
            String email = 'EmailAddress@InsertEmailDomain.Unknown';
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

            List<Contact> contactMatches = [
                    SELECT Id, Name, FirstName, LastName, Email
                    FROM Contact
                    WHERE Id = :applicant.Contact__c
            ];
            for (Contact contact : contactMatches) {
                firstName = contact.FirstName;
                lastName = contact.LastName;
                email = contact.Email;
            }

            cMessage += styledP + firstName + ' ' + lastName + ',</p>';
            cMessage += styledP + 'Your application to the ' + scholarship.Name + ' has been received.</p>';
            if (scholarship.Description__c != null) {
                cMessage += styledP + '<strong>Scholarship Description</strong><br/>' + scholarship.Description__c + '</p>';
            }
            if (scholarship.Review_Award_Process_Description__c != null) {
                cMessage += styledP + '<strong>What happens next?</strong><br/>' + scholarship.Review_Award_Process_Description__c + '</p>';
            }
            emailsToSend.add(ScholarshipSharedUtilities.sendEmail(firstName + ' ' + lastName, email, 'University of St. Thomas Scholarship', cMessage, cMessage, scholarship.Name));

            if (emailsToSend.size() > 0) {
                try {
                    upsert applicant;
                    Messaging.sendEmail(emailsToSend);
                } catch (Exception ex) {
                    //If the email fails, we want to add the error message to the activity task description
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Scholarship not saved: ' + ex.getMessage()));
                    return null;
                }
            }

        }
        return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationComplete, false, scholarship.Scholarship_ID__c);
    }

    public PageReference GoCriteria() {
        return ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationPage1, false, scholarship.Scholarship_ID__c);
    }

    private static String getFileExtension(String fn) {
        if (fn != null && fn.contains('.')) {
            fn = fn.substring(fn.lastIndexOf('.'), fn.length());
            return fn;
        }
        return '';
    }
}