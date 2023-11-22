import { LightningElement, api, track, wire } from "lwc";
import getCanvasingAccounts from "@salesforce/apex/MarketOverviewController.getCanvasingAccounts";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import refreshCanvas from "@salesforce/messageChannel/refreshCanvas__c";

export default class CanvasingAccount extends LightningElement {
  @api recordId;
  subscription = null;

  @track accounts;
  @track selectedItem;

  @wire(MessageContext) messageContext;

  connectedCallback() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        refreshCanvas,
        (message) => this.loadData(),
        { scope: APPLICATION_SCOPE }
      );
    }
    if (this.recordId) {
      console.log("canvasing account", this.recordId);
    } else {
      this.loadData();
    }
  }

  loadData() {
    let accounts = sessionStorage.getItem("accIDs");
    console.log(accounts);
    if (accounts) {
      getCanvasingAccounts({ IDs: accounts.split(",") })
        .then((result) => {
          this.accounts = result;
          this.selectedItem = this.accounts[0].Id;
        })
        .catch((error) => {
          console.log(error);
        });
    }
  }

  handleSelect(event) {
    this.selectedItem = event.detail.name;
    let teams = this.template.querySelector("c-account-teams");
    if (teams) {
      teams.loadData();
    }
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  handleNext() {
    let idx = 0;
    if (this.accounts) {
      for (let i = 0; i < this.accounts.length; i++) {
        if (this.selectedItem === this.accounts[i].Id) {
          idx = i + 1;
          break;
        }
      }
      this.selectedItem =
        idx < this.accounts.length
          ? this.accounts[idx].Id
          : this.accounts[this.accounts.length - 1].Id;
    }
  }

  handlePrev() {
    let idx = 0;
    if (this.accounts) {
      for (let i = 0; i < this.accounts.length; i++) {
        if (this.selectedItem === this.accounts[i].Id) {
          idx = i - 1;
          break;
        }
      }
      this.selectedItem =
        idx >= 0 ? this.accounts[idx].Id : this.accounts[0].Id;
    }
  }
}
