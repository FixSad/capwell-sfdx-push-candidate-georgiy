import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { importCommonStyles } from 'c/sharedLib';

export default class MailshotCanvassing extends LightningElement {
    @track mailshot;
    @track candidateId;
    @track candidateMailshot;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
            this.mailshot = currentPageReference.state.c__mailshot || undefined;
            this.candidateId = currentPageReference.state.c__candidate || undefined;
            this.candidateMailshot = currentPageReference.state.c__candidateMailshot || undefined;
       }
    }

    handleSave() {
        this.template.querySelector('lightning-record-edit-form').submit();
        this.template.querySelector('c-log-a-call').handleSave();
    }


    handleSuccess(event) {
        this.handleMessage('Success', 'Record updated', 'success');
    }

    connectedCallback() {
        importCommonStyles(this);
    }
}