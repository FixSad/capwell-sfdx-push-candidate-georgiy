import { LightningElement, track, api, wire } from 'lwc';
import getAssociatedMarkets from '@salesforce/apex/MarketController.getAssociatedMarkets';

export default class MarketAssociation extends LightningElement {
    @api recordId;
    @track selectedMarkets = [];

    @wire(getAssociatedMarkets, {accountId: '$recordId'}) wiredAssociation ({error, data}) {
        if (data) {
            let currData = [];
            data.forEach(element => {
                let el = Object.assign({}, element);
                el.title = element.Market_List__r.Name+' ('+element.Market_List__r.Owner.Name+')';
                currData.push(el);

            })
            this.selectedMarkets = currData;
        } else if (error) {
            console.log('Error', error);
        }
    }

    get hasMarkets() {
        return true;
    }
}