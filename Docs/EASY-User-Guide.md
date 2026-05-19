```
Updated Oct. 2018
```
## ***E***NTERPRISE ***A***PPLICATION ***S***OLUTION FOR ***Y***IELD

Enterprise Application Solution for Yield (EASY), developed for the

Salesforce community by Maryville University, is a “builder” for

applications across the enterprise. It is designed to be a user tool,

so departments can have and control their own, unique

application. It is made available at no charge through the

generosity of a Salesforce.org Force for Change Grant.


## Enterprise Application Solution for Yield (EASY)

```
Open-sourced by Maryville University
```

**Enterprise Application Solution for Yield (EASY)**

- ACKNOWLEDGEMENTS Table of Contents
- OVERVIEW
    - Audience
    - What is Enterprise Application Solution for Yield (Easy)?
- APPLICATION ADMINISTRATOR
    - Navigating the Applications App
    - Introduction to Creating a Dynamic Application
    - Application Control – Create an Application
    - Requirements
    - Requirement Items
    - Create Requirement Items
    - Properties of Requirement Items
    - Document Uploads
    - Question Groups
    - Related Objects
    - Questions
    - Question Dependencies
    - External Requirement Items
    - Programs
    - TerM Controls Open-sourced by Maryville University
    - Previewing Requirements
- THE APPLICATION EXPERIENCE
    - Application Creation
- APPLICATION CHECKLIST
- APPLICATION ADMINISTRATOR VIEW AND REVIEW
    - Administrator View
    - Application Review
- OTHER CONSIDERATIONS
    - Storage
    - Data Integrity
    - Admissions Office Example


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
## ACKNOWLEDGEMENTS

The Enterprise Application Solution for Yield (EASY) is first, and foremost, a _community-driven_
open-source solution. While contributors are too numerous to name, specific credit does need
to be acknowledged and goes to the following community members for their inspiration,
support and participation:

- Algonquin College: Laura Campbell, Doug Wotherspoon and Nash Zgonjanin
- Cornell University: Rebecca Joffrey, Laura Landphair and Rob Parker
- Oregon State University: John Henry
- Pepperdine University: Terry Utter
- Providence College: Colleen Whelan
- University of Miami: Deborah Duran, Nina Gomez-Fernandini and Florence Parodi, along
  with their Sierra-Cedar partners led by Kara McIntyre
- Amjad Ayoubi, Tulane University
- Wayne State University: Eric Bowman, Jeff Dunn, Mihn Ha, Daren Hubbard and Robert
  Thompson

EASY wouldn’t have been easy at all without the Salesforce.org Higher Education Advisory
Council. The members of the 2016-17 and 2017-18 terms provided invaluable input as EASY was
transformed from Maryville’s solution to one that any school could install and use.

On that note, credit goes to Ryan Gudis and Kyle Schmid from Huron Consulting Group. Under
the leadership of Nicholas Zinser, formerly Huron’s Salesforce Consulting Director for higher
education and now with Salesforce.org, Ryan and Kyle served as the brilliant developers who
brought to life the “user tool” philosophy behind EASY. As the senior developer, Kyle took the
lead on the project.

Last, but not least, EASY exists because of the leadership and support of Maryville University.
Critical support spanned the university, from Doug Glaze, CTO, and Steven Mandeville, CFO, to
the members of the Enrollment Management team and the entire Maryville Salesforce Steering
Committee. Special thanks to President Mark Lombardi, who is setting the industry template
for transforming higher education and just happens to be the Salesforce champion at Maryville.
He invested in and supported the grant work by Kathleen Lueckeman, Chief Innovation Officer,
who served as PI for the grant and whose community activity ensured the input necessary to
produce such a robust solution.

## ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
## OVERVIEW

### Audience

While this User Guide contains step-by-step instructions intended for end users (application
creators/administrators), it is intended equally for System Administrators to learn about use
cases and best practices for the Enterprise Application Solution for Yield (EASY). Before you
proceed to the Installation and Configuration Guide, we recommend that you review this User
Guide first.

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### What is Enterprise Application Solution for Yield (Easy)?

Enterprise Application Solution for Yield (EASY) is a native form builder with administrative and
decision-making tools. It is designed to be a user tool so departments can control their own
application. It’s an extension of Salesforce’s approach to “democratizing” software. That is, the
same way that Salesforce democratized software by separating declarative functionality from
coding, EASY democratizes declarative and user functionality, separating application and
question/requirement setup from administrative setup of fields and picklist values. The latter
most often are associated with IPEDS and/or SIS fields in global picklist sets, minimizing the
initial and support work required by system administrators.

That means users control most of the functions of the solution rather than having to heavily
rely on the IT department for updates to existing questions or new applications. The user tool
approach, then, equates to empowerment for departments.

The solution is provided as an unmanaged package (the EASY Package) and includes resource
documents (such as this guide) and code via the Salesforce Foundation GIT repository. This
guide explains EASY and shares the best practices for using it.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
**EASY Features**

Below are some of the ways that EASY empowers departments while taking advantage of the
robust Salesforce platform. The first part starts with a short description of each tool that
comprises the solution.

**Application Control Tool** : With this functionality, you can create multiple, distinct applications.
While most departments will need only one application for admission, EASY is an enterprise
solution so any department can use the solution for their own application needs.

