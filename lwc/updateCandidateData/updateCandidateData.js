import { LightningElement, track, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import VERSION_DATA_FIELD from '@salesforce/schema/ContentVersion.VersionData';
import CANDIDATE_FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Candidate_Field_Configuration__c';
import getWRFAndJobData from '@salesforce/apex/CustomerRequestController.getWRFAndJobData';
import createCandidates from '@salesforce/apex/CustomerRequestController.updateCandidates';
import uploadFile from '@salesforce/apex/CandidateUploadContoller.uploadFile';
import createRatings from '@salesforce/apex/CustomerRequestController.createRatings';
import MAX_CANDIDATE_COUNT_JOB from '@salesforce/schema/Job__c.Solution_Cap__c';
import CANDIDATES_UPLOADED from '@salesforce/schema/Job__c.Candidate_Max_Sequence_No_New__c';
import PARTICIPANTS_CREATED_JOB from '@salesforce/schema/Job__c.Number_of_Participants_New__c';
import JOBID from '@salesforce/schema/Work_Request__c.Job__c';
import CANDIDATES_REQUESTED from '@salesforce/schema/Work_Request__c.No_of_Candidate_Requested__c';
import PARTICIPANTS_REQUESTED from '@salesforce/schema/Work_Request__c.No_of_Participant_Requested__c';
import CANDIDATES_CREATED from '@salesforce/schema/Work_Request__c.No_of_Candidate_Created__c';
import PARTICIPANTS_CREATED from '@salesforce/schema/Work_Request__c.No_of_Participant_Created__c';
import IS_REPEATABLE from '@salesforce/schema/Job__c.Account__r.Is_Repeatable_Business__c';
import getJobStatus from '@salesforce/apex/CandidateUploadContoller.getJobStatus';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import CANDIDATE_REQUEST_TYPE from '@salesforce/schema/Work_Request__c.Candidate_Request_Type_Backend_Use__c';
import PRODUCT_ASSESSMENT from '@salesforce/schema/Work_Request__c.Product_Assessment__c';
import updateCandidatesToLinkJob from '@salesforce/apex/CustomerRequestController.updateCandidatesToLinkJob';
import IS_GCSC from '@salesforce/schema/Job__c.Is_GCSC_Opp__c';
/*
const arrayMap = { "Id": "Record ID", "First_Name__c": "First Name", "Last_Name__c": "Last Name", "Email__c": "Email", "Gender__c": "Gender", "Phone_Number__c": "Phone Number", "Country__c": "Country", "Language__c": "Language", "Status2__c": "Status", "Reports_Status__c": "Report Status", "Username_New__c": "Username", "Product_Assessment__c": "Product/Assessment", "System_s__c": "System(s)", "Email_as_Username__c": "Email as Username?" };
const arrayMap1 = { "Category__c": "Category", "First_Name__c": "First Name", "Last_Name__c": "Last Name", "Email__c": "Email", "Gender__c": "Gender", "Phone_Number__c": "Phone Number", "Country__c": "Country", "Language__c": "Language", "Status2__c": "Status", "Reports_Status__c": "Report Status", "Username__c": "Username", "Product_Assessment__c": "Product/Assessment", "System_s__c": "System(s)", "Bureau_Job__c": "Bureau Job", "Email_as_Username__c": "Email as Username?", "Candidate_Unique_Id__c": "uniqueId", "Job_Region__c": "jobRegion" };
const arrayMap2 = { "Id": "Record ID", "First_Name__c": "First Name", "Last_Name__c": "Last Name", "Email__c": "Email", "Gender__c": "Gender", "Phone_Number__c": "Phone Number", "Country__c": "Country", "Language__c": "Language", "Status2__c": "Status", "Reports_Status__c": "Report Status", "Username__c": "Username", "Product_Assessment__c": "Product/Assessment", "System_s__c": "System(s)", "Email_as_Username__c": "Email as Username?", "Candidate_Unique_Id__c": "uniqueId" };
const arrayMap3 = { "Category__c": "Category", "First_Name__c": "First Name", "Last_Name__c": "Last Name", "Email__c": "Email", "Gender__c": "Gender", "Phone_Number__c": "Phone Number", "Country__c": "Country", "Language__c": "Language", "Status2__c": "Status", "Reports_Status__c": "Report Status", "Username__c": "Username", "Product_Assessment__c": "Product/Assessment", "System_s__c": "System(s)", "Bureau_Job__c": "Bureau Job", "Recipient_Email__c": "Recipient Email" };
const arrayMap4 = { "Category": "Category", "First_Name": "First Name", "Last_Name": "Last Name", "Email": "Email", "Bureau_Job": "Bureau Job", "Recipient_Email": "Recipient Email" };
const attributesToRemove = { "First_Name__c": "First Name", "Last_Name__c": "Last Name", "Bureau_Job": "Bureau Job", "Gender__c": "Gender", "Phone_Number__c": "Phone Number", "Country__c": "Country", "Language__c": "Language", "Status2__c": "Status", "Reports_Status__c": "Report Status", "Username__c": "Username", "Product_Assessment__c": "Product/Assessment", "System_s__c": "System(s)", "Email_as_Username__c": "Email as Username?", "Job_Region__c": "jobRegion" };
*/
const arrayMap4 = { "Category": "Category", "Email": "Email", "Recipient_Email": "Recipient Email" };

export default class ParseCSVFile extends NavigationMixin(LightningElement) {
    /*
    rowHeadings = ['Record ID', 'First Name', 'Last Name', 'Email', 'Gender', 'Phone Number', 'Country', 'Language', 'Status', 'Report Status', 'Username', 'Product/Assessment', 'System(s)', 'Email as Username?'];
    rowHeaderToImport = ['Category', 'First Name', 'Last Name', 'Email', 'Gender', 'Phone Number', 'Country', 'Language', 'Status', 'Report Status', 'Username', 'Product/Assessment', 'System(s)', 'Email as Username?'];
    importRowHeadings = ['Category__c', 'First_Name__c', 'Last_Name__c', 'Email__c', 'Gender__c', 'Phone_Number__c', 'Country__c', 'Language__c', 'Status2__c', 'Reports_Status__c', 'Username__c', 'Product_Assessment__c', 'System_s__c', 'Bureau_Job__c', 'Email_as_Username__c', 'Candidate_Unique_Id__c', 'Job_Region__c'];
    rowHeader = ['Category', 'First Name', 'Last Name', 'Email', 'Gender', 'Phone Number', 'Country', 'Language', 'Status', 'Report Status', 'Username', 'Product/Assessment', 'System(s)', 'Email as Username?'];
    rowHeaderMessageToDisplay = 'Category, First Name, Last Name, Email, Gender, Phone Number, Country, Language, Status, Report Status, Username, Product/Assessment, System(s), Email as Username?';
    rowHeaderUpdate = ['Record ID', 'First Name', 'Last Name', 'Email', 'Gender', 'Phone Number', 'Country', 'Language', 'Status', 'Report Status', 'Username', 'Product/Assessment', 'System(s)', 'Email as Username?'];
    rowHeaderUpdateMessageToDisplay = 'Record ID, First Name, Last Name, Email, Gender, Phone Number, Country, Language, Status, Report Status, Username, Product/Assessment, System(s), Email as Username?';
    importRowHeadingsUpdate = ['Id', 'First_Name__c', 'Last_Name__c', 'Email__c', 'Gender__c', 'Phone_Number__c', 'Country__c', 'Language__c', 'Status2__c', 'Reports_Status__c', 'Username__c', 'Product_Assessment__c', 'System_s__c', 'Email_as_Username__c', 'Candidate_Unique_Id__c'];
    */
    @api recordId;
    @api generatedWrfId;

    rowHeaderToImport = [];
    candidateData;
    submittedWRFId;
    csvData;
    jobId;
    arrayMap1 = {};
    fileName;
    importRowHeadings;
    tempCsvData = [];
    copyOfCsvData;
    ratingCsvDatafromJSON;

    arrayOfCategoryValues;
    arrayOfStatusValues;
    arrayOfReportStatusValues;
    @track candidateIdsRelatedToJob;
    @track exportCandidateLabel = 'Export Candidates';
    @track importCandidateLabel = 'Import New Candidate List';
    @track showImportCandidateScreen = false;
    @track showCreateNewCandidate = false;
    @track showCandidateScreen = true;
    @track showErrorMessage = false;
    @track errorMessage;
    @track errorType;
    @track offSetValue = 0;
    parserInitialized = false;
    loading = false;
    @api jobCandidateData = [];
    @track _results;
    @track csvDataRating;
    @track csvDatafromJSON;
    @track jobRatingData = [];
    @track fullJSON = [];
    @track isMFSSystem = false;
    @track spinnerText;

    @api insertQueue = [];
    @api systemUsedNotRequired;
    pendingUpload = false;
    @track stopProcessing = false;
    @track showCandidateExportButton = false;
    i = 0;

    @track systemUsedValues;
    @track jobName;
    @track dataCount;
    @track job;
    @track showLoadingSpinner = false;
    @track showLoadingSpinnerExport = false;
    @track disableInput = false;
    @track numberOfRecordsFailed;
    @track numberOfRecordsProcessed;
    @track state;
    @track contentDocumentId;
    @track recordCount;
    @track updateCandidate = true;
    @track jobLOB;
    talentManagementLOB = 'Talent Management';
    talentVocationalBatchLOB = 'TA - Vocational (Batch)';
    talentVocationalSchoolLOB = 'TA - Vocational (School)';
    talentCorporateLOB = 'TA - Corporate';
    talentCredentialingLOB = 'TA - Credentialing';
    @api recordTypeId;
    categoryValues;
    statusValues;
    reportStatusValues;
    @track mapOfValues = [];
    isSystemAvailable = false;
    doCallInputChange = false;
    @track isRatingApplicable = false;
    @track jobRegion;

    initialJSON;

    fileReader;
    fileContents;
    file;
    filesUploaded;
    fileUrl;

    systemDataList;
    listOfFields = [];
    showListofFields = false;
    array;
    selectedHeaders = [];
    value = [];
    showFieldSelectionScreen = false;
    contentVersionId;
    contentDocumentId;

    //Priyank's Code
    maxCandidateCount;
    candidatesUploaded;
    participantsCreatedJob;
    candidatesRequested;
    parcipantRequested;
    candidatesCreated;
    participantsCreated;
    limitReached = false;
    remainingLimit;
    extraUsage;
    isRepeatable = false;
    candidatesRequestType;
    manualType = false;
    isNotMFSSystem = false;
    productAssessment;
    isGCSC;

    get acceptedFormats() {
        return ['.csv'];
    }

    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => {
                    //console.log('inside parser');
                    //console.log('record Id rendered'+this.recordId);
                    this.parserInitialized = true;
                })
                .catch(error => console.error('parser error', error));
        }
    }

    connectedCallback() {
        /*  this.showLoadingSpinner = true;
          setTimeout(() => {
              //console.log('this.recordId: ', this.recordId);
              this.makeApexCallout();
          }, 100); */
    }

   /* @wire(getRecord, {
        recordId: '$recordId',
        fields: [JOBID, CANDIDATES_REQUESTED, CANDIDATES_CREATED, CANDIDATE_REQUEST_TYPE, PRODUCT_ASSESSMENT,PARTICIPANTS_REQUESTED,PARTICIPANTS_CREATED],
    })
    WRFRecord({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
            this.toast('Error', 'An Error Occurred. Please contact the admin.', 'error', 'dismissible');
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        else if (data) {
            //console.log('Linked Job Id ' + getFieldValue(data, JOBID));
            //console.log('Candidates Requested ' + getFieldValue(data, CANDIDATES_REQUESTED));
            this.jobId = getFieldValue(data, JOBID);
            this.candidatesRequested = getFieldValue(data, CANDIDATES_REQUESTED);
            this.parcipantRequested = getFieldValue(data, PARTICIPANTS_REQUESTED);
            this.candidatesCreated = getFieldValue(data, CANDIDATES_CREATED);
            this.participantsCreated = getFieldValue(data, PARTICIPANTS_CREATED);
            this.candidatesRequestType = getFieldValue(data, CANDIDATE_REQUEST_TYPE);
            this.productAssessment = getFieldValue(data, PRODUCT_ASSESSMENT);
            this.generatedWrfId='a3aPu000001EiVFIA0';
            //console.log('this.productAssessment: ', this.productAssessment);
            //console.log('Candidates Created ' + this.candidatesCreated);
            if (this.candidatesCreated == null) {
                this.candidatesCreated = 0;
            }
            if (this.participantsCreated == null) {
                this.participantsCreated = 0;
            }
        }
    }*/

   /* @wire(getRecord, {
        recordId: '$jobId',
        fields: [MAX_CANDIDATE_COUNT_JOB, CANDIDATES_UPLOADED, IS_REPEATABLE, IS_GCSC,PARTICIPANTS_CREATED_JOB],
    })
    jobRecord({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
            this.toast('Error', 'An Error Occurred. Please contact the admin.', 'error', 'dismissible');
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        else if (data) {
            //console.log('MAX Candidate Count formula ' + getFieldValue(data, MAX_CANDIDATE_COUNT_JOB));
            //console.log('Candidates Uploaded ' + getFieldValue(data, CANDIDATES_UPLOADED));
            this.maxCandidateCount = getFieldValue(data, MAX_CANDIDATE_COUNT_JOB);
            this.candidatesUploaded = getFieldValue(data, CANDIDATES_UPLOADED);
            this.participantsCreatedJob = getFieldValue(data,PARTICIPANTS_CREATED_JOB);
            this.isRepeatable = getFieldValue(data, IS_REPEATABLE);
            this.isGCSC = getFieldValue(data, IS_GCSC);
            if (this.participantsCreatedJob == null) {
                this.participantsCreatedJob = 0;
            }
            if (!this.isGCSC) {
                this.remainingLimit = parseInt((this.maxCandidateCount - this.participantsCreatedJob));
                if (parseInt(this.parcipantRequested) > this.remainingLimit) {
                    //this.limitReached=true;
                    this.extraUsage = parseInt(this.parcipantRequested) - parseInt(this.remainingLimit) - parseInt(this.participantsCreated);
                }
                //console.log('Extra Usage ' + this.extraUsage);
                if (this.extraUsage > 0) {
                    this.limitReached = true;
                }
            }
            if (!this.limitReached) {
                this.showLoadingSpinner = true;
                setTimeout(() => {
                    //console.log('this.recordId: ', this.recordId);
                    //this.makeApexCallout();
                }, 100);
            }
        }
    }*/


    @wire(getRecord, { recordId: '$contentVersionId', fields: [VERSION_DATA_FIELD] })
    contentversion({ error, data }) {
        if (data) {
            var temp = data.fields.VersionData.value;
            //console.log('temp: ', temp);
            this.initialJSON = this.decodeBase64(temp);
            //console.log('this.initialJSON: ', JSON.stringify(this.initialJSON));
            this.callParserToReadDataFromFile(); // changes for WRF
        }
        if (error) {
            //console.log('contentversion error: ', JSON.stringify(error));
            this.toast('Error', 'An Error Occurred. Please contact the admin.', 'error', 'dismissible');
            this.dispatchEvent(new CloseActionScreenEvent());
        }
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

    @wire(getRecord, { recordId: '$generatedWrfId', fields: [CANDIDATE_FIELD_CONFIGURATION] })
    getCandidateDataFromgeneratedWRF({ error, data }) {
        if (data) {
            this.candidateData = JSON.parse(data.fields.Candidate_Field_Configuration__c.value);
            const stringToRemove = 'Category__c';
            this.candidateData = this.candidateData.filter(item => item.API_Name__c !== stringToRemove);
            let templateHeader = ["Id"];
            this.candidateData.forEach(element => {
                    templateHeader.push(element.API_Name__c);
                
            });

            // Mapping API_Name__c to Label__c
            /*this.arrayMap1 = this.candidateData.reduce((accumulator, currentField) => {
                accumulator[currentField.API_Name__c] = currentField.Label__c;
                return accumulator;
            }, {});
            //console.log('aa ', JSON.stringify(this.arrayMap1));*/

            this.importRowHeadings = Object.keys(this.candidateData);
            //console.log('this.importRowHeadings: ', JSON.stringify(this.importRowHeadings));

            /*if (this.isMFSSystem) {
                let mfsHeadersToAdd = ['Category'];
                this.rowHeaderToImport = [...mfsHeadersToAdd, ...templateHeader];
            } else {
                this.rowHeaderToImport = [...templateHeader];
            }*/
            this.rowHeaderToImport = [...templateHeader];
            //this.contentVersionId = this.latestFileId;
            //console.log('this.rowHeaderToImport '+this.rowHeaderToImport);
        }
        if (error) {
            //console.log(' getCandidateDataFromgeneratedWRFerror: ', JSON.stringify(error));
            this.toast('Error', 'An Error Occurred. Please contact the admin.', 'error', 'dismissible');
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    linkCandidatesToJob() {
        updateCandidatesToLinkJob({
            jobId: this.jobId
        })
            .then(data => {
                //console.log('LinkCandidatesToJob data: ', JSON.stringify(data));
                this.toast('Success', 'Candidates accepted successfully!!!', 'success', 'dismissible');
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                //console.log('LinkCandidatesToJob error: ', JSON.stringify(error));
                this.toast('Error', 'An Error Occurred. Please contact the admin.', 'error', 'dismissible');
                this.dispatchEvent(new CloseActionScreenEvent());
            })
    }

    /*makeApexCallout() {
        getWRFAndJobData({
            recordId: this.recordId
        })
            .then(data => {
                //console.log('data: ', JSON.stringify(data));
                this.latestFileId = data.contentDocumentLink?.ContentDocument?.LatestPublishedVersionId;
                this.fileName = data.contentDocumentLink?.ContentDocument?.Title;
                this.jobName = data.jobData?.Name;
                let systemUsed = data.jobData?.System_Used__c;
                this.jobLOB = data.jobData?.MS_Line_of_Business__c;
                this.jobRegion = data.jobData?.Job_Region__c;
                this.systemUsedValues = data.jobData?.System_Used__c;
                this.submittedWRFId = data.workRequestData?.Id;
                let wrfSystemUsed = data.workRequestData?.System_Used__c;
                if (wrfSystemUsed && this.jobLOB == 'Talent Management') {
                    if (wrfSystemUsed.includes('360')) {
                        this.isMFSSystem = true;
                    } else {
                        this.isNotMFSSystem = true;
                    }
                }
                if (this.candidatesRequestType == 'Manual') {
                    this.linkCandidatesToJob();
                } else {
                    this.generatedWrfId = data.workRequestData?.Work_Request_Generated__c;
                }

                let linkedSystem = data.linkedSystem;
                //console.log('linkedSystem: ', linkedSystem);
                if (linkedSystem != undefined && linkedSystem.length > 0) {
                    //this.jobId = data.jobData?.Id;
                }*/
                /*if (systemUsed && this.jobLOB) {
                    if ((systemUsed.includes('MFS') || systemUsed.includes('TalentCentral')) && this.jobLOB == 'Talent Management') {
                        this.isMFSSystem = true;
                    }
                }*/
           /* })
            .catch(error => {
                //console.log('makeApexCallout error: ', JSON.stringify(error));
                this.toast('Error', 'An Error Occurred. Please contact the admin.', 'error', 'dismissible');
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }*/

    callParserToReadDataFromFile() {
        //console.log('callParserToReadDataFromFile: ');

        var completeProcessing = (results) => {
            this.csvData = JSON.parse(JSON.stringify(results.data));
            //console.log('this.csvData: ', JSON.stringify(this.csvData));

            this.tempCsvData = JSON.parse(JSON.stringify(results.data));
            //console.log('this.tempCsvData: ', JSON.stringify(this.tempCsvData));
            let result = true;
            let errorMessage = '';
            var validateFileHeadersFlag = this.validateColumns(errorMessage);

            //If headers are correct
            if (validateFileHeadersFlag) {
                //check if required field is blank
                var validateDataFlag = this.validateData(errorMessage);
                result = validateDataFlag;
            }
            else {
                result = validateFileHeadersFlag;
            }
            //If any error found show error message
            if (!result) {
                //console.log('inside if');
                this.showLoadingSpinner = false;
                this.disableInput = false;
                this.showErrorMessage = true;
                this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            //If no error
            else {
                //console.log('No Error Found!!!');
                //console.log('this.csvData: ', JSON.stringify(this.csvData));
                var candidatesList = [];
                /* Logic to add Bureau Job */
                this.csvData.forEach(row => {
                    if (!this.updateCandidate) {
                        if (!row.hasOwnProperty('Category') && this.isNotMFSSystem) {
                            row["Category"] = 'Self';
                        }
                        //}
                        row["Bureau Job"] = this.jobId;
                        row["Work Request"] = this.submittedWRFId;
                        /* START Logic to generate Candidate Unique Id */
                        //let lastString = row["Username"] ? row["Username"] : row["Email"];
                        row["uniqueId"] = this.jobId + row["First Name"] + row["Last Name"] + row["Email"];
                        /* END Logic to generate Candidate Unique Id */
                        row["jobRegion"] = this.jobRegion;
                        if (this.productAssessment) {
                            row["Product/Assessment"] = this.productAssessment;
                        }
                    }
                    //candidatesList.push(row);
                });

                let listToAppendForNonMFS = ['Category__c', 'Bureau_Job__c', 'Work_Request__c', 'Candidate_Unique_Id__c', 'Job_Region__c', 'Product_Assessment__c'];
                let listToAppendMapForNonMFS = { "Category__c": "Category", "Bureau_Job__c": "Bureau Job", "Work_Request__c": "Work Request", "Candidate_Unique_Id__c": "uniqueId", "Job_Region__c": "jobRegion", "Product_Assessment__c": "Product/Assessment" };

                //let listToAppendForMFS = ['Bureau_Job__c', 'Work_Request__c', 'Candidate_Unique_Id__c', 'Job_Region__c'];
                //let listToAppendMapForMFS = { "Category__c": "Category", "Bureau_Job__c": "Bureau Job", "Work_Request__c": "Work Request", "Candidate_Unique_Id__c": "uniqueId", "Job_Region__c": "jobRegion" };

                let listToAppendForMFS = ['Bureau_Job__c', 'Work_Request__c', 'Candidate_Unique_Id__c', 'Job_Region__c'];
                let listToAppendMapForMFS = { "Bureau_Job__c": "Bureau Job", "Work_Request__c": "Work Request", "Candidate_Unique_Id__c": "uniqueId", "Job_Region__c": "jobRegion" };

              /*  if (this.isMFSSystem) {
                    listToAppendForMFS.forEach(ele => {
                        this.importRowHeadings.push(ele);
                    });
                    //console.log('this.importRowHeadings: ', JSON.stringify(this.importRowHeadings));
                    Object.assign(this.arrayMap1, listToAppendMapForMFS);
                } else {
                    listToAppendForNonMFS.forEach(ele => {
                        this.importRowHeadings.push(ele);
                    });
                    //console.log('this.importRowHeadings: ', JSON.stringify(this.importRowHeadings));
                    Object.assign(this.arrayMap1, listToAppendMapForNonMFS);
                }
                //console.log('this.arrayMap1: ', JSON.stringify(this.arrayMap1));
                */
                candidatesList = [];
                if (!this.updateCandidate) {
                    /* START Logic to remove Duplicates */
                    const uniqueObjects = this.uniqueByKeepSelf(this.csvData);
                    this.csvData = [...uniqueObjects];
                    this.csvData.forEach(row => {
                        candidatesList.push(row);
                    });
                    /* END Logic to remove Duplicates */
                }
                this.csvData.forEach(row => {
                    candidatesList.push(row);
                });
                this.jobCandidateData = [...candidatesList];
                //console.log('this.jobCandidateData: ', JSON.stringify(this.jobCandidateData));

                let rowData = new Set();
                this.jobCandidateData.forEach(function (record) {
                    Object.keys(record).forEach(function (key) {
                        rowData.add(key);
                    });
                });

                //below block get api name of headers
                rowData = Array.from(rowData);
                const headerAPIName = new Map();
                for (let key in rowData) {
                    if (rowData.hasOwnProperty(key)) {
                        let rowKeyValue = rowData[key];
                        let rowKey = this.getKeyByValue(this.arrayMap1, rowKeyValue);
                        headerAPIName.set(rowKey, rowKeyValue);
                    }
                }

                //below block replace header label with API Names
                /*let jsonString = JSON.stringify(this.jobCandidateData);
                for (let key of headerAPIName.keys()) {
                    let mapValue = headerAPIName.get(key);
                    let keyStr = "\"" + key + "\":";
                    let valueStr = "\"" + mapValue + "\":";
                    jsonString = jsonString.replaceAll(valueStr, keyStr);
                }
                this.jobCandidateData = JSON.parse(jsonString);*/

                //Below logic is written to create full JSON
                // Here we are not removing duplicate Candidate records because we need all the candidates to create ratings.
                var fullList = [];
                var recipientEmail;
                this.csvData = JSON.parse(JSON.stringify(results.data));
                this.csvData.forEach(row => {
                    let is360Product;
                    row["Bureau Job"] = this.jobId;
                    row["Work Request"] = this.submittedWRFId;
                    row["jobRegion"] = this.jobRegion;
                    if (!row.hasOwnProperty('Category') && this.isNotMFSSystem) {
                        row["Category"] = 'Self';
                    }
                    if (this.productAssessment) {
                        row["Product/Assessment"] = this.productAssessment;
                    }
                    row["uniqueId"] = this.jobId + row["First Name"] + row["Last Name"] + row["Email"];
                    /*if (this.isMFSSystem && !(row["Category"] == "" || row["Category"] == undefined || row["Category"] == null)) {
                        if (row["Category"] == 'Self') {
                            recipientEmail = row["Email"];
                            row["Recipient Email"] = recipientEmail;
                        }
                        if (row["Category"] != 'Self' && !(row["Category"] == "" || row["Category"] == undefined || row["Category"] == null)) {
                            row["Recipient Email"] = recipientEmail;
                        }
                    } else {
                        row["Recipient Email"] = row["Email"];
                    }*/
                    ////////////////////////////////////////////////////////
                    ////console.log('this.isMFSSystem: ', this.isMFSSystem);
                   /* if (this.isMFSSystem) {
                        if (row["Category"] == 'Self') {
                            if (row["Product/Assessment"]) {
                                let products = row["Product/Assessment"].toUpperCase();
                                is360Product = (products?.includes('SHL 360')) ? true : (products?.includes('NOMINATION') ? true : ((products?.includes('ENGAGEMENT') ? true : false)));

                                if (is360Product == true) {
                                    recipientEmail = row["Email"];
                                    row["Recipient Email"] = recipientEmail;
                                } else {
                                    recipientEmail = undefined;
                                }
                            } else {
                                recipientEmail = undefined;
                            }
                        }
                        if (row["Category"] != 'Self' && !(row["Category"] == "" || row["Category"] == undefined || row["Category"] == null)) {
                            row["Recipient Email"] = recipientEmail;
                        }
                    } else {
                        row["Recipient Email"] = row["Email"];
                    } */

                    /* END Logic to add Recipient Email */

                    //fullList.push(row);
                });

                this.copyOfCsvData = JSON.parse(JSON.stringify(this.csvData));

                //fullList = [];
                if (!this.updateCandidate) {
                    /* START Logic to remove Duplicates */
                    const uniqueObjects = this.uniqueByKeepSelf(this.csvData);
                    this.csvData = [...uniqueObjects];
                    this.csvData.forEach(row => {
                        fullList.push(row);
                    });
                    /* END Logic to remove Duplicates */
                }
                this.csvData.forEach(row => {
                    fullList.push(row);
                });

                this.fullJSON = [...fullList];
                //console.log('this.fullJSON: ', JSON.stringify(this.fullJSON));

                // New Change Aashi
                this.csvDatafromJSON = this.unparseJSON(this.fullJSON);
                //console.log('this.csvDatafromJSON: ', JSON.stringify(this.csvDatafromJSON));

                /////////////////////////////////////////////////////////////////////////////////////////////////////
                //Below logic is written for ratings
                //if (this.isMFSSystem) {
                var ratingList = [];
                this.copyOfCsvData = this.copyOfCsvData.map(item => {
                    return {
                        "Category": item["Category"],
                        "Email": item["Email"],
                        "Recipient Email": item["Recipient Email"]
                    };
                });
                //console.log('this.copyOfCsvData: ', JSON.stringify(this.copyOfCsvData));

                this.copyOfCsvData.forEach(row => {
                    if (row["Recipient Email"]) {
                        ratingList.push(row);
                    }
                });
                this.jobRatingData = [...ratingList];
                //console.log('this.jobRatingData: ', JSON.stringify(this.jobRatingData));
                this.ratingCsvDatafromJSON = this.unparseJSON(this.jobRatingData);
                //console.log('this.ratingCsvDatafromJSON: ', JSON.stringify(this.ratingCsvDatafromJSON));

                /* Logic to replace Column Labels with API Name */
                let rowData2 = new Set();
                this.jobRatingData.forEach(function (record) {
                    Object.keys(record).forEach(function (key) {
                        rowData2.add(key);
                    });
                });
                rowData2 = Array.from(rowData2);
                const fruits2 = new Map();
                for (let key in rowData2) {
                    if (rowData2.hasOwnProperty(key)) {
                        let rowKeyValue = rowData2[key];
                        let rowKey = this.getKeyByValue(arrayMap4, rowKeyValue);
                        fruits2.set(rowKey, rowKeyValue);
                    }
                }

                let jsonString2 = JSON.stringify(this.jobRatingData);

                for (let key of fruits2.keys()) {
                    let mapValue = fruits2.get(key);
                    let keyStr = "\"" + key + "\":";
                    let valueStr = "\"" + mapValue + "\":";
                    jsonString2 = jsonString2.replaceAll(valueStr, keyStr);
                }
                this.jobRatingData = JSON.parse(jsonString2);
                //console.log('this.jobRatingData: ', JSON.stringify(this.jobRatingData));
                //}
                this.evalutateCriteria();
            }

        }
        var errorProcessing = (error) => {
            //console.log('callPapaParserToGetRecordsInCSVFile error: ', error);
            this.loading = false;
        };
        Papa.parse(this.initialJSON, {
            skipEmptyLines: true,
            quoteChar: '"',
            header: true,
            complete: completeProcessing,
            error: errorProcessing
        })
    }

    getMapKey(mapArray, value) {
        return [...mapArray.entries()].filter(({ 1: v }) => v === value).map(([k]) => k);

    }

    /*uniqueByKeepSelf(a) {
        const arraMap = new Map();
        a.forEach(ele => {
            if (arraMap.has(ele.uniqueId.toUpperCase())) {
                if (ele.Category == 'Self' && arraMap.get(ele.uniqueId.toUpperCase()).Category != 'Self') {
                    //Remove previous value
                    arraMap.delete(ele.uniqueId);
                    arraMap.set(ele.uniqueId.toUpperCase(), ele);
                }
            } else {
                arraMap.set(ele.uniqueId.toUpperCase(), ele);
            }
        });
        return arraMap.values();
    }*/

    unparseJSON(jsonToCSV) {
        var csv = Papa.unparse(jsonToCSV, {
            quotes: false,
            quoteChar: '"',
            escapeChar: '"',
            delimiter: ",",
            header: true,
            newline: "\r\n",
            skipEmptyLines: false, //other option is 'greedy', meaning skip delimiters, quotes, and whitespace.
            columns: null //or array of strings
        });
        return csv;
    }

    evalutateCriteria() { // IN USE
        //console.log('evalutateCriteria: ');

        var fileName;
        this.recordCount = this.jobCandidateData.length;
        if (this.jobCandidateData.length <= 1000) {
            //fileName = file.name; //this.jobName + '_CandidateFileUpload';// wrf changes
            fileName = this.jobName + '_CandidateFileUpload.csv';// wrf changes
            // Attach file Job record
            //this.convertJSONToBase64(fileName);
            this.insertCandidateLessThan10K(fileName);
        }
        else {
            if (this.updateCandidate) {
                fileName = this.jobName + '_CandidateWRFUpdateSheet.csv';
            } else {
                fileName = this.jobName + '_CandidateWRFImportSheet.csv';
            }
            // Insert using Bulk API
            this.showLoadingSpinner = true;
            this.insertCandidates10KOrMoreThan10K(fileName);
        }
    }

    toast(title, message, variant, mode) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
        })
        this.dispatchEvent(toastEvent)
    }

    /*insertRating(fileName) {
        //console.log('Inside insertRating: ');
        createRatings({
            ratingJSON: JSON.stringify(this.jobRatingData),
            bureauJobId: this.jobId,
            wrfId: this.recordId,
            isUpdate: this.updateCandidate
        })
            .then(data => {
                //console.log('data: ', JSON.stringify(data));
                let title = fileName + ' uploaded successfully!!';
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                this.errorMessage = title;
                this.displayMessage('SUCCESS', this.errorMessage, 'slds-theme_success');
                this.dispatchEvent(new CloseActionScreenEvent());
                this.refreshPage();
            })
            .catch(error => {
                //console.log('insetrrating 615 error: ', JSON.stringify(error));
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                this.errorMessage = error.body.message;
                this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }*/

    insertCandidateLessThan10K(fileName) { // IN USE
        this.showLoadingSpinner = true;
        //console.log('JSON.stringify(this.jobCandidateData): ', JSON.stringify(this.jobCandidateData));
        createCandidates({
            candidatesJSON: JSON.stringify(this.jobCandidateData),
            fieldList: this.rowHeaderToImport
        })
            .then(data => {
                this.showLoadingSpinner = false;
                this.toast('Success', 'Candidates Updated SuccessFully', 'success', 'dismissible');
                //console.log('Update done ');
                this.dispatchEvent(new CustomEvent('updatestatus', {
                    detail: {
                        message: 'Update Done'
                    }
                }));
                //this.refreshPage();
                //this.insertRating(fileName);
                /*if (this.isMFSSystem && !this.updateCandidate) {
                    this.insertRating(fileName);
                } else {
                    this.disableInput = false;
                    let title = fileName + ' uploaded successfully!!';
                    this.showLoadingSpinner = false;
                    this.showErrorMessage = true;
                    this.errorMessage = title;
                    this.displayMessage('SUCCESS', this.errorMessage, 'slds-theme_success');
                    this.refreshPage();
                    this.dispatchEvent(new CloseActionScreenEvent());
                }*/
            })
            .catch(error => {
                //console.log('lessthan10K error: ', JSON.stringify(error));
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                var errorStr = error.body.message;
                this.errorMessage = error.body.message;
                this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    insertCandidates10KOrMoreThan10K(fileName) { // IN USE
        this.callPapaParserToDivideFileInChunks(fileName);
    }

    //This function helps to find value based on key
    getKeyByValue(object, value) {
        return Object.keys(object).find(key => object[key] === value);
    }

    // Call Papa parser to divide file into chunks
    callPapaParserToDivideFileInChunks(fileName) { // IN USE
        var chunkProcessing = (results, parser) => {
            this.csvData = JSON.parse(JSON.stringify(results.data));
            //console.log('results.data: ', JSON.stringify(results.data));
            var candidatesList = [];
            this.csvData.forEach(row => {
                if (!this.updateCandidate) {
                    delete row["Recipient Email"];
                }
                /* START Logic to generate Candidate Unique Id */
                //row["uniqueId"] = this.jobId + this.recordId + row["First Name"] + row["Last Name"] + row["Email"];
                /* END Logic to generate Candidate Unique Id */
                candidatesList.push(row);
            });
            this.jobCandidateData = [...candidatesList];
            //console.log('this.jobCandidateData: ', JSON.stringify(this.jobCandidateData));
            this.stopProcessing = true;
            if (this.stopProcessing) {
                parser.pause();
            }
            this.convertJSONToBase64(fileName, parser);
        };

        var completeProcessing = (results) => {
            /*if (!this.isMFSSystem || this.updateCandidate) {
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                this.errorMessage = 'This job has more than 1000 candidates and can not be imported Immediately. A background process has been started and you will be notified by an email once import is completed.';
                this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');
                this.dispatchEvent(new CloseActionScreenEvent());
            }*/
            this.showLoadingSpinner = false;
            this.showErrorMessage = true;
            this.errorMessage = 'This job has more than 1000 candidates and can not be imported Immediately. A background process has been started and you will be notified by an email once import is completed.';
            this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');
            this.dispatchEvent(new CloseActionScreenEvent());
            getJobStatus({ jobId: this.recordId })
                .then(result => {
                    //console.log('inside getJobStatus: ');
                    //this.createFilesForRating(fileName);
                    /*if (this.isMFSSystem && (!this.updateCandidate)) {
                        //console.log('inside getJobStatus: 707 ');
                        this.createFilesForRating(fileName);
                        //console.log('inside getJobStatus: 709 ');
                    } else {
                        this.refreshPage();
                    }*/
                    //console.log('inside getJobStatus: 711 ');
                    this.showLoadingSpinner = false;
                    this.dispatchEvent(new CustomEvent('updatestatus', {
                        detail: {
                            message: 'Update Done'
                        }
                    }));
                })
                .catch(error => {
                    //console.log('inside getJobStatus: 714 ');
                    //console.log('getJobStatus error: ', error);
                    this.showLoadingSpinner = false;
                });
        };

        var errorProcessing = (error) => {
            //console.log('errorProcessing 715 error: ', JSON.stringify(error));
            this.loading = false;
        };

        Papa.parse(this.csvDatafromJSON, {
            quoteChar: '"',
            header: 'true',
            chunkSize: 1024 * 1024 * 1.5,
            chunk: chunkProcessing,
            complete: completeProcessing,
            error: errorProcessing
        })
    }

    refreshPage() {
        this.dispatchEvent(new CustomEvent('force:refreshView'));
        //console.log('Inside Refresh 1');
        getRecordNotifyChange([{ recordId: this.recordId }]);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Job__c',
                actionName: 'view'
            }
        });
        //console.log('Inside Refresh 2');
    }

    convertJSONToBase64(fileName, parser) { // IN USE
        //console.log('convertJSONToBase64: ');
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        if (!this.updateCandidate) {
            //rowData = this.importRowHeadingsUpdate;
        } else {
            rowData = this.rowHeaderToImport;
        }

        csvString += rowData.join(',');
        csvString += rowEnd;

        for (let i = 0; i < this.jobCandidateData.length; i++) {
            let colValue = 0;
            for (let key in rowData) {
                if (rowData.hasOwnProperty(key)) {
                    let rowKeyValue = rowData[key];
                    let rowKey;
                    if (this.recordCount <= 1000) {
                        rowKey = rowKeyValue;
                    } else {
                        if (this.updateCandidate) {
                            rowKey = rowKeyValue;
                        } else {
                            rowKey = this.arrayMap1[rowKeyValue];
                        }
                    }

                    if (colValue > 0) {
                        csvString += ',';
                    }
                    let value = this.jobCandidateData[i][rowKey] === undefined ? '' : this.jobCandidateData[i][rowKey];
                    csvString += '"' + value + '"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        //console.log('csvString: ', csvString);
        uploadFile({
            base64: csvString,
            filename: fileName,
            recordId: this.recordId
        })
            .then(result => {
                //console.log('result: ', result);
                this.contentDocumentId = result;
                //console.log('this.contentDocumentId: ', this.contentDocumentId);
                //console.log('recordCount: ', this.recordCount);
                if (this.stopProcessing) {
                    //console.log('recordCount: ', this.stopProcessing);
                    this.stopProcessing = false;
                    parser.resume();
                }
                return false;
            })
            .catch(error => {
                //console.log('convertjsontobase64 error: ', JSON.stringify(error));
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                //this.errorMessage = error.body.message + '. A Server Error Occurred Please Contact the System Administrator';
                this.errorMessage = '. A Server Error Occurred Please Contact the System Administrator';
                this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                return false;
            });
        return false;
    }

    validateColumns(errorMessage) {
        var result = true;
        let rowDataHeader = new Set();
        this.tempCsvData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowDataHeader.add(key);
            });
        });

        //row header from file
        rowDataHeader = Array.from(rowDataHeader);
        //console.log('rowDataHeader: ', JSON.stringify(rowDataHeader));
        //console.log('rowHeaderToImport ', JSON.stringify(this.rowHeaderToImport));
        /*if (rowDataHeader.length == 0 || JSON.stringify(rowDataHeader) == '' || JSON.stringify(rowDataHeader) == undefined || JSON.stringify(rowDataHeader) == null) {
            result = false;
            errorMessage = errorMessage + 'The imported file is blank. Please provide candidate details';
            this.errorMessage = errorMessage;
            return result;
        }*/

        if (rowDataHeader.length != this.rowHeaderToImport.length || JSON.stringify(rowDataHeader) != JSON.stringify(this.rowHeaderToImport)) {
            result = false;
            errorMessage = errorMessage + 'The import CSV file has invalid first line. Please ensure that the first line has the following values and order: ' + this.rowHeaderToImport;
            this.errorMessage = errorMessage;
            return result;
        }
        //console.log('result: ', result);
        return result;
    }

    //this is 5th fun get called when clicked on import candidate, and if headers are correct
    validateData(errorMessage) {
        //console.log('Inside validateData: ');
        var result = true;
        let lineNo;
        let errorOccur;

        this.tempCsvData.every((row, index) => {
            lineNo = index + 2;
            if (!result) {
                return result;
            }
            this.candidateData.every(element => {
                if ((element.hideDelete)
                    && (row[element.API_Name__c] == null || row[element.API_Name__c] == "" || row[element.API_Name__c] == 'undefined')) {
                    errorOccur = true; result = false;
                    errorMessage = errorMessage + "Line " + lineNo + ": Required Field: " + element.API_Name__c + " is blank.";
                    return result;
                }

                if (row[element.API_Name__c] !== null && row[element.API_Name__c] !== "" && row[element.API_Name__c] !== 'undefined') {
                    if (element.Data_Type__c == 'DropDown') {
                        let rowValue = row[element.API_Name__c].toUpperCase();
                        let valueList = element.Values__c.toUpperCase();
                        if (!valueList.includes(rowValue)) {
                            errorOccur = true; result = false;
                            errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in " + element.API_Name__c + " column.";
                            return result;
                        }
                    }
                    if (element.Data_Type__c == 'email') {
                        let emailValue = row[element.API_Name__c];
                        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,63}))$/;
                        if (!emailValue.match(emailRegex)) {
                            errorOccur = true; result = false;
                            errorMessage = errorMessage + "Line " + lineNo + ": Invalid Email";
                            return result;
                        }
                    }
                }
                return true;
            });
            return true;
        });

       /* if (!this.productAssessment) {
            errorOccur = true; result = false;
            errorMessage = errorMessage + "Required Field: Product/Assessment is blank on Work Request.";
            //return result;
        }*/

        this.errorMessage = errorMessage;
        //console.log('this.errorMessage: ', this.errorMessage);
        //console.log('result: ', result);
        return result;
    }

    displayMessage(errorType, errorMessage, className) {
        this.errorMessage = errorMessage;
        this.errorType = errorType;
        let variant;
        if (className.includes('success')) {
            variant = 'success';
        } else {
            variant = 'error';
        }
        this.toast(errorType, errorMessage, variant, 'dismissible');
    }

    removeMessage(errorType, errorMessage, className) {
        this.errorMessage = errorType;
        this.errorType = errorMessage;
    }

    createFilesForRating(fileName) {
        //console.log('fileName: 907 ', fileName);
        var chunkProcessing = (results, parser) => {
            //console.log('Inside chunkProcessing: ');
            this.csvData = JSON.parse(JSON.stringify(results.data));

            /////////////////////////////////////////////////////////////////////////////////////////////////////
            //if (this.isMFSSystem) {
            this.csvDataRating = JSON.parse(JSON.stringify(results.data));
            var ratingList = [];

            this.csvDataRating = this.csvDataRating.map(item => {
                return {
                    "Category": item["Category"],
                    "Email": item["Email"],
                    "Recipient Email": item["Recipient Email"]
                };
            });

            this.csvDataRating.forEach(row => {
                if (row["Recipient Email"]) {
                    ratingList.push(row);
                }
            });
            this.jobRatingData = [...ratingList];

            /* Logic to replace Column Labels with API Name */
            let rowData2 = new Set();
            this.jobRatingData.forEach(function (record) {
                Object.keys(record).forEach(function (key) {
                    rowData2.add(key);
                });
            });
            rowData2 = Array.from(rowData2);
            const fruits2 = new Map();
            for (let key in rowData2) {
                if (rowData2.hasOwnProperty(key)) {
                    let rowKeyValue = rowData2[key];
                    let rowKey = this.getKeyByValue(arrayMap4, rowKeyValue);
                    fruits2.set(rowKey, rowKeyValue);
                }
            }

            let jsonString2 = JSON.stringify(this.jobRatingData);
            for (let key of fruits2.keys()) {
                let mapValue = fruits2.get(key);
                let keyStr = "\"" + key + "\":";
                let valueStr = "\"" + mapValue + "\":";
                jsonString2 = jsonString2.replaceAll(valueStr, keyStr);
            }
            this.jobRatingData = JSON.parse(jsonString2);
            //}
            /////////////////////////////////////////////////////////////////////////////////////////////////////

            this.stopProcessing = true;
            if (this.stopProcessing) {
                parser.pause();
            }
            this.convertJSONToBase64Rating(fileName, parser);
        };

        var completeProcessing = (results) => {
            this.showLoadingSpinner = false;
            this.showErrorMessage = true;
            this.errorMessage = 'This job has more than 1000 candidates and can not be imported Immediately. A background process has been started and you will be notified by an email once import is completed.';
            this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');
            this.dispatchEvent(new CloseActionScreenEvent());
            this.refreshPage();
        };

        var errorProcessing = (error) => {
            this.loading = false;
            this.dispatchEvent(new CloseActionScreenEvent());
        };
        // replaced file with this.csvDatafromJSON
        Papa.parse(this.ratingCsvDatafromJSON, {
            quoteChar: '"',
            header: 'true',
            chunkSize: 1024 * 1024 * 1.0,
            chunk: chunkProcessing,
            complete: completeProcessing,
            error: errorProcessing
        })
    }

    convertJSONToBase64Rating(fileName, parser) { // IN USE

        let s2 = fileName;
        let fileName1 = s2.replace('Sheet.csv', 'Rating.csv');
        fileName = fileName1;

        let csvString2 = '';
        //if (this.isMFSSystem) {
        csvString2 += this.unparseJSON(this.jobRatingData);
        //}

        uploadFile({
            base64: csvString2,
            filename: fileName,
            recordId: this.recordId
        })
            .then(result => {
                //console.log('inside uploadFile: ');
                this.contentDocumentId = result;
                if (this.stopProcessing) {
                    this.stopProcessing = false;
                    parser.resume();
                }
            })
            .catch(error => {
                //console.log('upload file 1008 error: ', JSON.stringify(error));
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                return false;
            });
        return false;
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        this.showFileName = false;
        //console.log('generatedWrfId child '+this.generatedWrfId);
        //console.log('recordId child '+this.recordId);
        //this.generatedWrfId='a3aPu000001EiVFIA0';
        const uploadedFiles = event.detail.files;
        this.documentName = uploadedFiles[0].name;
        //console.log('this.documentName: ', this.documentName);
        //console.log('event.detail.files: ', JSON.stringify(event.detail.files));
        let docId = uploadedFiles[0].documentId;
        //console.log('docId: ', docId);
        let contentVersion = uploadedFiles[0].contentVersionId;
        //console.log('contentVersion: ', contentVersion);
        this.contentVersionId = contentVersion;

        //console.log('this.contentVersionId: ', this.contentVersionId);
        this.contentDocumentId = docId;
        const successEvent = new CustomEvent("candidatedetails", {
            detail: {
                contentVersionId: null,
                documentName: this.documentName
            }
        });
        this.dispatchEvent(successEvent);
    }




}