import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';
import { loadScript } from 'lightning/platformResourceLoader';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import CANDIDATE_FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Candidate_Field_Configuration__c';
import getQueryStatus from '@salesforce/apex/CustomerRequestController.getQueryStatus';
import getQueryData from '@salesforce/apex/CustomerRequestController.getQueryData';
import getMoreQueryData from '@salesforce/apex/CustomerRequestController.getMoreQueryData';
import getRatingsCount from '@salesforce/apex/MasterProgressReportView.getRatingsCount';
import createQueryJobToGetCandidateDataForMasterView from '@salesforce/apex/CustomerRequestController.createQueryJobToGetCandidateDataForMasterView';

const arrayMap4 = { "Participant__r.Full_Name__c": "Participant Name", "Participant__r.Email__c": "Participant Email", "Respondent__r.Full_Name__c": "Respondent Name", "Respondent__r.Email__c": "Respondent Email", "Rater_Type__c": "Rater Type", "MFS_Status__c": "MFS Status", "TC_Status__c": "TC Status", "Overall_Status__c": "Overall Status", "Report_Ready__c": "Report Ready", "Report_Sent__c": "Report Sent",};
const arrayMap1 = { "participantName": "Participant Name","participantEmail": "Participant Email", "respondentFullName": "Respondent Name", "respondentEmail": "Respondent Email", "Rater_Type__c": "Rater Type", "MFS_Status__c": "MFS Status", "TC_Status__c": "TC Status", "Overall_Status__c": "Overall Status", "Report_Ready__c": "Report Ready", "Report_Sent__c": "Report Sent",};

export default class ExportReportView extends LightningElement {
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
    @api candidateJSON;
    formattingRequired = false;
    masterViewFlag = false;
    mergeDataForMasterViewFlag = false;
    ratingDataToMerge;
    ratingQueryJobIdForMasterView;
    resetCall = false;
    @api ratingApiNameList;
    @api candidateApiNameList;
    candidateList;
    ratingList = [];

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

        console.log('this.candidateJSON: ', JSON.stringify(this.candidateJSON));
        console.log('this.ratingApiNameList: ', JSON.stringify(this.ratingApiNameList));
        //console.log('this.candidateApiNameList: ', JSON.stringify(this.candidateApiNameList));
        //let candidateApiList = [];
        const jsonString = JSON.stringify(this.candidateJSON);
        const jsonArray = JSON.parse(jsonString);
        //console.log('jsonArray', JSON.stringify(jsonArray));
        // Check if an object with label === "Email" exists
        const hasEmailLabel = jsonArray.some(item => item.label === "Email");
        const hasPartName = jsonArray.some(item => item.label === "Participant Name");
        const hasPartEmail = jsonArray.some(item => item.label === "Participant Email");
        const hasRespEmail = jsonArray.some(item => item.label === "Respondent Email");
        const hasRespName = jsonArray.some(item => item.label === "Respondent Name");
        const hasRaterType = jsonArray.some(item => item.label === "Rater Type");
        //console.log('hasEmailLabel',hasEmailLabel);

