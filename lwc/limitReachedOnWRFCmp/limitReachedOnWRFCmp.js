import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord, getRecordNotifyChange } from "lightning/uiRecordApi";
import MAX_CANDIDATE_COUNT_JOB from '@salesforce/schema/Job__c.Solution_Cap__c';
import CANDIDATES_UPLOADED from '@salesforce/schema/Job__c.Candidate_Max_Sequence_No_New__c';
import JOBID from '@salesforce/schema/Work_Request__c.Job__c';
import CANDIDATES_REQUESTED from '@salesforce/schema/Work_Request__c.No_of_Candidate_Requested__c';
import PARTICIPANTS_REQUESTED from '@salesforce/schema/Work_Request__c.No_of_Participant_Requested__c';
import CANDIDATES_CREATED from '@salesforce/schema/Work_Request__c.No_of_Candidate_Created__c';
import PARTICIPANTS_CREATED from '@salesforce/schema/Work_Request__c.No_of_Participant_Created__c';
import PARTICIPANTS_CREATED_JOB from '@salesforce/schema/Job__c.Number_of_Participants_New__c';
import WORKREQUEST_TYPE from '@salesforce/schema/Work_Request__c.Work_Request_Type__c';
import SYSTEM_USED from '@salesforce/schema/Work_Request__c.System_Used__c';
import CLONED_FROM from '@salesforce/schema/Work_Request__c.Cloned_From__c';
import ISGCSCOPP from '@salesforce/schema/Job__c.Is_GCSC_Opp__c';
import VERSION_DATA_FIELD from '@salesforce/schema/ContentVersion.VersionData';
import { loadScript } from 'lightning/platformResourceLoader';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import { NavigationMixin } from 'lightning/navigation';


import { refreshApex } from '@salesforce/apex';

export default class LimitReachedOnWRFCmp extends NavigationMixin(LightningElement) {
    @api recordId;
    maxCandidateCount;
    candidatesUploaded;
    participantsCreatedJob;
    candidatesRequested;
    participantsRequested;
    candidatesCreated;
    participantsCreated;
    jobId;
    limitReached = false;
    remainingLimit;
    extraUsage;
    rowHeaderToImport = [];
    showImportCandidateScreen = false;
    disableInput = false;
    showErrorMessage = false;
    initialJSON;
    contentVersionId;
    parserInitialized = false;
    @api documentName;
    candidateData;
    templateHeader;
    showOptionScreen = true;
    workRequestType;
    showUI = false;
    showConfirmation = false;
    confirmedByUser = false;
    clonedFrom = null;
    isGCSCOPP = false;
    csvData;
    isMFSSystem;

