import { LightningElement, api, track } from 'lwc';
import getContactAccounts from '@salesforce/apex/accountTeamController.getContactAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Account', fieldName: 'accountName'},
    { label: 'Roles', fieldName: 'Roles'},
    { label: 'Started', fieldName: 'StartDate', type: 'date-local', 
        typeAttributes:{
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: 'Is Direct', fieldName: 'IsDirect', type: 'boolean'}
];


export default class ContactAccounts extends LightningElement {
    _contactId=undefined;
    @track data=[];
    columns = COLUMNS;

	@api
	get contactId() {
		return this._contactId;
	}
	set contactId(value) {
		this._contactId = value;
		this.loadData();
	}

    loadData() {
        getContactAccounts({contactId: this._contactId})
            .then(result => {
                let tmpData = [];
                result.forEach(e => {
                    let tmp={};
                    tmp.accountName = e.Account.Name;
                    tmp.Id = e.Id;
                    tmp.Roles = e.Roles;
                    tmp.accountId = e.AccountId;
                    tmp.IsDirect = e.IsDirect;
                    tmp.StartDate = e.StartDate;
                    tmpData.push(tmp);
                })
                this.data = tmpData;
            })
            .catch(error => {
                console.log(error);
                this.handleMessage('Error loading search results', error.body.message, 'error');
            })
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

    handleRowAction() {

    }
}