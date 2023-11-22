import { LightningElement, api, wire, track } from "lwc";
import getResults from "@salesforce/apex/MailshotController.mailShotCandidatesResults";
import { NavigationMixin } from "lightning/navigation";
const COLUMNS = [
  {
    label: "Name",
    fieldName: "contactURL",
    type: "url",
    sortable: true,
    typeAttributes: {
      label: { fieldName: "contactName" }
    }
  },
  { label: "Email", fieldName: "contactEmail", type: "email" },
  { label: "Phone", fieldName: "contactPhone", type: "phone" },
  {
    label: "Sent",
    fieldName: "mailSent",
    type: "date",
    typeAttributes: {
      year: "2-digit",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit"
    }
  },
  { label: "Sent to", fieldName: "sentTo", type: "email" },
  {
    label: "First Opened",
    fieldName: "firstOpen",
    type: "datetime" /*, 
        typeAttributes:{
            year: "2-digit",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }*/
  },
  {
    label: "Last Opened",
    fieldName: "lastOpen",
    type: "datetime" /*, 
        typeAttributes:{
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }*/
  },
  { label: "Is Opened", fieldName: "IsOpened", type: "boolean" },
  { label: "Is Bounced", fieldName: "IsBounced", type: "boolean" },
  { label: "Is Canvassed", fieldName: "IsCanvassed", type: "boolean" },
  { label: "Is Replied", fieldName: "IsReplied", type: "boolean" }
];

export default class MailshotCandidatesResult extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @track results = [];
  @track allValues = [];
  @track loaded = false;
  columns = COLUMNS;
  statusFilterValue = "all";

  options = [
    { label: "All", value: "all" },
    { label: "Sent", value: "sent" },
    { label: "Opened", value: "opened" },
    { label: "Bounced", value: "bounced" },
    { label: "Canvassed", value: "canvassed" }
  ];

  constructor() {
    super();
    this.columns.push({
      type: "action",
      typeAttributes: { rowActions: this.getRowActions }
    });
  }

  connectedCallback() {
    this.loadData();
  }

  loadData() {
    this.loaded = false;
    getResults({ mailshot: this.recordId, filter: this.statusFilterValue })
      .then((result) => {
        this.results = result;
        this.loaded = true;
      })
      .catch((error) => {
        console.log(error);
        this.loaded = true;
      });
  }

  get hasResults() {
    return this.results ? this.results.length : false;
  }

  get getTotal() {
    return this.results ? this.results.length : 0;
  }

  handleRowAction(event) {
    switch (event.detail.action.name) {
      case "canvassing":
        this[NavigationMixin.Navigate]({
          type: "standard__component",
          attributes: {
            componentName: "c__mailshotCanvassingAura"
          },
          state: {
            c__mailshot: this.recordId,
            c__candidate: event.detail.row.contactId,
            c__candidateMailshot: event.detail.row.mailshotRef
          }
        });
        break;
      case "newcandidate":
        this[NavigationMixin.Navigate]({
          type: "standard__objectPage",
          attributes: {
            objectApiName: "Contact",
            actionName: "new"
          },
          state: {
            defaultFieldValues: "Email=" + event.detail.row.sentTo,
            nooverride: "1"
          }
        });
        break;
      default:
        break;
    }
  }

  getRowActions(row, doneCallback) {
    const actions = [];
    if (row["contactId"] && row["mailSent"]) {
      //!row['IsCanvassed'] &&
      actions.push({
        label: "Canvassing",
        iconName: "utility:edit",
        name: "canvassing"
      });
    } else if (!row["contactId"] && !row["IsBounced"]) {
      actions.push({
        label: "Create Candidate",
        iconName: "utility:adduser",
        name: "newcandidate"
      });
    }
    setTimeout(() => {
      doneCallback(actions);
    }, 200);
  }

  handleStatusFilter(event) {
    this.statusFilterValue = event.detail.value;
    this.loadData();
  }
}
