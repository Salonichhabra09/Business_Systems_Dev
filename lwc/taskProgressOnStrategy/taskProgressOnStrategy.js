import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Strategy_and_Goal__c.Progress_on_tasks__c', 'Strategy_and_Goal__c.Number_of_tasks_created__c','Strategy_and_Goal__c.Number_of_tasks_completed__c'];
export default class TaskProgressOnStrategy extends LightningElement {

    @api recordId;
    progressOnTasks;
    numberOfTasks;
    numberOfCompletedTasks;
    isCreatedGreaterThanZero = false;
    isTotalExceeded = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.progressOnTasks = Math.round(data.fields.Progress_on_tasks__c.value);
            this.numberOfTasks = data.fields.Number_of_tasks_created__c.value;
            this.numberOfCompletedTasks = data.fields.Number_of_tasks_completed__c.value;
            this.isTotalExceeded = (data.fields.Number_of_tasks_created__c.value>0 && data.fields.Number_of_tasks_created__c.value!=data.fields.Number_of_tasks_completed__c.value)?true:false;
            this.isCreatedGreaterThanZero = data.fields.Number_of_tasks_completed__c.value >0?true:false;
            var css = this.template.host.style;
            css.setProperty('--progressBarWidth', (this.progressOnTasks)+'%');
            css.setProperty('--completedActivities', (this.progressOnTasks-2)+'%');
            if(this.numberOfTasks>9){
                css.setProperty('--totalValue', (97-this.progressOnTasks)+'%');
            }else{
                css.setProperty('--totalValue', (98-this.progressOnTasks)+'%');
            }
        }
    }
}