To determine the need for separate applications, ask whether there is a need:

- For a different look and feel for each application
- To ask the applicant to select a term and program
- For different questions to create an application (e.g., an application for admission may
  ask whether the applicant is a freshman, transfer or graduate applicant while an
  employment application would never ask that question)
- To have different a status when an application can be submitted (e.g., one application
  allows applicants to use the “submit” button only when all requirements are fulfilled
  while another allows applicants to submit an application that is incomplete)
- To allow one application to have a cancellation and/or withdrawal process while
  another does not allow such processes.

If the answer is “yes” to one of these questions, it likely would be better to use the Application
Control Tool to set up a unique application.

**Requirements and Requirement Items** : This is the top-level objects of the “form builder” tool
for the application. Staff can create application requirements, which serve as categories on the
application, add filters to each requirement to ensure they display only to the intended
audience, then group questions as Requirement Items.

There are further controls in this feature. For instance, staff can set where and when
Requirements and Requirement Items display on the application by selecting the order and
status during which they should show. Staff also can set whether and during which status an
applicant can edit a response (answer). This gives the school the ability to lock down answers so
they cannot be changed.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
Even better, the school can display requirements after an application has an admission
decision. That means, schools can use EASY for post-admission requirements to accommodate
commitment and yield processes, which usually must be accomplished through separate forms
or systems. This functionality allows students to stay in place to complete post-admissions
processes.

**Questions and Document Uploads** : Staff can create questions that are formatted for text, radio
buttons, checkbox, date, email and a long list of other formats – a function traditionally
available only to system administrators and not departmental users. Staff also can create
conditional questions with logic dependencies, lookup other objects to provide applicants with
a type-ahead search, and store information associated with the application either on the
Application object or on related objects.

**Streamlined Account Creation** : Since many schools feel that applicants are discouraged if they
have to create an account first before creating an application, EASY offers an account creation
process to help the applicant feel as if an application is being started rather than creating an
account. Importantly, the account creation process must include the filtering questions
required to determine the correct applicant type, and it can have as many or few questions as
the school prefers to include in this section. At the culmination, the applicant creates a
password to be used to access the application in subsequent visits.

**Checklist** : Complementing the Application Creation functionality, the Checklist is the list of
Requirements and related Requirement Items with a visual indicator of fulfillment. The checklist
is visible to applicants, which means applicants don’t have to call or email to ask whether the
school has received a document (like an official transcript) or an external requirement has been
fulfilled (e.g., a letter of recommendation has been received).

**Application Review** : This is the reader function in EASY. Because answers to questions and
uploaded documents are separate records, the reader brings all of the application information
onto one screen. For added convenience, the fields used to document the reader’s review of
the application are included at the end of the Application Review screen, making it easy to read
and review the application by clicking one button.

**Academic Term / Intended Program Term** : EASY includes the ability to display application by
date, along with the ability to display when applicants can apply to programs. At a high level,
you can define when an application opens/closes for each term. Furthermore, you can add-in
intended program term records for specific populations (i.e. an earlier application close date for
international students) by using its native filters. Importantly, you can turn off and turn on
applications for a specific program. For example, may schools accept applications for PhD
programs only in the fall. With Intended Program Term, you can turn off the application for PhD
programs for winter, spring and summer.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
**Note:** The EASY solution also includes the Interactions for Student Recruitment solution, open-
sourced by the University of Miami. This is a staging table that uses your matching rules and it
automatically creates related records. It was included in the EASY solution to ensure
applications are matched to Leads/Contacts and to update existing records like Opportunities.
The EASY solution has altered the Interactions solution, taking it from a recruitment solution to
an enterprise solution by ensuring it works with this enterprise application solution.

More information on Interactions for Student Recruitment is available on the Salesforce
Foundation GIT repository and in a Power of Us Hub Chatter group.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
## APPLICATION ADMINISTRATOR

This section describes how EASY empowers departments so they do not have to heavily rely on
Salesforce system administrators to create new or edit existing application questions. For
clarity, this document uses the term “application administrator” to describe staff who have the
appropriate permission to create applications, differentiating them from “system
administrators.”

The application administrator’s key responsibilities that are covered in this section include (but
are not be limited to):

• (^) Create a distinct application with basic branding
• (^) Set controls around when an application opens and closes
• (^) Set controls on when an application can be submitted, cancelled and/or withdrawn
• (^) Set the status of an application when it is submitted, cancelled and/or withdrawn
• (^) Create/edit records in Salesforce
o (^) Requirements
o (^) Requirement Items
o (^) Intended Term of Entry
• (^) Review records in a staging table that were created by the applicant and need approval
prior to creation
o (^) Contacts
o (^) Accounts
• (^) Fulfill Requirement Items, Questions and Document Uploads
• (^) Enter admission decisions
Other permissions will allow staff members and volunteers to use the solution’s tools to:
• (^) Review submitted applications
• (^) Create an application review record
Note: Access to these different functions do not have to rely on one application administrator.
Permission sets ensure some staff can create Requirement Items while others can use the
Application Review Tool and still others can approve new records prior to their creation.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Navigating the Applications App

The rest of this guide assumes that users are aware of how to navigate in the Lightning UI,
though (naturally) EASY works with both the Lightning and Classic UI.
After installation, you can access EASY via the App Launcher in the Lightning UI or via the App
Picker in the Classic view.

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Introduction to Creating a Dynamic Application

