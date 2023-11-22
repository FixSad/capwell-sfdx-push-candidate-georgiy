import { LightningElement, api, track } from 'lwc';

export default class MarketList extends LightningElement {
    @api list = [];
    @api selectType='radio';
    @api associatedMarkets = [];
    @track selectedMarkets = [];
    @track selectedMarket;

    @api getSelected() {
        if (this.selectType=='radio') {
            return this.selectedMarket;
        } else {
            return this.selectedMarkets;
        }
    }

    handleSelect(event) {
        if (this.selectType=='radio') {
            this.selectedMarket = event.detail.value;
        } else {
            this.selectedMarkets = event.detail.value;
        }
    }

    get options() {
        return this.list?.list ? this.list.list : [];
    }

    get title() {
        return this.list.name;
    }

    get isRadio() {
        return this.selectType==='radio';
    }
}