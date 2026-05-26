import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import deleteCandidateList from '@salesforce/apex/CustomerRequestController.deleteCandidateList';
import { NavigationMixin } from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';

export default class DeleteAllCandidateFromWrf extends NavigationMixin(LightningElement) {

    recordId;
    showLoadingSpinner = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            //console.log('currentPageReference ', currentPageReference);
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        if (this.recordId) {
            this.deleteCandidates();
        }
    }

    async deleteCandidates() {
        //console.log('recordId: ', this.recordId);
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to delete Candidates?',
            variant: 'header',
            label: 'Please Confirm',
            theme: 'warning',
        });

        if (result == true) {
            this.showLoadingSpinner = true;
            deleteCandidateList({ wrfId: this.recordId })
                .then(data => {
                    this.showLoadingSpinner = false;
                    //console.log('data ', JSON.stringify(data));
                    if (data) {
                        //console.log('Inside If data ', JSON.stringify(data));
                        this.showToast('Success', data, 'success');
                    } else {
                        //console.log('Inside Else data ', JSON.stringify(data));
                        this.showToast('Error', 'Error occurred while deleting candidate records', 'error');
                    }
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.refreshPage();
                })
                .catch(error => {
                    this.showLoadingSpinner = false;
                    //console.log('error ', JSON.stringify(error));
                    this.showToast('Error', 'Error occurred while deleting candidate records', 'error');
                    this.dispatchEvent(new CloseActionScreenEvent());
                });
        } else {
            this.showLoadingSpinner = false;
            this.dispatchEvent(new CloseActionScreenEvent());
            this.refreshPage();
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    refreshPage() {
        getRecordNotifyChange([{ recordId: this.recordId }]);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Work_Request__c',
                actionName: 'view'
            }
        });
    }
}