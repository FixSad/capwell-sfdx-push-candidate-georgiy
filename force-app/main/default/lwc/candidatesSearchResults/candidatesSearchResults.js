import { LightningElement, api, track } from "lwc";
import addCandidateMailshot from "@salesforce/apex/candidatesSearchController.addCandidateMailshot";

const columns = [
  {
    label: "Name",
    fieldName: "url",
    type: "url",
    sortable: true,
    typeAttributes: {
      label: { fieldName: "name" }
    }
  },
  { label: "Email", fieldName: "email", type: "email" },
  { label: "Phone", fieldName: "phone", type: "phone" },
  { label: "City", fieldName: "city" },
  { label: "Title", fieldName: "title" },
  { label: "Account", fieldName: "account" },
  { label: "Type", fieldName: "jobType" }
  //{ label: 'Is Manager', fieldName: 'isManager', type: 'boolean'},
  //{ label: 'Employable', fieldName: 'isEmployable', type: 'boolean'},
  /*{ label: 'Last Mailshot', fieldName: 'LastMailshot__c', type: 'date-local', 
        typeAttributes:{
            month: "2-digit",
            day: "2-digit"
        }
    }*/
];

const columnsLocation = [
  {
    label: "Name",
    fieldName: "url",
    type: "url",
    sortable: true,
    typeAttributes: {
      label: { fieldName: "name" }
    }
  },
  { label: "Email", fieldName: "email", type: "email" },
  { label: "Phone", fieldName: "phone", type: "phone" },
  { label: "City", fieldName: "city" },
  { label: "Title", fieldName: "title" },
  { label: "Account", fieldName: "account" },
  { label: "Type", fieldName: "jobType" },
  //{ label: 'Is Manager', fieldName: 'isManager', type: 'boolean'},
  //{ label: 'Employable', fieldName: 'isEmployable', type: 'boolean'},
  /*{ label: 'Last Mailshot', fieldName: 'LastMailshot__c', type: 'date-local', 
        typeAttributes:{
            month: "2-digit",
            day: "2-digit"
        }
    },*/
  {
    label: "Distance (KM)",
    fieldName: "distance",
    type: "number",
    typeAttributes: {
      step: "0.1",
      minimumFractionDigits: "1",
      maximumFractionDigits: "1"
    }
  },
  {
    label: "Location (KM)",
    fieldName: "geolocation",
    type: "number",
    typeAttributes: {
      step: "0.1",
      minimumFractionDigits: "1",
      maximumFractionDigits: "1"
    }
  }
];

export default class CandidatesSearchResults extends LightningElement {
  @api searchResults = [];
  @api selectedRows = [];
  @api mailShotId;
  @api showDistance = false;

  columns = columns;
  columnsLocation = columnsLocation;

  get hasResults() {
    return this.searchResults ? this.searchResults.length > 0 : false;
  }

  get getTotal() {
    return this.searchResults ? this.searchResults.length : 0;
  }

  getSelectedRows(event) {
    this.selectedRows = event.detail.selectedRows;
  }
  get hasSelectedRows() {
    return this.selectedRows ? this.selectedRows.length > 0 : false;
  }

  handleAddMailshot() {
    if (this.mailShotId && this.selectedRows) {
      let idList = this.selectedRows.map((e) => e.id);
      addCandidateMailshot({ mailShotId: this.mailShotId, candidates: idList })
        .then((result) => {
          this.dispatchEvent(new CustomEvent("refresh"));
        })
        .catch((error) => {
          console.log("Error", error);
        });
    }
  }
}
