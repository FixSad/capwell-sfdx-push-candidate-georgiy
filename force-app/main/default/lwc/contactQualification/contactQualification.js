import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import CONTACT_RECORDTYPE from '@salesforce/schema/Contact.RecordTypeId';

export default class ContactQualification extends LightningElement {
    @api recordId;
    @track objectInfo;
    @track recordTypeId;
    @track recordTypeName='';

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields: [CONTACT_RECORDTYPE] })
    getContact({ error, data }){
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