import { LightningElement, api, track } from "lwc";
import LightningModal from "lightning/modal";

export default class NewLogModal extends LightningModal {
  @api whoId;
  @api whatId;
  @track isFollowup = false;

  handleSubmit(event) {
    event.preventDefault();
    const fields = event.detail.fields;
    this.close(fields);
  }

  handleFollowup(event) {
    this.isFollowup = !this.isFollowup;
  }

  get showFollowup() {
    return this.isFollowup;
  }

  get disabledlAccount() {
    return this.whoId === undefined;
  }
}
