import { LightningElement, api, track } from 'lwc';
import getClientLists from '@salesforce/apex/AccountListContainerController.getClientLists';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class ClientsList extends LightningElement {

    @api userId;
    @track result;
    @track selectedItem;
    @track clientListMap;
    @track clientListArr;

    connectedCallback(){
        this.getClientLists();  
    }

    @api
    getClientLists(useId) {
        if (useId) {
            this.userId = useId;
        }
        getClientLists({
            userId: this.userId
        }).then(result => {
                if (result && result.length != 0) {
                    this.clearValues();
                    this.result = result;
                    this.result.forEach((clientList) => {
                        this.clientListArr.push({
                            Id: clientList.Id,
                            Name: clientList.Name,
                            NumberOfAcc: clientList.Client_List_Associations__r ? clientList.Client_List_Associations__r.length : 0
                        });
                        this.clientListMap.set(clientList.Id, clientList);
                    });
                    if (this.clientListArr.length) {
                        this.selectedItem = this.clientListArr[0].Id;
                    }
                    this.fireSelectListEvent();
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

    clearValues() {
        this.clientListMap = new Map();
        this.clientListArr = [];
    }

    handleSelect(event) {
        this.selectedItem = event.detail.name;
        this.fireSelectListEvent();
    }

    fireSelectListEvent() {
        if (this.selectedItem) {
            let clientList = this.clientListMap.get(this.selectedItem);
            let currentAccIds = clientList.Client_List_Associations__r ? clientList.Client_List_Associations__r.map(item => item.Account__c) : undefined;
            let clientListArr = [];
            this.clientListArr.forEach((cl) => {
                if (cl.Id != clientList.Id) {
                    clientListArr.push(cl);
                }
            });
            let detailObj = {
                currentIds: currentAccIds, 
                userClientLists: clientListArr, 
                selectedClientListId: clientList.Id
            };
            this.dispatchEvent(new CustomEvent('selectlist', {detail: detailObj}));
        }
    }

}