Creating records and sections within applications will evolve as the application process changes
but the core areas include:

**Application Control**

• (^) The Application Control allows for the creation of the application template.
Organizations can customize the application with specific branding and color schemes.
**Requirements**
• (^) The Requirements object is set to outline and manage the requirements for each
application. Requirements serve as a holding object and display as a category on an
application.
**Requirement Items**
• (^) Requirement Items are sub-categories that hold questions, uploads and related object
Checklist items. Multiple Requirement Items can be added/used on a single
Requirement. For an organized applicant interface, each Requirement Item is its own
“page,” making it easy for the applicant to navigate among groups of questions, uploads
and related objects.
**Question Groups**
• (^) Question Groups are used to create one or many questions that are associated with a
Requirement Item.
**Questions**
• (^) These are the individual questions that applicants are expected to answer.
**Related Object Requirement Item**
• (^) Related Object Requirement Items are used to populate objects that relate to the
Contact or Application. These are typically used for resume-builder items (e.g.,
Employment History, Education History, etc.).
**External Requirement Item**

- External Requirement Items are used to give applicants the ability to request an external
  third-party complete part of the application (e.g., letters of recommendation).


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
**Uploads**

• (^) As with any Upload functionality, this allows applicants to upload a document in any
format allowed by the school.
• (^) For flexibility, Uploads have an optional checkbox that includes a Text Area textbox to
appear on the same screen as the document upload feature. In this way, you can allow
applicants to provide information, provide context for or answer a question associated
with each upload.
**Filters**
• (^) Filters are available on both Requirements and Requirement Items. This allows you to
categorize the Requirement, Requirement Item, and Question so they can be
personalized for the applicant and customized to the program.
• (^) Filters are picklists of categories and are set up by a system administrator after
installation. Even though a system administrator must maintain picklists associated with
filters, these are lists that rarely, if ever, change. They are things like your target market

- freshman, transfer, graduate, etc. – and applicant characteristics like resident/non-
  resident, domestic/international, etc. That means these values are set up one time and
  only need to change if you add target markets or some compliance requirements
  change that necessitates an update of the picklist values.

The next section includes instructions on using the tools.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Application Control – Create an Application

The Application Control Tool allows schools to have multiple, distinct applications that are
uniquely branded with controls around whether a term/program question is included and a
cancellation/withdrawal process is offered. Note: While EASY does not require schools to allow
cancellations or withdrawals, the Application Control Tool provides the functionality to
automate this process, perhaps for the first time ever.

Click “New” to create a dynamic and branded application for your organization.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
Complete the following fields:

