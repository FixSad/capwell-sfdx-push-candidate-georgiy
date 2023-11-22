import { LightningElement, track } from 'lwc';
import hasPermission from '@salesforce/customPermission/Client_All_List';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUsers from '@salesforce/apex/MarketOverviewController.getUsers';
import Id from '@salesforce/user/Id';

export default class MarketOverview extends LightningElement {

    @track userId = Id;
    @track accountIds = [];
    @track accFields = ['Name', 'Rating', 'BillingCity', 'Phone', 'Email__c', 'Account_Region__c', 'LastModifiedDate'];
    @track userNames = [{ label: 'Only my lists', value: Id }];
    @track showDropdown;
    @track userClientLists;
    @track currentClientListId;
    result;

    connectedCallback () {
        if (hasPermission) {
            this.getUsers();
        }
    }
    
    getUsers() {
        getUsers().then(result => {
                if (result) {
                    this.result = new Map(Object.entries(result));
                    this.result.forEach((label, value) => {
                        this.userNames.push({label: label, value: value});
                    });
                    this.showDropdown = true;
                }
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
    }

    handleChange(event) {
        this.userId = event.detail.value;
        this.template.querySelector('c-clients-list').getClientLists(this.userId);
    }

    onSelectList(event) {
        this.accountIds = event.detail.currentIds;
        this.userClientLists =  event.detail.userClientLists;
        this.currentClientListId = event.detail.selectedClientListId;
        this.template.querySelector('c-accounts-table').getAccounts(this.accountIds);
    }

    hadleMoveAccounts() {
        this.template.querySelector('c-clients-list').getClientLists(this.userId);
    }
}