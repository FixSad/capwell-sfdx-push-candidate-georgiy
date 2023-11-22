import { LightningElement,api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
export default class CLeadLogaCall extends NavigationMixin(LightningElement) {
    @api recordId;
    handleCall(event){
        const config = {
            type: 'standard__webPage',
            attributes: {
                url:  window.location.origin+'/00T/e?title=Call&who_id='+this.recordId+'&followup=1&tsk5=Call&retURL='+this.recordId
            }
        };
        this[NavigationMixin.Navigate](config);
    }    
}