import { api, LightningElement, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountDetail from '@salesforce/apex/AccountListContainerController.getAccountDetail';


export default class AccountDetails extends LightningElement {

    @api accIds;
    @api accFields;
    @track fieldsMap;
    @track account;
    @track currentAccId;
    @track showEditForm;

    @api
    getAccountDetail(accId) {
        if (accId) {
        this.currentAccId = accId;
        this.showEditForm = false;
        getAccountDetail({
            accountId: this.currentAccId,
            accountFieldsList: this.accFields
        }).then(result => {
            console.log('result', result);
                    this.account = result;
                    this.fieldsMap = this.accFields.map((fieldName) => {
                        return {
                            fieldName: fieldName,
                            fieldValue: (this.account[fieldName]) ? this.account[fieldName] : null
                            }
                    });
                    this.showEditForm = true;
            })
            .catch(error => {
                dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        } else {
            this.showEditForm = true;
        }
    }

    get disabledPrev() {
        return (this.accIds && this.currentAccId == this.accIds[0]) ? true : false;
    }

    get disabledNext() {
        return (this.accIds && this.currentAccId == this.accIds[this.accIds.length - 1]) ? true : false;
    }

    handleNext(event) {
        this.save(event);
        const accId = this.currentAccId;
        this.accIds.forEach((item, index, array) => {
            if (item === accId && index < array.length) {
                this.currentAccId = array[index + 1];
            }
        });
        this.getAccountDetail(this.currentAccId);
    }
    
    handlePrev() {
        const accId = this.currentAccId;
        this.accIds.forEach((item, index, array) => {
            if (item === accId && index > 0) {
                this.currentAccId = array[index - 1];
            }
        });
        this.getAccountDetail(this.currentAccId);
    }

    handleSave(event) {
        this.save(event);
        this.template.querySelector('c-log-a-call').handleSave();
    }

    handleSaveCall() {
        this.getAccountDetail(this.currentAccId);
    }

    save(event) {
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'The record is updated!',
                variant: 'success'
            })
        );
    }

    handleError(){
        dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Something went wrong',
                variant: 'error'
            })
        );
    }
}