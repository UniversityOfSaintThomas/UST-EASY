import { LightningElement } from 'lwc';
import FIRSTNAME_FIELD from '@salesforce/schema/Lead.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Lead.LastName';
import EMAIL_FIELD from '@salesforce/schema/Lead.Email';
import PHONE_FIELD from '@salesforce/schema/Lead.Phone';
import MOBILEPHONE_FIELD from '@salesforce/schema/Lead.MobilePhone';
import COMPANY_FIELD from '@salesforce/schema/Lead.Company';

export default class RfiCmp extends LightningElement {
  objectApiName = 'Lead'
  fields = [FIRSTNAME_FIELD, LASTNAME_FIELD, EMAIL_FIELD, PHONE_FIELD, MOBILEPHONE_FIELD, COMPANY_FIELD]
}