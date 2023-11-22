import { LightningElement, api, wire } from 'lwc';
import getShotlistCandidates from "@salesforce/apex/MailshotController.getShotlistCandidates";

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email' },
    { label: 'Phone', fieldName: 'Phone' },
    { label: 'Is Shotlisted', fieldName: 'Shotlisted__c' },
];

export default class ShotlistCandidate extends LightningElement {
    @api recordId;
    @api objectApiName;

    columns = columns;
    data = [];
    
    @wire(getShotlistCandidates, { recordId: "$recordId"})
    fetchDatatableData(result) {
        if (result.data && result.data.length) {
            this.data = result.data.map((item) => ({
                ...item, ...{
                    Shotlisted__c: item.Tasks[0].Shotlisted__c || false
                }
            }));
        }
    };
}