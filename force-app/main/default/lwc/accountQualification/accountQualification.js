import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import ACCOUNT_RECORDTYPE from '@salesforce/schema/Account.RecordTypeId';

export default class AccountQualification extends LightningElement {
    @api recordId;
    @track objectInfo;
    @track recordTypeId;
    @track recordTypeName='';

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_RECORDTYPE] })
    getAccount({ error, data }){
        if(data){
            this.recordTypeId = data.fields.RecordTypeId.value;
            const rtis = this.objectInfo.data.recordTypeInfos;
            console.log(rtis);
            this.recordTypeName = rtis[this.recordTypeId] ? rtis[this.recordTypeId].name : '';
        } else if(error) {
            var result = JSON.parse(JSON.stringify(error));
            console.log('error: ', result);
        }
    };
}