        //exclude columns value if not present in header
        if(!jsonString.includes('First Name') && this.candidateApiNameList.includes('First_Name__c')){
            this.candidateApiNameList = this.candidateApiNameList.split(',').map(item => item.trim()).filter(item => item !== 'First_Name__c').join(', '); // Convert back to a string
        }
        if(!jsonString.includes('Last Name') && this.candidateApiNameList.includes('Last_Name__c')){
            this.candidateApiNameList = this.candidateApiNameList.split(',').map(item => item.trim()).filter(item => item !== 'Last_Name__c').join(', '); // Convert back to a string
        }
        if(!hasEmailLabel && this.candidateApiNameList.includes('Email__c')){
            this.candidateApiNameList = this.candidateApiNameList.split(',').map(item => item.trim()).filter(item => item !== 'Email__c').join(', '); // Convert back to a string
        }
        console.log('hasPartName',hasPartName );
        console.log('hasRespEmail',hasRespEmail );
        console.log('hasRespName',hasRespName );
        console.log('hasPartEmail',hasPartEmail );
        console.log('hasRaterType',hasRaterType);
        if(!hasPartName && this.ratingApiNameList.includes('Participant__r.Full_Name__c')){
            this.ratingApiNameList = this.ratingApiNameList.split(',').map(item => item.trim()).filter(item => item !== 'Participant__r.Full_Name__c').join(', '); // Convert back to a string
        }
        if(!hasPartEmail && this.ratingApiNameList.includes('Participant__r.Email__c')){
            this.ratingApiNameList = this.ratingApiNameList.split(',').map(item => item.trim()).filter(item => item !== 'Participant__r.Email__c').join(', '); // Convert back to a string
        }
        if(!hasRespName && this.ratingApiNameList.includes('Respondent__r.Full_Name__c')){
            this.ratingApiNameList = this.ratingApiNameList.split(',').map(item => item.trim()).filter(item => item !== 'Respondent__r.Full_Name__c').join(', '); // Convert back to a string
        }
    
        if(!hasRespEmail && this.ratingApiNameList.includes('Respondent__r.Email__c')){
            this.ratingApiNameList = this.ratingApiNameList.split(',').map(item => item.trim()).filter(item => item !== 'Respondent__r.Email__c').join(', '); // Convert back to a string
        }
        
       if(!hasRaterType && this.ratingApiNameList.includes('Rater_Type__c')){
            this.ratingApiNameList = this.ratingApiNameList.split(',').map(item => item.trim()).filter(item => item !== 'Rater_Type__c').join(', '); // Convert back to a string
        }

        // Ensure it's an array
        let listArray = this.ratingApiNameList ? this.ratingApiNameList.split(", ") : [];
        console.log('listArray',listArray);
        // Add value if it doesn't exist
        if (!hasRespName && !hasRespEmail) {
            listArray.push('Respondent__r.id');
        }

        if (!hasPartName && !hasPartName) {
            listArray.push('Participant__r.id');
        }

        // Convert back to a comma-separated string
        this.ratingApiNameList = listArray.join(", ");
        
        let candidateApiList = this.candidateApiNameList.split(',');
        this.candidateList = [...candidateApiList];
        //console.log('this.candidateApiNameList before sorting: ', JSON.stringify(this.candidateApiNameList));
        // Remove extra spaces from elements
        this.candidateList = this.candidateList.map(item => item.trim());

        // Define the priority order
        const priorityOrder = ["Id", "First_Name__c", "Last_Name__c", "Email__c"];

        // Custom sort function
        this.candidateList.sort((a, b) => {
            const indexA = priorityOrder.indexOf(a);
            const indexB = priorityOrder.indexOf(b);
            
            // If both elements are in priorityOrder, sort by their index
            if (indexA !== -1 && indexB !== -1) {
                return indexA - indexB;
            }
            
            // If only one element is in priorityOrder, prioritize it
            if (indexA !== -1) return -1;
            if (indexB !== -1) return 1;
            
            // If neither element is in priorityOrder, maintain original order
            return 0;
        });

        // Convert back to a comma-separated string
        this.candidateApiNameList = this.candidateList.join(', ');
        
        //console.log('this.candidateList after sorting: ', JSON.stringify(this.candidateList));
        //console.log('this.candidateApiNameList after sorting: ', JSON.stringify(this.candidateApiNameList));
        this.ratingList = this.ratingApiNameList.split(',');
        console.log('this.ratingList: ', JSON.stringify(this.ratingList));
        
