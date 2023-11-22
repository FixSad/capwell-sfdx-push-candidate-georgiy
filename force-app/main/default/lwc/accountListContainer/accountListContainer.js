import { api, wire, LightningElement, track } from "lwc";
import getAccountNames from "@salesforce/apex/AccountListContainerController.getAccountNames";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AccountListContainer extends LightningElement {
  @api accFields = [];
  @track accountIds = [];
  @track accounts;
  @track selectedItem;

  get isEmptyFields() {
    let accFields = this.accFields;
    return accFields && !accFields.length;
  }

  get isEmptyAccountIds() {
    let accountIds = this.accountIds;
    return accountIds && !accountIds.length;
  }

  @api
  getAccountNames(accIds) {
    getAccountNames({
      accountIdList: accIds
    })
      .then((result) => {
        if (result && result.length != 0) {
          this.accounts = [...result];
          this.accountIds = this.accounts.map((acc) => {
            return acc.Id;
          });
          this.selectedItem = this.accounts[0].Id;
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
  }

  handleSelect(event) {
    if (this.selectedItem) {
      this.selectedItem = event.detail.name;
      this.template
        .querySelector("c-account-details")
        .getAccountDetail(this.selectedItem);
    }
  }

  handleSelectedItem(event) {
    let currentAccountId = event.detail;
    this.selectedItem = String(currentAccountId);
  }
}
