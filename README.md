# admissions-rfi

Add a brief description of this project here, in Markdown format.
It will be shown on the main page of the project's GitHub repository.

## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `cci org browser dev` to open the org in your browser.

## Lightning out steps

### Create site

* Preferences - Allow guest users to access public APIs - Checked
* Preferences - Let guest users view asset files and CMS content available to the site
* Settings - Activate

### TODO

* Verify that there is a guest user tied to the site
* Make sure that there is a permission set tied to the site that includes the necessary read/write perms