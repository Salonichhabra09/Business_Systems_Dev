import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import JOB_TRANSFER_STATUS_FIELD from '@salesforce/schema/Job__c.Job_Transfer_Status__c';
import CANDIDATE_TRANSFER_STATUS_FIELD from '@salesforce/schema/Job__c.Candidate_Transfer_Status__c';
import { CloseActionScreenEvent } from 'lightning/actions';


const FIELDS = [JOB_TRANSFER_STATUS_FIELD, CANDIDATE_TRANSFER_STATUS_FIELD];

export default class JobStatusUpdate extends LightningElement {
    @api recordId;
    jobStatus;
    candidateStatus;
    initialStatusValue;

    showModal = false;
    successMessage = '';
    errorMessage = '';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredJob({ data, error }) {
        if (data) {
            this.jobStatus = data.fields.Job_Transfer_Status__c.value;
            this.candidateStatus = data.fields.Candidate_Transfer_Status__c.value;
            console.log('jobStatus: ', this.jobStatus);
            console.log('candidateStatus: ', this.candidateStatus);
            this.handleStatusUpdate();
        } else if (error) {
            this.error = 'Error loading record.';
            this.showModal = true;
        }
    }

    handleStatusUpdate() {
        const fieldsToUpdate = { Id: this.recordId };
        let updateNeeded = false;

        // Rule 1
        if (this.jobStatus !== 'Ready to transfer' && this.jobStatus !== 'Sent to FTP') {
            fieldsToUpdate[JOB_TRANSFER_STATUS_FIELD.fieldApiName] = 'Ready to transfer';
            updateNeeded = true;
        }

        // Rule 2
        if (
            (this.jobStatus === 'Ready to transfer' || this.jobStatus === 'Sent to FTP') &&
            this.candidateStatus !== 'Ready to transfer' &&
            this.candidateStatus !== 'Sent to FTP'
        ) {
            fieldsToUpdate[CANDIDATE_TRANSFER_STATUS_FIELD.fieldApiName] = 'Ready to transfer';
            updateNeeded = true;
        }

        if (updateNeeded) {
            updateRecord({ fields: fieldsToUpdate })
                .then(() => {
                    this.successMessage = 'Status successfully updated!';
                    this.showModal = true;
                    setTimeout(() => {
                        //this.showModal = false;
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }, 1000);
                })
                .catch(err => {
                    const message = err.body && err.body.output && err.body.output.errors && err.body.output.errors.length
        ? err.body.output.errors[0].message
        : err.body.message || 'Unknown error';
                    this.errorMessage = 'Error updating status: ' + message;
                    this.showModal = true;
                });
        } /*else {
            setTimeout(() => {
                //this.showModal = false;
                this.dispatchEvent(new CustomEvent('close'));
            }, 2000);
        }*/
    }

     closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}