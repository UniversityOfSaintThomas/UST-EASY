BEGIN TRANSACTION;
CREATE TABLE "Application_Control__c" (
	id INTEGER NOT NULL, 
	"Academic_Level__c" VARCHAR(255), 
	"Active__c" VARCHAR(255), 
	"Allow_Cancel_From__c" VARCHAR(255), 
	"Allow_Submit_From__c" VARCHAR(255), 
	"Allow_Withdraw_From__c" VARCHAR(255), 
	"Application_Start_Status__c" VARCHAR(255), 
	"Arrow_Color__c" VARCHAR(255), 
	"Button_Color__c" VARCHAR(255), 
	"Button_Text_Color__c" VARCHAR(255), 
	"Cancel_Status__c" VARCHAR(255), 
	"Default__c" VARCHAR(255), 
	"Degree_Levels__c" VARCHAR(255), 
	"Hide_Term_Program__c" VARCHAR(255), 
	"Line_Color__c" VARCHAR(255), 
	"Link_Color__c" VARCHAR(255), 
	"Logo_Static_Resource_Path__c" VARCHAR(255), 
	"Logo_Static_Resource__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"School_College__c" VARCHAR(255), 
	"Submit_Status__c" VARCHAR(255), 
	"Template__c" VARCHAR(255), 
	"Text_Color__c" VARCHAR(255), 
	"URL_Parameter__c" VARCHAR(255), 
	"Withdraw_Status__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Application_Control__c" VALUES(1,'Undergraduate','True','Started App','Started App','Started App;Submitted App','Started App','000000','ffffff','000000','Withdrawn','False','','False','000000','000000','','Logo','Undergraduate Summer Non-Degree','Undergraduate','Submitted App','stthomas2021','000000','UGSNDO','Withdrawn');
CREATE TABLE "EASY_Widget__c" (
	id INTEGER NOT NULL, 
	"Activation_State__c" VARCHAR(255), 
	"Display_Heading__c" VARCHAR(255), 
	"Display_Text__c" VARCHAR(255), 
	"Display_Widget_On_Citizenship__c" VARCHAR(255), 
	"Display_Widget_On_Pages__c" VARCHAR(255), 
	"Display_Widget_On_Status__c" VARCHAR(255), 
	"Display_Widget_On_Sub_Status__c" VARCHAR(255), 
	"End_Date__c" VARCHAR(255), 
	"End_Time__c" VARCHAR(255), 
	"Generic_Filter_2__c" VARCHAR(255), 
	"Only_One_Widget_Key__c" VARCHAR(255), 
	"Generic_Filter_1__c" VARCHAR(255), 
	"Generic_Filter_4__c" VARCHAR(255), 
	"Generic_Filter_3__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Scripts__c" VARCHAR(255), 
	"Sort_Order__c" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Start_Time__c" VARCHAR(255), 
	"Widget_Screen_Location__c" VARCHAR(255), 
	"Widget_Time_Zone__c" VARCHAR(255), 
	"Widget_Type__c" VARCHAR(255), 
	"Application_Control__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "EASY_Widget__c" VALUES(1,'Active','','<p><strong style="color: rgb(109, 54, 150); font-size: 18px;">Account</strong></p>','','ApplicationCreate;ApplicationPortal;ApplicationRegistration;ApplicationRequirement','Started App','','','','','','','','','Logout (UGNDO)','<div class="USTLine"></div>
<style>
.USTLine {
border-bottom: 5px solid #5f19a0;
margin-top: 5px;
margin-bottom: 4px;
width: 100%;
}
</style>','0.0','','','Right','Central Daylight Time (America/Chicago)','User Info Login/Logout','1');
CREATE TABLE "Plan__c" (
	id INTEGER NOT NULL, 
	"Active__c" VARCHAR(255), 
	"CIP_Code__c" VARCHAR(255), 
	"Career__c" VARCHAR(255), 
	"Degree__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Plan_Code__c" VARCHAR(255), 
	"Plan_Type__c" VARCHAR(255), 
	"Type__c" VARCHAR(255), 
	"Program__c" VARCHAR(255), 
	"Recruitment_Interest__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Plan__c" VALUES(1,'True','','Non-Degree','Non-Degree','Undergraduate Summer Non-Degree','','','Academic','1','');
CREATE TABLE "Program__c" (
	id INTEGER NOT NULL, 
	"Academic_Level__c" VARCHAR(255), 
	"Active__c" VARCHAR(255), 
	"Applicant_Type__c" VARCHAR(255), 
	"Application_Fee_Amount__c" VARCHAR(255), 
	"Associated_Schools__c" VARCHAR(255), 
	"Banner_Major_Name__c" VARCHAR(255), 
	"Banner_Program_Code__c" VARCHAR(255), 
	"Banner_Program_Name__c" VARCHAR(255), 
	"CIP_Code__c" VARCHAR(255), 
	"Career__c" VARCHAR(255), 
	"Citizenship__c" VARCHAR(255), 
	"College_Code__c" VARCHAR(255), 
	"Concentration_Code__c" VARCHAR(255), 
	"Concentration_Description__c" VARCHAR(255), 
	"Degree_Type__c" VARCHAR(255), 
	"Degree__c" VARCHAR(255), 
	"Delivery_Type__c" VARCHAR(255), 
	"Department_Code__c" VARCHAR(255), 
	"Description__c" VARCHAR(255), 
	"First_License__c" VARCHAR(255), 
	"Generic_Filter_1__c" VARCHAR(255), 
	"Generic_Filter_2__c" VARCHAR(255), 
	"Generic_Filter_3__c" VARCHAR(255), 
	"Generic_Filter_4__c" VARCHAR(255), 
	"Hide_Applicant_Type__c" VARCHAR(255), 
	"Hide_Citizenship__c" VARCHAR(255), 
	"Hide_Student_Type__c" VARCHAR(255), 
	"Hide_from_Application__c" VARCHAR(255), 
	"Integration_Program_Code__c" VARCHAR(255), 
	"License_Area__c" VARCHAR(255), 
	"Major_Code__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Number_of_Applications_Limit__c" VARCHAR(255), 
	"Pre_Professional_Program__c" VARCHAR(255), 
	"Program_Applicant_Type__c" VARCHAR(255), 
	"Program_Areas_of_Interest__c" VARCHAR(255), 
	"Program_Bucket__c" VARCHAR(255), 
	"Program_Code__c" VARCHAR(255), 
	"Program_College_of_Interest__c" VARCHAR(255), 
	"Program_Degree_Code__c" VARCHAR(255), 
	"Program_Display__c" VARCHAR(255), 
	"Program_Keywords__c" VARCHAR(255), 
	"Program_Learning_Style__c" VARCHAR(255), 
	"Program_Name_on_Application__c" VARCHAR(255), 
	"Program_Offered_Name__c" VARCHAR(255), 
	"Program_Record_Type__c" VARCHAR(255), 
	"Program_Type__c" VARCHAR(255), 
	"Program_URL__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Residency__c" VARCHAR(255), 
	"STEM_Major__c" VARCHAR(255), 
	"STVMAJR_CIPC_CODE__c" VARCHAR(255), 
	"STVMAJR_VALID_CONCENTRATN_IND__c" VARCHAR(255), 
	"STVMAJR_VALID_MAJOR_IND__c" VARCHAR(255), 
	"STVMAJR_VALID_MINOR_IND__c" VARCHAR(255), 
	"School_College__c" VARCHAR(255), 
	"Student_Type__c" VARCHAR(255), 
	"Application_Control__c" VARCHAR(255), 
	"Recruitment_Program__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Program__c" VALUES(1,'U','True','','','','','AS_UN_NDO','','','Undergraduate','','','','','','Bachelor of Arts','','','','','','','','','','','','False','AS_UN_NDO','','NDND','Undergraduate Summer Non-Degree','One Application Per Term and Program','False','Non-Degree','','','','Non-Degree','','','','','Undergraduate Summer Non-Degree','','Academic Program','Major','','0124P0000003S96QAE','','False','','','','','','','1','');
CREATE TABLE "Program__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Program__c_rt_mapping" VALUES('0124P0000003S96QAE','Academic_Program');
INSERT INTO "Program__c_rt_mapping" VALUES('0124P0000003S97QAE','Recruitment_Program');
CREATE TABLE "Question_Dependency__c" (
	id INTEGER NOT NULL, 
	"RecordTypeId" VARCHAR(255), 
	"ValueCheckbox__c" VARCHAR(255), 
	"Value__c" VARCHAR(255), 
	"Controlling_Question__c" VARCHAR(255), 
	"Question__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Question_Dependency__c" VALUES(1,'0124P0000003S9AQAU','True','Yes','62','70');
INSERT INTO "Question_Dependency__c" VALUES(2,'0124P0000003S9AQAU','True','Other','21','81');
INSERT INTO "Question_Dependency__c" VALUES(3,'0124P0000003S9AQAU','True','Other','21','83');
INSERT INTO "Question_Dependency__c" VALUES(4,'0124P0000003S9AQAU','True','Other','21','82');
INSERT INTO "Question_Dependency__c" VALUES(5,'0124P0000003S9AQAU','True','Yes','41','107');
INSERT INTO "Question_Dependency__c" VALUES(6,'0124P0000003S9AQAU','True','Yes','85','52');
INSERT INTO "Question_Dependency__c" VALUES(7,'0124P0000003S9AQAU','True','Yes','85','54');
INSERT INTO "Question_Dependency__c" VALUES(8,'0124P0000003S9AQAU','True','Yes','85','55');
INSERT INTO "Question_Dependency__c" VALUES(9,'0124P0000003S9AQAU','True','Yes','85','53');
INSERT INTO "Question_Dependency__c" VALUES(10,'0124P0000003S9AQAU','True','Yes','67','77');
INSERT INTO "Question_Dependency__c" VALUES(11,'0124P0000003S9AQAU','True','Home','108','68');
INSERT INTO "Question_Dependency__c" VALUES(12,'0124P0000003S9AQAU','True','Mobile','108','79');
INSERT INTO "Question_Dependency__c" VALUES(13,'0124P0000003S9AQAU','True','Mobile','108','80');
INSERT INTO "Question_Dependency__c" VALUES(14,'0124P0000003S9AQAU','True','Add another pronoun set','112','111');
INSERT INTO "Question_Dependency__c" VALUES(15,'0124P0000003S9AQAU','True','Add another pronoun set','112','111');
INSERT INTO "Question_Dependency__c" VALUES(16,'0124P0000003S99QAE','True','Black or African American','113','1');
INSERT INTO "Question_Dependency__c" VALUES(17,'0124P0000003S99QAE','True','American Indian or Alaskan Native','113','10');
INSERT INTO "Question_Dependency__c" VALUES(18,'0124P0000003S99QAE','True','American Indian or Alaskan Native','113','11');
INSERT INTO "Question_Dependency__c" VALUES(19,'0124P0000003S99QAE','True','American Indian or Alaskan Native','113','12');
INSERT INTO "Question_Dependency__c" VALUES(20,'0124P0000003S99QAE','True','American Indian or Alaskan Native','113','13');
INSERT INTO "Question_Dependency__c" VALUES(21,'0124P0000003S99QAE','True','Asian','113','20');
INSERT INTO "Question_Dependency__c" VALUES(22,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','113','58');
INSERT INTO "Question_Dependency__c" VALUES(23,'0124P0000003S99QAE','True','American Indian or Alaskan Native','113','138');
INSERT INTO "Question_Dependency__c" VALUES(24,'0124P0000003S99QAE','True','White','113','148');
INSERT INTO "Question_Dependency__c" VALUES(25,'0124P0000003S9AQAU','True','Yes','66','64');
INSERT INTO "Question_Dependency__c" VALUES(26,'0124P0000003S99QAE','True','Other','1','2');
INSERT INTO "Question_Dependency__c" VALUES(27,'0124P0000003S9AQAU','True','Yes','10','11');
INSERT INTO "Question_Dependency__c" VALUES(28,'0124P0000003S9AQAU','True','Yes','10','13');
INSERT INTO "Question_Dependency__c" VALUES(29,'0124P0000003S9AQAU','True','Yes','10','138');
INSERT INTO "Question_Dependency__c" VALUES(30,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','58','59');
INSERT INTO "Question_Dependency__c" VALUES(31,'0124P0000003S99QAE','True','Other East Asia','20','44');
INSERT INTO "Question_Dependency__c" VALUES(32,'0124P0000003S99QAE','True','Other South Asia','20','129');
INSERT INTO "Question_Dependency__c" VALUES(33,'0124P0000003S99QAE','True','Other Southeast Asia','20','130');
INSERT INTO "Question_Dependency__c" VALUES(34,'0124P0000003S99QAE','True','Other','148','149');
INSERT INTO "Question_Dependency__c" VALUES(35,'0124P0000003S99QAE','True','Other','64','65');
INSERT INTO "Question_Dependency__c" VALUES(36,'0124P0000003S9AQAU','True','Add another gender','57','56');
INSERT INTO "Question_Dependency__c" VALUES(37,'0124P0000003S9AQAU','True','Yes','45','3');
INSERT INTO "Question_Dependency__c" VALUES(38,'0124P0000003S9AQAU','True','Yes','45','4');
INSERT INTO "Question_Dependency__c" VALUES(39,'0124P0000003S9AQAU','True','Yes','45','5');
INSERT INTO "Question_Dependency__c" VALUES(40,'0124P0000003S9AQAU','True','Yes','45','6');
INSERT INTO "Question_Dependency__c" VALUES(41,'0124P0000003S9AQAU','True','Other','106','105');
INSERT INTO "Question_Dependency__c" VALUES(42,'0124P0000003S9AQAU','True','Yes','115','8');
INSERT INTO "Question_Dependency__c" VALUES(43,'0124P0000003S9AQAU','True','Yes','115','7');
INSERT INTO "Question_Dependency__c" VALUES(44,'0124P0000003S9AQAU','True','Yes','115','9');
INSERT INTO "Question_Dependency__c" VALUES(45,'0124P0000003S9AQAU','True','Yes','94','87');
INSERT INTO "Question_Dependency__c" VALUES(46,'0124P0000003S9AQAU','True','Yes','94','88');
INSERT INTO "Question_Dependency__c" VALUES(47,'0124P0000003S9AQAU','True','Yes','94','103');
INSERT INTO "Question_Dependency__c" VALUES(48,'0124P0000003S9AQAU','True','Yes','94','97');
INSERT INTO "Question_Dependency__c" VALUES(49,'0124P0000003S9AQAU','True','Yes','94','89');
INSERT INTO "Question_Dependency__c" VALUES(50,'0124P0000003S9AQAU','True','No','94','38');
INSERT INTO "Question_Dependency__c" VALUES(51,'0124P0000003S9AQAU','True','Yes','94','90');
INSERT INTO "Question_Dependency__c" VALUES(52,'0124P0000003S9AQAU','True','Yes','94','86');
INSERT INTO "Question_Dependency__c" VALUES(53,'0124P0000003S9AQAU','True','A different address','86','101');
INSERT INTO "Question_Dependency__c" VALUES(54,'0124P0000003S9AQAU','True','A different address','86','100');
INSERT INTO "Question_Dependency__c" VALUES(55,'0124P0000003S9AQAU','True','A different address','86','90');
INSERT INTO "Question_Dependency__c" VALUES(56,'0124P0000003S9AQAU','True','Yes','43','42');
INSERT INTO "Question_Dependency__c" VALUES(57,'0124P0000003S9AQAU','True','Yes','137','136');
INSERT INTO "Question_Dependency__c" VALUES(58,'0124P0000003S98QAE','True','TRUE','117','145');
INSERT INTO "Question_Dependency__c" VALUES(59,'0124P0000003S98QAE','True','TRUE','117','143');
INSERT INTO "Question_Dependency__c" VALUES(60,'0124P0000003S98QAE','True','TRUE','117','144');
INSERT INTO "Question_Dependency__c" VALUES(61,'0124P0000003S98QAE','True','TRUE','117','145');
INSERT INTO "Question_Dependency__c" VALUES(62,'0124P0000003S98QAE','True','TRUE','117','146');
INSERT INTO "Question_Dependency__c" VALUES(63,'0124P0000003S98QAE','True','TRUE','27','31');
INSERT INTO "Question_Dependency__c" VALUES(64,'0124P0000003S98QAE','True','TRUE','27','142');
INSERT INTO "Question_Dependency__c" VALUES(65,'0124P0000003S98QAE','True','TRUE','27','139');
INSERT INTO "Question_Dependency__c" VALUES(66,'0124P0000003S98QAE','True','TRUE','27','140');
INSERT INTO "Question_Dependency__c" VALUES(67,'0124P0000003S98QAE','True','TRUE','27','141');
INSERT INTO "Question_Dependency__c" VALUES(68,'0124P0000003S9AQAU','True','Other','60','84');
INSERT INTO "Question_Dependency__c" VALUES(69,'0124P0000003S9AQAU','True','Yes','114','23');
INSERT INTO "Question_Dependency__c" VALUES(70,'0124P0000003S99QAE','True','Other','23','28');
INSERT INTO "Question_Dependency__c" VALUES(71,'0124P0000003S99QAE','True','Community Based Organization/College Access Group','128','125');
INSERT INTO "Question_Dependency__c" VALUES(72,'0124P0000003S99QAE','True','High School Counselor/Teacher','128','61');
INSERT INTO "Question_Dependency__c" VALUES(73,'0124P0000003S99QAE','True','Friend/Relative','128','126');
INSERT INTO "Question_Dependency__c" VALUES(74,'0124P0000003S99QAE','True','St. Thomas Alumnus/a','128','131');
INSERT INTO "Question_Dependency__c" VALUES(75,'0124P0000003S99QAE','True','Other','128','127');
INSERT INTO "Question_Dependency__c" VALUES(76,'0124P0000003S99QAE','True','Independent College Counselor','128','71');
INSERT INTO "Question_Dependency__c" VALUES(77,'0124P0000003S9AQAU','True','Yes','109','40');
CREATE TABLE "Question_Dependency__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Question_Dependency__c_rt_mapping" VALUES('0124P0000003S98QAE','Checkbox');
INSERT INTO "Question_Dependency__c_rt_mapping" VALUES('0124P0000003S99QAE','Multi_Select_Picklist');
INSERT INTO "Question_Dependency__c_rt_mapping" VALUES('0124P0000003S9AQAU','Picklist');
INSERT INTO "Question_Dependency__c_rt_mapping" VALUES('0124P0000003S9BQAU','Radio');
CREATE TABLE "Question__c" (
	id INTEGER NOT NULL, 
	"Active__c" VARCHAR(255), 
	"Additional_Field_Validation__c" VARCHAR(255), 
	"Applicant_Type__c" VARCHAR(255), 
	"Application_Field__c" VARCHAR(255), 
	"Application_Status__c" VARCHAR(255), 
	"Assistive_Text__c" VARCHAR(255), 
	"Citizenship__c" VARCHAR(255), 
	"Contact_Field__c" VARCHAR(255), 
	"Date_Stamp__c" VARCHAR(255), 
	"Degree_Type__c" VARCHAR(255), 
	"Delivery_Type__c" VARCHAR(255), 
	"Dependency_Behavior__c" VARCHAR(255), 
	"Dependency_Logic__c" VARCHAR(255), 
	"Display_Order__c" VARCHAR(255), 
	"Display_as_Picklist__c" VARCHAR(255), 
	"Display_on_Admin_Review_Pages__c" VARCHAR(255), 
	"Editable_Application_Status__c" VARCHAR(255), 
	"External_Email_Field__c" VARCHAR(255), 
	"Generic_Filter_1__c" VARCHAR(255), 
	"Generic_Filter_2__c" VARCHAR(255), 
	"Generic_Filter_3__c" VARCHAR(255), 
	"Generic_Filter_4__c" VARCHAR(255), 
	"Hardcoded_Value__c" VARCHAR(255), 
	"Help_Text__c" VARCHAR(255), 
	"Hide_from_Application__c" VARCHAR(255), 
	"Label__c" VARCHAR(255), 
	"Length__c" VARCHAR(255), 
	"Lookup_Object__c" VARCHAR(255), 
	"Lookup_Where_Clause__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Name_Field_API_Name__c" VARCHAR(255), 
	"New_Reference_Field__c" VARCHAR(255), 
	"Picklist_Values__c" VARCHAR(255), 
	"Placeholder__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Related_Object_Field__c" VARCHAR(255), 
	"Required__c" VARCHAR(255), 
	"Residency__c" VARCHAR(255), 
	"School_College__c" VARCHAR(255), 
	"Static_Text__c" VARCHAR(255), 
	"Student_Type__c" VARCHAR(255), 
	"URL_Parameter__c" VARCHAR(255), 
	"Intended_Program__c" VARCHAR(255), 
	"Requirement_Item__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Question__c" VALUES(1,'true','','','Race_Black_African_American_Background__c','Started App;Submitted App','','','','false','','','','','23.0','true','true','Started App','false','','','','','','','false','Which best describes your Black or African American background? (You may select one or more)','','','','African background (UGNDO)','Name','false','U.S. / African American
Africa
Caribbean
Other','','0124P0000003S9JQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(2,'true','','','Race_Other_Black_Background__c','Started App;Submitted App','','','','false','','','','','24.0','false','true','Started App','false','','','','','','','false','Specify other Black or African American background','100.0','','','African other (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(3,'true','','','','Started App;Submitted App','','','','false','','','','','34.0','false','true','Started App','false','','','','','','','false','Agency Address','','','','Agency Address(UGNDO)','Name','false','','','0124P0000003S9CQAU','','','','','','','','','12');
INSERT INTO "Question__c" VALUES(4,'true','','','Agent_Email_International__c','Started App;Submitted App','','','','false','','','','','32.0','false','true','Started App','false','','','','','','','false','Agency Email','','','','Agency Email(UGNDO)','Name','false','','','0124P0000003S9HQAU','','Started App','','','','','','','12');
INSERT INTO "Question__c" VALUES(5,'true','','','Ed_Agent_International__c','Started App;Submitted App','','','','false','','','','','31.0','false','true','Started App','false','','','','','','','false','Agency Name','','','','Agency Name(UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','12');
INSERT INTO "Question__c" VALUES(6,'true','','','','Started App;Submitted App','','','','false','','','','','33.0','false','true','Started App','false','','','','','','','false','Agency Phone','','','','Agency Phone(UGNDO)','Name','false','','','0124P0000003S9MQAU','','','','','','','','','12');
INSERT INTO "Question__c" VALUES(7,'true','','','','Started App;Submitted App','','','','false','','','','','3.0','false','true','Started App','false','','','','','','','false','First/Given Name','','','','Alumni First/Given Name(UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','2');
INSERT INTO "Question__c" VALUES(8,'true','','','','Started App;Submitted App','','','','false','','','','','40.0','false','true','Started App','false','','','','','','','false','Last/Family/Surname','','','','Alumni Last/Family/Surname(UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','2');
INSERT INTO "Question__c" VALUES(9,'true','','','','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','Alumni Relationship','','','','Alumni Relationship(UGNDO)','Name','false','Parent/Guardian
Sibling
Grandparent
Aunt/Uncle
Cousin
Other','','0124P0000003S9NQAU','','Started App','','','','','','','2');
INSERT INTO "Question__c" VALUES(10,'true','','','Tribe_Enrolled_Ind__c','Started App;Submitted App','','','','false','','','','','15.0','true','true','Started App','false','','','','','','','false','Are you enrolled in a federally recognized tribe?','','','','American Indian Enrolled or not (UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(11,'true','','','','Started App;Submitted App','','','','false','','','','','17.0','false','true','Started App','false','','','','','','','false','','','','','American Indian Instructional (UGNDO)','Name','false','','','0124P0000003S9QQAU','','','','','<p>If you do not find your tribe in this list or if you have more than one to report, please use the tribal identity question above to add details.</p>','','','','9');
INSERT INTO "Question__c" VALUES(12,'true','','','Tribal_Identity__c','Started App;Submitted App','','','','false','','','','','14.0','false','true','Started App','false','','','','','','','false','Please tell us about your tribal identity or affiliation','100.0','','','American Indian other (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(13,'true','','','Tribe_Name__c','Started App;Submitted App','','','','false','','','','','16.0','true','true','Started App','false','','','','','','','false','Please choose the tribe you are enrolled in','','','','American Indian Tribe (UGNDO)','Name','false','AK - Afognak
AK - Agdaagux
AK - Akhiok
AK - Akiachak
AK - Akiak
AK - Akutan
AK - Alakanuk
AK - Alatna
AK - Aleknagik
AK - Algaaciq
AK - Allakaket
AK - Alutiiq Tribe of Old Harbor
AK - Ambler
AK - Anaktuvuk Pass
AK - Andreafski
AK - Angoon
AK - Aniak
AK - Anvik
AK - Arctic Slope
AK - Arctic Village
AK - Asa''carsarmiut
AK - Atka
AK - Atmautluak
AK - Atqasuk
AK - Barrow
AK - Beaver
AK - Belkofski
AK - Bill Moore''s Slough
AK - Birch Creek
AK - Brevig Mission
AK - Buckland
AK - Cantwell
AK - Chalkyitsik
AK - Cheesh-Na
AK - Chefornak
AK - Chenega
AK - Chevak
AK - Chickaloon
AK - Chignik Bay
AK - Chignik Lagoon
AK - Chignik Lake
AK - Chilkat
AK - Chilkoot
AK - Chinik
AK - Chitina
AK - Chuathbaluk
AK - Chuloonawick
AK - Circle
AK - Clark''s Point
AK - Council
AK - Craig
AK - Crooked Creek
AK - Curyung
AK - Deering
AK - Diomede
AK - Dot Lake
AK - Douglas
AK - Eagle
AK - Eek
AK - Egegik
AK - Eklutna
AK - Ekuk
AK - Ekwok
AK - Elim IRA
AK - Emmonak
AK - Evansville
AK - Eyak
AK - False Pass
AK - Fort Yukon
AK - Gakona
AK - Galena
AK - Gambell
AK - Georgetown
AK - Goodnews Bay
AK - Grayling
AK - Gulkana
AK - Hamilton
AK - Healy Lake
AK - Holy Cross
AK - Hoonah
AK - Hooper Bay
AK - Hughes
AK - Huslia
AK - Hydaburg
AK - Igiugig
AK - Iliamna
AK - Iqugmiut
AK - Ivanof Bay Tribe
AK - Kaguyuk
AK - Kake
AK - Kaktovik
AK - Kalskag
AK - Kaltag
AK - Kanatak
AK - Karluk
AK - Kasaan
AK - Kasigluk
AK - Kenaitze
AK - Ketchikan
AK - Kiana
AK - King Island
AK - King Salmon
AK - Kipnuk
AK - Kivalina
AK - Klawock
AK - Kluti-Kaah
AK - Knik
AK - Kobuk
AK - Kokhanok
AK - Kongiganak
AK - Kotlik
AK - Kotzebue
AK - Koyuk
AK - Koyukuk
AK - Kwethluk
AK - Kwigillingok
AK - Kwinhagak
AK - Larsen Bay
AK - Levelock
AK - Lime
AK - Lower Kalskag
AK - Manley Hot Springs
AK - Manokotak
AK - Marshall
AK - Mary''s Igloo
AK - Mcgrath
AK - Mekoryuk
AK - Mentasta
AK - Metlakatla
AK - Minto
AK - Naknek
AK - Nanwalek
AK - Napaimute
AK - Napakiak
AK - Napaskiak
AK - Nelson Lagoon
AK - Nenana
AK - New Koliganek
AK - New Stuyahok
AK - Newhalen
AK - Newtok
AK - Nightmute
AK - Nikolai
AK - Nikolski
AK - Ninilchik
AK - Noatak
AK - Nome
AK - Nondalton
AK - Noorvik
AK - Northway
AK - Nuiqsut
AK - Nulato
AK - Nunakauyarmiut
AK - Nunam Iqua
AK - Nunapitchuk
AK - Ohogamiut
AK - Orutsararmiut
AK - Oscarville
AK - Ouzinkie
AK - Paimiut
AK - Pauloff Harbor
AK - Pedro Bay
AK - Perryville
AK - Petersburg
AK - Pilot Point
AK - Pilot Station
AK - Pitka''s Point
AK - Platinum
AK - Point Hope IRA
AK - Point Lay IRA
AK - Port Graham
AK - Port Heiden
AK - Port Lions
AK - Portage Creek
AK - Qagan Tayagungin
AK - Qawalangin
AK - Rampart
AK - Red Devil
AK - Ruby
AK - Saint Paul
AK - Salamatof
AK - Savoonga
AK - Saxman
AK - Scammon Bay
AK - Selawik
AK - Seldovia
AK - Shageluk
AK - Shaktoolik
AK - Shishmaref IRA
AK - Shungnak
AK - Sitka
AK - Skagway
AK - Sleetmute
AK - Solomon
AK - South Naknek
AK - St. George
AK - St. Michael IRA
AK - Stebbins
AK - Stevens Village
AK - Stony River
AK - Sun''aq
AK - Takotna
AK - Tanacross
AK - Tanana
AK - Tangirnaq
AK - Tatitlek
AK - Tazlina
AK - Telida
AK - Teller
AK - Tetlin
AK - Tlingit & Haida
AK - Togiak
AK - Tuluksak
AK - Tuntutuliak
AK - Tununak
AK - Twin Hills
AK - Tyonek
AK - Ugashik
AK - Umkumiut
AK - Unalakleet
AK - Unga
AK - Venetie
AK - Venetie IRA
AK - Wainwright
AK - Wales
AK - White Mountain AK
AK - Wrangell
AK - Yakutat
AL - Poarch
AZ - Ak Chin
AZ - Cocopah
AZ - Colorado River
AZ - Fort McDowell
AZ - Gila River
AZ - Havasupai
AZ - Hopi
AZ - Hualapai
AZ - Kaibab
AZ - Navajo
AZ - Pascua Yaqui
AZ - Quechan
AZ - Salt River
AZ - San Carlos
AZ - San Juan
AZ - Tohono O''odham
AZ - Tonto Apache
AZ - White Mountain
AZ - Yavapai-Apache
AZ - Yavapai-Prescott
CA - Agua Caliente
CA - Alturas
CA - Augustine
CA - Bear River
CA - Benton
CA - Berry Creek
CA - Big Lagoon
CA - Big Pine
CA - Big Sandy
CA - Big Valley Rancheria
CA - Bishop Paiute
CA - Blue Lake
CA - Bridgeport Indian Colony
CA - Buena Vista Rancheria
CA - Cabazon
CA - Cachil DeHe
CA - Cahto
CA - Cahuilla
CA - California Valley
CA - Campo
CA - Capitan Grande
CA - Cedarville
CA - Chemehuevi
CA - Cher-Ae Heights
CA - Chicken Ranch
CA - Cloverdale
CA - Cold Springs
CA - Cortina
CA - Coyote Valley
CA - Dry Creek
CA - Elem
CA - Elk Valley
CA - Enterprise
CA - Ewiiaapaayp
CA - Federated Indians of Graton
CA - Fort Bidwell
CA - Fort Independence
CA - Fort Mojave
CA - Greenville
CA - Grindstone
CA - Guidiville
CA - Habematolel
CA - Hoopa
CA - Hopland
CA - Iipay
CA - Inaja
CA - Ione
CA - Jackson
CA - Jamul
CA - Karuk
CA - Kashia
CA - Koi
CA - La Jolla
CA - La Posta
CA - Lone Pine
CA - Los Coyotes
CA - Lytton
CA - Manchester
CA - Manzanita
CA - Mechoopda
CA - Mesa Grande
CA - Middletown
CA - Mooretown
CA - Morongo
CA - Northfork
CA - Pala
CA - Paskenta
CA - Pauma
CA - Pechanga
CA - Picayune
Ca - Pinoleville
CA - Pit River
CA - Potter Valley
CA - Quartz Valley
CA - Ramona
CA - Redding
CA - Redwood Valley
CA - Resighini
CA - Rincon
CA - Robinson
CA - Round Valley
CA - San Manuel
CA - San Pasqual
CA - Santa Rosa
CA - Santa Rosa of Cahuilla
CA - Santa Ynez
CA - Scotts Valley
CA - Sherwood Valley
CA - Shingle Springs
CA - Soboba
CA - Susanville
CA - Sycuan
CA - Table Mountain
CA - Tejon
CA - Timbi-sha Shoshone
CA - Tolowa Dee-Ni''
CA - Torres Martinez
CA - Tule River
CA - Tuolumne
CA - Twenty-Nine Palms
CA - United Auburn
CA - Viejas
CA - Wilton
CA - Wiyot
CA - Yocha Dehe
CA - Yurok
CO - Southern Ute
CO - Ute Mountain Ute
CT - Mashantucket Pequot
CT - Mohegan
FL - Miccosukee
FL - Seminole
IA - Sac & Fox of Mississippi
ID - Coeur D''Alene
ID - Kootenai
ID - Nez Perce
ID - Shoshone-Bannock
KS - Iowa of Kansas
KS - Kickapoo of Kansas
KS - Prairie Band
KS - Sac and Fox Nation of Missouri in Kansas and Nebraska
LA - Chitimacha
LA - Coushatta
LA - Jena
LA - Tunica-Biloxi
MA - Mashpee
MA - Wampanoag
ME - Aroostok
ME - Houlton
ME - Passamaquaddy Pleasant Point
ME - Passamaquoddy Indian Township
ME - Penobscot
MI - Bay Mills
MI - Grand Traverse
MI - Hannahville
MI - Keweenaw
MI - Lac Vieux
MI - Little River
MI - Little Traverse
MI - Match-e-be-nash-she-wish Band
MI - Nottawaseppi Potawatomi
MI - Pokagon
MI - Saginaw Chippewa
MI - Sault Ste. Marie
MN - Bois Forte
MN - Fond du Lac
MN - Grand Portage
MN - Leech Lake
MN - Lower Sioux
MN - Mille Lacs
MN - Minnesota Chippewa
MN - Prairie Island
MN - Red Lake
MN - Shakopee
MN - Upper Sioux
MN - White Earth
MO - Eastern Shawnee
MS - Mississippi Choctaw
MT - Assiniboine and Gros Ventre Tribes
MT - Assiniboine and Sioux
MT - Blackfeet
MT - Chippewa-Cree
MT - Confederated Salish
MT - Crow
MT - Little Shell Tribe
MT - Northern Cheyenne
NC - Eastern Cherokee
ND - Spirit Lake
ND - Standing Rock
ND - Three Affiliated
ND - Turtle Mountain
NE - Omaha
NE - Ponca of Nebraska
NE - Santee Sioux
NE - Winnebago
NM - Jicarilla
NM - Kewa Pueblo
NM - Mescalero Apache
NM - Ohkay Owingeh
NM - Pueblo of Acoma
NM - Pueblo of Cochiti
NM - Pueblo of Isleta
NM - Pueblo of Jemez
NM - Pueblo of Laguna
NM - Pueblo of Nambe
NM - Pueblo of Picuris
NM - Pueblo of Pojoaque
NM - Pueblo of San Felipe
NM - Pueblo of San Ildefonso
NM - Pueblo of Sandia
NM - Pueblo of Santa Ana
NM - Pueblo of Santa Clara
NM - Pueblo of Taos
NM - Pueblo of Tesuque
NM - Pueblo of Zia
NM - Ramah
NM - Zuni
NV - Duckwater
NV - Ely Shoshone
NV - Fort McDermitt
NV - Las Vegas
NV - Lovelock
NV - Moapa
NV - Paiute-Shoshone
NV - Pyramid Lake
NV - Reno-Sparks
NV - Shoshone-Paiute
NV - Summit Lake
NV - Te-Moak
NV - Walker River
NV - Washoe
NV - Winnemucca
NV - Yerington
NV - Yomba Shoshone
NY - Cayuga Nation of New York
NY - Oneida Indian Nation
NY - Onondaga
NY - Saint Regis
NY - Seneca
NY - Shinnecock
NY - Tonawanda
NY - Tuscarora
OK - Absentee-Shawnee
OK - Alabama-Quassarte
OK - Apache
OK - Caddo
OK - Cherokee
OK - Chickasaw
OK - Choctaw
OK - Citizen Potawatomi
OK - Comanche
OK - Delaware Nation
OK - Delaware Tribe
OK - Fort Sill
OK - Iowa of Oklahoma
OK - Kaw
OK - Kialegee
OK - Kickapoo of Oklahoma
OK - Kiowa
OK - Miami of Oklahoma
OK - Modoc
OK - Muscogee (Creek) Nation
OK - Osage Nation
OK - Otoe-Missouria
OK - Ottawa of Oklahoma
OK - Pawnee
OK - Peoria
OK - Ponca of Oklahoma
OK - Quapaw Nation
OK - Sac and Fox Nation, Oklahoma
OK - Seminole Nation of Oklahoma
OK - Seneca-Cayuga Nation
OK - Shawnee
OK - Thlopthlocco Tribal Town
OK - Tonkawa
OK - United Keetoowah
OK - Wichita
OK - Wyandotte
OK – Cheyenne and Arapaho Tribes
OR - Burns Paiute
OR - Confederated Coos
OR - Coquille
OR - Cow Creek
OR - Grand Ronde Tribes
OR - Klamath
OR - Siletz Tribe
OR - Umatilla Tribe
OR - Warms Springs Tribe
RI - Narragansett
SC - Catawba
SD - Cheyenne River Sioux Tribe
SD - Crow Creek
SD - Flandreau
SD - Lower Brule
SD - Oglala Sioux
SD - Rosebud
SD - Sisseton-Wahpeton
SD - Yankton
TX - Alabama-Coushatta
TX - Kickapoo of Texas
TX - Ysleta Del Sur
UT - Confederated Goshute
UT - Northwestern Shoshone
UT - Paiute of Utah
UT - Skull Valley
UT - Ute
VA - Chickahominy Indian Tribe - Eastern Division
VA - Chickahominy Indian Tribe, Inc.
VA - Monacan Indian Nation
VA - Nansemond Indian Tribe
VA - Pamunkey Indian Tribe
VA - Rappahannock Tribe, Inc.
VA - Upper Mattaponi Tribe
WA - Chehalis
WA - Confederated Colville
WA - Confederated Yakama
WA - Cowlitz
WA - Hoh
WA - Jamestown
WA - Kalispel
WA - Lower Elwha
WA - Lummi
WA - Makah
WA - Muckleshoot
WA - Nisqually
WA - Nooksack
WA - Port Gamble
WA - Puyallup
WA - Quileute
WA - Quinault
WA - Samish
WA - Sauk-Suiattle
WA - Shoalwater
WA - Skokomish
WA - Snoqualmie
WA - Spokane
WA - Squaxin
WA - Stillaguamish
WA - Suquamish
WA - Swinomish
WA - Tulalip
WA - Upper Skagit
WI - Bad River Band
WI - Forest County
WI - Ho-Chunk
WI - Lac Courte Oreilles
WI - Lac du Flambeau
WI - Menominee
WI - Oneida Nation (Wisconsin)
WI - Red Cliff
WI - Sokaogon
WI - St. Croix
WI - Stockbridge
WY - Eastern Shoshone
WY - Northern Arapaho','','0124P0000003S9NQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(14,'true','','','','Started App;Submitted App','','','','false','','','','','100.0','false','true','Started App','false','','','','','','','false','','','','','Applicant Feedback(UGNDO)','Name','false','','','0124P0000003S9IQAU','','','','','','','','','1');
INSERT INTO "Question__c" VALUES(15,'true','','','','Started App;Submitted App','','','','false','','','','','4.0','false','true','Started App','false','','','','','','','false','','','','','Application Changes Consent Text (UGNDO)','Name','false','','','0124P0000003S9QQAU','','Started App','','','<p>I understand that once my application has been submitted it may not be altered; I will need to contact the Office of Student Data and Registrar via email at <strong>registrar@stthomas.edu</strong> to provide additional information or make changes (ex. address change). <span style="color: rgb(255, 0, 0);">*</span></p>','','','','10');
INSERT INTO "Question__c" VALUES(16,'true','','','','Started App;Submitted App','','','','false','','','','','5.0','false','true','Started App','false','','','','','','','false','','','','','Application Changes Consent (UGNDO)','Name','false','I Agree','','0124P0000003S9NQAU','','Started App','','','','','','','10');
INSERT INTO "Question__c" VALUES(17,'true','','','','','','','','false','','','','','72.0','false','true','','false','','','','','','','false','Application Experience Feedback','','','','Application Feedback Static (UGNDO)','Name','false','','','0124P0000003S9QQAU','','','','','<p><span style="font-size: 15.6px; color: rgb(3, 45, 96);">We are interested in hearing about your experience with our online application. We appreciate your feedback. Thank you.</span></p>','','','','1');
INSERT INTO "Question__c" VALUES(18,'true','','','','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','','','','','Application Materials Consent Text (UGNDO)','Name','false','','','0124P0000003S9QQAU','','Started App','','','<p><br></p><p>I have reviewed each page of my application; I certify the information I have provided on this application and all other admission materials is complete, accurate and true to the best of my knowledge. <span style="color: rgb(255, 0, 0); background-color: rgb(255, 255, 255);">*</span></p>','','','','10');
INSERT INTO "Question__c" VALUES(19,'true','','','','Started App;Submitted App','','','','false','','','','','3.0','false','true','Started App','false','','','','','','','false','','','','','Application Materials Consent (UGNDO)','Name','false','I Agree','','0124P0000003S9NQAU','','Started App','','','','','','','10');
INSERT INTO "Question__c" VALUES(20,'true','','','Race_Asian_Background__c','Started App;Submitted App','','','','false','','','','','19.0','true','true','Started App','false','','','','','','','false','Which best describes your Asian background? (You may select one or more)','','','','Asian background (UGNDO)','Name','false','Cambodia
China
India
Japan
Korea
Malaysia
Pakistan
Philippines
Vietnam
Other East Asia
Other South Asia
Other Southeast Asia','','0124P0000003S9JQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(21,'true','','','Citizenship__c','','','','','false','','','','','1.0','true','true','','false','','','','','','','false','Please select the type of citizenship you currently hold:','','','','Citizenship (UGNDO)','Name','false','U.S. Citizen
U.S. Dual Citizen
U.S. Permanent Resident
Asylee/Refugee
International
Other','','0124P0000003S9NQAU','','Started App','','','','','','','19');
INSERT INTO "Question__c" VALUES(22,'true','','','','Started App;Submitted App','','','','false','','','','','5.0','false','true','Started App','false','','','','','','','false','City:','','','','City of Birth (UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','12');
INSERT INTO "Question__c" VALUES(23,'true','','','College_Readiness_Program__c','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','Please list the organization(s) below','','','','College Access Readiness Program Organizations(UGNDO)','Name','false','AVID
Big Brothers/Big Sisters
Boys and Girls Club
College Possible
Genesys Works
Mentoring Excellence Program (MEP)
Northside Achievement Zone
Tazel Institute
Upward Bound
Other','','0124P0000003S9JQAU','','','','','','','','','5');
INSERT INTO "Question__c" VALUES(24,'true','','','','Started App;Submitted App','','','','false','','','','','14.0','false','true','Started App','false','','','','','','','false','Attended from: (mm/yyyy)','','','','College Date Start(UGNDO)','Name','false','','','0124P0000003S9FQAU','hed__Start_Date__c','','','','','','','','4');
INSERT INTO "Question__c" VALUES(25,'true','','','','Started App;Submitted App','','','','false','','','','','16.0','false','true','Started App','false','','','','','','','false','College Degree','','','','College Degree(UGNDO)','Name','false','Associate''s
Bachelor''s
Master''s
Doctoral
Certificate
Post Graduate Diploma
Attended No Degree
Other
None','','0124P0000003S9NQAU','hed__Degree_Earned__c','','','','','','','','4');
INSERT INTO "Question__c" VALUES(26,'true','','','','Started App;Submitted App','','','','false','','','','','15.0','false','true','Started App','false','','','','','','','false','Attended to: (mm/yyyy)','','','','College End Start(UGNDO)','Name','false','','','0124P0000003S9FQAU','hed__End_Date__c','','','','','','','','4');
INSERT INTO "Question__c" VALUES(27,'true','','','','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','Check this box if you did not find your school.','','','','College Not Found Checkbox (UGNDO)','Name','false','','','0124P0000003S9DQAU','School_Not_Found__c','','','','','','','','4');
INSERT INTO "Question__c" VALUES(28,'true','','','','Started App;Submitted App','','','','false','','','','','3.0','false','true','Started App','false','','','','','','','false','List other Community Based Organization here','','','','Community Based Other (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','5');
INSERT INTO "Question__c" VALUES(29,'true','','','','Started App;Submitted App','','','','false','','','','','6.0','false','true','Started App','false','','','','','','','false','Country of Birth:','','','','Country of Birth (UGNDO)','Name','false','Afghanistan
Aland Islands
Albania
Algeria
American Samoa
Andorra
Angola
Anguilla
Antarctica
Antigua and Barbuda
Argentina
Armenia
Aruba
Australia
Austria
Azerbaijan
Bahamas
Bahrain
Bangladesh
Barbados
Belarus
Belgium
Belize
Benin
Bermuda
Bhutan
Bolivia
Bonaire, St Eustatius & Saba
Bosnia and Herzegovina
Botswana
Bouvet Island
Brazil
British Indian Ocean Territory
Brunei Darussalam
Bulgaria
Burkina Faso
Burundi
Cambodia
Cameroon
Canada
Cape Verde
Cayman Islands
Central African Republic
Chad
Chile
China
Christmas Island
Cocos (Keeling) Islands
Colombia
Comoros
Congo (Brazzaville)
Congo, Democratic Republic of the
Cook Islands
Costa Rica
Cote d''Ivoire
Croatia
Cuba
Curacao
Cyprus
Czech Republic
Denmark
Djibouti
Dominica
Dominican Republic
Ecuador
Egypt
El Salvador
Equatorial Guinea
Eritrea
Estonia
Eswatini (Swaziland)
Ethiopia
Falkland Islands (Malvinas)
Faroe Islands
Fiji
Finland
France
French Guiana
French Polynesia
French Southern Territories
Gabon
Gambia
Georgia
Germany
Ghana
Gibraltar
Greece
Greenland
Grenada
Guadeloupe
Guatemala
Guernsey
Guinea
Guinea-Bissau
Guyana
Haiti
Heard and McDonald Islands
Holy See (Vatican City State)
Honduras
Hong Kong
Hungary
Iceland
India
Indonesia
Iran, Islamic Republic of
Iraq
Ireland
Isle of Man
Israel
Italy
Jamaica
Japan
Jersey
Jordan
Kazakhstan
Kenya
Kiribati
Korea, Democratic People''s Republic of
Korea, Republic of
Kosovo
Kuwait
Kyrgyzstan
Laos
Latvia
Lebanon
Lesotho
Liberia
Libya
Liechtenstein
Lithuania
Luxembourg
Macao
Macedonia, Republic of
Madagascar
Malawi
Malaysia
Maldives
Mali
Malta
Marshall Islands
Martinique
Mauritania
Mauritius
Mayotte
Mexico
Micronesia, Federated States of
Moldova
Monaco
Mongolia
Montenegro
Montserrat
Morocco
Mozambique
Myanmar
Namibia
Nauru
Nepal
Netherlands
Netherlands Antilles
New Caledonia
New Zealand
Nicaragua
Niger
Nigeria
Niue
Norfolk Island
Northern Mariana Islands
Norway
Oman
Pakistan
Palau
Palestine, State of
Panama
Papua New Guinea
Paraguay
Peru
Philippines
Pitcairn
Poland
Portugal
Qatar
Reunion
Romania
Russian Federation
Rwanda
Saint Helena
Saint Kitts and Nevis
Saint Lucia
Saint Pierre and Miquelon
Saint Vincent and the Grenadines
Saint-Barthelemy
Saint-Martin (French part)
Samoa
San Marino
Sao Tome and Principe
Saudi Arabia
Senegal
Serbia
Seychelles
Sierra Leone
Singapore
Sint Maarten (Dutch part)
Slovakia
Slovenia
Solomon Islands
Somalia
South Africa
South Georgia and the South Sandwich Islands
South Sudan
Spain
Sri Lanka
Sudan
Suriname
Svalbard and Jan Mayen Islands
Sweden
Switzerland
Syrian Arab Republic (Syria)
Taiwan
Tajikistan
Tanzania, United Republic of
Thailand
Timor-Leste
Togo
Tokelau
Tonga
Trinidad and Tobago
Tunisia
Turkey
Turkmenistan
Turks and Caicos Islands
Tuvalu
Uganda
Ukraine
United Arab Emirates
United Kingdom
United States of America
United States Minor Outlying Islands
Uruguay
Uzbekistan
Vanuatu
Venezuela
Viet Nam
Virgin Islands, British
Wallis and Futuna Islands
Western Sahara
Yemen
Zambia
Zimbabwe
Other','','0124P0000003S9NQAU','','Started App','','','','','','','12');
INSERT INTO "Question__c" VALUES(30,'true','','','Citizenship_Country__c','Started App;Submitted App','','','','false','','','','','11.0','false','true','Started App','false','','','','','','','false','Country of Citizenship:','','','','Country of Citizenship (UGNDO)','Name','false','Afghanistan
Aland Islands
Albania
Algeria
American Samoa
Andorra
Angola
Anguilla
Antarctica
Antigua and Barbuda
Argentina
Armenia
Aruba
Australia
Austria
Azerbaijan
Bahamas
Bahrain
Bangladesh
Barbados
Belarus
Belgium
Belize
Benin
Bermuda
Bhutan
Bolivia
Bonaire, St Eustatius & Saba
Bosnia and Herzegovina
Botswana
Bouvet Island
Brazil
British Indian Ocean Territory
Brunei Darussalam
Bulgaria
Burkina Faso
Burundi
Cambodia
Cameroon
Canada
Cape Verde
Cayman Islands
Central African Republic
Chad
Chile
China
Christmas Island
Cocos (Keeling) Islands
Colombia
Comoros
Congo (Brazzaville)
Congo, Democratic Republic of the
Cook Islands
Costa Rica
Cote d''Ivoire
Croatia
Cuba
Curacao
Cyprus
Czech Republic
Denmark
Djibouti
Dominica
Dominican Republic
Ecuador
Egypt
El Salvador
Equatorial Guinea
Eritrea
Estonia
Eswatini (Swaziland)
Ethiopia
Falkland Islands (Malvinas)
Faroe Islands
Fiji
Finland
France
French Guiana
French Polynesia
French Southern Territories
Gabon
Gambia
Georgia
Germany
Ghana
Gibraltar
Greece
Greenland
Grenada
Guadeloupe
Guatemala
Guernsey
Guinea
Guinea-Bissau
Guyana
Haiti
Heard and McDonald Islands
Holy See (Vatican City State)
Honduras
Hong Kong
Hungary
Iceland
India
Indonesia
Iran, Islamic Republic of
Iraq
Ireland
Isle of Man
Israel
Italy
Jamaica
Japan
Jersey
Jordan
Kazakhstan
Kenya
Kiribati
Korea, Democratic People''s Republic of
Korea, Republic of
Kosovo
Kuwait
Kyrgyzstan
Laos
Latvia
Lebanon
Lesotho
Liberia
Libya
Liechtenstein
Lithuania
Luxembourg
Macao
Macedonia, Republic of
Madagascar
Malawi
Malaysia
Maldives
Mali
Malta
Marshall Islands
Martinique
Mauritania
Mauritius
Mayotte
Mexico
Micronesia, Federated States of
Moldova
Monaco
Mongolia
Montenegro
Montserrat
Morocco
Mozambique
Myanmar
Namibia
Nauru
Nepal
Netherlands
Netherlands Antilles
New Caledonia
New Zealand
Nicaragua
Niger
Nigeria
Niue
Norfolk Island
Northern Mariana Islands
Norway
Oman
Pakistan
Palau
Palestine, State of
Panama
Papua New Guinea
Paraguay
Peru
Philippines
Pitcairn
Poland
Portugal
Qatar
Reunion
Romania
Russian Federation
Rwanda
Saint Helena
Saint Kitts and Nevis
Saint Lucia
Saint Pierre and Miquelon
Saint Vincent and the Grenadines
Saint-Barthelemy
Saint-Martin (French part)
Samoa
San Marino
Sao Tome and Principe
Saudi Arabia
Senegal
Serbia
Seychelles
Sierra Leone
Singapore
Sint Maarten (Dutch part)
Slovakia
Slovenia
Solomon Islands
Somalia
South Africa
South Georgia and the South Sandwich Islands
South Sudan
Spain
Sri Lanka
Sudan
Suriname
Svalbard and Jan Mayen Islands
Sweden
Switzerland
Syrian Arab Republic (Syria)
Taiwan
Tajikistan
Tanzania, United Republic of
Thailand
Timor-Leste
Togo
Tokelau
Tonga
Trinidad and Tobago
Tunisia
Turkey
Turkmenistan
Turks and Caicos Islands
Tuvalu
Uganda
Ukraine
United Arab Emirates
United Kingdom
United States of America
United States Minor Outlying Islands
Uruguay
Uzbekistan
Vanuatu
Venezuela
Viet Nam
Virgin Islands, British
Wallis and Futuna Islands
Western Sahara
Yemen
Zambia
Zimbabwe
Other','','0124P0000003S9NQAU','','Started App','','','','','','','12');
INSERT INTO "Question__c" VALUES(31,'true','','','','Started App;Submitted App','','','','false','','','Hide','','1.0','false','true','Started App','false','','','','','','','false','Current or Most Recent College/University lookup','','Account','(Name !=''Unknown College'' AND Type=''College'' AND School_Inactive__c = FALSE)','Current College(UGNDO)','Name, BillingCity, BillingState','false','','','0124P0000003S9PQAU','hed__Account__c','Started App','','','','','','','4');
INSERT INTO "Question__c" VALUES(32,'true','','','Current_Courses__c','Started App;Submitted App','','','','false','','','','','3.0','false','true','Started App','false','','','','','','','false','Current Courses','','','','Current Courses(UGNDO)','Name','false','','','0124P0000003S9IQAU','','','','','','','','','8');
INSERT INTO "Question__c" VALUES(33,'true','','','','Started App;Submitted App','','','MailingAddress','false','','','','','1.0','false','true','Started App','false','','','','','','','false','Current Home Address','','','','Current Home Address(UGNDO)','Name','false','','','0124P0000003S9CQAU','','Started App','','','','','','','3');
INSERT INTO "Question__c" VALUES(34,'true','','','','Started App;Submitted App','','','','false','','','','','1.0','false','true','Started App','false','','','','','','','false','City:','','','','Current Location City (UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','12');
INSERT INTO "Question__c" VALUES(35,'true','','','','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','Country:','','','','Current Location Country (UGNDO)','Name','false','Afghanistan
Aland Islands
Albania
Algeria
American Samoa
Andorra
Angola
Anguilla
Antarctica
Antigua and Barbuda
Argentina
Armenia
Aruba
Australia
Austria
Azerbaijan
Bahamas
Bahrain
Bangladesh
Barbados
Belarus
Belgium
Belize
Benin
Bermuda
Bhutan
Bolivia
Bonaire, St Eustatius & Saba
Bosnia and Herzegovina
Botswana
Bouvet Island
Brazil
British Indian Ocean Territory
Brunei Darussalam
Bulgaria
Burkina Faso
Burundi
Cambodia
Cameroon
Canada
Cape Verde
Cayman Islands
Central African Republic
Chad
Chile
China
Christmas Island
Cocos (Keeling) Islands
Colombia
Comoros
Congo (Brazzaville)
Congo, Democratic Republic of the
Cook Islands
Costa Rica
Cote d''Ivoire
Croatia
Cuba
Curacao
Cyprus
Czech Republic
Denmark
Djibouti
Dominica
Dominican Republic
Ecuador
Egypt
El Salvador
Equatorial Guinea
Eritrea
Estonia
Eswatini (Swaziland)
Ethiopia
Falkland Islands (Malvinas)
Faroe Islands
Fiji
Finland
France
French Guiana
French Polynesia
French Southern Territories
Gabon
Gambia
Georgia
Germany
Ghana
Gibraltar
Greece
Greenland
Grenada
Guadeloupe
Guatemala
Guernsey
Guinea
Guinea-Bissau
Guyana
Haiti
Heard and McDonald Islands
Holy See (Vatican City State)
Honduras
Hong Kong
Hungary
Iceland
India
Indonesia
Iran, Islamic Republic of
Iraq
Ireland
Isle of Man
Israel
Italy
Jamaica
Japan
Jersey
Jordan
Kazakhstan
Kenya
Kiribati
Korea, Democratic People''s Republic of
Korea, Republic of
Kosovo
Kuwait
Kyrgyzstan
Laos
Latvia
Lebanon
Lesotho
Liberia
Libya
Liechtenstein
Lithuania
Luxembourg
Macao
Macedonia, Republic of
Madagascar
Malawi
Malaysia
Maldives
Mali
Malta
Marshall Islands
Martinique
Mauritania
Mauritius
Mayotte
Mexico
Micronesia, Federated States of
Moldova
Monaco
Mongolia
Montenegro
Montserrat
Morocco
Mozambique
Myanmar
Namibia
Nauru
Nepal
Netherlands
Netherlands Antilles
New Caledonia
New Zealand
Nicaragua
Niger
Nigeria
Niue
Norfolk Island
Northern Mariana Islands
Norway
Oman
Pakistan
Palau
Palestine, State of
Panama
Papua New Guinea
Paraguay
Peru
Philippines
Pitcairn
Poland
Portugal
Qatar
Reunion
Romania
Russian Federation
Rwanda
Saint Helena
Saint Kitts and Nevis
Saint Lucia
Saint Pierre and Miquelon
Saint Vincent and the Grenadines
Saint-Barthelemy
Saint-Martin (French part)
Samoa
San Marino
Sao Tome and Principe
Saudi Arabia
Senegal
Serbia
Seychelles
Sierra Leone
Singapore
Sint Maarten (Dutch part)
Slovakia
Slovenia
Solomon Islands
Somalia
South Africa
South Georgia and the South Sandwich Islands
South Sudan
Spain
Sri Lanka
Sudan
Suriname
Svalbard and Jan Mayen Islands
Sweden
Switzerland
Syrian Arab Republic (Syria)
Taiwan
Tajikistan
Tanzania, United Republic of
Thailand
Timor-Leste
Togo
Tokelau
Tonga
Trinidad and Tobago
Tunisia
Turkey
Turkmenistan
Turks and Caicos Islands
Tuvalu
Uganda
Ukraine
United Arab Emirates
United Kingdom
United States of America
United States Minor Outlying Islands
Uruguay
Uzbekistan
Vanuatu
Venezuela
Viet Nam
Virgin Islands, British
Wallis and Futuna Islands
Western Sahara
Yemen
Zambia
Zimbabwe
Other','','0124P0000003S9NQAU','','Started App','','','','','','','12');
INSERT INTO "Question__c" VALUES(36,'true','','','','Started App;Submitted App','','','','false','','','','','0.0','false','true','Started App','false','','','','','','','false','','','','','Current Location Static (UGNDO)','Name','false','','','0124P0000003S9QQAU','','','','','Enter your current location (this should be the actual place of residence of the student at the time of application. Please do not enter the location of a relative, friend, agent, etc.).','','','','12');
INSERT INTO "Question__c" VALUES(37,'true','','','Current_US_Visa_Type__c','Started App;Submitted App','','','','false','','','','','10.0','false','true','Started App','false','','','','','','','false','Currently held United States Visa','','','','Current US Visa Type(UGNDO)','Name','false','I do not hold a currently valid U.S. non-immigrant Visa
A-1 Foreign Diplomatic Personnel
A-2 Dependent Foreign Diplomatic Personnel
A-3 Employee of Foreign Gov Office
B-2 Tourist
E-2 Dependent of Treaty Investor
F-1 Student
F-2 Dependent of F-1 Student
G-1 Representative of Intl. Org.
G-2 Dependent of Representative of Intl. Org.
G-3 Dependent of Representative of Intl. Org.
G-4 Dependent of Representative of Intl. Org.
H-1 Work Visa
H-4 Dependent of H Visa Holder
J-1 Exchange Visitor
J-2 Dependent of J-1 Visa Holder
L-2 Dependent of L-1 Visa Holder
M-1 Student (Vocational)
M-2 Dependent of M-1 Student
R-2 Dependent of R-1 Visa Holder
Other Visa Type','','0124P0000003S9NQAU','','','','','','','','','12');
INSERT INTO "Question__c" VALUES(38,'true','','','','Started App;Submitted App','','','','false','','','','','3.0','false','true','Started App','false','','','','','','','false','Date Deceased','','','','Date Deceased (UGNDO)','Name','false','','','0124P0000003S9FQAU','Date_Deceased__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(39,'true','','','','Started App;Submitted App','','','Birthdate','false','','','','','16.0','false','true','Started App','false','','','','','','','false','What is your date of birth? (MM/DD/YYYY)','','','','Date of Birth(UGNDO)','Name','false','','','0124P0000003S9FQAU','','Started App','','','','','','','18');
INSERT INTO "Question__c" VALUES(40,'true','','','UST_Previous_Apply_Date__c','Started App;Submitted App','','','','false','','','','','71.0','false','true','Started App','false','','','','','','','false','Date of Previous Application','','','','Date of Previous Application(UGNDO)','Name','false','','','0124P0000003S9FQAU','','','','','','','','','1');
INSERT INTO "Question__c" VALUES(41,'true','','','','Started App;Submitted App','','','','false','','','','','5.0','false','true','Started App','false','','','','','','','false','Would you like to share a different first name that you go by?  (Official communications from St. Thomas may use this name)','','','','Different First Name (UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','','','','','18');
INSERT INTO "Question__c" VALUES(42,'true','','','','Started App;Submitted App','','','','false','','','Show','AND','7.0','false','true','Started App','false','','','','','','','false','Diploma/GED Earned Date','','','','Diploma/GED Earned Date(UGNDO)','Name','false','','','0124P0000003S9FQAU','Diploma_GED_Earned_Date__c','','','','','','','','7');
INSERT INTO "Question__c" VALUES(43,'true','','','','Started App;Submitted App','','','','false','','','','','6.0','false','true','Started App','false','','','','','','','false','Have you graduated or anticipate graduating or earning your General Educational Development (GED)?','','','','Diploma/GED Earned(UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','Diploma_GED_Earned__c','Started App','','','','','','','7');
INSERT INTO "Question__c" VALUES(44,'true','','','Race_Other_East_Asia__c','Started App;Submitted App','','','','false','','','','','20.0','false','true','Started App','false','','','','','','','false','Specify other East Asian background','100.0','','','East Asia other (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(45,'true','','','','Started App;Submitted App','','','','false','','','','','30.0','false','true','Started App','false','','','','','','','false','Are you working with an Educational Agent?','','','','Educational Agent(UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','','','','','12');
INSERT INTO "Question__c" VALUES(46,'true','','','','Started App','','International','','false','','','','','46.0','false','true','Started App','false','','','','','','','false','Based on the list of accepted options on our website listed above, which one did you already qualified for?','','','','English Proficiency answer (UGNDO)','Name','false','From an Exempted Country (list above)
TOEFL iBT
IELTS
Duolingo English Test
Minnesota English Language Program (MELP)
ELS Language Center
SAT
ACT
Pearson PTE Academic
Oxford Test of English
Cambridge English
GTEC CBT
International Baccalaureate (IB)
AP exam
Transfer from College in the United States
West African Exams Council Senior School Certificate
Kenya Certificate of Secondary Education (KCSE)
National Senior Certificate (South Africa)','','0124P0000003S9NQAU','','Started App','','','','','','','12');
INSERT INTO "Question__c" VALUES(47,'true','','','','Started App;Submitted App','','','','false','','','','','45.0','false','true','Started App','false','','','','','','','false','','','','','English Proficiency Info (UGNDO)','Name','false','','','0124P0000003S9QQAU','','','','','For more information on proof of English proficiency, please visit: <a href="https://www.stthomas.edu/admissions/undergraduate/international/english-proficiency/index.html" target="_blank">https://www.stthomas.edu/admissions/undergraduate/international/english-proficiency/index.html</a>','','','','12');
INSERT INTO "Question__c" VALUES(48,'true','','','','Started App;Submitted App','','','','false','','','','','44.0','false','true','Started App','false','','','','','','','false','Have you already achieved one or more of our approved proofs of English proficiency?','','','','English Proficiency (UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','<p>Have you already achieved one or more of our approved proofs of English proficiency?</p>','','','','12');
INSERT INTO "Question__c" VALUES(49,'true','','','','Started App;Submitted App','','','','false','','','','','15.0','false','true','Started App','false','','','','','','','false','','','','','EOE Statement (UGNDO)','Name','false','','','0124P0000003S9QQAU','','','','','<p><br></p><p><br></p><p><strong style="color: rgb(81, 35, 115);">The University of St. Thomas is an equal opportunity educator and employer. St. Thomas does not unlawfully discriminate, in any of its programs or activities, on the basis of race, color, creed, religion, national origin, sex, sexual orientation, family status, disability, age, marital status, status with regard to public assistance, membership or activity in a local commission, genetic information or any other characteristic protected by applicable law. </strong><a href="http://www.stthomas.edu/eostatement" target="_blank"><strong>http://www.stthomas.edu/eostatement</strong></a></p><p><strong> </strong></p><p><strong style="color: rgb(81, 35, 115);">The University of St. Thomas is registered with the Minnesota Office of Higher Education pursuant to sections 136A.61 to 136A.71. Registration is not an endorsement of the institution. Credits earned at the institution may not transfer to all other institutions. Contact information for the Minnesota Office of Higher Education is: 1450 Energy Park Drive, Suite 350 St. Paul, MN 55108-5227 Phone: (651) 642-0567 Toll Free: (800) 657-3866 Fax: (651) 642-0675 </strong><a href="https://www.ohe.state.mn.us/" target="_blank"><strong>https://www.ohe.state.mn.us/</strong></a></p>','','','','10');
INSERT INTO "Question__c" VALUES(50,'true','','','','Started App;Submitted App','','','FirstName','false','','','','','1.0','false','true','Started App','false','','','','','','','false','Legal First/Given Name:','255.0','','','First Name (UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','18');
INSERT INTO "Question__c" VALUES(51,'true','','','','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','Language Proficiency','','','','Fluency (UGNDO)','Name','false','First Language
Speak
Read
Write
Spoken at Home','','0124P0000003S9JQAU','Language_Fluency__c','','','','','','','','15');
INSERT INTO "Question__c" VALUES(52,'true','','','','Started App;Submitted App','','','hed__Former_First_Name__c','false','','','','','10.0','false','true','Started App','false','','','','','','','false','Former First Name','','','','Former First Name (UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','18');
INSERT INTO "Question__c" VALUES(53,'true','','','','Started App;Submitted App','','','hed__Former_Last_Name__c','false','','','','','12.0','false','true','Started App','false','','','','','','','false','Former Last Name','','','','Former Last Name(UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','18');
INSERT INTO "Question__c" VALUES(54,'true','','','','Started App;Submitted App','','','','false','','','','','9.0','false','true','Started App','false','','','','','','','false','Former Last/Family/Surname (if any)','','','','Former Last Name (UGNDO)','Name','false','','','0124P0000003S9RQAU','Maiden_Other_Last__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(55,'true','','','','Started App;Submitted App','','','hed__Former_Middle_Name__c','false','','','','','11.0','false','true','Started App','false','','','','','','','false','Former Middle Name','','','','Former Middle Name (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','18');
INSERT INTO "Question__c" VALUES(56,'true','','','Gender_Other__c','Started App;Submitted App','','','','false','','','','','1.0','false','false','Started App','false','','','','','','','false','If you would like the opportunity, we invite you to share more about your gender identity below:','','','','Gender Identity (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(57,'true','','','Generic_Filter_2__c','Started App;Submitted App','','','','false','','','','','0.0','true','true','Started App','false','','','','','','','false','Gender','','','','Gender (UGNDO)','Name','false','Female
Male
Nonbinary
Add another gender','','0124P0000003S9NQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(58,'true','','','Race_Native_Pacific_Islander_Background__c','Started App;Submitted App','','','','false','','','','','25.0','false','true','Started App','false','','','','','','','false','Which best describes your Native Hawaiian or Other Pacific Islander background? (You may select one or more)','','','','Hawaiian background (UGNDO)','Name','false','Guam
Hawaii
Samoa
Other Pacific Islands (excluding Philippines)','','0124P0000003S9JQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(59,'true','','','Race_Other_Pacific_Islander__c','Started App;Submitted App','','','','false','','','','','26.0','false','true','Started App','false','','','','','','','false','Specify other Native Hawaiian or Other Pacific Islander background','100.0','','','Hawaiian other (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(60,'true','','','Highest_Level_Math__c','Started App;Submitted App','','','','false','','','','','1.0','true','true','Started App','false','','','','','','','false','Please provide the highest level math course you will complete by the end of your senior year.','','','','Highest Math (UGNDO)','Name','false','Algebra 1
Geometry
Algebra 2
Pre-Calculus
Calculus
Other Advanced Math (Algebra 3, Statistics, Trigonometry or other)
AP Calculus AB
AP Calculus BC
(IB) Mathematics SL or Mathematical Studies SL
(IB) Mathematics HL
Other','','0124P0000003S9NQAU','','','','','','','','','8');
INSERT INTO "Question__c" VALUES(61,'true','','','','Started App;Submitted App','','','','false','','','','','47.0','false','true','Started App','false','','','','','','','false','You selected High School Counselor/Teacher. Please provide more details:','','','','High School CounselorTeacher(UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','1');
INSERT INTO "Question__c" VALUES(62,'true','','','','','','','','false','','','','','5.0','false','true','','false','','','','','','','false','Are you currently in High School?','','','','High School (UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','','','','','19');
INSERT INTO "Question__c" VALUES(63,'true','','','','Started App;Submitted App','','','','false','','','Hide','','0.0','false','true','Started App','false','','','','','','','false','High School/Secondary School Lookup','','Account','(Name !=''Unknown High School'' AND Type=''High School'')','High School (UGNDO)','Name, BillingCity, BillingState','false','','','0124P0000003S9PQAU','hed__Account__c','Started App','','','','','','','7');
INSERT INTO "Question__c" VALUES(64,'true','','','Race_Hispanic_Background__c','Started App;Submitted App','','','','false','','','','','11.0','true','true','Started App','false','','','','','','','false','Which best describes your Hispanic or Latino/a/x background? (You may select one or more)','','','','Hispanic Latino background (UGNDO)','Name','false','Central America
Cuba
Mexico
Puerto Rico
South America
Spain
Other','','0124P0000003S9JQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(65,'true','','','Race_Other_Hispanic__c','Started App;Submitted App','','','','false','','','','','12.0','false','true','Started App','false','','','','','','','false','Specify other Hispanic or Latino/a/x background','100.0','','','Hispanic Latino other (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(66,'true','','','Race_Hispanic_Latino__c','Started App;Submitted App','','','','false','','','','','10.0','false','true','Started App','false','','','','','','','false','Are you Hispanic or Latino?','','','','Hispanic/Latino(UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(67,'true','','','','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','Is your permanent address different than your current mailing address?','','','','Home Different From Mailing(UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','','','','','3');
INSERT INTO "Question__c" VALUES(68,'true','','','','Started App;Submitted App','','','HomePhone','false','','','','','3.0','false','true','Started App','false','','','','','','','false','Home Phone','','','','Home Phone(UGNDO)','Name','false','','','0124P0000003S9MQAU','','Started App','','','','','','','6');
INSERT INTO "Question__c" VALUES(69,'true','','','Honors_Activities_Desc__c','Started App;Submitted App','','','','false','','','','','','false','true','Started App','false','','','','','','','false','Please provide activities that take up your time outside the classroom. Examples of activities might include: arts or music, clubs, family responsibilities, hobbies, work or volunteering, and more.','','','','Honors & Activities (UGNDO)','Name','false','','','0124P0000003S9IQAU','','','','','','','','','13');
INSERT INTO "Question__c" VALUES(70,'true','','','','','','','','false','','','','','6.0','false','true','','false','','','','','','IMPORTANT: Only Junior and Senior students at the time of enrollment are eligible to take courses.','false','What will be your grade level when you enroll at St. Thomas?','','','','HS Grade Level (UGNDO)','Name','false','11th grade (Junior)
12th grade (Senior)','','0124P0000003S9NQAU','','Started App','','','','','','','19');
INSERT INTO "Question__c" VALUES(71,'true','','','','Started App;Submitted App','','','','false','','','','','48.0','false','true','Started App','false','','','','','','','false','You selected Independent College Counselor. Please provide more details:','','','','IndependentCollegeCounselor(UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','1');
INSERT INTO "Question__c" VALUES(72,'true','','','','Started App;Submitted App','','','','false','','','','','0.0','false','true','Started App','false','','','','','','','false','','','','','Instructions (UGNDO)','Name','false','','','0124P0000003S9QQAU','','Started App','','','<p><strong>Please affirm the following before you submit your application.</strong></p>','','','','10');
INSERT INTO "Question__c" VALUES(73,'true','','','','Started App;Submitted App','','','','false','','','','','1.0','false','true','Started App','false','','','','','','','false','Please select the language(s) in which you are proficient.','','hed__Language__c','','Language (UGNDO)','Name','false','','','0124P0000003S9PQAU','hed__Language__c','Started App','','','','','','','15');
INSERT INTO "Question__c" VALUES(74,'true','','','','Started App;Submitted App','','','LastName','false','','','','','3.0','false','true','Started App','false','','','','','','','false','Last/Family/Surname:','255.0','','','Last Name (UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','18');
INSERT INTO "Question__c" VALUES(75,'true','','','Legal_Sex__c','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','What is your legal sex?','','','','Legal sex (UGNDO)','Name','false','Female
Male','','0124P0000003S9NQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(76,'true','','','','Started App;Submitted App','','','','false','','','','','4.0','false','true','Started App','false','','','','','','','false','','','','','Location of Birth Static (UGNDO)','Name','false','','','0124P0000003S9QQAU','','','','','Enter your city and country of birth.','','','','12');
INSERT INTO "Question__c" VALUES(77,'true','','','','Started App;Submitted App','','','OtherAddress','false','','','','','3.0','false','true','Started App','false','','','','','','','false','Permanent Address','','','','Mailing Address(UGNDO)','Name','false','','','0124P0000003S9CQAU','','Started App','','','','','','','3');
INSERT INTO "Question__c" VALUES(78,'true','','','','Started App;Submitted App','','','MiddleName','false','','','','','2.0','false','true','Started App','false','','','','','','','false','Middle Name:','255.0','','','Middle Name (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','18');
INSERT INTO "Question__c" VALUES(79,'true','','','','Started App;Submitted App','','','Admissions_Mobile_Opt_In__c','false','','','','','2.0','false','true','Started App','false','','','','','','','false','Are you willing to receive text messages from the admissions office at St. Thomas? (Users can opt-out by texting STOP to unsubscribe at any time. Message and data rates may apply.)','','','','Mobile Opt In(UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','','','','','6');
INSERT INTO "Question__c" VALUES(80,'true','','','','Started App;Submitted App','','','MobilePhone','false','','','','','1.0','false','true','Started App','false','','','','','','','false','Mobile Phone','','','','Mobile Phone(UGNDO)','Name','false','','','0124P0000003S9MQAU','','Started App','','','','','','','6');
INSERT INTO "Question__c" VALUES(81,'true','','','','','','','','false','','','','','2.0','false','true','','false','','','','','','','false','','','','','Other Citizenship Confirm (UGNDO)','Name','false','','','0124P0000003S9QQAU','','','','','You have selected Other as your citizenship status.  <i>If you are coming to the US with a non-immigrant visa, including F-1 Student Visa, please update your response to International. </i>','','','','19');
INSERT INTO "Question__c" VALUES(82,'true','','','','','','','','false','','','','','4.0','false','true','','false','','','','','','','false','','255.0','','','Other Citizenship Information (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','19');
INSERT INTO "Question__c" VALUES(83,'true','','','','','','','','false','','','','','3.0','false','true','','false','','','','','','','false','','','','','Other Citizenship Static Text (UGNDO)','Name','false','','','0124P0000003S9QQAU','','','','','Please share additional information in the field below. If you have DACA or Dreamer status, please specify. Note: All information shared will be treated as confidential and will be maintained separately from the application.','','','','19');
INSERT INTO "Question__c" VALUES(84,'true','','','Highest_Math_Other__c','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','Specify other math','','','','Other Math (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','8');
INSERT INTO "Question__c" VALUES(85,'true','','','Other_Names_Indicator__c','Started App;Submitted App','','','','false','','','','','9.0','false','true','Started App','false','','','','','','','false','Have you ever used any other names?','','','','Other Names (UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','','','','','','','','18');
INSERT INTO "Question__c" VALUES(86,'true','','','','Started App;Submitted App','','','','false','','','','','24.0','false','true','Started App','false','','','','','','','false','Address is:','','','','Parent Address is (UGNDO)','Name','false','Same as my Current Address
Same as my Mailing Address
A different address
Unknown','','0124P0000003S9NQAU','Family_Address_Relationship__c','Started App','','','','','','','16');
INSERT INTO "Question__c" VALUES(87,'true','','','','Started App;Submitted App','','','','false','','','','','22.0','false','true','Started App','false','','','','','','','false','Cell Phone','','','','Parent Cell Phone(UGNDO)','Name','false','','','0124P0000003S9MQAU','Cell_Phone__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(88,'true','','','','Started App;Submitted App','','','','false','','','','','20.0','false','true','Started App','false','','','','','','','false','Email','','','','Parent Email (UGNDO)','Name','false','','','0124P0000003S9HQAU','Email__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(89,'true','','','','Started App;Submitted App','','','','false','','','','','30.0','false','true','Started App','false','','','','','','','false','Employer (if applicable)','','','','Parent Employer(UGNDO)','Name','false','','','0124P0000003S9RQAU','Employer__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(90,'true','','','','Started App;Submitted App','','','','false','','','','','25.0','false','true','Started App','false','','','','','','','false','Parent''s Street Address','','','','Parent First Address (UGNDO)','Name','false','','','0124P0000003S9RQAU','Street__c','Started App','','','','','','','16');
INSERT INTO "Question__c" VALUES(91,'true','','','','Started App;Submitted App','','','','false','','','','','5.0','false','true','Started App','false','','','','','','','false','First/Given Name','','','','Parent First/Given Name (UGNDO)','Name','false','','','0124P0000003S9RQAU','First_Name__c','Started App','','','','','','','16');
INSERT INTO "Question__c" VALUES(92,'true','','','','Started App;Submitted App','','','','false','','','','','29.0','false','true','Started App','false','','','','','','','false','Education Level','','','','Parent/Guardian Ed Level (UGNDO)','Name','false','Some grade/primary school
Completed grade/primary school
Some high/secondary school
Graduated from high/secondary school (or equivalent)
Some trade school or community college
Graduated from trade school or community college
Some college/university
Graduated from college/university
Graduate school
None','','0124P0000003S9NQAU','Highest_Level_of_Education__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(93,'true','','','','Started App;Submitted App','','','','false','','','','','1.0','false','true','Started App','false','','','','','','','false','Parent/Guardian Type','','','','Parent/Guardian Information (UGNDO)','Name','false','Mother
Father
Guardian','','0124P0000003S9NQAU','Relationship__c','Started App','','','','','','','16');
INSERT INTO "Question__c" VALUES(94,'true','','','','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','Is parent/guardian living?','','','','Parent/Guardian Living (UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','Parent_Living__c','Started App','','','','','','','16');
INSERT INTO "Question__c" VALUES(95,'true','','','','Started App;Submitted App','','','','false','','','','','31.0','false','true','Started App','false','','','','','','','false','Occupation (former occupation, if retired or deceased)','','','','Parent/Guardian Occupation (UGNDO)','Name','false','Accountant or actuary
Actor or entertainer
Architect or urban planner
Artist
Business (clerical)
Business executive (management, admiinistrator)
Business owner or proprietor
Clergy (minister, priest)
Clergy (other religious)
Clinical psychologist
College administrator/staff
College teacher
Computer programmer or analyst
Conservationist or forester
Dentist (including orthodontist)
Dietitian or nutritionist
Engineer
Farmer or rancher
Foreign service worker (including diplomat)
Homemaker (full-time)
Interior decorator (including designer)
Lab techinician or hygenist
Laborer
Law enforcement officer
Lawyer (attorney) or judge
Military service (career)
Musician (performer, composer)
Nurse
Optometrist
Pharmacist
Physician
Policymaker/Government
School counselor
School principal or superintendent
Scientific researcher
Skilled trades
Social, welfare, or recreation worker
Teacher or administrator (elementary)
Teacher or administrator (secondary)
Therapist (physical, occupational, speech)
Veterinarian
Writer or journalist
Other','','0124P0000003S9RQAU','Occupation__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(96,'true','','','','Started App;Submitted App','','','','false','','','','','4.0','false','true','Started App','false','','','','','','','false','Prefix','','','','Parent/Guardian Prefix (UGNDO)','Name','false','Dr.
Mr.
Ms.
Mrs.
Mx.
Other','','0124P0000003S9NQAU','Prefix__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(97,'true','','','','Started App;Submitted App','','','','false','','','','','21.0','false','true','Started App','false','','','','','','','false','Home Phone','','','','Parent Home Phone(UGNDO)','Name','false','','','0124P0000003S9MQAU','Home_Phone__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(98,'true','','','','Started App;Submitted App','','','','false','','','','','7.0','false','true','Started App','false','','','','','','','false','Last/Family/Surname','','','','Parent Last Name (UGNDO)','Name','false','','','0124P0000003S9RQAU','Last_Name__c','Started App','','','','','','','16');
INSERT INTO "Question__c" VALUES(99,'true','','','','Started App;Submitted App','','','','false','','','','','6.0','false','true','Started App','false','','','','','','','false','Middle Name','','','','Parent Middle Name (UGNDO)','Name','false','','','0124P0000003S9RQAU','Middle_Name__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(100,'true','','','','Started App;Submitted App','','','','false','','','','','27.0','false','true','Started App','false','','','','','','','false','City','','','','Parent''s City (UGNDO)','Name','false','','','0124P0000003S9RQAU','City__c','Started App','','','','','','','16');
INSERT INTO "Question__c" VALUES(101,'true','','','','Started App;Submitted App','','','','false','','','','','26.0','false','true','Started App','false','','','','','','','false','Country','','','','Parent''s Country (UGNDO)','Name','false','','','0124P0000003S9RQAU','Country__c','Started App','','','','','','','16');
INSERT INTO "Question__c" VALUES(102,'true','','','','Started App;Submitted App','','','','false','','','','','0.0','false','true','Started App','false','','','','','','','false','Parents'' marital status (relative to each other)','','','','Parents Marital Status (UGNDO)','Name','false','Married
Separated
Divorced
Never Married
Widowed
Civil Union/Domestic Partners','','0124P0000003S9NQAU','','Started App','','','','','','','14');
INSERT INTO "Question__c" VALUES(103,'true','','','','Started App;Submitted App','','','','false','','','','','23.0','false','true','Started App','false','','','','','','','false','Work Phone','','','','Parent Work Phone(UGNDO)','Name','false','','','0124P0000003S9MQAU','Work_Phone__c','','','','','','','','16');
INSERT INTO "Question__c" VALUES(104,'true','','','','Started App;Submitted App','','','','false','','','','','15.0','false','true','Started App','false','','','','','','','false','Enter your permanent address in your home country.','','','','Permanent Address(UGNDO)','Name','false','','','0124P0000003S9CQAU','','Started App','','','','','','','12');
INSERT INTO "Question__c" VALUES(105,'true','','','','Started App;Submitted App','','','','false','','','','','3.0','false','true','Started App','false','','','','','','','false','Specify with whom you make your permanent home','','','','Permanent Home Other(UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','14');
INSERT INTO "Question__c" VALUES(106,'true','','','','Started App;Submitted App','','','','false','','','','','1.0','false','true','Started App','false','','','','','','','false','With whom do you make your permanent home?','','','','Permanent Home With (UGNDO)','Name','false','Parent 1
Parent 2
Both Parents
Legal Guardian
Ward of the Court/State
Other','','0124P0000003S9NQAU','','Started App','','','','','','','14');
INSERT INTO "Question__c" VALUES(107,'true','','','','Started App;Submitted App','','','Preferred_First_Name__c','false','','','','','6.0','false','true','Started App','false','','','','','','','false','Preferred First Name','255.0','','','Preferred First Name(UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','18');
INSERT INTO "Question__c" VALUES(108,'true','','','','Started App;Submitted App','','','hed__PreferredPhone__c','false','','','','','0.0','false','true','Started App','false','','','','','','','false','Preferred Phone','','','','Preferred Phone(UGNDO)','Name','false','Mobile
Home','','0124P0000003S9NQAU','','Started App','','','','','','','6');
INSERT INTO "Question__c" VALUES(109,'true','','','UST_Previous_Apply_Ind__c','Started App;Submitted App','','','','false','','','','','70.0','false','true','Started App','false','','','','','','','false','Have you previously enrolled in a Non-degree program at the University of St. Thomas?','','','','Previously Applied(UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','','','','','1');
INSERT INTO "Question__c" VALUES(110,'true','','','','Started App;Submitted App','','','','false','','','','','3.0','false','true','Started App','false','','','','','','','false','Is this your primary/preferred language?','','','','Primary Language (UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','Primary_Language__c','Started App','','','','','','','15');
INSERT INTO "Question__c" VALUES(111,'true','','','My_Pronouns__c','Started App;Submitted App','','','','false','','','','','4.0','false','true','Started App','false','','','','','','','false','My pronouns','','','','Pronouns Add (UGNDO)','Name','false','','','0124P0000003S9RQAU','','Started App','','','','','','','9');
INSERT INTO "Question__c" VALUES(112,'true','','','Pronouns__c','Started App;Submitted App','','','','false','','','','','3.0','true','true','Started App','false','','','','','','','false','Pronouns','','','','Pronouns (UGNDO)','Name','false','He/Him
She/Her
They/Them
Add another pronoun set','','0124P0000003S9JQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(113,'true','','','Ethnicity__c','Started App;Submitted App','','','','false','','','','','13.0','true','true','Started App','false','','','','','','','false','Regardless of your answer to the prior question, please indicate how you identify yourself. (You may select one or more)','','','','Race (UGNDO)','Name','false','American Indian or Alaskan Native
Asian
Black or African American
Native Hawaiian or Pacific Islander
White','','0124P0000003S9JQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(114,'true','','','','Started App;Submitted App','','','','false','','','','','1.0','false','true','Started App','false','','','','','','','false','Are you currently, or have you been, a member of a college access program such as College Possible, Trio, AVID, etc.?','','','','Readiness Program(UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','','','','','5');
INSERT INTO "Question__c" VALUES(115,'true','','','','Started App;Submitted App','','','','false','','','','','1.0','false','true','Started App','false','','','','','','','false','Have any relatives ever attended the University of St. Thomas? (including the 4-year undergraduate, Dougherty Family College 2-year or graduate programs)','','','','Relatives Attended UST(UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','','','','','2');
INSERT INTO "Question__c" VALUES(116,'true','','','Religious_Preference__c','Started App;Submitted App','','','','false','','','','','5.0','false','true','Started App','false','','','','','','','false','Religious Preference','','','','Religious Preference(UGNDO)','Name','false','Baptist
Buddhist
Chinese Religions
Episcopal
Ev. Lutheran Church/America
Hinduism
Jewish
Methodist
Muslim
Native American
Orthodox
Other Christian
Other Lutheran
Other Non-Christian
Presbyterian
Roman Catholic
Prefer not to Respond
None','','0124P0000003S9NQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(117,'true','','','','Started App;Submitted App','','','','false','','','','','1.0','false','true','Started App','false','','','','','','','false','Check this box if you did not find your school.','','','','School Not Found Checkbox (UGNDO)','Name','false','','','0124P0000003S9DQAU','School_Not_Found__c','','','','','','','','7');
INSERT INTO "Question__c" VALUES(118,'true','','','','Started App;Submitted App','','','','false','','','','','5.0','false','true','Started App','false','','','','','','','false','Age','','','','Sibling Age (UGNDO)','Name','false','','','0124P0000003S9KQAU','Age__c','Started App','','','','','','','20');
INSERT INTO "Question__c" VALUES(119,'true','','','','Started App;Submitted App','','','','false','','','','','2.0','false','true','Started App','false','','','','','','','false','First/Given Name','','','','Sibling First/Given Name(UGNDO)','Name','false','','','0124P0000003S9RQAU','First_Name__c','Started App','','','','','','','20');
INSERT INTO "Question__c" VALUES(120,'true','','','','Started App;Submitted App','','','','false','','','','','4.0','false','true','Started App','false','','','','','','','false','Last/Family/Surname','','','','Sibling Last/Family/Surname(UGNDO)','Name','false','','','0124P0000003S9RQAU','Last_Name__c','Started App','','','','','','','20');
INSERT INTO "Question__c" VALUES(121,'true','','','','Started App;Submitted App','','','','false','','','','','3.0','false','true','Started App','false','','','','','','','false','Middle Name','','','','Sibling Middle Name (UGNDO)','Name','false','','','0124P0000003S9RQAU','Middle_Name__c','','','','','','','','20');
INSERT INTO "Question__c" VALUES(122,'true','','','','Started App;Submitted App','','','','false','','','','','1.0','false','true','Started App','false','','','','','','','false','Sibling Relationship','','','','Sibling Relationship(UGNDO)','Name','false','Sister
Brother
Twin
Triplet
Quadruplet
Step-sister
Step-brother','','0124P0000003S9NQAU','Relationship__c','Started App','','','','','','','20');
INSERT INTO "Question__c" VALUES(123,'true','','','','Started App;Submitted App','','','','false','','','','','6.0','false','true','Started App','false','','','','','','','false','Are any of your siblings (including half and/or step) also applying to the University of St. Thomas for this same term?','','','','Siblings applying to UST (UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','','','','','14');
INSERT INTO "Question__c" VALUES(124,'true','validateSSN','','','Started App;Submitted App','','U.S. Citizen;U.S. Dual Citizen;U.S. Permanent Resident;Asylee/Refugee;Other','hed__Social_Security_Number__c','false','','','','','17.0','false','true','Started App','false','','','','','','','false','Social Security Number','11.0','','','Social Security Number (UGNDO)','Name','false','','XXX-XX-XXXX','0124P0000003S9TQAU','','','','','','','','','18');
INSERT INTO "Question__c" VALUES(125,'true','','','','Started App;Submitted App','','','','false','','','','','44.0','false','true','Started App','false','','','','','','','false','You selected Community Based Organization/College Access Group. Please provide more details:','','','','SourceCommunityBasedOrg(UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','1');
INSERT INTO "Question__c" VALUES(126,'true','','','','Started App;Submitted App','','','','false','','','','','45.0','false','true','Started App','false','','','','','','','false','You selected Friend/Relative. Please provide more details:','','','','SourceFriendRelative(UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','1');
INSERT INTO "Question__c" VALUES(127,'true','','','','Started App;Submitted App','','','','false','','','','','49.0','false','true','Started App','false','','','','','','','false','You selected Other. Please provide more details:','','','','SourceOther(UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','1');
INSERT INTO "Question__c" VALUES(128,'true','','','','Started App;Submitted App','','','','false','','','','','43.0','false','true','Started App','false','','','','','','','false','How did you hear about us? Check all that apply and enter name (if applicable).','','','','Source(UGNDO)','Name','false','Community Based Organization/College Access Group
Friend/Relative
St. Thomas Alumnus/a
High School Counselor/Teacher
Independent College Counselor
Other','','0124P0000003S9JQAU','','','','','','','','','1');
INSERT INTO "Question__c" VALUES(129,'true','','','','Started App;Submitted App','','','','false','','','','','21.0','false','true','Started App','false','','','','','','','false','Specify other South Asian background','100.0','','','South Asia other (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(130,'true','','','Race_Other_Southeast_Asia__c','Started App;Submitted App','','','','false','','','','','22.0','false','true','Started App','false','','','','','','','false','Specify other Southeast Asian background','100.0','','','Southeast Asia other (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(131,'true','','','','Started App;Submitted App','','','','false','','','','','46.0','false','true','Started App','false','','','','','','','false','You selected St. Thomas Alumnus/a. Please provide more details:','','','','St. Thomas Alumnusa(UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','1');
INSERT INTO "Question__c" VALUES(132,'true','','','','Started App;Submitted App','','','','false','','','','','20.0','false','true','Started App','false','','','','','','Please type your name in the space above.','false','Student Signature','','','','Student Signature (UGNDO)','Name','false','','Full Name','0124P0000003S9RQAU','','Started App','','','','','','','10');
INSERT INTO "Question__c" VALUES(133,'true','','','','Started App;Submitted App','','','','false','','','','','4.0','false','true','Started App','false','','','','','','','false','Suffix','','','','Suffix(UGNDO)','Name','false','Jr.
Sr.
II
III
IV
V
VI','','0124P0000003S9NQAU','','','','','','','','','18');
INSERT INTO "Question__c" VALUES(134,'true','','','','Started App;Submitted App','','','','false','','','','','9.0','false','true','Started App','false','','','Apply Without Standardized Test','','','','false','','','','','Test Optional Consent Text (UGNDO)','Name','false','','','0124P0000003S9QQAU','','Started App','','','<p><br></p><p>I have chosen to apply as a test-optional applicant. By doing so, I understand that my standardized test scores (even if submitted) will not be considered as part of the admission or merit scholarship review process. I agree to the information the University of St. Thomas has shared about its test optional policy. I understand that if I change my mind and wish to have my test reviewed with my application, I should contact my admissions counselor to discuss my options. <span style="color: rgb(255, 0, 0);">*</span></p>','','','','10');
INSERT INTO "Question__c" VALUES(135,'true','','','','Started App;Submitted App','','','','false','','','','','10.0','true','true','Started App','false','','','Apply Without Standardized Test','','','','false','','','','','Test Optional Consent (UGNDO)','Name','false','I Agree','','0124P0000003S9NQAU','','Started App','','','','','','','10');
INSERT INTO "Question__c" VALUES(136,'true','','','','Started App;Submitted App','','International','','false','','','Show','AND','9.0','true','true','Started App','false','','','','','','WES - World Education Services

ECE - Educational Credential Evaluators','false','Where did you get your transcripts evaluated?','','','','Transcripts Evaluated By(UGNDO)','Name','false','WES
ECE','','0124P0000003S9NQAU','Transcript_Evaluator__c','','','','','','','','7');
INSERT INTO "Question__c" VALUES(137,'true','','','','Started App;Submitted App','','International','','false','','','','','8.0','false','true','Started App','false','','','','','','','false','Academic transcripts outside of the US must be evaluated by a transcript evaluation service in the National Association of Credential Evaluation Services (NACES). Two recommended services are WES and ECE. Are your transcripts already evaluated?','','','','Transcripts Evaluated (UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','Transcripts_Evaluated_Previously__c','','','','','','','','7');
INSERT INTO "Question__c" VALUES(138,'true','','','Tribe_Number__c','Started App;Submitted App','','','','false','','','','','18.0','false','true','Started App','false','','','','','','','false','Tribal enrollment number','50.0','','','Tribal enrollment number (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(139,'true','','','','Started App;Submitted App','','','','false','','','','','6.0','false','true','Started App','false','','','','','','','false','College Address Line 1','','','','Unknown College Address Line 1 (UGNDO)','Name','false','','','0124P0000003S9SQAU','Street__c','Started App','','','','','','','4');
INSERT INTO "Question__c" VALUES(140,'true','','','','Started App;Submitted App','','','','false','','','','','8.0','false','true','Started App','false','','','','','','','false','City','','','','Unknown College City (UGNDO)','Name','false','','','0124P0000003S9RQAU','City__c','Started App','','','','','','','4');
INSERT INTO "Question__c" VALUES(141,'true','','','','Started App;Submitted App','','','','false','','','','','7.0','false','true','Started App','false','','','','','','','false','Country','','','','Unknown College Country (UGNDO)','Name','false','','','0124P0000003S9RQAU','Country__c','Started App','','','','','','','4');
INSERT INTO "Question__c" VALUES(142,'true','','','','Started App;Submitted App','','','','false','','','Show','','5.0','false','true','Started App','false','','','','','','','false','Please provide your College/University name','255.0','','','Unknown College (UGNDO)','Name','false','','','0124P0000003S9RQAU','hed__Educational_Institution_Name__c','Started App','','','','','','','4');
INSERT INTO "Question__c" VALUES(143,'true','','','','Started App','','','','false','','','','','3.0','false','true','','false','','','','','','','false','High School Address Line 1','','','','Unknown High School Address Line 1 (UGNDO)','Name','false','','','0124P0000003S9SQAU','Street__c','Started App','','','','','','','7');
INSERT INTO "Question__c" VALUES(144,'true','','','','Started App','','','','false','','','','','4.0','false','true','','false','','','','','','','false','City','','','','Unknown High School City (UGNDO)','Name','false','','','0124P0000003S9RQAU','City__c','Started App','','','','','','','7');
INSERT INTO "Question__c" VALUES(145,'true','','','','Started App','','','','false','','','','','5.0','false','true','','false','','','','','','','false','Country','','','','Unknown High School Country (UGNDO)','Name','false','','','0124P0000003S9RQAU','Country__c','Started App','','','','','','','7');
INSERT INTO "Question__c" VALUES(146,'true','','','','Started App;Submitted App','','','','false','','','Show','','2.0','false','true','Started App','false','','','','','','','false','Please provide your high school/secondary school name','255.0','','','Unknown High School (UGNDO)','Name','false','','','0124P0000003S9RQAU','hed__Educational_Institution_Name__c','Started App','','','','','','','7');
INSERT INTO "Question__c" VALUES(147,'true','','','','Started App;Submitted App','','International','','false','','','','','13.0','false','true','Started App','false','','','','','','','false','Is your most recent college/university experience at a US Institution?','','','','US or International Instituition(UGNDO)','Name','false','Yes
No','','0124P0000003S9NQAU','Most_Recent_College_in_US__c','','','','','','','','4');
INSERT INTO "Question__c" VALUES(148,'true','','','Race_White_Background__c','Started App;Submitted App','','','','false','','','','','27.0','true','true','Started App','false','','','','','','','false','Which best describes your White background? (You may select one or more)','','','','White background (UGNDO)','Name','false','Europe
Middle East
Other','','0124P0000003S9JQAU','','','','','','','','','9');
INSERT INTO "Question__c" VALUES(149,'true','','','Race_White_Background__c','Started App;Submitted App','','','','false','','','','','28.0','false','true','Started App','false','','','','','','','false','Specify other White background','100.0','','','White other (UGNDO)','Name','false','','','0124P0000003S9RQAU','','','','','','','','','9');
CREATE TABLE "Question__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9CQAU','Address');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9DQAU','Checkbox');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9EQAU','Currency');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9FQAU','Date');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9GQAU','DateTime');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9HQAU','Email');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9KQAU','Number');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003SJ2QAM','Payment');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9LQAU','Percent');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9MQAU','Phone');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9NQAU','Picklist');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9JQAU','MultiPicklist');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9OQAU','Radio');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9PQAU','Reference');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9QQAU','Static');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9RQAU','Text');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9TQAU','TextEncrypted');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9SQAU','TextArea');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9IQAU','LongTextArea');
INSERT INTO "Question__c_rt_mapping" VALUES('0124P0000003S9UQAU','URL');
CREATE TABLE "Requirement_Item__c" (
	id INTEGER NOT NULL, 
	"Active__c" VARCHAR(255), 
	"Allow_Supporting_Documentation_Upload__c" VARCHAR(255), 
	"Allow_Text_Entry__c" VARCHAR(255), 
	"Applicant_Type__c" VARCHAR(255), 
	"Application_Status__c" VARCHAR(255), 
	"Citizenship__c" VARCHAR(255), 
	"Degree_Type__c" VARCHAR(255), 
	"Delivery_Type__c" VARCHAR(255), 
	"Display_Order__c" VARCHAR(255), 
	"Display_on_Admin_Review_Pages__c" VARCHAR(255), 
	"Display_on_Checklist__c" VARCHAR(255), 
	"Editable_Application_Status__c" VARCHAR(255), 
	"File_Name_Prefix__c" VARCHAR(255), 
	"File_Types__c" VARCHAR(255), 
	"Generic_Filter_1__c" VARCHAR(255), 
	"Generic_Filter_2__c" VARCHAR(255), 
	"Generic_Filter_3__c" VARCHAR(255), 
	"Generic_Filter_4__c" VARCHAR(255), 
	"Holding_Record_Id__c" VARCHAR(255), 
	"Instructions__c" VARCHAR(255), 
	"Internal_Only_Applicant_Instructions__c" VARCHAR(255), 
	"Internal_Only_Show_on_Checklist__c" VARCHAR(255), 
	"Internal_Only__c" VARCHAR(255), 
	"Label__c" VARCHAR(255), 
	"Maximum_Number_of_Children__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"RI_UID__c" VARCHAR(255), 
	"R_UID__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Related_List_Object_Master_Field__c" VARCHAR(255), 
	"Related_List_Object_Master__c" VARCHAR(255), 
	"Related_List_Object__c" VARCHAR(255), 
	"Related_List_Where_Clause__c" VARCHAR(255), 
	"Related_Object_Record_Type_ID__c" VARCHAR(255), 
	"Required_Number_of_Children__c" VARCHAR(255), 
	"Required_Supporting_Documentation__c" VARCHAR(255), 
	"Required__c" VARCHAR(255), 
	"Requirement_Item_Integration_Ext_Id__c" VARCHAR(255), 
	"Residency__c" VARCHAR(255), 
	"School_College__c" VARCHAR(255), 
	"Student_Type__c" VARCHAR(255), 
	"Viewing_Requirement__c" VARCHAR(255), 
	"Intended_Program__c" VARCHAR(255), 
	"Internal_Requirement_Item__c" VARCHAR(255), 
	"Requirement__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Requirement_Item__c" VALUES(1,'True','False','False','','Started App;Submitted App','','','','0.0','True','True','Started App','','','','','','','','','','False','False','Additional Information','','Additional Information (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','Requirement_Item__c2023-02-21 19:35:49Z00000','','','','True','','','1');
INSERT INTO "Requirement_Item__c" VALUES(2,'True','False','False','','Started App','','','','','True','True','Started App','','','','','','','','','','False','False','Additional Relationships','','Additional Relationships (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','Requirement_Item__c2022-05-19 01:11:07Z00000','','','','True','','','4');
INSERT INTO "Requirement_Item__c" VALUES(3,'True','False','False','','Started App;Submitted App','','','','2.0','True','True','Started App','','','','','','','','','','False','False','Mailing Address','','Address (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','RequirementItemAddres44676.6741123843','','','','True','','','6');
INSERT INTO "Requirement_Item__c" VALUES(4,'True','False','False','','Started App;Submitted App','','','','2.0','True','True','Started App','','','','','','','0014P000040pCXsQAM','Have you taken any college/university courses?  If yes, create a new record.','','False','False','Colleges & Universities','5.0','Colleges & Universities (UGNDO)','','','0124P0000003S9XQAU','hed__Contact__c','Contact','hed__Education_History__c','(RecordTypeId=''0124P0000003S9YQAU'')','0124P0000003S9YQAU','0.0','','','RequirementItemColleg44676.6741123843','','','','True','','','3');
INSERT INTO "Requirement_Item__c" VALUES(5,'True','False','False','','Started App','','','','6.0','True','True','Started App','','','','','','','','','','False','False','Community-Based Organizations','','Community-Based Organizations (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','Requirement_Item__c2022-04-25 20:54:39Z00000','','','','True','','','3');
INSERT INTO "Requirement_Item__c" VALUES(6,'True','False','False','','Started App','','','','3.0','True','True','Started App','','','','','','','','','','False','False','Contact Details','','Contact Details (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','Requirement_Item__c2022-04-25 20:54:36Z00000','','','','True','','','6');
INSERT INTO "Requirement_Item__c" VALUES(7,'True','False','False','','Started App;Submitted App','','','','1.0','True','True','Started App','','','','','','','0014P000040pCXrQAM','','','False','False','Current or Most Recent High School/Secondary School','1.0','Current or Most Recent School (UGNDO)','','','0124P0000003S9XQAU','hed__Contact__c','Contact','hed__Education_History__c','(RecordTypeId=''0124P0000003S9ZQAU'')','0124P0000003S9ZQAU','1.0','','Started App','RequirementItemCurren44676.6741123843','','','','True','','','3');
INSERT INTO "Requirement_Item__c" VALUES(8,'True','False','False','','Started App','','','','4.0','True','True','Started App','','','','','','','','','','False','False','List all courses you are taking this academic year.','','Curr or Most Recent Yr Courses (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','RequirementItemCurr o44676.6741123843','','','','True','','','3');
INSERT INTO "Requirement_Item__c" VALUES(9,'True','False','False','','Started App','','','','4.0','True','True','Started App','','','','','','','','','','False','False','Demographics','','Demographics (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','RequirementItemDemogr44676.6741123843','','','','True','','','6');
INSERT INTO "Requirement_Item__c" VALUES(10,'True','False','False','','','','','','0.0','True','True','','','','','','','','','','','False','False','Digital Consent and Submit','','Digital Consent and Submit (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','Requirement_Item__c2021-05-07 22:10:44Z00000','','','','True','','','2');
INSERT INTO "Requirement_Item__c" VALUES(11,'True','False','False','','Started App;Submitted App','International','','','7.0','True','True','Started App','','','','','','','','English Proficiency Certificate','','False','False','English Proficiency Certificate','','English Proficiency (UGNDO)','','','0124P0000003S9VQAU','','','','','','','','','Requirement_Item__c2023-02-02 20:30:46Z00000','','','','True','','','6');
INSERT INTO "Requirement_Item__c" VALUES(12,'True','False','False','','Started App','International','','','6.0','True','True','Started App','','','','','','','','','','False','False','Geography and Nationality','','Geography and Nationality (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','RequirementItemGeograx44676.6741123843','','','','True','','','6');
INSERT INTO "Requirement_Item__c" VALUES(13,'True','False','False','','Started App','','','','5.0','True','True','Started App','','','','','','','','','','False','False','Honors','','Honors (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','RequirementItemHonors44676.6741123843','','','','True','','','3');
INSERT INTO "Requirement_Item__c" VALUES(14,'True','False','False','','Started App','','','','1.0','True','True','Started App','','','','','','','','','','False','False','Household','','Household (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','RequirementItemHouseh44676.6741123843','','','','True','','','4');
INSERT INTO "Requirement_Item__c" VALUES(15,'True','False','False','','Started App;Submitted App','','','','5.0','True','True','Started App','','','','','','','a0H4P00000tMnXxUAK','Click "New Record" to add a language proficiency other than English. Click "Save and Continue" if no additional language(s) need to be added.','','False','False','Language','','Language (UGNDO)','','','0124P0000003S9XQAU','hed__Contact__c','Contact','hed__Contact_Language__c','','','','','','RequirementItemLangua44676.6741123843','','','','True','','','6');
INSERT INTO "Requirement_Item__c" VALUES(16,'True','False','False','','Started App','','','','2.0','True','True','Started App','','','','','','','0014P000040pCXvQAM','If parent information is not available, please enter "N/A" in the required fields.','','False','False','Parent/Legal Guardian','','Parent Legal Guardian (UGNDO)','','','0124P0000003S9XQAU','Contact__c','Contact','Family_Member__c','(RecordTypeID=''0124P0000003S8wQAE'')','0124P0000003S8wQAE','','','','RequirementItemParent44676.6741123843','','','','True','','','4');
INSERT INTO "Requirement_Item__c" VALUES(17,'True','False','False','','Started App;Submitted App','International','','','8.0','True','True','Started App','','','','','','','','Upload a copy of your passport','','False','False','Upload a copy of your passport','','Passport(UGNDO)','','','0124P0000003S9VQAU','','','','','','','','','Requirement_Item__c2020-1-2108:25:335czC','','','','True','','','6');
INSERT INTO "Requirement_Item__c" VALUES(18,'True','False','False','','Started App','','','','1.0','True','True','Started App','','','','','','','','','','False','False','Personal Information','','Personal Information (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','RequirementItemPerson44676.6741123843','','','','True','','','6');
INSERT INTO "Requirement_Item__c" VALUES(19,'True','False','False','','','','','','0.0','True','True','','','','','','','','','','','False','False','','','PreApp Questions (UGNDO)','','','0124P0000003S9WQAU','','','','','','','','','Requirement_Item__c2023-02-17 17:48:37Z00000','','','','True','','','5');
INSERT INTO "Requirement_Item__c" VALUES(20,'True','False','False','','Started App','','','','4.0','True','True','Started App','','','','','','','0014P000040pCXuQAM','','','False','False','Sibling','','Sibling (UGNDO)','','','0124P0000003S9XQAU','Contact__c','Contact','Family_Member__c','(RecordTypeID=''0124P0000003S8xQAE'')','0124P0000003S8xQAE','','','','Requirement_Item__c2022-04-25 20:54:40Z00000','','','','True','','','4');
CREATE TABLE "Requirement_Item__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Requirement_Item__c_rt_mapping" VALUES('0124P0000003S9VQAU','Document_Upload');
INSERT INTO "Requirement_Item__c_rt_mapping" VALUES('0124P0000003S9WQAU','Question_Group');
INSERT INTO "Requirement_Item__c_rt_mapping" VALUES('0124P0000003S9XQAU','Related_Object');
CREATE TABLE "Requirement__c" (
	id INTEGER NOT NULL, 
	"Active__c" VARCHAR(255), 
	"Applicant_Type__c" VARCHAR(255), 
	"Application_Creation_Display_Order__c" VARCHAR(255), 
	"Application_Status__c" VARCHAR(255), 
	"Citizenship__c" VARCHAR(255), 
	"Degree_Type__c" VARCHAR(255), 
	"Delivery_Type__c" VARCHAR(255), 
	"Display_Order__c" VARCHAR(255), 
	"Display_on_Admin_Review_Pages__c" VARCHAR(255), 
	"Display_on_Checklist__c" VARCHAR(255), 
	"Generic_Filter_1__c" VARCHAR(255), 
	"Generic_Filter_2__c" VARCHAR(255), 
	"Generic_Filter_3__c" VARCHAR(255), 
	"Generic_Filter_4__c" VARCHAR(255), 
	"Internal_Only_Show_on_Checklist__c" VARCHAR(255), 
	"Internal_Only__c" VARCHAR(255), 
	"Label__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Residency__c" VARCHAR(255), 
	"School_College__c" VARCHAR(255), 
	"Show_on_Application_Creation__c" VARCHAR(255), 
	"Student_Type__c" VARCHAR(255), 
	"Viewing_Requirement__c" VARCHAR(255), 
	"Application_Control__c" VARCHAR(255), 
	"Intended_Program__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Requirement__c" VALUES(1,'True','','','Started App','','','','4.0','True','True','','','','','False','False','Additional Information','Additional Information (UGNDO)','','','False','','True','1','');
INSERT INTO "Requirement__c" VALUES(2,'True','','','Started App','','','','5.0','True','True','','','','','False','False','Digital Consent & Submit','Digital Consent & Submit (UGNDO)','','','False','','True','1','');
INSERT INTO "Requirement__c" VALUES(3,'True','','','Started App','','','','3.0','True','True','','','','','False','False','Education','Education (UGNDO)','','','False','','True','1','');
INSERT INTO "Requirement__c" VALUES(4,'True','','','Started App','','','','2.0','True','True','','','','','False','False','Family','Family (UGNDO)','','','False','','True','1','');
INSERT INTO "Requirement__c" VALUES(5,'True','','Before Term/Program Questions','','','','','0.0','True','True','AS_UN_NDO|NDND','','','','False','False','About you','PreApp Requirements (UGNDO)','','','True','','True','1','');
INSERT INTO "Requirement__c" VALUES(6,'True','','','Started App','','','','1.0','True','True','','','','','False','False','Profile','Profile (UGNDO)','','','False','','True','1','');
COMMIT;