    get acceptedFormats() {
        return ['.csv'];
    }

    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => {
                    this.parserInitialized = true;
                })
                .catch(error => console.error(error));
        }
    }

    @wire(getRecord, { recordId: '$contentVersionId', fields: [VERSION_DATA_FIELD] })
    contentversion({ error, data }) {
        if (data) {
            //console.log("data " + JSON.stringify(data));
            //console.log('data.fields.VersionData.value: ', data.fields.VersionData.value);
            //var temp = data.fields.VersionData.value.replace('/', '');
            var temp = data.fields.VersionData.value;
            //console.log("temp " + temp);
            //console.log(' hi ', this.decodeBase64(temp));
            //console.log(' hi ', JSON.stringify(this.decodeBase64(temp)));
            this.initialJSON = this.decodeBase64(temp);
            this.parseCSVtoJSON();
        }
        if (error) {
            //console.log('contentversion error: ', JSON.stringify(error));
        }
    }


    @wire(getRecord, {
        recordId: '$recordId',
        fields: [JOBID, CANDIDATES_REQUESTED, CANDIDATES_CREATED, WORKREQUEST_TYPE, CLONED_FROM, PARTICIPANTS_REQUESTED, PARTICIPANTS_CREATED, SYSTEM_USED],
    })
    WRFRecord({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            //console.log('Linked Job Id LR' + getFieldValue(data, JOBID));
            //console.log('Candidates Requested LR' + getFieldValue(data, CANDIDATES_REQUESTED));
            this.jobId = getFieldValue(data, JOBID);
            this.candidatesRequested = getFieldValue(data, CANDIDATES_REQUESTED);
            this.participantsRequested = getFieldValue(data, PARTICIPANTS_REQUESTED);
            this.candidatesCreated = getFieldValue(data, CANDIDATES_CREATED);
            this.participantsCreated = getFieldValue(data, PARTICIPANTS_CREATED);
            this.workRequestType = getFieldValue(data, WORKREQUEST_TYPE);
            this.clonedFrom = getFieldValue(data, CLONED_FROM);
            let systemUsed = getFieldValue(data, SYSTEM_USED);
            //let systemUsed = JSON.parse(data.fields.System_Used__c.value);
            //console.log('systemUsed: ', systemUsed);
            this.isMFSSystem = systemUsed.includes('360') ? true : false;
            //console.log('Candidates Created LR' + this.candidatesCreated);
            //console.log('Participants Created ' + this.participantsCreated);
            if (this.workRequestType == 'Internal Submission' && this.candidatesRequested == null) {
                this.showUI = true;
            }
            if (this.candidatesCreated == null) {
                this.candidatesCreated = 0;
            }
            if (this.participantsCreated == null) {
                this.participantsCreated = 0;
            }
        }
    }


    @wire(getRecord, {
        recordId: '$jobId',
        fields: [MAX_CANDIDATE_COUNT_JOB, CANDIDATES_UPLOADED, ISGCSCOPP, PARTICIPANTS_CREATED_JOB],
    })
    jobRecord({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            //console.log('MAX Candidate Count formula LR' + getFieldValue(data, MAX_CANDIDATE_COUNT_JOB));
            //console.log('Candidates Uploaded LR' + getFieldValue(data, CANDIDATES_UPLOADED));
            this.maxCandidateCount = getFieldValue(data, MAX_CANDIDATE_COUNT_JOB);
            this.candidatesUploaded = getFieldValue(data, CANDIDATES_UPLOADED);
            this.participantsCreatedJob = getFieldValue(data, PARTICIPANTS_CREATED_JOB);
            this.isGCSCOPP = getFieldValue(data, ISGCSCOPP);
            if (this.participantsCreatedJob == null) {
                this.participantsCreatedJob = 0;
            }
            this.remainingLimit = parseInt((this.maxCandidateCount - this.participantsCreatedJob));
            if (parseInt(this.participantsRequested) > this.remainingLimit) {
                //this.limitReached=true;
                this.extraUsage = parseInt(this.participantsRequested) - parseInt(this.remainingLimit) - parseInt(this.participantsCreated);
            }
            //console.log('candidatesRequested ' + this.candidatesRequested);
            //console.log('participantsRequested ' + this.participantsRequested);
            //console.log('Remaining Candidated ' + this.remainingLimit);
            //console.log('Candidates Created ' + this.candidatesCreated);
            //console.log('Extra Usage ' + this.extraUsage);
            if (this.extraUsage > 0 && !this.isGCSCOPP && (this.workRequestType == 'Client Submitted' || this.workRequestType == 'Internal Submission')) {
                this.showUI = true;
                this.limitReached = true;
            }
        }
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.documentName = uploadedFiles[0].name;
        //console.log('event.detail.files: ', JSON.stringify(event.detail.files));
        let docId = uploadedFiles[0].documentId;
        //console.log('docId: ', docId);
        let contentVersion = uploadedFiles[0].contentVersionId;
        //console.log('contentVersion: ', contentVersion);
        this.contentVersionId = contentVersion;
        //console.log('this.contentVersionId: ', this.contentVersionId);
        this.contentDocumentId = docId;

    }

    parseCSVtoJSON() {
        var completeProcessing = (results) => {
            //console.log('this._rows: ', JSON.stringify(results.data));
            //console.log('results.data length: ', results.data.length);
            this.csvData = JSON.parse(JSON.stringify(results.data));
            let participantCount = 0;
            this.csvData.forEach(row => {
                if (this.isMFSSystem && row.hasOwnProperty('Category')) {
                    if (row.Category == 'Self') {
                        participantCount++;
                    }
                }
            });

            if (!this.isMFSSystem && participantCount == 0) {
                participantCount = results.data.length;
            }
            //this._rows = JSON.parse(JSON.stringify(results.data));
            const fields = {};
            fields['Id'] = this.recordId; // Make sure you have this.recordId set to the record's Id
            fields['No_of_Candidate_Requested__c'] = results.data.length;
            fields['No_of_Participant_Requested__c'] = participantCount;

            if (results.data.length < this.remainingLimit && this.confirmedByUser == false && this.clonedFrom == null) {
                this.showConfirmation = true;
            }
            else {
                const recordInput = { fields };
                updateRecord(recordInput)
                    .then(() => {
                        this.showConfirmation = false;
                        //console.log('Record Updated');
                        getRecordNotifyChange([{ recordId: this.recordId }]);
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordId,
                                objectApiName: 'Work_Request__c', // Replace with your object API name
                                actionName: 'view'
                            }
                        });
                    })
                    .catch(error => {
                        //console.log('Error from update' + JSON.stringify(error));
                    });

            }

        }

        var errorProcessing = (error) => {
            //console.log('error: ', error);
            //this.loading = false;
        };
        Papa.parse(this.initialJSON, {
            skipEmptyLines: true,
            quoteChar: '"',
            header: true,
            complete: completeProcessing,
            error: errorProcessing
        })
    }

    decodeBase64(base64) {
        const text = atob(base64);
        const length = text.length;
        const bytes = new Uint8Array(length);
        for (let i = 0; i < length; i++) {
            bytes[i] = text.charCodeAt(i);
        }
        const decoder = new TextDecoder(); // default is utf-8
        return decoder.decode(bytes);
    }

    handleCloseDialog() {
        this.showConfirmation = false;
    }
    handleConfirmDelete() {
        this.confirmedByUser = true;
        this.parseCSVtoJSON();

    }


}