import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import JOB_TRANSFER_STATUS_FIELD from '@salesforce/schema/Job__c.Job_Transfer_Status__c';
import CANDIDATE_TRANSFER_STATUS_FIELD from '@salesforce/schema/Job__c.Candidate_Transfer_Status__c';

const FIELDS = [JOB_TRANSFER_STATUS_FIELD, CANDIDATE_TRANSFER_STATUS_FIELD];

export default class JobStatusUpdater extends LightningElement {
    @api recordId;
    jobStatus;
    candidateStatus;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredJob({ data, error }) {
        if (data) {
            this.jobStatus = data.fields.Job_Transfer_Status__c.value;
            this.candidateStatus = data.fields.Candidate_Transfer_Status__c.value;
            console.log('jobStatus: ', this.jobStatus);
            console.log('candidateStatus: ', this.candidateStatus);
            this.handleStatusUpdate();
        } else if (error) {
            this.showToast('Error', 'Failed to load Job record.', 'error');
            this.closeAction();
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
            this.jobStatus === 'Ready to transfer' &&
            this.candidateStatus !== 'Ready to transfer' &&
            this.candidateStatus !== 'Sent to FTP'
        ) {
            fieldsToUpdate[CANDIDATE_TRANSFER_STATUS_FIELD.fieldApiName] = 'Ready to transfer';
            updateNeeded = true;
        }

        if (updateNeeded) {
            updateRecord({ fields: fieldsToUpdate })
                .then(() => {
                    this.showToast('Success', 'Status updated successfully!', 'success');
                    //this.closeAction();
                })
                .catch(error => {
                    this.showToast('Error updating status', error.body.message, 'error');
                });
        } else {
            this.showToast('Info', 'No update needed. Status is already correct.', 'info');
            //this.closeAction();
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}