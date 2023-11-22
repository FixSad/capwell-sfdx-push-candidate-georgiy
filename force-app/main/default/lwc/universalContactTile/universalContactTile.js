import { api, wire, track, LightningElement } from 'lwc';
import getContactDetail from '@salesforce/apex/UniversalContactTileController.getContactDetail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS =  ['Name','MailingAddress','Title', 'Account.Name'];

export default class UniversalContactTile extends LightningElement {

    fields = FIELDS;

    @api recordId;

    @track contact;
    @track name;
    @track contactLink;
    @track title;
    @track accName;
    @track location;
    @track skillsString;
    @track avatar;
    @track withoutAvatar = true;

    @wire(getContactDetail, {contactId: '$recordId', conFieldsList: '$fields'})
    getContactDetail({error, data}) {
        if (data) {
            this.contact = data;
            this.name = this.contact.Name;
            this.contactLink = '/' + this.contact.Id;
            this.title = (this.contact.Title) ? this.contact.Title : '';
            this.accName = (this.contact.AccountId) ? this.contact.Account.Name : null;
            this.location = (this.contact.MailingAddress) ? this.contact.MailingAddress.city : '';
            if (this.contact.Skill_Associations__r) {
                this.setSkills(this.contact.Skill_Associations__r);
            }    
        } else if (error) {
            dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error loading data',
                    variant: 'error'
                })
            );
       }
    }

    /*setAvatarHTML(avatarField) {
        let tempArr = avatarField.split('"');
        this.avatar = '"' + tempArr[1] + '"';
        let avatarHTML = `<img src=` + this.avatar + `alt="Contact Image" width="48" height="48"/>`;
        this.template.querySelector('.avatar').innerHTML = avatarHTML;
        this.withoutAvatar = false;
    }*/

    setSkills(skillsAssociations) {
        const skillsArr = skillsAssociations.map(skill => skill.Skill__r.Name);
        this.skillsString = skillsArr.join(', ');
        if (this.skillsString.length > 179) {
            let tempSkillsArr = this.skillsString.substring(1, 179).split(',');
            tempSkillsArr.pop();
            this.skillsString = tempSkillsArr.join(', ') + ' ...';
        }
    }
}