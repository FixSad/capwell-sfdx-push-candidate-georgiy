import { LightningElement, api, track, wire } from "lwc";
import getAccountTeam from "@salesforce/apex/accountTeamController.getAccountTeam";
import getTeams from "@salesforce/apex/accountTeamController.getTeams";
import recordNewActivity from "@salesforce/apex/ActivityController.recordNewActivity";
import { NavigationMixin } from "lightning/navigation";
import {
  createRecord,
  deleteRecord,
  updateRecord
} from "lightning/uiRecordApi";
import TeamName from "@salesforce/schema/Account_Team__c.Name";
import TeamAccount from "@salesforce/schema/Account_Team__c.Account__c";
import TeamObject from "@salesforce/schema/Account_Team__c";
import ContactId from "@salesforce/schema/Contact.Id";
import ContactTeam from "@salesforce/schema/Contact.Account_Team__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import newModal from "c/newLogModal";

const COLUMNS_DEFINITION_BASIC = [
  {
    type: "text",
    fieldName: "name",
    label: "Team Name"
  },
  {
    type: "text",
    fieldName: "title",
    label: "Title"
  },
  {
    type: "phone",
    fieldName: "phone",
    label: "Phone"
  },
  {
    type: "email",
    fieldName: "email",
    label: "Email"
  }
];

export default class AccountTeams extends NavigationMixin(LightningElement) {
  @api recordId;
  @track isModalOpen = false;
  @track data = [];
  @track modalType = "new";
  @track teamOptions = [];
  @track selectedTeam = "";
  @track showActivity = false;
  selectedContact;
  callSubj;
  callDesc;
  callRes;
  @wire(getTeams, { accountId: "$recordId" }) wireTeams({ error, data }) {
    if (data) {
      for (let i = 0; i < data.length; i++) {
        this.teamOptions = [
          ...this.teamOptions,
          { value: data[i].Id, label: data[i].Name }
        ];
      }
    } else if (error) {
      console.log(error);
    }
  }
  teamName = "";
  columns = COLUMNS_DEFINITION_BASIC;

  constructor() {
    super();
    this.columns.push({
      type: "action",
      typeAttributes: { rowActions: this.getRowActions }
    });
  }

  get actionNew() {
    return this.modalType === "new";
  }

  get actionAssign() {
    return this.modalType === "assign";
  }

  connectedCallback() {
    this.loadData();
  }

  @api loadData() {
    this.data = [];
    getAccountTeam({ id: this.recordId })
      .then((result) => {
        let currData = [];
        result.forEach((element) => {
          let obj = {};
          obj.id = element.id;
          obj.name =
            element.name +
            (element.type === "team"
              ? element.children
                ? " - (" + element.children.length + ")"
                : " - (0)"
              : "");
          obj.title = element.title;
          obj.phone = element.phone;
          obj.email = element.email;
          obj.type = element.type;
          obj.team = element.team;
          if (element.children) {
            obj._children = element.children;
          }
          currData.push(obj);
        });
        this.data = currData;
      })
      .catch((error) => {
        this.handleMessage("Error fetching data", error.body.message, "error");
      });
  }

  getRowActions(row, doneCallback) {
    const actions = [];
    if (row.type === "team") {
      actions.push({
        label: "Delete Team",
        iconName: "utility:block_visitor",
        name: "delete"
      });
    } else {
      if (row.team) {
        actions.push({
          label: "Remove from Team",
          iconName: "utility:adduser",
          name: "remove"
        });
      } else {
        actions.push({
          label: "Assign to Team",
          iconName: "utility:adduser",
          name: "assign"
        });
      }
      actions.push({
        label: "View Details",
        iconName: "utility:description",
        name: "view"
      });
      if (row.phone) {
        actions.push({
          label: "Log Call",
          iconName: "utility:call",
          name: "logCall"
        });
      }
      if (row.email) {
        actions.push({
          label: "Send Email",
          iconName: "utility:email",
          name: "sendEmail"
        });
      }
    }
    doneCallback(actions);
  }

