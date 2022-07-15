# EASY-Open-Source-Solution

Add a brief description of this project here, in Markdown format.
It will be shown on the main page of the project's GitHub repository.

## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `cci org browser dev` to open the org in your browser.

Select the option to allow Digital Experiences. This change will allow for the creation of public sites. If Digital Experiences have already been enabled, no change need to be made.

### 2. Create a Lead creation permission set

Setup > Users > Permission Sets

A permission set needs to be created to allow the guest user to successfully generate new Lead records. A permission set exists in this repo already, but if a new one needs to be created, follow these steps.

* Click the *New* button
* Populate the required fields and save
* Select the *Object Settings* option
* Select the *Leads* option
* Click the *Edit* button
* Enable the Read and Create checkboxes, as well as the Edit Access for each of the fields the form will require then save

### 3. Create a public Site

Setup > User Interface > Sites and Domains > Sites

A Site needs to be created to act as the component's conduit for creating Leads. This requires it to be public and for its public user to have the required permissions.

* Click the *New* button
* Populate the required fields
* Check the *Active* option to immediately deploy the Site

### 4. Attach correct permissions for the Site guest user

Setup > User Interface > Sites and Domains > Sites

After creating the public Site, you should now be on the configuration page for the Site. If not, click on the *Site Label* (the name) of the Site you created.

* Click the *Public Access Settings* button
* Click the *Assigned Users* button
* Click the Full Name of the Site Guest User
* Click the *Edit Assignments* button under the Permission Set Assignments section
* Enable the Permission Set you created earlier and save

### 5. Whitelist your domain(s)

Setup > Security > CORS

The domain that the component will be displayed on needs to be included in the list of allowed CORS rules. This is not the URL of the site we created, but rather the URL of the page that the form will be displayed on.

## Resources

* [Lightning Out](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.lightning_out)
* [CumulusCI](https://cumulusci.readthedocs.io/en/latest/index.html)
* [Lightning Design System](https://www.lightningdesignsystem.com/)
* [Lightning Web Components](https://developer.salesforce.com/docs/component-library/overview/components)
* [Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_top.htm)
