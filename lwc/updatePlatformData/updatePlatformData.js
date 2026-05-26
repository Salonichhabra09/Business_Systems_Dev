import { LightningElement, track, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import VERSION_DATA_FIELD from '@salesforce/schema/ContentVersion.VersionData';
import CANDIDATE_FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Candidate_Field_Configuration__c';
import getWRFAndJobData from '@salesforce/apex/CustomerRequestController.getWRFAndJobData';
import updateRating from '@salesforce/apex/CustomerRequestController.updateRating';
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
import MFS_STATUS_FIELD from '@salesforce/schema/Bureau_Rating__c.MFS_Status__c';
import TC_STATUS_FIELD from '@salesforce/schema/Bureau_Rating__c.TC_Status__c';
import REPORT_STATUS from '@salesforce/schema/Bureau_Rating__c.Report_Ready__c';
import TC_REPORT_SENT from '@salesforce/schema/Bureau_Rating__c.TC_Report_Sent__c';
import MFS_REPORT_SENT from '@salesforce/schema/Bureau_Rating__c.MFS_Report_Sent__c';
import VADC_Status from '@salesforce/schema/Bureau_Rating__c.VADC_Status__c';
import Insights_Status from '@salesforce/schema/Bureau_Rating__c.Insights_Status__c';

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

    rowHeaderToImport = [];
    candidateData;
    generatedWRFId;
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
    arrayOfMFSStatusValues = [];
    arrayOfTCStatusValues = [];
    arrayOfReportStatusValues = [];
    arrayOfMFSSentValues = [];
    arrayOfTCSentValues = [];
    arrayOfVADCStatusValues = [];
    arrayOfInsightsStatusValues = [];

    get acceptedFormats() {
        return ['.csv'];
    }

    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => {
                    //console.log('inside parser');
                    this.parserInitialized = true;
                })
                .catch(error => console.error('parser error', error));
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: MFS_STATUS_FIELD })
    wiredMFSStatusValues({ error, data }) {
        if (data) {
            //console.log('data ' + JSON.stringify(data));
            data.values.forEach(element => {
                this.arrayOfMFSStatusValues.push(element.value);
            })
            //console.log('MFS Values ' + JSON.stringify(this.arrayOfMFSStatusValues));
        } else if (error) {

        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: TC_STATUS_FIELD })
    wiredTCStatusValues({ error, data }) {
        if (data) {
            data.values.forEach(element => {
                this.arrayOfTCStatusValues.push(element.value);
            })
            //console.log('TC Values ' + JSON.stringify(this.arrayOfTCStatusValues));
        } else if (error) {

        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: REPORT_STATUS })
    wiredReportStatusValues({ error, data }) {
        if (data) {
            data.values.forEach(element => {
                this.arrayOfReportStatusValues.push(element.value);
            })
            //console.log('Report Values ' + JSON.stringify(this.arrayOfReportStatusValues));
        } else if (error) {

        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: MFS_REPORT_SENT })
    wiredMFSSentValues({ error, data }) {
        if (data) {
            data.values.forEach(element => {
                this.arrayOfMFSSentValues.push(element.value);
            })
            //console.log('Sent Values MFS ' + JSON.stringify(this.arrayOfMFSSentValues));
        } else if (error) {
            //console.log('Error ' + error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: TC_REPORT_SENT })
    wiredTCSentValues({ error, data }) {
        if (data) {
            data.values.forEach(element => {
                this.arrayOfTCSentValues.push(element.value);
            })
            //console.log('Sent Values TC' + JSON.stringify(this.arrayOfTCSentValues));
        } else if (error) {

        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Insights_Status })
    wiredInsightStatusValues({ error, data }) {
        if (data) {
            data.values.forEach(element => {
                this.arrayOfInsightsStatusValues.push(element.value);
            })
            //console.log('arrayOfInsightsStatusValues ' + JSON.stringify(this.arrayOfInsightsStatusValues));
        } else if (error) {

        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: VADC_Status })
    wiredVADCStatusValues({ error, data }) {
        if (data) {
            data.values.forEach(element => {
                this.arrayOfVADCStatusValues.push(element.value);
            })
            //console.log('arrayOfVADCStatusValues ' + JSON.stringify(this.arrayOfVADCStatusValues));
        } else if (error) {

        }
    }

    connectedCallback() {
        /*  this.showLoadingSpinner = true;
          setTimeout(() => {
              //console.log('this.recordId: ', this.recordId);
              this.makeApexCallout();
          }, 100); */
    }

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

    checkCompletionStatusForAll(data) {
        let groupedByFocus = this.groupByFocusName(data);
        //console.log('groupedByFocus: ', JSON.stringify(groupedByFocus));
        let results = {};

        for (let focusName in groupedByFocus) {
            let focusData = groupedByFocus[focusName];
            results[focusName] = this.checkCompletionStatus(focusData);
        }

        data = data.map(row => {
            //console.log('row: ', JSON.stringify(row));
            //console.log('results[row.Respondent__r.Full_Name__c]: ', results[row["Participant__r.Full_Name__c"]]);
            let reportReady = (results.hasOwnProperty(row["Participant__r.Email__c"]) && (row["Rater_Type__c"] == 'Self')) ? results[row["Participant__r.Email__c"]] : null;
            //console.log('reportReady: ', reportReady);
            //row["Report_Ready__c"] = reportReady;
            return {
                ...row,
                Report_Ready__c: reportReady
            }
        });
        //console.log('data: ', JSON.stringify(data));
        return data;
    }

    groupByFocusName(data) {
        let grouped = {};
        data.every(row => {
            //console.log('row: ', row["Participant__r.Full_Name__c"]);
            //console.log('row: ', row.Participant__r.Full_Name__c);
            return false;
        });
        data.forEach(row => {
            if (!grouped[row["Participant__r.Email__c"]]) {
                grouped[row["Participant__r.Email__c"]] = [];
            }
            grouped[row["Participant__r.Email__c"]].push(row);
        });

        return grouped;
    }

    checkCompletionStatus(focusData) {
        let minimumCriteria = {
            //'Manager': 1,
            'Direct Reports': 2,
            'Colleagues': 2,
            'Others': 2
        };

        let completionCount = {};
        let focusPersonCompleted = false;
        let managerPersonCompleted = false;
        let totalRaters = 0;
        let completedCount = 0;
        let actualCount = {};
        let result = 'Can not be generated';
        //console.log('focusData: ', JSON.stringify(focusData));
        totalRaters = focusData.length;
        //console.log('totalRaters: ', totalRaters);
        // Count completed raters for each category
        focusData.forEach(row => {
            if (row["MFS_Status__c"] === 'Completed') {
                completedCount++;
                if (!completionCount.hasOwnProperty(row["Rater_Type__c"])) {
                    completionCount[row["Rater_Type__c"]] = 1;
                } else {
                    completionCount[row["Rater_Type__c"]]++;
                }
            }
            if (!actualCount.hasOwnProperty(row["Rater_Type__c"])) {
                actualCount[row["Rater_Type__c"]] = 1;
            } else {
                actualCount[row["Rater_Type__c"]]++;
            }

            if (row["Rater_Type__c"] === 'Self' && row["MFS_Status__c"] === 'Completed') {
                focusPersonCompleted = true;
            }
            if (row["Rater_Type__c"] === 'Manager' && row["MFS_Status__c"] === 'Completed') {
                managerPersonCompleted = true;
            }
        });
        //console.log('completedCount: ', completedCount);
        //console.log('completionCount: ', JSON.stringify(completionCount));
        for (let row in completionCount) {
            //console.log('row: ', row);
            //console.log('row: ', JSON.stringify(row));
        }
        // Check if minimum criteria met
        let criteriaMet = false;
        let count = 0;
        let generatedCount = 0;
        for (let raterType in minimumCriteria) {
            //console.log('raterType: ', raterType);
            //console.log('actualCount: ', JSON.stringify(actualCount));
            if (actualCount.hasOwnProperty(raterType) && raterType != 'Manager') {
                if (actualCount[raterType] < minimumCriteria[raterType]) {
                    result = 'Data Insufficient';
                    //return result;
                }
            }
            if (!actualCount.hasOwnProperty('Manager')) {
                result = 'Data Insufficient';
                //return result;
            }
            if (completionCount.hasOwnProperty(raterType) && raterType != 'Manager') {
                if (result != 'Data Insufficient' &&
                    completionCount[raterType] >= minimumCriteria[raterType] &&
                    (focusPersonCompleted && managerPersonCompleted)) {
                    //result = 'Can be Generated';
                    generatedCount++;
                    //return result;
                }
            }
        }

        let ratersInCompletionCount = Object.keys(completionCount).length;
        if (result != 'Data Insufficient' && generatedCount == (ratersInCompletionCount - 2)) {
            result = 'Can be Generated';
        }

        if (result != 'Data Insufficient' && completedCount == totalRaters) {
            result = '100% Completed';
            //return result;
        }
        //console.log('result: ', result);
        return result;
    }

    calculateOverAllStatus(row) {
        if ((!row["MFS_Status__c"]) && (!row["TC_Status__c"])) {
            return null;
        }
        else if ((row["MFS_Status__c"]) && (!row["TC_Status__c"])) {
            return row["MFS_Status__c"];
        }
        else if ((!row["MFS_Status__c"]) && (row["TC_Status__c"])) {
            return row["TC_Status__c"];
        }
        else if (row["MFS_Status__c"] == 'Not Started' && row["TC_Status__c"] == 'Not Started') {
            return 'Not Started';
        }
        else if (row["MFS_Status__c"] == 'Not Started' && row["TC_Status__c"] == 'In Progress') {
            return 'In Progress';
        }
        else if (row["MFS_Status__c"] == 'Not Started' && row["TC_Status__c"] == 'Completed') {
            return 'In Progress';
        }
        else if (row["MFS_Status__c"] == 'In Progress' && row["TC_Status__c"] == 'Not Started') {
            return 'In Progress';
        }
        else if (row["MFS_Status__c"] == 'In Progress' && row["TC_Status__c"] == 'In Progress') {
            return 'In Progress';
        }
        else if (row["MFS_Status__c"] == 'In Progress' && row["TC_Status__c"] == 'Completed') {
            return 'In Progress';
        }
        else if (row["MFS_Status__c"] == 'Ready to Submit' && row["TC_Status__c"] == 'Not Started') {
            return 'In Progress';
        }
        else if (row["MFS_Status__c"] == 'Ready to Submit' && row["TC_Status__c"] == 'In Progress') {
            return 'In Progress';
        }
        else if (row["MFS_Status__c"] == 'Ready to Submit' && row["TC_Status__c"] == 'Completed') {
            return 'Ready to Submit';
        }
        else if (row["MFS_Status__c"] == 'Completed' && row["TC_Status__c"] == 'Not Started') {
            return 'In Progress';
        }
        else if (row["MFS_Status__c"] == 'Completed' && row["TC_Status__c"] == 'In Progress') {
            return 'In Progress';
        }
        else if (row["MFS_Status__c"] == 'Completed' && row["TC_Status__c"] == 'Completed') {
            return 'Completed';
        }
        else {
            return null;
        }

    }

    formatDateToISO(dateStr) {
        if (!dateStr || dateStr.trim() === '') {
            return ''; // return blank if no value
        }
        //SSE-29741 Change in Deadline Line formatting
        if(dateStr.includes('-')){
            const [day, month, year] = dateStr.split("-");
            return `${year}-${month}-${day}`;
        }
    }

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
                console.log('inside if');
                this.showLoadingSpinner = false;
                this.disableInput = false;
                this.showErrorMessage = true;
                this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            //If no error
            else {
                console.log('No Error Found!!!');
                console.log('this.csvData: ', JSON.stringify(this.csvData));
                var candidatesList = [];
                const raterStringMap1 = new Map();
                const reminderMap1 = new Map();
                /* Logic to add Bureau Job */
                this.csvData = this.checkCompletionStatusForAll(this.csvData);
                //console.log('this.csvData after report ready formula : ', JSON.stringify(this.csvData));
                let computeForNonSelf1 = false;
                const participantEmailNameMap = new Map();
                this.csvData.forEach(row => {
                    participantEmailNameMap.set(row["Participant__r.Email__c"], row["Participant__r.Full_Name__c"]);
                });
                this.csvData.forEach(row => {
                    row["Deadline__c"] = this.formatDateToISO(row["Deadline__c"]);
                    row["Overall_Status__c"] = this.calculateOverAllStatus(row);
                    //console.log('row["Overall_Status__c"]: ', row["Overall_Status__c"]);
                    //console.log('row["TC_Status__c"]: ', row["TC_Status__c"]);
                    if (row["Rater_Type__c"] != 'Self') {
                        if (row["MFS_Status__c"] != 'Completed') {
                            let respondentEmail = row["Respondent__r.Email__c"].toLowerCase();
                            if (!raterStringMap1.has(respondentEmail)) {
                                raterStringMap1.set(respondentEmail, participantEmailNameMap.get(row["Participant__r.Email__c"]));
                            } else {
                                let oldValue = raterStringMap1.get(respondentEmail);
                                if (oldValue == '') {
                                    raterStringMap1.set(respondentEmail, participantEmailNameMap.get(row["Participant__r.Email__c"]));
                                } else {
                                    raterStringMap1.set(respondentEmail, oldValue + ', ' + participantEmailNameMap.get(row["Participant__r.Email__c"]));
                                }
                                //raterStringMap1.set(respondentEmail, oldValue + ', ' + participantEmailNameMap.get(row["Participant__r.Email__c"]));
                            }
                        }
                        else if (row["MFS_Status__c"] == 'Completed') {
                            let respondentEmail = row["Respondent__r.Email__c"].toLowerCase();
                            if (!raterStringMap1.has(respondentEmail)) {
                                raterStringMap1.set(respondentEmail, '');
                            }
                        }
                    }
                    if (row["Rater_Type__c"] == 'Self') {
                        if (row["MFS_Report_Sent__c"] == 'Sent' && row["TC_Report_Sent__c"] == 'Sent') {
                            computeForNonSelf1 = false;
                            let participantEmail = row["Participant__r.Email__c"].toLowerCase();
                            reminderMap1.set(participantEmail, 'Not Eligible');
                        }
                        else if (row["MFS_Report_Sent__c"] == 'Not Sent' || row["TC_Report_Sent__c"] == 'Not Sent') {
                            computeForNonSelf1 = true;
                            let participantEmail = row["Participant__r.Email__c"].toLowerCase();
                            let respondentEmail = row["Respondent__r.Email__c"].toLowerCase();
                            let key = participantEmail + respondentEmail;
                            if (row["Overall_Status__c"] == 'In Progress' || row["Overall_Status__c"] == 'Not Started') {
                                reminderMap1.set(key, 'Eligible');
                            }
                            else {
                                reminderMap1.set(key, 'Not Eligible');
                            }
                        }
                        else if (row["TC_Report_Sent__c"] == 'Sent' && row["MFS_Report_Sent__c"] == '') {
                            computeForNonSelf1 = false;
                            let participantEmail = row["Participant__r.Email__c"].toLowerCase();
                            reminderMap1.set(participantEmail, 'Not Eligible');
                            //console.log('reminderMap1 else if sent value : ', JSON.stringify(reminderMap1));
                        }
                    }
                    if (computeForNonSelf1 && row["Rater_Type__c"] != 'Self') {
                        let participantEmail = row["Participant__r.Email__c"].toLowerCase();
                        let respondentEmail = row["Respondent__r.Email__c"].toLowerCase();
                        let key = participantEmail + respondentEmail;
                        if (row["Overall_Status__c"] == 'In Progress' || row["Overall_Status__c"] == 'Not Started') {
                            reminderMap1.set(key, 'Eligible');
                        }
                        else {
                            reminderMap1.set(key, 'Not Eligible');
                        }
                    }
                    //console.log('reminderMap1: ', JSON.stringify(reminderMap1));
                    //candidatesList.push(row);
                });
                //console.log('this.csvData after reminder formula : ', JSON.stringify(this.csvData));

                candidatesList = [];
                //console.log('inside me: ');
                /* START Logic to remove Duplicates */
                //console.log('this.csvData after unique: ', JSON.stringify(this.csvData));
                this.csvData.forEach(row => {
                    row["Rater_String__c"] = (raterStringMap1.get(row["Respondent__r.Email__c"].toLowerCase()));
                    let participantEmail = row["Participant__r.Email__c"].toLowerCase();
                    let respondentEmail = row["Respondent__r.Email__c"].toLowerCase();
                    let key = participantEmail + respondentEmail;
                    if (reminderMap1.has(key)) {
                        row["Reminder_1__c"] = (reminderMap1.get(key));
                    } else {
                        row["Reminder_1__c"] = (reminderMap1.get(participantEmail));
                    }
                    console.log('row Reminder_1__c: ', JSON.stringify(row));
                    candidatesList.push(row);
                });
                /* END Logic to remove Duplicates */

                this.jobCandidateData = [...candidatesList];
                console.log('this.jobCandidateData: ', JSON.stringify(this.jobCandidateData));

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

                //Below logic is written to create full JSON
                // Here we are not removing duplicate Candidate records because we need all the candidates to create ratings.
                var fullList = [];
                var recipientEmail;
                this.csvData = JSON.parse(JSON.stringify(results.data));
                const raterStringMap = new Map();
                const reminderMap = new Map();
                //const reminderMap1 = new Map();
                this.csvData = this.checkCompletionStatusForAll(this.csvData);
                let computeForNonSelf = false;
                /*this.csvData.forEach(row => {
                    row["Overall_Status__c"] = this.calculateOverAllStatus(row);
                });*/
                /* this.csvData.forEach(row => {
                     row["Overall_Status__c"] = this.calculateOverAllStatus(row);
                     if (row["Rater_Type__c"] != 'Self') {
                         if (row["MFS_Status__c"] != 'Completed') {
                             let respondentName = row["Respondent__r.Full_Name__c"].toLowerCase();
                             if (!raterStringMap.has(respondentName)) {
                                 raterStringMap.set(respondentName, row["Participant__r.Full_Name__c"]);
                             } else {
                                 let oldValue = raterStringMap.get(respondentName);
                                 raterStringMap.set(respondentName, oldValue + ', ' + row["Participant__r.Full_Name__c"]);
                             }
                         }
                         else if (row["MFS_Status__c"] == 'Completed') {
                             let respondentName = row["Respondent__r.Full_Name__c"].toLowerCase();
                             if (!raterStringMap1.has(respondentName)) {
                                 raterStringMap1.set(respondentName, '');
                             }
                         }
                     }
 
                     if (row["Rater_Type__c"] == 'Self') {
                         if (row["MFS_Report_Sent__c"] == 'Sent' && row["TC_Report_Sent__c"] == 'Sent') {
                             computeForNonSelf = false;
                             let participantName = row["Participant__r.Full_Name__c"].toLowerCase();
                             reminderMap.set(participantName, 'Not Eligible');
                         }
                         else if (row["MFS_Report_Sent__c"] == 'Not Sent' || row["TC_Report_Sent__c"] == 'Not Sent') {
                             computeForNonSelf = true;
                             let participantName = row["Participant__r.Full_Name__c"].toLowerCase();
                             let respondentName = row["Respondent__r.Full_Name__c"].toLowerCase();
                             let key = participantName + respondentName;
                             if (row["Overall_Status__c"] == 'In Progress' || row["Overall_Status__c"] == 'Not Started') {
                                 reminderMap.set(key, 'Eligible');
                             }
                             else {
                                 reminderMap.set(key, 'Not Eligible');
                             }
                         }
                     }
                     if (computeForNonSelf && row["Rater_Type__c"] != 'Self') {
                         let participantName = row["Participant__r.Full_Name__c"].toLowerCase();
                         let respondentName = row["Respondent__r.Full_Name__c"].toLowerCase();
                         let key = participantName + respondentName;
                         if (row["Overall_Status__c"] == 'In Progress' || row["Overall_Status__c"] == 'Not Started') {
                             reminderMap.set(key, 'Eligible');
                         }
                         else {
                             reminderMap.set(key, 'Not Eligible');
                         }
                     }
                 });*/

                this.csvData.forEach(row => {
                    //row["Rater_String__c"] = (raterStringMap.get(row["Respondent__r.Full_Name__c"].toLowerCase()));
                    /*let participantName = row["Participant__r.Full_Name__c"].toLowerCase();
                    let respondentName = row["Respondent__r.Full_Name__c"].toLowerCase();
                    let key = participantName + respondentName;
                    if (reminderMap.has(key)) {
                        row["Reminder_1__c"] = (reminderMap.get(key));
                    } else {
                        row["Reminder_1__c"] = (reminderMap.get(participantName));
                    }
                    row["Reminder_1__c"] = (reminderMap.get(row["Participant__r.Full_Name__c"].toLowerCase()));
                    */fullList.push(row);
                });

                this.fullJSON = [...fullList];
                //console.log('this.fullJSON: ', JSON.stringify(this.fullJSON));

                // New Change Aashi
                this.csvDatafromJSON = this.unparseJSON(this.fullJSON);
                console.log('this.csvDatafromJSON: ', JSON.stringify(this.csvDatafromJSON));

                this.evalutateCriteria();
            }

        }
        var errorProcessing = (error) => {
            console.log('callPapaParserToGetRecordsInCSVFile error: ', error);
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

    uniqueByKeepSelf(a) {
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
    }

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
            fileName = this.jobName + '_PlatformFileUpload.csv';// wrf changes
            // Attach file Job record
            //this.convertJSONToBase64(fileName);
            this.insertCandidateLessThan10K(fileName);
        }
        else {
            if (this.updateCandidate) {
                fileName = this.jobName + '_PlatformWRFUpdateSheet.csv';
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

    insertCandidateLessThan10K(fileName) { // IN USE
        this.showLoadingSpinner = true;
        console.log('JSON.stringify(this.jobCandidateData): ', JSON.stringify(this.jobCandidateData));
        updateRating({
            candidatesJSON: JSON.stringify(this.jobCandidateData),
            jobId: this.recordId
        })
            .then(data => {
                this.showLoadingSpinner = false;
                //console.log('Update done ');
                this.toast('Success', 'Platform infromation Updated SuccessFully', 'success', 'dismissible');
                this.dispatchEvent(new CustomEvent('updatestatus', {
                    detail: {
                        message: 'Update Done'
                    }
                }));
            })
            .catch(error => {
                console.log('lessthan10K error: ', JSON.stringify(error));
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
                if (this.updateCandidate) {
                    if (row["Deadline__c"] == '') {
                        row["Deadline__c"] = null;
                    }
                    row["Deadline__c"] = this.formatDateToISO(row["Deadline__c"]);
                    delete row["Participant__r.Work_Request__c"];
                    delete row["Participant__r.Full_Name__c"];
                    delete row["Participant__r.Email__c"];
                    delete row["Respondent__r.Full_Name__c"];
                    delete row["Respondent__r.Email__c"];
                    delete row["Name"];
                    delete row["Overall_Status__c"];
                    delete row["Rater_String__c"];
                    delete row["Reminder__c"];

                }
                /* START Logic to generate Candidate Unique Id */
                //row["uniqueId"] = this.jobId + this.recordId + row["First Name"] + row["Last Name"] + row["Email"];
                /* END Logic to generate Candidate Unique Id */
                candidatesList.push(row);
            });
            this.jobCandidateData = [...candidatesList];
            console.log('this.jobCandidateData: ', JSON.stringify(this.jobCandidateData));
            this.stopProcessing = true;
            if (this.stopProcessing) {
                parser.pause();
            }
            this.convertJSONToBase64(fileName, parser);
        };

        var completeProcessing = (results) => {
            this.showLoadingSpinner = false;
            this.showErrorMessage = true;
            this.errorMessage = 'This job has more than 1000 candidates and can not be imported Immediately. A background process has been started and you will be notified by an email once import is completed.';
            this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');
            this.dispatchEvent(new CloseActionScreenEvent());
            getJobStatus({
                jobId: this.recordId,
                operationType: 'update',
                objectName: 'Bureau_Rating__c'
            })
                .then(result => {
                    //console.log('inside getJobStatus: ');
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
            rowData = ['Id', 'Rater_Type__c', 'VADC_Status__c', 'Insights_Status__c', 'MFS_Status__c', 'TC_Status__c', 'Report_Ready__c', 'MFS_Report_Sent__c', 'TC_Report_Sent__c', 'Report_Sent__c', 'Deadline__c', 'Comments__c', 'File_Name__c', 'Single_Use_Link__c', 'EmailType__c', 'Email_File_Name__c', 'Sharepoint_File_Path__c'];
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
        console.log('Inside validateData: ');
        var result = true;
        let invalidMFSStatus = false;
        let invalidTCStatus = false;
        let invalidReportStatus = false;
        let invalidEmail = false;
        let invalidMFSSent = false;
        let invalidTCSent = false;
        let invalidInsightsStatus = false;
        let invalidVADCStatus = false;
        let invalidDeadlineDate = false;
        let lineNo;

        let errorOccur;

        /*this.dropDownValuesList.forEach(item => {
            //console.log('row: ', row[item.key]);     
        });*/

        this.tempCsvData.every((row, index) => {
            lineNo = index + 2;
            if (!result) {
                return result;
            }
            /*if (row["File_Name__c"]) {
                let emailValue = row["File_Name__c"];
                if(emailValue==null || emailValue==''){
                    return true;
                }
                const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                if (!emailValue.match(emailRegex)) {
                    invalidEmail = true; result = false;
                    return result;
                }
            }*/
            if (this.ignoreMFSStatusDataCase(row)) {
                invalidMFSStatus = true; result = false;
                return result;
            }
            if (this.ignoreTCStatusDataCase(row)) {
                invalidTCStatus = true; result = false;
                return result;
            }
            /*if (this.ignoreReportStatusDataCase(row)) {
                invalidReportStatus = true; result = false;
                return result;
            }*/
            if (this.ignoreMFSSentCase(row)) {
                invalidMFSSent = true; result = false;
                return result;
            }
            if (this.ignoreTCSentCase(row)) {
                invalidTCSent = true; result = false;
                return result;
            }
            if (this.ignoreInsightsCase(row)) {
                invalidInsightsStatus = true; result = false;
                return result;
            }
            if (this.ignoreVADCCase(row)) {
                invalidVADCStatus = true; result = false;
                return result;
            }
            console.log('Date ', this.validateDateFormat(row));
            //SSE-29741 Added validation to check valid Deadline date format. Acceptable format is 'DD-MM'YYYYY'
            if (!this.validateDateFormat(row)){
                invalidDeadlineDate = true; result = false;
                return result;
            }

            /* this.candidateData.every(element => {
                 if (row[element.API_Name__c] == null || row[element.API_Name__c] == "" || row[element.API_Name__c] == 'undefined') {
                     errorOccur = true; result = false;
                     errorMessage = errorMessage + "Line " + lineNo + ": Required Field: " + element.API_Name__c + " is blank.";
                     return result;
                 }
 
                 if (row[element.API_Name__c] !== null && row[element.API_Name__c] !== "" && row[element.API_Name__c] !== 'undefined') {
                     if (element.Data_Type__c == 'DropDown') {
                         let rowValue = row[element.Label__c].toUpperCase();
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
             });*/
            return true;
        });

        /* if (!this.productAssessment) {
             errorOccur = true; result = false;
             errorMessage = errorMessage + "Required Field: Product/Assessment is blank on Work Request.";
             //return result;
         }*/
        if (invalidMFSStatus) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in MFS Status column";
        if (invalidTCStatus) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in TC Status column";
        //if (invalidReportStatus) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in Report Status column";
        //if (invalidEmail) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in File Name column";
        if (invalidMFSSent) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in MFS Report Sent column";
        if (invalidTCSent) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in TC Report Sent column";
        if (invalidInsightsStatus) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in Insights Status column";
        if (invalidVADCStatus) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in VADC Status column";
        if (invalidDeadlineDate) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in Deadline Date column. Accepted date format is DD-MM-YYYY";

        this.errorMessage = errorMessage;
        console.log('this.errorMessage',errorMessage);
        return result;
    }

    //SSE-29741 Added validateDateFormat function to check Deadline format. Acceptable format 'DD-MM'YYYYY'
    validateDateFormat(row) {
        if(row["Deadline__c"] !== null && row["Deadline__c"] !== "" && row["Deadline__c"] !== 'undefined'){
            console.log('Date ',row["Deadline__c"]);
            let dateString = row["Deadline__c"];
            // Check if input is a string
            if (typeof dateString !== 'string') {
                return false;
            }

            // Regular expression to match d-m-yyyy or dd-mm-yyyy format
            // d/dd: 1-31 (1 or 2 digits), m/mm: 1-12 (1 or 2 digits), yyyy: 4 digits
            const dateFormatRegex = /^(\d{1,2})-(\d{1,2})-(\d{4})$/;
            
            // Test if the string matches the pattern
            const match = dateString.match(dateFormatRegex);
            console.log('Date ',match);
            if (!match) {
                return false;
            }

            // Extract day, month, and year
            const day = parseInt(match[1], 10);
            const month = parseInt(match[2], 10);
            const year = parseInt(match[3], 10);

            // Validate month range (1-12)
            if (month < 1 || month > 12) {
                return false;
            }

            // Validate day range based on month
            const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
            
            // Check for leap year
            const isLeapYear = (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
            if (isLeapYear) {
                daysInMonth[1] = 29; // February has 29 days in leap year
            }
            console.log('Date ',daysInMonth);
            // Validate day range for the given month
            if (day < 1 || day > daysInMonth[month - 1]) {
                return false;
            }
            return true;
        }else{
            return true;
        }
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

    handleUploadFinished(event) {
        // Get the list of uploaded files
        this.showFileName = false;
        //this.generatedWRFId='a3aPu000001EiVFIA0';
        //console.log('Record Id Child ' + this.recordId);
        //this.rowHeaderToImport = ['Id', 'Name', 'Participant__r.Full_Name__c', 'Participant__r.Email__c', 'Respondent__r.Full_Name__c', 'Respondent__r.Email__c', 'Rater_Type__c', 'VADC_Status__c', 'Insights_Status__c', 'MFS_Status__c', 'TC_Status__c', 'Overall_Status__c', 'Report_Sent__c', 'MFS_Report_Sent__c', 'TC_Report_Sent__c', 'Deadline__c', 'Comments__c', 'File_Name__c', 'Single_Use_Link__c', 'EmailType__c', 'Email_File_Name__c', 'Sharepoint_File_Path__c'];
        this.rowHeaderToImport = ['Id', 'Name', 'Participant__r.Work_Request__r.Name','Participant__r.Full_Name__c', 'Participant__r.Email__c', 'Respondent__r.Full_Name__c', 'Respondent__r.Email__c', 'Rater_Type__c', 'VADC_Status__c', 'Insights_Status__c', 'MFS_Status__c', 'TC_Status__c', 'Overall_Status__c', 'Rater_String__c', 'Reminder__c', 'Report_Ready__c', 'Report_Sent__c', 'MFS_Report_Sent__c', 'TC_Report_Sent__c', 'Deadline__c', 'Comments__c', 'File_Name__c', 'Single_Use_Link__c', 'EmailType__c', 'Email_File_Name__c', 'Sharepoint_File_Path__c'];
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

    ignoreMFSStatusDataCase(row) {
        let flag = false;
        if (row["MFS_Status__c"] !== null && row["MFS_Status__c"] !== "" && row["MFS_Status__c"] !== 'undefined') {
            let rowStatusKeyValue = row["MFS_Status__c"];
            let rowStatusKey = this.getMapKey(this.arrayOfMFSStatusValues, rowStatusKeyValue);
            if (rowStatusKey.length > 0) {
                row["MFS_Status__c"] = rowStatusKey[0];
            } else {
                flag = true;
            }
        }
        return flag;
    }

    ignoreTCStatusDataCase(row) {
        let flag = false;
        if (row["TC_Status__c"] !== null && row["TC_Status__c"] !== "" && row["TC_Status__c"] !== 'undefined') {
            let rowStatusKeyValue = row["TC_Status__c"];
            let rowStatusKey = this.getMapKey(this.arrayOfTCStatusValues, rowStatusKeyValue);
            if (rowStatusKey.length > 0) {
                row["TC_Status__c"] = rowStatusKey[0];
            } else {
                flag = true;
            }
        }
        return flag;
    }

    ignoreReportStatusDataCase(row) {
        let flag = false;
        if (row["Report_Ready__c"] !== null && row["Report_Ready__c"] !== "" && row["Report_Ready__c"] !== 'undefined') {
            let rowStatusKeyValue = row["Report_Ready__c"];
            let rowStatusKey = this.getMapKey(this.arrayOfReportStatusValues, rowStatusKeyValue);
            if (rowStatusKey.length > 0) {
                row["Report_Ready__c"] = rowStatusKey[0];
            } else {
                flag = true;
            }
        }
        return flag;
    }

    ignoreMFSSentCase(row) {
        let flag = false;
        if (row["MFS_Report_Sent__c"] !== null && row["MFS_Report_Sent__c"] !== "" && row["MFS_Report_Sent__c"] !== 'undefined') {
            let rowStatusKeyValue = row["MFS_Report_Sent__c"];
            let rowStatusKey = this.getMapKey(this.arrayOfMFSSentValues, rowStatusKeyValue);
            if (rowStatusKey.length > 0) {
                row["MFS_Report_Sent__c"] = rowStatusKey[0];
            } else {
                flag = true;
            }
        }
        return flag;
    }

    ignoreTCSentCase(row) {
        let flag = false;
        if (row["TC_Report_Sent__c"] !== null && row["TC_Report_Sent__c"] !== "" && row["TC_Report_Sent__c"] !== 'undefined') {
            let rowStatusKeyValue = row["TC_Report_Sent__c"];
            let rowStatusKey = this.getMapKey(this.arrayOfTCSentValues, rowStatusKeyValue);
            if (rowStatusKey.length > 0) {
                row["TC_Report_Sent__c"] = rowStatusKey[0];
            } else {
                flag = true;
            }
        }
        return flag;
    }
    ignoreInsightsCase(row) {
        let flag = false;
        if (row["Insights_Status__c"] !== null && row["Insights_Status__c"] !== "" && row["Insights_Status__c"] !== 'undefined') {
            let rowStatusKeyValue = row["Insights_Status__c"];
            let rowStatusKey = this.getMapKey(this.arrayOfInsightsStatusValues, rowStatusKeyValue);
            if (rowStatusKey.length > 0) {
                row["Insights_Status__c"] = rowStatusKey[0];
            } else {
                flag = true;
            }
        }
        return flag;
    }
    ignoreVADCCase(row) {
        let flag = false;
        if (row["VADC_Status__c"] !== null && row["VADC_Status__c"] !== "" && row["VADC_Status__c"] !== 'undefined') {
            let rowStatusKeyValue = row["VADC_Status__c"];
            let rowStatusKey = this.getMapKey(this.arrayOfVADCStatusValues, rowStatusKeyValue);
            if (rowStatusKey.length > 0) {
                row["VADC_Status__c"] = rowStatusKey[0];
            } else {
                flag = true;
            }
        }
        return flag;
    }





}