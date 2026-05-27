import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import VERSION_DATA_FIELD from '@salesforce/schema/ContentVersion.VersionData';
import CANDIDATE_FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Candidate_Field_Configuration__c';
import SYSTEM_USED from '@salesforce/schema/Work_Request__c.System_Used__c';
import TEMPLATE_INSTRUCTIONS from '@salesforce/schema/Work_Request__c.Candidate_Template_Instructions__c';
import { loadScript } from 'lightning/platformResourceLoader';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CATEGORY_FIELD from '@salesforce/schema/Bureau_Rating__c.Rater_Type__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CrfFClientFileUpload extends LightningElement {

    @api recordId;
    @api candidatesList;
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
    csvData;
    errorMessage;
    showLoadingSpinner = false;
    dropDownValuesList = [];
    showFileName = false;
    errorType;
    showManualCandidateScreen = false;
    isMFSSystem;
    templateInstructions;
    arrayOfCategoryValues;

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
            //console.log('error: ', error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [CANDIDATE_FIELD_CONFIGURATION, SYSTEM_USED, TEMPLATE_INSTRUCTIONS] })
    getCandidateDataFromgeneratedWRF({ error, data }) {
        if (data) {
            this.candidateData = JSON.parse(data.fields.Candidate_Field_Configuration__c.value);
            let templateInstructions = getFieldValue(data, TEMPLATE_INSTRUCTIONS);
            if (templateInstructions) {
                let templateInstructionsList = templateInstructions.split('\n');
                let filteredList = templateInstructionsList.filter(item => item && item.trim() !== '');
                this.templateInstructions = [...filteredList];
            }
            let systemUsed = getFieldValue(data, SYSTEM_USED);
            //let systemUsed = JSON.parse(data.fields.System_Used__c.value);
            //console.log('systemUsed: ', systemUsed);
            this.isMFSSystem = systemUsed.includes('360') ? true : false;
            //console.log('this.isMFSSystem: ', this.isMFSSystem);
            let templateHeader = [];
            this.candidateData.forEach(element => {
                templateHeader.push(element.Label__c);
            });

            this.rowHeaderToImport = [...templateHeader];
            //console.log('this.templateHeader: ', JSON.stringify(this.rowHeaderToImport));
        }
        if (error) {
            //console.log('recordId: error ', this.recordId);
            //console.log('error: ', JSON.stringify(error));
        }
    }

    @wire(getRecord, { recordId: '$contentVersionId', fields: [VERSION_DATA_FIELD] })
    contentversion({ error, data }) {
        if (data) {
            ////console.log("data " + JSON.stringify(data));
            ////console.log('data.fields.VersionData.value: ', data.fields.VersionData.value);
            var temp = data.fields.VersionData.value;
            ////console.log("temp " + temp);
            ////console.log(' hi ', this.decodeBase64(temp));
            ////console.log(' hi ', JSON.stringify(this.decodeBase64(temp)));
            this.initialJSON = this.decodeBase64(temp);
            //console.log('this.initialJSON: ', JSON.stringify(this.initialJSON));
            this.parseCSVtoJSON();
        }
        if (error) {
            //console.log('contentversion error: ', JSON.stringify(error));
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

    parseCSVtoJSON() {
        var completeProcessing = (results) => {
            //console.log('results: ', results);
            ////console.log('this._rows: ', JSON.stringify(results.data));
            this.csvData = JSON.parse(JSON.stringify(results.data));
            //console.log('this.csvData: ', JSON.stringify(this.csvData));
            //console.log('results.data length: ', results.data.length);

            let result = true;
            let errorMessage = '';
            var validateFileHeadersFlag = this.validateColumns(errorMessage);
            //console.log('validateFileHeadersFlag: ', validateFileHeadersFlag);

            //If headers are correct
            if (validateFileHeadersFlag) {
                //check if required field is blank
                var validateDataFlag = this.validateData(errorMessage);
                //console.log('validateDataFlag: ', validateDataFlag);
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
                this.showFileName = false;
                //this.displayMessage('ERROR', this.errorMessage, 'slds-theme_error');
            }
            //If no error
            else {
                //console.log('this.documentName: ', this.documentName);
                this.showFileName = true;
                this.showLoadingSpinner = false;
                //this.disableInput = false;
                this.showErrorMessage = false;
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

                const successEvent1 = new CustomEvent("candidatedetails", {
                    detail: {
                        contentVersionId: this.contentDocumentId,
                        documentName: this.documentName
                    }
                });
                this.dispatchEvent(successEvent1);

                const successEvent = new CustomEvent("parse", {
                    detail: {
                        candidateRequestedCount: results.data.length,
                        participantRequestedCount: participantCount
                    }
                });
                this.dispatchEvent(successEvent);
            }
        }

        var errorProcessing = (error) => {
            //console.log('error: ', error);
            this.showFileName = false;
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

    handleUploadFinished(event) {
        // Get the list of uploaded files
        this.showFileName = false;
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

    handleManualCandidate() {

        this.showOptionScreen = false;
        this.showImportCandidateScreen = false;
        this.showManualCandidateScreen = true;
        const successEvent = new CustomEvent("screen", {
            detail: { screenName: 'manual' }
        });
        this.dispatchEvent(successEvent);
        //console.log('End of Screen');
    }

    handleImportCandidate() {
        this.showImportCandidateScreen = true;
        this.showOptionScreen = false;
        this.showManualCandidateScreen = false;
        const successEvent = new CustomEvent("screen", {
            detail: { screenName: 'bulkUpload' }
        });
        this.dispatchEvent(successEvent);
    }

    @api resetScreen() {
        this.showImportCandidateScreen = false;
        this.showOptionScreen = true;
    }

    validateColumns(errorMessage) {
        var result = true;
        let rowDataHeader = new Set();
        this.csvData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowDataHeader.add(key);
            });
        });

        //row header from file
        rowDataHeader = Array.from(rowDataHeader);

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

        /*this.dropDownValuesList.forEach(item => {
            //console.log('row: ', row[item.key]);     
        });*/

        this.csvData.every((row, index) => {
            lineNo = index + 2;
            if (!result) {
                return result;
            }
            if (row.hasOwnProperty('Category')) {
                if (lineNo == 2 && (row["Category"] && row["Category"] != 'Self')) {
                    errorOccur = true; result = false;
                    errorMessage = errorMessage + "Line " + lineNo + ": Category should be Self.";
                    return result;
                }
                if (this.ignoreCategoryDataCase(row)) {
                    errorOccur = true; result = false;
                    errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in Category column.";
                    return result;
                }
                if (!row["Category"]) {
                    errorOccur = true; result = false;
                    errorMessage = errorMessage + "Line " + lineNo + ": Required Field: Category is blank.";
                    return result;
                }
            }
        this.candidateData.every(element => {
            if (((!row.hasOwnProperty('Category'))
            || (row.hasOwnProperty('Category') && row["Category"] == 'Self')
            || (element.hideDelete && row.hasOwnProperty('Category') && row["Category"] != 'Self'))
            && (row[element.Label__c] == null || row[element.Label__c] == "" || row[element.Label__c] == 'undefined')) {
                errorOccur = true; result = false;
                errorMessage = errorMessage + "Line " + lineNo + ": Required Field: " + element.Label__c + " is blank.";
                return result;
            }

            if (row[element.Label__c] !== null && row[element.Label__c] !== "" && row[element.Label__c] !== 'undefined') {
                if (element.Data_Type__c == 'DropDown') {
                    let rowValue = row[element.Label__c].toUpperCase();
                    let valueList = element.Values__c.toUpperCase();
                    if (!valueList.includes(rowValue)) {
                        errorOccur = true; result = false;
                        errorMessage = errorMessage + "Line " + lineNo + ": Bad Value in " + element.Label__c + " column.";
                        return result;
                    }
                }
                if (element.Data_Type__c == 'email') {
                    let emailValue = row[element.Label__c];
                    const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,63}))$/;
                    //const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,63}$/;
                    if (!emailValue.match(emailRegex)) {
                        errorOccur = true; result = false;
                        errorMessage = errorMessage + "Line " + lineNo + ": Invalid Email Address";
                        return result;
                    }
                }
            }
            return true;
        });
        return true;
        });

        this.errorMessage = errorMessage;
        //console.log('this.errorMessage: ', this.errorMessage);
        //console.log('result: ', result);
        return result;
    }

    handleDownloadTemplate() {
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
        downloadElement.download = 'CandidateUploadTemplate.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
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

    getMapKey(mapArray, value) {
        return [...mapArray.entries()].filter(({ 1: v }) => v === value).map(([k]) => k);

    }
}