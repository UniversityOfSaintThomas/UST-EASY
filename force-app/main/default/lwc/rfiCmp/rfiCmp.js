import { LightningElement } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Lead.Name';
import EMAIL_FIELD from '@salesforce/schema/Lead.Email';
import PHONE_FIELD from '@salesforce/schema/Lead.Phone';
import MOBILEPHONE_FIELD from '@salesforce/schema/Lead.MobilePhone';
import COMPANY_FIELD from '@salesforce/schema/Lead.Company';

export default class RfiCmp extends LightningElement {
  objectApiName = 'Lead'

  nameField = NAME_FIELD
  emailField = EMAIL_FIELD
  phoneField = PHONE_FIELD
  mobilePhoneField = MOBILEPHONE_FIELD
  companyField = COMPANY_FIELD

  loading = true
  success = false

  handleLoad (event) {
    this.loading = false
  }

  // Overriding handleSubmit to display our own submission message for now
  // https://trailblazer.salesforce.com/issues_view?id=a1p3A000001GN1gQAG&title=community-guest-user-may-see-the-error-the-requested-resource-does-not-exist-while-creating-record-from-community-using-the-lightning-recordeditform
  handleSubmit (event) {
    this.success = true
  }
}