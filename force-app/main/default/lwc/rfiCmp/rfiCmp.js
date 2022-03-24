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

  handleLoad (event) {
    this.loading = false
  }

  handleSubmit (event) {

  }
}