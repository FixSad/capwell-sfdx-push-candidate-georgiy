import { LightningElement, api, track } from 'lwc';

export default class CapwellCombobox extends LightningElement {
  @api label;
  @api value;
  @api options;
  @api placeholder = 'Select an option';
  @track openDropDown = false;

  toggleMenu() {
    this.openDropDown = !this.openDropDown;
  }

  closeMenu() {
    setTimeout(() => {
      this.openDropDown = false;
    }, 300)
  }

  handleClick(event) {
    this.value = event.currentTarget.dataset.id;
    this.dispatchEvent(new CustomEvent('valuechange', { detail: {value: this.value} }));
    
  }

  get dropDownClass() {
    return (this.openDropDown ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open" : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click");
  }
}