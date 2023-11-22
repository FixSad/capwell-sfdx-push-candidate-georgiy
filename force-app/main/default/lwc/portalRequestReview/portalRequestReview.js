import { LightningElement, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getAllRequests from "@salesforce/apex/candidateReviewController.getAllRequests";
import getRequestMergeData from "@salesforce/apex/candidateReviewController.getRequestMergeData";
import rejectRequest from "@salesforce/apex/candidateReviewController.rejectRequest";
import approveRequest from "@salesforce/apex/candidateReviewController.approveRequest";

export default class PortalRequestReview extends LightningElement {
  @track requests;
  @track requestsError;
  @track selectedItem;
  @track currentRequest;

  @wire(getAllRequests)
  wiredRequests({ error, data }) {
    if (data) {
      this.requests = data;
      this.selectedItem = this.requests[0].Id;
      this.requestsError = undefined;
    } else if (error) {
      this.requestsError = error;
      this.requests = undefined;
    }
  }

  handleSelect(event) {
    this.selectedItem = event.detail.name;
    getRequestMergeData({ requestId: this.selectedItem })
      .then((result) => {
        console.log("Result", result);
        this.currentRequest = result;
      })
      .catch((error) => {
        console.log("Error", error);
        this.currentRequest = undefined;
      });
  }

  handleReject() {
    rejectRequest({ requestId: this.selectedItem })
      .then((result) => {
        refreshApex(this.wiredRequests);
        console.log("Result", result);
      })
      .catch((error) => {
        console.log("Error", error);
      });
  }

  handleApprove() {
    approveRequest({ requestId: this.selectedItem })
      .then((result) => {
        refreshApex(this.wiredRequests);
        console.log("Result", result);
      })
      .catch((error) => {
        console.log("Error", error);
      });
  }
}
