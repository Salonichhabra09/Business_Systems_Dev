import { LightningElement, track, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import createCandidates from '@salesforce/apex/CandidateUploadContoller.createCandidates';
import createRatings from '@salesforce/apex/CandidateUploadContoller.createRatings';
import uploadFile from '@salesforce/apex/CandidateUploadContoller.uploadFile';
import getCandidateCount from '@salesforce/apex/CandidateUploadContoller.getCandidateCount';
import getJobData from '@salesforce/apex/CandidateUploadContoller.getJobData';
import getJobStatus from '@salesforce/apex/CandidateUploadContoller.getJobStatus';
import getCandidateIdsRelateToJob from '@salesforce/apex/CandidateUploadContoller.getCandidateIdsRelateToJob';
import handleCandidateComponentVisibility from '@salesforce/apex/MsCandidateDataTableController.handleCandidateComponentVisibility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CATEGORY_FIELD from '@salesforce/schema/Bureau_Rating__c.Rater_Type__c';
import STATUS_FIELD from '@salesforce/schema/Bureau_Candidate__c.Status2__c';
import REPORT_STATUS_FIELD from '@salesforce/schema/Bureau_Candidate__c.Reports_Status__c';
import SYSTEM_USED_FOR_CANDIDATE from '@salesforce/label/c.System_Used_values_for_Candidates';
import SYSTEM_USED_FOR_SYSTEMS from '@salesforce/label/c.System_Used_values_for_Systems';

const arrayMap = { "Id": "Record ID", "First_Name__c": "First Name", "Last_Name__c": "Last Name", "Email__c": "Email Address", "Gender__c": "Gender", "Phone_Number__c": "Phone Number", "Country__c": "Country", "Language__c": "Language", "Status2__c": "Status", "Reports_Status__c": "Report Status", "Username_New__c": "Username", "Product_Assessment__c": "Product/Assessment", "System_s__c": "System(s)", "Email_as_Username__c": "Email as Username?" };
const arrayMap1 = { "Category__c": "Category", "First_Name__c": "First Name", "Last_Name__c": "Last Name", "Email__c": "Email Address", "Gender__c": "Gender", "Phone_Number__c": "Phone Number", "Country__c": "Country", "Language__c": "Language", "Status2__c": "Status", "Reports_Status__c": "Report Status", "Username__c": "Username", "Product_Assessment__c": "Product/Assessment", "System_s__c": "System(s)", "Bureau_Job__c": "Bureau Job", "Email_as_Username__c": "Email as Username?", "Candidate_Unique_Id__c": "uniqueId", "Job_Region__c": "jobRegion" };
const arrayMap2 = { "Id": "Record ID", "First_Name__c": "First Name", "Last_Name__c": "Last Name", "Email__c": "Email Address", "Gender__c": "Gender", "Phone_Number__c": "Phone Number", "Country__c": "Country", "Language__c": "Language", "Status2__c": "Status", "Reports_Status__c": "Report Status", "Username__c": "Username", "Product_Assessment__c": "Product/Assessment", "System_s__c": "System(s)", "Email_as_Username__c": "Email as Username?", "Candidate_Unique_Id__c": "uniqueId" };
const arrayMap3 = { "Category__c": "Category", "First_Name__c": "First Name", "Last_Name__c": "Last Name", "Email__c": "Email Address", "Gender__c": "Gender", "Phone_Number__c": "Phone Number", "Country__c": "Country", "Language__c": "Language", "Status2__c": "Status", "Reports_Status__c": "Report Status", "Username__c": "Username", "Product_Assessment__c": "Product/Assessment", "System_s__c": "System(s)", "Bureau_Job__c": "Bureau Job", "Recipient_Email__c": "Recipient Email" };
const arrayMap4 = { "Category": "Category", "First_Name": "First Name", "Last_Name": "Last Name", "Email": "Email Address", "Bureau_Job": "Bureau Job", "Recipient_Email": "Recipient Email" };
const attributesToRemove = { "First_Name__c": "First Name", "Last_Name__c": "Last Name", "Bureau_Job": "Bureau Job", "Gender__c": "Gender", "Phone_Number__c": "Phone Number", "Country__c": "Country", "Language__c": "Language", "Status2__c": "Status", "Reports_Status__c": "Report Status", "Username__c": "Username", "Product_Assessment__c": "Product/Assessment", "System_s__c": "System(s)", "Email_as_Username__c": "Email as Username?", "Job_Region__c": "jobRegion" };

export default class ProcessCSVFileAndSplit extends LightningElement {
    rowHeadings = ['Record ID', 'First Name', 'Last Name', 'Email Address', 'Gender', 'Phone Number', 'Country', 'Language', 'Status', 'Report Status', 'Username', 'Product/Assessment', 'System(s)', 'Email as Username?'];
    rowHeaderToImport = ['Category', 'First Name', 'Last Name', 'Email Address', 'Gender', 'Phone Number', 'Country', 'Language', 'Status', 'Report Status', 'Username', 'Product/Assessment', 'System(s)', 'Email as Username?'];
    importRowHeadings = ['Category__c', 'First_Name__c', 'Last_Name__c', 'Email__c', 'Gender__c', 'Phone_Number__c', 'Country__c', 'Language__c', 'Status2__c', 'Reports_Status__c', 'Username__c', 'Product_Assessment__c', 'System_s__c', 'Bureau_Job__c', 'Email_as_Username__c', 'Candidate_Unique_Id__c', 'Job_Region__c'];
    rowHeader = ['Category', 'First Name', 'Last Name', 'Email Address', 'Gender', 'Phone Number', 'Country', 'Language', 'Status', 'Report Status', 'Username', 'Product/Assessment', 'System(s)', 'Email as Username?'];
    rowHeaderMessageToDisplay = 'Category, First Name, Last Name, Email Address, Gender, Phone Number, Country, Language, Status, Report Status, Username, Product/Assessment, System(s), Email as Username?';
    rowHeaderUpdate = ['Record ID', 'First Name', 'Last Name', 'Email Address', 'Gender', 'Phone Number', 'Country', 'Language', 'Status', 'Report Status', 'Username', 'Product/Assessment', 'System(s)', 'Email as Username?'];
    rowHeaderUpdateMessageToDisplay = 'Record ID, First Name, Last Name, Email Address, Gender, Phone Number, Country, Language, Status, Report Status, Username, Product/Assessment, System(s), Email as Username?';
    importRowHeadingsUpdate = ['Id', 'First_Name__c', 'Last_Name__c', 'Email__c', 'Gender__c', 'Phone_Number__c', 'Country__c', 'Language__c', 'Status2__c', 'Reports_Status__c', 'Username__c', 'Product_Assessment__c', 'System_s__c', 'Email_as_Username__c', 'Candidate_Unique_Id__c'];

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
    @track _rows;
    @track _rowsRating;
    @api recordId;
    @track csvDatafromJSON;
    @track csvDatafromJSON1;
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
    @track updateCandidate = false;
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


    fileReader;
    fileContents;
    file;
    filesUploaded;
    fileUrl;

    systemDataList

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: STATUS_FIELD })
    wiredStatusValues({ error, data }) {
        if (data) {
            const fruits2 = new Map();
            for (let key in data.values) {
                if (data.values.hasOwnProperty(key)) {
                    let dataValue = data.values[key].value.toUpperCase();
                    fruits2.set(data.values[key].value, dataValue);
                }
            }
            this.arrayOfStatusValues = fruits2;
        } else if (error) {

        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: REPORT_STATUS_FIELD })
    wiredReportStatusValues({ error, data }) {
        if (data) {
            const fruits2 = new Map();
            for (let key in data.values) {
                if (data.values.hasOwnProperty(key)) {
                    let dataValue = data.values[key].value.toUpperCase();
                    fruits2.set(data.values[key].value, dataValue);
                }
            }
            this.arrayOfReportStatusValues = fruits2;
        } else if (error) {

        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: CATEGORY_FIELD })
    wiredCategoryValues({ error, data }) {
        if (data) {
            const fruits2 = new Map();
            for (let key in data.values) {
                if (data.values.hasOwnProperty(key)) {
                    let dataValue = data.values[key].value.toUpperCase();
                    fruits2.set(data.values[key].value, dataValue);
                }
            }
            this.arrayOfCategoryValues = fruits2;

        } else if (error) {

        }
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

    connectedCallback() { // IN USE
        getJobData({
            recordId: this.recordId
        })
            .then(data => {
                this.jobName = data[0].Name;
                this.job = data;
                let systemUsed = data[0].System_Used__c;
                let LOB = data[0].MS_Line_of_Business__c;
                this.jobLOB = LOB;
                let region = data[0].Job_Region__c;
                this.jobRegion = region;

                this.systemUsedValues = data[0].System_Used__c;
                if (systemUsed && LOB) {
                    if (systemUsed.includes('MFS') && LOB == 'Talent Management') {
                        this.isMFSSystem = true;
                    }
                }
            })
            .catch(error => {

            });
    }

    //This is the 1st fun get called when clicked on import candidate
    @api handleImportCandidate() { // IN USE
        this.updateCandidate = false;
        this.showErrorMessage = false;
        this.showImportCandidateScreen = true;
        this.showCandidateScreen = false;
        /*var contactForm = this.template.querySelector('div[data-id="myDiv"]');
        let className = (contactForm.classList.value).split(' ')[2];
        this.removeMessage('', '', className);*/
    }

    @api handleUpdateCandidate() {
        this.updateCandidate = true;
        this.showErrorMessage = false;
        this.showImportCandidateScreen = true;
        this.showCandidateScreen = false;
        this.getCandidateIdsRelateToJob();
    }

    /*getCandidateIdsRelateToJob(){
        getCandidateIdsRelateToJob({
            jobId : this.recordId
        })
        .then( data => {
            this.candidateIdsRelatedToJob = JSON.stringify(data);
        })
        .catch( error => {
        });
    }*/

    getCandidateIdsRelateToJob() {
        getCandidateIdsRelateToJob({
            candidateIds: this.candidateIdsRelatedToJob
        })
            .then(data => {
                //this.candidateIdsRelatedToJob = JSON.stringify(data);
            })
            .catch(error => {
            });
    }

    handleBack() { // IN USE
        this.showImportCandidateScreen = false;
        this.showCandidateScreen = true;
        this.disableInput = false;
        this.showErrorMessage = false;
        const successEvent = new CustomEvent("candidatehome", {
            detail: 'success'
        });
        this.dispatchEvent(successEvent);
    }

    handleCandidateComponentVisibility() {
        handleCandidateComponentVisibility({ jobId: this.recordId })
            .then(result => {
                this.systemDataList = result;
                if (this.systemDataList != undefined &&
                    this.systemDataList.length > 0) {
                    systemUsedAvailable = true;
                }
                else {
                    alert('Please select system first.');
                }
            })
            .catch(error => {
                console.log('error ====> ', error);
            });
    }

    // Get file from user using lightning-input
    //This function get called when user uploads the file (2nd fun)
    handleInputChange(event) { // IN USE
        let file
        if (event.target.files.length > 0) {
            //get first file
            file = event.target.files[0];
        }

        if (this.systemUsedValues != null) {
            let updatedSysUsed = this.systemUsedValues.split(';')
            for (let i = 0; i < updatedSysUsed.length; i++) {
                console.log('updatedSysUsed ##' + updatedSysUsed[i]);
                if (SYSTEM_USED_FOR_SYSTEMS.includes(updatedSysUsed[i])) {
                    handleCandidateComponentVisibility({ jobId: this.recordId })
                        .then(result => {
                            this.systemDataList = result;
                            console.log('this.systemDataList ###' + this.systemDataList)
                            if (this.systemDataList != undefined && this.systemDataList.length > 0) {
                                if (SYSTEM_USED_FOR_CANDIDATE.includes(updatedSysUsed[i])) {
                                    this.showLoadingSpinner = true;
                                    this.showErrorMessage = false;
                                    if (this.updateCandidate) {
                                        this.callPapaParserToGetRecordsInCSVFileForUpdateCandidate(file);
                                    }
                                    else {
                                        this.callPapaParserToGetRecordsInCSVFile(file);
                                    }
                                }
                            }
                            else {
                                this.displayMessage('ERROR', 'Please Select system in "System Used" tab', 'slds-theme_error');
                            }
                        })
                        .catch(error => {
                            console.log('error ====> ', error);
                        });
                    console.log('If Called')
                    break;
                }
                else {
                    console.log('SYSTEM_USED_FOR_CANDIDATE check')
                    if (SYSTEM_USED_FOR_CANDIDATE.includes(updatedSysUsed[i])) {
                        this.showLoadingSpinner = true;
                        this.showErrorMessage = false;
                        if (this.updateCandidate) {
                            this.callPapaParserToGetRecordsInCSVFileForUpdateCandidate(file);
                        }
                        else {
                            this.callPapaParserToGetRecordsInCSVFile(file);
                        }
                    }
                    break;
                }

            }
        }


    }

    getMapKey(mapArray, value) {
        return [...mapArray.entries()].filter(({ 1: v }) => v === value).map(([k]) => k);

    }

    ignoreStatusDataCase(row) {
        let flag = false;
        if (row["Status"] !== null && row["Status"] !== "" && row["Status"] !== 'undefined') {
            let rowStatusKeyValue = row["Status"].toUpperCase();
            let rowStatusKey = this.getMapKey(this.arrayOfStatusValues, rowStatusKeyValue);
            if (rowStatusKey.length > 0) {
                row["Status"] = rowStatusKey[0];
            } else {
                flag = true;
            }
        }
        return flag;
    }
    ignoreCategoryDataCase(row) {
        let flag = false;
        if (row["Category"]) {
            let rowCategoryKeyValue = row["Category"].toUpperCase();
            let rowCategoryKey = this.getMapKey(this.arrayOfCategoryValues, rowCategoryKeyValue);
            if (rowCategoryKey.length > 0) {
                row["Category"] = rowCategoryKey[0];
            } else {
                flag = true;
            }
        }
        return flag;
    }
    ignoreReportStatusDataCase(row) {
        let flag = false;
        if (row["Report Status"] !== null && row["Report Status"] !== "" && row["Report Status"] !== 'undefined') {
            let rowReportStatusKeyValue = row["Report Status"].toUpperCase();
            let rowReportStatusKey = this.getMapKey(this.arrayOfReportStatusValues, rowReportStatusKeyValue);
            if (rowReportStatusKey.length > 0) {
                row["Report Status"] = rowReportStatusKey[0];
            } else {
                flag = true;
            }
        }
        return flag;

    }
    uniqueByKeepSelf(a) {
        const arraMap = new Map();
        a.forEach(ele => {
            if (arraMap.has(ele.uniqueId)) {
                if (ele.Category == 'Self' && arraMap.get(ele.uniqueId).Category != 'Self') {
                    //Remove previous value
                    arraMap.delete(ele.uniqueId);
                    arraMap.set(ele.uniqueId, ele);
                }
            } else {
                arraMap.set(ele.uniqueId, ele);
            }
        });
        return arraMap.values();
    }

    // Call papa parser to check record count in file
    //This is the 3rd fun get called when user uploads the file using import candidate button
    callPapaParserToGetRecordsInCSVFile(file) { // IN USE
        //If file selected
        if (file.name != '') {
            //get first file
            let fileName = file.name;
            //check if filename includes .csv
            let result = fileName?.includes(".csv");
            //If file is not csv
            if (result == false) {
                this.showErrorMessage = true;
                this.errorMessage = 'Please select a CSV file to import';
                this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                this.showLoadingSpinner = false;
            }
            //If file is csv
            else {
                var completeProcessing = (results, file) => {
                    this._rows = JSON.parse(JSON.stringify(results.data));
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
                        this.showLoadingSpinner = false;
                        this.disableInput = false;
                        this.showErrorMessage = true;
                        this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                    }
                    //If no error
                    else {
                        var candidatesList = [];
                        var recipientEmail;
                        const candidateMap = new Map();

                        /* Logic to add Bureau Job */
                        this._rows.forEach(row => {
                            row["Bureau Job"] = this.recordId;
                            if (!this.updateCandidate) {
                                /* START Mark Status default as Not Started and Report Status as Unsent */
                                row["Status"] = row["Status"] ? row["Status"] : 'Not Started';
                                row["Report Status"] = row["Report Status"] ? row["Report Status"] : 'Unsent';
                                /* END */
                                row["jobRegion"] = this.jobRegion;
                            }
                            /* START Logic to generate Candidate Unique Id */
                            let lastString = row["Username"] ? row["Username"] : row["Email Address"];
                            row["uniqueId"] = this.recordId + row["First Name"] + row["Last Name"] + row["Email Address"] + lastString;
                            /* END Logic to generate Candidate Unique Id */
                            row["Email as Username?"] = row["Email as Username?"] && row["Email as Username?"].toUpperCase() == 'TRUE' ? true : false; // Added by Naved

                            if ((row["Category"] === "" || row["Category"] === null || row["Category"] === undefined) && this.jobLOB !== this.talentManagementLOB) {
                                row["Category"] = 'Self';
                            }
                            candidatesList.push(row);
                        });
                        candidatesList = [];
                        if (!this.updateCandidate) {
                            /* START Logic to remove Duplicates */
                            const uniqueObjects = this.uniqueByKeepSelf(this._rows);

                            this._rows = [...uniqueObjects];
                            this._rows.forEach(row => {
                                //delete row["uniqueId"];
                                candidatesList.push(row);
                            });
                            /* END Logic to remove Duplicates */
                        }
                        this.jobCandidateData = [...candidatesList];
                        // Added below line to fix duplicate issue
                        this.csvDatafromJSON1 = this.unparseJSON(this.jobCandidateData);

                        /* Logic to replace Column Labels with API Name */

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
                                let rowKey = this.getKeyByValue(arrayMap1, rowKeyValue);
                                headerAPIName.set(rowKey, rowKeyValue);
                            }
                        }

                        //below block replace header label with API Names
                        let jsonString = JSON.stringify(this.jobCandidateData);
                        for (let key of headerAPIName.keys()) {
                            let mapValue = headerAPIName.get(key);
                            let keyStr = "\"" + key + "\":";
                            let valueStr = "\"" + mapValue + "\":";
                            jsonString = jsonString.replaceAll(valueStr, keyStr);
                        }
                        this.jobCandidateData = JSON.parse(jsonString);
                        const size1 = new TextEncoder().encode(jsonString).length;
                        const kiloBytes1 = size1 / 1024;
                        const megaBytes1 = kiloBytes1 / 1024;


                        /////////////////////////////////////////////////////////////////////////////////////////////////////
                        //Below logic is written to create full JSON
                        // Here we are not removing duplicate Candidate records because we need all the candidates to create ratings.
                        var fullList = [];
                        var recipientEmail;
                        this._rows = JSON.parse(JSON.stringify(results.data));
                        this._rows.forEach(row => {
                            row["Bureau Job"] = this.recordId;
                            let is360Product;
                            if (row["Category"] == 'Self') {
                                if (row["Product/Assessment"]) {
                                    let products = row["Product/Assessment"].toUpperCase();
                                    is360Product = (products?.includes('SHL 360')) ? true : (products?.includes('NOMINATION') ? true : ((products?.includes('ENGAGEMENT') ? true : false)));

                                    if (is360Product == true) {
                                        recipientEmail = row["Email Address"];
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

                            /* END Logic to add Recipient Email Address */
                            /* START Mark Status default as Not Started and Report Status as Unsent */
                            row["Status"] = row["Status"] ? row["Status"] : 'Not Started';
                            row["Report Status"] = row["Report Status"] ? row["Report Status"] : 'Unsent';
                            /* END */
                            row["jobRegion"] = this.jobRegion;
                            row["Email as Username?"] = row["Email as Username?"] && row["Email as Username?"].toUpperCase() == 'TRUE' ? true : false; // Added by Naved
                            fullList.push(row);
                        });
                        this.fullJSON = [...fullList];


                        // New Change Aashi
                        this.csvDatafromJSON = this.unparseJSON(this.fullJSON);

                        /////////////////////////////////////////////////////////////////////////////////////////////////////
                        //Below logic is written for ratings
                        if (this.isMFSSystem) {
                            var ratingList = [];
                            let rowDataSet = new Set();
                            Object.getOwnPropertyNames(attributesToRemove).forEach(function (val) {
                                rowDataSet.add(attributesToRemove[val]);
                            });
                            this._rows.forEach(row => {
                                //Remove not required fields
                                rowDataSet.forEach(var1 => {
                                    delete row[var1];
                                });
                                if (!(row["Recipient Email"] == undefined || row["Recipient Email"] == null || row["Recipient Email"] == "")) {

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
                        }
                        /////////////////////////////////////////////////////////////////////////////////////////////////////
                        this.evalutateCriteria(file);
                    }
                }
                var errorProcessing = (error) => {
                    this.loading = false;
                };
                Papa.parse(file, {
                    skipEmptyLines: true,
                    encoding: "utf-8",
                    quoteChar: '"',
                    header: true,
                    complete: completeProcessing,
                    error: errorProcessing
                })
            }
        }
        //If file not selected
        else {
            this.showErrorMessage = true;
            this.errorMessage = 'Please select a file to import';
            this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
            this.showLoadingSpinner = false;
        }
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

    evalutateCriteria(file) { // IN USE
        var fileName;
        this.recordCount = this.jobCandidateData.length;
        if (this.jobCandidateData.length <= 1000) {
            fileName = file.name; //this.jobName + '_CandidateFileUpload';
            // Attach file  Job record
            this.convertJSONToBase64(fileName);
        }
        else {
            if (this.updateCandidate) {
                fileName = this.jobName + '_CandidateUpdateSheet.csv';
            } else {
                fileName = this.jobName + '_CandidateImportSheet.csv';
            }
            // Insert using Bulk API
            this.insertCandidates10KOrMoreThan10K(fileName, file);
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

    insertRating(fileName) {
        createRatings({
            ratingJSON: JSON.stringify(this.jobRatingData),
            bureauJobId: this.recordId,
            isUpdate: this.updateCandidate
        })
            .then(data => {
                let title = fileName + ' uploaded successfully!!';
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                this.errorMessage = title;
                this.displayMessage('SUCCESS', this.errorMessage, 'slds-theme_success');
            })
            .catch(error => {
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                this.errorMessage = error.body.message;
                this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
            });
    }

    insertCandidateLessThan10K(fileName) { // IN USE
        createCandidates({
            candidatesJSON: JSON.stringify(this.jobCandidateData),
            bureauJobId: this.recordId,
            isUpdate: this.updateCandidate
        })
            .then(data => {
                if (this.isMFSSystem && !this.updateCandidate) {
                    this.insertRating(fileName);
                } else {
                    this.disableInput = false;
                    let title = fileName + ' uploaded successfully!!';
                    this.showLoadingSpinner = false;
                    this.showErrorMessage = true;
                    this.errorMessage = title;
                    this.displayMessage('SUCCESS', this.errorMessage, 'slds-theme_success');
                }
            })
            .catch(error => {
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                var errorStr = error.body.message;
                this.errorMessage = error.body.message;
                this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');


            });
    }

    insertCandidates10KOrMoreThan10K(fileName, file) { // IN USE
        this.callPapaParserToDivideFileInChunks(fileName, file);
    }

    //This function helps to find value based on key
    getKeyByValue(object, value) {
        return Object.keys(object).find(key => object[key] === value);
    }

    // Call Papa parser to divide file into chunks
    callPapaParserToDivideFileInChunks(fileName, file) { // IN USE
        var chunkProcessing = (results, parser) => {
            this._rows = JSON.parse(JSON.stringify(results.data));
            var candidatesList = [];
            const candidateMap = new Map();
            this._rows.forEach(row => {

                if (row["First Name"] !== null && row["First Name"] !== "" && row["First Name"] !== 'undefined') {
                    if (!this.updateCandidate) {
                        //delete row["Recipient Email"];// Commented to fix Duplicate Issue
                        row["Bureau Job"] = this.recordId;
                        row["jobRegion"] = this.jobRegion;
                        if (!this.updateCandidate) {

                        }
                    }
                    /* START Logic to generate Candidate Unique Id */
                    let lastString = row["Username"] ? row["Username"] : row["Email Address"];
                    row["uniqueId"] = this.recordId + row["First Name"] + row["Last Name"] + row["Email Address"] + lastString;
                    /* END Logic to generate Candidate Unique Id */
                    candidatesList.push(row);
                }
            });

            if (!this.updateCandidate) {
                //candidatesList = []; // Commented to fix Duplicate Issue
                /* START Logic to remove Duplicates */
                // Commented to fix Duplicate
                /*const uniqueObjects = this.uniqueByKeepSelf(this._rows);
                this._rows = [...uniqueObjects];
                this._rows.forEach(row => {
                    candidatesList.push(row);
                });
                /* END Logic to remove Duplicates */
            }

            this.jobCandidateData = [...candidatesList];


            /////////////////////////////////////////////////////////////////////////////////////////////////////
            if (this.isMFSSystem && (!this.updateCandidate)) {
                this._rowsRating = JSON.parse(JSON.stringify(results.data));
                var ratingList = [];
                let rowDataSet = new Set();
                Object.getOwnPropertyNames(attributesToRemove).forEach(function (val) {
                    rowDataSet.add(attributesToRemove[val]);
                });

                this._rowsRating.forEach(row => {
                    rowDataSet.forEach(var1 => {
                        delete row[var1];
                    });
                    if (!(row["Recipient Email"] == undefined || row["Recipient Email"] == null || row["Recipient Email"] == "")) {
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
            }

            /////////////////////////////////////////////////////////////////////////////////////////////////////

            this.stopProcessing = true;
            if (this.stopProcessing) {
                parser.pause();
            }
            this.convertJSONToBase64(fileName, parser);
        };

        var completeProcessing = (results, file) => {


            this.disableInput = true;
            if (!this.isMFSSystem || this.updateCandidate) {
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                this.errorMessage = 'This job has more than 1000 candidates and can not be imported Immediately. A background process has been started and you will be notified by an email once import is completed.';
                this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');
            }

            getJobStatus({ jobId: this.recordId })
                .then(result => {
                    if (this.isMFSSystem && (!this.updateCandidate)) {
                        this.createFilesForRating(fileName, file);
                    }
                })
                .catch(error => {

                });
        };

        var errorProcessing = (error) => {
            this.loading = false;
        };
        // replaced file with this.csvDatafromJSON
        // Replaced csvDatafromJSON1 with csvDatafromJSON to fix Duplicate Issue
        Papa.parse(this.csvDatafromJSON1, {
            quoteChar: '"',
            header: 'true',
            chunkSize: 1024 * 1024 * 1.5,
            chunk: chunkProcessing,
            complete: completeProcessing,
            error: errorProcessing
        })
    }

    convertJSONToBase64(fileName, parser) { // IN USE
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        if (this.recordCount <= 1000) {
            this.jobCandidateData.forEach(function (record) {
                Object.keys(record).forEach(function (key) {
                    rowData.add(key);
                });
            });
            rowData = Array.from(rowData);

        } else {
            if (this.updateCandidate) {
                rowData = this.importRowHeadingsUpdate;
            } else {
                rowData = this.importRowHeadings;
            }
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
                            //rowKey = arrayMap2[rowKeyValue];
                            rowKey = rowKeyValue;
                        } else {
                            rowKey = arrayMap1[rowKeyValue];
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

        uploadFile({
            base64: csvString,
            filename: fileName,
            recordId: this.recordId
        })
            .then(result => {
                this.contentDocumentId = result;
                if (this.recordCount <= 1000) {
                    this.insertCandidateLessThan10K(fileName);
                }
                if (this.stopProcessing) {
                    this.stopProcessing = false;
                    parser.resume();
                }
            })
            .catch(error => {
                console.log('error: ', error);
                this.showLoadingSpinner = false;
                this.showErrorMessage = true;
                this.errorMessage = error.body.message + '. A Server Error Occurred Please Contact the System Administrator';
                this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                return false;
            });
        return false;
    }

    @api handleExportCandidate() { // IN USE
        this.updateCandidate = false;
        this.showErrorMessage = false;
        getCandidateCount({
            jobId: this.recordId,
            offSetValue: this.offSetValue
        })
            .then(result => {
                if (result.candidateCount == 0) {
                    this.showErrorMessage = true;
                    this.errorMessage = result.message;
                    this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                } else if (result.candidateCount < 40000) {
                    this.jobCandidateData = result.candidateData;
                    var tempData = [];
                    tempData = this.jobCandidateData;
                    this.jobName = JSON.stringify(tempData[0].Bureau_Job__r?.Name);
                    this.handleExportCandidateJS();
                } else {
                    this.showErrorMessage = true;
                    this.errorMessage = result.message;
                    this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');

                    ///////////////
                }
                const exportEvent = new CustomEvent("candidateexportaction", {
                    detail: 'success'
                });
                this.dispatchEvent(exportEvent);
            })
            .catch(error => {

                const exportEvent = new CustomEvent("candidateexportaction", {
                    detail: 'error'
                });
                this.dispatchEvent(exportEvent);
            });
    }

    // Export candidate data in CSV
    handleExportCandidateJS() { // IN USE
        let rowEnd = '\n';
        let csvString = '';

        let rowData = new Set();
        rowData = this.rowHeadings;
        csvString += rowData.join(',');
        csvString += rowEnd;
        for (let i = 0; i < this.jobCandidateData.length; i++) {
            let colValue = 0;
            for (let key in rowData) {
                if (rowData.hasOwnProperty(key)) {
                    let rowKeyValue = rowData[key];

                    let rowKey = Object.keys(arrayMap).find(key => arrayMap[key] === rowKeyValue);
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
        var universalBOM = "\uFEFF";
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(universalBOM + csvString);
        //encodeURI(csvString);
        downloadElement.target = '_self';
        downloadElement.download = this.jobName + '_CandidatesUploadSheet.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    handleFileFormatExport() {
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        rowData = this.rowHeaderToImport;
        csvString += rowData.join(',');
        csvString += rowEnd;
        var universalBOM = "\uFEFF";
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(universalBOM + csvString);
        //encodeURI(csvString);
        downloadElement.target = '_self';
        downloadElement.download = 'CandidateUpload_' + this.jobName + '.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    //This is 4th fun get called from import candidate button
    validateColumns(errorMessage) {
        var result = true;
        let rowDataHeader = new Set();
        this._rows.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowDataHeader.add(key);
            });
        });

        //row header from file
        rowDataHeader = Array.from(rowDataHeader);
        let rowHeaderList = [];
        if (rowDataHeader.length != this.rowHeader.length || JSON.stringify(rowDataHeader) != JSON.stringify(this.rowHeader)) {
            result = false;
            errorMessage = errorMessage + 'The import CSV file has invalid first line. Please ensure that the first line has the following values and order: ' + this.rowHeaderMessageToDisplay;
            this.errorMessage = errorMessage;
            return result;
        }
        const rowHeaderToMatch = this.rowHeader;
        return result;
    }

    //this is 5th fun get called when clicked on impot candidate, and if headers are correct
    validateData(errorMessage) {
        var result = true;
        let firstName = false;
        let lastName = false;
        let emailAddress = false;
        let category = false;
        let firstCategoryRow = false;
        let invalidStatus = false;
        let invalidCategory = false;
        let invalidReportStatus = false;
        let selfCategory = false;
        let lineNo;
        let username = false;
        let invalidEmail = false;

        this._rows.every((row, index) => {
            lineNo = index + 2;
            if (row["First Name"] == null || row["First Name"] == "") {
                firstName = true; result = false;
                return result;
            }
            if (row["Email Address"] == null || row["Email Address"] == "") {
                emailAddress = true; result = false;
                return result;
            }
            if (row["Email Address"]) {
                let emailValue = row["Email Address"];
                const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                if (!emailValue.match(emailRegex)) {
                    invalidEmail = true; result = false;
                    return result;
                }
            }
            if (this.jobLOB == this.talentManagementLOB && (row["Category"] == null || row["Category"] == "")) {
                let is360Product = false;
                if (row["Product/Assessment"]) {
                    let products = row["Product/Assessment"].toUpperCase();
                    is360Product = (products?.includes('SHL 360')) ? true : (products?.includes('NOMINATION') ? true : ((products?.includes('ENGAGEMENT') ? true : false)));
                    if (is360Product == true) {
                        selfCategory = true; result = false;
                    }
                }
                return result;
            }
            if (this.ignoreStatusDataCase(row)) {
                invalidStatus = true; result = false;
                return result;
            }
            if (this.ignoreReportStatusDataCase(row)) {
                invalidReportStatus = true; result = false;
                return result;
            }
            if (this.jobLOB == this.talentManagementLOB && this.ignoreCategoryDataCase(row)) {
                invalidCategory = true; result = false;
                return result;
            }
            if ((this.jobLOB == this.talentVocationalBatchLOB || this.jobLOB == this.talentVocationalSchoolLOB ||
                this.jobLOB == this.talentCorporateLOB || this.jobLOB == this.talentCredentialingLOB) &&
                (row["Username"] == null || row["Username"] == "")) {
                username = true; result = false;
                return result;
            }
            return true;
        });

        if (firstName) errorMessage = errorMessage + "Line " + lineNo + ": Required Field: First Name is blank.";
        if (emailAddress) errorMessage = errorMessage + "Line " + lineNo + ": Required Field: Email Address is blank.";
        if (invalidEmail) errorMessage = errorMessage + "Line " + lineNo + ": Invalid Email Address";
        if (invalidStatus) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in Status column";
        if (invalidReportStatus) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in Report Status column";
        if (invalidCategory) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in Category column";
        if (selfCategory) errorMessage = errorMessage + "Line " + lineNo + ": Category should be Self for MFS";
        if (username) errorMessage = errorMessage + "Line " + lineNo + ": Username is blank";
        this.errorMessage = errorMessage;
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

    validateColumnsForUpdateCandidates(errorMessage) {
        var result = true;
        let rowDataHeader = new Set();
        this._rows.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowDataHeader.add(key);
            });
        });
        rowDataHeader = Array.from(rowDataHeader);
        let rowHeaderList = [];
        if (rowDataHeader.length != this.rowHeaderUpdate.length || JSON.stringify(rowDataHeader) != JSON.stringify(this.rowHeaderUpdate)) {
            result = false;
            errorMessage = errorMessage + 'The import CSV file has invalid first line. Please ensure that the first line has the following values and order: ' + this.rowHeaderUpdateMessageToDisplay;
            this.errorMessage = errorMessage;
            return result;
        }

        return result;
    }

    async validateDataForUpdateCandidates(errorMessage) {
        var result = true;
        let candidateRecordId = false;
        let candidateIdList = [];
        let firstName = false;
        let emailAddress = false;
        let invalidStatus = false;
        let invalidReportStatus = false;
        let lineNo;
        let username = false;
        let invalidEmail = false;

        this._rows.forEach(row => {
            candidateIdList.push(row["Record ID"]);

        });

        const first10Ids = candidateIdList.slice(0, 10);
        console.log('first10Ids: ', JSON.stringify(first10Ids));
        const last10Ids = candidateIdList.slice(-10);
        console.log('last10Ids: ', JSON.stringify(last10Ids));

        const finalIdsList = first10Ids.concat(last10Ids);
        this.candidateIdsRelatedToJob = [...finalIdsList];
        console.log('finalIdsList: ', JSON.stringify(finalIdsList));

        console.log('candidateIdsRelatedToJob -> ' + JSON.stringify(this.candidateIdsRelatedToJob));
        console.log('result: ', result);
        result = await getCandidateIdsRelateToJob({ candidateIds: finalIdsList, jobId: this.recordId });
        console.log('result: ', result);

        if (!result) {
            errorMessage = errorMessage + "Candidate Record does not belongs to this Job.";
            this.errorMessage = errorMessage;
            return result;
        }
        /*for(let aa of candidateIdList){
            result = (this.candidateIdsRelatedToJob)?.includes(aa);
            if(!result){
                console.log('aa ' + aa);
                errorMessage = errorMessage + "Candidate Record does not belongs to this Job."; 
                this.errorMessage = errorMessage;
                return result;
            }
        }*/

        for (let aa of candidateIdList) {
            result = (this.candidateIdsRelatedToJob)?.includes(aa);
            if (!result) {
                errorMessage = errorMessage + "Candidate Record does not belongs to this Job.";
                this.errorMessage = errorMessage;
                return result;
            }
        }

        this._rows.every((row, index) => {
            lineNo = index + 2;
            if (row["Record ID"] == null || row["Record ID"] == "") {
                candidateRecordId = true; result = false;
                return result;
            }
            if (row["First Name"] == null || row["First Name"] == "") {
                firstName = true; result = false;
                return result;
            }
            if (row["Email Address"] == null || row["Email Address"] == "") {
                emailAddress = true; result = false;
                return result;
            }
            if (row["Email Address"]) {
                let emailValue = row["Email Address"];
                const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                if (!emailValue.match(emailRegex)) {
                    invalidEmail = true; result = false;
                    return result;
                }
            }
            if (this.ignoreStatusDataCase(row)) {
                invalidStatus = true; result = false;
                return result;
            }
            if (this.ignoreReportStatusDataCase(row)) {
                invalidReportStatus = true; result = false;
                return result;
            }
            if ((this.jobLOB == this.talentVocationalBatchLOB || this.jobLOB == this.talentVocationalSchoolLOB ||
                this.jobLOB == this.talentCorporateLOB || this.jobLOB == this.talentCredentialingLOB) &&
                (row["Username"] == null || row["Username"] == "")) {
                username = true; result = false;
                return result;
            }
            return true;
        });

        if (candidateRecordId) errorMessage = errorMessage + "Line " + lineNo + "Record ID is blank.";
        if (firstName) errorMessage = errorMessage + "Line " + lineNo + ": Required Field: First Name is blank.";
        if (emailAddress) errorMessage = errorMessage + "Line " + lineNo + ": Required Field: Email Address is blank.";
        if (invalidEmail) errorMessage = errorMessage + "Line " + lineNo + ": Invalid Email Address";
        if (invalidStatus) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in Status column";
        if (invalidReportStatus) errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in Report Status column";
        if (username) errorMessage = errorMessage + "Line " + lineNo + ": Username is blank";
        this.errorMessage = errorMessage;
        return result;
    }

    callPapaParserToGetRecordsInCSVFileForUpdateCandidate(file) { // IN USE
        if (file.name != null) {
            let fileName = file.name;
            let result = fileName?.includes(".csv");
            if (result == false) {
                this.showErrorMessage = true;
                this.errorMessage = 'Please select a CSV file to import';
                this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                this.showLoadingSpinner = false;
            } else {
                var completeProcessing = (results, file) => {
                    this._rows = results.data;
                    let result = true;
                    let errorMessage = '';
                    this._rows.pop();

                    var validateFileHeadersFlag = this.validateColumnsForUpdateCandidates(errorMessage);
                    if (validateFileHeadersFlag) {
                        var validateDataFlag = this.validateDataForUpdateCandidates(errorMessage);
                        result = validateDataFlag;
                    } else {
                        result = validateFileHeadersFlag;
                    }

                    if (!result) {
                        this.showErrorMessage = true;
                        this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                        this.showLoadingSpinner = false;
                    } else {
                        var candidatesList = [];

                        /* Logic to add Bureau Job */
                        this._rows.forEach(row => {
                            row["Email as Username?"] = row["Email as Username?"] && row["Email as Username?"].toUpperCase() == 'TRUE' ? true : false; // Added by Naved
                            /* START Logic to generate Candidate Unique Id */
                            let lastString = row["Username"] ? row["Username"] : row["Email Address"];
                            row["uniqueId"] = this.recordId + row["First Name"] + row["Last Name"] + row["Email Address"] + lastString;
                            /* END Logic to generate Candidate Unique Id */
                            candidatesList.push(row);
                        });
                        this.jobCandidateData = [...candidatesList];

                        /* Logic to replace Column Labels with API Name */
                        let rowData = new Set();
                        this.jobCandidateData.forEach(function (record) {
                            Object.keys(record).forEach(function (key) {
                                rowData.add(key);
                            });
                        });
                        rowData = Array.from(rowData);
                        const fruits = new Map();
                        for (let key in rowData) {
                            if (rowData.hasOwnProperty(key)) {
                                let rowKeyValue = rowData[key];
                                let rowKey = this.getKeyByValue(arrayMap2, rowKeyValue);
                                fruits.set(rowKey, rowKeyValue);
                            }
                        }

                        let jsonString = JSON.stringify(this.jobCandidateData);
                        for (let key of fruits.keys()) {
                            let mapValue = fruits.get(key);
                            let keyStr = "\"" + key + "\":";
                            let valueStr = "\"" + mapValue + "\":";
                            jsonString = jsonString.replaceAll(valueStr, keyStr);
                        }
                        this.jobCandidateData = JSON.parse(jsonString);
                        /////////////////////////////////////////////////////////////////////////////////////////////////////
                        // Replaced csvDatafromJSON to csvDatafromJSON1 to fix Duplicate Issue
                        this.csvDatafromJSON1 = this.unparseJSON(this.jobCandidateData);
                        // New Change Aashi
                        //this.csvDatafromJSON = this.unparseJSON(this.jobCandidateData); // Commented to fix Duplicate Issue
                        /////////////////////////////////////////////////////////////////////////////////////////////////////
                        this.evalutateCriteria(file);
                    }
                }
                var errorProcessing = (error) => {
                    this.loading = false;
                };
                Papa.parse(file, {
                    skipEmptyLines: true,
                    encoding: "utf-8",
                    quoteChar: '"',
                    header: 'true',
                    complete: completeProcessing,
                    error: errorProcessing
                })
            }
        } else {
            this.showErrorMessage = true;
            this.errorMessage = 'Please select a file to import';
            this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
            this.showLoadingSpinner = false;
        }
    }

    createFilesForRating(fileName, file) {
        var chunkProcessing = (results, parser) => {
            this._rows = JSON.parse(JSON.stringify(results.data));

            /////////////////////////////////////////////////////////////////////////////////////////////////////
            if (this.isMFSSystem) {
                this._rowsRating = JSON.parse(JSON.stringify(results.data));
                var ratingList = [];
                let rowDataSet = new Set();
                Object.getOwnPropertyNames(attributesToRemove).forEach(function (val) {
                    rowDataSet.add(attributesToRemove[val]);
                });

                this._rowsRating.forEach(row => {
                    rowDataSet.forEach(var1 => {
                        delete row[var1];
                    });
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
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////////

            this.stopProcessing = true;
            if (this.stopProcessing) {

                parser.pause();
            }
            this.convertJSONToBase64Rating(fileName, parser);
        };

        var completeProcessing = (results, file) => {
            this.showLoadingSpinner = false;
            this.showErrorMessage = true;
            this.disableInput = true;
            this.errorMessage = 'This job has more than 1000 candidates and can not be imported Immediately. A background process has been started and you will be notified by an email once import is completed.';
            this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');


        };

        var errorProcessing = (error) => {

            this.loading = false;
        };
        // replaced file with this.csvDatafromJSON
        Papa.parse(this.csvDatafromJSON, {
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
        if (this.isMFSSystem) {
            csvString2 += this.unparseJSON(this.jobRatingData);
        }

        uploadFile({
            base64: csvString2,
            filename: fileName,
            recordId: this.recordId
        })
            .then(result => {

                this.contentDocumentId = result;
                if (this.stopProcessing) {
                    this.stopProcessing = false;

                    parser.resume();
                }
            })
            .catch(error => {

                return false;
            });
        return false;
    }
}