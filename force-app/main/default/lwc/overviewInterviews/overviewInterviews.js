import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInterviewsMap from '@salesforce/apex/OverviewInterviewsController.getInterviewsMap';

const COLUMNS = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
];

export default class OverviewInterviews extends LightningElement {

    columns = COLUMNS;

    @api week;
    @api weekNumber;
    @track interviewMap;
    @track cells = [];

    @wire(getInterviewsMap, {week:'$week'})
    getInterviewsMap(response) {
        let error = response && response.error;
        let data = response && response.data;
        if (data) {
            this.interviewMap = new Map(Object.entries(data));
            for (var i = 1, max = 7; i <= max; i++) {
                let day = this.interviewMap.get(i.toString()); 
                if (day) {
                    const interviewsForTheDay = day.map(interview => {
                        const inter = {};
                        inter.Name = interview.Name;
                        inter.Id = '/' + interview.Id;
                        inter.CandidateName = interview.Candidate__r.LastName;
                        inter.ClientName = interview.Account__r.Name;
                        inter.JobName = interview.Job__r.Name;
                        return inter;
                    });
                    this.cells.push(interviewsForTheDay);
                } else {
                    this.cells.push(null);
                }
            }
        } else if (error) {
            dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                })
            );
        }
    }

}