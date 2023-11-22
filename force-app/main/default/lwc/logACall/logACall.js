import { LightningElement, api, track } from 'lwc';
import saveCallLog from '@salesforce/apex/contactCanvassingController.saveCallLog';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class LogACall extends LightningElement {

    @api title;
    @api whatId;
    @api whoId;
    @api tskSubj;
    @track tskFollow = false;
    @track tskFollowDate = undefined;
    @track tskComments = '';
    @track isApplicant = false;
    @track value = 'New';

    get options() {
        return [
            { label: 'New', value: 'New' },
            { label: 'Open', value: 'Open' },
            { label: 'In Progress', value: 'InProgress' },
            { label: 'Completed', value: 'Completed' },
        ];
    }

    handleApplicantStatus(event) {
        this.value = event.detail.value;
    }

    handleEditChange(event) {
        if (event.target.type=='checkbox') {
            this[event.target.name] = event.target.checked;
        } else {
            this[event.target.name] = event.target.value;
        }
    }

    handleApplicantChange() {
        this.isApplicant = !this.isApplicant;
    }

    @api
    handleSave() {
        saveCallLog({
            whatId: this.whatId, 
            contactId: this.whoId, 
            status: this.value, 
            comments: this.tskComments,
            subject: this.tskSubj, 
            followUp: this.tskFollow,
            folloUpDate: this.tskFollowDate
        }).then(() => {
                this.handleMessage('Success', 'Call Log Registered', 'success');
                this.dispatchEvent(new CustomEvent('savecall'));
            })
            .catch(error => {
                this.handleMessage('Error logging the call', error.body.message, 'error');
            });
    }

    handleMessage(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
			}),
		);
	}

}