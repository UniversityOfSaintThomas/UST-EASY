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
INSERT INTO "Application_Control__c" VALUES(1,'','True','Started App','Started App','Started App;Submitted App','Started App','000000','ffffff','000000','Withdrawn','False','','False','000000','000000','','Logo','Non-Credit University of St. Thomas','','Submitted App','stthomas2021','000000','NCUST','Withdrawn');
INSERT INTO "Application_Control__c" VALUES(2,'','True','Started App','Started App','Started App;Submitted App','Started App','000000','ffffff','000000','Withdrawn','False','','False','000000','000000','','Logo','Non-Credit College of Arts and Sciences','','Submitted App','stthomas2021','000000','NCCAS','Withdrawn');
INSERT INTO "Application_Control__c" VALUES(3,'','False','Started App','Started App','Started App;Submitted App','Started App','000000','ffffff','000000','Withdrawn','False','','False','000000','000000','','Logo','Non-Credit Courses','','Submitted App','stthomas2021','000000','USTNCC','Withdrawn');
INSERT INTO "Application_Control__c" VALUES(4,'','True','Started App','Started App','Started App;Submitted App','Started App','000000','ffffff','000000','Withdrawn','False','','False','000000','000000','','Logo','Non-Credit Opus College of Business','','Submitted App','stthomas2021','000000','NCOCB','Withdrawn');
INSERT INTO "Application_Control__c" VALUES(5,'','True','Started App','Started App','Started App;Submitted App','Started App','000000','ffffff','000000','Withdrawn','False','','False','000000','000000','','Logo','Non-Credit Dougherty Family College','','Submitted App','stthomas2021','000000','NCDFC','Withdrawn');
INSERT INTO "Application_Control__c" VALUES(6,'','True','Started App','Started App','Started App;Submitted App','Started App','000000','ffffff','000000','Withdrawn','False','','False','000000','000000','','Logo','Non-Credit Selim Center for Lifelong Learning','','Submitted App','stthomas2021','000000','NCSCFLLL','Withdrawn');
INSERT INTO "Application_Control__c" VALUES(7,'','True','Started App','Started App','Started App;Submitted App','Started App','000000','ffffff','000000','Withdrawn','False','','False','000000','000000','','Logo','Non-Credit Executive Education','','Submitted App','stthomas2021','000000','NCEXECED','Withdrawn');
INSERT INTO "Application_Control__c" VALUES(8,'','True','Started App','Started App','Started App;Submitted App','Started App','000000','ffffff','000000','Withdrawn','False','','False','000000','000000','','Logo','Non-Credit Morrison Family College of Health','','Submitted App','stthomas2021','000000','NCMFCOH','Withdrawn');
INSERT INTO "Application_Control__c" VALUES(9,'','True','Started App','Started App','Started App;Submitted App','Started App','000000','ffffff','000000','Withdrawn','False','','False','000000','000000','','Logo','Non-Credit School of Education','','Submitted App','stthomas2021','000000','NCGSOED','Withdrawn');
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
INSERT INTO "EASY_Widget__c" VALUES(1,'Active','','<p><strong>Account</strong></p>

<p style="text-align: center;"> </p>','','ApplicationCreate;ApplicationPortal;ApplicationRegistration;ApplicationRequirement','','','','','','','','','','User Info Logout (NCUST)','<style>

.horizontal_line {

            background-color: #5f19a0;

            width: 100%;

            height: 1px;

            border-top: 5px dotted black;

            line-height: 100%;

        }

  

        .line {

            border-bottom: 5px solid #5f19a0;

            margin-top: 5px;

            margin-bottom: 4px;

            width: 100%;

        }



</style>

<div class="line"></div>','0.0','','','Left','Central Daylight Time (America/Chicago)','User Info Login/Logout','1');
INSERT INTO "EASY_Widget__c" VALUES(2,'Active','','<p><strong>Need Assistance? </strong></p>

<p>Tommie Tech Services</p>

<p>Phone: (651) 962-6230</p>

<p>techdesk@stthomas.edu<br><br>We provide technical assistance through our <strong>Tech Desk St. Paul </strong>(O&#39;Shaughnessy-Frey Library: First Floor Reference Desk) and <strong>Tech Desk Minneapolis</strong> (Terrance Murphy Hall 203B) walk-up counters located on both of our campuses.  </p>','','ApplicationCreate;ApplicationPortal;ApplicationRegistration;ApplicationRequirement','Started App;Submitted App;Complete App;Denied;Admit;Confirmed;File Hold','','','','','','','','','Contact Info (NCUST)','','5.0','','','Left','Central Daylight Time (America/Chicago)','Custom','1');
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
	"Program_CEU_Amount__c" VARCHAR(255), 
	"Program_Code__c" VARCHAR(255), 
	"Program_College_of_Interest__c" VARCHAR(255), 
	"Program_Degree_Code__c" VARCHAR(255), 
	"Program_Description__c" VARCHAR(255), 
	"Program_Display__c" VARCHAR(255), 
	"Program_Index_Code__c" VARCHAR(255), 
	"Program_Image_URL__c" VARCHAR(255), 
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
INSERT INTO "Program__c" VALUES(1,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Certified Professional Project Manager (CPPM)','','False','','Project Management','','3.5','','','','Build your leadership and decision-making skills while exploring best practices and tools for effective project management. Gain new information and the CPPM certification.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij68&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wOO"></img>','','In person','Certified Professional Project Manager (CPPM)','','','','','0124P0000003S97QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(2,'','True','','160.0','School of Education','','','','','Non-Credit','','','','2021-CulComp-Self','','','','','','','','','','','','','','False','','','','Cultural Competency for Educators','','False','','Education','','16.0','','','','<p>Cultural Competency for Educators is a PELSB-approved course that meets licensure renewal requirements for K-12 educators in Minnesota who need to complete cultural competency training. The program is 100% online, self-guided, which means you work through the program on your own schedule.</p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b0000052iTd&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000000Aqo1" style="height: 314px; width: 500px;"></img>','','Online self-guided','Cultural Competency for Educators','','','','','0124P0000003S97QAE','','False','','','','','','','9','');
INSERT INTO "Program__c" VALUES(3,'','True','','395.0','University of St. Thomas','','','','','Non-Credit','','','','202007-DAUR','','','','','','','','','','','','','','False','','','','Data Analytics with R','','False','','Workplace Skills','','','','','','<p>Do you work with data on a daily basis? Are you finding that tools like Excel are holding you back in both your analysis and productivity? Are you spending hours copying and pasting into a presentation or report, only to do it all over again because a requirement changes or the data needs to be refreshed?  </p>

<p>This course introduces business professionals to the power of the R programming language for data analysis, visualization, and reporting. Through real-world scenarios and datasets in a project-based format, participants will learn how to leverage R in their day-to-day work to produce professional visualizations and summaries of their data, revealing insights that drive decision-making for their organization</p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SFBY&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002hpE" style="height: 373px; width: 500px;"></img>','','Online self-guided','Data Analytics with R','','','','','0124P0000003S97QAE','','False','','','','','','','1','');
INSERT INTO "Program__c" VALUES(4,'','True','','99.0','School of Education','','','','','Non-Credit','','','','202010-ExplicitReading','','','','','','','','','','','','','','False','','','','Essential Literacy Instruction','','False','','Education','','4.0','','','','Scientifically based reading instruction is key to solving the national reading problem. In this course we will teach the five components of reading instruction, underscore the importance of early identification of children with reading difficulties and highlight effective remediation strategies.  ','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b0000052iTi&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000000AqoL" style="height: 375px; width: 500px;"></img>','','Online self-guided','Essential Literacy Instruction','','','','','0124P0000003S97QAE','','False','','','','','','','9','');
INSERT INTO "Program__c" VALUES(5,'','True','','30.0','Morrison Family College of Health','','','','','Non-Credit','','','','2021-Telehealth','','','','','','','','','','','','','','False','','','','Ethics and Telemental Health','','False','','Healthcare','','2.0','','','','Explore the ethical?concerns and challenges related to telehealth and learn best practices you can apply now and in the future. Ethics CEs approved by MN BOSW.','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006UdaR&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000006WgoI" style="height: 281px; width: 500px;"></img>','','Online self-guided','Ethics and Telemental Health','','','','','0124P0000003S97QAE','','False','','','','','','','8','');
INSERT INTO "Program__c" VALUES(6,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Agile Project Management','','False','','Project Management','','2.1','','','','Dive into the agile methodology in this three-day program. Learn to complete projects more efficiently and earn a St. Thomas Certified Agile Practitioner certification (UST-CAP).','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij63&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wOY"></img>','','In person','Agile Project Management','','','','','0124P0000003S97QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(7,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','The Supreme Court''s Monumental Term, & What Might Come Next','','False','','Personal Growth','','','','','','<span style="font-size: 11.0pt;"><span style="">In its 2021-2022 term, the U.S. Supreme Court issued rulings ranging from important to monumental. We’ll review several major decisions &amp; their implications, ongoing debates &amp; political pushback.</span></span>','Course Catalog','20252','<img alt="Supreme Court building" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kECA&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXQs"></img>','','Hybrid (in person and online)','The Supreme Court''s Monumental Term, & What Might Come Next','','','','','0124P0000003S97QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(8,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Certified Professional Project Manager (CPPM)','','False','','Project Management','','3.5','','','','Build your leadership and decision-making skills while exploring best practices and tools for effective project management. Gain new information and the CPPM certification.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij50&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wOO"></img>','','In person','Certified Professional Project Manager (CPPM)','','','','','0124P0000003S96QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(9,'','True','','160.0','School of Education','','','','','Non-Credit','','','','2021-CulComp-Self','','','','','','','','','','','','','','False','','','','Cultural Competency for Educators','','False','','Education','','16.0','','','','<p>Cultural Competency for Educators is a PELSB-approved course that meets licensure renewal requirements for K-12 educators in Minnesota who need to complete cultural competency training. The program is 100% online, self-guided, which means you work through the program on your own schedule.</p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b0000052iTd&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000000Aqo1" style="height: 314px; width: 500px;"></img>','','Online self-guided','Cultural Competency for Educators','','','','','0124P0000003S96QAE','','False','','','','','','','9','');
INSERT INTO "Program__c" VALUES(10,'','True','','395.0','University of St. Thomas','','NCUST_DAR','','','Non-Credit','','','','202007-DAUR','','','','','','','','','','','','','','False','','','','Data Analytics with R','','False','','Workplace Skills','','','','','','<p>Do you work with data on a daily basis? Are you finding that tools like Excel are holding you back in both your analysis and productivity? Are you spending hours copying and pasting into a presentation or report, only to do it all over again because a requirement changes or the data needs to be refreshed?  </p>

<p>This course introduces business professionals to the power of the R programming language for data analysis, visualization, and reporting. Through real-world scenarios and datasets in a project-based format, participants will learn how to leverage R in their day-to-day work to produce professional visualizations and summaries of their data, revealing insights that drive decision-making for their organization</p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SFBY&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002hpE" style="height: 373px; width: 500px;"></img>','','Online self-guided','Data Analytics with R','','','','','0124P0000003S96QAE','','False','','','','','','','1','');
INSERT INTO "Program__c" VALUES(11,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','The Prophets','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">This program offers an introduction &amp; overview of prophets &amp; prophecy in ancient Israel &amp; will provide an in-depth look at selected texts with emphasis on interpretation &amp; relevance for our world today.</span></span></span><br> ','Course Catalog','20252','<img alt="Man writing at a desk" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEBg&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXOX"></img>','','Hybrid (in person and online)','The Prophets','','','','','0124P0000003S96QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(12,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','The Singularity is Already Here, Not with a Bang but with a Whimper','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">Thieme predicted the impacts of the computer revolution on society at all levels 25 years ago. Now he looks at the inevitable consequences of what we’re doing now &amp; its implications for democracy.</span></span></span><br><br> ','Course Catalog','20252','<img alt="AI figure with computer symbols" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kECF&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXRW"></img>','','Hybrid (in person and online)','The Singularity is Already Here, Not with a Bang but with a Whimper','','','','','0124P0000003S96QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(13,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','The Supreme Court''s Monumental Term, & What Might Come Next','','False','','Personal Growth','','','','','','<span style="font-size: 11.0pt;"><span style="">In its 2021-2022 term, the U.S. Supreme Court issued rulings ranging from important to monumental. We’ll review several major decisions &amp; their implications, ongoing debates &amp; political pushback.</span></span>','Course Catalog','20252','<img alt="Supreme Court building" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kECA&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXQs"></img>','','Hybrid (in person and online)','The Supreme Court''s Monumental Term, & What Might Come Next','','','','','0124P0000003S96QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(14,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','20th Century US History','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span>This three-week course will provide an overview of US history from the end of the nineteenth century to the start of the twenty-first century.</span></span></span><br> ','Course Catalog','20252','<img alt="US History image cloud" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEBG&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXNe"></img>','','Hybrid (in person and online)','20th Century US History','','','','','0124P0000003S97QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(15,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Minnesota Architecture Lost & Found','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">This course offers 2 distinct looks at architecture in the Twin Cities &amp; Minnesota, including a visual tour of “Lost Twin Cities”, Minnesota’s finest homes &amp; a review of Midcentury Modernism &amp; its legacy.</span></span></span><br> ','Course Catalog','20252','<img alt="Building architecture" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEBl&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXOr"></img>','','Hybrid (in person and online)','Minnesota Architecture Lost & Found','','','','','0124P0000003S96QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(16,'','True','','','College of Arts and Sciences','','','','','Non-Credit','','','','202109-MissionAndCulture','','','','','','','','','','','','','','False','','','','Mission, Culture, and Emerging Questions in Catholic Education','','False','','','','','','','','Grounded in the Church’s educational tradition over two millennia, this course engages participants in the profound questions of every Catholic school educator.','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006BJ6b&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000002pakS" style="height: 331px; width: 500px;"></img>','','Online self-guided','Mission, Culture, and Emerging Questions in Catholic Education','','','','','0124P0000003S96QAE','','False','','','','','','','2','');
INSERT INTO "Program__c" VALUES(17,'','True','','','College of Arts and Sciences','','','','','Non-Credit','','','','202206-MCEQ-CR01','','','','','','','','','','','','','','False','','','','Mission, Culture, and Emerging Questions in Catholic Education for Crookston Sch','','False','','','','','','','','<p>Grounded in the Church’s educational tradition over two millennia, this course engages participants in the profound questions of every Catholic school educator.</p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006j4EK&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007vbAi" style="height: 331px; width: 500px;"></img>','','Online self-guided','Mission, Culture, and Emerging Questions in Catholic Education for Crookston Schools','','','','','0124P0000003S96QAE','','False','','','','','','','2','');
INSERT INTO "Program__c" VALUES(18,'','True','','','College of Arts and Sciences','','','','','Non-Credit','','','','202206-MCEQ-OG01','','','','','','','','','','','','','','False','','','','Mission, Culture, and Emerging Questions in Catholic Education for O''Gorman Scho','','False','','','','','','','','<p>Grounded in the Church’s educational tradition over two millennia, this course engages participants in the profound questions of every Catholic school educator.</p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006iuzE&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007vbAi" style="height: 331px; width: 500px;"></img>','','Online self-guided','Mission, Culture, and Emerging Questions in Catholic Education for O''Gorman Schools','','','','','0124P0000003S96QAE','','False','','','','','','','2','');
INSERT INTO "Program__c" VALUES(19,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Online Certified Professional Project Manager (CPPM)','','False','','Project Management','','3.5','','','','Learn effective project management skills and principles through this online offering of the CPPM certification program. Gain skills that can be applied right away.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij5t&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wNk"></img>','','Online instructor guided','Online Certified Professional Project Manager (CPPM)','','','','','0124P0000003S96QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(20,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Project Management for the Accidental Project Manager','','False','','Project Management','','0.8','','','','Learn the language and approaches to project management to be better equipped when participating in projects. Use real-world examples from your own experience.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij4l&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wNp" style="height: 375px; width: 500px;"></img>','','In person','Project Management for the Accidental Project Manager','','','','','0124P0000003S96QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(21,'','True','','99.0','University of St. Thomas','','NCUST_SSDV','','','Non-Credit','','','','202006-DIYV','','','','','','','','','','','','','','False','','','','Simpler (and Smarter) DIY Videos','','False','','Personal Growth','','','','','','<p>Creating professional-looking videos can seem daunting, but it doesn’t need to be! You can produce high-quality videos with little more than your smartphone and some imagination, and this course will teach you how to do it. We’ll explain common types of video projects and help you decide which type suits your needs. Then, you’ll learn best practices for planning, shooting, editing and distributing your project. At the end, you’ll submit a short video and get feedback from our experts. Join us and learn to create simpler (and smarter) DIY videos!</p>','Course Catalog','40493','<img alt="Charming young African man in shirt showing digital camera and telling something while making social media video" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SDMY&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002Yae" styl','','Online self-guided','Simpler (and Smarter) DIY Videos','','','','','0124P0000003S96QAE','','False','','','','','','','1','');
INSERT INTO "Program__c" VALUES(22,'','True','','99.0','Opus College of Business','','','','','Non-Credit','','','','202009-SmallBusSmart','','','','','','','','','','','','','','False','','','','Smart Start for Business','','False','','General Business','','','','','','<p>Twenty percent of new businesses fail in the first two years. Why? Lack of knowledge, resources, and planning. Taking the time to learn and plan is the best first investment a business owner can make. Smart Start for Business will provide you with all the information prospective (and new) business owners need to be successful. You’ll also have the chance to share with other entrepreneurs and get your questions answered from seasoned business owners. We’re here to help you stay out of the twenty percent. </p>','Course Catalog','40493','<img alt="Person holding an iPad that reads &quot;Small Business.&quot;" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SVU2&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002x9A" style="height: 375px; width: 500px;"></img>','','Online self-guided','Smart Start for Business','','','','','0124P0000003S96QAE','','False','','','','','','','4','');
INSERT INTO "Program__c" VALUES(23,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Finance for Non-Financial Managers','','False','','General Business','','1.8','','','','Gain the foundation and tools you need to make better financial decisions at work. Practice in class to become a confident contributor upon returning to the office.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij5j&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000006WsFP" style="height: 500px; width: 500px;"></img>','','In person','Finance for Non-Financial Managers','','','','','0124P0000003S96QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(24,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Freedom''s Ring: Slavery, Emancipation & the Making of America','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">This series considers the rise &amp; fall of American slavery from its 15<sup>th</sup> century origins through its long legacies, centering on the experience of people living in what would become the United States.</span></span></span><br> ','Course Catalog','20252','<img alt="Soldier with American flag, school" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEB6&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXMb"></img>','','Hybrid (in person and online)','Freedom''s Ring: Slavery, Emancipation & the Making of America','','','','','0124P0000003S96QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(25,'','True','','30.0','Dougherty Family College','','','','','Non-Credit','','','','2021-UnconBiasManagers','','','','','','','','','','','','','','False','','','','Interrupting Unconscious Bias at Work','','False','','Personal Growth;Workplace Skills','','0.2','','','','Learn how and why our brains process and categorize information to promote bias and use this information to identify your own biased tendencies within workplace environments. You will explore the impact of these biases on individuals and teams and apply strategies to interrupt these tendencies, so that you may work toward building an inclusive workplace culture.','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006UkNr&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000006XwSV" style="height: 281px; width: 500px;"></img>','','Online self-guided','Interrupting Unconscious Bias at Work','','','','','0124P0000003S96QAE','','False','','','','','','','5','');
INSERT INTO "Program__c" VALUES(26,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Making Sense of the 2022 Elections & Why They Matter for 2024 & Beyond','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">The 2022 midterm elections could be make-or-break for Pres. Biden, Congress, the Democratic &amp; Republican parties &amp; the United States. We’ll examine factors that impacted the elections &amp; what they mean.</span>   </span></span><br> ','Course Catalog','20252','<img alt="2022 elections billboard" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kECK&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXRv"></img>','','Hybrid (in person and online)','Making Sense of the 2022 Elections & Why They Matter for 2024 & Beyond','','','','','0124P0000003S96QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(27,'','True','','','College of Arts and Sciences','','','','','Non-Credit','','','','202206-MCEQ-CR01','','','','','','','','','','','','','','False','','','','Mission, Culture, and Emerging Questions in Catholic Education for Crookston Sch','','False','','','','','','','','<p>Grounded in the Church’s educational tradition over two millennia, this course engages participants in the profound questions of every Catholic school educator.</p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006j4EK&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007vbAi" style="height: 331px; width: 500px;"></img>','','Online self-guided','Mission, Culture, and Emerging Questions in Catholic Education for Crookston Schools','','','','','0124P0000003S97QAE','','False','','','','','','','2','');
INSERT INTO "Program__c" VALUES(28,'','True','','','College of Arts and Sciences','','','','','Non-Credit','','','','202206-MCEQ-OG01','','','','','','','','','','','','','','False','','','','Mission, Culture, and Emerging Questions in Catholic Education for O''Gorman Scho','','False','','','','','','','','<p>Grounded in the Church’s educational tradition over two millennia, this course engages participants in the profound questions of every Catholic school educator.</p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006iuzE&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007vbAi" style="height: 331px; width: 500px;"></img>','','Online self-guided','Mission, Culture, and Emerging Questions in Catholic Education for O''Gorman Schools','','','','','0124P0000003S97QAE','','False','','','','','','','2','');
INSERT INTO "Program__c" VALUES(29,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Online Certified Professional Project Manager (CPPM)','','False','','Project Management','','3.5','','','','Learn effective project management skills and principles through this online offering of the CPPM certification program. Gain skills that can be applied right away.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij5e&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wNk"></img>','','Online instructor guided','Online Certified Professional Project Manager (CPPM)','','','','','0124P0000003S97QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(30,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Project Management for the Accidental Project Manager','','False','','Project Management','','0.8','','','','Learn the language and approaches to project management to be better equipped when participating in projects. Use real-world examples from your own experience.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij4l&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wNp" style="height: 375px; width: 500px;"></img>','','In person','Project Management for the Accidental Project Manager','','','','','0124P0000003S97QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(31,'','True','','','University of St. Thomas','','','','','Non-Credit','','','','202204-DEIViewfinder','','','','','','','','','','','','','','False','','','','Inclusive Marketing & Communications: A Practical Approach','','False','','Education;Healthcare;Leadership;General Business;Nonprofit;Personal Growth;Project Management;Sales & Marketing;Workplace Skills','','0.2','','','','<p>From images and presentations to emails, this course will help you examine content through a DEI lens, identifying common pitfalls that can send unintended messages and undermine inclusivity.</p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006V9bH&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007uycF" style="height: 281px; width: 500px;"></img>','','Online self-guided','Inclusive Marketing & Communications: A Practical Approach','','','','','0124P0000003S97QAE','','False','','','','','','','1','');
INSERT INTO "Program__c" VALUES(32,'','True','','30.0','Dougherty Family College','','','','','Non-Credit','','','','2021-UnconBiasManagers','','','','','','','','','','','','','','False','','','','Interrupting Unconscious Bias at Work','','False','','Personal Growth;Workplace Skills','','0.2','','','','Learn how and why our brains process and categorize information to promote bias and use this information to identify your own biased tendencies within workplace environments. You will explore the impact of these biases on individuals and teams and apply strategies to interrupt these tendencies, so that you may work toward building an inclusive workplace culture.','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006UkNr&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000006XwSV" style="height: 281px; width: 500px;"></img>','','Online self-guided','Interrupting Unconscious Bias at Work','','','','','0124P0000003S97QAE','','False','','','','','','','5','');
INSERT INTO "Program__c" VALUES(33,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Making Sense of the 2022 Elections & Why They Matter for 2024 & Beyond','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">The 2022 midterm elections could be make-or-break for Pres. Biden, Congress, the Democratic &amp; Republican parties &amp; the United States. We’ll examine factors that impacted the elections &amp; what they mean.</span>   </span></span><br> ','Course Catalog','20252','<img alt="2022 elections billboard" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kECK&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXRv"></img>','','Hybrid (in person and online)','Making Sense of the 2022 Elections & Why They Matter for 2024 & Beyond','','','','','0124P0000003S97QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(34,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Mini MBA','','False','','General Business','','3.8','','','','Gain a solid foundation in business and leadership strategy while learning skills you can put to work right away. Practice these skills with a business simulation.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij4v&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wNz"></img>','','In person','Mini MBA','','','','','0124P0000003S97QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(35,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Mini MBA - Virtual','','False','','General Business','','3.8','','','','Gain a solid foundation in business and leadership strategy while learning skills you can put to work right away. Practice these skills with a business simulation.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kL8j&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wNz"></img>','','Online instructor guided','Mini MBA - Virtual','','','','','0124P0000003S97QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(36,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Mini MBA for Nonprofit Organizations','','False','','Nonprofit','','4.2','','','','Learn how to have a more effective impact in your nonprofit organization. Gain a solid foundation of skills, tools and knowledge needed to be successful in the nonprofit sector.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij5P&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wOn"></img>','','In person','Mini MBA for Nonprofit Organizations','','','','','0124P0000003S97QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(37,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Mini MBA for Nonprofit Organizations - Virtual','','False','','Nonprofit','','4.2','','','','Learn how to have a more effective impact in your nonprofit organization. Gain a solid foundation of skills, tools and knowledge needed to be successful in the nonprofit sector.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kL8o&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wOn"></img>','','Online instructor guided','Mini MBA for Nonprofit Organizations - Virtual','','','','','0124P0000003S97QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(38,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Minnesota Architecture Lost & Found','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">This course offers 2 distinct looks at architecture in the Twin Cities &amp; Minnesota, including a visual tour of “Lost Twin Cities”, Minnesota’s finest homes &amp; a review of Midcentury Modernism &amp; its legacy.</span></span></span><br> ','Course Catalog','20252','<img alt="Building architecture" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEBl&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXOr"></img>','','Hybrid (in person and online)','Minnesota Architecture Lost & Found','','','','','0124P0000003S97QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(39,'','True','','','College of Arts and Sciences','','','','','Non-Credit','','','','202109-MissionAndCulture','','','','','','','','','','','','','','False','','','','Mission, Culture, and Emerging Questions in Catholic Education','','False','','','','','','','','Grounded in the Church’s educational tradition over two millennia, this course engages participants in the profound questions of every Catholic school educator.','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006BJ6b&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000002pakS" style="height: 331px; width: 500px;"></img>','','Online self-guided','Mission, Culture, and Emerging Questions in Catholic Education','','','','','0124P0000003S97QAE','','False','','','','','','','2','');
INSERT INTO "Program__c" VALUES(40,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Everyday Economics','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Arial,sans-serif;"><span style=""><span style="color: black;">Our lives are affected by economic decision making daily, yet economics seems so complicated. Described as the “science of common sense”, the instructors will bring common sense to a variety of topics.</span></span></span></span><br> ','Course Catalog','20252','<img alt="Economics word cloud" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEBv&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXQ9"></img>','','Hybrid (in person and online)','Everyday Economics','','','','','0124P0000003S97QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(41,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Examinations in Minnesota Race Relations in 3 Case Studies','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span>The pre-eminent historian of African-Americans in Minnesota will look at the development of race relations in Minnesota through the lens of 3 case studies &amp; the stories that surround them.</span></span></span><br> ','Course Catalog','20252','<img alt="State of Minnesota word cloud" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEBB&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXNA"></img>','','Hybrid (in person and online)','Examinations in Minnesota Race Relations in 3 Case Studies','','','','','0124P0000003S97QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(42,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Exploring the Psychology of Personality','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">This course will review the Big 5 trait model &amp; contrast it with the Myers-Brigg Type Indicator &amp; will discuss a range of explanations for what makes individuals different and what we have in common.</span></span></span><br> ','Course Catalog','20252','<img alt="People with puzzle of brain" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEC5&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXQY"></img>','','Hybrid (in person and online)','Exploring the Psychology of Personality','','','','','0124P0000003S97QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(43,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Finance for Non-Financial Managers','','False','','General Business','','1.8','','','','Gain the foundation and tools you need to make better financial decisions at work. Practice in class to become a confident contributor upon returning to the office.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij5j&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000006WsFP" style="height: 500px; width: 500px;"></img>','','In person','Finance for Non-Financial Managers','','','','','0124P0000003S97QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(44,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Freedom''s Ring: Slavery, Emancipation & the Making of America','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">This series considers the rise &amp; fall of American slavery from its 15<sup>th</sup> century origins through its long legacies, centering on the experience of people living in what would become the United States.</span></span></span><br> ','Course Catalog','20252','<img alt="Soldier with American flag, school" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEB6&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXMb"></img>','','Hybrid (in person and online)','Freedom''s Ring: Slavery, Emancipation & the Making of America','','','','','0124P0000003S97QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(45,'','True','','','University of St. Thomas','','NCUST_SCM','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Supply Chain Management','','False','','General Business','','1.4','','','','This 2-day Supply Chain Management course provides an introduction to navigating the supply chain and creating efficiencies that help your organization run smoothly, across departments.','Course Catalog','28491','<img alt="Logistics workers reviewing data" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij5A&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007uxYh" style="height: 281px; width: 500px;"></img>','','In person','Supply Chain Management','','','','','0124P0000003S96QAE','','False','','','','','','','1','');
INSERT INTO "Program__c" VALUES(46,'','True','','25.0','School of Education','','','','','Non-Credit','','','','202004-TLO','','','','','','','','','','','','','','False','','','','Teaching Live, Online!','','False','','Education','','','','','','Teaching live, online can seem scary, but it doesn’t need to be. This course will teach you the tips, tricks, and tools you need to have a successful virtual class meeting.  We’ll go over how to choose the right platform and equipment for your needs, set up your streaming environment, and plan a class that holds students’ attention and encourages participation. You and your students will come to love the flexibility and versatility of teaching live, online!','Course Catalog','40493','<img alt="computer-screen-instructor-whiteboard" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a0000052cRg&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a000000ASGp" style="height: 375px; width: 500px;"></img>','','Online self-guided','Teaching Live, Online!','','','','','0124P0000003S96QAE','','False','','','','','','','9','');
INSERT INTO "Program__c" VALUES(47,'','True','','325.0','University of St. Thomas','','NCUST_ASP','','','Non-Credit','','','','202006-ASP','','','','','','','','','','','','','','False','','','','The Art of Sales Persuasion','','False','','Sales & Marketing','','','','','','You thought they were going to close this quarter. You did the pitch, the meeting went great, so what went wrong? The Art of Sales Persuasion will equip you with the tools to prevent this internal monologue next quarter. Here you’ll learn the messaging and discovery tactics that show you who is in and out early in your process, and the tactics you can use to flat out win more deals.<br><br>Whether you are looking to get more quality opportunities flowing in your pipeline or you manage a team that is breaking into a new market or looking to find a way to level up their game, this is the course for you.','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SDMT&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002YZq" style="height: 331px; width: 500px;"></img>','','Online self-guided','The Art of Sales Persuasion','','','','','0124P0000003S96QAE','','False','','','','','','','1','');
INSERT INTO "Program__c" VALUES(48,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','The Leadership and Management Program','','False','','Leadership','','4.4','','','','Learn the essentials of successful leadership and concepts you can apply right away. From emotional intelligence to systems thinking, return to work with a new lens.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij5F&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000005A79b" style="height: 281px; width: 500px;"></img>','','In person','The Leadership and Management Program','','','','','0124P0000003S96QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(49,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','20th Century US History','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span>This three-week course will provide an overview of US history from the end of the nineteenth century to the start of the twenty-first century.</span></span></span><br> ','Course Catalog','20252','<img alt="US History image cloud" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEBG&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXNe"></img>','','Hybrid (in person and online)','20th Century US History','','','','','0124P0000003S96QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(50,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Agile Project Management','','False','','Project Management','','2.1','','','','Dive into the agile methodology in this three-day program. Learn to complete projects more efficiently and earn a St. Thomas Certified Agile Practitioner certification (UST-CAP).','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij63&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wOY"></img>','','In person','Agile Project Management','','','','','0124P0000003S96QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(51,'','True','','50.0','School of Education','','','','','Non-Credit','','','','202002-ASD','','','','','','','','','','','','','','False','','','','Autism Spectrum Disorder: Evidence-Based Practices','','False','','Education','','4.0','','','','This course will provide educators a solid understanding of the evidence-based practices and high-leverage practices in the field of autism spectrum disorder.','Course Catalog','40493','<img alt="A young girl draws with markers while in a therapy session, with the therapist sitting behind her, writing on a pad." src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a0000052VMC&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a000000AJoN"','','Online self-guided','Autism Spectrum Disorder: Evidence-Based Practices','','','','','0124P0000003S96QAE','','False','','','','','','','9','');
INSERT INTO "Program__c" VALUES(52,'','True','','50.0','College of Arts and Sciences','','','','','Non-Credit','','','','2020-BecHuman-01','','','','','','','','','','','','','','False','','','','Becoming Human: Dismantling Racism','','False','','Personal Growth','','','','','','<p>“Becoming Human,” is rooted in the idea that the racial history people in the United States inherit is dehumanizing for all of us, though it is dehumanizing for white folks in different ways than it is dehumanizing for people of color.  </p>

<p>The only way to “become human” is to confront the legacy of white supremacy, and to work to dismantle the structures that distribute advantages and disadvantages unequally on the basis of pigmentation in the skin. This work to dismantle racist structures will interrupt the cultural conditioning in white supremacy that has been able to perpetuate down through the centuries.  </p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SKT8&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002tQv" style="height: 375px; width: 500px;"></img>','','Online self-guided','Becoming Human: Dismantling Racism','','','','','0124P0000003S96QAE','','False','','','','','','','2','');
INSERT INTO "Program__c" VALUES(53,'','True','','125.0','School of Education','','','','','Non-Credit','','','','202009-TIPP-K-12','','','','','','','','','','','','','','False','','','','Becoming Trauma-Informed: A Primer for Educators','','False','','Education','','8.0','','','','More than two-thirds of people report experiencing at least one traumatic event by age 16. For some, school is a respite from the anxiety and worry at home, but for others, well-meaning teachers are doing more harm than good by not being trauma-aware.?It is essential that educators know how to identify and help students who face the impacts of trauma.? ','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SW96&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002x0X"></img>','','Online self-guided','Becoming Trauma-Informed: A Primer for Educators','','','','','0124P0000003S96QAE','','False','','','','','','','9','');
INSERT INTO "Program__c" VALUES(54,'','True','','75.0','University of St. Thomas','','NCUST_IMCA','','','Non-Credit','','','','202204-DEIViewfinder','','','','','','','','','','','','','','False','','','','Inclusive Marketing & Communications: A Practical Approach','','False','','Education;Healthcare;Leadership;General Business;Nonprofit;Personal Growth;Project Management;Sales & Marketing;Workplace Skills','','0.2','','','','From images and presentations to emails, this course will help you examine content through a DEI lens, identifying common pitfalls that can send unintended messages and undermine inclusivity.','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006V9bH&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007uycF" style="height: 281px; width: 500px;"></img>','','Online self-guided','Inclusive Marketing & Communications: A Practical Approach','Inclusive Marketing & Communications: A Practical Approach','','','','0124P0000003S96QAE','','False','','','','','','','1','');
INSERT INTO "Program__c" VALUES(55,'','True','','99.0','University of St. Thomas','','','','','Non-Credit','','','','202006-DIYV','','','','','','','','','','','','','','False','','','','Simpler (and Smarter) DIY Videos','','False','','Personal Growth','','','','','','<p>Creating professional-looking videos can seem daunting, but it doesn’t need to be! You can produce high-quality videos with little more than your smartphone and some imagination, and this course will teach you how to do it. We’ll explain common types of video projects and help you decide which type suits your needs. Then, you’ll learn best practices for planning, shooting, editing and distributing your project. At the end, you’ll submit a short video and get feedback from our experts. Join us and learn to create simpler (and smarter) DIY videos!</p>','Course Catalog','40493','<img alt="Charming young African man in shirt showing digital camera and telling something while making social media video" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SDMY&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002Yae" styl','','Online self-guided','Simpler (and Smarter) DIY Videos','','','','','0124P0000003S97QAE','','False','','','','','','','1','');
INSERT INTO "Program__c" VALUES(56,'','True','','99.0','Opus College of Business','','','','','Non-Credit','','','','202009-SmallBusSmart','','','','','','','','','','','','','','False','','','','Smart Start for Business','','False','','General Business','','','','','','<p>Twenty percent of new businesses fail in the first two years. Why? Lack of knowledge, resources, and planning. Taking the time to learn and plan is the best first investment a business owner can make. Smart Start for Business will provide you with all the information prospective (and new) business owners need to be successful. You’ll also have the chance to share with other entrepreneurs and get your questions answered from seasoned business owners. We’re here to help you stay out of the twenty percent. </p>','Course Catalog','40493','<img alt="Person holding an iPad that reads &quot;Small Business.&quot;" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SVU2&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002x9A" style="height: 375px; width: 500px;"></img>','','Online self-guided','Smart Start for Business','','','','','0124P0000003S97QAE','','False','','','','','','','4','');
INSERT INTO "Program__c" VALUES(57,'','True','','','University of St. Thomas','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Supply Chain Management','','False','','General Business','','1.4','','','','This 2-day Supply Chain Management course provides an introduction to navigating the supply chain and creating efficiencies that help your organization run smoothly, across departments.','Course Catalog','28491','<img alt="Logistics workers reviewing data" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij55&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007uxYh" style="height: 281px; width: 500px;"></img>','','In person','Supply Chain Management','','','','','0124P0000003S97QAE','','False','','','','','','','1','');
INSERT INTO "Program__c" VALUES(58,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','The Prophets','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">This program offers an introduction &amp; overview of prophets &amp; prophecy in ancient Israel &amp; will provide an in-depth look at selected texts with emphasis on interpretation &amp; relevance for our world today.</span></span></span><br> ','Course Catalog','20252','<img alt="Man writing at a desk" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEBg&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXOX"></img>','','Hybrid (in person and online)','The Prophets','','','','','0124P0000003S97QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(59,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','The Singularity is Already Here, Not with a Bang but with a Whimper','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">Thieme predicted the impacts of the computer revolution on society at all levels 25 years ago. Now he looks at the inevitable consequences of what we’re doing now &amp; its implications for democracy.</span></span></span><br><br> ','Course Catalog','20252','<img alt="AI figure with computer symbols" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kECF&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXRW"></img>','','Hybrid (in person and online)','The Singularity is Already Here, Not with a Bang but with a Whimper','','','','','0124P0000003S97QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(60,'','True','','25.0','School of Education','','','','','Non-Credit','','','','202004-TLO','','','','','','','','','','','','','','False','','','','Teaching Live, Online!','','False','','Education','','','','','','Teaching live, online can seem scary, but it doesn’t need to be. This course will teach you the tips, tricks, and tools you need to have a successful virtual class meeting.  We’ll go over how to choose the right platform and equipment for your needs, set up your streaming environment, and plan a class that holds students’ attention and encourages participation. You and your students will come to love the flexibility and versatility of teaching live, online!','Course Catalog','40493','<img alt="computer-screen-instructor-whiteboard" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a0000052cRg&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a000000ASGp" style="height: 375px; width: 500px;"></img>','','Online self-guided','Teaching Live, Online!','','','','','0124P0000003S97QAE','','False','','','','','','','9','');
INSERT INTO "Program__c" VALUES(61,'','True','','325.0','University of St. Thomas','','','','','Non-Credit','','','','202006-ASP','','','','','','','','','','','','','','False','','','','The Art of Sales Persuasion','','False','','Sales & Marketing','','','','','','You thought they were going to close this quarter. You did the pitch, the meeting went great, so what went wrong? The Art of Sales Persuasion will equip you with the tools to prevent this internal monologue next quarter. Here you’ll learn the messaging and discovery tactics that show you who is in and out early in your process, and the tactics you can use to flat out win more deals.<br><br>Whether you are looking to get more quality opportunities flowing in your pipeline or you manage a team that is breaking into a new market or looking to find a way to level up their game, this is the course for you.','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SDMT&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002YZq" style="height: 331px; width: 500px;"></img>','','Online self-guided','The Art of Sales Persuasion','','','','','0124P0000003S97QAE','','False','','','','','','','1','');
INSERT INTO "Program__c" VALUES(62,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','The Leadership and Management Program','','False','','Leadership','','4.4','','','','Learn the essentials of successful leadership and concepts you can apply right away. From emotional intelligence to systems thinking, return to work with a new lens.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij5F&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000005A79b" style="height: 281px; width: 500px;"></img>','','In person','The Leadership and Management Program','','','','','0124P0000003S97QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(63,'','True','','99.0','School of Education','','','','','Non-Credit','','','','202010-ExplicitReading','','','','','','','','','','','','','','False','','','','Essential Literacy Instruction','','False','','Education','','4.0','','','','Scientifically based reading instruction is key to solving the national reading problem. In this course we will teach the five components of reading instruction, underscore the importance of early identification of children with reading difficulties and highlight effective remediation strategies.  ','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b0000052iTi&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000000AqoL" style="height: 375px; width: 500px;"></img>','','Online self-guided','Essential Literacy Instruction','','','','','0124P0000003S96QAE','','False','','','','','','','9','');
INSERT INTO "Program__c" VALUES(64,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Examinations in Minnesota Race Relations in 3 Case Studies','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span>The pre-eminent historian of African-Americans in Minnesota will look at the development of race relations in Minnesota through the lens of 3 case studies &amp; the stories that surround them.</span></span></span><br> ','Course Catalog','20252','<img alt="State of Minnesota word cloud" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEBB&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXNA"></img>','','Hybrid (in person and online)','Examinations in Minnesota Race Relations in 3 Case Studies','','','','','0124P0000003S96QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(65,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Exploring the Psychology of Personality','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Calibri,sans-serif;"><span style="">This course will review the Big 5 trait model &amp; contrast it with the Myers-Brigg Type Indicator &amp; will discuss a range of explanations for what makes individuals different and what we have in common.</span></span></span><br> ','Course Catalog','20252','<img alt="People with puzzle of brain" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEC5&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXQY"></img>','','Hybrid (in person and online)','Exploring the Psychology of Personality','','','','','0124P0000003S96QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(66,'','True','','30.0','Morrison Family College of Health','','','','','Non-Credit','','','','2021-Telehealth','','','','','','','','','','','','','','False','','','','Ethics and Telemental Health','','False','','Healthcare','','2.0','','','','Explore the ethical?concerns and challenges related to telehealth and learn best practices you can apply now and in the future. Ethics CEs approved by MN BOSW.','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006UdaR&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000006WgoI" style="height: 281px; width: 500px;"></img>','','Online self-guided','Ethics and Telemental Health','','','','','0124P0000003S96QAE','','False','','','','','','','8','');
INSERT INTO "Program__c" VALUES(67,'','True','','50.0','School of Education','','','','','Non-Credit','','','','202002-ASD','','','','','','','','','','','','','','False','','','','Autism Spectrum Disorder: Evidence-Based Practices','','False','','Education','','4.0','','','','This course will provide educators a solid understanding of the evidence-based practices and high-leverage practices in the field of autism spectrum disorder.','Course Catalog','40493','<img alt="A young girl draws with markers while in a therapy session, with the therapist sitting behind her, writing on a pad." src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a0000052VMC&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a000000AJoN"','','Online self-guided','Autism Spectrum Disorder: Evidence-Based Practices','','','','','0124P0000003S97QAE','','False','','','','','','','9','');
INSERT INTO "Program__c" VALUES(68,'','True','','50.0','College of Arts and Sciences','','','','','Non-Credit','','','','2020-BecHuman-01','','','','','','','','','','','','','','False','','','','Becoming Human: Dismantling Racism','','False','','Personal Growth','','','','','','<p>“Becoming Human,” is rooted in the idea that the racial history people in the United States inherit is dehumanizing for all of us, though it is dehumanizing for white folks in different ways than it is dehumanizing for people of color.  </p>

<p>The only way to “become human” is to confront the legacy of white supremacy, and to work to dismantle the structures that distribute advantages and disadvantages unequally on the basis of pigmentation in the skin. This work to dismantle racist structures will interrupt the cultural conditioning in white supremacy that has been able to perpetuate down through the centuries.  </p>','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SKT8&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002tQv" style="height: 375px; width: 500px;"></img>','','Online self-guided','Becoming Human: Dismantling Racism','','','','','0124P0000003S97QAE','','False','','','','','','','2','');
INSERT INTO "Program__c" VALUES(69,'','True','','','Selim Center for Lifelong Learning','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Everyday Economics','','False','','Personal Growth','','','','','','<span style="font-size: 11pt;"><span style="font-family: Arial,sans-serif;"><span style=""><span style="color: black;">Our lives are affected by economic decision making daily, yet economics seems so complicated. Described as the “science of common sense”, the instructors will bring common sense to a variety of topics.</span></span></span></span><br> ','Course Catalog','20252','<img alt="Economics word cloud" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kEBv&amp;feoid=00N0a00000D0P8l&amp;refid=0EM5b000007yXQ9"></img>','','Hybrid (in person and online)','Everyday Economics','','','','','0124P0000003S96QAE','','False','','','','','','','6','');
INSERT INTO "Program__c" VALUES(70,'','True','','125.0','School of Education','','','','','Non-Credit','','','','202009-TIPP-K-12','','','','','','','','','','','','','','False','','','','Becoming Trauma-Informed: A Primer for Educators','','False','','Education','','8.0','','','','More than two-thirds of people report experiencing at least one traumatic event by age 16. For some, school is a respite from the anxiety and worry at home, but for others, well-meaning teachers are doing more harm than good by not being trauma-aware.?It is essential that educators know how to identify and help students who face the impacts of trauma.? ','Course Catalog','40493','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t0a000005SW96&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002x0X"></img>','','Online self-guided','Becoming Trauma-Informed: A Primer for Educators','','','','','0124P0000003S97QAE','','False','','','','','','','9','');
INSERT INTO "Program__c" VALUES(71,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Mini MBA for Nonprofit Organizations','','False','','Nonprofit','','4.2','','','','Learn how to have a more effective impact in your nonprofit organization. Gain a solid foundation of skills, tools and knowledge needed to be successful in the nonprofit sector.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij5P&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wOn"></img>','','In person','Mini MBA for Nonprofit Organizations','','','','','0124P0000003S96QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(72,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Mini MBA for Nonprofit Organizations - Virtual','','False','','Nonprofit','','4.2','','','','Learn how to have a more effective impact in your nonprofit organization. Gain a solid foundation of skills, tools and knowledge needed to be successful in the nonprofit sector.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kL8o&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wOn"></img>','','Online instructor guided','Mini MBA for Nonprofit Organizations - Virtual','','','','','0124P0000003S96QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(73,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Mini MBA','','False','','General Business','','3.8','','','','Gain a solid foundation in business and leadership strategy while learning skills you can put to work right away. Practice these skills with a business simulation.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006ij5y&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wNz"></img>','','In person','Mini MBA','','','','','0124P0000003S96QAE','','False','','','','','','','7','');
INSERT INTO "Program__c" VALUES(74,'','True','','','Executive Education','','','','','Non-Credit','','','','','','','','','','','','','','','','','','False','','','','Mini MBA - Virtual','','False','','General Business','','3.8','','','','Gain a solid foundation in business and leadership strategy while learning skills you can put to work right away. Practice these skills with a business simulation.','Course Catalog','28491','<img alt="User-added image" src="https://stthomas.file.force.com/servlet/rtaImage?eid=01t5b000006kL8j&amp;feoid=00N0a00000D0P8l&amp;refid=0EM0a0000002wNz"></img>','','Online instructor guided','Mini MBA - Virtual','','','','','0124P0000003S96QAE','','False','','','','','','','7','');
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
INSERT INTO "Question_Dependency__c" VALUES(1,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8rPIAQ','a2aS0000003f8rTIAQ');
INSERT INTO "Question_Dependency__c" VALUES(2,'0124P0000003S99QAE','True','Other','a2aS0000003f8rQIAQ','a2aS0000003f8rRIAQ');
INSERT INTO "Question_Dependency__c" VALUES(3,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8rSIAQ','a2aS0000003f8r4IAA');
INSERT INTO "Question_Dependency__c" VALUES(4,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8rSIAQ','a2aS0000003f8r6IAA');
INSERT INTO "Question_Dependency__c" VALUES(5,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8rVIAQ','a2aS0000003f8rUIAQ');
INSERT INTO "Question_Dependency__c" VALUES(6,'0124P0000003S9AQAU','True','Work','a2aS0000003f8rVIAQ','a2aS0000003f8rWIAQ');
INSERT INTO "Question_Dependency__c" VALUES(7,'0124P0000003S9AQAU','True','Home','a2aS0000003f8rVIAQ','a2aS0000003f8rXIAQ');
INSERT INTO "Question_Dependency__c" VALUES(8,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8rVIAQ','a2aS0000003f8rYIAQ');
INSERT INTO "Question_Dependency__c" VALUES(9,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XMIAY','a2aS0000003f8XBIAY');
INSERT INTO "Question_Dependency__c" VALUES(10,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XMIAY','a2aS0000003f8XFIAY');
INSERT INTO "Question_Dependency__c" VALUES(11,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XMIAY','a2aS0000003f8XGIAY');
INSERT INTO "Question_Dependency__c" VALUES(12,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XMIAY','a2aS0000003f8XHIAY');
INSERT INTO "Question_Dependency__c" VALUES(13,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XMIAY','a2aS0000003f8XIIAY');
INSERT INTO "Question_Dependency__c" VALUES(14,'0124P0000003S98QAE','False','','5','6');
INSERT INTO "Question_Dependency__c" VALUES(15,'0124P0000003S9AQAU','True','No','a2aS0000003f8XMIAY','a2aS0000003f8XKIAY');
INSERT INTO "Question_Dependency__c" VALUES(16,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XMIAY','a2aS0000003f8XSIAY');
INSERT INTO "Question_Dependency__c" VALUES(17,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XMIAY','a2aS0000003f8XTIAY');
INSERT INTO "Question_Dependency__c" VALUES(18,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8nxIAA','a2aS0000003f8nyIAA');
INSERT INTO "Question_Dependency__c" VALUES(19,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8nxIAA','a2aS0000003f8nzIAA');
INSERT INTO "Question_Dependency__c" VALUES(20,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8nxIAA','a2aS0000003f8o0IAA');
INSERT INTO "Question_Dependency__c" VALUES(21,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8nxIAA','a2aS0000003f8oCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(22,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8nxIAA','a2aS0000003f8oDIAQ');
INSERT INTO "Question_Dependency__c" VALUES(23,'0124P0000003S98QAE','True','','a2aS0000003f8bzIAA','a2aS0000003f8byIAA');
INSERT INTO "Question_Dependency__c" VALUES(24,'0124P0000003S98QAE','True','','a2aS0000003f8bzIAA','a2aS0000003f8c0IAA');
INSERT INTO "Question_Dependency__c" VALUES(25,'0124P0000003S98QAE','True','','a2aS0000003f8bzIAA','a2aS0000003f8c1IAA');
INSERT INTO "Question_Dependency__c" VALUES(26,'0124P0000003S98QAE','True','','a2aS0000003f8bzIAA','a2aS0000003f8c2IAA');
INSERT INTO "Question_Dependency__c" VALUES(27,'0124P0000003S98QAE','True','','a2aS0000003f8bzIAA','a2aS0000003f8c3IAA');
INSERT INTO "Question_Dependency__c" VALUES(28,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8cDIAQ','a2aS0000003f8c7IAA');
INSERT INTO "Question_Dependency__c" VALUES(29,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8cDIAQ','a2aS0000003f8c8IAA');
INSERT INTO "Question_Dependency__c" VALUES(30,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8cDIAQ','a2aS0000003f8c9IAA');
INSERT INTO "Question_Dependency__c" VALUES(31,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8tQIAQ','a2aS0000003f8teIAA');
INSERT INTO "Question_Dependency__c" VALUES(32,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8tQIAQ','a2aS0000003f8tfIAA');
INSERT INTO "Question_Dependency__c" VALUES(33,'0124P0000003S99QAE','True','Asian','a2aS0000003f8tQIAQ','a2aS0000003f8tiIAA');
INSERT INTO "Question_Dependency__c" VALUES(34,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8tQIAQ','a2aS0000003f8tmIAA');
INSERT INTO "Question_Dependency__c" VALUES(35,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8tQIAQ','a2aS0000003f8toIAA');
INSERT INTO "Question_Dependency__c" VALUES(36,'0124P0000003S99QAE','True','White','a2aS0000003f8tQIAQ','a2aS0000003f8tqIAA');
INSERT INTO "Question_Dependency__c" VALUES(37,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8tQIAQ','a2aS0000003f8tsIAA');
INSERT INTO "Question_Dependency__c" VALUES(38,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8tTIAQ','a2aS0000003f8tcIAA');
INSERT INTO "Question_Dependency__c" VALUES(39,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8tTIAQ','a2aS0000003f8tdIAA');
INSERT INTO "Question_Dependency__c" VALUES(40,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8tUIAQ','a2aS0000003f8tSIAQ');
INSERT INTO "Question_Dependency__c" VALUES(41,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8tVIAQ','a2aS0000003f8tWIAQ');
INSERT INTO "Question_Dependency__c" VALUES(42,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8tYIAQ','a2aS0000003f8tZIAQ');
INSERT INTO "Question_Dependency__c" VALUES(43,'0124P0000003S99QAE','True','White','a2aS0000003f8rIIAQ','a2aS0000003f8rRIAQ');
INSERT INTO "Question_Dependency__c" VALUES(44,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8rIIAQ','a2aS0000003f8rOIAQ');
INSERT INTO "Question_Dependency__c" VALUES(45,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8rIIAQ','a2aS0000003f8rPIAQ');
INSERT INTO "Question_Dependency__c" VALUES(46,'0124P0000003S99QAE','True','White','a2aS0000003f8rIIAQ','a2aS0000003f8rQIAQ');
INSERT INTO "Question_Dependency__c" VALUES(47,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8rIIAQ','a2aS0000003f8rSIAQ');
INSERT INTO "Question_Dependency__c" VALUES(48,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8rIIAQ','a2aS0000003f8rTIAQ');
INSERT INTO "Question_Dependency__c" VALUES(49,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8rLIAQ','a2aS0000003f8r1IAA');
INSERT INTO "Question_Dependency__c" VALUES(50,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8rLIAQ','a2aS0000003f8r2IAA');
INSERT INTO "Question_Dependency__c" VALUES(51,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8rMIAQ','a2aS0000003f8rKIAQ');
INSERT INTO "Question_Dependency__c" VALUES(52,'0124P0000003S99QAE','True','Other','a2aS0000003f8rNIAQ','a2aS0000003f8rOIAQ');
INSERT INTO "Question_Dependency__c" VALUES(53,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8tYIAQ','a2aS0000003f8taIAA');
INSERT INTO "Question_Dependency__c" VALUES(54,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8tYIAQ','a2aS0000003f8tbIAA');
INSERT INTO "Question_Dependency__c" VALUES(55,'0124P0000003S9AQAU','True','A different address','a2aS0000003f8XTIAY','a2aS0000003f8X8IAI');
INSERT INTO "Question_Dependency__c" VALUES(56,'0124P0000003S9AQAU','True','A different address','a2aS0000003f8XTIAY','a2aS0000003f8X9IAI');
INSERT INTO "Question_Dependency__c" VALUES(57,'0124P0000003S9AQAU','True','A different address','a2aS0000003f8XTIAY','a2aS0000003f8XSIAY');
INSERT INTO "Question_Dependency__c" VALUES(58,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8tiIAA','a2aS0000003f8tjIAA');
INSERT INTO "Question_Dependency__c" VALUES(59,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8tiIAA','a2aS0000003f8tkIAA');
INSERT INTO "Question_Dependency__c" VALUES(60,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8tiIAA','a2aS0000003f8tlIAA');
INSERT INTO "Question_Dependency__c" VALUES(61,'0124P0000003S99QAE','True','Other','a2aS0000003f8tmIAA','a2aS0000003f8tnIAA');
INSERT INTO "Question_Dependency__c" VALUES(62,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8toIAA','a2aS0000003f8tpIAA');
INSERT INTO "Question_Dependency__c" VALUES(63,'0124P0000003S99QAE','True','Other','a2aS0000003f8tqIAA','a2aS0000003f8trIAA');
INSERT INTO "Question_Dependency__c" VALUES(64,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8tsIAA','a2aS0000003f8tfIAA');
INSERT INTO "Question_Dependency__c" VALUES(65,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8tsIAA','a2aS0000003f8thIAA');
INSERT INTO "Question_Dependency__c" VALUES(66,'0124P0000003S9AQAU','True','No','a2aS0000003f8buIAA','a2aS0000003f8bvIAA');
INSERT INTO "Question_Dependency__c" VALUES(67,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ojIAA','a2aS0000003f8oeIAA');
INSERT INTO "Question_Dependency__c" VALUES(68,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ojIAA','a2aS0000003f8ofIAA');
INSERT INTO "Question_Dependency__c" VALUES(69,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ojIAA','a2aS0000003f8ogIAA');
INSERT INTO "Question_Dependency__c" VALUES(70,'0124P0000003S98QAE','True','','a2aS0000003f8omIAA','a2aS0000003f8oYIAQ');
INSERT INTO "Question_Dependency__c" VALUES(71,'0124P0000003S98QAE','True','','a2aS0000003f8omIAA','a2aS0000003f8oZIAQ');
INSERT INTO "Question_Dependency__c" VALUES(72,'0124P0000003S98QAE','True','','a2aS0000003f8omIAA','a2aS0000003f8oaIAA');
INSERT INTO "Question_Dependency__c" VALUES(73,'0124P0000003S9AQAU','True','Home','a2aS0000003f8wYIAQ','a2aS0000003f8wVIAQ');
INSERT INTO "Question_Dependency__c" VALUES(74,'0124P0000003S98QAE','True','','a2aS0000003f8omIAA','a2aS0000003f8olIAA');
INSERT INTO "Question_Dependency__c" VALUES(75,'0124P0000003S98QAE','True','','a2aS0000003f8omIAA','a2aS0000003f8onIAA');
INSERT INTO "Question_Dependency__c" VALUES(76,'0124P0000003S9AQAU','True','No','a2aS0000003f8oGIAQ','a2aS0000003f8oHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(77,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8wYIAQ','a2aS0000003f8wWIAQ');
INSERT INTO "Question_Dependency__c" VALUES(78,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8wYIAQ','a2aS0000003f8wXIAQ');
INSERT INTO "Question_Dependency__c" VALUES(79,'0124P0000003S9AQAU','True','Work','a2aS0000003f8wYIAQ','a2aS0000003f8wZIAQ');
INSERT INTO "Question_Dependency__c" VALUES(80,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8udIAA','a2aS0000003f8uYIAQ');
INSERT INTO "Question_Dependency__c" VALUES(81,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8udIAA','a2aS0000003f8uZIAQ');
INSERT INTO "Question_Dependency__c" VALUES(82,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8udIAA','a2aS0000003f8uaIAA');
INSERT INTO "Question_Dependency__c" VALUES(83,'0124P0000003S98QAE','True','','a2aS0000003f8uhIAA','a2aS0000003f8ugIAA');
INSERT INTO "Question_Dependency__c" VALUES(84,'0124P0000003S98QAE','True','','a2aS0000003f8uhIAA','a2aS0000003f8uiIAA');
INSERT INTO "Question_Dependency__c" VALUES(85,'0124P0000003S98QAE','True','','a2aS0000003f8uhIAA','a2aS0000003f8ujIAA');
INSERT INTO "Question_Dependency__c" VALUES(86,'0124P0000003S98QAE','True','','a2aS0000003f8uhIAA','a2aS0000003f8ukIAA');
INSERT INTO "Question_Dependency__c" VALUES(87,'0124P0000003S98QAE','True','','a2aS0000003f8uhIAA','a2aS0000003f8ulIAA');
INSERT INTO "Question_Dependency__c" VALUES(88,'0124P0000003S9AQAU','True','Other','a2aS0000003f8u2IAA','a2aS0000003f8u1IAA');
INSERT INTO "Question_Dependency__c" VALUES(89,'0124P0000003S9AQAU','True','Other','a2aS0000003f8u2IAA','a2aS0000003f8u3IAA');
INSERT INTO "Question_Dependency__c" VALUES(90,'0124P0000003S9AQAU','True','Other','a2aS0000003f8u2IAA','a2aS0000003f8u4IAA');
INSERT INTO "Question_Dependency__c" VALUES(91,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8wbIAA','a2aS0000003f8wcIAA');
INSERT INTO "Question_Dependency__c" VALUES(92,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8wnIAA','a2aS0000003f8wqIAA');
INSERT INTO "Question_Dependency__c" VALUES(93,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8wlIAA','a2aS0000003f8whIAA');
INSERT INTO "Question_Dependency__c" VALUES(94,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8wnIAA','a2aS0000003f8woIAA');
INSERT INTO "Question_Dependency__c" VALUES(95,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8wnIAA','a2aS0000003f8wpIAA');
INSERT INTO "Question_Dependency__c" VALUES(96,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8w2IAA','a2aS0000003f8w3IAA');
INSERT INTO "Question_Dependency__c" VALUES(97,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8khIAA','a2aS0000003f8keIAA');
INSERT INTO "Question_Dependency__c" VALUES(98,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8kkIAA','a2aS0000003f8kgIAA');
INSERT INTO "Question_Dependency__c" VALUES(99,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8kmIAA','a2aS0000003f8knIAA');
INSERT INTO "Question_Dependency__c" VALUES(100,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8kmIAA','a2aS0000003f8koIAA');
INSERT INTO "Question_Dependency__c" VALUES(101,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8kmIAA','a2aS0000003f8kpIAA');
INSERT INTO "Question_Dependency__c" VALUES(102,'0124P0000003S9AQAU','True','No','a2aS0000003f8anIAA','a2aS0000003f8amIAA');
INSERT INTO "Question_Dependency__c" VALUES(103,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vhIAA','a2aS0000003f8vbIAA');
INSERT INTO "Question_Dependency__c" VALUES(104,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vhIAA','a2aS0000003f8vcIAA');
INSERT INTO "Question_Dependency__c" VALUES(105,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vhIAA','a2aS0000003f8vdIAA');
INSERT INTO "Question_Dependency__c" VALUES(106,'0124P0000003S9AQAU','True','Other','a2aS0000003f8w5IAA','a2aS0000003f8w7IAA');
INSERT INTO "Question_Dependency__c" VALUES(107,'0124P0000003S98QAE','True','','a2aS0000003f8vlIAA','a2aS0000003f8vVIAQ');
INSERT INTO "Question_Dependency__c" VALUES(108,'0124P0000003S98QAE','True','','a2aS0000003f8vlIAA','a2aS0000003f8vWIAQ');
INSERT INTO "Question_Dependency__c" VALUES(109,'0124P0000003S98QAE','True','','a2aS0000003f8vlIAA','a2aS0000003f8vXIAQ');
INSERT INTO "Question_Dependency__c" VALUES(110,'0124P0000003S98QAE','True','','a2aS0000003f8vlIAA','a2aS0000003f8vYIAQ');
INSERT INTO "Question_Dependency__c" VALUES(111,'0124P0000003S98QAE','True','','a2aS0000003f8vlIAA','a2aS0000003f8vkIAA');
INSERT INTO "Question_Dependency__c" VALUES(112,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8wsIAA','a2aS0000003f8x4IAA');
INSERT INTO "Question_Dependency__c" VALUES(113,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8wtIAA','a2aS0000003f8wyIAA');
INSERT INTO "Question_Dependency__c" VALUES(114,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8wuIAA','a2aS0000003f8wvIAA');
INSERT INTO "Question_Dependency__c" VALUES(115,'0124P0000003S99QAE','True','White','a2aS0000003f8wwIAA','a2aS0000003f8xIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(116,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8wwIAA','a2aS0000003f8xKIAQ');
INSERT INTO "Question_Dependency__c" VALUES(117,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8wwIAA','a2aS0000003f8x6IAA');
INSERT INTO "Question_Dependency__c" VALUES(118,'0124P0000003S99QAE','True','Asian','a2aS0000003f8wwIAA','a2aS0000003f8xAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(119,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8wwIAA','a2aS0000003f8xEIAQ');
INSERT INTO "Question_Dependency__c" VALUES(120,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8wwIAA','a2aS0000003f8xGIAQ');
INSERT INTO "Question_Dependency__c" VALUES(121,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8x0IAA','a2aS0000003f8x1IAA');
INSERT INTO "Question_Dependency__c" VALUES(122,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8x0IAA','a2aS0000003f8x2IAA');
INSERT INTO "Question_Dependency__c" VALUES(123,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8x0IAA','a2aS0000003f8x3IAA');
INSERT INTO "Question_Dependency__c" VALUES(124,'0124P0000003S99QAE','True','Other','a2aS0000003f8x4IAA','a2aS0000003f8x5IAA');
INSERT INTO "Question_Dependency__c" VALUES(125,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8xAIAQ','a2aS0000003f8xBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(126,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8xAIAQ','a2aS0000003f8xCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(127,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8xAIAQ','a2aS0000003f8xDIAQ');
INSERT INTO "Question_Dependency__c" VALUES(128,'0124P0000003S99QAE','True','Other','a2aS0000003f8xEIAQ','a2aS0000003f8xFIAQ');
INSERT INTO "Question_Dependency__c" VALUES(129,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8xGIAQ','a2aS0000003f8xHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(130,'0124P0000003S99QAE','True','Other','a2aS0000003f92gIAA','a2aS0000003f92hIAA');
INSERT INTO "Question_Dependency__c" VALUES(131,'0124P0000003S98QAE','True','','a2aS0000003f93nIAA','a2aS0000003f93oIAA');
INSERT INTO "Question_Dependency__c" VALUES(132,'0124P0000003S99QAE','True','Other','a2aS0000003f8xIIAQ','a2aS0000003f8xJIAQ');
INSERT INTO "Question_Dependency__c" VALUES(133,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8xKIAQ','a2aS0000003f8x7IAA');
INSERT INTO "Question_Dependency__c" VALUES(134,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8xKIAQ','a2aS0000003f8x9IAA');
INSERT INTO "Question_Dependency__c" VALUES(135,'0124P0000003S9AQAU','True','No','a2aS0000003f8xjIAA','a2aS0000003f8xkIAA');
INSERT INTO "Question_Dependency__c" VALUES(136,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8xOIAQ','a2aS0000003f8xLIAQ');
INSERT INTO "Question_Dependency__c" VALUES(137,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8xOIAQ','a2aS0000003f8xMIAQ');
INSERT INTO "Question_Dependency__c" VALUES(138,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8xOIAQ','a2aS0000003f8xNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(139,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8cGIAQ','a2aS0000003f8cHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(140,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8lDIAQ','a2aS0000003f8lBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(141,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8lFIAQ','a2aS0000003f8lHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(142,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8lIIAQ','a2aS0000003f8lEIAQ');
INSERT INTO "Question_Dependency__c" VALUES(143,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8lJIAQ','a2aS0000003f8lCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(144,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8lLIAQ','a2aS0000003f8lGIAQ');
INSERT INTO "Question_Dependency__c" VALUES(145,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8wCIAQ','a2aS0000003f8wBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(146,'0124P0000003S9AQAU','True','No','a2aS0000003f8f7IAA','a2aS0000003f8f3IAA');
INSERT INTO "Question_Dependency__c" VALUES(147,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8gsIAA','a2aS0000003f8gjIAA');
INSERT INTO "Question_Dependency__c" VALUES(148,'0124P0000003S9AQAU','True','No','a2aS0000003f8ZyIAI','a2aS0000003f8ZzIAI');
INSERT INTO "Question_Dependency__c" VALUES(149,'0124P0000003S99QAE','True','Other','a2aS0000003f9N2IAI','a2aS0000003f9N3IAI');
INSERT INTO "Question_Dependency__c" VALUES(150,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9N4IAI','a2aS0000003f9N2IAI');
INSERT INTO "Question_Dependency__c" VALUES(151,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8kAIAQ','a2aS0000003f8kBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(152,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8kAIAQ','a2aS0000003f8kCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(153,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8kAIAQ','a2aS0000003f8kDIAQ');
INSERT INTO "Question_Dependency__c" VALUES(154,'0124P0000003S99QAE','True','Other','a2aS0000003f8kEIAQ','a2aS0000003f8kFIAQ');
INSERT INTO "Question_Dependency__c" VALUES(155,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8kGIAQ','a2aS0000003f8kHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(156,'0124P0000003S99QAE','True','Other','a2aS0000003f8kIIAQ','a2aS0000003f8kJIAQ');
INSERT INTO "Question_Dependency__c" VALUES(157,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8kKIAQ','a2aS0000003f8k8IAA');
INSERT INTO "Question_Dependency__c" VALUES(158,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8kKIAQ','a2aS0000003f8k9IAA');
INSERT INTO "Question_Dependency__c" VALUES(159,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8kLIAQ','a2aS0000003f8k8IAA');
INSERT INTO "Question_Dependency__c" VALUES(160,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8gsIAA','a2aS0000003f8ggIAA');
INSERT INTO "Question_Dependency__c" VALUES(161,'0124P0000003S99QAE','True','Asian','a2aS0000003f8kLIAQ','a2aS0000003f8kAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(162,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8kLIAQ','a2aS0000003f8kEIAQ');
INSERT INTO "Question_Dependency__c" VALUES(163,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8kLIAQ','a2aS0000003f8kGIAQ');
INSERT INTO "Question_Dependency__c" VALUES(164,'0124P0000003S99QAE','True','White','a2aS0000003f8kLIAQ','a2aS0000003f8kIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(165,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8kLIAQ','a2aS0000003f8kKIAQ');
INSERT INTO "Question_Dependency__c" VALUES(166,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8kLIAQ','a2aS0000003f8kZIAQ');
INSERT INTO "Question_Dependency__c" VALUES(167,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8kOIAQ','a2aS0000003f8kXIAQ');
INSERT INTO "Question_Dependency__c" VALUES(168,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8kOIAQ','a2aS0000003f8kYIAQ');
INSERT INTO "Question_Dependency__c" VALUES(169,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8kPIAQ','a2aS0000003f8kNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(170,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8kQIAQ','a2aS0000003f8kRIAQ');
INSERT INTO "Question_Dependency__c" VALUES(171,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8kTIAQ','a2aS0000003f8kUIAQ');
INSERT INTO "Question_Dependency__c" VALUES(172,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8kTIAQ','a2aS0000003f8kVIAQ');
INSERT INTO "Question_Dependency__c" VALUES(173,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8kTIAQ','a2aS0000003f8kWIAQ');
INSERT INTO "Question_Dependency__c" VALUES(174,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8U2IAI','a2aS0000003f8U0IAI');
INSERT INTO "Question_Dependency__c" VALUES(175,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8U2IAI','a2aS0000003f8U3IAI');
INSERT INTO "Question_Dependency__c" VALUES(176,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8U2IAI','a2aS0000003f8U4IAI');
INSERT INTO "Question_Dependency__c" VALUES(177,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8U2IAI','a2aS0000003f8U5IAI');
INSERT INTO "Question_Dependency__c" VALUES(178,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8U2IAI','a2aS0000003f8U6IAI');
INSERT INTO "Question_Dependency__c" VALUES(179,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8U2IAI','a2aS0000003f8U7IAI');
INSERT INTO "Question_Dependency__c" VALUES(180,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8U2IAI','a2aS0000003f8U8IAI');
INSERT INTO "Question_Dependency__c" VALUES(181,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8U2IAI','a2aS0000003f8U9IAI');
INSERT INTO "Question_Dependency__c" VALUES(182,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8U2IAI','a2aS0000003f8UAIAY');
INSERT INTO "Question_Dependency__c" VALUES(183,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8U2IAI','a2aS0000003f8UBIAY');
INSERT INTO "Question_Dependency__c" VALUES(184,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8U2IAI','a2aS0000003f8UCIAY');
INSERT INTO "Question_Dependency__c" VALUES(185,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8U2IAI','a2aS0000003f8UDIAY');
INSERT INTO "Question_Dependency__c" VALUES(186,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8U2IAI','a2aS0000003f8TyIAI');
INSERT INTO "Question_Dependency__c" VALUES(187,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8U2IAI','a2aS0000003f8TzIAI');
INSERT INTO "Question_Dependency__c" VALUES(188,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9NpIAI','a2aS0000003f9NoIAI');
INSERT INTO "Question_Dependency__c" VALUES(189,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9NpIAI','a2aS0000003f9NtIAI');
INSERT INTO "Question_Dependency__c" VALUES(190,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9NpIAI','a2aS0000003f9NuIAI');
INSERT INTO "Question_Dependency__c" VALUES(191,'0124P0000003S9AQAU','True','Other','a2aS0000003f9O6IAI','a2aS0000003f9O4IAI');
INSERT INTO "Question_Dependency__c" VALUES(192,'0124P0000003S9AQAU','True','Other','a2aS0000003f9O6IAI','a2aS0000003f9O5IAI');
INSERT INTO "Question_Dependency__c" VALUES(193,'0124P0000003S9AQAU','True','Other','a2aS0000003f9O6IAI','a2aS0000003f9O7IAI');
INSERT INTO "Question_Dependency__c" VALUES(194,'0124P0000003S9AQAU','True','1','a2aS0000003f9OAIAY','a2aS0000003f9OBIAY');
INSERT INTO "Question_Dependency__c" VALUES(195,'0124P0000003S9AQAU','True','3','a2aS0000003f9OAIAY','a2aS0000003f9OBIAY');
INSERT INTO "Question_Dependency__c" VALUES(196,'0124P0000003S9AQAU','True','2','a2aS0000003f9OAIAY','a2aS0000003f9OBIAY');
INSERT INTO "Question_Dependency__c" VALUES(197,'0124P0000003S9AQAU','True','3','a2aS0000003f9OAIAY','a2aS0000003f9OFIAY');
INSERT INTO "Question_Dependency__c" VALUES(198,'0124P0000003S9AQAU','True','2','a2aS0000003f9OAIAY','a2aS0000003f9OHIAY');
INSERT INTO "Question_Dependency__c" VALUES(199,'0124P0000003S9AQAU','True','3','a2aS0000003f9OAIAY','a2aS0000003f9OHIAY');
INSERT INTO "Question_Dependency__c" VALUES(200,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f9ODIAY','a2aS0000003f9O8IAI');
INSERT INTO "Question_Dependency__c" VALUES(201,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f9ODIAY','a2aS0000003f9O9IAI');
INSERT INTO "Question_Dependency__c" VALUES(202,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f9ODIAY','a2aS0000003f9OAIAY');
INSERT INTO "Question_Dependency__c" VALUES(203,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f9ODIAY','a2aS0000003f9OCIAY');
INSERT INTO "Question_Dependency__c" VALUES(204,'0124P0000003S9AQAU','True','Home','a2aS0000003f8TSIAY','a2aS0000003f8TWIAY');
INSERT INTO "Question_Dependency__c" VALUES(205,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f9ODIAY','a2aS0000003f9OEIAY');
INSERT INTO "Question_Dependency__c" VALUES(206,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8TSIAY','a2aS0000003f8TTIAY');
INSERT INTO "Question_Dependency__c" VALUES(207,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8TSIAY','a2aS0000003f8TVIAY');
INSERT INTO "Question_Dependency__c" VALUES(208,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WxIAI','a2aS0000003f8WyIAI');
INSERT INTO "Question_Dependency__c" VALUES(209,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WxIAI','a2aS0000003f8WzIAI');
INSERT INTO "Question_Dependency__c" VALUES(210,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WxIAI','a2aS0000003f8X0IAI');
INSERT INTO "Question_Dependency__c" VALUES(211,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8USIAY','a2aS0000003f8UMIAY');
INSERT INTO "Question_Dependency__c" VALUES(212,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8USIAY','a2aS0000003f8UNIAY');
INSERT INTO "Question_Dependency__c" VALUES(213,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8USIAY','a2aS0000003f8UOIAY');
INSERT INTO "Question_Dependency__c" VALUES(214,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8USIAY','a2aS0000003f8UVIAY');
INSERT INTO "Question_Dependency__c" VALUES(215,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8USIAY','a2aS0000003f8UWIAY');
INSERT INTO "Question_Dependency__c" VALUES(216,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8UeIAI','a2aS0000003f8UdIAI');
INSERT INTO "Question_Dependency__c" VALUES(217,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8UeIAI','a2aS0000003f8UdIAI');
INSERT INTO "Question_Dependency__c" VALUES(218,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8UfIAI','a2aS0000003f8UnIAI');
INSERT INTO "Question_Dependency__c" VALUES(219,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8UfIAI','a2aS0000003f8UrIAI');
INSERT INTO "Question_Dependency__c" VALUES(220,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8UfIAI','a2aS0000003f8UuIAI');
INSERT INTO "Question_Dependency__c" VALUES(221,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8UfIAI','a2aS0000003f8UvIAI');
INSERT INTO "Question_Dependency__c" VALUES(222,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8UfIAI','a2aS0000003f8UwIAI');
INSERT INTO "Question_Dependency__c" VALUES(223,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8UfIAI','a2aS0000003f8UxIAI');
INSERT INTO "Question_Dependency__c" VALUES(224,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8UfIAI','a2aS0000003f8UzIAI');
INSERT INTO "Question_Dependency__c" VALUES(225,'0124P0000003S99QAE','True','Asian','a2aS0000003f8UfIAI','a2aS0000003f8V3IAI');
INSERT INTO "Question_Dependency__c" VALUES(226,'0124P0000003S99QAE','True','White','a2aS0000003f8UfIAI','a2aS0000003f8V4IAI');
INSERT INTO "Question_Dependency__c" VALUES(227,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8UiIAI','a2aS0000003f8V5IAI');
INSERT INTO "Question_Dependency__c" VALUES(228,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8UjIAI','a2aS0000003f8UkIAI');
INSERT INTO "Question_Dependency__c" VALUES(229,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8UjIAI','a2aS0000003f8UmIAI');
INSERT INTO "Question_Dependency__c" VALUES(230,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8UjIAI','a2aS0000003f8UsIAI');
INSERT INTO "Question_Dependency__c" VALUES(231,'0124P0000003S99QAE','True','Other','a2aS0000003f8UrIAI','a2aS0000003f8UyIAI');
INSERT INTO "Question_Dependency__c" VALUES(232,'0124P0000003S99QAE','True','Other','a2aS0000003f98MIAQ','a2aS0000003f98OIAQ');
INSERT INTO "Question_Dependency__c" VALUES(233,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8yeIAA','a2aS0000003f8ymIAA');
INSERT INTO "Question_Dependency__c" VALUES(234,'0124P0000003S99QAE','True','Other','a2aS0000003f8yfIAA','a2aS0000003f8yhIAA');
INSERT INTO "Question_Dependency__c" VALUES(235,'0124P0000003S99QAE','True','St. Thomas Alumnus/a','a2aS0000003f98MIAQ','a2aS0000003f98NIAQ');
INSERT INTO "Question_Dependency__c" VALUES(236,'0124P0000003S99QAE','True','High School Counselor/Teacher','a2aS0000003f98MIAQ','a2aS0000003f98PIAQ');
INSERT INTO "Question_Dependency__c" VALUES(237,'0124P0000003S99QAE','True','Independent College Counselor','a2aS0000003f98MIAQ','a2aS0000003f98QIAQ');
INSERT INTO "Question_Dependency__c" VALUES(238,'0124P0000003S99QAE','True','Community Based Organization/College Access Group','a2aS0000003f98MIAQ','a2aS0000003f98RIAQ');
INSERT INTO "Question_Dependency__c" VALUES(239,'0124P0000003S99QAE','True','Friend/Relative','a2aS0000003f98MIAQ','a2aS0000003f98SIAQ');
INSERT INTO "Question_Dependency__c" VALUES(240,'0124P0000003S9AQAU','True','Other','a2aS0000003f91XIAQ','a2aS0000003f91YIAQ');
INSERT INTO "Question_Dependency__c" VALUES(241,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8yBIAQ','a2aS0000003f8y0IAA');
INSERT INTO "Question_Dependency__c" VALUES(242,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8yBIAQ','a2aS0000003f8y4IAA');
INSERT INTO "Question_Dependency__c" VALUES(243,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8yBIAQ','a2aS0000003f8y9IAA');
INSERT INTO "Question_Dependency__c" VALUES(244,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8yBIAQ','a2aS0000003f8yCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(245,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8yeIAA','a2aS0000003f8ykIAA');
INSERT INTO "Question_Dependency__c" VALUES(246,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8yeIAA','a2aS0000003f8ylIAA');
INSERT INTO "Question_Dependency__c" VALUES(247,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8yBIAQ','a2aS0000003f8yEIAQ');
INSERT INTO "Question_Dependency__c" VALUES(248,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8pLIAQ','a2aS0000003f8pOIAQ');
INSERT INTO "Question_Dependency__c" VALUES(249,'0124P0000003S99QAE','True','Asian','a2aS0000003f8pLIAQ','a2aS0000003f8pRIAQ');
INSERT INTO "Question_Dependency__c" VALUES(250,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8pLIAQ','a2aS0000003f8pVIAQ');
INSERT INTO "Question_Dependency__c" VALUES(251,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8pLIAQ','a2aS0000003f8pXIAQ');
INSERT INTO "Question_Dependency__c" VALUES(252,'0124P0000003S99QAE','True','White','a2aS0000003f8pLIAQ','a2aS0000003f8phIAA');
INSERT INTO "Question_Dependency__c" VALUES(253,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8pLIAQ','a2aS0000003f8pjIAA');
INSERT INTO "Question_Dependency__c" VALUES(254,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8pLIAQ','a2aS0000003f8pnIAA');
INSERT INTO "Question_Dependency__c" VALUES(255,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8pRIAQ','a2aS0000003f8pSIAQ');
INSERT INTO "Question_Dependency__c" VALUES(256,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8pRIAQ','a2aS0000003f8pTIAQ');
INSERT INTO "Question_Dependency__c" VALUES(257,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8pRIAQ','a2aS0000003f8pUIAQ');
INSERT INTO "Question_Dependency__c" VALUES(258,'0124P0000003S99QAE','True','Other','a2aS0000003f8pVIAQ','a2aS0000003f8pWIAQ');
INSERT INTO "Question_Dependency__c" VALUES(259,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8pXIAQ','a2aS0000003f8pYIAQ');
INSERT INTO "Question_Dependency__c" VALUES(260,'0124P0000003S9AQAU','True','Master''s','a2aS0000003f8jzIAA','a2aS0000003f8k2IAA');
INSERT INTO "Question_Dependency__c" VALUES(261,'0124P0000003S9AQAU','True','Non-Degree','a2aS0000003f8jzIAA','a2aS0000003f8jyIAA');
INSERT INTO "Question_Dependency__c" VALUES(262,'0124P0000003S9AQAU','True','Master''s','a2aS0000003f8jzIAA','a2aS0000003f8k0IAA');
INSERT INTO "Question_Dependency__c" VALUES(263,'0124P0000003S9AQAU','True','Master''s','a2aS0000003f8jzIAA','a2aS0000003f8k1IAA');
INSERT INTO "Question_Dependency__c" VALUES(264,'0124P0000003S9AQAU','True','Master''s','a2aS0000003f8jzIAA','a2aS0000003f8k3IAA');
INSERT INTO "Question_Dependency__c" VALUES(265,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f9N8IAI','a2aS0000003f9MnIAI');
INSERT INTO "Question_Dependency__c" VALUES(266,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f9N8IAI','a2aS0000003f9MpIAI');
INSERT INTO "Question_Dependency__c" VALUES(267,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f9N8IAI','a2aS0000003f9MqIAI');
INSERT INTO "Question_Dependency__c" VALUES(268,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f9N8IAI','a2aS0000003f9MrIAI');
INSERT INTO "Question_Dependency__c" VALUES(269,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f9N8IAI','a2aS0000003f9MsIAI');
INSERT INTO "Question_Dependency__c" VALUES(270,'0124P0000003S99QAE','True','Asian','a2aS0000003f9N8IAI','a2aS0000003f9MuIAI');
INSERT INTO "Question_Dependency__c" VALUES(271,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8UvIAI','a2aS0000003f8UnIAI');
INSERT INTO "Question_Dependency__c" VALUES(272,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8UvIAI','a2aS0000003f8UwIAI');
INSERT INTO "Question_Dependency__c" VALUES(273,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8UvIAI','a2aS0000003f8UxIAI');
INSERT INTO "Question_Dependency__c" VALUES(274,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f9N6IAI','a2aS0000003f9N7IAI');
INSERT INTO "Question_Dependency__c" VALUES(275,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8UzIAI','a2aS0000003f8V0IAI');
INSERT INTO "Question_Dependency__c" VALUES(276,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8V3IAI','a2aS0000003f8UoIAI');
INSERT INTO "Question_Dependency__c" VALUES(277,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8V3IAI','a2aS0000003f8UpIAI');
INSERT INTO "Question_Dependency__c" VALUES(278,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8V3IAI','a2aS0000003f8UqIAI');
INSERT INTO "Question_Dependency__c" VALUES(279,'0124P0000003S99QAE','True','Other','a2aS0000003f8V4IAI','a2aS0000003f8V1IAI');
INSERT INTO "Question_Dependency__c" VALUES(280,'0124P0000003S99QAE','True','Other','a2aS0000003f8V5IAI','a2aS0000003f8UtIAI');
INSERT INTO "Question_Dependency__c" VALUES(281,'0124P0000003S9AQAU','True','Female','a2aS0000003f8V6IAI','a2aS0000003f8TcIAI');
INSERT INTO "Question_Dependency__c" VALUES(282,'0124P0000003S9AQAU','True','Female','a2aS0000003f8V6IAI','a2aS0000003f8TlIAI');
INSERT INTO "Question_Dependency__c" VALUES(283,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8V6IAI','a2aS0000003f8UgIAI');
INSERT INTO "Question_Dependency__c" VALUES(284,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8VBIAY','a2aS0000003f8VLIAY');
INSERT INTO "Question_Dependency__c" VALUES(285,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8VGIAY','a2aS0000003f8VEIAY');
INSERT INTO "Question_Dependency__c" VALUES(286,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8VGIAY','a2aS0000003f8VHIAY');
INSERT INTO "Question_Dependency__c" VALUES(287,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8VGIAY','a2aS0000003f8VJIAY');
INSERT INTO "Question_Dependency__c" VALUES(288,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8VNIAY','a2aS0000003f8VPIAY');
INSERT INTO "Question_Dependency__c" VALUES(289,'0124P0000003S98QAE','True','','a2aS0000003f8WDIAY','a2aS0000003f8WMIAY');
INSERT INTO "Question_Dependency__c" VALUES(290,'0124P0000003S98QAE','True','','a2aS0000003f8WDIAY','a2aS0000003f8WEIAY');
INSERT INTO "Question_Dependency__c" VALUES(291,'0124P0000003S98QAE','True','','a2aS0000003f8WDIAY','a2aS0000003f8WFIAY');
INSERT INTO "Question_Dependency__c" VALUES(292,'0124P0000003S98QAE','True','','a2aS0000003f8WDIAY','a2aS0000003f8WGIAY');
INSERT INTO "Question_Dependency__c" VALUES(293,'0124P0000003S98QAE','True','','a2aS0000003f8WDIAY','a2aS0000003f8WNIAY');
INSERT INTO "Question_Dependency__c" VALUES(294,'0124P0000003S9AQAU','True','Other','a2aS0000003f8X3IAI','a2aS0000003f8X2IAI');
INSERT INTO "Question_Dependency__c" VALUES(295,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WJIAY','a2aS0000003f8WDIAY');
INSERT INTO "Question_Dependency__c" VALUES(296,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WJIAY','a2aS0000003f8WHIAY');
INSERT INTO "Question_Dependency__c" VALUES(297,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WJIAY','a2aS0000003f8WIIAY');
INSERT INTO "Question_Dependency__c" VALUES(298,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WJIAY','a2aS0000003f8WKIAY');
INSERT INTO "Question_Dependency__c" VALUES(299,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WJIAY','a2aS0000003f8WLIAY');
INSERT INTO "Question_Dependency__c" VALUES(300,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WJIAY','a2aS0000003f8WMIAY');
INSERT INTO "Question_Dependency__c" VALUES(301,'0124P0000003S9AQAU','True','Other','a2aS0000003f8WQIAY','a2aS0000003f8WOIAY');
INSERT INTO "Question_Dependency__c" VALUES(302,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WUIAY','a2aS0000003f8WXIAY');
INSERT INTO "Question_Dependency__c" VALUES(303,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WYIAY','a2aS0000003f8WWIAY');
INSERT INTO "Question_Dependency__c" VALUES(304,'0124P0000003S98QAE','True','','a2aS0000003f8WZIAY','a2aS0000003f8WRIAY');
INSERT INTO "Question_Dependency__c" VALUES(305,'0124P0000003S98QAE','True','','a2aS0000003f8WZIAY','a2aS0000003f8WTIAY');
INSERT INTO "Question_Dependency__c" VALUES(306,'0124P0000003S98QAE','True','','a2aS0000003f8WZIAY','a2aS0000003f8WVIAY');
INSERT INTO "Question_Dependency__c" VALUES(307,'0124P0000003S98QAE','True','','a2aS0000003f8WZIAY','a2aS0000003f8WaIAI');
INSERT INTO "Question_Dependency__c" VALUES(308,'0124P0000003S98QAE','True','','a2aS0000003f8WZIAY','a2aS0000003f8WbIAI');
INSERT INTO "Question_Dependency__c" VALUES(309,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WjIAI','a2aS0000003f8WkIAI');
INSERT INTO "Question_Dependency__c" VALUES(310,'0124P0000003S99QAE','True','Other','a2aS0000003f8WkIAI','a2aS0000003f8WiIAI');
INSERT INTO "Question_Dependency__c" VALUES(311,'0124P0000003S9AQAU','True','Yes','a2aS0000003f95uIAA','a2aS0000003f95qIAA');
INSERT INTO "Question_Dependency__c" VALUES(312,'0124P0000003S9AQAU','True','Yes','a2aS0000003f95uIAA','a2aS0000003f95rIAA');
INSERT INTO "Question_Dependency__c" VALUES(313,'0124P0000003S9AQAU','True','Yes','a2aS0000003f95uIAA','a2aS0000003f95sIAA');
INSERT INTO "Question_Dependency__c" VALUES(314,'0124P0000003S9AQAU','True','Yes','a2aS0000003f95uIAA','a2aS0000003f95tIAA');
INSERT INTO "Question_Dependency__c" VALUES(315,'0124P0000003S9AQAU','True','Yes','a2aS0000003f95uIAA','a2aS0000003f95vIAA');
INSERT INTO "Question_Dependency__c" VALUES(316,'0124P0000003S9AQAU','True','Yes','a2aS0000003f95uIAA','a2aS0000003f95vIAA');
INSERT INTO "Question_Dependency__c" VALUES(317,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8X6IAI','a2aS0000003f8X5IAI');
INSERT INTO "Question_Dependency__c" VALUES(318,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ydIAA','a2aS0000003f8yfIAA');
INSERT INTO "Question_Dependency__c" VALUES(319,'0124P0000003S9AQAU','True','2','a2aS0000003f8YbIAI','a2aS0000003f8YTIAY');
INSERT INTO "Question_Dependency__c" VALUES(320,'0124P0000003S9AQAU','True','3','a2aS0000003f8YbIAI','a2aS0000003f8YSIAY');
INSERT INTO "Question_Dependency__c" VALUES(321,'0124P0000003S9AQAU','True','2','a2aS0000003f8YbIAI','a2aS0000003f8YSIAY');
INSERT INTO "Question_Dependency__c" VALUES(322,'0124P0000003S9AQAU','True','3','a2aS0000003f8YbIAI','a2aS0000003f8YTIAY');
INSERT INTO "Question_Dependency__c" VALUES(323,'0124P0000003S9AQAU','True','1','a2aS0000003f8YbIAI','a2aS0000003f8YTIAY');
INSERT INTO "Question_Dependency__c" VALUES(324,'0124P0000003S9AQAU','True','3','a2aS0000003f8YbIAI','a2aS0000003f8YUIAY');
INSERT INTO "Question_Dependency__c" VALUES(325,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8b8IAA','a2aS0000003f8b2IAA');
INSERT INTO "Question_Dependency__c" VALUES(326,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8b8IAA','a2aS0000003f8b3IAA');
INSERT INTO "Question_Dependency__c" VALUES(327,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8b8IAA','a2aS0000003f8b4IAA');
INSERT INTO "Question_Dependency__c" VALUES(328,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8b8IAA','a2aS0000003f8bBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(329,'0124P0000003S99QAE','True','Yes','a2aS0000003f8bJIAQ','a2aS0000003f8bMIAQ');
INSERT INTO "Question_Dependency__c" VALUES(330,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8lOIAQ','a2aS0000003f8lNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(331,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8lRIAQ','a2aS0000003f8lQIAQ');
INSERT INTO "Question_Dependency__c" VALUES(332,'0124P0000003S99QAE','True','St. Thomas Alumnus/a','a2aS0000003f8leIAA','a2aS0000003f8lPIAQ');
INSERT INTO "Question_Dependency__c" VALUES(333,'0124P0000003S99QAE','True','High School Counselor/Teacher','a2aS0000003f8leIAA','a2aS0000003f8lUIAQ');
INSERT INTO "Question_Dependency__c" VALUES(334,'0124P0000003S99QAE','True','Independent College Counselor','a2aS0000003f8leIAA','a2aS0000003f8lVIAQ');
INSERT INTO "Question_Dependency__c" VALUES(335,'0124P0000003S99QAE','True','Community Based Organization/College Access Group','a2aS0000003f8leIAA','a2aS0000003f8lbIAA');
INSERT INTO "Question_Dependency__c" VALUES(336,'0124P0000003S99QAE','True','Friend/Relative','a2aS0000003f8leIAA','a2aS0000003f8lcIAA');
INSERT INTO "Question_Dependency__c" VALUES(337,'0124P0000003S99QAE','True','Other','a2aS0000003f8leIAA','a2aS0000003f8ldIAA');
INSERT INTO "Question_Dependency__c" VALUES(338,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8TeIAI','a2aS0000003f8TfIAI');
INSERT INTO "Question_Dependency__c" VALUES(339,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8TlIAI','a2aS0000003f8ThIAI');
INSERT INTO "Question_Dependency__c" VALUES(340,'0124P0000003S99QAE','True','Friend/Relative','a2aS0000003f8TqIAI','a2aS0000003f8TmIAI');
INSERT INTO "Question_Dependency__c" VALUES(341,'0124P0000003S99QAE','True','St. Thomas Alumnus/a','a2aS0000003f8TqIAI','a2aS0000003f8TnIAI');
INSERT INTO "Question_Dependency__c" VALUES(342,'0124P0000003S99QAE','True','Other','a2aS0000003f8TqIAI','a2aS0000003f8ToIAI');
INSERT INTO "Question_Dependency__c" VALUES(343,'0124P0000003S99QAE','True','Independent College Counselor','a2aS0000003f8TqIAI','a2aS0000003f8TpIAI');
INSERT INTO "Question_Dependency__c" VALUES(344,'0124P0000003S99QAE','True','High School Counselor/Teacher','a2aS0000003f8TqIAI','a2aS0000003f8TrIAI');
INSERT INTO "Question_Dependency__c" VALUES(345,'0124P0000003S99QAE','True','Community Based Organization/College Access Group','a2aS0000003f8TqIAI','a2aS0000003f8TsIAI');
INSERT INTO "Question_Dependency__c" VALUES(346,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8U2IAI','a2aS0000003f8TwIAI');
INSERT INTO "Question_Dependency__c" VALUES(347,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8U2IAI','a2aS0000003f8TxIAI');
INSERT INTO "Question_Dependency__c" VALUES(348,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8wGIAQ','a2aS0000003f8w9IAA');
INSERT INTO "Question_Dependency__c" VALUES(349,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8wCIAQ','a2aS0000003f8wDIAQ');
INSERT INTO "Question_Dependency__c" VALUES(350,'0124P0000003S9AQAU','True','No','a2aS0000003f8wCIAQ','a2aS0000003f8wFIAQ');
INSERT INTO "Question_Dependency__c" VALUES(351,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8wGIAQ','a2aS0000003f8w8IAA');
INSERT INTO "Question_Dependency__c" VALUES(352,'0124P0000003S9AQAU','True','No','a2aS0000003f8wGIAQ','a2aS0000003f8wAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(353,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8YcIAI','a2aS0000003f8YlIAI');
INSERT INTO "Question_Dependency__c" VALUES(354,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8YhIAI','a2aS0000003f8YfIAI');
INSERT INTO "Question_Dependency__c" VALUES(355,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8YhIAI','a2aS0000003f8YiIAI');
INSERT INTO "Question_Dependency__c" VALUES(356,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8YhIAI','a2aS0000003f8YjIAI');
INSERT INTO "Question_Dependency__c" VALUES(357,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8YrIAI','a2aS0000003f8YpIAI');
INSERT INTO "Question_Dependency__c" VALUES(358,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8YuIAI','a2aS0000003f8YvIAI');
INSERT INTO "Question_Dependency__c" VALUES(359,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8YuIAI','a2aS0000003f8YwIAI');
INSERT INTO "Question_Dependency__c" VALUES(360,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8YuIAI','a2aS0000003f8ZGIAY');
INSERT INTO "Question_Dependency__c" VALUES(361,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8YyIAI','a2aS0000003f8YzIAI');
INSERT INTO "Question_Dependency__c" VALUES(362,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8Z2IAI','a2aS0000003f8ZHIAY');
INSERT INTO "Question_Dependency__c" VALUES(363,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8Z2IAI','a2aS0000003f8ZIIAY');
INSERT INTO "Question_Dependency__c" VALUES(364,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8Z2IAI','a2aS0000003f8ZJIAY');
INSERT INTO "Question_Dependency__c" VALUES(365,'0124P0000003S99QAE','True','Other','a2aS0000003f8Z3IAI','a2aS0000003f8Z0IAI');
INSERT INTO "Question_Dependency__c" VALUES(366,'0124P0000003S99QAE','True','Other','a2aS0000003f8Z4IAI','a2aS0000003f8YsIAI');
INSERT INTO "Question_Dependency__c" VALUES(367,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8Z5IAI','a2aS0000003f8Z9IAI');
INSERT INTO "Question_Dependency__c" VALUES(368,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8Z7IAI','a2aS0000003f8Z6IAI');
INSERT INTO "Question_Dependency__c" VALUES(369,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8Z8IAI','a2aS0000003f8YtIAI');
INSERT INTO "Question_Dependency__c" VALUES(370,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8Z8IAI','a2aS0000003f8YuIAI');
INSERT INTO "Question_Dependency__c" VALUES(371,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8Z8IAI','a2aS0000003f8YvIAI');
INSERT INTO "Question_Dependency__c" VALUES(372,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8Z8IAI','a2aS0000003f8YwIAI');
INSERT INTO "Question_Dependency__c" VALUES(373,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8Z8IAI','a2aS0000003f8YyIAI');
INSERT INTO "Question_Dependency__c" VALUES(374,'0124P0000003S99QAE','True','Asian','a2aS0000003f8Z8IAI','a2aS0000003f8Z2IAI');
INSERT INTO "Question_Dependency__c" VALUES(375,'0124P0000003S99QAE','True','White','a2aS0000003f8Z8IAI','a2aS0000003f8Z3IAI');
INSERT INTO "Question_Dependency__c" VALUES(376,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8Z8IAI','a2aS0000003f8ZGIAY');
INSERT INTO "Question_Dependency__c" VALUES(377,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8ZCIAY','a2aS0000003f8ZFIAY');
INSERT INTO "Question_Dependency__c" VALUES(378,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8Z8IAI','a2aS0000003f8ZKIAY');
INSERT INTO "Question_Dependency__c" VALUES(379,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ZBIAY','a2aS0000003f8Z4IAI');
INSERT INTO "Question_Dependency__c" VALUES(380,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8ZCIAY','a2aS0000003f8ZDIAY');
INSERT INTO "Question_Dependency__c" VALUES(381,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8ZCIAY','a2aS0000003f8ZLIAY');
INSERT INTO "Question_Dependency__c" VALUES(382,'0124P0000003S99QAE','True','Other','a2aS0000003f8ZKIAY','a2aS0000003f8YxIAI');
INSERT INTO "Question_Dependency__c" VALUES(383,'0124P0000003S98QAE','True','','a2aS0000003f8lhIAA','a2aS0000003f8liIAA');
INSERT INTO "Question_Dependency__c" VALUES(384,'0124P0000003S98QAE','True','','a2aS0000003f8lhIAA','a2aS0000003f8ljIAA');
INSERT INTO "Question_Dependency__c" VALUES(385,'0124P0000003S98QAE','True','','a2aS0000003f8lhIAA','a2aS0000003f8lkIAA');
INSERT INTO "Question_Dependency__c" VALUES(386,'0124P0000003S98QAE','True','','a2aS0000003f8lhIAA','a2aS0000003f8lnIAA');
INSERT INTO "Question_Dependency__c" VALUES(387,'0124P0000003S98QAE','True','','a2aS0000003f8lhIAA','a2aS0000003f8loIAA');
INSERT INTO "Question_Dependency__c" VALUES(388,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8lwIAA','a2aS0000003f8lqIAA');
INSERT INTO "Question_Dependency__c" VALUES(389,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8lwIAA','a2aS0000003f8lrIAA');
INSERT INTO "Question_Dependency__c" VALUES(390,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8lwIAA','a2aS0000003f8lsIAA');
INSERT INTO "Question_Dependency__c" VALUES(391,'0124P0000003S9AQAU','True','Yes','a2aS0000003f95YIAQ','a2aS0000003f95ZIAQ');
INSERT INTO "Question_Dependency__c" VALUES(392,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8irIAA','a2aS0000003f8idIAA');
INSERT INTO "Question_Dependency__c" VALUES(393,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8irIAA','a2aS0000003f8isIAA');
INSERT INTO "Question_Dependency__c" VALUES(394,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8irIAA','a2aS0000003f8itIAA');
INSERT INTO "Question_Dependency__c" VALUES(395,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8irIAA','a2aS0000003f8iuIAA');
INSERT INTO "Question_Dependency__c" VALUES(396,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8irIAA','a2aS0000003f8ivIAA');
INSERT INTO "Question_Dependency__c" VALUES(397,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ZgIAI','a2aS0000003f8ZdIAI');
INSERT INTO "Question_Dependency__c" VALUES(398,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ZgIAI','a2aS0000003f8ZeIAI');
INSERT INTO "Question_Dependency__c" VALUES(399,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ZgIAI','a2aS0000003f8ZfIAI');
INSERT INTO "Question_Dependency__c" VALUES(400,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ZgIAI','a2aS0000003f8ZjIAI');
INSERT INTO "Question_Dependency__c" VALUES(401,'0124P0000003S98QAE','True','','a2aS0000003f8eaIAA','a2aS0000003f8ebIAA');
INSERT INTO "Question_Dependency__c" VALUES(402,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MdIAI','a2aS0000003f9MPIAY');
INSERT INTO "Question_Dependency__c" VALUES(403,'0124P0000003S9AQAU','True','No','a2aS0000003f9MdIAI','a2aS0000003f9MQIAY');
INSERT INTO "Question_Dependency__c" VALUES(404,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MdIAI','a2aS0000003f9MSIAY');
INSERT INTO "Question_Dependency__c" VALUES(405,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MdIAI','a2aS0000003f9MZIAY');
INSERT INTO "Question_Dependency__c" VALUES(406,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MdIAI','a2aS0000003f9MTIAY');
INSERT INTO "Question_Dependency__c" VALUES(407,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MdIAI','a2aS0000003f9MUIAY');
INSERT INTO "Question_Dependency__c" VALUES(408,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MdIAI','a2aS0000003f9MWIAY');
INSERT INTO "Question_Dependency__c" VALUES(409,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MdIAI','a2aS0000003f9MiIAI');
INSERT INTO "Question_Dependency__c" VALUES(410,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8efIAA','a2aS0000003f8ecIAA');
INSERT INTO "Question_Dependency__c" VALUES(411,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8efIAA','a2aS0000003f8edIAA');
INSERT INTO "Question_Dependency__c" VALUES(412,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8efIAA','a2aS0000003f8eeIAA');
INSERT INTO "Question_Dependency__c" VALUES(413,'0124P0000003S98QAE','True','','a2aS0000003f8eiIAA','a2aS0000003f8ejIAA');
INSERT INTO "Question_Dependency__c" VALUES(414,'0124P0000003S98QAE','True','','a2aS0000003f8eiIAA','a2aS0000003f8ekIAA');
INSERT INTO "Question_Dependency__c" VALUES(415,'0124P0000003S98QAE','True','','a2aS0000003f8eiIAA','a2aS0000003f8elIAA');
INSERT INTO "Question_Dependency__c" VALUES(416,'0124P0000003S98QAE','True','','a2aS0000003f8eiIAA','a2aS0000003f8eoIAA');
INSERT INTO "Question_Dependency__c" VALUES(417,'0124P0000003S98QAE','True','','a2aS0000003f8eiIAA','a2aS0000003f8epIAA');
INSERT INTO "Question_Dependency__c" VALUES(418,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8d5IAA','a2aS0000003f8d2IAA');
INSERT INTO "Question_Dependency__c" VALUES(419,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8d5IAA','a2aS0000003f8d3IAA');
INSERT INTO "Question_Dependency__c" VALUES(420,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8d5IAA','a2aS0000003f8d4IAA');
INSERT INTO "Question_Dependency__c" VALUES(421,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8d5IAA','a2aS0000003f8d8IAA');
INSERT INTO "Question_Dependency__c" VALUES(422,'0124P0000003S9AQAU','True','No','a2aS0000003f8dLIAQ','a2aS0000003f8dMIAQ');
INSERT INTO "Question_Dependency__c" VALUES(423,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8tuIAA','a2aS0000003f8tvIAA');
INSERT INTO "Question_Dependency__c" VALUES(424,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8tyIAA','a2aS0000003f8twIAA');
INSERT INTO "Question_Dependency__c" VALUES(425,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8tyIAA','a2aS0000003f8txIAA');
INSERT INTO "Question_Dependency__c" VALUES(426,'0124P0000003S9AQAU','True','Work','a2aS0000003f8tyIAA','a2aS0000003f8tzIAA');
INSERT INTO "Question_Dependency__c" VALUES(427,'0124P0000003S9AQAU','True','Home','a2aS0000003f8tyIAA','a2aS0000003f8u0IAA');
INSERT INTO "Question_Dependency__c" VALUES(428,'0124P0000003S99QAE','True','Other','a2aS0000003f8vCIAQ','a2aS0000003f8vDIAQ');
INSERT INTO "Question_Dependency__c" VALUES(429,'0124P0000003S9AQAU','True','A different address','a2aS0000003f9MiIAI','a2aS0000003f9MPIAY');
INSERT INTO "Question_Dependency__c" VALUES(430,'0124P0000003S9AQAU','True','A different address','a2aS0000003f9MiIAI','a2aS0000003f9MgIAI');
INSERT INTO "Question_Dependency__c" VALUES(431,'0124P0000003S9AQAU','True','A different address','a2aS0000003f9MiIAI','a2aS0000003f9MhIAI');
INSERT INTO "Question_Dependency__c" VALUES(432,'0124P0000003S9AQAU','True','Non-Degree','a2aS0000003f8vIIAQ','a2aS0000003f8vLIAQ');
INSERT INTO "Question_Dependency__c" VALUES(433,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8h0IAA','a2aS0000003f8gyIAA');
INSERT INTO "Question_Dependency__c" VALUES(434,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8h0IAA','a2aS0000003f8h1IAA');
INSERT INTO "Question_Dependency__c" VALUES(435,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8hEIAQ','a2aS0000003f8hFIAQ');
INSERT INTO "Question_Dependency__c" VALUES(436,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8h0IAA','a2aS0000003f8h5IAA');
INSERT INTO "Question_Dependency__c" VALUES(437,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8h4IAA','a2aS0000003f8hBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(438,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8hCIAQ','a2aS0000003f8h9IAA');
INSERT INTO "Question_Dependency__c" VALUES(439,'0124P0000003S9AQAU','True','Home','a2aS0000003f8hJIAQ','a2aS0000003f8hGIAQ');
INSERT INTO "Question_Dependency__c" VALUES(440,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8hJIAQ','a2aS0000003f8hHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(441,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8hJIAQ','a2aS0000003f8hIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(442,'0124P0000003S9AQAU','True','Work','a2aS0000003f8hJIAQ','a2aS0000003f8hKIAQ');
INSERT INTO "Question_Dependency__c" VALUES(443,'0124P0000003S9AQAU','True','District Partnerships','a2aS0000003f8wHIAQ','a2aS0000003f8wIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(444,'0124P0000003S99QAE','True','Special Education;Teacher Education','a2aS0000003f8wHIAQ','a2aS0000003f8wJIAQ');
INSERT INTO "Question_Dependency__c" VALUES(445,'0124P0000003S9AQAU','True','Special Education','a2aS0000003f8wHIAQ','a2aS0000003f8wLIAQ');
INSERT INTO "Question_Dependency__c" VALUES(446,'0124P0000003S9AQAU','True','Educational Leadership','a2aS0000003f8wHIAQ','a2aS0000003f8wMIAQ');
INSERT INTO "Question_Dependency__c" VALUES(447,'0124P0000003S9AQAU','True','Teacher Education','a2aS0000003f8wHIAQ','a2aS0000003f8wRIAQ');
INSERT INTO "Question_Dependency__c" VALUES(448,'0124P0000003S9AQAU','True','Teacher Residency','a2aS0000003f8wIIAQ','a2aS0000003f8wKIAQ');
INSERT INTO "Question_Dependency__c" VALUES(449,'0124P0000003S9AQAU','True','No','a2aS0000003f8wJIAQ','a2aS0000003f8wLIAQ');
INSERT INTO "Question_Dependency__c" VALUES(450,'0124P0000003S99QAE','True','Other','a2aS0000003f9MnIAI','a2aS0000003f9MoIAI');
INSERT INTO "Question_Dependency__c" VALUES(451,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MpIAI','a2aS0000003f9MqIAI');
INSERT INTO "Question_Dependency__c" VALUES(452,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MpIAI','a2aS0000003f9MsIAI');
INSERT INTO "Question_Dependency__c" VALUES(453,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MpIAI','a2aS0000003f9NCIAY');
INSERT INTO "Question_Dependency__c" VALUES(454,'0124P0000003S9AQAU','True','Non-Degree','a2aS0000003f8bVIAQ','a2aS0000003f8bTIAQ');
INSERT INTO "Question_Dependency__c" VALUES(455,'0124P0000003S9AQAU','True','Master in the Study of Law (MSL)','a2aS0000003f8bVIAQ','a2aS0000003f8bUIAQ');
INSERT INTO "Question_Dependency__c" VALUES(456,'0124P0000003S9AQAU','True','Master of Laws (LLM)','a2aS0000003f8bVIAQ','a2aS0000003f8bWIAQ');
INSERT INTO "Question_Dependency__c" VALUES(457,'0124P0000003S99QAE','True','Master in the Study of Law (MSL);Master of Laws (LLM)','a2aS0000003f8bVIAQ','a2aS0000003f8bXIAQ');
INSERT INTO "Question_Dependency__c" VALUES(458,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f9MuIAI','a2aS0000003f9MxIAI');
INSERT INTO "Question_Dependency__c" VALUES(459,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f9MuIAI','a2aS0000003f9NAIAY');
INSERT INTO "Question_Dependency__c" VALUES(460,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f9MuIAI','a2aS0000003f9NBIAY');
INSERT INTO "Question_Dependency__c" VALUES(461,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8iFIAQ','a2aS0000003f8i5IAA');
INSERT INTO "Question_Dependency__c" VALUES(462,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8iFIAQ','a2aS0000003f8i9IAA');
INSERT INTO "Question_Dependency__c" VALUES(463,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8iFIAQ','a2aS0000003f8iIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(464,'0124P0000003S98QAE','True','','a2aS0000003f8iGIAQ','a2aS0000003f8iEIAQ');
INSERT INTO "Question_Dependency__c" VALUES(465,'0124P0000003S98QAE','True','','a2aS0000003f8iGIAQ','a2aS0000003f8i4IAA');
INSERT INTO "Question_Dependency__c" VALUES(466,'0124P0000003S98QAE','True','','a2aS0000003f8iGIAQ','a2aS0000003f8iAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(467,'0124P0000003S98QAE','True','','a2aS0000003f8iGIAQ','a2aS0000003f8iBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(468,'0124P0000003S98QAE','True','','a2aS0000003f8iGIAQ','a2aS0000003f8iHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(469,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f9MyIAI','a2aS0000003f9MzIAI');
INSERT INTO "Question_Dependency__c" VALUES(470,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8gQIAQ','a2aS0000003f8gYIAQ');
INSERT INTO "Question_Dependency__c" VALUES(471,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8gQIAQ','a2aS0000003f8gkIAA');
INSERT INTO "Question_Dependency__c" VALUES(472,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8gQIAQ','a2aS0000003f8glIAA');
INSERT INTO "Question_Dependency__c" VALUES(473,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8gRIAQ','a2aS0000003f8gUIAQ');
INSERT INTO "Question_Dependency__c" VALUES(474,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8gRIAQ','a2aS0000003f8gfIAA');
INSERT INTO "Question_Dependency__c" VALUES(475,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8gRIAQ','a2aS0000003f8gmIAA');
INSERT INTO "Question_Dependency__c" VALUES(476,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8gSIAQ','a2aS0000003f8giIAA');
INSERT INTO "Question_Dependency__c" VALUES(477,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8gZIAQ','a2aS0000003f8goIAA');
INSERT INTO "Question_Dependency__c" VALUES(478,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8gbIAA','a2aS0000003f8grIAA');
INSERT INTO "Question_Dependency__c" VALUES(479,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8gcIAA','a2aS0000003f8gVIAQ');
INSERT INTO "Question_Dependency__c" VALUES(480,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8gcIAA','a2aS0000003f8gXIAQ');
INSERT INTO "Question_Dependency__c" VALUES(481,'0124P0000003S99QAE','True','Other','a2aS0000003f8gdIAA','a2aS0000003f8geIAA');
INSERT INTO "Question_Dependency__c" VALUES(482,'0124P0000003S99QAE','True','Other','a2aS0000003f8ggIAA','a2aS0000003f8gjIAA');
INSERT INTO "Question_Dependency__c" VALUES(483,'0124P0000003S99QAE','True','Other','a2aS0000003f8ghIAA','a2aS0000003f8gnIAA');
INSERT INTO "Question_Dependency__c" VALUES(484,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f9N0IAI','a2aS0000003f9N1IAI');
INSERT INTO "Question_Dependency__c" VALUES(485,'0124P0000003S99QAE','True','Asian','a2aS0000003f8gpIAA','a2aS0000003f8gQIAQ');
INSERT INTO "Question_Dependency__c" VALUES(486,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8gpIAA','a2aS0000003f8gVIAQ');
INSERT INTO "Question_Dependency__c" VALUES(487,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8gpIAA','a2aS0000003f8gZIAQ');
INSERT INTO "Question_Dependency__c" VALUES(488,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8gpIAA','a2aS0000003f8gaIAA');
INSERT INTO "Question_Dependency__c" VALUES(489,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8gpIAA','a2aS0000003f8gcIAA');
INSERT INTO "Question_Dependency__c" VALUES(490,'0124P0000003S99QAE','True','White','a2aS0000003f8gpIAA','a2aS0000003f8gdIAA');
INSERT INTO "Question_Dependency__c" VALUES(491,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8gpIAA','a2aS0000003f8ghIAA');
INSERT INTO "Question_Dependency__c" VALUES(492,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8pbIAA','a2aS0000003f8pcIAA');
INSERT INTO "Question_Dependency__c" VALUES(493,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8pZIAQ','a2aS0000003f8plIAA');
INSERT INTO "Question_Dependency__c" VALUES(494,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8pZIAQ','a2aS0000003f8pmIAA');
INSERT INTO "Question_Dependency__c" VALUES(495,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8paIAA','a2aS0000003f8pNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(496,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8pgIAA','a2aS0000003f8peIAA');
INSERT INTO "Question_Dependency__c" VALUES(497,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8pgIAA','a2aS0000003f8pfIAA');
INSERT INTO "Question_Dependency__c" VALUES(498,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8pgIAA','a2aS0000003f8pkIAA');
INSERT INTO "Question_Dependency__c" VALUES(499,'0124P0000003S99QAE','True','Other','a2aS0000003f8phIAA','a2aS0000003f8piIAA');
INSERT INTO "Question_Dependency__c" VALUES(500,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8pjIAA','a2aS0000003f8pOIAQ');
INSERT INTO "Question_Dependency__c" VALUES(501,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8pjIAA','a2aS0000003f8pQIAQ');
INSERT INTO "Question_Dependency__c" VALUES(502,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vuIAA','a2aS0000003f8vvIAA');
INSERT INTO "Question_Dependency__c" VALUES(503,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vuIAA','a2aS0000003f8vwIAA');
INSERT INTO "Question_Dependency__c" VALUES(504,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vuIAA','a2aS0000003f8vxIAA');
INSERT INTO "Question_Dependency__c" VALUES(505,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vuIAA','a2aS0000003f8vyIAA');
INSERT INTO "Question_Dependency__c" VALUES(506,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vuIAA','a2aS0000003f8vzIAA');
INSERT INTO "Question_Dependency__c" VALUES(507,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vuIAA','a2aS0000003f8w0IAA');
INSERT INTO "Question_Dependency__c" VALUES(508,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vuIAA','a2aS0000003f8w1IAA');
INSERT INTO "Question_Dependency__c" VALUES(509,'0124P0000003S9AQAU','True','No','a2aS0000003f8iyIAA','a2aS0000003f8j0IAA');
INSERT INTO "Question_Dependency__c" VALUES(510,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8bhIAA','a2aS0000003f8biIAA');
INSERT INTO "Question_Dependency__c" VALUES(511,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8bhIAA','a2aS0000003f8bjIAA');
INSERT INTO "Question_Dependency__c" VALUES(512,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8bhIAA','a2aS0000003f8bkIAA');
INSERT INTO "Question_Dependency__c" VALUES(513,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8bhIAA','a2aS0000003f8brIAA');
INSERT INTO "Question_Dependency__c" VALUES(514,'0124P0000003S99QAE','True','Other','a2aS0000003f8r1IAA','a2aS0000003f8r2IAA');
INSERT INTO "Question_Dependency__c" VALUES(515,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8r7IAA','a2aS0000003f8rAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(516,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8r7IAA','a2aS0000003f8rBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(517,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8r7IAA','a2aS0000003f8rCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(518,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8rDIAQ','a2aS0000003f8rEIAQ');
INSERT INTO "Question_Dependency__c" VALUES(519,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8rGIAQ','a2aS0000003f8r8IAA');
INSERT INTO "Question_Dependency__c" VALUES(520,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8rGIAQ','a2aS0000003f8r9IAA');
INSERT INTO "Question_Dependency__c" VALUES(521,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8rIIAQ','a2aS0000003f8r6IAA');
INSERT INTO "Question_Dependency__c" VALUES(522,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8rGIAQ','a2aS0000003f8rHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(523,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8rIIAQ','a2aS0000003f8r3IAA');
INSERT INTO "Question_Dependency__c" VALUES(524,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8rIIAQ','a2aS0000003f8r4IAA');
INSERT INTO "Question_Dependency__c" VALUES(525,'0124P0000003S99QAE','True','Asian','a2aS0000003f8rIIAQ','a2aS0000003f8r7IAA');
INSERT INTO "Question_Dependency__c" VALUES(526,'0124P0000003S99QAE','True','Asian','a2aS0000003f8rIIAQ','a2aS0000003f8rAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(527,'0124P0000003S99QAE','True','Asian','a2aS0000003f8rIIAQ','a2aS0000003f8rBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(528,'0124P0000003S99QAE','True','Asian','a2aS0000003f8rIIAQ','a2aS0000003f8rCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(529,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8rIIAQ','a2aS0000003f8rNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(530,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8dpIAA','a2aS0000003f8e7IAA');
INSERT INTO "Question_Dependency__c" VALUES(531,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8dpIAA','a2aS0000003f8e4IAA');
INSERT INTO "Question_Dependency__c" VALUES(532,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8dpIAA','a2aS0000003f8e5IAA');
INSERT INTO "Question_Dependency__c" VALUES(533,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8dpIAA','a2aS0000003f8e6IAA');
INSERT INTO "Question_Dependency__c" VALUES(534,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8dpIAA','a2aS0000003f8e9IAA');
INSERT INTO "Question_Dependency__c" VALUES(535,'0124P0000003S99QAE','True','Asian','a2aS0000003f8dpIAA','a2aS0000003f8eDIAQ');
INSERT INTO "Question_Dependency__c" VALUES(536,'0124P0000003S99QAE','True','White','a2aS0000003f8dpIAA','a2aS0000003f8eEIAQ');
INSERT INTO "Question_Dependency__c" VALUES(537,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9NDIAY','a2aS0000003f9MtIAI');
INSERT INTO "Question_Dependency__c" VALUES(538,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9NDIAY','a2aS0000003f9MwIAI');
INSERT INTO "Question_Dependency__c" VALUES(539,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9NDIAY','a2aS0000003f9NEIAY');
INSERT INTO "Question_Dependency__c" VALUES(540,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8dsIAA','a2aS0000003f8eFIAQ');
INSERT INTO "Question_Dependency__c" VALUES(541,'0124P0000003S98QAE','True','','a2aS0000003f95cIAA','a2aS0000003f95aIAA');
INSERT INTO "Question_Dependency__c" VALUES(542,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8dtIAA','a2aS0000003f8duIAA');
INSERT INTO "Question_Dependency__c" VALUES(543,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8dtIAA','a2aS0000003f8dwIAA');
INSERT INTO "Question_Dependency__c" VALUES(544,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8dtIAA','a2aS0000003f8e2IAA');
INSERT INTO "Question_Dependency__c" VALUES(545,'0124P0000003S98QAE','True','','a2aS0000003f95cIAA','a2aS0000003f95bIAA');
INSERT INTO "Question_Dependency__c" VALUES(546,'0124P0000003S98QAE','True','','a2aS0000003f95cIAA','a2aS0000003f95dIAA');
INSERT INTO "Question_Dependency__c" VALUES(547,'0124P0000003S98QAE','True','','a2aS0000003f95cIAA','a2aS0000003f95eIAA');
INSERT INTO "Question_Dependency__c" VALUES(548,'0124P0000003S98QAE','True','','a2aS0000003f95cIAA','a2aS0000003f95fIAA');
INSERT INTO "Question_Dependency__c" VALUES(549,'0124P0000003S99QAE','True','Other','a2aS0000003f8e1IAA','a2aS0000003f8e8IAA');
INSERT INTO "Question_Dependency__c" VALUES(550,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8e5IAA','a2aS0000003f8dxIAA');
INSERT INTO "Question_Dependency__c" VALUES(551,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8e5IAA','a2aS0000003f8e6IAA');
INSERT INTO "Question_Dependency__c" VALUES(552,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8e5IAA','a2aS0000003f8e7IAA');
INSERT INTO "Question_Dependency__c" VALUES(553,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8e9IAA','a2aS0000003f8eAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(554,'0124P0000003S99QAE','True','Other','a2aS0000003f9NFIAY','a2aS0000003f9NGIAY');
INSERT INTO "Question_Dependency__c" VALUES(555,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8eDIAQ','a2aS0000003f8dyIAA');
INSERT INTO "Question_Dependency__c" VALUES(556,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8eDIAQ','a2aS0000003f8dzIAA');
INSERT INTO "Question_Dependency__c" VALUES(557,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8eDIAQ','a2aS0000003f8e0IAA');
INSERT INTO "Question_Dependency__c" VALUES(558,'0124P0000003S99QAE','True','Other','a2aS0000003f8eEIAQ','a2aS0000003f8eBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(559,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8eMIAQ','a2aS0000003f8eKIAQ');
INSERT INTO "Question_Dependency__c" VALUES(560,'0124P0000003S99QAE','True','Other','a2aS0000003f8eFIAQ','a2aS0000003f8e3IAA');
INSERT INTO "Question_Dependency__c" VALUES(561,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8eGIAQ','a2aS0000003f8dqIAA');
INSERT INTO "Question_Dependency__c" VALUES(562,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8eHIAQ','a2aS0000003f8eRIAQ');
INSERT INTO "Question_Dependency__c" VALUES(563,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8eMIAQ','a2aS0000003f8eNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(564,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8eMIAQ','a2aS0000003f8ePIAQ');
INSERT INTO "Question_Dependency__c" VALUES(565,'0124P0000003S99QAE','True','Other','a2aS0000003f8mxIAA','a2aS0000003f8mwIAA');
INSERT INTO "Question_Dependency__c" VALUES(566,'0124P0000003S99QAE','True','Alumni','a2aS0000003f8mxIAA','a2aS0000003f8myIAA');
INSERT INTO "Question_Dependency__c" VALUES(567,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9NIIAY','a2aS0000003f9NQIAY');
INSERT INTO "Question_Dependency__c" VALUES(568,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8naIAA','a2aS0000003f8nXIAQ');
INSERT INTO "Question_Dependency__c" VALUES(569,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8naIAA','a2aS0000003f8ndIAA');
INSERT INTO "Question_Dependency__c" VALUES(570,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8naIAA','a2aS0000003f8nfIAA');
INSERT INTO "Question_Dependency__c" VALUES(571,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ncIAA','a2aS0000003f8ngIAA');
INSERT INTO "Question_Dependency__c" VALUES(572,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8nmIAA','a2aS0000003f8nkIAA');
INSERT INTO "Question_Dependency__c" VALUES(573,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8noIAA','a2aS0000003f8nnIAA');
INSERT INTO "Question_Dependency__c" VALUES(574,'0124P0000003S9AQAU','True','Work','a2aS0000003f8noIAA','a2aS0000003f8npIAA');
INSERT INTO "Question_Dependency__c" VALUES(575,'0124P0000003S9AQAU','True','Home','a2aS0000003f8noIAA','a2aS0000003f8nqIAA');
INSERT INTO "Question_Dependency__c" VALUES(576,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8noIAA','a2aS0000003f8nrIAA');
INSERT INTO "Question_Dependency__c" VALUES(577,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8mJIAQ','a2aS0000003f8mKIAQ');
INSERT INTO "Question_Dependency__c" VALUES(578,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8mLIAQ','a2aS0000003f8mMIAQ');
INSERT INTO "Question_Dependency__c" VALUES(579,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8mNIAQ','a2aS0000003f8mOIAQ');
INSERT INTO "Question_Dependency__c" VALUES(580,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8ZRIAY','a2aS0000003f8ZPIAY');
INSERT INTO "Question_Dependency__c" VALUES(581,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8mPIAQ','a2aS0000003f8mQIAQ');
INSERT INTO "Question_Dependency__c" VALUES(582,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8mRIAQ','a2aS0000003f8mSIAQ');
INSERT INTO "Question_Dependency__c" VALUES(583,'0124P0000003S9AQAU','True','Home','a2aS0000003f8ZRIAY','a2aS0000003f8ZOIAY');
INSERT INTO "Question_Dependency__c" VALUES(584,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8ZRIAY','a2aS0000003f8ZQIAY');
INSERT INTO "Question_Dependency__c" VALUES(585,'0124P0000003S9AQAU','True','Work','a2aS0000003f8ZRIAY','a2aS0000003f8ZSIAY');
INSERT INTO "Question_Dependency__c" VALUES(586,'0124P0000003S9AQAU','True','Completed','a2aS0000003f8m0IAA','a2aS0000003f8mBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(587,'0124P0000003S9AQAU','True','Not Completed','a2aS0000003f8m0IAA','a2aS0000003f8mHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(588,'0124P0000003S9AQAU','True','Completed','a2aS0000003f8m1IAA','a2aS0000003f8m9IAA');
INSERT INTO "Question_Dependency__c" VALUES(589,'0124P0000003S9AQAU','True','Not Completed','a2aS0000003f8m1IAA','a2aS0000003f8mGIAQ');
INSERT INTO "Question_Dependency__c" VALUES(590,'0124P0000003S9AQAU','True','Completed','a2aS0000003f8m2IAA','a2aS0000003f8mCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(591,'0124P0000003S9AQAU','True','Not Completed','a2aS0000003f8m2IAA','a2aS0000003f8mIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(592,'0124P0000003S99QAE','True','Completed','a2aS0000003f8m4IAA','a2aS0000003f8m7IAA');
INSERT INTO "Question_Dependency__c" VALUES(593,'0124P0000003S9AQAU','True','Not Completed','a2aS0000003f8m4IAA','a2aS0000003f8mDIAQ');
INSERT INTO "Question_Dependency__c" VALUES(594,'0124P0000003S9AQAU','True','Completed','a2aS0000003f8m5IAA','a2aS0000003f8m8IAA');
INSERT INTO "Question_Dependency__c" VALUES(595,'0124P0000003S9AQAU','True','Not Completed','a2aS0000003f8m5IAA','a2aS0000003f8mFIAQ');
INSERT INTO "Question_Dependency__c" VALUES(596,'0124P0000003S9AQAU','True','Completed','a2aS0000003f8m6IAA','a2aS0000003f8mAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(597,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8n5IAA','a2aS0000003f8nCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(598,'0124P0000003S9AQAU','True','Not Completed','a2aS0000003f8m6IAA','a2aS0000003f8mEIAQ');
INSERT INTO "Question_Dependency__c" VALUES(599,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8n2IAA','a2aS0000003f8nGIAQ');
INSERT INTO "Question_Dependency__c" VALUES(600,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8n2IAA','a2aS0000003f8nHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(601,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9NPIAY','a2aS0000003f9NKIAY');
INSERT INTO "Question_Dependency__c" VALUES(602,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9NPIAY','a2aS0000003f9NLIAY');
INSERT INTO "Question_Dependency__c" VALUES(603,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9NPIAY','a2aS0000003f9NMIAY');
INSERT INTO "Question_Dependency__c" VALUES(604,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8n9IAA','a2aS0000003f8n3IAA');
INSERT INTO "Question_Dependency__c" VALUES(605,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8n9IAA','a2aS0000003f8nAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(606,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8n9IAA','a2aS0000003f8nMIAQ');
INSERT INTO "Question_Dependency__c" VALUES(607,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8nBIAQ','a2aS0000003f8nLIAQ');
INSERT INTO "Question_Dependency__c" VALUES(608,'0124P0000003S99QAE','True','Other','a2aS0000003f8nFIAQ','a2aS0000003f8nIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(609,'0124P0000003S99QAE','True','Other','a2aS0000003f8nJIAQ','a2aS0000003f8n4IAA');
INSERT INTO "Question_Dependency__c" VALUES(610,'0124P0000003S99QAE','True','Other','a2aS0000003f8nKIAQ','a2aS0000003f8n8IAA');
INSERT INTO "Question_Dependency__c" VALUES(611,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8nOIAQ','a2aS0000003f8n7IAA');
INSERT INTO "Question_Dependency__c" VALUES(612,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8nOIAQ','a2aS0000003f8nNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(613,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8nOIAQ','a2aS0000003f8nPIAQ');
INSERT INTO "Question_Dependency__c" VALUES(614,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8nQIAQ','a2aS0000003f8n6IAA');
INSERT INTO "Question_Dependency__c" VALUES(615,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8nSIAQ','a2aS0000003f8nKIAQ');
INSERT INTO "Question_Dependency__c" VALUES(616,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8nTIAQ','a2aS0000003f8n2IAA');
INSERT INTO "Question_Dependency__c" VALUES(617,'0124P0000003S99QAE','True','Asian','a2aS0000003f8nTIAQ','a2aS0000003f8n9IAA');
INSERT INTO "Question_Dependency__c" VALUES(618,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8nTIAQ','a2aS0000003f8nQIAQ');
INSERT INTO "Question_Dependency__c" VALUES(619,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8nTIAQ','a2aS0000003f8nDIAQ');
INSERT INTO "Question_Dependency__c" VALUES(620,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8nTIAQ','a2aS0000003f8nFIAQ');
INSERT INTO "Question_Dependency__c" VALUES(621,'0124P0000003S99QAE','True','White','a2aS0000003f8nTIAQ','a2aS0000003f8nJIAQ');
INSERT INTO "Question_Dependency__c" VALUES(622,'0124P0000003S9AQAU','True','Catholic Studies','a2aS0000003f8fHIAQ','a2aS0000003f8fGIAQ');
INSERT INTO "Question_Dependency__c" VALUES(623,'0124P0000003S99QAE','True','Art History / Museum Studies;Catholic Studies;English;Spanish;Music Education','a2aS0000003f8fHIAQ','a2aS0000003f8fJIAQ');
INSERT INTO "Question_Dependency__c" VALUES(624,'0124P0000003S9AQAU','True','Diversity Leadership','a2aS0000003f8fHIAQ','a2aS0000003f8fMIAQ');
INSERT INTO "Question_Dependency__c" VALUES(625,'0124P0000003S9AQAU','True','Non-Degree','a2aS0000003f8fJIAQ','a2aS0000003f8fIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(626,'0124P0000003S9AQAU','True','Home','a2aS0000003f8ppIAA','a2aS0000003f8poIAA');
INSERT INTO "Question_Dependency__c" VALUES(627,'0124P0000003S9AQAU','True','Work','a2aS0000003f8ppIAA','a2aS0000003f8pqIAA');
INSERT INTO "Question_Dependency__c" VALUES(628,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8ppIAA','a2aS0000003f8prIAA');
INSERT INTO "Question_Dependency__c" VALUES(629,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8ppIAA','a2aS0000003f8psIAA');
INSERT INTO "Question_Dependency__c" VALUES(630,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ptIAA','a2aS0000003f8puIAA');
INSERT INTO "Question_Dependency__c" VALUES(631,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8faIAA','a2aS0000003f8fZIAQ');
INSERT INTO "Question_Dependency__c" VALUES(632,'0124P0000003S9AQAU','True','No','a2aS0000003f8rvIAA','a2aS0000003f8rwIAA');
INSERT INTO "Question_Dependency__c" VALUES(633,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8rvIAA','a2aS0000003f8s0IAA');
INSERT INTO "Question_Dependency__c" VALUES(634,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8s1IAA','a2aS0000003f8s4IAA');
INSERT INTO "Question_Dependency__c" VALUES(635,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8rvIAA','a2aS0000003f8s3IAA');
INSERT INTO "Question_Dependency__c" VALUES(636,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9NUIAY','a2aS0000003f9NVIAY');
INSERT INTO "Question_Dependency__c" VALUES(637,'0124P0000003S9AQAU','True','No','a2aS0000003f8s1IAA','a2aS0000003f8ryIAA');
INSERT INTO "Question_Dependency__c" VALUES(638,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8s1IAA','a2aS0000003f8s5IAA');
INSERT INTO "Question_Dependency__c" VALUES(639,'0124P0000003S9AQAU','True','No','a2aS0000003f8s7IAA','a2aS0000003f8rzIAA');
INSERT INTO "Question_Dependency__c" VALUES(640,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8s7IAA','a2aS0000003f8s2IAA');
INSERT INTO "Question_Dependency__c" VALUES(641,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8s7IAA','a2aS0000003f8s6IAA');
INSERT INTO "Question_Dependency__c" VALUES(642,'0124P0000003S98QAE','True','','a2aS0000003f8qMIAQ','a2aS0000003f8qLIAQ');
INSERT INTO "Question_Dependency__c" VALUES(643,'0124P0000003S98QAE','True','','a2aS0000003f8qMIAQ','a2aS0000003f8qUIAQ');
INSERT INTO "Question_Dependency__c" VALUES(644,'0124P0000003S98QAE','True','','a2aS0000003f8qMIAQ','a2aS0000003f8qVIAQ');
INSERT INTO "Question_Dependency__c" VALUES(645,'0124P0000003S98QAE','True','','a2aS0000003f8qMIAQ','a2aS0000003f8qWIAQ');
INSERT INTO "Question_Dependency__c" VALUES(646,'0124P0000003S98QAE','True','','a2aS0000003f8qMIAQ','a2aS0000003f8qXIAQ');
INSERT INTO "Question_Dependency__c" VALUES(647,'0124P0000003S9AQAU','True','Home','a2aS0000003f9NZIAY','a2aS0000003f9NWIAY');
INSERT INTO "Question_Dependency__c" VALUES(648,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f9NZIAY','a2aS0000003f9NXIAY');
INSERT INTO "Question_Dependency__c" VALUES(649,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f9NZIAY','a2aS0000003f9NYIAY');
INSERT INTO "Question_Dependency__c" VALUES(650,'0124P0000003S9AQAU','True','Work Phone','a2aS0000003f9NZIAY','a2aS0000003f9NaIAI');
INSERT INTO "Question_Dependency__c" VALUES(651,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8qYIAQ','a2aS0000003f8qPIAQ');
INSERT INTO "Question_Dependency__c" VALUES(652,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8qYIAQ','a2aS0000003f8qQIAQ');
INSERT INTO "Question_Dependency__c" VALUES(653,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8qYIAQ','a2aS0000003f8qRIAQ');
INSERT INTO "Question_Dependency__c" VALUES(654,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8qkIAA','a2aS0000003f8qlIAA');
INSERT INTO "Question_Dependency__c" VALUES(655,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8q8IAA','a2aS0000003f8q9IAA');
INSERT INTO "Question_Dependency__c" VALUES(656,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8q8IAA','a2aS0000003f8qEIAQ');
INSERT INTO "Question_Dependency__c" VALUES(657,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8q8IAA','a2aS0000003f8qAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(658,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8q8IAA','a2aS0000003f8qBIAQ');
INSERT INTO "Question_Dependency__c" VALUES(659,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8q8IAA','a2aS0000003f8qCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(660,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8pBIAQ','a2aS0000003f8p9IAA');
INSERT INTO "Question_Dependency__c" VALUES(661,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8pEIAQ','a2aS0000003f8pAIAQ');
INSERT INTO "Question_Dependency__c" VALUES(662,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8pGIAQ','a2aS0000003f8pHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(663,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8pGIAQ','a2aS0000003f8pIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(664,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8pGIAQ','a2aS0000003f8pJIAQ');
INSERT INTO "Question_Dependency__c" VALUES(665,'0124P0000003S9AQAU','True','No','a2aS0000003f8yIIAQ','a2aS0000003f8yJIAQ');
INSERT INTO "Question_Dependency__c" VALUES(666,'0124P0000003S9AQAU','True','No','a2aS0000003f8u5IAA','a2aS0000003f8u6IAA');
INSERT INTO "Question_Dependency__c" VALUES(667,'0124P0000003S9AQAU','True','No','a2aS0000003f8qHIAQ','a2aS0000003f8qIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(668,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8uKIAQ','a2aS0000003f8uLIAQ');
INSERT INTO "Question_Dependency__c" VALUES(669,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8uKIAQ','a2aS0000003f8uMIAQ');
INSERT INTO "Question_Dependency__c" VALUES(670,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8uKIAQ','a2aS0000003f8uNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(671,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8uKIAQ','a2aS0000003f8uPIAQ');
INSERT INTO "Question_Dependency__c" VALUES(672,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ffIAA','a2aS0000003f8fdIAA');
INSERT INTO "Question_Dependency__c" VALUES(673,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ffIAA','a2aS0000003f8feIAA');
INSERT INTO "Question_Dependency__c" VALUES(674,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ffIAA','a2aS0000003f8fgIAA');
INSERT INTO "Question_Dependency__c" VALUES(675,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ffIAA','a2aS0000003f8fkIAA');
INSERT INTO "Question_Dependency__c" VALUES(676,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ffIAA','a2aS0000003f8fhIAA');
INSERT INTO "Question_Dependency__c" VALUES(677,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ffIAA','a2aS0000003f8fiIAA');
INSERT INTO "Question_Dependency__c" VALUES(678,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ffIAA','a2aS0000003f8fjIAA');
INSERT INTO "Question_Dependency__c" VALUES(679,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ouIAA','a2aS0000003f8p1IAA');
INSERT INTO "Question_Dependency__c" VALUES(680,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8ovIAA','a2aS0000003f8oyIAA');
INSERT INTO "Question_Dependency__c" VALUES(681,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8oxIAA','a2aS0000003f8owIAA');
INSERT INTO "Question_Dependency__c" VALUES(682,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8p2IAA','a2aS0000003f8ozIAA');
INSERT INTO "Question_Dependency__c" VALUES(683,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8p3IAA','a2aS0000003f8p0IAA');
INSERT INTO "Question_Dependency__c" VALUES(684,'0124P0000003S9AQAU','True','A different address','a2aS0000003f9MBIAY','a2aS0000003f9MAIAY');
INSERT INTO "Question_Dependency__c" VALUES(685,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8xcIAA','a2aS0000003f8xeIAA');
INSERT INTO "Question_Dependency__c" VALUES(686,'0124P0000003S9AQAU','True','A different address','a2aS0000003f9MBIAY','a2aS0000003f9MNIAY');
INSERT INTO "Question_Dependency__c" VALUES(687,'0124P0000003S9AQAU','True','A different address','a2aS0000003f9MBIAY','a2aS0000003f9MOIAY');
INSERT INTO "Question_Dependency__c" VALUES(688,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8xcIAA','a2aS0000003f8xdIAA');
INSERT INTO "Question_Dependency__c" VALUES(689,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8xcIAA','a2aS0000003f8xfIAA');
INSERT INTO "Question_Dependency__c" VALUES(690,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8xcIAA','a2aS0000003f8xgIAA');
INSERT INTO "Question_Dependency__c" VALUES(691,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8qmIAA','a2aS0000003f8qnIAA');
INSERT INTO "Question_Dependency__c" VALUES(692,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8qmIAA','a2aS0000003f8qoIAA');
INSERT INTO "Question_Dependency__c" VALUES(693,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8qmIAA','a2aS0000003f8qpIAA');
INSERT INTO "Question_Dependency__c" VALUES(694,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8qwIAA','a2aS0000003f8qtIAA');
INSERT INTO "Question_Dependency__c" VALUES(695,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8qzIAA','a2aS0000003f8qvIAA');
INSERT INTO "Question_Dependency__c" VALUES(696,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8tGIAQ','a2aS0000003f8tDIAQ');
INSERT INTO "Question_Dependency__c" VALUES(697,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8tJIAQ','a2aS0000003f8tFIAQ');
INSERT INTO "Question_Dependency__c" VALUES(698,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8tLIAQ','a2aS0000003f8tMIAQ');
INSERT INTO "Question_Dependency__c" VALUES(699,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8tLIAQ','a2aS0000003f8tNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(700,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8tLIAQ','a2aS0000003f8tPIAQ');
INSERT INTO "Question_Dependency__c" VALUES(701,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MJIAY','a2aS0000003f9M5IAI');
INSERT INTO "Question_Dependency__c" VALUES(702,'0124P0000003S9AQAU','True','Yes, I am','a2aS0000003f8k2IAA','a2aS0000003f8k1IAA');
INSERT INTO "Question_Dependency__c" VALUES(703,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f9N8IAI','a2aS0000003f9N0IAI');
INSERT INTO "Question_Dependency__c" VALUES(704,'0124P0000003S99QAE','True','White','a2aS0000003f9N8IAI','a2aS0000003f9NFIAY');
INSERT INTO "Question_Dependency__c" VALUES(705,'0124P0000003S9AQAU','True','Yes, I am','a2aS0000003f8k2IAA','a2aS0000003f8k0IAA');
INSERT INTO "Question_Dependency__c" VALUES(706,'0124P0000003S9AQAU','True','Home','a2aS0000003f8kuIAA','a2aS0000003f8krIAA');
INSERT INTO "Question_Dependency__c" VALUES(707,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8kuIAA','a2aS0000003f8ksIAA');
INSERT INTO "Question_Dependency__c" VALUES(708,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8kuIAA','a2aS0000003f8ktIAA');
INSERT INTO "Question_Dependency__c" VALUES(709,'0124P0000003S9AQAU','True','Work','a2aS0000003f8kuIAA','a2aS0000003f8kvIAA');
INSERT INTO "Question_Dependency__c" VALUES(710,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8kyIAA','a2aS0000003f8kwIAA');
INSERT INTO "Question_Dependency__c" VALUES(711,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8dYIAQ','a2aS0000003f8dWIAQ');
INSERT INTO "Question_Dependency__c" VALUES(712,'0124P0000003S9AQAU','True','Home','a2aS0000003f8dcIAA','a2aS0000003f8dZIAQ');
INSERT INTO "Question_Dependency__c" VALUES(713,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8dcIAA','a2aS0000003f8daIAA');
INSERT INTO "Question_Dependency__c" VALUES(714,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8dcIAA','a2aS0000003f8dbIAA');
INSERT INTO "Question_Dependency__c" VALUES(715,'0124P0000003S9AQAU','True','Other','a2aS0000003f8dcIAA','a2aS0000003f8ddIAA');
INSERT INTO "Question_Dependency__c" VALUES(716,'0124P0000003S9AQAU','True','Work','a2aS0000003f8dcIAA','a2aS0000003f8deIAA');
INSERT INTO "Question_Dependency__c" VALUES(717,'0124P0000003S98QAE','True','','a2aS0000003f8jEIAQ','a2aS0000003f8jDIAQ');
INSERT INTO "Question_Dependency__c" VALUES(718,'0124P0000003S98QAE','True','','a2aS0000003f8jEIAQ','a2aS0000003f8jFIAQ');
INSERT INTO "Question_Dependency__c" VALUES(719,'0124P0000003S98QAE','True','','a2aS0000003f8jEIAQ','a2aS0000003f8jGIAQ');
INSERT INTO "Question_Dependency__c" VALUES(720,'0124P0000003S98QAE','True','','a2aS0000003f8jEIAQ','a2aS0000003f8jHIAQ');
INSERT INTO "Question_Dependency__c" VALUES(721,'0124P0000003S98QAE','True','','a2aS0000003f8jEIAQ','a2aS0000003f8jIIAQ');
INSERT INTO "Question_Dependency__c" VALUES(722,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8jRIAQ','a2aS0000003f8jLIAQ');
INSERT INTO "Question_Dependency__c" VALUES(723,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8jRIAQ','a2aS0000003f8jMIAQ');
INSERT INTO "Question_Dependency__c" VALUES(724,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8jRIAQ','a2aS0000003f8jNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(725,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8doIAA','a2aS0000003f8dnIAA');
INSERT INTO "Question_Dependency__c" VALUES(726,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8dpIAA','a2aS0000003f8dxIAA');
INSERT INTO "Question_Dependency__c" VALUES(727,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8dpIAA','a2aS0000003f8e1IAA');
INSERT INTO "Question_Dependency__c" VALUES(728,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9BqIAI','a2aS0000003f9BoIAI');
INSERT INTO "Question_Dependency__c" VALUES(729,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MJIAY','a2aS0000003f9M6IAI');
INSERT INTO "Question_Dependency__c" VALUES(730,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MJIAY','a2aS0000003f9M8IAI');
INSERT INTO "Question_Dependency__c" VALUES(731,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f9BkIAI','a2aS0000003f9BlIAI');
INSERT INTO "Question_Dependency__c" VALUES(732,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f9BmIAI','a2aS0000003f9BnIAI');
INSERT INTO "Question_Dependency__c" VALUES(733,'0124P0000003S99QAE','True','Other','a2aS0000003f9BoIAI','a2aS0000003f9BpIAI');
INSERT INTO "Question_Dependency__c" VALUES(734,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f9BrIAI','a2aS0000003f9BsIAI');
INSERT INTO "Question_Dependency__c" VALUES(735,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f9BrIAI','a2aS0000003f9BsIAI');
INSERT INTO "Question_Dependency__c" VALUES(736,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f9BtIAI','a2aS0000003f9BaIAI');
INSERT INTO "Question_Dependency__c" VALUES(737,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f9BtIAI','a2aS0000003f9BcIAI');
INSERT INTO "Question_Dependency__c" VALUES(738,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f9BtIAI','a2aS0000003f9BdIAI');
INSERT INTO "Question_Dependency__c" VALUES(739,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f9BtIAI','a2aS0000003f9BeIAI');
INSERT INTO "Question_Dependency__c" VALUES(740,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f9BtIAI','a2aS0000003f9BfIAI');
INSERT INTO "Question_Dependency__c" VALUES(741,'0124P0000003S99QAE','True','Asian','a2aS0000003f9BtIAI','a2aS0000003f9BhIAI');
INSERT INTO "Question_Dependency__c" VALUES(742,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f9BtIAI','a2aS0000003f9BmIAI');
INSERT INTO "Question_Dependency__c" VALUES(743,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f9BtIAI','a2aS0000003f9BxIAI');
INSERT INTO "Question_Dependency__c" VALUES(744,'0124P0000003S99QAE','True','White','a2aS0000003f9BtIAI','a2aS0000003f9C0IAI');
INSERT INTO "Question_Dependency__c" VALUES(745,'0124P0000003S99QAE','True','Other','a2aS0000003f9C0IAI','a2aS0000003f9C1IAI');
INSERT INTO "Question_Dependency__c" VALUES(746,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8Y4IAI','a2aS0000003f8Y6IAI');
INSERT INTO "Question_Dependency__c" VALUES(747,'0124P0000003S9AQAU','True','Yes, I am interested.','a2aS0000003f97iIAA','a2aS0000003f97jIAA');
INSERT INTO "Question_Dependency__c" VALUES(748,'0124P0000003S9AQAU','True','Yes, I am interested.','a2aS0000003f97iIAA','a2aS0000003f97kIAA');
INSERT INTO "Question_Dependency__c" VALUES(749,'0124P0000003S9AQAU','True','Master''s','a2aS0000003f8fMIAQ','a2aS0000003f8fNIAQ');
INSERT INTO "Question_Dependency__c" VALUES(750,'0124P0000003S9AQAU','True','Home','a2aS0000003f9L3IAI','a2aS0000003f9L0IAI');
INSERT INTO "Question_Dependency__c" VALUES(751,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f9L3IAI','a2aS0000003f9L1IAI');
INSERT INTO "Question_Dependency__c" VALUES(752,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f9L3IAI','a2aS0000003f9L2IAI');
INSERT INTO "Question_Dependency__c" VALUES(753,'0124P0000003S9AQAU','True','Work','a2aS0000003f9L3IAI','a2aS0000003f9L4IAI');
INSERT INTO "Question_Dependency__c" VALUES(754,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8YZIAY','a2aS0000003f8YXIAY');
INSERT INTO "Question_Dependency__c" VALUES(755,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8YZIAY','a2aS0000003f8YYIAY');
INSERT INTO "Question_Dependency__c" VALUES(756,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8YZIAY','a2aS0000003f8YYIAY');
INSERT INTO "Question_Dependency__c" VALUES(757,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8YZIAY','a2aS0000003f8YaIAI');
INSERT INTO "Question_Dependency__c" VALUES(758,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8YZIAY','a2aS0000003f8YbIAI');
INSERT INTO "Question_Dependency__c" VALUES(759,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8YZIAY','a2aS0000003f8aCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(760,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8YZIAY','a2aS0000003f8aCIAQ');
INSERT INTO "Question_Dependency__c" VALUES(761,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8YZIAY','a2aS0000003f8YaIAI');
INSERT INTO "Question_Dependency__c" VALUES(762,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MJIAY','a2aS0000003f9MIIAY');
INSERT INTO "Question_Dependency__c" VALUES(763,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MJIAY','a2aS0000003f9MBIAY');
INSERT INTO "Question_Dependency__c" VALUES(764,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MJIAY','a2aS0000003f9MDIAY');
INSERT INTO "Question_Dependency__c" VALUES(765,'0124P0000003S9AQAU','True','No','a2aS0000003f9MJIAY','a2aS0000003f9MHIAY');
INSERT INTO "Question_Dependency__c" VALUES(766,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9MJIAY','a2aS0000003f9MOIAY');
INSERT INTO "Question_Dependency__c" VALUES(767,'0124P0000003S9AQAU','True','Other','a2aS0000003f9NdIAI','a2aS0000003f9NcIAI');
INSERT INTO "Question_Dependency__c" VALUES(768,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8TQIAY','a2aS0000003f8TOIAY');
INSERT INTO "Question_Dependency__c" VALUES(769,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8TQIAY','a2aS0000003f8TPIAY');
INSERT INTO "Question_Dependency__c" VALUES(770,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8TQIAY','a2aS0000003f8TRIAY');
INSERT INTO "Question_Dependency__c" VALUES(771,'0124P0000003S9AQAU','True','Associate''s','a2aS0000003f9GtIAI','a2aS0000003f9H2IAI');
INSERT INTO "Question_Dependency__c" VALUES(772,'0124P0000003S98QAE','True','','a2aS0000003f9H0IAI','a2aS0000003f9GvIAI');
INSERT INTO "Question_Dependency__c" VALUES(773,'0124P0000003S98QAE','True','','a2aS0000003f9H0IAI','a2aS0000003f9GwIAI');
INSERT INTO "Question_Dependency__c" VALUES(774,'0124P0000003S98QAE','True','','a2aS0000003f9H0IAI','a2aS0000003f9GxIAI');
INSERT INTO "Question_Dependency__c" VALUES(775,'0124P0000003S98QAE','True','','a2aS0000003f9H0IAI','a2aS0000003f9GzIAI');
INSERT INTO "Question_Dependency__c" VALUES(776,'0124P0000003S98QAE','True','','a2aS0000003f9H0IAI','a2aS0000003f9H1IAI');
INSERT INTO "Question_Dependency__c" VALUES(777,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9I3IAI','a2aS0000003f9I4IAI');
INSERT INTO "Question_Dependency__c" VALUES(778,'0124P0000003S98QAE','True','','a2aS0000003f9I6IAI','a2aS0000003f9I5IAI');
INSERT INTO "Question_Dependency__c" VALUES(779,'0124P0000003S98QAE','True','','a2aS0000003f9I6IAI','a2aS0000003f9I7IAI');
INSERT INTO "Question_Dependency__c" VALUES(780,'0124P0000003S98QAE','True','','a2aS0000003f9I6IAI','a2aS0000003f9I9IAI');
INSERT INTO "Question_Dependency__c" VALUES(781,'0124P0000003S98QAE','True','','a2aS0000003f9I6IAI','a2aS0000003f9IAIAY');
INSERT INTO "Question_Dependency__c" VALUES(782,'0124P0000003S98QAE','True','','a2aS0000003f9I6IAI','a2aS0000003f9IDIAY');
INSERT INTO "Question_Dependency__c" VALUES(783,'0124P0000003S9AQAU','True','True','a2aS0000003f9IBIAY','a2aS0000003f9I8IAI');
INSERT INTO "Question_Dependency__c" VALUES(784,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9IBIAY','a2aS0000003f9ICIAY');
INSERT INTO "Question_Dependency__c" VALUES(785,'0124P0000003S99QAE','True','Other','a2aS0000003f9LcIAI','a2aS0000003f9LdIAI');
INSERT INTO "Question_Dependency__c" VALUES(786,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8yoIAA','a2aS0000003f8ynIAA');
INSERT INTO "Question_Dependency__c" VALUES(787,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9LeIAI','a2aS0000003f9LcIAI');
INSERT INTO "Question_Dependency__c" VALUES(788,'0124P0000003S9AQAU','True','Other','a2aS0000003f9LfIAI','a2aS0000003f9LgIAI');
INSERT INTO "Question_Dependency__c" VALUES(789,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8VSIAY','a2aS0000003f8VqIAI');
INSERT INTO "Question_Dependency__c" VALUES(790,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8yoIAA','a2aS0000003f8ypIAA');
INSERT INTO "Question_Dependency__c" VALUES(791,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8VYIAY','a2aS0000003f8VZIAY');
INSERT INTO "Question_Dependency__c" VALUES(792,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8yoIAA','a2aS0000003f8yqIAA');
INSERT INTO "Question_Dependency__c" VALUES(793,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8yoIAA','a2aS0000003f8ysIAA');
INSERT INTO "Question_Dependency__c" VALUES(794,'0124P0000003S9AQAU','True','Add another pronoun set','a2aS0000003f8VYIAY','a2aS0000003f8VZIAY');
INSERT INTO "Question_Dependency__c" VALUES(795,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8VaIAI','a2aS0000003f8VQIAY');
INSERT INTO "Question_Dependency__c" VALUES(796,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8VaIAI','a2aS0000003f8VSIAY');
INSERT INTO "Question_Dependency__c" VALUES(797,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8VaIAI','a2aS0000003f8VTIAY');
INSERT INTO "Question_Dependency__c" VALUES(798,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8VaIAI','a2aS0000003f8VUIAY');
INSERT INTO "Question_Dependency__c" VALUES(799,'0124P0000003S99QAE','True','Native Hawaiian or Pacific Islander','a2aS0000003f8VaIAI','a2aS0000003f8VhIAI');
INSERT INTO "Question_Dependency__c" VALUES(800,'0124P0000003S99QAE','True','White','a2aS0000003f8VaIAI','a2aS0000003f8VlIAI');
INSERT INTO "Question_Dependency__c" VALUES(801,'0124P0000003S9AQAU','True','Apply With Standardized Test','a2aS0000003f8yoIAA','a2aS0000003f8ywIAA');
INSERT INTO "Question_Dependency__c" VALUES(802,'0124P0000003S9AQAU','True','3','a2aS0000003f8ysIAA','a2aS0000003f8ytIAA');
INSERT INTO "Question_Dependency__c" VALUES(803,'0124P0000003S9AQAU','True','2','a2aS0000003f8ysIAA','a2aS0000003f8ytIAA');
INSERT INTO "Question_Dependency__c" VALUES(804,'0124P0000003S9AQAU','True','2','a2aS0000003f8ysIAA','a2aS0000003f8yuIAA');
INSERT INTO "Question_Dependency__c" VALUES(805,'0124P0000003S9AQAU','True','3','a2aS0000003f8ysIAA','a2aS0000003f8yuIAA');
INSERT INTO "Question_Dependency__c" VALUES(806,'0124P0000003S9AQAU','True','1','a2aS0000003f8ysIAA','a2aS0000003f8yuIAA');
INSERT INTO "Question_Dependency__c" VALUES(807,'0124P0000003S9AQAU','True','3','a2aS0000003f8ysIAA','a2aS0000003f8yvIAA');
INSERT INTO "Question_Dependency__c" VALUES(808,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vUIAQ','a2aS0000003f8vRIAQ');
INSERT INTO "Question_Dependency__c" VALUES(809,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vUIAQ','a2aS0000003f8vSIAQ');
INSERT INTO "Question_Dependency__c" VALUES(810,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8vUIAQ','a2aS0000003f8vTIAQ');
INSERT INTO "Question_Dependency__c" VALUES(811,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WmIAI','a2aS0000003f8WqIAI');
INSERT INTO "Question_Dependency__c" VALUES(812,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8WnIAI','a2aS0000003f8WoIAI');
INSERT INTO "Question_Dependency__c" VALUES(813,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8VSIAY','a2aS0000003f8VQIAY');
INSERT INTO "Question_Dependency__c" VALUES(814,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8VSIAY','a2aS0000003f8VTIAY');
INSERT INTO "Question_Dependency__c" VALUES(815,'0124P0000003S99QAE','True','Asian','a2aS0000003f8VaIAI','a2aS0000003f8VtIAI');
INSERT INTO "Question_Dependency__c" VALUES(816,'0124P0000003S99QAE','True','Black or African American','a2aS0000003f8VaIAI','a2aS0000003f8VnIAI');
INSERT INTO "Question_Dependency__c" VALUES(817,'0124P0000003S99QAE','True','American Indian or Alaskan Native','a2aS0000003f8VaIAI','a2aS0000003f8VqIAI');
INSERT INTO "Question_Dependency__c" VALUES(818,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f99EIAQ','a2aS0000003f99BIAQ');
INSERT INTO "Question_Dependency__c" VALUES(819,'0124P0000003S99QAE','True','Other','a2aS0000003f8VbIAI','a2aS0000003f8VcIAI');
INSERT INTO "Question_Dependency__c" VALUES(820,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f99EIAQ','a2aS0000003f99CIAQ');
INSERT INTO "Question_Dependency__c" VALUES(821,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8VdIAI','a2aS0000003f8VbIAI');
INSERT INTO "Question_Dependency__c" VALUES(822,'0124P0000003S9AQAU','True','Add another gender','a2aS0000003f8VfIAI','a2aS0000003f8VgIAI');
INSERT INTO "Question_Dependency__c" VALUES(823,'0124P0000003S9AQAU','True','No','a2aS0000003f9JjIAI','a2aS0000003f9JkIAI');
INSERT INTO "Question_Dependency__c" VALUES(824,'0124P0000003S9AQAU','True','Female','a2aS0000003f8VfIAI','a2aS0000003f8lOIAQ');
INSERT INTO "Question_Dependency__c" VALUES(825,'0124P0000003S9AQAU','True','Female','a2aS0000003f8VfIAI','a2aS0000003f8lWIAQ');
INSERT INTO "Question_Dependency__c" VALUES(826,'0124P0000003S9AQAU','True','No','a2aS0000003f9JjIAI','a2aS0000003f9JlIAI');
INSERT INTO "Question_Dependency__c" VALUES(827,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f8VtIAI','a2aS0000003f8VWIAY');
INSERT INTO "Question_Dependency__c" VALUES(828,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f8VtIAI','a2aS0000003f8VpIAI');
INSERT INTO "Question_Dependency__c" VALUES(829,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f8VtIAI','a2aS0000003f8VsIAI');
INSERT INTO "Question_Dependency__c" VALUES(830,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9JzIAI','a2aS0000003f9JwIAI');
INSERT INTO "Question_Dependency__c" VALUES(831,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9JzIAI','a2aS0000003f9JxIAI');
INSERT INTO "Question_Dependency__c" VALUES(832,'0124P0000003S99QAE','True','Other Pacific Islands (excluding Philippines)','a2aS0000003f8VhIAI','a2aS0000003f8ViIAI');
INSERT INTO "Question_Dependency__c" VALUES(833,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8VjIAI','a2aS0000003f8VRIAY');
INSERT INTO "Question_Dependency__c" VALUES(834,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8VjIAI','a2aS0000003f8VXIAY');
INSERT INTO "Question_Dependency__c" VALUES(835,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f8VjIAI','a2aS0000003f8VkIAI');
INSERT INTO "Question_Dependency__c" VALUES(836,'0124P0000003S99QAE','True','Other','a2aS0000003f8akIAA','a2aS0000003f8alIAA');
INSERT INTO "Question_Dependency__c" VALUES(837,'0124P0000003S99QAE','True','Other','a2aS0000003f8VlIAI','a2aS0000003f8VmIAI');
INSERT INTO "Question_Dependency__c" VALUES(838,'0124P0000003S99QAE','True','Other','a2aS0000003f8VnIAI','a2aS0000003f8VoIAI');
INSERT INTO "Question_Dependency__c" VALUES(839,'0124P0000003S99QAE','True','Other','a2aS0000003f8VnIAI','a2aS0000003f8VoIAI');
INSERT INTO "Question_Dependency__c" VALUES(840,'0124P0000003S9AQAU','True','Yes','a2aS0000003f92iIAA','a2aS0000003f92gIAA');
INSERT INTO "Question_Dependency__c" VALUES(841,'0124P0000003S9AQAU','True','No','a2aS0000003f98yIAA','a2aS0000003f98zIAA');
INSERT INTO "Question_Dependency__c" VALUES(842,'0124P0000003S9AQAU','True','No','a2aS0000003f98yIAA','a2aS0000003f990IAA');
INSERT INTO "Question_Dependency__c" VALUES(843,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f99mIAA','a2aS0000003f99jIAA');
INSERT INTO "Question_Dependency__c" VALUES(844,'0124P0000003S9AQAU','True','No','a2aS0000003f99WIAQ','a2aS0000003f99XIAQ');
INSERT INTO "Question_Dependency__c" VALUES(845,'0124P0000003S9AQAU','True','No','a2aS0000003f99WIAQ','a2aS0000003f99YIAQ');
INSERT INTO "Question_Dependency__c" VALUES(846,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8W5IAI','a2aS0000003f8W1IAI');
INSERT INTO "Question_Dependency__c" VALUES(847,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f99mIAA','a2aS0000003f99kIAA');
INSERT INTO "Question_Dependency__c" VALUES(848,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8W5IAI','a2aS0000003f8W2IAI');
INSERT INTO "Question_Dependency__c" VALUES(849,'0124P0000003S9AQAU','True','No','a2aS0000003f9JRIAY','a2aS0000003f9JSIAY');
INSERT INTO "Question_Dependency__c" VALUES(850,'0124P0000003S9AQAU','True','No','a2aS0000003f9JRIAY','a2aS0000003f9JTIAY');
INSERT INTO "Question_Dependency__c" VALUES(851,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8W5IAI','a2aS0000003f8W3IAI');
INSERT INTO "Question_Dependency__c" VALUES(852,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8W5IAI','a2aS0000003f8W4IAI');
INSERT INTO "Question_Dependency__c" VALUES(853,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8W5IAI','a2aS0000003f8W6IAI');
INSERT INTO "Question_Dependency__c" VALUES(854,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8W5IAI','a2aS0000003f8W7IAI');
INSERT INTO "Question_Dependency__c" VALUES(855,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8W5IAI','a2aS0000003f8W8IAI');
INSERT INTO "Question_Dependency__c" VALUES(856,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8W5IAI','a2aS0000003f8W9IAI');
INSERT INTO "Question_Dependency__c" VALUES(857,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8W5IAI','a2aS0000003f8WAIAY');
INSERT INTO "Question_Dependency__c" VALUES(858,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8W5IAI','a2aS0000003f8WBIAY');
INSERT INTO "Question_Dependency__c" VALUES(859,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9JhIAI','a2aS0000003f9JeIAI');
INSERT INTO "Question_Dependency__c" VALUES(860,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9JhIAI','a2aS0000003f9JfIAI');
INSERT INTO "Question_Dependency__c" VALUES(861,'0124P0000003S9AQAU','True','No','a2aS0000003f9AKIAY','a2aS0000003f9ALIAY');
INSERT INTO "Question_Dependency__c" VALUES(862,'0124P0000003S9AQAU','True','No','a2aS0000003f9AKIAY','a2aS0000003f9AMIAY');
INSERT INTO "Question_Dependency__c" VALUES(863,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9AaIAI','a2aS0000003f9AXIAY');
INSERT INTO "Question_Dependency__c" VALUES(864,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9AaIAI','a2aS0000003f9AYIAY');
INSERT INTO "Question_Dependency__c" VALUES(865,'0124P0000003S9AQAU','True','No','a2aS0000003f99FIAQ','a2aS0000003f99GIAQ');
INSERT INTO "Question_Dependency__c" VALUES(866,'0124P0000003S9AQAU','True','No','a2aS0000003f99FIAQ','a2aS0000003f99HIAQ');
INSERT INTO "Question_Dependency__c" VALUES(867,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8W5IAI','a2aS0000003f8VvIAI');
INSERT INTO "Question_Dependency__c" VALUES(868,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8W5IAI','a2aS0000003f8VwIAI');
INSERT INTO "Question_Dependency__c" VALUES(869,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8W5IAI','a2aS0000003f8VxIAI');
INSERT INTO "Question_Dependency__c" VALUES(870,'0124P0000003S9AQAU','True','ACT','a2aS0000003f8W5IAI','a2aS0000003f8VyIAI');
INSERT INTO "Question_Dependency__c" VALUES(871,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8W5IAI','a2aS0000003f8VzIAI');
INSERT INTO "Question_Dependency__c" VALUES(872,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f99VIAQ','a2aS0000003f99TIAQ');
INSERT INTO "Question_Dependency__c" VALUES(873,'0124P0000003S9AQAU','True','SAT','a2aS0000003f8W5IAI','a2aS0000003f8WCIAY');
INSERT INTO "Question_Dependency__c" VALUES(874,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f99VIAQ','a2aS0000003f99SIAQ');
INSERT INTO "Question_Dependency__c" VALUES(875,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9AGIAY','a2aS0000003f9AEIAY');
INSERT INTO "Question_Dependency__c" VALUES(876,'0124P0000003S9AQAU','True','No','a2aS0000003f98hIAA','a2aS0000003f98iIAA');
INSERT INTO "Question_Dependency__c" VALUES(877,'0124P0000003S98QAE','False','','a2aS0000003f9AgIAI','a2aS0000003f9AhIAI');
INSERT INTO "Question_Dependency__c" VALUES(878,'0124P0000003S9AQAU','True','No','a2aS0000003f98hIAA','a2aS0000003f98jIAA');
INSERT INTO "Question_Dependency__c" VALUES(879,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f98xIAA','a2aS0000003f98uIAA');
INSERT INTO "Question_Dependency__c" VALUES(880,'0124P0000003S98QAE','True','','a2aS0000003f9AgIAI','a2aS0000003f9AiIAI');
INSERT INTO "Question_Dependency__c" VALUES(881,'0124P0000003S9AQAU','True','Other','a2aS0000003f8UcIAI','a2aS0000003f8UZIAY');
INSERT INTO "Question_Dependency__c" VALUES(882,'0124P0000003S9AQAU','True','Other','a2aS0000003f8UcIAI','a2aS0000003f8UaIAI');
INSERT INTO "Question_Dependency__c" VALUES(883,'0124P0000003S9AQAU','True','Other','a2aS0000003f8UcIAI','a2aS0000003f8UbIAI');
INSERT INTO "Question_Dependency__c" VALUES(884,'0124P0000003S9AQAU','True','Home','a2aS0000003f8WdIAI','a2aS0000003f8WeIAI');
INSERT INTO "Question_Dependency__c" VALUES(885,'0124P0000003S9AQAU','True','Work Phone','a2aS0000003f8WdIAI','a2aS0000003f8WfIAI');
INSERT INTO "Question_Dependency__c" VALUES(886,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8WdIAI','a2aS0000003f8WgIAI');
INSERT INTO "Question_Dependency__c" VALUES(887,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f8WdIAI','a2aS0000003f8WhIAI');
INSERT INTO "Question_Dependency__c" VALUES(888,'0124P0000003S98QAE','False','','a2aS0000003f97lIAA','a2aS0000003f97mIAA');
INSERT INTO "Question_Dependency__c" VALUES(889,'0124P0000003S98QAE','True','','a2aS0000003f97lIAA','a2aS0000003f97nIAA');
INSERT INTO "Question_Dependency__c" VALUES(890,'0124P0000003S98QAE','False','','a2aS0000003f9I0IAI','a2aS0000003f9I1IAI');
INSERT INTO "Question_Dependency__c" VALUES(891,'0124P0000003S98QAE','True','','a2aS0000003f9I0IAI','a2aS0000003f9I2IAI');
INSERT INTO "Question_Dependency__c" VALUES(892,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f98xIAA','a2aS0000003f98vIAA');
INSERT INTO "Question_Dependency__c" VALUES(893,'0124P0000003S9AQAU','True','No','a2aS0000003f9KEIAY','a2aS0000003f9KFIAY');
INSERT INTO "Question_Dependency__c" VALUES(894,'0124P0000003S9AQAU','True','No','a2aS0000003f9KEIAY','a2aS0000003f9KGIAY');
INSERT INTO "Question_Dependency__c" VALUES(895,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9KUIAY','a2aS0000003f9KRIAY');
INSERT INTO "Question_Dependency__c" VALUES(896,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9KUIAY','a2aS0000003f9KSIAY');
INSERT INTO "Question_Dependency__c" VALUES(897,'0124P0000003S9AQAU','True','No','a2aS0000003f9A0IAI','a2aS0000003f9A1IAI');
INSERT INTO "Question_Dependency__c" VALUES(898,'0124P0000003S9AQAU','True','No','a2aS0000003f9A0IAI','a2aS0000003f9A2IAI');
INSERT INTO "Question_Dependency__c" VALUES(899,'0124P0000003S99QAE','True','Currently Serving;Previously Served;Current Dependent','a2aS0000003f9AGIAY','a2aS0000003f9ADIAY');
INSERT INTO "Question_Dependency__c" VALUES(900,'0124P0000003S9AQAU','True','Other','a2aS0000003f9IMIAY','a2aS0000003f9IOIAY');
INSERT INTO "Question_Dependency__c" VALUES(901,'0124P0000003S9AQAU','True','Other','a2aS0000003f9LJIAY','a2aS0000003f9LNIAY');
INSERT INTO "Question_Dependency__c" VALUES(902,'0124P0000003S99QAE','True','Other East Asia','a2aS0000003f9BhIAI','a2aS0000003f9BjIAI');
INSERT INTO "Question_Dependency__c" VALUES(903,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XnIAI','a2aS0000003f8XpIAI');
INSERT INTO "Question_Dependency__c" VALUES(904,'0124P0000003S9AQAU','True','Other','a2aS0000003f9BOIAY','a2aS0000003f9BSIAY');
INSERT INTO "Question_Dependency__c" VALUES(905,'0124P0000003S9AQAU','True','Other','a2aS0000003f98HIAQ','a2aS0000003f98IIAQ');
INSERT INTO "Question_Dependency__c" VALUES(906,'0124P0000003S9AQAU','True','Other','a2aS0000003f98HIAQ','a2aS0000003f98JIAQ');
INSERT INTO "Question_Dependency__c" VALUES(907,'0124P0000003S99QAE','True','Other South Asia','a2aS0000003f9BhIAI','a2aS0000003f9BvIAI');
INSERT INTO "Question_Dependency__c" VALUES(908,'0124P0000003S9AQAU','True','Other','a2aS0000003f98HIAQ','a2aS0000003f98KIAQ');
INSERT INTO "Question_Dependency__c" VALUES(909,'0124P0000003S99QAE','True','Other Southeast Asia','a2aS0000003f9BhIAI','a2aS0000003f9BwIAI');
INSERT INTO "Question_Dependency__c" VALUES(910,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9ImIAI','a2aS0000003f9IoIAI');
INSERT INTO "Question_Dependency__c" VALUES(911,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9IpIAI','a2aS0000003f9IqIAI');
INSERT INTO "Question_Dependency__c" VALUES(912,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9IpIAI','a2aS0000003f9IrIAI');
INSERT INTO "Question_Dependency__c" VALUES(913,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9IpIAI','a2aS0000003f9IsIAI');
INSERT INTO "Question_Dependency__c" VALUES(914,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9J1IAI','a2aS0000003f9J2IAI');
INSERT INTO "Question_Dependency__c" VALUES(915,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f9IvIAI','a2aS0000003f9IwIAI');
INSERT INTO "Question_Dependency__c" VALUES(916,'0124P0000003S9AQAU','True','Mobile','a2aS0000003f9IvIAI','a2aS0000003f9IyIAI');
INSERT INTO "Question_Dependency__c" VALUES(917,'0124P0000003S9AQAU','True','Home','a2aS0000003f9IvIAI','a2aS0000003f9IzIAI');
INSERT INTO "Question_Dependency__c" VALUES(918,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XsIAI','a2aS0000003f8XxIAI');
INSERT INTO "Question_Dependency__c" VALUES(919,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XsIAI','a2aS0000003f8XyIAI');
INSERT INTO "Question_Dependency__c" VALUES(920,'0124P0000003S9AQAU','True','Yes','a2aS0000003f8XsIAI','a2aS0000003f8XzIAI');
INSERT INTO "Question_Dependency__c" VALUES(921,'0124P0000003S9AQAU','True','Yes','a2aS0000003f94EIAQ','a2aS0000003f94BIAQ');
INSERT INTO "Question_Dependency__c" VALUES(922,'0124P0000003S9AQAU','True','Yes','a2aS0000003f94EIAQ','a2aS0000003f94CIAQ');
INSERT INTO "Question_Dependency__c" VALUES(923,'0124P0000003S9AQAU','True','Yes','a2aS0000003f94EIAQ','a2aS0000003f94DIAQ');
INSERT INTO "Question_Dependency__c" VALUES(924,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9C4IAI','a2aS0000003f9C8IAI');
INSERT INTO "Question_Dependency__c" VALUES(925,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9C5IAI','a2aS0000003f9C6IAI');
INSERT INTO "Question_Dependency__c" VALUES(926,'0124P0000003S99QAE','True','Other','a2aS0000003f9BaIAI','a2aS0000003f9BbIAI');
INSERT INTO "Question_Dependency__c" VALUES(927,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9BcIAI','a2aS0000003f9BdIAI');
INSERT INTO "Question_Dependency__c" VALUES(928,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9BcIAI','a2aS0000003f9BfIAI');
INSERT INTO "Question_Dependency__c" VALUES(929,'0124P0000003S9AQAU','True','Yes','a2aS0000003f9BcIAI','a2aS0000003f9BxIAI');
INSERT INTO "Question_Dependency__c" VALUES(930,'0124P0000003S98QAE','True','','5','1');
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
INSERT INTO "Question__c" VALUES(1,'true','','','','','','','','false','','','','','53.0','false','true','','false','','','','','','','false','','','','','Registration Fee Received (NCUST)','Name','false','','','0124P0000003S9QQAU','','','','','<p><strong>Registration Fee Received</strong></p>

<p>Thank you for registering!<br><br>Please check your email for a link to access your On Demand course. </p>','','','','1');
INSERT INTO "Question__c" VALUES(2,'true','','','','Started App;Submitted App','','','HomePhone','false','','','','','37.0','false','true','Started App','false','','','','','','','false','Home Phone','','','','Home (NCUST)','Name','false','','','0124P0000003S9MQAU','','Started App','','','','','','','1');
INSERT INTO "Question__c" VALUES(3,'true','','','','Started App;Submitted App','','','hed__WorkPhone__c','false','','','','','38.0','false','true','Started App','false','','','','','','','false','Work Phone','','','','Work (NCUST)','Name','false','','','0124P0000003S9MQAU','','Started App','','','','','','','1');
INSERT INTO "Question__c" VALUES(4,'true','','','','Started App;Submitted App','','','MobilePhone','false','','','','','32.0','false','true','Started App','false','','','','','','','false','Mobile Phone','','','','Mobile (NCUST)','Name','false','','','0124P0000003S9MQAU','','Started App','','','','','','','1');
INSERT INTO "Question__c" VALUES(5,'true','','','','','','','','false','','','','','50.0','false','true','','false','','','','','','','false','','','','','Registration Fee Payment (NCUST)','Name','false','','','0124P0000003SJ2QAM','','','','','','','','','1');
INSERT INTO "Question__c" VALUES(6,'true','','','','','','','','false','','','','','52.0','false','true','','false','','','','','','','false','','','','','Registration Fee Enticement (NCUST)','Name','false','','','0124P0000003S9QQAU','','','','','Click the button above to submit your registration fee and enroll in this course. ','','','','1');
INSERT INTO "Question__c" VALUES(7,'true','','','','Started App;Submitted App','','','hed__PreferredPhone__c','false','','','','','31.0','false','true','Started App','false','','','','','','','false','Preferred Phone','','','','Preferred Phone (NCUST)','Name','false','Mobile
Home
Work','','0124P0000003S9NQAU','','Started App','','','','','','','1');
INSERT INTO "Question__c" VALUES(8,'true','','','','Started App;Submitted App','','','Admissions_Mobile_Opt_In__c','false','','','','','36.0','false','true','Started App','false','','','','','','','false','Are you willing to receive text messages from the University of St. Thomas? (Users can opt-out by texting STOP to unsubscribe at any time. Message and data rates may apply.)','','','','Mobile Opt-in (NCUST)','Name','false','Yes
No','','0124P0000003S9NQAU','','Started App','','','','','','','1');
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
INSERT INTO "Requirement_Item__c" VALUES(1,'True','False','False','','Started App','','','','3.0','True','True','','','','','','','','','','','False','False','Complete Your Registration','','Profile & Registration (NCUST)','','','0124P0000003S9WQAU','','','','','','','','','Requirement_Item__c2023-02-17 04:25:20Z00000','','','','True','','','1');
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
INSERT INTO "Requirement__c" VALUES(1,'True','','','Started App','','','','1.0','True','True','','','','','False','False','Create Your Profile & Register','Course Registration Profile  (NCUST)','','','False','','True','1','');
INSERT INTO "Requirement__c" VALUES(2,'False','','Before Term/Program Questions','','','','','1.0','True','True','','','','','False','False','','PreApp Questions (NCUST)','','','True','','True','1','');
COMMIT;
