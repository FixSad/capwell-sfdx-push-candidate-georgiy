import { LightningElement, track, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import recruitmentResources from "@salesforce/resourceUrl/recruitment";
import getAssociatedSkills from "@salesforce/apex/SkillsController.getAssociatedSkills";
import getSkillGroups from "@salesforce/apex/SkillsController.getAllGroups";
import JOB_REF from "@salesforce/schema/Mailshot__c.Job__c";
import ACCOUNT_ShippingLatitude from "@salesforce/schema/Mailshot__c.Job__r.Account.ShippingLatitude";
import ACCOUNT_ShippingLongitude from "@salesforce/schema/Mailshot__c.Job__r.Account.ShippingLongitude";
import ACCOUNT_ShippingCity from "@salesforce/schema/Mailshot__c.Job__r.Account.ShippingCity";
import searchCandidates from "@salesforce/apex/candidatesSearchController.searchCandidates";

export default class CandidatesSearch extends LightningElement {
  @api recordId;
  @track primarySkills = [];
  @track secondarySkills = [];
  @track searchResults = [];
  @track wiredResults;
  @track usingLocation = false;
  @track usingGeolocation = false;
  @track selectedType = "all";
  @track skillGroup = "all";
  @track isLoading = false;
  @track hasGeolocation = false;
  typeOptions = [
    { value: "all", label: "All" },
    { value: "none", label: '"None" type' },
    { value: "temp", label: "Freelance" },
    { value: "perm", label: "Permanent" },
    { value: "both", label: "Freelance & Permanent" }
  ];
  keyword;
  radius = 10;
  location;
  clientLatitude;
  clientLongitude;
  capwellIcon = `${recruitmentResources}/capwell.png`;
  @track skillGroupOptions = [{ label: "All", value: "all" }];
  skillGroupsRAW = [];

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      JOB_REF,
      ACCOUNT_ShippingLatitude,
      ACCOUNT_ShippingLongitude,
      ACCOUNT_ShippingCity
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
      this.clientLatitude =
        data.fields.Job__r.value.fields.Account.value.fields.ShippingLatitude.value;
      this.clientLongitude =
        data.fields.Job__r.value.fields.Account.value.fields.ShippingLongitude.value;
      this.hasGeolocation = this.clientLatitude && this.clientLongitude;
      this.location =
        data.fields.Job__r.value.fields.Account.value.fields.ShippingCity.value;
      getAssociatedSkills({
        objectApiName: "Opportunity",
        objectId: data.fields.Job__c.value,
        skillType: ""
      })
        .then((result) => {
          result.forEach((element) => {
            if (element.Type__c === "Primary") {
              this.primarySkills.push({
                id: element.Skill__c,
                name: element.Skill__r.Name
              });
            } else {
              this.secondarySkills.push({
                id: element.Skill__c,
                name: element.Skill__r.Name
              });
            }
          });
        })
        .catch((error) => {
          this.handleMessage("Error loading mailshot data", error, "error");
        });
    }
  }

  @wire(getSkillGroups) wireSkillGroup({ error, data }) {
    if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      this.handleMessage("Error loading mailshot data", error, "error");
    } else if (data) {
      this.skillGroupsRAW = data;
      let _skillGroupOptions = [{ label: "All", value: "all" }];
      data.forEach((item) => {
        _skillGroupOptions.push({ label: item.Name, value: item.Id });
      });
      this.skillGroupOptions = _skillGroupOptions;
    }
  }

  handleSelectPrimary(event) {
    const selected = this.primarySkills.find(
      ({ id }) => id === event.detail.skillId
    );
    if (!selected) {
      const skill = {
        id: event.detail.skillId,
        name: event.detail.skillName
      };
      this.primarySkills.push(skill);
    }
  }

  handleSelectSecondary(event) {
    const selected = this.secondarySkills.find(
      ({ id }) => id === event.detail.skillId
    );
    if (!selected) {
      const skill = {
        id: event.detail.skillId,
        name: event.detail.skillName
      };
      this.secondarySkills.push(skill);
    }
  }

  handleSkillRemovePrimary(event) {
    const skillId = event.currentTarget.dataset.id;
    this.primarySkills = this.primarySkills.filter(
      (item) => item.id !== skillId
    );
  }

  handleSkillRemoveSecondary(event) {
    const skillId = event.currentTarget.dataset.id;
    this.secondarySkills = this.secondarySkills.filter(
      (item) => item.id !== skillId
    );
  }

  get hasPrimarySkills() {
    return this.primarySkills.length > 0;
  }

  get hasSecondarySkills() {
    return this.secondarySkills.length > 0;
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
    this.isLoading = true;
    var skillIds = [];
    this.primarySkills.forEach((e) => skillIds.push(e.id));
    searchCandidates({
      primarySkills: skillIds,
      keywords: this.keyword,
      mailShotId: this.recordId,
      selectedType: this.selectedType,
      radius: this.usingLocation ? this.radius : null,
      latitude: this.usingLocation ? this.clientLatitude : null,
      longitude: this.usingLocation ? this.clientLongitude : null,
      usingGeolocation: this.usingGeolocation
    })
      .then((result) => {
        this.searchResults = result;
        this.isLoading = false;
      })
      .catch((error) => {
        console.log("Error", error);
        this.handleMessage(
          "Error loading search results",
          error.body.message,
          "error"
        );
        this.isLoading = false;
      });
  }

  handleValueChange(event) {
    this[event.currentTarget.name] = event.currentTarget.value;
    if (
      event.currentTarget.name == "skillGroup" &&
      event.currentTarget.value != "all"
    ) {
      let selectedGroup = this.skillGroupsRAW.filter(
        (item) => item.Id === event.currentTarget.value
      );
      if (selectedGroup) {
        if (selectedGroup[0].Skill_Group_Associations__r) {
          selectedGroup[0].Skill_Group_Associations__r.forEach((skill) => {
            const _tmpSkill = {
              id: skill.Professional_Skill__r.Id,
              name: skill.Professional_Skill__r.Name
            };
            this.primarySkills.push(_tmpSkill);
          });
        }
      }
    }
  }

  handleRefresh() {
    this.handleSearch();
  }

  handleLocation() {
    this.usingLocation = !this.usingLocation;
    this.usingGeolocation = this.usingLocation ? this.usingGeolocation : false;
  }

  handleGeolocation() {
    this.usingGeolocation = !this.usingGeolocation;
  }

  handleTypeChange(event) {
    this.selectedType = event.target.value;
  }

  handleClearPrimarySkills() {
    this.primarySkills = [];
  }

  handleClearSecondarySkills() {
    this.secondarySkills = [];
  }

  get noGeolocation() {
    return !this.hasGeolocation;
  }
}
