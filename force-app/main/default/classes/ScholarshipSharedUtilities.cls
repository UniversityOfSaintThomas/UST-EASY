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
            List<Contact> resultIds = [
                    SELECT FirstName, LastName, Email
                    FROM Contact
                    WHERE Id = :contactId
            ];
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
            List<User> resultIds = [
                    SELECT ContactId
                    FROM User
                    WHERE Id = :userId
            ];
            if (resultIds.size() > 0) {
                result = resultIds[0].ContactId;
            }
        }
        return result;
    }

    public static PageReference setSid(PageReference pageRef, Boolean redir, String scholarshipId) {
        if (!String.isEmpty(scholarshipId)) {
            createCookie(scholarshipId);
            pageRef.getParameters().put('sid', scholarshipId);
        }
        pageRef.setRedirect(redir);
        return pageRef;
    }

    public static Scholarship__c getScholarshipInfo() {
        Scholarship__c scholarshipInfo = null;
        String scholarshipId = ApexPages.currentPage().getParameters().get('sid');
        if (String.isBlank(ApexPages.currentPage().getParameters().get('sid'))) {
            scholarshipId = getCookie();
        }
        if (String.isNotBlank(scholarshipId)) {
            List<Scholarship__c> ScholarshipInfos = [
                    SELECT Close_Date__c, Completion_Statement__c, Criteria_Statement__c, Description__c, Essay_1_Text__c, Essay_2_Text__c,
                            Id, Name, Open_Date__c, OwnerId, Question_1_Text__c, Question_2_Text__c, Question_3_Text__c, Question_4_Text__c,
                            Recommender2_Auto_Send__c, Recommender2_Description__c, Recommender2_Question__c, Recommender2__c, Recommender_Auto_Send__c,
                            Recommender_Description__c, Recommender_Question__c, Recommender__c, Scholarship_ID__c, Short_Description__c,
                            Review_Award_Process_Description__c, Self_Report_ACT_GPA_Criteria__c, Essay_1_Allow_Upload__c, Essay_2_Allow_Upload__c,
                            Recommender_Option__c, Recommender2_Option__c, Recommender_Email_Template_Id__c, Recommender2_Email_Template_Id__c,
                            Recommender_Org_From_Email_Id__c, Recommender2_Org_From_Email_Id__c
                    FROM Scholarship__c
                    WHERE Scholarship_ID__c = :scholarshipId
            ];
            if (ScholarshipInfos.size() > 0) {
                scholarshipInfo = ScholarshipInfos[0];
                createCookie(scholarshipId);
            }
        }

        return scholarshipInfo;
    }

    public static Scholarship_Applicant__c getApplicantInfo(String scholarshipId, Id contactId) {
        Scholarship_Applicant__c scholarshipApplicant;
        //System.debug('getApplicantInfo():: scholarshipId: ' + scholarshipId + ', contactId: ' + contactId );
        if (!String.isEmpty(scholarshipId)) {
            List<Scholarship_Applicant__c> ScholarshipApplicants = [
                    SELECT Confirmed_Criteria__c, Declared_ACT_SAT__c, Declared_GPA__c, Essay_1_Answer__c, Essay_1_Uploaded__c, Essay_2_Answer__c,
                            Essay_2_Uploaded__c, Id, Name, Question_1_Answer__c, Question_2_Answer__c, Question_3_Answer__c,
                            Question_4_Answer__c, Recommendation2__c, Recommendation__c, Recommender2_Email__c, Recommender2_Name__c,
                            Recommender_Email__c, Recommender_Name__c, Scholarship_Complete__c, Scholarship__c, Signature__c, Scholarship_Status__c,
                            Essay_1_Uploaded_Orig_Filename__c, Essay_2_Uploaded_Orig_Filename__c, Scholarship_Date_Started__c, Scholarship_Date_Submitted__c,
                            Recommendation2_Request_Date__c, Recommendation_Request_Date__c, Contact__c, Recommendation_Link__c, Recommendation_Link_2__c,
                            Contact__r.Name
                    FROM Scholarship_Applicant__c
                    WHERE Contact__c = :contactId
                    AND Scholarship__c = :scholarshipId
            ];

            if (ScholarshipApplicants.size() > 0) {
                //load in scholarship applicant
                scholarshipApplicant = ScholarshipApplicants[0];
            } else {
                //Create a new scholarship applicant if there is none already
                scholarshipApplicant = new Scholarship_Applicant__c();
            }
        } else {
            scholarshipApplicant = null;
        }
        return scholarshipApplicant;
    }

    public static Boolean isScratchTrialOrg() {
        Organization org = [SELECT IsSandbox, TrialExpirationDate FROM Organization];
        Boolean isScratchOrg = org.IsSandbox && org.TrialExpirationDate != null;
        Boolean isTrialOrg = !org.IsSandbox && org.TrialExpirationDate != null;
        return isScratchOrg || isTrialOrg;
    }

    //Create Lightning Email Message
    public static Messaging.SingleEmailMessage sendLightningEmail(String emailTemplateId, String emailFromId, String scholarshipApplication, String applicantContactId, String recommenderEmail) {

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        message = Messaging.renderStoredEmailTemplate(emailTemplateId, applicantContactId, scholarshipApplication);
        message.setTreatTargetObjectAsRecipient(false);
        message.setToAddresses(new String[]{recommenderEmail});
        message.setUseSignature(false);
        message.setOrgWideEmailAddressId(emailFromId);
        message.optOutPolicy = 'FILTER';
        message.setUseSignature(false);
        message.setBccSender(false);

        return message;
    }

    public static Messaging.SingleEmailMessage sendEmail(String rName, String EmailAddress, String Subject, String HTMLBodyText, String PlainBodyText, String sName) {

        if (!String.isEmpty(EmailAddress)) {

            // TODO: Make email template selectable.
            EmailTemplate[] emailTemplates = [
                    SELECT Id, Subject, HtmlValue, Body
                    FROM EmailTemplate
                    WHERE Name = '2017 Scholarship Email Template'
                    LIMIT 1
            ];
            EmailTemplate emailTemplate;
            if (emailTemplates.size() > 0) {
                emailTemplate = emailTemplates.get(0);

                /* We are going to want this to be selectable. See SummitEventsLetterheadLookup.page in SummitEvents. */
                //TODO: Make org wide email selectable and use permission set.
                OrgWideEmailAddress[] owea = [
                        SELECT Id
                        FROM OrgWideEmailAddress
                        WHERE Address = 'admissions@stthomas.edu'
                ];

                if (isScratchTrialOrg()) {
                    owea = [
                            SELECT Id
                            FROM OrgWideEmailAddress
                            WHERE isAllowAllProfiles = TRUE
                            LIMIT 1
                    ];
                } // Fallback for scratch environments.

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

                return mail;
            }
        }
        return null;
    }

    public static Boolean isScholarshipOpen(Scholarship__c scholarship) {
        Boolean scholarshipOpen = false;
        if (scholarship != null && scholarship.Open_Date__c <= adjustForCentralTime(Datetime.now()) && scholarship.Close_Date__c >= adjustForCentralTime(Datetime.now())) {
            scholarshipOpen = true;
        }
        return scholarshipOpen;
    }


    public static Datetime adjustForCentralTime(Datetime dt) {
        //Get the current GMT time and adjust for our timezone
        TimeZone tz = TimeZone.getTimeZone('America/Chicago');
        dt = dt.addSeconds(tz.getOffset(dt) / 1000);
        return dt;
    }

    public static PageReference checkScholarshipAccess() {
        String scholarshipId = null;
        PageReference result = null;
        Scholarship__c scholarship = ScholarshipSharedUtilities.getScholarshipInfo();
        if (scholarship != null) {
            Scholarship_Applicant__c scholarshipApplicant = ScholarshipSharedUtilities.getApplicantInfo(scholarship.Id, ScholarshipSharedUtilities.getActiveContactId());
            System.debug('ScholarshipSharedUtilities.checkScholarshipAccess():: scholarshipApplicant.Scholarship_Complete__c: ' + scholarshipApplicant.Scholarship_Complete__c);
            if (scholarshipApplicant.Scholarship_Complete__c) {
                result = ScholarshipSharedUtilities.setSid(Page.ScholarshipApplicationComplete, false, scholarshipId);
            } else {
                Boolean scholarshipOpen = ScholarshipSharedUtilities.isScholarshipOpen(scholarship);
                if (!scholarshipOpen) {
                    result = ScholarshipSharedUtilities.setSid(Page.ScholarshipClosed, false, scholarshipId);
                }
            }
        } else {
            return Page.ScholarshipHome.setRedirect(true);
        }
        return result;
    }

    public static String createCookie(String scholarshipId) {
        Cookie scholarshipCookie = new Cookie('USTScholarship', scholarshipId, null, -1, true, 'Strict');
        ApexPages.currentPage().setCookies(new Cookie[]{
                scholarshipCookie
        });
        return scholarshipCookie.getValue();
    }

    public static String getCookie() {
        Cookie encodedCipherText = ApexPages.currentPage().getCookies().get('USTScholarship');
        if (encodedCipherText != null) {
            return encodedCipherText.getValue();
        }
        return '';
    }

    //Create Task Activity for Emails Sent
    public static Task createTaskActivity(Id whatId, Id contactId, String subject, String description, String name, String email, Boolean resendBool, Integer recommenderNum) {
        String subjectText = '';
        String resendStatus = '';

        if (resendBool) {
            resendStatus = '[RESENT] ';
        }

        if (recommenderNum == 0) {
            subjectText = 'Email sent to Applicant';
        } else {
            subjectText = resendStatus + 'Email sent to Recommender ' + recommenderNum + ': ' + name + ' ' + email;
        }

        Task taskActivity = new Task();
        taskActivity.WhatId = whatId;
        taskActivity.WhoId = contactId;
        taskActivity.Type = 'Email';
        taskActivity.ActivityDate = Date.today();
        taskActivity.Subject = subjectText;
        taskActivity.Status = 'Completed';
        taskActivity.Priority = 'Low';
        taskActivity.Description = 'Subject: ' + subject + '\n\n';
        taskActivity.Description += description.replaceAll('</p>', '\n');
        taskActivity.Description = taskActivity.Description.replaceAll('<(.*?)>', '');

        return taskActivity;
    }

    public without sharing class RecommenderEmailStatus {

        public String emailStatus(String scholarshipAppId, String toAddress) {
            String emailOpenStatus = 'Unopened';

            List<Task> taskList = [
                    SELECT Id
                    FROM Task
                    WHERE WhatId = :scholarshipAppId
            ];

            Set<Id> taskIds = new Set<Id>();

            for (Task t : taskList) {
                taskIds.add(t.Id);
            }

            List<EmailMessage> emails = [
                    SELECT Id, FromAddress, ToAddress, IsBounced, IsOpened, IsTracked
                    FROM EmailMessage
                    WHERE ActivityId IN :taskIds
                    AND ToAddress = :toAddress
                    ORDER BY CreatedDate DESC,
                            LastModifiedDate DESC
                    LIMIT 1
            ];

            if (emails.size() > 0) {
                if (emails[0].IsOpened) {
                    emailOpenStatus = 'Opened';
                }
            }

            return emailOpenStatus;
        }

    }
}