        if (this.recordId && this.ratingApiNameList) {
            this.handleMasterView();
        }
    }

    //This function helps to find value based on key
    getKeyByValue(object, value) {
        return Object.keys(object).find(key => object[key] === value);
    }

    /*@wire(getRecord, { recordId: '$recordId', fields: [CANDIDATE_FIELD_CONFIGURATION] })
    getCandidateDataFromgeneratedWRF({ error, data }) {
        if (data) {
            //console.log('getCandidateDataFromgeneratedWRF data: ', JSON.stringify(data));

            this.candidateJSON = JSON.parse(data.fields.Candidate_Field_Configuration__c.value);
            let ratingApiNameList = 'Id';
            this.candidateJSON.forEach(element => {
                if (element.label) {
                    let rowKey = this.getKeyByValue(arrayMap4, element.label);
                    if (rowKey) {
                        ratingApiNameList = ratingApiNameList + ', ' + rowKey;
                    }
                }
            });
            this.handleExportPlatformData(ratingApiNameList);
        }
        if (error) {
            //console.log('error: ', error);
            this.showLoadingSpinner = false;
        }
    }*/

    handleMasterView() {
        this.showLoadingSpinner = true;
        this.masterViewFlag = true;
        let formattedData =[];
        let formattedDataSelf =[];
        getRatingsCount({
            jobId: this.recordId,
            soqlQueryRatingList: this.ratingApiNameList,
            soqlQueryList: this.candidateApiNameList,
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
                    //console.log('result.candidateData: ', JSON.stringify(result.candidateData));
                    //console.log('result.ratingData: ', JSON.stringify(result.ratingData));
                    console.log('mergeData ', JSON.stringify(mergeData));
                    if(!this.ratingApiNameList.includes('Participant__r.Full_Name__c')){
                        formattedDataSelf = this.formatCSVDataSelf(mergeData);
                        console.log('selefexport',formattedDataSelf);
                        this.dataToExport = this.unparseMatserViewJSON(formattedDataSelf);
                    }
                    else{
                        formattedData = this.formatCSVData(mergeData);
                        console.log('formattedData inside else',JSON.stringify(formattedData));
                        this.dataToExport = this.unparseMatserViewJSON(formattedData);
                    }
                     
                    //console.log('formattedData ',this.formattedData);
                    
                    this.handleExportFile('MasterView');
                } else {
                    this.showErrorMessage = true;
                    this.createQueryForMasterView();
                    this.initiateCheckQueryJobStatus(result.queryJobId, 'MasterView');
                    //this.displayMessage('INFO', this.errorMessage, 'slds-theme_success');
                }
            })
            .catch(error => {
                console.log('error ====> ', JSON.stringify(error));
                this.resetChildComponent();
            });
    }

    mergeData(ratingData, candidateData) {
        //console.log('Inside mergeData: ');
        let tempRecords = JSON.parse(JSON.stringify(ratingData));
        //console.log('tempRecords: ', JSON.stringify(tempRecords));
        let tempRecordsCandidate = JSON.parse(JSON.stringify(candidateData));
        //console.log('tempRecordsCandidate: ', tempRecordsCandidate);
        let finalData = {};

        tempRecords = tempRecords.map(item => {

            //console.log('item: ', JSON.stringify(item));
            //console.log('item.hasOwnProperty: ', item.hasOwnProperty('Participant__r'));
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

        return tempRecords;
    }

    formatCSVData(dataSet) {
        //console.log('formatCSVData: ');
        let selfIndexCounter;
        //console.log('dataSet ', JSON.stringify(dataSet));
        let tempRecords = dataSet.map(row => {
            selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : (row.Rater_Type__c == 'Manager') ? 1 : (row.Rater_Type__c == 'Colleagues') ? 2 : (row.Rater_Type__c == 'Others') ? 3 : (row.Rater_Type__c == 'Direct Reports') ? 4 : 5;
            let participantFullName = row.hasOwnProperty('Participant__r') ? row.Participant__r?.Full_Name__c : row["Participant__r.Full_Name__c"];
            let respondentFullName = row.hasOwnProperty('Respondent__r') ? row.Respondent__r?.Full_Name__c : row["Respondent__r.Full_Name__c"];
            let respondentEmail = row.hasOwnProperty('Respondent__r') ? row.Respondent__r?.Email__c : row["Respondent__r.Email__c"];
            let participantEmail = row.hasOwnProperty('Participant__r') ? row.Participant__r?.Email__c : row["Participant__r.Email__c"];
            return {
                ...row,
                selfIndex: selfIndexCounter,
                participantName: participantFullName,
                participantEmail: participantEmail,
                "Participant__r.Full_Name__c": participantFullName,
                "Respondent__r.Full_Name__c": respondentFullName,
                "Respondent__r.Email__c": respondentEmail,
                "Participant__r.Email__c": participantEmail,
            };
        });
        //tempRecords.sort((a, b) => a.participantName.localeCompare(b.participantName) || a.selfIndex - b.selfIndex);
        tempRecords.sort((a, b) => a.participantName.localeCompare(b.participantName) || a.participantEmail.localeCompare(b.participantEmail) || a.selfIndex - b.selfIndex);
        tempRecords.forEach(row => {
            delete row["selfIndex"];
            delete row["participantName"];
            delete row["participantEmail"];
        });
        console.log('tempRecords formatted data: ', JSON.stringify(tempRecords));
        return tempRecords;
    }

    //Self table export
    formatCSVDataSelf(dataSet) {
        //console.log('formatCSVData self: ');
        let selfIndexCounter;
        //console.log('dataSet self ', JSON.stringify(dataSet));
        let tempRecords = dataSet.map(row => {
            selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : (row.Rater_Type__c == 'Manager') ? 1 : (row.Rater_Type__c == 'Colleagues') ? 2 : (row.Rater_Type__c == 'Others') ? 3 : (row.Rater_Type__c == 'Direct Reports') ? 4 : 5;
             return {
                ...row,
                selfIndex: selfIndexCounter,
            };
        });
        //tempRecords.sort((a, b) => a.participantName.localeCompare(b.participantName) || a.selfIndex - b.selfIndex);
        //tempRecords.sort((a, b) => a.participantName.localeCompare(b.participantName) || a.participantEmail.localeCompare(b.participantEmail) || a.selfIndex - b.selfIndex);
        tempRecords.forEach(row => {
            delete row["selfIndex"];
        });
        //console.log('tempRecords self table formatted data: ', JSON.stringify(tempRecords));
        return tempRecords;
    }


    initiateCheckQueryJobStatus(queryJobId) {
        setTimeout(() => {
            this.checkQueryJobStatus(queryJobId);
        }, 5000);
    }

    checkQueryJobStatus(queryJobId) {
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
                        this.getQueryData(queryJobId);
                    } else if (state != 'Failed') {
                        this.initiateCheckQueryJobStatus(queryJobId);
                    }
                } else {
                    //console.log('Reponse Error ', data.response);
                }
            })
            .catch(error => {
                //console.log('error: ', JSON.stringify(error));
                this.showLoadingSpinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    getQueryData(queryJobId) {
        //console.log('Inside getCandidateQueryData: ');
        getQueryData({
            queryJobId: queryJobId
        })
            .then(data => {
                this.locator = data.locator;
                this.dataToExport = data.response;
                if (this.locator == null) {
                    this.handleExportFile();
                } else {
                    this.getMoreQueryData(queryJobId, data.locator);
                }
            })
            .catch(error => {
                //console.log('error: ', JSON.stringify(error));
                this.showLoadingSpinner = false;
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
                /*let headerList = [];
                headerList = this.apiListVar.split(',');
                headerList.forEach(element => {
                    if (csvString === '') {
                        csvString += '"' + element.replace(/\s/g, '') + '"';
                    } else {
                        csvString += ',"' + element.replace(/\s/g, '') + '"';
                    }
                });*/

                let csvArray = data.response.split('\n');
                // Remove the first line (header)
                csvArray.shift();
                // Join the array back into a CSV string
                let updatedCsvString = csvArray.join('\n');
                this.dataToExport = this.dataToExport.concat(updatedCsvString);

                if (this.locator == null) {
                    if (this.mergeDataForMasterViewFlag) {
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
                            delete row["Participant__r.Email__c"]
                            //delete row["Respondent__r.Id"];
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

                        //console.log('this.ratingDataToMerge: ', this.ratingDataToMerge);
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

    createQueryForMasterView() {
        createQueryJobToGetCandidateDataForMasterView({
            soqlQueryList: this.candidateApiNameList,
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

    handleExportFile() { // IN USE
        //console.log('inside handleExportFile');

        var universalBOM = "\uFEFF";
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(universalBOM + this.dataToExport);
        downloadElement.target = '_self';
        downloadElement.download = 'ReportViewExport.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        document.body.removeChild(downloadElement);
        this.showLoadingSpinner = false;
        this.resetChildComponent();
    }

    unparseJSONCandidate(jsonToCSV) {
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

    unparseJSON(jsonToCSV) {
        let data = jsonToCSV;

        // Define the CSV headers
        const headers = [
            ...this.candidateJSON.filter(element => this.getKeyByValue(arrayMap4, element.label) != null).map(element => element.label)
        ];
        //console.log('candidateJSON: ', JSON.stringify(this.candidateJSON));
        //console.log('headers: ', JSON.stringify(headers));
        const apiNameList = [
            ...this.candidateJSON.filter(element => this.getKeyByValue(arrayMap4, element.label) != null).map(element => this.getKeyByValue(arrayMap1, element.label))
        ];

        //console.log('apiNameList: ', JSON.stringify(apiNameList));
        // Convert the headers array to a CSV string
        let csvString = headers.join(',') + '\n';
        //console.log('csvString',csvString);
        // Loop through the ratingData array and create CSV rows
        data.forEach(item => {
            const row = [
                ...apiNameList.map(element => item[element] || '')
            ];
            // Add the row to the CSV string
            csvString += row.join(',') + '\n';
        });
        return csvString;
    }

    escapeCSV(value) {
        if (value === undefined || value === null) return '';
        const str = value.toString();
        // Escape double quotes by replacing with two double quotes, and wrap in quotes if contains comma, quote, or newline
        if (str.includes(',') || str.includes('"') || str.includes('\n')) {
            return `"${str.replace(/"/g, '""')}"`;
        }
        return str;
    }

    unparseMatserViewJSON(jsonToCSV) {
        let data = jsonToCSV;

       /* let tempVar = this.candidateJSON.map(element => {
            if (element.label == 'MFS Report Sent') {
                element.label = '360 Report Sent';
            }
            else if (element.label == 'TC Report Sent') {
                element.label = 'Assessment Report Sent';
            }
            else if (element.label == 'Overall Status') {
                element.label = 'Overall Status(360 + Assessment)';
            }
            else if (element.label == 'MFS Status') {
                element.label = '360 Status';
            }
            else if (element.label == 'TC Status') {
                element.label = 'Assessment Status';
            }
            else if (element.label == 'Participant Name') {
                element.label = 'Foci Name';
            }
            return element;
        });*/

        const headers = [
            ...this.candidateJSON.filter(element => element.label !== 'S.No.').map(element => element.label),
            //...tempVar.filter(element => element.label !== 'S.No.').map(element => element.label),
        ];

        //console.log('headers: ', JSON.stringify(headers));

        // Convert the headers array to a CSV string
        let csvString = headers.join(',') + '\n';
        //console.log('this.candidateList ', JSON.stringify(this.candidateList));
        //console.log('this.ratingList ', JSON.stringify(this.ratingList));
        // Loop through the ratingData array and create CSV rows
        data.forEach(item => {

            // Extract row data
            const row = [
                ...this.candidateList.filter(element => element !== 'Id').map(element => this.escapeCSV(item[element.trim()]) || ''), // Handles missing keys safely
                ...this.ratingList.filter(element => element !== 'Id').map(element => this.escapeCSV(item[element.trim()]) || ''), // Handles missing keys safely
            ];

            csvString += row.join(',') + '\n';

        });
        console.log('csvString: ', csvString);
        return csvString;
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
            detail: { exportReport: true }
        });
        // Fire the custom event
        this.dispatchEvent(submitEvent);
    }
}