BEGIN TRANSACTION;
CREATE TABLE "Award__c" (
	id INTEGER NOT NULL, 
	"Award_Amount__c" VARCHAR(255), 
	"Award_Date__c" VARCHAR(255), 
	"Award_Status__c" VARCHAR(255), 
	"CreatedDate" VARCHAR(255), 
	"LastModifiedDate" VARCHAR(255), 
	"Scholarship_Name__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Contact" (
	id INTEGER NOT NULL, 
	"FirstName" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"Preferred_First_Name__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Contact" VALUES(1,'Test','Testerman','');
CREATE TABLE "Scholarship_Applicant__c" (
	id INTEGER NOT NULL, 
	"App_Attachment_SF_ID__c" VARCHAR(255), 
	"Confirmed_Criteria__c" VARCHAR(255), 
	"CreatedDate" VARCHAR(255), 
	"Declared_ACT_SAT__c" VARCHAR(255), 
	"Declared_GPA__c" VARCHAR(255), 
	"Essay_1_Answer__c" VARCHAR(255), 
	"Essay_1_Uploaded_Orig_Filename__c" VARCHAR(255), 
	"Essay_1_Uploaded__c" VARCHAR(255), 
	"Essay_2_Answer__c" VARCHAR(255), 
	"Essay_2_Uploaded_Orig_Filename__c" VARCHAR(255), 
	"Essay_2_Uploaded__c" VARCHAR(255), 
	"LastModifiedDate" VARCHAR(255), 
	"Question_1_Answer__c" VARCHAR(255), 
	"Question_2_Answer__c" VARCHAR(255), 
	"Question_3_Answer__c" VARCHAR(255), 
	"Question_4_Answer__c" VARCHAR(255), 
	"Recommendation2_Received__c" VARCHAR(255), 
	"Recommendation2_Request_Date__c" VARCHAR(255), 
	"Recommendation2__c" VARCHAR(255), 
	"Recommendation_Received__c" VARCHAR(255), 
	"Recommendation_Request_Date__c" VARCHAR(255), 
	"Recommendation__c" VARCHAR(255), 
	"Recommender2_Email__c" VARCHAR(255), 
	"Recommender2_Name__c" VARCHAR(255), 
	"Recommender_Email__c" VARCHAR(255), 
	"Recommender_Name__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Scholarship_Amount__c" VARCHAR(255), 
	"Scholarship_Award_Type__c" VARCHAR(255), 
	"Scholarship_Complete__c" VARCHAR(255), 
	"Scholarship_Date_Accepted__c" VARCHAR(255), 
	"Scholarship_Date_Decision__c" VARCHAR(255), 
	"Scholarship_Date_Declined__c" VARCHAR(255), 
	"Scholarship_Date_Finalist__c" VARCHAR(255), 
	"Scholarship_Date_Not_Interested__c" VARCHAR(255), 
	"Scholarship_Date_Reviewed__c" VARCHAR(255), 
	"Scholarship_Date_Semi_Finalist__c" VARCHAR(255), 
	"Scholarship_Date_Started__c" VARCHAR(255), 
	"Scholarship_Date_Submitted__c" VARCHAR(255), 
	"Scholarship_Date_Withdrawn__c" VARCHAR(255), 
	"Scholarship_Notes__c" VARCHAR(255), 
	"Scholarship_Status__c" VARCHAR(255), 
	"Signature__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	"Scholarship__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Scholarship_Applicant__c" VALUES(1,'','True','2023-01-30T21:17:40.000+0000','35.0','3.8','yes','','False','yes','','False','2023-01-30T21:18:08.000+0000','yes','','','','','','','','2023-01-30T21:18:04.000+0000','','','','jjheaney@stthomas.edu','Jim Henley','01252000002cqEZAAY','','','True','','','','','','','','2023-01-30T21:17:40.000+0000','2023-01-30T21:18:08.000+0000','','','Submitted App','jjh','1','1');
CREATE TABLE "Scholarship_Applicant__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Scholarship_Applicant__c_rt_mapping" VALUES('01252000002cqEYAAY','Grant');
INSERT INTO "Scholarship_Applicant__c_rt_mapping" VALUES('01252000002cqEZAAY','Scholarship');
CREATE TABLE "Scholarship__c" (
	id INTEGER NOT NULL, 
	"Amount__c" VARCHAR(255), 
	"Award_Year__c" VARCHAR(255), 
	"Close_Date__c" VARCHAR(255), 
	"Completion_Statement__c" VARCHAR(255), 
	"CreatedDate" VARCHAR(255), 
	"Criteria_Statement__c" VARCHAR(255), 
	"Description__c" VARCHAR(255), 
	"Essay_1_Allow_Upload__c" VARCHAR(255), 
	"Essay_1_Text__c" VARCHAR(255), 
	"Essay_2_Allow_Upload__c" VARCHAR(255), 
	"Essay_2_Text__c" VARCHAR(255), 
	"LastModifiedDate" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Number_of_Scholarships__c" VARCHAR(255), 
	"Open_Date__c" VARCHAR(255), 
	"Question_1_Text__c" VARCHAR(255), 
	"Question_2_Text__c" VARCHAR(255), 
	"Question_3_Text__c" VARCHAR(255), 
	"Question_4_Text__c" VARCHAR(255), 
	"Recommender2_Auto_Send__c" VARCHAR(255), 
	"Recommender2_Description__c" VARCHAR(255), 
	"Recommender2_Question__c" VARCHAR(255), 
	"Recommender2__c" VARCHAR(255), 
	"Recommender_Auto_Send__c" VARCHAR(255), 
	"Recommender_Description__c" VARCHAR(255), 
	"Recommender_Question__c" VARCHAR(255), 
	"Recommender__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Review_Award_Process_Description__c" VARCHAR(255), 
	"Scholarship_Budget__c" VARCHAR(255), 
	"Self_Report_ACT_GPA_Criteria__c" VARCHAR(255), 
	"Short_Description__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Scholarship__c" VALUES(1,'1000000.0','2223','2028-10-21','<p>Thanks, Smith!</p>','2022-05-24T19:22:30.000+0000','<p>Are you named Smith?</p>','<p>For Smiths</p>','False','<p>Are you REALLY named Smith?</p>','True','<p>What does Smith mean to you?</p>','2023-01-30T21:14:40.000+0000','Smith Scholars','75.0','2022-05-01','<p>How long have you been a Smith?</p>','','','','False','','','False','True','<p>Another Smith</p>','<p>Is this person a good Smith?</p>','True','01252000002cqEaAAI','<p>We will check your birth certificate to make sure you are a Smith.</p>','','True','Smiths only');
CREATE TABLE "Scholarship__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Scholarship__c_rt_mapping" VALUES('01252000002cqEaAAI','Scholarship');
INSERT INTO "Scholarship__c_rt_mapping" VALUES('01252000002cqEbAAI','Signature_Programs');
INSERT INTO "Scholarship__c_rt_mapping" VALUES('01252000002cqEcAAI','UG_Merit');
COMMIT;
