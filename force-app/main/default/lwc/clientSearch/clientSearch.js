import { LightningElement, track, wire, api } from "lwc";
import recruitmentResources from "@salesforce/resourceUrl/recruitment";
import getAssociatedSkills from "@salesforce/apex/SkillsController.getAssociatedSkills";
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CANDIDATE_REF from "@salesforce/schema/Mailshot__c.Candidate__c";
import CANDIDATE_MailingLatitude from "@salesforce/schema/Mailshot__c.Candidate__r.MailingLatitude";
import CANDIDATE_MailingLongitude from "@salesforce/schema/Mailshot__c.Candidate__r.MailingLongitude";
import CANDIDATE_MailingCity from "@salesforce/schema/Mailshot__c.Candidate__r.MailingCity";
import searchClients from "@salesforce/apex/clientSearchController.searchClients";
import addClientsToMailshot from "@salesforce/apex/clientSearchController.addClientsToMailshot";
import ACCOUNT_REF from "@salesforce/schema/Account";
import ACCOUNT_REGION from "@salesforce/schema/Account.Account_Region__c";

const GRID_Columns = [
  {
    type: "text",
    fieldName: "name",
    label: "Name",
    initialWidth: 300
  },
  {
    type: "text",
    fieldName: "title",
    label: "Title",
    initialWidth: 300
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
  },
  {
    type: "text",
    fieldName: "team",
    label: "Team"
  },
  {
    type: "number",
    fieldName: "distance",
    label: "Distance"
  }
];

export default class ClientSearch extends LightningElement {
  @api recordId;
  @track selectedSkills = [];
  @track usingLocation = false;
  @track searchResults = [];
  capwellIcon = `${recruitmentResources}/capwell.png`;
  radius = 10;
  location;
  contactLatitude;
  contactLongitude;
  selectedRegion;
  @track regions;
  @track markets = [];

  resultGridColumns = GRID_Columns;

  @wire(getObjectInfo, { objectApiName: ACCOUNT_REF }) accountInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$accountInfo.data.defaultRecordTypeId",
    fieldApiName: ACCOUNT_REGION
  })
  accountRegionValues({ error, data }) {
    if (data) {
      let options = [];
      options.push({ label: "All", value: "all" });
      data.values.forEach((e) => {
        options.push(e);
      });
      this.regions = options;
      this.selectedRegion = "all";
    } else {
      console.log(error);
    }
  }

  handleSelectSkill(event) {
    const selected = this.selectedSkills.find(
      ({ id }) => id === event.detail.skillId
    );
    if (!selected) {
      const skill = {
        id: event.detail.skillId,
        name: event.detail.skillName
      };
      this.selectedSkills.push(skill);
    }
  }

  get hasSkillsSelected() {
    return this.selectedSkills.length > 0;
  }

  handleSkillRemove(event) {
    const skillId = event.currentTarget.dataset.id;
    this.selectedSkills = this.selectedSkills.filter(
      (item) => item.id !== skillId
    );
  }

  handleLocation() {
    this.usingLocation = !this.usingLocation;
  }

  handleValueChange(event) {
    this[event.currentTarget.name] = event.currentTarget.value;
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      CANDIDATE_REF,
      CANDIDATE_MailingLatitude,
      CANDIDATE_MailingLongitude,
      CANDIDATE_MailingCity
    ]
  })
  wiredMailshot({ error, data }) {
    if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      this.handleMessage("Error loading mailshot data", error, "error");
    } else if (data) {
      this.contactLatitude =
        data.fields.Candidate__r.value.fields.MailingLatitude.value;
      this.contactLongitude =
        data.fields.Candidate__r.value.fields.MailingLongitude.value;
      this.location = data.fields.Candidate__r.value.fields.MailingCity.value;
      getAssociatedSkills({
        objectApiName: "Contact",
        objectId: data.fields.Candidate__c.value,
        skillType: "Primary"
      })
        .then((result) => {
          result.forEach((element) => {
            this.selectedSkills.push({
              id: element.Skill__c,
              name: element.Skill__r.Name
            });
          });
        })
        .catch((error) => {
          this.handleMessage("Error loading mailshot data", error, "error");
        });
    }
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

  handleSearch() {
    let skillIds = [];
    this.selectedSkills.forEach((e) => skillIds.push(e.id));
    let marketIDs = [];
    this.markets.forEach((e) => marketIDs.push(e.id));
    searchClients({
      skills: skillIds,
      mailShotId: this.recordId,
      radius: this.usingLocation ? this.radius : null,
      latitude: this.usingLocation ? this.contactLatitude : null,
      longitude: this.usingLocation ? this.contactLongitude : null,
      region: this.selectedRegion === "all" ? "" : this.selectedRegion,
      markets: marketIDs ? (marketIDs.length ? marketIDs : null) : null
    })
      .then((result) => {
        let currData = [];
        result.forEach((element) => {
          let obj = {};
          obj.id = element.id;
          obj.name = element.name;
          obj.type = element.type;
          obj.distance = element.distance;
          if (element.children) {
            obj._children = element.children;
          }
          currData.push(obj);
        });
        this.searchResults = currData;
      })
      .catch((error) => {
        console.log("Error", error);
        this.handleMessage(
          "Error loading search results",
          error.body.message,
          "error"
        );
      });
  }

  get hasResults() {
    return this.searchResults ? this.searchResults.length : false;
  }

  handleAdd() {
    const selectedRows = this.template
      .querySelector("lightning-tree-grid")
      .getSelectedRows();
    let contactsToAdd = [];
    selectedRows.forEach((e) => {
      if (e.type == "contact" && e.email) {
        contactsToAdd.push(e.id);
      } else {
        if (e.hasChildren) {
          this.searchResults.forEach((s) => {
            if (s.id == e.id) {
              s._children.forEach((ch) => {
                if (ch.email) {
                  contactsToAdd.push(ch.id);
                }
              });
            }
          });
        }
      }
    });
    let cleanContacts = [...new Set(contactsToAdd)];
    if (cleanContacts.length) {
      addClientsToMailshot({
        contacts: cleanContacts,
        mailshotId: this.recordId
      })
        .then((result) => {
          //TO-DO: Show Toast with Success
          console.log("Result", result);
        })
        .catch((error) => {
          console.log("Error", error);
        });
    }
  }

  handleRegionChange(event) {
    this.selectedRegion = event.currentTarget.value;
  }

  handleSelectMarkets(event) {
    this.markets = event.detail;
  }

  handleMarketRemove(event) {}

  get marketsSelected() {
    return this.markets ? this.markets.length : false;
  }
}
