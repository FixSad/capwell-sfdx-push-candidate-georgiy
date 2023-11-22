import { LightningElement, api, track } from "lwc";
import getLeads from "@salesforce/apex/homeComponentsController.getLeads";
import getJobs from "@salesforce/apex/homeComponentsController.getJobs";
import getApplicants from "@salesforce/apex/homeComponentsController.getApplicants";
import { NavigationMixin } from "lightning/navigation";
import { deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const actions = [
  //{ label: 'Show details', name: 'view' },
  { label: "Delete", name: "delete" }
];

const leadColumns = [
  {
    label: "Created",
    fieldName: "Created",
    type: "date",
    typeAttributes: {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit"
    }
  },
  { label: "Type", fieldName: "Type__c" },
  {
    label: "Name",
    fieldName: "url",
    type: "url",
    sortable: true,
    typeAttributes: {
      label: { fieldName: "Name" }
    }
  },
  { label: "Title", fieldName: "Title" },
  { label: "Company", fieldName: "Company" },
  { label: "Phone", fieldName: "Phone", type: "phone" },
  { label: "Email", fieldName: "Email", type: "email" },
  { label: "Status", fieldName: "Status" },
  {
    type: "action",
    typeAttributes: { rowActions: actions }
  }
];

const jobsColumns = [
  { label: " ", fieldName: "type" },
  { label: "Rating", fieldName: "rating" },
  {
    label: "Name",
    fieldName: "url",
    type: "url",
    sortable: true,
    typeAttributes: {
      label: { fieldName: "name" }
    }
  },
  { label: "Company", fieldName: "account" },
  { label: "Stage", fieldName: "stageName" },
  { label: "Amount", fieldName: "amount", type: "currency" },
  { label: "Probability", fieldName: "probability", type: "percent" },
  { label: "Close Date", fieldName: "closeDate", type: "date" },
  {
    type: "action",
    typeAttributes: { rowActions: actions }
  }
];

const applicantsColumns = [
  {
    label: "Name",
    fieldName: "url",
    type: "url",
    sortable: true,
    typeAttributes: {
      label: { fieldName: "Name" }
    }
  },
  { label: "Email", fieldName: "email", type: "email" },
  { label: "Phone", fieldName: "phone", type: "phone" },
  { label: "Position", fieldName: "job" },
  { label: "Company", fieldName: "client" },
  { label: "Status", fieldName: "status" },
  {
    type: "action",
    typeAttributes: { rowActions: actions }
  }
];

export default class HomeListComponent extends NavigationMixin(
  LightningElement
) {
  @api type = "My Leads";
  @track data = [];
  @track error;

  get listType() {
    return this.type;
  }

  get columns() {
    switch (this.listType) {
      case "My Leads":
        return leadColumns;
      case "My Jobs":
        return jobsColumns;
      case "My Applicants":
        return applicantsColumns;
    }
  }

  connectedCallback() {
    this.loadData();
  }

  loadData() {
    switch (this.listType) {
      case "My Leads":
        this.loadLeads();
        break;
      case "My Jobs":
        this.loadJobs();
        break;
      case "My Applicants":
        this.loadApplicants();
        break;
    }
  }

  handleRefresh() {
    this.loadData();
  }

  loadLeads() {
    getLeads()
      .then((result) => {
        let currData = [];
        result.forEach((rec) => {
          let obj = this.mapObject(rec);
          obj.Title = rec.Title;
          obj.Phone = rec.Phone;
          obj.Email = rec.Email;
          obj.Status = rec.Status;
          obj.Type__c = rec.Type__c;
          obj.Company = rec.Company;
          obj.Created = rec.CreatedDate;
          currData.push(obj);
        });
        this.data = currData;
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.data = undefined;
      });
  }

  mapObject(rec) {
    let obj = {};
    obj.Id = rec.Id;
    obj.Name = rec.Name;
    obj.url = "/" + rec.Id;
    return obj;
  }

  loadJobs() {
    getJobs()
      .then((result) => {
        let currData = [];
        result.forEach((e) => {
          let obj = this.mapObject(e);
          obj.rating = e.Job_Rating__c;
          obj.account = e.Account ? e.Account.Name : "n/a";
          obj.stageName = e.StageName;
          obj.type = e.recType__c;
          obj.amount = e.Amount;
          obj.probability = e.Probability;
          obj.closeDate = e.CloseDate;
          currData.push(obj);
        });
        this.data = currData;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  loadApplicants() {
    getApplicants()
      .then((result) => {
        this.error = undefined;
        let currData = [];
        result.forEach((e) => {
          let obj = {};
          obj.name = e.Candidate__r ? e.Candidate__r.Name : "n/a";
          obj.email = e.Candidate__r ? e.Candidate__r.Email : "n/a";
          obj.phone = e.Candidate__r ? e.Candidate__r.Phone : "n/a";
          obj.job = e.Job__r ? e.Job__r.Name : "n/a";
          obj.client = e.Job__r.Account ? e.Job__r.Account.Name : "n/a";
          obj.status = e.Status__c;
          currData.push(obj);
        });
        this.data = currData;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  handleRowAction(event) {
    const row = event.detail.row;
    const action = event.detail.action;
    switch (action.name) {
      case "delete":
        deleteRecord(row.Id)
          .then(() => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: "Record deleted",
                variant: "success"
              })
            );
            this.loadData();
          })
          .catch((error) => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error deleting record",
                message: error.body.message,
                variant: "error"
              })
            );
          });
        break;
      case "view":
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: row.Id,
            actionName: "view"
          }
        });
        break;
    }
  }

  handleNew() {
    switch (this.listType) {
      case "My Leads":
        this[NavigationMixin.Navigate]({
          type: "standard__objectPage",
          attributes: {
            objectApiName: "Lead",
            actionName: "new"
          }
        });
        break;
      case "My Jobs":
        this[NavigationMixin.Navigate]({
          type: "standard__objectPage",
          attributes: {
            objectApiName: "Opportunity",
            actionName: "new"
          }
        });
        break;
      case "My Applicants":
        console.log("New Applicant");
    }
  }
}