• (^) Application Control Name (required): Internal name of the application control
• (^) Active checkbox: activate the application control
• (^) URL Parameter (required): organizations can personalize the URL that leads to their
application
• (^) Arrow Color: use HEX code [http://htmlcolorcodes.com;](http://htmlcolorcodes.com;) don’t include “#”; 6 digit code
(progression arrow)
• (^) Button Color: use HEX code as indicated above (save, submit, cancel, withdraw buttons)
• (^) Button Text Color: use HEX code as indicated above to set the color of the text on
buttons
• (^) Line Color: color of lines separating each section
• (^) Link Color: hyperlink color
• (^) Logo Static Resource: name of the static resource in Salesforce that holds the logo
image. Create a static resource by going to Setup>Static Resources. This image’s size will
display as-is on the application, so it may need to be adjusted to fit.
• (^) Logo Static Resource Path: zip folder that contains static resource (may or may not be
used)
• (^) Text Color: use HEX code as indicated above to set the color of the text
• (^) Allow Submit From: when to allow the submit button to appear; values are controlled by
the “Application Status” picklist value set
• (^) Submit Status: the status when the application is submitted
• (^) Allow Cancel From: what application status(es) to allow the cancel button to appear
• (^) Allow Withdraw From: what application status(es) to allow the withdraw button to
appear
• (^) Cancel Status: the status when the application is cancelled
• (^) Withdraw Status: the status when the application is withdrawn
• (^) Default: sets this application control as your organization’s default; this will be used if no
URL parameter is specified
• (^) Application Start Status (required): the status of the application when started
• (^) Hide Term/Program checkbox: the ability to hide the term and program fields when
creating an application (used primarily for non-admissions applications)

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Requirements

The Requirements object is used to organize Requirement Items and are displayed as section
titles on the application. Requirements have the following fields and filters, which dictate when
and to whom the Requirement is displayed on the application:

• (^) Name: Internal name of the Requirement
• (^) Label: Title that will show on the application as a “section” of the application (Name
field shows if this is left blank)
• (^) Active: Whether or not the requirement is active
• (^) Display Order: Order in which the requirement is displayed relative to other
Requirements on the Checklist
• (^) Application Status: The status(es) under which the requirement appears (values
controlled by the “Application Status” picklist value set)
• (^) Viewing Requirement: When checked, the applicant must view this requirement before
submitting an application, even if no part of the requirement is actually required for
submission
• (^) Application Control: The application control record associated to the requirement
• (^) Show on Application Creation: Controls whether the requirement is on the application
creation process or as part of the overall application; this is typically used for basic
identifying information about a student and, importantly, for filtering information
• (^) Application Creation Display Order: Controls whether this requirement shows before or
after the Term/Program questions on the Application Creation page. If left blank, it
defaults to before.
• (^) Internal Only: Controls whether the requirement can only be fulfilled by an internal
Salesforce user (e.g., official transcripts)
• (^) Internal Only Show on Checklist: When checked, an Internal Only requirement will show
on the checklist to display the status to the applicant
• (^) Filters: Value(s) that restricts the conditions under which a requirement appears; if no
value is specified, the requirement will appear for all applications
o (^) Applicant Type: Values controlled by the “Applicant Types” picklist value set; field on
Application is called “Applicant Type”
o (^) Student Type: Values controlled by the “Student Types” picklist value set; field on
Application is called “Student Type”
o (^) Delivery Type: Values controlled by the “Delivery Types” picklist value set; field on
Application is called “Delivery Type”


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
o (^) Citizenship: Values controlled by the “Citizenship Types” picklist value set; field on
Application is called “Citizenship”
o (^) Residency: Values controlled by the “Residency Types” picklist value set; field on
Application is called “Residency”
o (^) Degree Type: Values controlled by the “Degree Types” picklist value set; field on
Program is called “Degree Type”
o (^) School/College: Values controlled by the “School / College” picklist value set; field on
Program is called “School / College”
o (^) Intended Program: Values controlled by records in the “Program” object; field on
Application is called “Intended Program”
Select the “Requirements” tab from the top navigation bar.
On the Requirement object’s home page, you will be shown the Recent Requirement Names.
Click “New.”
Enter the name of the Requirement, enter the display order and select the Active checkbox,
select the application status, application control, set the filters (optional), and click the Save
button.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Requirement Items

A Requirement Item is a holding object that organizes Question Groups, Uploads and Related
Objects within the Requirement. Requirements Items have their own record type. To ensure
Requirements Items are, likewise, dynamically personalized to the applicant and customized for
the program, the same Filters that are on a Requirement also are available on each
Requirement Item.

Requirement Items show as sub-bullets on the application checklist under each Requirement.
Additionally, they each appear as a single-screen within a Requirement “carousel.” This breaks
the application down into smaller section for the student to complete. It also helps the
application with mobile-friendliness.

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Create Requirement Items

Under the “Related” tab of a Requirement, click on “New” next to the Requirement Items
related list. Requirement Items can be a Document Upload, Question Group, or Related Object.

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Properties of Requirement Items

All requirement items have the following properties:

• (^) Name: internal name of the requirement item
• (^) Label: label that displays on the application. Name is used if this is left blank.
• (^) Requirement: lookup to the Requirement that item is associated with
• (^) Active: whether or not the item is active
• (^) Display Order: order in which the item is displayed on the application relative to other
items that are part of the same Requirement
• (^) Required: multi-select picklist of the application status(es) this item is required for; this
is controlled by the “Application Status” picklist value set
• (^) Editable Application Status: multi-select picklist of the application status(es) this item is
editable for; this is controlled by the “Application Status” picklist value set
• (^) Instructions: displayed to the user at the top of the page; HTML is allowed in this field in
order to support hyperlinks and other formatting
• (^) Internal Requirement Item: lookup to a related item that can only be completed by
someone other than the applicant (i.e. recommendation letters or official transcripts)
• (^) Internal Only: if checked, item can only be fulfilled by an internal user (i.e. official
transcripts)
• (^) Internal Only Show on Checklist: if checked, the status of an Internal Only requirement
item will display on the checklist to the applicant
• (^) Internal Only Applicant Instructions: displayed to the user at the top of an Internal Only
requirement item in lieu of the questions/fields that make it up; HTML is allowed in this
field in order to support hyperlinks and other formatting
• (^) Viewing Requirement: when checked, the applicant must view this requirement item
before submitting an application, even if no part of the requirement item is actually
required for submission
• (^) Filters: these function in the same manner as the filters for Requirements (see above)

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Document Uploads

Document uploads have these additional properties:

• (^) File Types: extension(s) allowed for this upload; if none are selected, all extensions will
be allowed; this picklist can be edited by going to the File Types field on the
Requirement Item object in the Object Manager
• (^) Allow Text Entry: if checked, users will be able to enter text in a long text area field in
addition to uploading a document.

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Question Groups

Questions are added to Requirement Items with the Question Group record type. This allows
related questions to be grouped together within a Requirement Item (i.e. the Contact
Information requirement item might include questions for phone numbers, emails, and
addresses). Question Group Requirement Items don’t have any additional properties associated
with them. All the questions are defined using the Question object (explained further down in
this document).

### Related Objects

Related Object Requirement Items are used to populate an organization-specific object that is
related to either the Application or the Contact. This is useful for sections of an application that
have zero-to-many answers (i.e. Enrollment History or Employment History). Additionally, when
the object is related to the Contact, the application will display existing data to the applicant.
This prevents the applicant from having to complete the same information on multiple
applications.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
Related Object Requirement Items come with the following additional properties:

• (^) Related List Object: Object that the data is populated into; picklist controlled by a
system administrator
• (^) Related List Object Master: Object that the Related List Object is related to; options are
“Application” and “Contact”
• (^) Related List Object Master Field: API name of the lookup or master-detail field that ties
together the object and the master object
• (^) Related List Where Clause: SOQL where clause to limit the types of records that
populate in the application’s auto-complete field if this object looks-up to another
object (i.e. Employment History lookup to Account)
• (^) Holding Record Id: Salesforce ID of the record to temporarily tie the new related object
record to if the object looks-up to another object and an existing record is not found (i.e.
new company not already in Salesforce); more details on this below
• (^) Required Number of Children: Minimum number of responses required to fulfill this
Requirement Item (e.g., at least one former school required for Enrollment History)
• (^) Maximum Number of Children: Maximum number of responses allowed (e.g. no more
than three former employers for Employment History).
Many of these fields are used when the related object you’re using is a junction object between
Contact or Application and another Object (e.g. Employment History being a junction object
between Contact and Account). When this is the case, EASY supports type-ahead functionality
to dynamically search for existing records (e.g. existing companies in Salesforce). Sometimes, an
applicant may not find what he/she is looking for and would need to create a new record. EASY
will suspend creation of the record, and it provides a review/approval page for application
administrators to use in order to avoid duplicates and ensure clean data. Details on how new
records can get created are in the section below.
Note: Your system administrator will have to help get these objects created. Each object that
can be used with EASY must have a specific set of fields created. Details on these fields are in
the technical guide. Additionally, your administrator will have to give the community
permission set and/or profile access to any fields/objects exposed to the application as part of
Related Object Requirement Items.

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Questions

Each Question Group can have one or more questions that are associated with it. To create a
new question, go to the “Related” tab on the Requirement Item detail page and click “New”
next to the questions related list. You’ll see a screen that looks like this:


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
This screen is where you choose the type of field you want the question to be:

• (^) Address: this will display all the standard fields for an address according to your
Salesforce settings. If state/country picklists are enabled, they will display here.
Otherwise, state/country will appear as text fields.
• (^) Checkbox: this is a simple checkbox that can either be checked (true) or unchecked
(false)
• (^) Currency: currency in the user’s locale, limited to two places past the decimal
• (^) Date: date formatted in the user’s locale
• (^) Date/Time: date and time represented as one field formatted in the user’s locale
• (^) Email: text field with email address formatting enforced
• (^) Number: number field with maximum of 14 places to the left of the decimal and 4
places past the decimal
• (^) Percent: percent field with maximum of 4 places to the left of the decimal and 4 places
past the decimal
• (^) Phone: text field that is formatted as a phone number
• (^) Picklist: drop-down list of values that a user can select a single value from
• (^) Picklist (Multi-Select): list of values that the user can select multiple values from
(displayed as a series of checkboxes)
• (^) Radio: list of values that a user can select a single value from (useful over a picklist when
each value is long)
• (^) Reference: Represents a lookup or master-detail field (i.e. lookup to Account)
• (^) Static: static text that displays in place of a field
• (^) Text: single-line text box
• (^) Text (Encrypted): single-line text box that is encrypted when stored
• (^) Text Area: multi-line text box up to 255 characters
• (^) Text Area (Long): multi-line text box up to 32,768 characters
• (^) URL: text field that is formatted as a URL


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
Each of these Question types have the following attributes:

• (^) Question Name: internal name of the question (not displayed to the applicant)
• (^) Requirement Item: the Requirement Item that this question is a part of
• (^) Label: the label of the question that gets displayed to the applicant
• (^) Active: if checked, this question is active and displayed on the application
• (^) Display Order: the order in which this question is displayed relative to other questions
within the same question group
• (^) Required: the application status(es) that this question is required to be complete for
• (^) Application Status: the application status(es) that this question displays on
• (^) Editable Application Status: the application status(es) that in which the applicant can
edit his/her answer to this question
• (^) Help Text: text that gets displayed below the question to assist/further explain the
question
• (^) Contact Field: API name of the field on the Contact you want responses to this question
to be mapped to (this is not required). Note: Whatever value the applicant puts in this
question (including null) will overwrite this field on Contact.
• (^) Application Field: API name of the field on the Application you want responses to this
question to be mapped to (this is not required)
• (^) URL Parameter: name of the URL parameter that allows for dynamic prefill of a question
• (^) Filters: these function in the same manner as the filters for Requirements (see above)


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
In addition to these, some Questions have more specific attributes:

• (^) Placeholder: placeholder text for free-text fields
• (^) Length: maximum character length for text fields
• (^) Picklist Values: valid list values for picklist and radio fields
• (^) External Email Field: check this box if this question is being used as the email address for
an external requirement (e.g. the email for a recommender)
• (^) Static Text: this is the text that is displayed as part of a Static Text question type
• (^) Related Object Field: if this question is part of a Related Object Requirement Item, this
holds the API name of the field on the related object that this question maps to
• (^) Name Field API Name: if this question is a Reference question, this field specified the API
name of the field on the related object that gets displayed to the applicant during the
typeahead (defaults to the standard Name field if blank)
• (^) Display as Picklist: if this question is a Reference question, checking this box will display
the question as a picklist instead of a typeahead
• (^) New Reference Field: if this question is part of a Related Object Requirement Item,
checking this box makes the question part of a new record that gets created if an
existing record is not found for a junction object
• (^) Hardcoded Value: if this question is set to display and has a Hardcoded Value, the value
will be populated automatically instead of displaying the question to the applicant
• (^) Lookup Object: for Reference questions, this stores the API name of the object that the
reference field points to
• (^) Lookup Where Clause: for Reference questions, this stores a SOQL WHERE clause that
will limit what records get returned in the type-ahead search

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Question Dependencies

EASY supports showing/hiding Questions based on an applicant’s answers to other Questions.
The logic for this is stored in two places: on the Question itself and in an object called Question
Dependency. Each Question detail page has a section called “Question Dependency
Information” with two fields:

• (^) Dependency Logic: this specifies whether to use AND or OR logic when evaluating the
Question Dependencies (AND is used if nothing specified)
• (^) Dependency Behavior: this specifies whether to Show or Hide this Question when the
Question Dependency logic evaluates to TRUE (Show is used if nothing specified)
Once you set up your Dependency Logic and Dependency Behavior, you’re ready to create a
new Question Dependency. To do this, go to the “Related” tab on the Question you want to
show/hide and click “New” next to the Question Dependencies list. You will then be asked to
choose a Record Type for the dependency:
• (^) Checkbox: choose this if the controlling question is a checkbox
• (^) Multi-Select Picklist: choose this if the controlling question is a multi-select picklist
• (^) Picklist: choose this if the controlling question is a picklist or radio button


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
Once you choose a Record Type, you’ll be presented a screen with two fields:

• (^) Controlling Question: this is a lookup to the Question that controls this Question
• (^) Value: this is the value that the controlling question has to equal for this dependency to
evaluate to TRUE
You can create any number of Question Dependencies for a single Question. The Question will
then show or hide based on the Dependency Logic and Dependency Behavior fields.

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### External Requirement Items

Each Requirement Item can have an “external” Requirement Item associated with it. This is a
Requirement Item that an external user (non-internal and non-applicant) fulfills (i.e. letters of
recommendation).

To create an External Requirement Item, create a new Question Group Requirement Item and a
new “Email” Question with the “External Email” checkbox checked. Then, add other Questions
you want to ask of the applicant (e.g., recommendation provider name, organization, etc.).
After this, navigate to the “Related” tab of the Requirement Item and click “New” next to the
External Requirement Items related list. You can then build out this Requirement Item as you
would any other.

When the Requirement Item is fulfilled from the applicant-side (the application enters the
information and saves it), an email is generated with a unique link for the external user to click
and fulfill the requirement. This link is de-activated if the applicant ever changes the email that
already had been submitted. Applicants can remind external users to complete the requirement
by clicking a “Remind” button on the application. The original request is controlled by the
“External Response Requested” email template and the reminder request is controlled by the
“External Response Reminder” email template.

### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Programs

EASY comes with a Program object to manage what programs applicants can select for their
application. Each program lets you filter at both the program level and the term level. Most of
the filters at the Program level work in the same manner as Requirements, Requirement Items,
and Questions (see above); however, there are a few more filters involved:

• (^) Hide Applicant Type: program will not show up for the applicant type(s) selected
• (^) Hide Student Type: program will not show up for the student type(s) selected
• (^) Hide Citizenship: program will not show up for the citizenship(s) selected
• (^) Hide from Application: program will not show up for any application
• (^) Number of Applications Limit: applicant will be limited on number of applications
he/she can start based on selected value (no limit by default)


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### TERM CONTROLS

EASY provides various ways to open/close application periods for different populations and
programs. The first level of term control is on the Academic Term object:

The application can be opened and closed for a particular term based on the Activate
Application Date and End Application Date fields. To open/close the application for a particular
term based on specific populations and/or programs, navigate to the “Related” tab for a term
and click “New” next to “Intended Program Terms.”

On the record, you can control the open application periods based on a population/program.
This object has a number of fields that let you control who can apply to a program and when:

• (^) Intended Program: The program that is being controlled.
• (^) Academic Term: The term that during which applications are accepted.
• (^) Activate Application Date: The date on which the application is displayed.
• (^) End Application Date: The date on which the application is removed from display.
• (^) Filters: Filters work in the same way as in the sections above; however, if any Intended
Program Terms exist that allow someone to apply for a given program/term on a given
date, then that person will be able to apply.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### ^


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Previewing Requirements

EASY has built-in functionality that allows application administrators to preview the
requirements they’ve built. To do so, navigate to a Requirement and hit the “Preview” button
or select the Preview Action from the drop-down list of Actions.

This will bring up a page that shows a preview of what an individual requirement looks like for
different types of applicants/applications. Users can select values from “filters” at the top of the
screen and see how it affects the requirement at the bottom. The filters displayed here are
controlled by the “Application Preview Filters” change set on the Application object, which can
be customized by a System Administrator. While this feature is a great way to preview what has
been built, we recommend testing the requirement with a test user before going live.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
Note: Question Dependencies and Related Object Requirement Items are not supported by the
preview functionality. Please use a test user to preview these features. (Tip: You can add
periods anywhere in the front part of your Gmail address to make it unique for testing
purposes: john.smith@gmail.com works just the same as johnsmith@gmail.com. What's more,
you can add a plus sign and any word before the @ sign (e.g. johnsmith+test1@gmail.com) and
messages will still reach you. Use this whenever submitting test applications to ensure you have
a unique email address for every test application.)

## THE APPLICATION EXPERIENCE

Applicants will be using the dynamic application to create and manage their applications within
the organization’s community. As delivered, it has two main experiences – application creation
and a checklist. Since the application “portal” can be used separately as a Visualforce page or in
as its default in a Salesforce Community, you can build an entire applicant experience around
EASY.

### Application Creation

To begin the application process, applicants first must navigate to the community where
applications will be initiated. The URL will be created and managed by your organization,
usually the IT or Marketing department. They will use the URL parameter that was created in
the Application Control stage to create the application’s URL.

**New Application = Create an Account**
From here, the student will begin an application. This replaces the standard “create an account”
requirement for most application solutions. There are very few hard-coded questions that are
included with the New Application function and it includes only those needed to create an
account: First Name, Last Name, Email, and Password. Additionally, you can control whether or
not you want to ask for Program and Term via the Application Control Tool. All other fields and
questions shown on this portion of the application can be added as Requirements and
Requirement Items. Importantly, you will want to include filtering questions in this section to
ensure your checklist items are customized for the applicant.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
Below are _sample_ requirements and requirement items that an applicant could see when
completing the application. It’s good practice to add any questions used to filter requirements
to the application/account creation page by adding them under a requirement marked “Show
on Application Creation.” For the filters under the “Filtering Information” section of each object
to work, the corresponding fields on the Application object must be populated (e.g., Student
Type, Residency, etc.). You can do this by adding questions that leverage the “Application Field”
field to map to the Application object (e.g., adding a picklist question that has
“Student_Type__c” in the Application Field).

**Name (first and last are required for account creation)**

**Birthdate (helpful for matching purposes)**


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
**Email and Phone Number(s) (don’t forget to ask about SMS!)**

**Address Information**


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
**Radio Button Question(s)**

**Drop-Down**


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
**Conditional Question(s)**

These questions can be asked based on answers given to previous questions. In this example, if

“Transfer” is selected, additional questions appear to give more detail into the student’s

application.

**Password Creation**


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
## APPLICATION CHECKLIST

Once the applicant creates an account to start an application, he/she will be taken to the
Application Checklist. This is where the applicant can see what requirements he/she has
completed and what still needs to be done. By clicking on the Requirements links in the
checklist, the applicant will be able to complete the Requirement Items (e.g., questions,
uploads, etc.).


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
If the applicant clicks the “Back” button, he/she will be taken to the Application List, where all
applications for the applicant are listed. This is also where the applicant is taken after logging-in
at a later date. From here, the applicant can click on existing applications or create new
applications. The applicant can click the “New Application” button to apply for another
Intended Term of Entry and/or Intended Program. The number of applications someone can
start for a particular program is controlled by the “Number of Applications Limit” field on the
Program object.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
## APPLICATION ADMINISTRATOR VIEW AND REVIEW

### Administrator View

The solution provides an Administrator View that allows staff to view an application the way an
applicant sees it, with a few exceptions. First, administrators can see all requirements available
to the applicant regardless of the application status. This allows administrators to
submit/change requirements without restriction. Additionally, administrators can see and fulfill
the “Internal Only” requirements (e.g. letters of recommendation, official transcripts, etc.) for
requirements that applicants either cannot see or cannot fulfill themselves.

To access the Administrator View, click the “Admin View” action (Lightning) / button (Classic).


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Application Review

The Application Review feature is the native “reader” feature of the solution. Instead of having
to open individual records to review the application package, the Application Review function
brings together all of the application data and links to all uploaded documents in one view.
Moreover, the Application Review allows readers to document the information used in review
(ranking, rating, decision recommendation, etc.). These fields are included at the bottom of the
Application Review screen so readers can view and review the application in one EASY
interface. The fields shown here can be easily managed by your System Administrator through
the “Application Review Header” field set on the Application Review object.

To access the review page, select the “Review” action (in Lightning) or click the “Review” button
(at the top of any application in Classic).


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
## OTHER CONSIDERATIONS

### Storage

Because Requirements are categories of an application under which Requirement Items
(questions/uploads) reside, the answers and documents submitted – called Requirements
Responses – create separate records. Each Requirement Response (answer/document
submission) is a record in the system. To minimize the use of storage, schools may choose to
map some or all responses to fields on the Application object instead of having them create
Requirement Response records. This is done via the “Application Field” field on Question.

Additionally, EASY provides a way to automatically archive all these extra records as an
attached file on the Application itself. Details on how to do this are provided in the technical
documentation. Your System Administrator will be able to help you set up a process to archive
applications.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Data Integrity

Most school admit that their student information system is rife with duplicates and most have
learned that data integrity must be closely guarded to ensure the same thing doesn’t happen
with Salesforce. To assist with this, the solution:

• (^) Offers a checkbox called “New Reference Object” which, along with the use of the
Object Lookup function, provides applicants who cannot find the record they want by
searching with the ability to create a new record. However, that new record is pushed to
a holding table of your choosing to allow you to approve the creation of the record. It
also allows you to make changes to the record before creating it or to relate it to an
existing record. For example, if an applicant cannot find the school from which they
graduated, they are allowed to enter the school (in fields you create as Requirement
Items) and, instead of creating a new record for that school, it is pushed into a holding
table for review. In that way, you can review it, fix mistakes an applicant may have
introduced and then create the new record. Likewise, it allows you search for and find
the school the applicant should have selected and associate the application data with
the existing school to ensure you are not introducing duplicates in the system. This is
even more important when a school has a partnership that includes a corporate rate
and applicants enter an employer name that is a subsidiary, but not the name of the
corporation with which the corporate rate is related. With the New Reference Object
and holding table, you can associate the application with the correct employer to ensure
you know which applicants are associated with partners and are entitled to the
corporate rate. To get to this page, click on the “Related Object Review” tab.
• (^) Includes a staging table that manages submitted application data to match to existing
records, create new records and, when it’s unclear whether a record is new or a match,
it suspends a record for review. This staging table is courtesy of the University of
Miami’s open-source Interactions for Student Recruitment solution.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
### Admissions Office Example

Since it’s often easier to understand the benefits of a solution by putting it into context, this
next section uses a persona to help explain EASY.

**Persona**
Emily is an admissions director at Connected University (CU), where Salesforce is used to
customize an online admissions application tool. Specifically, Emily oversees admissions for the
undergraduate population. Despite being one office, it serves multiple populations, since
undergraduates range from traditional freshman to transfers and adult learners. Moreover,
these applicants can be in-state residents, live in any state in the nation or hale from any
country in the world. For that reason, Emily needs an application that serves a variety of
applicant populations.

**Admission Process**
CU has a central admission process but receives input from select programs and from readers
outside the department. That is, most undergraduate applicants select an intended major as
their program but are, in reality, applying for admission to the university. However, some CU
undergraduate programs allow direct entry and have specific admissions requirements on top
of the university’s standard requirements for admission. Those programs review applications
and make admissions recommendations to the centralized admissions office. Likewise, alumni
volunteer to read applications and make recommendations on admission.

**Post-Decision Process**
Emily’s former application process required separate forms for processes after an admission
decision is made. These include an intent to enroll form and a housing application.

Since CU’s administrators installed the EASY package, Emily has the flexibility to customize the
undergraduate admissions application to fit the needs and requirements specific to
undergraduates.


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
**Benefits**
For the university, the tool allows the department to:

• (^) Create an application that has filtering questions as part of the Account creation process
to set the type of applicant and display subsequent questions using filters
• (^) Create Requirements to have over-arching categories
• (^) Create Requirement Items to have Questions and Uploads within each Requirement
category
• (^) Add filters to Requirements and Requirement Items so the categorized questions and
uploads can be targeted to specific populations, showing only those items specific to the
applicant
• (^) Use lookups to other Salesforce objects to allow applicants to interact with them (e.g.,
allow applicants to search for their high school/college/university in the Account object)
• (^) Brand the application
• (^) Dynamically display requirements based on answers to filtering questions
• (^) Display a real-time Checklist of Requirements and Requirement Items that displays the
status of each Requirement Item
• (^) Select during which status, if at all, a Requirement Item can be edited by the applicant
• (^) Determine which status the application must be in for the applicant to submit it
• (^) Determine the status during which a Requirement and its Requirement Items are
displayed on the application to accommodate its yield and onboarding processes.
For applicants, the tool allows the ability to:
● Start an online admissions application, answering questions, uploading documents and
requesting others to submit requirements on their behalf (e.g., letters of
recommendation)
● Save and return to the application to complete it
● Send a reminder to people they selected to provide a letter of recommendation
● View their progress on their application via a Checklist
● View requirements that are fulfilled by others (e.g., when an official transcript is
received and staff fulfill the Requirement Item via an upload, a checkmark appears by
that Requirement Item)
● View the status of their application status in real-time
● View and complete new requirements based on their application’s status (e.g., admitted
students can have new requirements – like a housing application – that they can
complete without having to login to a different system or submit other forms).


```
Enterprise Application Solution for Yield (EASY)
Open-sourced by Maryville University
```
Among other things, Emily’s office has functionality that allows:

```
● Applicants to search/select/create schools and employers when submitting previous
schooling/employment information
● A staff member to review and approve schools/employers (Accounts) created by the
applicant or associate the newly created record (Account) with an existing record to
avoid duplicates
● Admissions staff to control which questions/requirements apply to which population by
a variety of filters
● Admissions staff to control which questions are mandatory and which are optional for
different programs and/or applicant types
● Admissions staff to employ logic (e.g., and/or operators) to define questions that
show/hide based on answers to other questions
● Admissions staff to define various types of questions (address, picklist, radio, text, text
area, phone, email, date, date/time, number, currency, percent, url, checkbox, multi-
select checkboxes, document upload, etc.)
● Admissions staff to define historical questions about an applicant that can be used
across multiple application submissions (e.g. education history, employment history,
criminal history, etc.)
● Admissions staff to see internal-only Requirements and Requirement Items that are not
displayed to the applicant; or displayed to the applicant without the ability to edit (e.g.,
official transcripts requirement is displayed to the applicant but can be fulfilled only by a
staff member)
● Admissions staff to open/close applications by application Term dates, by level and
other filters, and/or by program
● Admissions staff to modify admissions applications
● Admissions staff to use an administrative view to access the same view the applicant
sees and fulfill Requirements (e.g., upload an official transcript or other documents to
the application)
● Data submitted as part of the application to be associated with objects other than the
Application. In this way, the data can be re-used in subsequent applications, eliminating
the need for applicants to provide the information multiple times (e.g. this could include
education history, employment history, test scores, criminal history, etc.)
● Applicants to cancel an application
● Applicants to withdraw an application after an offer of admission
● Readers to easily review applications and associated materials.
```

