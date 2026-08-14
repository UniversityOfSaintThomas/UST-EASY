/**
 * Created by jjheaney on 5/12/2022.
 */

public with sharing class ScholarshipApplicationPage2Controller {
//    public String pageURL { get; set; }
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
                essay2 = new Attachment();
            }
            return essay2;
        }
        set;
    }
    public List<String> recommenderCheck {
        get {
            return new List<String>{'','2'};
        }
    }
    public Datetime recommendRequestDate1 { get; set; }
    public Datetime recommendRequestDate2 { get; set; }
    public String sId { get; set; }
    public Boolean recommendRequestNow1 {
        get {
            if (recommendRequestNow1 == null) {
                recommendRequestNow1 = false;
            }
            return recommendRequestNow1;
        }
        set;
    }
    public Boolean recommendRequestNow2 {
        get {
            if (recommendRequestNow2 == null) {
                recommendRequestNow2 = false;
            }
            return recommendRequestNow2;
        }
        set;
    }
    public Boolean resendRecommendationRequestBool {
        get {
            if (resendRecommendationRequestBool == null) {
                resendRecommendationRequestBool = false;
            }
            return resendRecommendationRequestBool;
        }
        set;
    }
    public Boolean resendRecommendation1 {
        get {
            if (resendRecommendation1 == null) {
                resendRecommendation1 = false;
            }
            return resendRecommendation1;
        }
        set;
    }
    public Boolean resendRecommendation2 {
        get {
            if (resendRecommendation2 == null) {
                resendRecommendation2 = false;
            }
            return resendRecommendation2;
        }
        set;
    }
    private ScholarshipSharedUtilities.emailUtilities emailBuilder { get; set; }

    public ScholarshipApplicationPage2Controller() {
        emailBuilder = new ScholarshipSharedUtilities.emailUtilities();
        scholarship = ScholarshipSharedUtilities.getScholarshipInfo();
        if (scholarship != null) {
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

        List<String> pageMessage = ScholarshipSharedUtilities.PageMessage();
        if (pageMessage.size() == 2) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.valueOf(pageMessage[0]), pageMessage[1]));
        }
    }

    //Constructor for use with Recommendation Request Resend LWC
    public ScholarshipApplicationPage2Controller(String scholarshipId, String ContactId) {
        emailBuilder = new ScholarshipSharedUtilities.emailUtilities();
    }

    public PageReference initialize() {
        return ScholarshipSharedUtilities.checkScholarshipAccess();
    }

    private PageReference uploadEssay(Attachment essay, Integer essayNum, String filename) {

        String ext = getFileExtension(filename);
        // check if file extension is allowed (.pdf, .doc, .docx, .txt, .rtf);
        if (ext != '.pdf' && ext != '.doc' && ext != '.docx' && ext != '.txt' && ext != '.rtf') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid file type. Please upload a .pdf, .doc, .docx, .txt, or .rtf file.'));
            return null;
        }
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error uploading essay ' + essayNum + ' attachment. '));
            return null;
        } finally {
            essay.Body = null; // If you don't explicitly erase the body, the Viewstate will crash (if the body is more than ~215KB). (Viewstate says 170KB but must be applying compression of some kind.)
            essay = new Attachment();
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Essay ' + essayNum + ' uploaded successfully. '));
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
        redirectPage.getParameters().put('sid', sId);

        try {
            upsert applicant;

        String recName1 = applicant.Recommender_Name__c;
        String recEmail1 = applicant.Recommender_Email__c;

        String recName2 = applicant.Recommender2_Name__c;
        String recEmail2 = applicant.Recommender2_Email__c;

        if (String.isNotBlank(recName1) && String.isNotBlank(recEmail1) && ((applicant.Recommendation_Request_Date__c == null && recommendRequestNow1) || resendRecommendation1)) {
                try {
                    emailsToSend.add(emailBuilder.createEmail(scholarship.Recommender_Email_Template_Id__c, scholarship.Org_Wide_Email_Id__c, applicant.Id, applicant.Contact__c, recEmail1));
                applicant.Recommendation_Request_Date__c = Datetime.now();
                } catch (Exception ex) {
                    recommendRequestNow1 = false;
                    resendRecommendation1 = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommender 1 Email Template exception: ' + ex.getMessage()));
                    System.debug('Recommender 1 Email Template exception: ' + ex.getMessage());
                    return null;
            }
        }
        if (String.isNotBlank(recName2) && String.isNotBlank(recEmail2) && ((applicant.Recommendation2_Request_Date__c == null && recommendRequestNow2) || resendRecommendation2)) {
                try {
                    emailsToSend.add(emailBuilder.createEmail(scholarship.Recommender2_Email_Template_Id__c, scholarship.Org_Wide_Email_Id__c, applicant.Id, applicant.Contact__c, recEmail2));
                applicant.Recommendation2_Request_Date__c = Datetime.now();
                } catch (Exception ex) {
                    recommendRequestNow2 = false;
                    resendRecommendation2 = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommender 2 Email Template exception: ' + ex.getMessage()));
                    System.debug('Recommender 2 Email Template exception: ' + ex.getMessage());
                    return null;
            }
        }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommender information not saved. No Request Sent'));
            System.debug('Recommender information not saved. No Request Sent: ' + ex.getMessage());
            return null;
        }

        if (emailsToSend.size() > 0) {
            try {
                emailBuilder.sendCreatedEmails(emailsToSend);
            } catch (Exception ex) {
                if (recommendRequestNow1 || recommendRequestNow2) {
                //If the email fails, we want to add the error message to the activity task description
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommendation saved. No request email sent.'));
                    System.debug('Recommendation saved. No request email sent: '+ex.getMessage());
                    return null;
                }
            }
            try {
                upsert applicant;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Request email sent but recommendation request date not saved'));
                System.debug('Request email sent but recommendation request date not saved: '+ex.getMessage());
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
        String msgComplete = '<strong>Saved:</strong> Your scholarship application has been saved and you can return to it at any time. ';
        msgComplete += 'Your scholarship will not be submitted until you click “Save & Submit” below.';

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, msgComplete));
        return null;
    }

    public PageReference SaveComplete() {
        PageReference pageRef = ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationComplete, false, scholarship.Scholarship_ID__c);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        recommendRequestNow1 = true;
        recommendRequestNow2 = true;
        PageReference recommendRedirect = SendRecommenderEmail();

        if (recommendRedirect != null) {
        try {
            applicant.Scholarship_Complete__c = true;
            applicant.Scholarship_Status__c = 'Submitted App';
            applicant.Scholarship_Date_Submitted__c = Datetime.now();
            upsert applicant;
        } catch (DmlException ex) {
                pageRef = Page.ScholarshipApplicationPage2;
                pageRef.setRedirect(true);
                pageRef.getParameters().put('pageMsg', '3w');
                System.debug('Upsert Applicant exception: ' + ex.getMessage());
                return pageRef;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommendation request error. Scholarship not saved.'));
            return null;
        }

        if (String.isNotEmpty(scholarship.Org_Wide_Email_Id__c) && String.isNotEmpty(scholarship.Submit_Scholarship_Email_Template_Id__c)) {
            try {
                emailsToSend.add(emailBuilder.createEmail(scholarship.Submit_Scholarship_Email_Template_Id__c, scholarship.Org_Wide_Email_Id__c, applicant.Id, applicant.Contact__c, applicant.Contact__r.Email));
        if (emailsToSend.size() > 0) {
            try {
                        emailBuilder.sendCreatedEmails(emailsToSend);
            } catch (Exception ex) {
                        pageRef.getParameters().put('pageMsg', '2w');
                        System.debug('Send Submit Email exception: ' + ex.getMessage());
                    }
            }
            } catch (Exception ex) {
                pageRef.getParameters().put('pageMsg', '2w');
                System.debug('Submit Email Template exception: ' + ex.getMessage());
            }
        } else {
            pageRef.getParameters().put('pageMsg', '2w');
            System.debug('Send Submit Email exception: no Org_Wide_Email_Id__c or Submit_Scholarship_Email_Template_Id__c');
        }

        return pageRef;
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