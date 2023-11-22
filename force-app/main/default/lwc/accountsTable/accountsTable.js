import { LightningElement, track, api, wire } from "lwc";
import getAccounts from "@salesforce/apex/AccountsTableController.getAccounts";
import moveAccounts from "@salesforce/apex/AccountsTableController.moveAccounts";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { publish, MessageContext } from "lightning/messageService";
import refreshCanvas from "@salesforce/messageChannel/refreshCanvas__c";

const columns = [
  { label: "Rating", fieldName: "Rating", fixedWidth: 90 },
  {
    label: "Company",
    fieldName: "accountLink",
    type: "url",
    typeAttributes: { label: { fieldName: "Name" }, target: "_blank" }
  },
  { label: "City", fieldName: "BillingCity", type: "text" },
  { label: "Phone", type: "phone", fieldName: "Phone" },
  { label: "Email", type: "email", fieldName: "Email__c" },
  { label: "Region", fieldName: "Account_Region__c" },
  { label: "Last Edited", fieldName: "LastModifiedDate", type: "date" }
];
const modalColumns = [{ label: "Name", fieldName: "Name" }];

export default class AccountsTable extends NavigationMixin(LightningElement) {
  @api accFields = [];
  @api userClientLists;
  @api currentClientListId;

  @track result;
  @track filteredResult;
  @track accIds;
  @track accId;
  @track searchKey = "";
  @track showModal = false;
  @track selectedAccountIds = [];
  @track clientListIdForInsertAs;
  @track disabledModalMove = true;
  @track disabledMove = true;

  columns = columns;
  modalColumns = modalColumns;
  keyChange = this.debounce(this._keyChange);
  modalTitle = "Select a Client List";

  get placeholder() {
    return `Filter results`;
  }

  @wire(MessageContext) messageContext;

  @api
  getAccounts(accIds) {
    if (accIds) {
      this.accIds = accIds;
      getAccounts({
        accountIdList: this.accIds,
        accountFieldsList: this.accFields
      })
        .then((result) => {
          if (result && result.length) {
            let tmpRes = JSON.parse(JSON.stringify(result));
            tmpRes.forEach((e) => {
              e.accountLink = "/" + e.Id;
            });
            this.result = tmpRes;
            this.filteredResult = this.result;
          }
        })
        .catch((error) => {
          dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: error.body.message,
              variant: "error"
            })
          );
        });
    } else {
      this.result = [];
      this.filteredResult = [];
    }
  }

  handleClickButton(event) {
    console.log(event.detail.row);
    this.accId = event.detail.row.Id;
  }

  handleSelectAccs(event) {
    this.disabledMove = true;
    const selectedRows = event.detail.selectedRows;
    if (selectedRows.length > 0) {
      this.selectedAccountIds = selectedRows.map((item) => item.Id);
      this.disabledMove = false;
    }
  }

  handleKeyChange({ target: { value = "" } }) {
    this.keyChange(value);
  }

  debounce(func, timeout = 350) {
    let timer;
    return (...args) => {
      clearTimeout(timer);
      timer = setTimeout(() => func.apply(this, args), timeout);
    };
  }

  _keyChange(searchTerm) {
    this.searchKey = searchTerm;
    this.searchKey == ""
      ? (this.filteredResult = this.result)
      : this.getResult();
  }

  getResult() {
    this.filteredResult = [];
    this.filteredResult = this.result.filter((c) =>
      c.Name.toLowerCase().includes(this.searchKey.toLowerCase())
    );
  }

  handleSelectClientList(event) {
    this.disabledModalMove = false;
    this.clientListIdForInsertAs = event.detail.selectedRows[0].Id;
  }

  switchShowModal() {
    this.showModal = !this.showModal;
  }

  handleMoveButton() {
    this.disabledModalMove = true;
    if (this.selectedAccountIds.length > 0) {
      this.switchShowModal();
    }
  }

  async moveAccounts() {
    try {
      await moveAccounts({
        clientListIdForInsertAs: this.clientListIdForInsertAs,
        accountIdList: this.selectedAccountIds,
        clientListIdForDeleteAs: this.currentClientListId
      });
      dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "The Accounts were moved successfully.",
          variant: "success"
        })
      );
      this.switchShowModal();
      this.dispatchEvent(new CustomEvent("move"));
    } catch (error) {
      dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: error.body.message,
          variant: "error"
        })
      );
    }
  }

  handleCanvasing() {
    if (
      Array.isArray(this.selectedAccountIds)
        ? this.selectedAccountIds.length
        : false
    ) {
      sessionStorage.setItem("accIDs", this.selectedAccountIds);
      const payload = { messageToSend: "refresh", sourceSystem: "AccountList" };
      publish(this.messageContext, refreshCanvas, payload);
      this[NavigationMixin.Navigate]({
        type: "standard__navItemPage",
        attributes: {
          apiName: "Accounts_Canvasing"
        }
      });
    } else {
      dispatchEvent(
        new ShowToastEvent({
          title: "Warning",
          message: "Select companies for canvasing",
          variant: "info"
        })
      );
    }
  }
}
