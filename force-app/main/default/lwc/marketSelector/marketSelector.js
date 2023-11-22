import { LightningElement, track, api, wire } from 'lwc';
import getMarkets from '@salesforce/apex/MarketController.getMarkets';

export default class MarketSelector extends LightningElement {
    @track isModalOpen=false;
    @api selectedMarkets;
    @api selectType = 'radio';
    @track distinctMarkets = [];

    @wire(getMarkets) wiredMarkets ({error, data}) {
        if (data) {
            let currentDistinct = [];
            data.forEach(element => {
                let market = currentDistinct.find(item => item.name == element.Owner.Name);
                if (market) {
                    market.list.push({label: element.Name, value: element.Id});
                } else {
                    currentDistinct.push({name: element.Owner.Name, list: [{label: element.Name, value: element.Id}]});
                }
            });
            this.distinctMarkets = currentDistinct;
        } else if (error) {
            console.log(error);
        }
    }

    handleShowDialog() {
        this.selectedOther = [];
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    submitDetails() {
        let lists = this.template.querySelectorAll("c-market-list");
        let selected = [];
        if (this.selectType=='radio') {
            lists.forEach(element => {
                selected.push(element.getSelected());
            });
        } else {
            lists.forEach(element => {
                selected.push(...element.getSelected());
            });
        }
        let selectedMarkets = [];
        selected.forEach(element => {
            this.distinctMarkets.forEach(market => {
                if (market.list) {
                    market.list.forEach(item => {
                        if (element === item.value) {
                            selectedMarkets.push({id: item.value, name: item.label+' ('+market.name+')'});
                        }
                    })
                }
            })
        })
        this.dispatchEvent(new CustomEvent('marketsselected', {detail: selectedMarkets}));
        this.isModalOpen = false;
    }

    handleMarketSelect(event) {
        this.selectedOther = event.detail.value;
    }
}