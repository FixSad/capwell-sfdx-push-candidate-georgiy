import { LightningElement, api, track } from 'lwc';

export default class CapwellMultiselect extends LightningElement {
    @api question;
    @track options;

    getalphabets(index) {
        let i = 0;
        return [...Array(26)].map(_=>(++i).toString(36),i=9)[index];
    }

    connectedCallback() {
        if (this.question) {
            if (this.question.Answer_Options__c) {
                let tmpList = [];
                this.question.Answer_Options__c.forEach((q, index)=>{
                    tmpList.push({value: q.value, id: this.question.Id+'-'+q.value, checked: this.question.value ? this.question.value.toLowerCase().includes(q.value) : false, index: this.getalphabets(index)});
                })
                this.options = tmpList;
            }
        }        
    }

    handleChange(event) {
        this.options.find( ({value}) => value === event.target.dataset.targetId).checked = event.target.checked;
        const res = this.options.filter(({checked}) => checked === true);
        this.dispatchEvent(new CustomEvent('multiselectvalue', { detail: {Id: this.question.Id, value: res.map(e=>e.value).join(';')} }));
    }
}