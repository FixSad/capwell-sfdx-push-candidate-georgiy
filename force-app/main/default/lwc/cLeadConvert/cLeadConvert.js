import { LightningElement,api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class CLeadConvert extends NavigationMixin(LightningElement) {
    @api recordId;
    handleConvertLead(event){

        const config = {
            type: 'standard__webPage',
            attributes: {
                url:  window.location.origin+'/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId='+this.recordId
            
            }
        };
        this[NavigationMixin.Navigate](config);
    }       
}