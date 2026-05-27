import {LightningElement,wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import assignToMe from '@salesforce/apex/CaseAssigneToMe.assignToMe';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class AssignToMeButton extends NavigationMixin(LightningElement) {
    recordId;
    

    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef?.state?.recordId) {
            this.recordId = pageRef.state.recordId;
            console.log('Record ID from CurrentPageReference:', this.recordId);
            this.handleAssignToMe();
        }
    }

    
    handleAssignToMe() {
        if (!this.recordId) {
            console.error('Record ID is not available.');
            return;
        }

        assignToMe({ caseId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'The case has been assigned to you.',
                        variant: 'success',
                    })
                );
                updateRecord({ fields: { Id: this.recordId }});
                this.refreshPage();
            })
            .catch((error) => {
                console.error('Error assigning case:', error);

                // Extract error messages
                let errorMessages = [];
                if (Array.isArray(error.body?.pageErrors)) {
                    error.body.pageErrors.forEach(err => errorMessages.push(err.message));
                }
                if (error.body?.fieldErrors) {
                    Object.values(error.body.fieldErrors).forEach(fieldErrors => {
                        fieldErrors.forEach(err => errorMessages.push(err.message));
                    });
                }
                if (error.body?.message) {
                    errorMessages.push(error.body.message);
                }
                if (error.message) {
                    errorMessages.push(error.message);
                }

                // Display the error in a toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessages.join(', ') || 'An unknown error occurred.',
                        variant: 'error',
                    })
                );
            });
    }

    refreshPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view',
            },
        });
    }
}