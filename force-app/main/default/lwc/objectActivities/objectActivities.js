import { LightningElement, api, track, wire } from "lwc";
import getActivities from "@salesforce/apex/ActivityController.getActivities";
import recordNewActivity from "@salesforce/apex/ActivityController.recordNewActivity";
import newModal from "c/newLogModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";

const FIELDS = ["Contact.AccountId"];

const columns = [
  {
    label: "Status",
    fieldName: "subType",
    cellAttributes: {
      iconName: { fieldName: "activityIcon" },
      tooltip: { fieldName: "subType" },
      class: { fieldName: "activityClass" }
    }
  },
  {
    label: "Date",
    fieldName: "idURL",
    sort: true,
    type: "url",
    typeAttributes: {
      label: { fieldName: "activityFormated" },
      tooltip: { fieldName: "activityFormated" }
    }
  },
  {
    label: "Contact",
    fieldName: "whoURL",
    type: "url",
    typeAttributes: {
      label: { fieldName: "whoName" },
      target: "_blank",
      tooltip: { fieldName: "whoName" }
    }
  },
  {
    label: "Subject",
    fieldName: "subject"
  },
  {
    label: "Description",
    fieldName: "description"
  },
  {
    label: "Recruiter",
    fieldName: "ownerURL",
    type: "url",
    typeAttributes: {
      label: { fieldName: "ownerName" },
      target: "_blank",
      tooltip: { fieldName: "ownerName" }
    }
  },
  {
    label: "Related",
    fieldName: "whatURL",
    type: "url",
    typeAttributes: {
      label: { fieldName: "whatName" },
      target: "_blank",
      tooltip: { fieldName: "whatName" }
    }
  }
];

export default class ObjectActivities extends LightningElement {
  _whatOrWhoId = undefined;
  columns = columns;

  @track data = [];
  @api recordId;
  @track whatId;

  @api
  get whatOrWhoId() {
    return this._whatOrWhoId;
  }
  set whatOrWhoId(value) {
    this._whatOrWhoId = value;
    this.loadData();
  }
  connectedCallback() {
    if (this.recordId) {
      this.whatOrWhoId = this.recordId;
    }
  }

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredRecord({ error, data }) {
    if (data) {
      this.whatId = data.fields.AccountId?.value;
    } else if (error) {
      console.log("Error", error);
    }
  }

  loadData() {
    getActivities({ whatOrWhoId: this._whatOrWhoId })
      .then((result) => {
        let res = JSON.parse(JSON.stringify(result));
        res = res.map((record) => {
          let activityClass =
            record.status === "Completed"
              ? "slds-text-color_success"
              : "slds-text-color_error";
          return { ...record, activityClass: activityClass };
        });
        this.data = res.map((record) => {
          let activityIcon =
            record.subType === "Email" ? "standard:email" : "standard:call";
          return { ...record, activityIcon: activityIcon };
        });
      })
      .catch((error) => {
        console.log(error);
      });
  }

  async handleNewLog() {
    let result;
    if (this.recordId) {
      if (this.recordId.startsWith("001")) {
        result = await newModal.open({
          size: "medium",
          description: "Create New Tracking Record",
          whatId: this.recordId
        });
      } else {
        result = await newModal.open({
          size: "medium",
          description: "Create New Tracking Record",
          whatId: this.whatId,
          whoId: this.recordId
        });
      }
    } else {
      result = await newModal.open({
        size: "medium",
        description: "Create New Tracking Record",
        whatId: this.whatOrWhoId
      });
    }
    if (result) {
      recordNewActivity({ newActivity: result })
        .then((res) => {
          if (res === "success") {
            this.loadData();
            const event = new ShowToastEvent({
              title: "Tracking Created",
              message: "Tracking Record Created",
              variant: "success"
            });
            this.dispatchEvent(event);
          } else {
            const event = new ShowToastEvent({
              title: "Tracking Created",
              message: "Error occured during Tracking Record Creation",
              variant: "error"
            });
            this.dispatchEvent(event);
          }
        })
        .catch((error) => {
          console.log(error);
        });
    }
  }
}
