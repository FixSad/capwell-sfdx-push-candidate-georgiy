import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import SKILL_ASSOCIATION from "@salesforce/schema/Skill_Association__c";
import SKILL_LEVEL from "@salesforce/schema/Skill_Association__c.Level__c";
import getAssociatedSkills from '@salesforce/apex/SkillsController.getAssociatedSkills';
import recruitmentResources from '@salesforce/resourceUrl/recruitment';
import createSkillAssociation from '@salesforce/apex/SkillsController.createSkillAssociation';
import updateSkillLevel from '@salesforce/apex/SkillsController.updateSkillLevel';
import removeSkillAssociation from '@salesforce/apex/SkillsController.removeSkillAssociation';

export default class SkillAssociation extends LightningElement {
    @api recordId;
	@api objectApiName;
	@api skillType = 'Primary';

    capwellIcon = `${recruitmentResources}/capwell.png`;

    wiredSkills;
	@track skills = [];

    @wire(getObjectInfo, { objectApiName: SKILL_ASSOCIATION }) SkillAssociationObjectInfo;
	@wire(getPicklistValues, {
	  	recordTypeId: "$SkillAssociationObjectInfo.data.defaultRecordTypeId",
	  	fieldApiName: SKILL_LEVEL
	}) skillLevels;

    get componentTitle() {
		return this.skillType+' Skills';
  	}

  	@wire(getAssociatedSkills, {objectApiName: '$objectApiName', objectId: '$recordId', skillType: '$skillType'})
  		loadReferencedSkills(result) {
			this.wiredSkills = result;
			if (result.data) {
				this.skills = result.data;
			}
		}

    get hasSkills() {
        return (this.skills.length > 0);
    }
    
    handleSelect(event) {
        const skillId = event.detail.skillId;
        const assigned = this.skills.find( ({Id}) => Id === skillId);
        if (!assigned) {
            createSkillAssociation({
                objectApiName: this.objectApiName,
                objectId: this.recordId,
                skillType: this.skillType,
                skillID: skillId,
                skillLevel: this.objectApiName === 'Account' ? null : 'Senior'
            })
            .then(_ => {
                refreshApex(this.wiredSkills);
            })
            .catch(error => {
                this.handleMessage('Error creating record', error.body.message, 'error');
            });
        }
    }

    handleMessage(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
			}),
		);
	}

    // Called when 'x' is clicked on a skill tag
  	handleSkillRemove(event) {
		var skillId = event.currentTarget.dataset.id;
		removeSkillAssociation({
			associationId: skillId
			})
		.then(_ => {
			refreshApex(this.wiredSkills);
		})
		.catch(error => {
			this.handleMessage('Error removing record', error.body.message, 'error');
		});
	}

    handleLevelChange(event) {
		var skillId = event.currentTarget.dataset.id;
		var selectedLevel = event.currentTarget.value;
		updateSkillLevel({
			associationId: skillId,
			level: selectedLevel
		})
		.then(_ => {
			refreshApex(this.wiredSkills);
		})
		.catch(error => {
			this.handleMessage('Error creating record', error.body.message, 'error');
		});
	}

	get isAccountObject() {
		return this.objectApiName === 'Account';
	}
}