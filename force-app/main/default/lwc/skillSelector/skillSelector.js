import { LightningElement, api, track, wire } from 'lwc';

import searchSkills from '@salesforce/apex/SkillsController.searchSkills';

export default class SkillSelector extends LightningElement {
	@track searchTerm = '';
	@track isLoading = false;
	@track showResults = false;

	@track searchResults = [];

	@wire(searchSkills, {searchTerm: '$searchTerm'})
		performSkillSearch(result) {
			this.isLoading = false;
			if (this.searchTerm === '') {
				this.showResults = false;
				return;
			}
			this.searchResults = result.data ? result.data : [];
			this.showResults = true;
  		}

  	// Called when input text changes
  	handleSearchTermChange(event) {
		// Debouncing this method: do not update the reactive property as
		// long as this function is being called within a delay of 300 ms.
		// This is to avoid a very large number of Apex method calls.
		window.clearTimeout(this.delayTimeout);
		const searchTerm = event.target.value;

		this.delayTimeout = setTimeout(() => {
	  		this.searchTerm = searchTerm;
	  		this.isLoading = true;
		}, 300);
  	}

  	// Called when a skill is clicked to be added, apex code will check
  	// if the skill as already been added before adding it again
  	handleSkillClick(event) {
		var skillId = event.currentTarget.dataset.id;
		var skillName = event.currentTarget.dataset.name;
		this.showResults = false;
		const input = this.template.querySelector('input');
		input.value = '';
		this.dispatchEvent(new CustomEvent('selected', { detail: {skillId: skillId, skillName: skillName} }));
  	}

	get hasSearchResults() {
		return (this.searchResults.length > 0);
	}
}