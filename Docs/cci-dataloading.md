# Data loading using CumulusCI

First create a bulk detaloader permission set to avoid access issues (Especially on create/modify dates). You only have to do this
once per org.

```
cci task run create_bulk_data_permission_set --org easy_app_dev
```

Then load your data set. Mapping and sql_path are set to your code base where these files are housed. --org is set
to the persistant org (or scratch org) you have set connected to with comulusCI.

```
cci task run load_dataset -o mapping datasets/fdfdata/mapping.yml -o sql_path datasets/fdfdata/data.sql --org easy_app_dev
```

If you need to connect an org, run the following command. It will connect, via a browser, to an org for authentication of
that org. In this case, "easy_app_dev" is the alias of the connected org and can be whatever you want. --login-url is the
custom domain of the org and will be unique for each org.

```
cci org connect easy_app_dev --login-url https://uofstthomasmn--easyappdev.my.salesforce.com
```

The following command will delete all object data that gets loaded with our EASY app dataset. Use
it at your own risk and never on production. Powerful stuff! Account records often have an address related
record that will need to be deleted manually.

```
cci task run delete_data -o objects Academic_Term__c,Application_Control__c,Interaction_Mapping__c,Plan__c,Staging_Record__c,hed__Language__c,EASY_Widget__c,Program__c,hed__Academic_Certification__c,hed__Program_Plan__c,hed__Term__c,Intended_Program_Term__c,Requirement__c,Requirement_Item__c,Question__c,Question_Dependency__c,Application_Review__c,Application__c,Recommendation__c,Requirement_Response__c,Question_Response__c,CampaignMember,Contact,Education_History__c,Family__c,Opportunity,Work_History__c,hed__Address__c,hed__Affiliation__c,hed__Contact_Language__c,hed__Education_History__c,hed__Test__c,Lead,hed__Program_Enrollment__c,hed__Test_Score__c,Interaction__c -o ignore_row_errors True
```

