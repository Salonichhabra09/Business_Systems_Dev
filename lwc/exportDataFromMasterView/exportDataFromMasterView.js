import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';
import { loadScript } from 'lightning/platformResourceLoader';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import NAME from '@salesforce/schema/Job__c.Name';
import CANDIDATES_UPLOADED from '@salesforce/schema/Job__c.Candidate_Max_Sequence_No_New__c';
import getQueryStatus from '@salesforce/apex/CustomerRequestController.getQueryStatus';
import getQueryData from '@salesforce/apex/CustomerRequestController.getQueryData';
import getMoreQueryData from '@salesforce/apex/CustomerRequestController.getMoreQueryData';
import getGeneratedWrf from '@salesforce/apex/MasterProgressReportView.getWRF';
import getCandidateCount from '@salesforce/apex/CustomerRequestController.getCandidateCount';
import getRatingsCount from '@salesforce/apex/CustomerRequestController.getRatingsCount';
import CANDIDATE_FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Candidate_Field_Configuration__c';
import getRatingData from '@salesforce/apex/CandidateRatingManager.getRatingDataWrf';
import createQueryJobToGetCandidateDataForMasterView from '@salesforce/apex/CustomerRequestController.createQueryJobToGetCandidateDataForMasterView';

export default class ExportDataFromMasterView extends LightningElement {
    @api recordId;
    parserInitialized = false;
    showLoadingSpinner = false;
    totalCandidatesOnJob;
    candidateData;
    csv = '';
    locator;
    apiListVar;
    generatedWRFId;
    error;
    jobName;
    dataToExport;
    candidateJSON;
    formattingRequired = false;
    masterViewFlag = false;
    mergeDataForMasterViewFlag = false;
    ratingDataToMerge;
    ratingQueryJobIdForMasterView;
    @api exportType;
    resetCall = false;
    showErrorMessage = false;

    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => {
                    this.parserInitialized = true;
                })
                .catch(error => console.error(error));
        }
    }

    connectedCallback() {
        if (this.apiListVar) {
            this.checkExportType();
        }
    }

    checkExportType() {
        //console.log('this.exportType: ', this.exportType);
        if (this.exportType == 'master') {
            this.handleMasterView();
        } else if (this.exportType == 'candidate') {
            this.handleExportCandidate();
        } else if (this.exportType == 'rating') {
            this.handleExportPlatformData();
        }
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CANDIDATES_UPLOADED, NAME],
    })
    jobRecord({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
            this.resetChildComponent();
        }
        else if (data) {
            //this.showLoadingSpinner = true;
            //console.log('Candidates Uploaded ' + getFieldValue(data, CANDIDATES_UPLOADED));
            this.totalCandidatesOnJob = getFieldValue(data, CANDIDATES_UPLOADED);
            this.jobName = getFieldValue(data, NAME);
        }
    }

    @wire(getGeneratedWrf, { jobId: '$recordId' })
    wiredContacts({ error, data }) {
        if (data) {
            //console.log('getGeneratedWrf data: ', JSON.stringify(data));
            this.generatedWRFId = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.showLoadingSpinner = false;
            this.resetChildComponent();
        }
    }

    handleExportCandidate() {
        console.log('this.apiListVar: ', this.apiListVar);
        if (this.apiListVar) {
            this.handleExportCandidateLogic(); // Call on Candidate Export
        }
    }

    @wire(getRecord, { recordId: '$generatedWRFId', fields: [CANDIDATE_FIELD_CONFIGURATION] })
    getCandidateDataFromgeneratedWRF({ error, data }) {
        if (data) {
            console.log('getCandidateDataFromgeneratedWRF data: ', JSON.stringify(data));

            this.candidateJSON = JSON.parse(data.fields.Candidate_Field_Configuration__c.value);
            //this.apiListVar = ['Id', ...this.candidateJSON.map(element => element.API_Name__c)].join(', ');
            console.log('Candidate JSON ', JSON.stringify(this.candidateJSON));
            this.apiListVar = ['Id', ...this.candidateJSON.filter(element => element.API_Name__c !== 'Category__c').map(element => element.API_Name__c)].join(', ');
            console.log('this.apiListVar: ', this.apiListVar);
            console.log('this.apiListVar: ', JSON.stringify(this.apiListVar));
            this.checkExportType();
        }
        if (error) {
            //console.log('error: ', error);
            this.showLoadingSpinner = false;
            this.resetChildComponent();
        }
    }

    handleExportCandidateLogic() { // IN USE
        this.showLoadingSpinner = true;
        console.log('In Export this.apiListVar: ', this.apiListVar);
        getCandidateCount({
            jobId: this.recordId,
            soqlQueryList: this.apiListVar
        })
            .then(result => {
                //console.log('getCandidateCount result: ', JSON.stringify(result));
                if (result.candidateCount == 0) {
                    this.showErrorMessage = true;
                    this.errorMessage = 'No Data found to Export';
                    //this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                } else if (result.candidateCount <= 50000) {
                    this.dataToExport = this.unparseJSONCandidate(result.candidateData);
                    console.log('getCandidateCount result: ', JSON.stringify(result.candidateData));
                    this.handleExportFile('Candidate');
                } else {
                    this.showErrorMessage = true;
                    this.initiateCheckQueryJobStatus(result.queryJobId, 'Candidate');
                    //this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');
                }
            })
            .catch(error => {
                //console.log('error: ', error);
                this.showLoadingSpinner = false;
                this.resetChildComponent();
            });
    }

    initiateCheckQueryJobStatus(queryJobId, exportType) {
        setTimeout(() => {
            this.checkQueryJobStatus(queryJobId, exportType);
        }, 5000);
    }

    handleExportPlatformData() { // IN USE
        this.showLoadingSpinner = true;
        this.formattingRequired = true;
        getRatingsCount({
            jobId: this.recordId,
            soqlQueryList: this.apiListVar,
            exportType: 'Rating'
        })
            .then(result => {
                console.log('getCandidateCount result: ', JSON.stringify(result));
                if (result.ratingCount == 0) {
                    this.showErrorMessage = true;
                    this.errorMessage = 'No Data found to Export';
                    //this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                } else if (result.ratingCount < 25000) {
                    let tempRecords = JSON.parse(JSON.stringify(result.ratingData));
                    let selfIndexCounter;

                    tempRecords = tempRecords.map(row => {
                        selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : (row.Rater_Type__c == 'Manager') ? 1 : (row.Rater_Type__c == 'Colleagues') ? 2 : (row.Rater_Type__c == 'Others') ? 3 : (row.Rater_Type__c == 'Direct Reports') ? 4 : 5;
                        return {
                            ...row,
                            selfIndex: selfIndexCounter,
                        };
                    });
                    tempRecords.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.Participant__r.Email__c.localeCompare(b.Participant__r.Email__c) || a.selfIndex - b.selfIndex);
                    //tempRecords.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.selfIndex - b.selfIndex);
                    tempRecords.forEach(row => {
                        delete row["selfIndex"];
                    });
                    let csvToExport = this.unparseJSON(tempRecords);
                    this.dataToExport = csvToExport;
                    console.log('data exported ', JSON.stringify(this.dataToExport));
                    this.handleExportFile('Platform');

                } else {
                    this.showErrorMessage = true;
                    this.initiateCheckQueryJobStatus(result.queryJobId, 'Platform');
                    //this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');
                }
            })
            .catch(error => {
                //console.log('error: handleExportPlatformData ', JSON.stringify(error));
                this.showLoadingSpinner = false;
                this.resetChildComponent();
            });
    }

    handleMasterView() {
        this.showLoadingSpinner = true;
        this.masterViewFlag = true;
        getRatingsCount({
            jobId: this.recordId,
            soqlQueryList: this.apiListVar,
            exportType: 'MasterView'
        })
            .then(result => {
                //console.log('getCandidateCount result: ', JSON.stringify(result));
                //console.log('result.ratingCount: ', result.ratingCount);
                if (result.ratingCount == 0) {
                    this.showErrorMessage = true;
                    this.errorMessage = 'No Data found to Export';
                    //this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
                } else if (result.ratingCount < 25000) {
                    let mergeData = this.mergeData(result.ratingData, result.candidateData);
                    //console.log('mergeData ', JSON.stringify(mergeData));
                    let formattedData = this.formatCSVData(mergeData);
                    this.dataToExport = this.unparseMatserViewJSON(formattedData);
                    this.handleExportFile('MasterView');
                } else {
                    this.showErrorMessage = true;
                    this.createQueryForMasterView();
                    this.initiateCheckQueryJobStatus(result.queryJobId, 'MasterView');
                    //this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');
                }
            })
            .catch(error => {
                //console.log('error ====> ', JSON.stringify(error));
                this.resetChildComponent();
            });
    }

    mergeData(ratingData, candidateData) {
        //console.log('Inside mergeData: ');
        let tempRecords = JSON.parse(JSON.stringify(ratingData));
        ////console.log('tempRecords: ', JSON.stringify(tempRecords));
        let tempRecordsCandidate = JSON.parse(JSON.stringify(candidateData));
        //console.log('tempRecordsCandidate: ', tempRecordsCandidate);
        let finalData = {};

        tempRecords = tempRecords.map(item => {

            ////console.log('item: ', JSON.stringify(item));
            ////console.log('item.hasOwnProperty: ', item.hasOwnProperty('Participant__r'));
            let index;
            if (item.hasOwnProperty('Respondent__r')) {
                index = tempRecordsCandidate.findIndex(attr => item.Respondent__r.Id === attr.Id);
            } else {
                index = tempRecordsCandidate.findIndex(attr => item["Respondent__r.Id"] === attr.Id);
            }

            let additionalData = tempRecordsCandidate[index];
            if (additionalData) {
                finalData = { ...additionalData, ...item };
                item = finalData;
            }
            return item;
        });

        tempRecords = tempRecords.map((row) => {
            let candidateRecordName = row.hasOwnProperty('Respondent__r') ? row.Respondent__r?.Name : row["Respondent__r.Name"];
            let participantFullName = row.hasOwnProperty('Participant__r') ? row.Participant__r?.Full_Name__c : row["Participant__r.Full_Name__c"];
            let respondantFullName = row.hasOwnProperty('Respondent__r') ? row.Respondent__r?.Full_Name__c : row["Respondent__r.Full_Name__c"];
            let respondantEmali = row.hasOwnProperty('Respondent__r') ? row.Respondent__r?.Email__c : row["Respondent__r.Email__c"];
            let participantEmail = row.hasOwnProperty('Participant__r') ? row.Participant__r?.Email__c : row["Participant__r.Email__c"];
            let participantWorkRequest = row.hasOwnProperty('Participant__r') ? row.Participant__r?.Work_Request__r.Name : row["Participant__r.Work_Request__r.Name"];
            return {
                ...row,
                candidateRecord: candidateRecordName,
                ratingRecord: (row.Name),
                raterType: (row.Rater_Type__c),
                workRequest: participantWorkRequest,
                participantName: participantFullName,
                respondentName: respondantFullName,
                respondentEmail: respondantEmali,
                participantEmail: participantEmail,
                vadcStatus: (row.VADC_Status__c),
                insightStatus: (row.Insights_Status__c),
                mfsStatus: (row.MFS_Status__c),
                tcStatus: (row.TC_Status__c),
                overallStatus: (row.Overall_Status__c),
                raterString: (row.Rater_Type__c != 'Self') ? (row.Rater_String__c) : null,
                reportReady: (row.Rater_Type__c == 'Self') ? (row.Report_Ready__c) : null,
                reportSent: (row.Report_Sent__c),
                mfsReportSent: (row.MFS_Report_Sent__c),
                tcReportSent: (row.TC_Report_Sent__c),
                reminder: (row.Reminder__c),
                deadline: (this.formatDateToISO(row.Deadline__c)),
                comments: (row.Comments__c),
                tcEmail: (row.File_Name__c),
                singleUseLink: (row.Single_Use_Link__c),
                emailType: (row.EmailType__c),
                emailFileName: (row.File_Name__c),
                sharepointFilePath: (row.Sharepoint_File_Path__c),
            };
        })
        tempRecords.forEach(row => {
            if (row.hasOwnProperty('Participant__c')) {
                delete row["Participant__c"];
            }
            if (row.hasOwnProperty('Respondent__c')) {
                delete row["Respondent__c"];
            }
            if (row.hasOwnProperty('Participant__r')) {
                delete row["Participant__r"];
            }
            if (row.hasOwnProperty('Respondent__r')) {
                delete row["Respondent__r"];
            }
        });
        return tempRecords;
    }

    createQueryForMasterView() {
        createQueryJobToGetCandidateDataForMasterView({
            soqlQueryList: this.apiListVar,
            jobId: this.recordId
        })
            .then(result => {
                //console.log('result: ', result);
                this.ratingQueryJobIdForMasterView = result;
                //console.log('ratingQueryJobIdForMasterView: ', this.ratingQueryJobIdForMasterView);
            })
            .catch(error => {
                //console.log('error: ', JSON.stringify(error));
                this.showLoadingSpinner = false;
                this.resetChildComponent();
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    checkQueryJobStatus(queryJobId, exportType) {
        getQueryStatus({
            queryJobId: queryJobId
        })
            .then(data => {
                if (data.state) {
                    let state = data.state;
                    //console.log('state: ', state);
                    let numberOfRecordsProcessed = data.numberOfRecord;
                    //console.log('numberOfRecordsProcessed: ', numberOfRecordsProcessed);

                    if (state == 'JobComplete') {
                        this.getQueryData(queryJobId, exportType);
                    } else if (state != 'Failed') {
                        this.initiateCheckQueryJobStatus(queryJobId, exportType);
                    }
                } else {
                    //console.log('Reponse Error ', data.response);
                    this.showLoadingSpinner = false;
                    this.resetChildComponent();
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
            .catch(error => {
                //console.log('error: ', JSON.stringify(error));
                this.showLoadingSpinner = false;
                this.resetChildComponent();
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    formatCSVData(dataSet) {
        //console.log('formatCSVData: ');
        let selfIndexCounter;
        //console.log('dataSet ', JSON.stringify(dataSet));
        let tempRecords = dataSet.map(row => {
            selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : (row.Rater_Type__c == 'Manager') ? 1 : (row.Rater_Type__c == 'Colleagues') ? 2 : (row.Rater_Type__c == 'Others') ? 3 : (row.Rater_Type__c == 'Direct Reports') ? 4 : 5;
            return {
                ...row,
                selfIndex: selfIndexCounter,
            };
        });
        tempRecords.sort((a, b) => a.participantName.localeCompare(b.participantName) || a.participantEmail.localeCompare(b.participantEmail) || a.selfIndex - b.selfIndex);

        tempRecords.forEach(row => {
            delete row["selfIndex"];
            delete row["participantEmail"];
        });
        return tempRecords;
    }

    getQueryData(queryJobId, exportType) {
        //console.log('Inside getCandidateQueryData: ');
        getQueryData({
            queryJobId: queryJobId
        })
            .then(data => {
                this.locator = data.locator;
                this.dataToExport = data.response;
                if (this.locator == null) {
                    this.handleExportFile(exportType);
                } else {
                    this.getMoreQueryData(queryJobId, data.locator, exportType);
                }
            })
            .catch(error => {
                //console.log('error getQueryData: ', JSON.stringify(error));
                this.showLoadingSpinner = false;
                this.resetChildComponent();
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    getMoreQueryData(queryJobId, locator, exportType) {
        getMoreQueryData({
            queryJobId: queryJobId,
            locator: locator
        })
            .then(data => {
                this.locator = data.locator;
                //console.log('this.locator: ', this.locator);

                let csvString = '';
                let headerList = [];
                headerList = this.apiListVar.split(',');
                headerList.forEach(element => {
                    if (csvString === '') {
                        csvString += '"' + element.replace(/\s/g, '') + '"';
                    } else {
                        csvString += ',"' + element.replace(/\s/g, '') + '"';
                    }
                });

                let csvArray = data.response.split('\n');
                // Remove the first line (header)
                csvArray.shift();
                // Join the array back into a CSV string
                let updatedCsvString = csvArray.join('\n');
                this.dataToExport = this.dataToExport.concat(updatedCsvString);

                if (this.locator == null) {
                    //console.log('this.formattingRequired: ', this.formattingRequired);
                    if (this.formattingRequired) {
                        let tempRecords = this.parseCSVtoJSON(this.dataToExport);
                        //console.log('tempRecords: ', JSON.stringify(tempRecords));
                        let selfIndexCounter;
                        tempRecords = tempRecords.map(row => {
                            selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : (row.Rater_Type__c == 'Manager') ? 1 : (row.Rater_Type__c == 'Colleagues') ? 2 : (row.Rater_Type__c == 'Others') ? 3 : (row.Rater_Type__c == 'Direct Reports') ? 4 : 5;
                            return {
                                ...row,
                                selfIndex: selfIndexCounter,
                            };
                        });
                        //tempRecords.sort((a, b) => a["Participant__r.Full_Name__c"].localeCompare(b["Participant__r.Full_Name__c"]) || a.selfIndex - b.selfIndex);
                        tempRecords.sort((a, b) => a["Participant__r.Full_Name__c"].localeCompare(b["Participant__r.Full_Name__c"]) || a["Participant__r.Email__c"].localeCompare(b["Participant__r.Email__c"]) || a.selfIndex - b.selfIndex);
                        tempRecords.forEach(row => {
                            row["Deadline__c"] = this.formatDateToISO(row["Deadline__c"]);
                            delete row["selfIndex"];
                            delete row["Participant__r.Name"];
                            delete row["Respondent__r.Name"];
                            delete row["Respondent__r.Id"];
                        });
                        this.dataToExport = this.unparseJSONRating(tempRecords);
                        this.handleExportFile(exportType);
                    }
                    else if (this.mergeDataForMasterViewFlag) {
                        let ratingData = this.parseCSVtoJSON(this.ratingDataToMerge);
                        let candidateData = this.parseCSVtoJSON(this.dataToExport);
                        let tempRecords = this.mergeData(ratingData, candidateData);
                        let selfIndexCounter;

                        tempRecords = tempRecords.map(row => {
                            selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : (row.Rater_Type__c == 'Manager') ? 1 : (row.Rater_Type__c == 'Colleagues') ? 2 : (row.Rater_Type__c == 'Others') ? 3 : (row.Rater_Type__c == 'Direct Reports') ? 4 : 5;
                            return {
                                ...row,
                                selfIndex: selfIndexCounter,
                            };
                        });
                        //tempRecords.sort((a, b) => a["Participant__r.Full_Name__c"].localeCompare(b["Participant__r.Full_Name__c"]) || a.selfIndex - b.selfIndex);
                        tempRecords.sort((a, b) => a["Participant__r.Full_Name__c"].localeCompare(b["Participant__r.Full_Name__c"]) || a["Participant__r.Email__c"].localeCompare(b["Participant__r.Email__c"]) || a.selfIndex - b.selfIndex);
                        tempRecords.forEach(row => {
                            delete row["selfIndex"];
                            delete row["Respondent__r.Id"];
                            delete row["participantEmail"];
                        });
                        this.dataToExport = this.unparseMatserViewJSON(tempRecords);
                        this.handleExportFile(exportType);
                    }
                    else if (this.masterViewFlag) {
                        //console.log('this.masterViewFlag: ', this.masterViewFlag);
                        this.masterViewFlag = false;
                        this.mergeDataForMasterViewFlag = true;
                        let ratingDataJSON = this.parseCSVtoJSON(this.dataToExport);
                        this.ratingDataToMerge = JSON.parse(JSON.stringify(this.dataToExport));
                        this.checkQueryJobStatus(this.ratingQueryJobIdForMasterView, exportType);

                        ////console.log('this.ratingDataToMerge: ', this.ratingDataToMerge);
                    } else {
                        this.handleExportFile(exportType);
                    }
                } else {
                    //console.log('else: ');
                    this.getMoreQueryData(queryJobId, data.locator, exportType);
                }
            })
            .catch(error => {
                //console.log('error getMoreQueryData: ', JSON.stringify(error));
                this.showLoadingSpinner = false;
                this.resetChildComponent();
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    handleExportFile(exportType) { // IN USE
        console.log('inside handleExportFile');
        console.log('inside handleExportFile', this.dataToExport);

        var universalBOM = "\uFEFF";
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(universalBOM + this.dataToExport);
        downloadElement.target = '_self';
        downloadElement.download = this.jobName + '_' + exportType + 'ExportSheet.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        document.body.removeChild(downloadElement);
        this.showLoadingSpinner = false;
        this.resetChildComponent();
    }

    unparseJSON67(jsonToCSV) {
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        rowData = [
            'Id', 'Name', 'Participant__r.Work_Request__r.Name','Participant__r.Full_Name__c', 'Participant__r.Email__c', 'Respondent__r.Full_Name__c', 'Respondent__r.Email__c',
            'Rater_Type__c', 'VADC_Status__c', 'Insights_Status__c', 'MFS_Status__c', 'TC_Status__c', 'Overall_Status__c', 'Rater_String__c', 'Reminder__c', 'Report_Ready__c',
            'Report_Sent__c', 'MFS_Report_Sent__c', 'TC_Report_Sent__c', 'Deadline__c', 'Comments__c', 'File_Name__c', 'Single_Use_Link__c',
            'EmailType__c', 'Email_File_Name__c', 'Sharepoint_File_Path__c',
        ];
        csvString += rowData.join(',');
        csvString += rowEnd;
        for (let i = 0; i < jsonToCSV.length; i++) {
            let colValue = 0;
            for (let rowKey in headers) {
                if (rowData.hasOwnProperty(key)) {
                    if (colValue > 0) {
                        csvString += ',';
                    }
                    let value = jsonToCSV[i][rowKey] === undefined ? '' : jsonToCSV[i][rowKey];
                    if (rowKey != 'Rater_String__c') {
                        csvString += '"' + value + '"';
                    } else {
                        csvString += '"' + ((jsonToCSV[i]["Rater_Type__c"] != 'Self') ? (jsonToCSV[i]["Rater_String__c"]) : null) + '"';
                    }
                    colValue++;
                }
            }
            csvString += rowEnd;
            //console.log('csvString: ', csvString);
        }
    }

    escapeCSV(value) {
        console.log('inside escapeCSV: ', value);
        if (value === undefined || value === null) return '';
        const str = value.toString();
        // Escape double quotes by replacing with two double quotes, and wrap in quotes if contains comma, quote, or newline
        if (str.includes(',') || str.includes('"') || str.includes('\n')) {
            return `"${str.replace(/"/g, '""')}"`;
        }
        return str;
    }

    unparseJSON(jsonToCSV) {
        let data = jsonToCSV;

        // Define the CSV headers
        const headers = [
            'Id', 'Name', 'Participant__r.Work_Request__r.Name','Participant__r.Full_Name__c', 'Participant__r.Email__c', 'Respondent__r.Full_Name__c', 'Respondent__r.Email__c',
            'Rater_Type__c', 'VADC_Status__c', 'Insights_Status__c', 'MFS_Status__c', 'TC_Status__c', 'Overall_Status__c', 'Rater_String__c', 'Reminder__c', 'Report_Ready__c',
            'Report_Sent__c', 'MFS_Report_Sent__c', 'TC_Report_Sent__c', 'Deadline__c', 'Comments__c', 'File_Name__c', 'Single_Use_Link__c',
            'EmailType__c', 'Email_File_Name__c', 'Sharepoint_File_Path__c',
        ];

        // Convert the headers array to a CSV string
        let csvString = headers.join(',') + '\n';
        // Loop through the ratingData array and create CSV rows
        console.log('584 fine');
        data.forEach(item => {
            const row = [
                this.escapeCSV(item.Id),
                this.escapeCSV(item.Name),
                this.escapeCSV(item.Participant__r.Work_Request__r.Name),
                this.escapeCSV(item.Participant__r.Full_Name__c),
                this.escapeCSV(item.Participant__r.Email__c),
                this.escapeCSV(item.Respondent__r.Full_Name__c),
                this.escapeCSV(item.Respondent__r.Email__c),
                this.escapeCSV(item.Rater_Type__c),
                this.escapeCSV(item.VADC_Status__c),
                this.escapeCSV(item.Insights_Status__c),
                this.escapeCSV(item.MFS_Status__c),
                this.escapeCSV(item.TC_Status__c),
                this.escapeCSV(item.Overall_Status__c),
                this.escapeCSV(item.Rater_Type__c != 'Self' ? (item.Rater_String__c) : null),
                this.escapeCSV(item.Reminder__c),
                this.escapeCSV(item.Rater_Type__c == 'Self') ? (item.Report_Ready__c) : null,
                this.escapeCSV(item.Report_Sent__c),
                this.escapeCSV(item.MFS_Report_Sent__c),
                this.escapeCSV(item.TC_Report_Sent__c),
                this.escapeCSV(item.Deadline__c),
                this.escapeCSV(item.Comments__c),
                this.escapeCSV(item.File_Name__c),
                this.escapeCSV(item.Single_Use_Link__c),
                this.escapeCSV(item.EmailType__c),
                this.escapeCSV(item.Email_File_Name__c),
                this.escapeCSV(item.Sharepoint_File_Path__c)
            ];
            // Add the row to the CSV string
            csvString += row.join(',') + '\n';
        });
        console.log('616 fine', csvString);
        return csvString;
    }

    unparseMatserViewJSON(jsonToCSV) {
        let data = jsonToCSV;

        const headers = [
            'Candidate Id',
            'Rating Number',
            //...this.candidateJSON.map(element => element.Label__c),
            ...this.candidateJSON.filter(element => element.Label__c !== 'Category').map(element => element.Label__c),
            'Rater Type','Work Request', 'Participant Name', 'Respondent Name', 'Respondent Email',
            'VADC Status', 'Insights Status',
            'MFS Status', 'TC Status', 'Overall Status', 'Rater String', 'Report Ready',
            'Report Sent', 'MFS Report Sent', 'TC Report Sent', 'Reminder', 'Deadline', 'Comments', 'File Name', 'Single Use Link',
            'Email Type', 'Email File Name', 'Sharepoint File Path'
        ];

        //console.log('headers: ', JSON.stringify(headers));

        // Convert the headers array to a CSV string
        let csvString = headers.join(',') + '\n';
        data.every(item => {
            //console.log('data data data item: ', JSON.stringify(item));
            return false;
        });
        // Loop through the ratingData array and create CSV rows
        data.forEach(item => {
            // Extract row data
            const row = [
                this.escapeCSV(item.candidateRecord),
                this.escapeCSV(item.ratingRecord),
                ...this.candidateJSON.filter(element => element.API_Name__c !== 'Category__c').map(element => this.escapeCSV(item[element.API_Name__c]) || ''),
                //...this.candidateJSON.map(element => this.escapeCSV(item[element.API_Name__c]) || ''), // Handles missing keys safely
                this.escapeCSV(item.raterType),
                this.escapeCSV(item.workRequest),
                this.escapeCSV(item.participantName),
                this.escapeCSV(item.respondentName),
                this.escapeCSV(item.respondentEmail),
                this.escapeCSV(item.vadcStatus),
                this.escapeCSV(item.insightStatus),
                this.escapeCSV(item.mfsStatus),
                this.escapeCSV(item.tcStatus),
                this.escapeCSV(item.overallStatus),
                this.escapeCSV(item.raterString),
                this.escapeCSV(item.reportReady),
                this.escapeCSV(item.reportSent),
                this.escapeCSV(item.mfsReportSent),
                this.escapeCSV(item.tcReportSent),
                this.escapeCSV(item.reminder),
                this.escapeCSV(item.deadline),
                this.escapeCSV(item.comments),
                this.escapeCSV(item.tcEmail),
                this.escapeCSV(item.singleUseLink),
                this.escapeCSV(item.emailType),
                this.escapeCSV(item.emailFileName),
                this.escapeCSV(item.sharepointFilePath)
            ];

            csvString += row.join(',') + '\n';

        });
        //console.log('csvString: ', csvString);
        return csvString;
    }

    unparseJSONCandidate(jsonToCSV) {
        const headerList = [...new Set(jsonToCSV.flatMap(obj => Object.keys(obj)))]; // Get list of keys from JSON
        console.log('headerList: ', JSON.stringify(headerList));
        var csv = Papa.unparse(jsonToCSV, {
            quotes: false,
            quoteChar: '"',
            escapeChar: '"',
            delimiter: ",",
            header: true,
            newline: "\r\n",
            skipEmptyLines: false, //other option is 'greedy', meaning skip delimiters, quotes, and whitespace.
            columns: headerList //or array of strings
        });
        return csv;
    }

    unparseJSONRating(jsonToCSV) {
        const headers = [
            'Id', 'Name','Participant__r.Work_Request__r.Name', 'Participant__r.Full_Name__c', 'Participant__r.Email__c', 'Respondent__r.Full_Name__c', 'Respondent__r.Email__c',
            'Rater_Type__c', 'VADC_Status__c', 'Insights_Status__c', 'MFS_Status__c', 'TC_Status__c', 'Overall_Status__c', 'Rater_String__c', 'Reminder__c', 'Report_Ready__c',
            'Report_Sent__c', 'MFS_Report_Sent__c', 'TC_Report_Sent__c', 'Deadline__c', 'Comments__c', 'File_Name__c', 'Single_Use_Link__c',
            'EmailType__c', 'Email_File_Name__c', 'Sharepoint_File_Path__c',
        ];

        var csv = Papa.unparse(jsonToCSV, {
            quotes: false,
            quoteChar: '"',
            escapeChar: '"',
            delimiter: ",",
            header: true,
            newline: "\r\n",
            skipEmptyLines: false, //other option is 'greedy', meaning skip delimiters, quotes, and whitespace.
            columns: headers //or array of strings
        });
        return csv;
    }

    parseCSVtoJSON(tempRecords) {
        let jsonData;
        var completeProcessing = (results) => {
            jsonData = JSON.parse(JSON.stringify(results.data));
        }

        var errorProcessing = (error) => {
            //console.log('error: ', error);
        };
        Papa.parse(tempRecords, {
            skipEmptyLines: true,
            quoteChar: '"',
            header: true,
            complete: completeProcessing,
            error: errorProcessing
        })
        return jsonData;
    }

    resetChildComponent() {
        const submitEvent = new CustomEvent('reset', {
            detail: { closeModal: true }
        });
        // Fire the custom event
        this.dispatchEvent(submitEvent);
    }

    formatDateToISO(dateStr) {
        if (!dateStr || dateStr.trim() === '') {
            return ''; // return blank if no value
        }
        const [day, month, year] = dateStr.split("-");
        return `${year}-${month}-${day}`;
    }

}