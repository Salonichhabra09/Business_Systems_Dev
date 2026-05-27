import { LightningElement, api, wire, track } from 'lwc';
import getApprovalRows from '@salesforce/apex/ApprovalHistoryController.getApprovalRows';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";
import { RefreshEvent } from "lightning/refresh";


//JIRA - SSE-29215 changes Start: Opportunity:Re-submission: Approval history is not getting refreshed
// ---------- NEW IMPORTS FOR PLATFORM EVENT ----------

import { subscribe, unsubscribe, onError } from 'lightning/empApi';

//JIRA - SSE-29215 Changes END

export default class ApprovalHistoryTable extends LightningElement {
    @api recordId;

    @track rows = [];
    @track error;
    @track isLoading = true;
    isRecall = false;
    header = 'Recall Approval Submission';
    wiredData;
    isRecallButtonVisible = false;

    //JIRA - SSE-29215 changes Start: Opportunity:Re-submission: Approval history is not getting refreshed
    // ---------- NEW IMPORTS FOR PLATFORM EVENT ----------
    subscription = {};
    channelName = '/event/Approval_Refresh__e'; 
    //JIRA - SSE-29215 Changes END

    columns = [
        {
            label: 'Type',
            fieldName: 'type',
            type: 'text',
            wrapText:true,
            hideDefaultActions:true,
        },
        {
            label: 'Status',
            fieldName: 'status',
            type: 'text',
            wrapText:true,
            hideDefaultActions:true,
        },
        {
            label: 'Person',
            fieldName: 'actorName',
            type: 'text',
            wrapText:true,
            hideDefaultActions:true,
        },
        {
            label: 'Approver',
            fieldName: 'reviewerName',
            type: 'text',
            wrapText:true,
            hideDefaultActions:true,
        },
        {
            label: 'Action',
            fieldName: 'actionLabel',
            type: 'text',
            wrapText:true,
            hideDefaultActions:true,
        },
        {
            label: 'Date',
            fieldName: 'createdDate',
            type: 'date',
            wrapText:true,
            hideDefaultActions:true,
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            },
        },
        {
            label: 'Comment',
            fieldName: 'comment',
            type: 'text',
            wrapText: true,
            wrapTextMaxLines: 20,
            hideDefaultActions:true
        }
    ];

    get inputVariables() {
        return [
            {
                name: 'OpportunityId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    @wire(getApprovalRows, { recordId: '$recordId' })
    ApprovalInfo(value) {
        this.wiredData = value;
        const { error, data } = value;
        if (data) {
            this.rows = data;
            this.rows.forEach(element => {
                if(element.type == 'Submission Action'){
                    this.isRecallButtonVisible = element.isRecallButtonVisible;
                }
            });
            this.error = undefined;
        } else if (error) {
            this.error = this.reduceError(error);
            this.rows = [];
            const event = new ShowToastEvent({
                title: 'Error',
                message: this.error,
                variant:'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
    }

    get hasData() {
        return this.rows && this.rows.length > 0;
    }

    reduceError(error) {
        let message = 'Unknown error';
        if (Array.isArray(error?.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error?.body?.message === 'string') {
            message = error.body.message;
        }
        return message;
    }

    handleRecall(){
        this.isRecall = true ;
    }

    closeRecallPopup(){
        this.isRecall = false;
    }

    handleStatusChange(event) {
             

        if (event.detail.status === 'FINISHED') {
            this.isRecall = false;
            this.dispatchEvent(new RefreshEvent());
            refreshApex(this.wiredData);
            this.isRecallButtonVisible = false;
            const event = new ShowToastEvent({
                title: 'Approval Submission Recalled',
                variant:'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
    }

//JIRA - SSE-29215 changes Start: Opportunity:Re-submission: Approval history is not getting refreshed
// ---------- NEW IMPORTS FOR PLATFORM EVENT ----------
    connectedCallback() {
        this.handleSubscribe();   
        this.registerErrorListener(); 
             

    }

    disconnectedCallback() {
        
        if (this.subscription) {
            unsubscribe(this.subscription, response => {
                console.log('Unsubscribed from channel: ', response);
            });
        }
    }

handleSubscribe() {
    console.log('Subscribing to:', this.channelName);
         
    const messageCallback = (response) => {
        console.log('Platform Event Payload:', JSON.stringify(response.data.payload));

        const recordIdFromEvent = response?.data?.payload?.Record_Id__c;
        console.log('Event RecordId:', recordIdFromEvent);
        console.log('Component RecordId:', this.recordId);

        if (recordIdFromEvent === this.recordId) {
            console.log('Record matched → refreshing Apex');
            setTimeout(() => {
                refreshApex(this.wiredData);
            }, 700); 
        }

             

    };

    subscribe(this.channelName, -1, messageCallback)
        .then((response) => {
            console.log('Subscribed successfully:', response.channel);
            this.subscription = response;
        })
        .catch(error => {
            console.error('Subscription error:', error);
        });
}



    registerErrorListener() {
        onError(error => {
            console.error('Platform Event Error: ', JSON.stringify(error));
        });
    }
}

//JIRA - SSE-29215 Changes END