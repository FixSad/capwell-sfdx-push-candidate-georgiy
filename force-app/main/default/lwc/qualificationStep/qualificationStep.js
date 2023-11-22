import { LightningElement, api } from 'lwc';

export default class AccountQualificationStep extends LightningElement {
    @api item;
    @api statuses;
    @api activeStep;

    handleClick(event){
        const selectedStep = new CustomEvent('selectedstep', { detail: event.target.dataset.name });
        this.dispatchEvent(selectedStep);
    }

    get isCompleted() {
        return (this.item && this.statuses) ? this.statuses.includes(this.item) : false;
    }

    get isActive() {
        return this.item ? this.item==this.activeStep : false;
    }
}