import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext } from 'lightning/empApi';

export default class JobRefresher extends NavigationMixin(LightningElement) {
    channelName = '/event/Job_Refresh_Event__e';
    subscription = null;

    connectedCallback() {
        this.subscribeToEvent();
    }

    subscribeToEvent() {
        subscribe(this.channelName, -1, (event) => {
            const jobId = event.data.payload.JobId__c;
            if (jobId) {
                console.log('Job Refresh Event received for Job ID:', jobId);
                this.refreshRecordPage(jobId);
            }
        });
    }

    refreshRecordPage(jobId) {
        const currentUrl = window.location.href;

    // Check if the current page is in edit mode
    if (currentUrl.includes('/e') || currentUrl.includes('edit?')) {
        console.log('Currently on edit page, navigation aborted.');
    }
    else{
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: jobId,
                objectApiName: 'Job__c', // update if needed
                actionName: 'view'
            }
        }, true);
    }
}
}