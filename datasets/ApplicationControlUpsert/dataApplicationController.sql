BEGIN TRANSACTION;
CREATE TABLE "Application_Control__c" (
	id VARCHAR(255) NOT NULL, 
	"Academic_Level__c" VARCHAR(255), 
	"Active__c" VARCHAR(255), 
	"Allow_Cancel_From__c" VARCHAR(255), 
	"Allow_Confirm_From__c" VARCHAR(255), 
	"Allow_Submit_From__c" VARCHAR(255), 
	"Allow_Withdraw_From__c" VARCHAR(255), 
	"Application_Control_External_ID__c" VARCHAR(255), 
	"Application_Start_Status__c" VARCHAR(255), 
	"Arrow_Color__c" VARCHAR(255), 
	"Button_Color__c" VARCHAR(255), 
	"Button_Text_Color__c" VARCHAR(255), 
	"Cancel_Status__c" VARCHAR(255), 
	"Confirm_Status__c" VARCHAR(255), 
	"Default__c" VARCHAR(255), 
	"Degree_Levels__c" VARCHAR(255), 
	"Hide_Term_Program__c" VARCHAR(255), 
	"Line_Color__c" VARCHAR(255), 
	"Link_Color__c" VARCHAR(255), 
	"Logo_Static_Resource_Path__c" VARCHAR(255), 
	"Logo_Static_Resource__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"School_College__c" VARCHAR(255), 
	"Show_on_App_Finder__c" VARCHAR(255), 
	"Submit_Status__c" VARCHAR(255), 
	"Template__c" VARCHAR(255), 
	"Text_Color__c" VARCHAR(255), 
	"URL_Parameter__c" VARCHAR(255), 
	"Withdraw_Status__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-1','','True','','','','','AppCtrUuid-0548aff2-59f6-46d2-b976-18297ea61cf3','Started App','FFF','FFF','FFF','','','False','','False','FFF','FFF','','FFF','Shell EngineeringCAS','','False','','','FFF','engineeringcas','');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-2','','True','','','','','AppCtrUuid-c8cd3882-fba9-41ce-a85a-b603b459ffc7','Started App','FFF','FFF','FFF','','','False','','False','FFF','FFF','','FFF','Shell Common App','','False','','','FFF','commonapp','');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-3','Undergraduate','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-f4635dd9-d7b7-4456-9427-53444e989040','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Undergraduate Transfer CAM','Undergraduate','False','Submitted App','','000000','UGTRCAM','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-4','Undergraduate','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-e1cb3507-62a1-4709-a279-1c7dbfa52c8b','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Undergraduate DFC Pre STEM','Dougherty Family College','False','Submitted App','stthomas2021','000000','DFCSTEM','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-5','','True','','','','','AppCtrUuid-c866703e-ae09-4f11-b00c-968e2272fd6d','Started App','FFF','FFF','FFF','','','False','','False','FFF','FFF','','FFF','Shell No App','','False','','','FFF','noapp','');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-6','Graduate','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-e93c93aa-dd0c-4734-93a0-30a8768f0991','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Graduate MSW Accelerated','School of Social Work','False','Submitted App','','000000','GMSWA','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-7','Undergraduate','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-3dfa0b42-ce6b-49e7-8600-7b4e69819c5a','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Undergraduate Transfer','Undergraduate','True','Submitted App','','000000','UGTR','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-8','Undergraduate','False','Started App','','Started App','Started App;Submitted App','AppCtrUuid-c929cea4-2ef2-43fb-b0f5-4207beaeb98c','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Undergraduate First-Year (Fall 2021)','Undergraduate','False','Submitted App','','000000','UGFR202140','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-9','Undergraduate','False','','','Started App','Submitted App','AppCtrUuid-1f547f1e-3cb9-4860-b60f-834bd0f838e8','Started App','000000','ffffff','000000','Withdrawn','','False','','True','000000','000000','','Logo','Undergraduate DFC','Dougherty Family College','True','Submitted App','','000000','DFC','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-10','Undergraduate','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-2ad1d20f-d7b1-4916-be89-b440f65f4b09','Started App','000000','ffffff','000000','Withdrawn','','True','','False','000000','000000','','Logo','Undergraduate First-Year','Undergraduate','True','Submitted App','stthomas2021','000000','UGFR','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-11','Undergraduate','True','','','Started App','','AppCtrUuid-047f9209-ec34-49a2-bd8c-5b4b5e674416','Started App','00000','fffff','00000','Withdrawn','','False','','False','00000','00000','','Logo','Undergraduate Transfer DFC','Undergraduate','False','Submitted App','stthomas2021','00000','UGTRDFC','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-12','Undergraduate','False','Started App','','Started App','Started App;Submitted App','AppCtrUuid-40ddf289-5a9f-4487-b3fb-8f5db62d423e','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Undergraduate Transfer (Common App)','Undergraduate','False','Submitted App','','000000','UGTRCA','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-13','Undergraduate','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-d8f57b3d-45e6-4e7d-8d1d-f61894f0fe22','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Undergraduate First-Year (Common App)','Undergraduate','False','Submitted App','stthomas2021','000000','UGFRCA','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-14','Graduate','True','','','Started App','Submitted App','AppCtrUuid-0bc3a69c-34ba-4136-a9d6-63cd323afd69','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Graduate School of Nursing','Morrison Family College of Health','True','Submitted App','','000000','GSON','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-15','Graduate','True','','','Started App','Submitted App','AppCtrUuid-ab3d4157-6812-437c-9d52-03aeddffd123','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Saint Paul Seminary School of Divinity','The Saint Paul Seminary School of Divinity','True','Submitted App','','000000','SPSSOD','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-16','Graduate','True','','','Started App','Submitted App','AppCtrUuid-67c6ff8b-8b17-45d1-a53d-cdaa83577306','Started App','000000','ffffff','000000','Withdrawn','','False','Doctorate

Education Specialist

Master of Arts

Certificate

Licensure

Non-Degree','False','000000','000000','','Logo','Graduate School of Education','School of Education','True','Submitted App','','000000','GSOED','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-17','Graduate','False','','','Started App','Submitted App','AppCtrUuid-348cc713-c00f-4af2-b8ac-29985b2accff','Started App','000000','fffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','The Murray Institute','The Murray Institute','False','Submitted App','','000000','MURR','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-18','Graduate','True','','','Started App','Submitted App','AppCtrUuid-a5a18aea-df7e-4fb0-8913-84ebfe4abf09','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Graduate School of Law','School of Law','True','Submitted App','','000000','GLAW','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-19','Graduate','True','','','Started App','Submitted App','AppCtrUuid-be3eb945-941f-494a-bc76-7a70de9e49df','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Graduate School of Engineering','School of Engineering','True','Submitted App','','000000','GSOE','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-20','Graduate','True','','Admit','Started App','Submitted App','AppCtrUuid-04e54b9b-d6c6-4e98-90c4-563418f5480c','Started App','000000','ffffff','000000','Withdrawn','Post-Admit (System)','False','','False','000000','000000','','Logo','Graduate College of Arts and Sciences','College of Arts and Sciences','True','Submitted App','','000000','GCAS','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-21','Graduate','True','','','Started App','Submitted App','AppCtrUuid-e7aaa14e-c725-44fd-b7b5-3efc4a3a746a','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Graduate School of Social Work','School of Social Work','True','Submitted App','','000000','GSSW','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-22','Graduate','True','','','Started App','Submitted App','AppCtrUuid-b7f841c1-1583-4e03-878c-3df82a7861e1','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Graduate School of Professional Psychology','Graduate School of Professional Psychology','True','Submitted App','','000000','GSPP','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-23','Graduate','True','','','Started App','Submitted App','AppCtrUuid-5f24bf99-31f5-4cd7-bde2-44d182dfdb13','Started App','000000','ffffff','000000','Withdrawn','','False','Master''s

Certificate

Non-Degree

Post-Masters Certificate','False','000000','000000','','Logo','Graduate Opus College of Business','Opus College of Business','True','Submitted App','','000000','GOCB','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-24','Undergraduate','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-da90dc22-e9fb-4a67-986f-a19072080dd7','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Undergraduate BSN','Morrison Family College of Health','False','Submitted App','','000000','UGBSN','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-25','','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-4b3d6195-3f1b-48ac-aead-d77ae6431761','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','SON Mentor Application','Morrison Family College of Health','False','Submitted App','','000000','SONMENTOR','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-26','Undergraduate','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-40c7c8e2-9e20-4bbf-ac6a-b18728a08dd8','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Undergraduate Non-Degree','Undergraduate','False','Submitted App','stthomas2021','000000','UGSNDO','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-27','Non-Credit','True','Started App','Admit','Started App','Started App;Submitted App','AppCtrUuid-fc5467a6-75f8-402a-be71-af1a338c309c','Started App','000000','ffffff','000000','Withdrawn','Post-Admit (System)','False','','False','000000','000000','','Logo','Non-Credit Morrison Family College of Health','Morrison Family College of Health','False','Confirmed','stthomas2021','000000','NCMFCOH','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-28','Non-Credit','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-a0327615-760a-48d6-abe3-c97f7553568c','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Non-Credit College of Arts and Sciences','College of Arts and Sciences','False','Confirmed','stthomas2021','000000','NCGCAS','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-29','Non-Credit','True','','Admit','Started App','Submitted App','AppCtrUuid-630a760a-c724-4a56-869b-5ae885658eef','Started App','000000','ffffff','000000','Withdrawn','Post-Admit (System)','False','','False','000000','000000','','Logo','Non-Credit Opus College of Business','Opus College of Business','False','Submitted App','stthomas2021','000000','NCGOCB','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-30','Non-Credit','True','Started App','','Started App','Started App;Submitted App','AppCtrUuid-2edc243d-fc02-4dbe-8d6f-da93fa4b5b62','Started App','000000','ffffff','000000','Withdrawn','','False','','False','000000','000000','','Logo','Non-Credit School of Education','School of Education','False','Confirmed','stthomas2021','000000','NCGSOED','Withdrawn');
INSERT INTO "Application_Control__c" VALUES('Application_Control__c-31','Undergraduate','True','','','','','AppCtrUuid-019ef20f-cb7e-4919-9368-8d1c3e5b2576','Started App','"FFF00"','"FFF00"','"FFF00"','','','False','','False','"FFF00"','"FFF00"','','[]','Control','','False','','','"FFFFF"','[]','');
COMMIT;
