import { LightningElement, wire, api } from 'lwc';
import { getSObjectValue } from '@salesforce/apex';
import findByContactId from '@salesforce/apex/ResumeController.findByContactId';

import TEXT_FIELD from '@salesforce/schema/Resume__c.Text__c';

export default class ResumeInfo extends LightningElement {
    @api recordId;
    @api objectApiName;

    @wire(findByContactId, {recordId: '$recordId'}) resume;

    get text() {
        return this.resume.data ? getSObjectValue(this.resume.data, TEXT_FIELD) : '';
    }
}