import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import getNextRecord from "@salesforce/apex/MailshotController.getNextRecord";
import getTotalRecords from "@salesforce/apex/MailshotController.getTotalRecords";
import saveCallLog from "@salesforce/apex/MailshotController.saveCallLog";
import toggleShortListStatus from "@salesforce/apex/MailshotController.toggleShortListStatus";

import STATUS_FIELD from "@salesforce/schema/Task.Call_Status__c";

const TASK_RECORD_TYPE_ID = '0125g0000000XD9';

export default class MailshotListing extends NavigationMixin(LightningElement) {
  @api recordId;
  @api objectApiName;

  contactId = null;
  contactFields = ["Name", "Phone", "Email"];
  status = "";
  comments = "";
  shortlist = '';
  pagination = { offset: 0, total: 0 };

  @wire(getNextRecord, { recordId: "$recordId", offset: 0 })
  loadNextRecord(result) {
    if (result.data && result.data.length) {
      this.contactId = result.data[0].WhoId;
      this.shortlist = result.data[0].Shotlisted__c == true ? 'yes' : 'no';
      this.pagination.offset++;
    }
  }

  @wire(getPicklistValues, { recordTypeId: TASK_RECORD_TYPE_ID, fieldApiName: STATUS_FIELD })
  statusPicklist;

  async connectedCallback() {
    this.pagination.total = await getTotalRecords({ recordId: this.recordId });
  }

  handleStatusChange(event) {
    this.status = event.detail.value;
  }

  handleNext() {
    if (!this.hasNext) {
      return;
    }

    this.pagination.offset++;

    getNextRecord({
      recordId: this.recordId,
      offset: this.pagination.offset
    }).then((result) => {
      if (result && result.length) {
        this.contactId = result[0].WhoId;
        this.shortlist = result[0].Shotlisted__c == true ? 'yes' : 'no';
      }
    });
  }

  handlePrev() {
    if (!this.hasPrev) {
      return;
    }

    this.pagination.offset--;

    getNextRecord({
      recordId: this.recordId,
      offset: this.pagination.offset
    }).then((result) => {
      if (result && result.length) {
        this.contactId = result[0].WhoId;
        this.shortlist = result[0].Shotlisted__c == true ? 'yes' : 'no';
      }
    });
  }

  viewRecord() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.contactId,
        objectApiName: "Contact",
        actionName: "view"
      }
    });
  }

  handleCommentInput(event) {
    this.comments = event.target.value;
  }

  submit() {
    saveCallLog({
      mailshotId: this.recordId,
      contactId: this.contactId,
      status: this.status,
      comments: this.comments
    })
      .then((_) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Done!",
            message: "Call logged successfully.",
            variant: "success"
          })
        );
        this.status = "";
        this.comments = "";
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error saving call log",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }

  handleShortlistSelection(event) {
    this.shortlist = event.detail.value;
    toggleShortListStatus({
      mailshotId: this.recordId,
      contactId: this.contactId,
      value: this.shortlist
    })
      .then((_) => {
        let msg = this.shortlist == 'yes'
          ? 'Candidate successfully added to short list.'
          : 'Candidate successfully removed from short list.'
        
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Done!",
            message: msg,
            variant: "success"
          })
        );
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error adding to short list",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }

  get hasNext() {
    return this.pagination.offset < this.pagination.total - 1;
  }

  get hasPrev() {
    return this.pagination.offset > 0;
  }

  get hasRecord() {
    return !!this.contactId;
  }

  get shotlistOptions() {
    return [
        { label: 'Yes', value: 'yes' },
        { label: 'No', value: 'no' },
    ];
}
}