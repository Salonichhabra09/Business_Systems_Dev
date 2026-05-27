import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import MS_Line_of_Business from '@salesforce/schema/Job__c.MS_Line_of_Business__c';
import OpportunityId from '@salesforce/schema/Job__c.Opportunity__c';
import RecordTypeId from '@salesforce/schema/Job__c.RecordTypeId';
import Project_Manager from '@salesforce/schema/Job__c.Project_Manager__c';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class CloneJobPage extends NavigationMixin(LightningElement) {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [MS_Line_of_Business,OpportunityId,RecordTypeId,Project_Manager] })
    jobRec({ error, data }) {
        if (data) {
        let defaultValues='';
        defaultValues = encodeDefaultFieldValues({
            MS_Line_of_Business__c: data.fields.MS_Line_of_Business__c.value,
            Opportunity__c : data.fields.Opportunity__c.value,
            Project_Manager__c: data.fields.Project_Manager__c.value

        });    
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Job__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues,
                recordTypeId: data.fields.RecordTypeId.value,
                //backgroundContext: '/lightning/r/Job__c/'+this.recordId+'/view'    
            }
        });
           
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
            
        }
    }

    
}