import { LightningElement, api, track } from 'lwc';

export default class QualificationQuestion extends LightningElement {
    @track _value;
    @api question;
    @api index;
    @api total;
    @api recordId;
	@api objectApiName;
    @api 
    get value() {
        return this._value ? this._value : '';
    }
    set value(val) {
        this._value = val;
    }

    get isText() {
        return this.question ? this.question.Answer_Type__c === 'Text' : false;
    }

    get isDate() {
        return this.question ? this.question.Answer_Type__c === 'Date' : false;
    }

    get isDropdown() {
        return this.question ? this.question.Answer_Type__c === 'Dropdown' : false;
    }

    get isCheckbox() {
        return this.question ? this.question.Answer_Type__c === 'Checkbox' : false;
    }

    get isMultiselect() {
        return this.question ? this.question.Answer_Type__c === 'Multiselect' : false;
    }

    get isSkill() {
        return this.question ? this.question.Answer_Type__c === 'Skills' : false;
    }

    get questionNumber() {
        return this.index + 1;
    }
    get isLast() {
        return this.index + 1 == this.total ? 'is-last' : '';
    }
    get wrapperClass() {
        return `question-wrapper ${this.isLast}`;
    }

    get formattedDate() {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        const locale = "nl-NL";
        const nDate = new Date(this.value);
        return this.value ? nDate.toLocaleDateString(locale, options) : "Select date";
    }

    get isMinMaxDate() {
        return this.question ? this.question.Answer_Type__c === 'MinMax Date' : false;
    }

    handleChange(event) {
        this.value = event.target.type == "checkbox" ? event.target.checked : event.target.value;
        const questionValue = new CustomEvent('questionvalue', { detail: {Id: this.question.Id, value: this.value} });
        this.dispatchEvent(questionValue);
    }

    get maxValue(){
        let str = this.question?.value;
        return this.question ? (str ? (str.split(/\|/).length>1 ? str.split(/\|/)[1] : '') : '') : '';
    }

    get minValue(){
        let str = this.question?.value;
        return this.question ? (str ? (str.split(/\|/).length>0 ? str.split(/\|/)[0] : '') : '') : '';
    }

    get formattedMinDate() {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        const locale = "nl-NL";
        const nDate = new Date(this.minValue);
        return this.minValue ? nDate.toLocaleDateString(locale, options) : "Select date";
    }

    get formattedMaxDate() {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        const locale = "nl-NL";
        const nDate = new Date(this.maxValue);
        return this.maxValue ? nDate.toLocaleDateString(locale, options) : "Select date";
    }

    handleChangeMultiSelect(event) {
        if (this.question.Answer_Type__c === 'MinMax Date') {
            let minValue = this.template.querySelector(`[data-id="minValue"]`)?.value;
            let maxValue = this.template.querySelector(`[data-id="maxValue"]`)?.value;
            if (minValue && maxValue ) {
                this.value = minValue + '|' + maxValue;
            }
        } else {
            this.value = event.target.type == "checkbox" ? event.target.checked : event.target.value;
        }
        const questionValue = new CustomEvent('questionvalue', { detail: {Id: this.question.Id, value: this.value} });
        this.dispatchEvent(questionValue);
    }
}