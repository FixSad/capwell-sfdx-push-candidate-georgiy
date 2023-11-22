import { LightningElement, track } from 'lwc';

const CURRENT_WEEK = 'CurrentWeek';
const NEXT_WEEK = 'NextWeek';

export default class OverviewInterviewContainer extends LightningElement {

    currentWeek = CURRENT_WEEK;
    nextWeek = NEXT_WEEK ;
    @track
    currentWeekNumber;
    @track
    nextWeekNumber;

    connectedCallback() {
    this.currentWeekNumber = this.getCurrentWeek(); 
    this.nextWeekNumber =  this.currentWeekNumber + 1;
    }

    getCurrentWeek() {
        let date = new Date();
        date.setHours(0, 0, 0, 0);
        date.setDate(date.getDate() + 3 - (date.getDay() + 6) % 7);
        let week1 = new Date(date.getFullYear(), 0, 4);
        return 1 + Math.round(((date.getTime() - week1.getTime()) / 86400000
                              - 3 + (week1.getDay() + 6) % 7) / 7);
    }
    
}