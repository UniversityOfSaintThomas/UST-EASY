BEGIN TRANSACTION;
CREATE TABLE "Interaction_Mapping__c" (
	id INTEGER NOT NULL, 
	"Active__c" VARCHAR(255), 
	"CreatedDate" VARCHAR(255), 
	"Insert_Null__c" VARCHAR(255), 
	"Interaction_Source_Field_API_Name__c" VARCHAR(255), 
	"LastModifiedDate" VARCHAR(255), 
	"Skip_Mapping__c" VARCHAR(255), 
	"Source_Field_API_Name__c" VARCHAR(255), 
	"Source_Object_API_Name__c" VARCHAR(255), 
	"Target_Field_API_Name__c" VARCHAR(255), 
	"Target_Object_API_Name__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Interaction_Mapping__c" VALUES(1,'True','2020-09-18T21:03:36.000+0000','False','First_Name__c','2020-09-18T21:03:36.000+0000','','FirstName','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(2,'True','2020-09-18T21:03:36.000+0000','False','Gender__c','2020-09-18T21:03:36.000+0000','','hed__Gender__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(3,'True','2020-09-18T21:03:36.000+0000','False','Home_Phone__c','2020-09-18T21:03:36.000+0000','','HomePhone','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(4,'True','2020-09-18T21:03:36.000+0000','False','Last_Name__c','2020-09-18T21:03:36.000+0000','','LastName','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(5,'True','2020-09-18T21:03:36.000+0000','False','Lead_Source__c','2020-09-18T21:03:36.000+0000','','LeadSource','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(6,'True','2020-09-18T21:03:41.000+0000','False','Affiliation_Role__c','2020-09-18T21:03:41.000+0000','','Affiliation_Role__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(7,'True','2020-09-18T21:03:41.000+0000','False','Birthdate__c','2020-09-18T21:03:41.000+0000','','Birthdate__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(8,'True','2020-09-18T21:03:41.000+0000','False','Ethnicity__c','2020-09-18T21:03:41.000+0000','','Ethnicity__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(9,'True','2020-09-18T21:03:41.000+0000','False','Race__c','2020-09-18T21:03:41.000+0000','','Race__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(10,'True','2020-09-18T21:03:36.000+0000','False','Campaign_Member_Status__c','2020-09-18T21:03:36.000+0000','','Status','CampaignMember');
INSERT INTO "Interaction_Mapping__c" VALUES(11,'True','2020-09-18T21:03:36.000+0000','False','Race__c','2020-09-18T21:03:36.000+0000','','hed__Race__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(12,'True','2020-09-18T21:03:36.000+0000','False','Birthdate__c','2020-09-18T21:03:36.000+0000','','Birthdate','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(13,'True','2020-09-18T21:03:36.000+0000','False','Contact_Title__c','2020-09-18T21:03:36.000+0000','','Title','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(14,'True','2020-09-18T21:03:36.000+0000','False','Email__c','2020-09-18T21:03:36.000+0000','','Email','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(15,'True','2021-05-10T18:00:38.000+0000','False','utm_content__c','2021-05-10T18:00:38.000+0000','','utm_content__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(17,'True','2021-05-10T17:51:23.000+0000','False','Receive_Texts__c','2021-05-10T17:51:23.000+0000','','Receive_Texts__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(18,'True','2021-04-12T03:26:05.000+0000','False','Citizenship__c','2021-04-12T03:26:05.000+0000','','Citizenship__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(19,'True','2021-04-12T03:26:55.000+0000','False','Citizenship__c','2021-04-12T03:26:55.000+0000','','Citizenship__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(20,'True','2021-05-10T18:00:46.000+0000','False','utm_medium__c','2021-05-10T18:00:46.000+0000','','utm_medium__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(21,'True','2021-05-10T18:00:56.000+0000','False','utm_source__c','2021-05-10T18:00:56.000+0000','','utm_source__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(22,'True','2021-05-10T17:48:46.000+0000','False','Receive_Texts__c','2021-05-10T17:48:46.000+0000','','Receive_Texts__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(23,'True','2021-05-10T18:00:28.000+0000','False','utm_campaign__c','2021-05-10T18:00:28.000+0000','','utm_campaign__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(25,'True','2021-05-10T18:01:09.000+0000','False','utm_term__c','2021-05-10T18:01:09.000+0000','','utm_term__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(28,'True','2021-04-08T15:53:11.000+0000','False','Intended_Start_Term__c','2021-04-08T15:53:11.000+0000','','Intended_Start_Term__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(29,'True','2021-04-08T15:52:02.000+0000','False','College_of_Interest__c','2021-04-08T15:54:18.000+0000','','College_of_Interest__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(30,'True','2021-04-08T15:52:51.000+0000','False','Degree_Level__c','2021-04-08T15:52:51.000+0000','','Degree_Level__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(31,'True','2021-04-08T04:55:22.000+0000','False','College_of_Interest__c','2021-04-08T04:55:22.000+0000','','College_of_Interest__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(32,'True','2021-04-08T04:55:41.000+0000','False','Degree_Level__c','2021-04-08T04:55:41.000+0000','','Degree_Level__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(33,'True','2021-04-08T04:54:13.000+0000','False','Intended_Start_Term__c','2021-04-08T04:54:13.000+0000','','Intended_Start_Term__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(34,'True','2021-03-24T03:29:24.000+0000','False','Application_Number__c','2021-03-24T03:32:16.000+0000','','Name','Application__c');
INSERT INTO "Interaction_Mapping__c" VALUES(35,'True','2020-09-18T20:57:45.000+0000','False','First_Name__c','2020-09-18T20:57:45.000+0000','','FirstName','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(36,'True','2020-09-18T21:03:39.000+0000','False','Affiliation_Role__c','2020-09-18T21:03:39.000+0000','','hed__Role__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES(37,'True','2020-09-18T21:03:39.000+0000','False','Contact_Title__c','2020-09-18T21:03:39.000+0000','','Title','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(38,'True','2020-09-18T21:03:39.000+0000','False','Email__c','2020-09-18T21:03:39.000+0000','','Email','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(39,'True','2020-09-18T21:03:39.000+0000','False','First_Name__c','2020-09-18T21:03:39.000+0000','','FirstName','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(40,'True','2020-09-18T21:03:37.000+0000','False','Mailing_City__c','2020-09-18T21:03:37.000+0000','','MailingCity','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(41,'True','2020-09-18T21:03:37.000+0000','False','Mailing_Country__c','2020-09-18T21:03:37.000+0000','','MailingCountry','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(42,'True','2020-09-18T21:03:37.000+0000','False','Mailing_Postal_Code__c','2020-09-18T21:03:37.000+0000','','MailingPostalCode','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(43,'True','2020-09-18T21:03:37.000+0000','False','Mailing_State__c','2020-09-18T21:03:37.000+0000','','MailingState','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(44,'True','2020-09-18T21:03:37.000+0000','False','Mailing_Street__c','2020-09-18T21:03:37.000+0000','','MailingStreet','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(45,'True','2020-09-18T21:03:38.000+0000','False','Mobile_Phone__c','2020-09-18T21:03:38.000+0000','','MobilePhone','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(46,'True','2020-09-18T21:03:38.000+0000','False','Salutation__c','2020-09-18T21:03:38.000+0000','','Salutation','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(47,'True','2020-09-18T21:03:38.000+0000','False','University_Email__c','2020-09-18T21:03:38.000+0000','','hed__UniversityEmail__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(48,'True','2020-09-18T21:03:38.000+0000','False','Constituent_ID__c','2020-09-18T21:03:38.000+0000','','Constituent_ID__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(49,'True','2020-09-18T21:03:38.000+0000','False','Middle_Name__c','2020-09-18T21:03:38.000+0000','','MiddleName','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(50,'True','2020-09-18T21:03:40.000+0000','False','Mailing_Postal_Code__c','2020-09-18T21:03:40.000+0000','','PostalCode','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(51,'True','2020-09-18T21:03:40.000+0000','False','Mailing_State__c','2020-09-18T21:03:40.000+0000','','State','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(52,'True','2020-09-18T21:03:40.000+0000','False','Mailing_Street__c','2020-09-18T21:03:40.000+0000','','Street','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(53,'True','2020-09-18T21:03:40.000+0000','False','Salutation__c','2020-09-18T21:03:40.000+0000','','Salutation','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(54,'True','2020-09-18T21:03:40.000+0000','False','Constituent_ID__c','2020-09-18T21:03:40.000+0000','','Constituent_ID__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(57,'True','2021-05-14T14:14:15.000+0000','False','Years_Attended__c','2021-05-14T14:14:15.000+0000','','Years_Attended__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(58,'True','2021-05-10T17:51:29.000+0000','False','Receive_Texts__c','2021-05-10T17:51:29.000+0000','','Receive_Texts__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(60,'True','2021-05-14T14:11:53.000+0000','False','High_School_Graduation_Year__c','2021-05-14T14:11:53.000+0000','','High_School_Graduation_Year__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(64,'True','2020-09-18T21:03:40.000+0000','False','Home_Phone__c','2020-09-18T21:03:40.000+0000','','Phone','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(65,'True','2020-09-18T21:03:40.000+0000','False','Last_Name__c','2020-09-18T21:03:40.000+0000','','LastName','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(66,'True','2020-09-18T21:03:40.000+0000','False','Lead_Source__c','2020-09-18T21:03:40.000+0000','','LeadSource','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(67,'True','2020-09-18T21:03:40.000+0000','False','Mailing_City__c','2020-09-18T21:03:40.000+0000','','City','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(68,'True','2020-09-18T21:03:40.000+0000','False','Mailing_Country__c','2020-09-18T21:03:40.000+0000','','Country','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(69,'True','2020-09-18T21:03:43.000+0000','False','Application_Number__c','2020-09-18T21:03:43.000+0000','','Application_Number__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(70,'True','2020-09-18T20:58:28.000+0000','False','Email__c','2020-09-18T20:58:28.000+0000','','Email','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(71,'True','2020-09-18T21:03:43.000+0000','False','Contact__c','2020-09-18T21:03:43.000+0000','','Contact__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(72,'True','2020-09-18T21:03:43.000+0000','False','Opportunity_Stage__c','2021-04-12T14:34:53.000+0000','Manual Entry','StageName','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(73,'True','2020-09-18T21:03:43.000+0000','False','Admit_Type__c','2020-09-18T21:03:43.000+0000','','Admit_Type__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(74,'True','2020-09-18T21:03:43.000+0000','False','Opportunity_Name__c','2020-09-18T21:03:43.000+0000','','Name','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(75,'True','2020-09-18T21:03:42.000+0000','False','Affiliated_Account__c','2020-09-18T21:03:42.000+0000','','Affiliated_Account__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(76,'True','2020-09-18T21:03:42.000+0000','False','Mobile_Phone__c','2020-09-18T21:03:42.000+0000','','MobilePhone','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(77,'True','2020-09-18T21:03:42.000+0000','False','Gender__c','2020-09-18T21:03:42.000+0000','','Gender__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(78,'True','2020-09-18T21:03:42.000+0000','False','Admit_Type__c','2020-09-18T21:03:42.000+0000','','Admit_Type__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(79,'True','2020-09-18T21:03:42.000+0000','False','Primary_Affiliation__c','2020-09-18T21:03:42.000+0000','','Primary_Affiliation__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES(80,'True','2020-09-18T21:03:42.000+0000','False','Opportunity_Close_Date__c','2020-09-18T21:03:42.000+0000','','CloseDate','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(81,'True','2020-09-18T21:03:42.000+0000','False','Affiliated_Account__c','2020-09-18T21:03:42.000+0000','','Affiliated_Account__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(82,'True','2020-09-18T21:03:42.000+0000','False','Lead_Source__c','2020-09-18T21:03:42.000+0000','','LeadSource','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES(83,'True','2020-09-18T21:03:38.000+0000','False','Ethnicity__c','2020-09-18T21:03:38.000+0000','','hed__Ethnicity__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES(84,'True','2020-09-18T21:03:38.000+0000','False','Affiliation_Status__c','2020-09-18T21:03:38.000+0000','','hed__Status__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES(85,'True','2020-09-18T21:03:38.000+0000','False','Affiliated_Account__c','2020-09-18T21:03:38.000+0000','','hed__Account__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES(86,'True','2020-09-18T21:03:38.000+0000','False','Primary_Affiliation__c','2020-09-18T21:03:38.000+0000','','hed__Primary__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES(87,'True','2020-09-18T21:03:38.000+0000','False','Contact__c','2020-09-18T21:03:38.000+0000','','hed__Contact__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES(88,'True','2020-09-18T20:58:01.000+0000','False','Last_Name__c','2020-09-18T20:58:01.000+0000','','LastName','Contact');
CREATE TABLE "Interaction__c" (
	id INTEGER NOT NULL, 
	"Additional_Campaign_Member_Status__c" VARCHAR(255), 
	"Additional_Campaign_Reference_ID__c" VARCHAR(255), 
	"Admit_Type__c" VARCHAR(255), 
	"Affiliation_Role__c" VARCHAR(255), 
	"Affiliation_Status__c" VARCHAR(255), 
	"Application_Number__c" VARCHAR(255), 
	"Audit_Reason__c" VARCHAR(255), 
	"Birthdate__c" VARCHAR(255), 
	"Campaign_Member_Status__c" VARCHAR(255), 
	"Campaign_Reference_ID__c" VARCHAR(255), 
	"Constituent_ID__c" VARCHAR(255), 
	"Contact_Title__c" VARCHAR(255), 
	"CreatedDate" VARCHAR(255), 
	"Email__c" VARCHAR(255), 
	"Ethnicity__c" VARCHAR(255), 
	"First_Name__c" VARCHAR(255), 
	"Gender__c" VARCHAR(255), 
	"Home_Phone__c" VARCHAR(255), 
	"Interaction_Source__c" VARCHAR(255), 
	"Interaction_Status__c" VARCHAR(255), 
	"Interaction_Upsert_Key__c" VARCHAR(255), 
	"LastModifiedDate" VARCHAR(255), 
	"Last_Name__c" VARCHAR(255), 
	"Lead_Only__c" VARCHAR(255), 
	"Lead_Source__c" VARCHAR(255), 
	"Mailing_City__c" VARCHAR(255), 
	"Mailing_Country__c" VARCHAR(255), 
	"Mailing_Postal_Code__c" VARCHAR(255), 
	"Mailing_State__c" VARCHAR(255), 
	"Mailing_Street__c" VARCHAR(255), 
	"Middle_Name__c" VARCHAR(255), 
	"Mobile_Phone__c" VARCHAR(255), 
	"Opportunity_Stage__c" VARCHAR(255), 
	"Primary_Affiliation__c" VARCHAR(255), 
	"Race__c" VARCHAR(255), 
	"Salutation__c" VARCHAR(255), 
	"University_Email__c" VARCHAR(255), 
	"Academic_Interest__c" VARCHAR(255), 
	"Academic_Program__c" VARCHAR(255), 
	"Additional_Campaign__c" VARCHAR(255), 
	"Affiliated_Account__c" VARCHAR(255), 
	"Campaign__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	"Lead__c" VARCHAR(255), 
	"Opportunity__c" VARCHAR(255), 
	"Recruitment_Interest__c" VARCHAR(255), 
	"Recruitment_Program__c" VARCHAR(255), 
	"Term__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
COMMIT;
