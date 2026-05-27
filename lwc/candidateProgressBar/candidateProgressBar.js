import { LightningElement,api,wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import MAX_CANDIDATE_COUNT_JOB from '@salesforce/schema/Job__c.Solution_Cap__c';
import CANDIDATES_UPLOADED from '@salesforce/schema/Job__c.Candidate_Max_Sequence_No_New__c';
import JOBID from '@salesforce/schema/Work_Request__c.Job__c';
import CANDIDATES_REQUESTED from '@salesforce/schema/Work_Request__c.No_of_Candidate_Requested__c';
import PARTICIPANTS_REQUESTED from '@salesforce/schema/Work_Request__c.No_of_Participant_Requested__c';
import PARTICIPANTS_CREATED from '@salesforce/schema/Job__c.Number_of_Participants_New__c';

export default class CandidateProgressBar extends LightningElement {
    @api recordId;
    maxCandidateCount;
    candidatesUploaded;
    candidatesRequested;
    participantsRequested;
    participantsCreated;
    jobId;
    limitReached;
    remainingLimit;
    extraUsage;

    get progressWidth() {
        let progress = (this.participantsCreated / this.maxCandidateCount) * 100;
        let style = 'width:'+progress+'%';
        return style;
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [JOBID,CANDIDATES_REQUESTED,PARTICIPANTS_REQUESTED],
    })
    WRFRecord({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            //console.log('Linked Job Id '+getFieldValue(data, JOBID));
            //console.log('Candidates Requested '+getFieldValue(data, CANDIDATES_REQUESTED));
            this.jobId = getFieldValue(data, JOBID);
            this.candidatesRequested = getFieldValue(data, CANDIDATES_REQUESTED);
            this.participantsRequested = getFieldValue(data, PARTICIPANTS_REQUESTED);
        }
    }


    @wire(getRecord, {
        recordId: '$jobId',
        fields: [MAX_CANDIDATE_COUNT_JOB,CANDIDATES_UPLOADED,PARTICIPANTS_CREATED],
    })
    jobRecord({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            //console.log('MAX Candidate Count formula '+getFieldValue(data, MAX_CANDIDATE_COUNT_JOB));
            //console.log('Candidates Uploaded '+getFieldValue(data, CANDIDATES_UPLOADED));
            this.maxCandidateCount = getFieldValue(data, MAX_CANDIDATE_COUNT_JOB);
            this.candidatesUploaded = getFieldValue(data, CANDIDATES_UPLOADED);
            this.participantsCreated = getFieldValue(data, PARTICIPANTS_CREATED);
            //console.log('Participants Created '+this.participantsCreated);
            this.remainingLimit = parseInt((this.maxCandidateCount-this.participantsCreated));
            if(parseInt(this.participantsRequested)>this.remainingLimit){
                this.limitReached=true;
                this.extraUsage = parseInt(this.participantsRequested)-parseInt(this.remainingLimit);
            }
        }
    }

}