  handleRowAction(event) {
    const row = event.detail.row;
    const action = event.detail.action;
    switch (action.name) {
      case "view":
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: row.id,
            actionName: "view"
          }
        });
        break;
      case "delete":
        this.handleDelete(row.id);
        break;
      case "remove":
        this.handleRemove(row.id);
        break;
      case "assign":
        this.handleAssign(row.id);
        break;
      case "logCall":
        this.handleLogCall(row.id);
        break;
      case "sendEmail":
        this[NavigationMixin.Navigate]({
          type: "standard__objectPage",
          attributes: {
            recordId: row.id,
            objectApiName: "Contact",
            actionName: "SendEmail"
          }
        });
    }
  }

  handleAssign(recId) {
    this.modalType = "assign";
    this.selectedContact = recId;
    this.isModalOpen = true;
  }

  handleRemove(recId) {
    const fields = {};
    fields[ContactId.fieldApiName] = recId;
    fields[ContactTeam.fieldApiName] = null;
    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        this.handleMessage("Success", "Contact Removed", "success");
        this.loadData();
      })
      .catch((error) => {
        this.handleMessage(
          "Error updating Contact",
          error.body.message,
          "error"
        );
      });
  }

  handleDelete(recId) {
    deleteRecord(recId)
      .then(() => {
        this.handleMessage("Success", "Record deleted", "success");
        this.loadData();
      })
      .catch((error) => {
        this.handleMessage(
          "Error deleting record",
          error.body.message,
          "error"
        );
      });
  }

  handleNewClick() {
    this.modalType = "new";
    this.isModalOpen = true;
  }

  handleNewContact() {
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Contact",
        actionName: "new"
      },
      state: {
        defaultFieldValues:
          "AccountId=" + this.recordId + ",RecordTypeId=012090000005ydw",
        nooverride: "1"
      }
    });
  }

  closeModal() {
    this.isModalOpen = false;
    this.showActivity = false;
  }

  submitDetails() {
    const fields = {};
    if (this.modalType === "new") {
      fields[TeamName.fieldApiName] = this.teamName;
      fields[TeamAccount.fieldApiName] = this.recordId;
      const recordInput = { apiName: TeamObject.objectApiName, fields };
      createRecord(recordInput)
        .then(() => {
          this.handleMessage("Success", "Account Team created", "success");
          this.loadData();
          this.isModalOpen = false;
        })
        .catch((error) => {
          this.handleMessage(
            "Error creating record",
            error.body.message,
            "error"
          );
        });
    } else if (this.selectedContact) {
      fields[ContactId.fieldApiName] = this.selectedContact;
      fields[ContactTeam.fieldApiName] = this.selectedTeam;
      const recordInput = { fields };
      updateRecord(recordInput)
        .then(() => {
          this.handleMessage(
            "Success",
            "Contact assigned to the Team",
            "success"
          );
          this.selectedContact = undefined;
          this.loadData();
          this.isModalOpen = false;
        })
        .catch((error) => {
          this.handleMessage(
            "Error updating Contact",
            error.body.message,
            "error"
          );
        });
    }
  }

  handleNameChange(event) {
    this.teamName = event.target.value;
  }

  handleTeamChange(event) {
    this.selectedTeam = event.target.value;
  }

  handleMessage(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

  handleEditChange(event) {
    this[event.target.name] = event.target.value;
  }

  async handleLogCall(rowId) {
    let result = await newModal.open({
      size: "medium",
      description: "Create New Tracking Record",
      whatId: this.recordId,
      whoId: rowId
    });
    console.log("Modal", result);
    if (result) {
      recordNewActivity({ newActivity: result })
        .then((res) => {
          if (res === "success") {
            this.handleMessage(
              "Tracking Created",
              "Tracking created successfully",
              "success"
            );
          } else {
            this.handleMessage(
              "Tracking Created",
              "Error occured during Tracking Record Creation",
              "error"
            );
          }
        })
        .catch((error) => {
          console.log(error);
        });
    }
  }
}
