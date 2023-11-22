import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CANDIDATE_FIELD from '@salesforce/schema/Applicant__c.Candidate__c';
import JOB_FIELD from '@salesforce/schema/Applicant__c.Job__c';
import CLIENT_FIELD from '@salesforce/schema/Applicant__c.Job__r.AccountId';

const FIELDS = [
    CANDIDATE_FIELD,
    JOB_FIELD,
    CLIENT_FIELD
];

export default class ScheduleInterviewButton extends LightningElement {

    @api objectApiName;
    @api recordId;
    @track candidateId;
    @track jobId;
    @track clientAccountId;

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    wiredRecord({error, data}) {
        if (data) {
          this.applicantObj = data;
          this.candidateId = data.fields.Candidate__c.value;
          this.jobId = data.fields.Job__c.value;
          this.clientAccountId = data.fields.Job__r.value.fields.AccountId.value;
        } else if (error) {
            dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error loading data',
                    variant: 'error'
                })
            );
       }
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave(event) {
        this.closeAction();
        event.preventDefault();       
        const fields = event.detail.fields;
        fields.Applicant__c = this.recordId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess() {
        dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Interview was scheduled successfully',
                variant: 'success'
            })
        );
    }
}