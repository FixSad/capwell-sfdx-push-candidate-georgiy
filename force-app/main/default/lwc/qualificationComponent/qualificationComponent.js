import { LightningElement, wire, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getQuestions from "@salesforce/apex/qualificationController.getQuestions";
import saveAnswers from "@salesforce/apex/qualificationController.saveAnswers";
import getStatuses from "@salesforce/apex/qualificationController.getStatuses";
import getRecordStatus from "@salesforce/apex/qualificationController.getRecordStatus";
import { updateRecord } from "lightning/uiRecordApi";

export default class QualificationComponent extends LightningElement {
  @api objectApiName;
  @api recordId;
  @api recordTypeName = "Freelance";
  @track completedStatuses = [];
  @track pathSteps = [];
  @track activeStep = "New";
  @track filteredQuestions = [];
  @track questions = [];
  @track objectStatuses = [];
  dataLoaded = false;
  isChanged = false;
  autosaveInterval;
  @track autosaveSetup = false;

  @track isModalOpen = false;

  handleQualification() {
    this.isModalOpen = true;
  }

  closeModal() {
    this.isModalOpen = false;
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

  get hasStatuses() {
    return this.completedStatuses && this.objectStatuses;
  }

  handleStep(event) {
    this.activeStep = event.detail;
    this.filteredQuestions = this.questions.filter((question) => {
      return question.Stage_Value__c === this.activeStep;
    });
  }

  renderedCallback() {
    if (this.recordId && !this.dataLoaded) {
      this.loadData();
      if (!this.autosaveSetup) {
        this.autosaveInterval = setInterval(
          function () {
            if (this.isModalOpen) {
              this.saveData();
            }
          }.bind(this),
          60000
        );
        this.autosaveSetup = true;
      }
    }
  }

  loadData() {
    getStatuses({ objectName: this.objectApiName })
      .then((result) => {
        this.objectStatuses = result;
      })
      .catch((error) => {
        console.log(error);
        this.handleMessage("Error loading data", error.body.message, "error");
      });
    getRecordStatus({ objectName: this.objectApiName, Id: this.recordId })
      .then((result) => {
        this.completedStatuses = result ? result.split(";") : [];
      })
      .catch((error) => {
        console.log(error);
        this.handleMessage("Error loading data", error.body.message, "error");
      });
    getQuestions({
      objectName: this.objectApiName,
      Id: this.recordId,
      recordTypeName: this.recordTypeName
    })
      .then((result) => {
        let tmpList = [];
        let statusList = new Set();
        result.forEach((e) => {
          if (e.Stage_Value__c) {
            statusList.add(e.Stage_Value__c);
          }
          let rec = {
            Id: e.Id,
            Answer_Options__c: [],
            Answer_Type__c: e.Answer_Type__c,
            Question__c: e.Question__c,
            Stage_Value__c: e.Stage_Value__c,
            Use_in_Summary__c: e.Use_in_Summary__c,
            isActive__c: e.isActive__c,
            Description__c: e.Description__c,
            isRequired__c: e.isRequired__c,
            fieldApiName: e.Field_Name__c,
            value: e.Qualification_Answers__r
              ? e.Qualification_Answers__r[0].Answer__c
              : undefined, //add handler for multiselect
            valueId: e.Qualification_Answers__r
              ? e.Qualification_Answers__r[0].Id
              : undefined,
            isChanged: false
          };
          if (
            (e.Answer_Type__c === "Dropdown" ||
              e.Answer_Type__c === "Multiselect") &&
            e.Answer_Options__c
          ) {
            let options = e.Answer_Options__c.split(";");
            options.forEach((a) => {
              rec.Answer_Options__c.push({ label: a.trim(), value: a.trim() });
            });
          }
          tmpList.push(rec);
        });
        this.questions = tmpList;
        if (this.objectStatuses && tmpList.length) {
          this.objectStatuses = this.objectStatuses.filter((e) => {
            return statusList.has(e);
          });
          this.activeStep = this.objectStatuses[0];
          this.filteredQuestions = this.questions.filter((question) => {
            return question.Stage_Value__c === this.activeStep;
          });
        }
        this.dataLoaded = true;
      })
      .catch((error) => {
        console.log(error);
        this.handleMessage("Error loading data", error.body.message, "error");
      });
  }

  handleValueChange(event) {
    this.questions.find(({ Id }) => Id === event.detail.Id).value =
      event.detail.value;
    this.questions.find(({ Id }) => Id === event.detail.Id).isChanged = true;
  }

  saveData() {
    let tmpList = [];
    let updateFields = {};
    this.questions.forEach((q) => {
      if (q.isChanged && q.Answer_Type__c != "Skills") {
        //
        let tmpObj = {
          Qualification_Question__c: q.Id,
          Id: q.valueId,
          Answer__c: q.value
        };
        tmpObj[this.objectApiName + "__c"] = this.recordId;
        tmpList.push(tmpObj);
        if (q.fieldApiName) {
          updateFields[q.fieldApiName] = q.value;
        }
      }
    });
    if (tmpList.length) {
      saveAnswers({
        objectName: this.objectApiName,
        answers: JSON.stringify(tmpList)
      })
        .then((result) => {
          if (updateFields) {
            updateFields["Id"] = this.recordId;
            updateRecord({ fields: updateFields })
              .then((result) => {
                this.handleMessage(
                  "Qualification updated",
                  "Qualification answers are saved",
                  "success"
                );
              })
              .catch((e) => {
                this.handleMessage(
                  "Error loading data",
                  e.body.message,
                  "error"
                );
                console.log("Error:", error.body.message);
              });
          } else {
            this.handleMessage(
              "Qualification updated",
              "Qualification answers are saved",
              "success"
            );
          }
        })
        .catch((error) => {
          this.handleMessage("Error loading data", error.body.message, "error");
          console.log("Error:", error.body.message);
        });
    }
  }

  disconnectedCallback() {
    clearInterval(this.autosaveInterval);
  }

  closeAction() {
    this.saveData();
    this.isModalOpen = false;
  }
}
