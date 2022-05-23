/**
 * Created by jjheaney on 3/14/2022.
 */

public with sharing class ScholarshipSharedUtilities {

    public static Id getActiveUserId() {
        return UserInfo.getUserId();
    }

    public static Contact getContactRecord(Id contactId) { // TODO: Really should expand this to include more/all fields.
        Contact result = null;
        if (contactId != null) {
            List<Contact> resultIds = [SELECT FirstName, LastName FROM Contact Where Id = :contactId];
            if (resultIds.size() > 0) {
                result = resultIds[0];
            }
        }
        return result;
    }

    public static Id getActiveContactId() {
        Id result = null;
        Id userId = getActiveUserId();
        if (userId != null) {
            List<User> resultIds = [SELECT contactID FROM User Where Id = :userId];
            if (resultIds.size() > 0) {
                result = resultIds[0].ContactId;
            }
        }
        return result;
    }

    public static PageReference setSid(PageReference pageRef, Boolean redir, String scholarshipId) {
        if (!String.isEmpty(scholarshipId)) {
            pageRef.getParameters().put('sid', scholarshipId);
        }
        pageRef.setRedirect(redir);
        return pageRef;
    }

    public static Scholarship__c getScholarshipInfo(String scholarshipId) {
        Scholarship__c scholarshipInfo = null;
        List<Scholarship__c> ScholarshipInfos = [
                SELECT Close_Date__c,Completion_Statement__c,Criteria_Statement__c,Description__c,Essay_1_Text__c,Essay_2_Text__c,
                        Id,Name,Open_Date__c,OwnerId,Question_1_Text__c,Question_2_Text__c,Question_3_Text__c,Question_4_Text__c,
                        Recommender2_Auto_Send__c,Recommender2_Description__c,Recommender2_Question__c,Recommender2__c,Recommender_Auto_Send__c,
                        Recommender_Description__c,Recommender_Question__c,Recommender__c,Scholarship_ID__c,Short_Description__c,
                        Review_Award_Process_Description__c,Self_Report_ACT_GPA_Criteria__c, Essay_1_Allow_Upload__c, Essay_2_Allow_Upload__c
                FROM Scholarship__c
                WHERE Scholarship_ID__c = :scholarshipId
        ];
        if (ScholarshipInfos.size() > 0) {
            scholarshipInfo = ScholarshipInfos[0];
        }

        return scholarshipInfo;
    }

    public static Scholarship_Applicant__c getApplicantInfo(String scholarshipId, Id contactId) {
        Scholarship_Applicant__c scholarshipApplicant;
        System.debug('getApplicantInfo():: scholarshipId: ' + scholarshipId + ', contactId: ' + contactId );
        if (!String.isEmpty(scholarshipId)) {
            List<Scholarship_Applicant__c> ScholarshipApplicants = [
                     SELECT Confirmed_Criteria__c,Declared_ACT_SAT__c,Declared_GPA__c,Essay_1_Answer__c,Essay_1_Uploaded__c,Essay_2_Answer__c,
                             Essay_2_Uploaded__c,Id,Name,Question_1_Answer__c,Question_2_Answer__c,Question_3_Answer__c,
                             Question_4_Answer__c,Recommendation2__c,Recommendation__c,Recommender2_Email__c,Recommender2_Name__c,
                             Recommender_Email__c,Recommender_Name__c,Scholarship_Complete__c,Scholarship__c,Signature__c, Scholarship_Status__c,
                             Essay_1_Uploaded_Orig_Filename__c, Essay_2_Uploaded_Orig_Filename__c, Scholarship_Date_Started__c, Scholarship_Date_Submitted__c,
                             Recommendation2_Request_Date__c, Recommendation_Request_Date__c, Contact__c
                     FROM Scholarship_Applicant__c
                     WHERE Contact__c = :contactId
                     AND Scholarship__c = :scholarshipId
            ];

            if (ScholarshipApplicants.size() > 0) {
                //load in scholarship applicant
                System.debug('getApplicantInfo():: found an applicant! ');
                scholarshipApplicant = ScholarshipApplicants[0];
            } else {
                //Create a new scholarship applicant if there is none already
                System.debug('getApplicantInfo():: creating new applicant! ');
                scholarshipApplicant = new Scholarship_Applicant__c();
            }
        } else {
            scholarshipApplicant = null;
        }
        return scholarshipApplicant;
    }

    public boolean hasEssayAnswer(Scholarship_Applicant__c scholarshipApplicant, Integer numEssay) {
        // replaces e1Text and e2Text
        boolean eText;
        if (numEssay == 1) {
            eText = !String.isEmpty(scholarshipApplicant.Essay_1_Answer__c);
        } else if (numEssay == 2) {
            eText = !String.isEmpty(scholarshipApplicant.Essay_2_Answer__c);
        } else {
            eText = false;
        }
        return eText;
    }

    public DateTime getRecommendationRequestDate(Scholarship_Applicant__c scholarshipApplicant, Integer numRec) {
        // replaces e1Text and e2Text
        DateTime recDate;
        if (numRec == 1) {
            if (scholarshipApplicant.Recommendation_Request_Date__c != null) {
                recDate = adjustForCentralTime(scholarshipApplicant.Recommendation_Request_Date__c);
            }
        } else if (numRec == 2) {
            if (scholarshipApplicant.Recommendation2_Request_Date__c != null) {
                recDate = adjustForCentralTime(scholarshipApplicant.Recommendation2_Request_Date__c);
            }
        } else {
            recDate = null;
        }
        return recDate;
    }

    public static void sendEmail(String rName, String EmailAddress, String Subject, String HTMLBodyText, String PlainBodyText, String sName) {
        if (!String.isEmpty(EmailAddress)) {

            /* grab the email template. Would be nice to make this admin-editable; see SummitEventsRegistration, lines 78-132 (after statuscheck). */
            EmailTemplate[] emailTemplates = [select Id, Subject, HtmlValue, Body from EmailTemplate where Name = '2017 Scholarship Email Template' LIMIT 1];
            EmailTemplate emailTemplate;
            if (emailTemplates.size() > 0) {
                emailTemplate = emailTemplates.get(0);

                /* We are going to want this to be selectable. See SummitEventsLetterheadLookup.page in SummitEvents. */
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'admissions@stthomas.edu'];
                if (owea.size() == 0) {
                    owea = [select Id from OrgWideEmailAddress where Address = 'jjheaney@stthomas.edu']; // Fallback for scratch environments.
                }

                String templateSubject = emailTemplate.Subject;
                templateSubject = templateSubject.replace('{!ScholarshipEmailSubject}', sName);

                String htmlBody = emailTemplate.HtmlValue;
                if (htmlBody != null) {
                    htmlBody = htmlBody.replace('{!ScholarshipEmailBody}', HTMLBodyText);
                }
                String plainBody = emailTemplate.Body;
                if (plainBody != null) {
                    plainBody = plainBody.replace('{!ScholarshipEmailBody}', PlainBodyText);
                }

                // Now create a new single email message object
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                //Assign the addresses for the To and CC lists to the mail object.
                mail.setToAddresses(new String[]{
                        EmailAddress
                });
                // mail.setCcAddresses(ccAddresses);

                // Specify the address used when the recipients reply to the email.
                // mail.setTemplateId('00X30000001GLJj');
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                mail.setSubject(Subject);
                mail.setBccSender(false);

                // Optionally append the salesforce.com email signature to the email.
                // The email address of the user executing the Apex Code will be used.
                mail.setUseSignature(false);

                // Specify the text content of the email.
                mail.setPlainTextBody(plainBody);
                mail.setHtmlBody(htmlBody);

                // Send the email you have created.
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
            }
        }
    }

    public static boolean isScholarshipOpen(Scholarship__c scholarship) {
        boolean scholarshipOpen;
        if (scholarship.Open_Date__c <= adjustForCentralTime(Datetime.now()) && scholarship.Close_Date__c >= adjustForCentralTime(Datetime.now())) {
            scholarshipOpen = true;
        } else {
            scholarshipOpen = false;
        }
        return scholarshipOpen;
    }

    public static String setHistoryPage(String scholarshipId) {
        String cPage = ApexPages.currentPage().getUrl();
        String[] cPageSplit = cPage.split('\\?');
        String historyURL = '/EASYApp/ScholarshipHome';
        if (cPageSplit.size() > 0) {
            historyURL = cPageSplit[0];
        }
        historyURL = historyURL.replace('/apex/', '/EASYApp/');
        if (!String.isEmpty(scholarshipId)) {
            historyURL += '?sid=' + scholarshipId;
        }
        return historyURL;
    }

    public static DateTime adjustForCentralTime(Datetime dt) {
        //Get the current GMT time and adjust for our timezone
        TimeZone tz = TimeZone.getTimeZone('America/Chicago');
        dt = dt.addSeconds(tz.getOffset(dt) / 1000);
        return dt;
    }
}