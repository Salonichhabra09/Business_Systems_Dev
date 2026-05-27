import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import JOBID from '@salesforce/schema/Work_Request__c.Job_Id_System_Used__c';
import ACCOUNTID_FIELD from "@salesforce/schema/Work_Request__c.Account__c";
import SYSTEM_FIELD from "@salesforce/schema/Work_Request__c.System_Used__c";
import CANDIDATE_FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Candidate_Field_Configuration__c';
import FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Field_Configuration__c';
import CANDIDATES_UPLOADED from '@salesforce/schema/Job__c.Candidate_Max_Sequence_No_New__c';
import PARTICIPANTS_CREATED from '@salesforce/schema/Job__c.Number_of_Participants_New__c';
import JOB_REGION from '@salesforce/schema/Job__c.Job_Region__c';
import MAX_CANDIDATE_COUNT_JOB from '@salesforce/schema/Job__c.Solution_Cap__c';
import IS_REPEATABLE from '@salesforce/schema/Job__c.Account__r.Is_Repeatable_Business__c';
import IS_GCSC from '@salesforce/schema/Job__c.Is_GCSC_Opp__c';


export default class CreateCandidatesManuallyWRF extends LightningElement {

    @api candidatesListToInsert;
    @api candidateConfig;

    @track candidateData = [];
    @track candidatesListToUse = [];

    @api wrfId;
    jobRegion;
    candidatesUploaded;
    particpantsCreated;
    maxCandidateCount;
    accountId;
    jobId;
    limitReached;
    @track errorMessage = [];
    showErrorMessage = false;
    remainingCandidates;
    isRepeatable = false;
    showSave = true;
    isGCSC;

    getValueData(event) {
        let index = event.target.dataset.index;
        //console.log('index: ', index);
        let fieldAPIName = event.target.dataset.api;
        //console.log('fieldAPIName: ', fieldAPIName);
        let row = event.target.dataset.row;
        //console.log('row: ', row);

        return this.candidatesListToUse[index][fieldAPIName];
    }

    @wire(getRecord, {
        recordId: "$wrfId",
        fields: [ACCOUNTID_FIELD, SYSTEM_FIELD, CANDIDATE_FIELD_CONFIGURATION, FIELD_CONFIGURATION, JOBID],
    })
    workRequest({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            //console.log('Generated Job Id ' + getFieldValue(data, JOBID));
            this.jobId = getFieldValue(data, JOBID);
            this.accountId = getFieldValue(data, ACCOUNTID_FIELD);
            //this.candidateData = JSON.parse(getFieldValue(data, CANDIDATE_FIELD_CONFIGURATION));
        }
    }

    @wire(getRecord, {
        recordId: '$jobId',
        fields: [CANDIDATES_UPLOADED, JOB_REGION, MAX_CANDIDATE_COUNT_JOB, IS_REPEATABLE,IS_GCSC,PARTICIPANTS_CREATED],
    })
    jobData({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            this.candidatesUploaded = getFieldValue(data, CANDIDATES_UPLOADED);
            this.maxCandidateCount = getFieldValue(data, MAX_CANDIDATE_COUNT_JOB);
            this.particpantsCreated = getFieldValue(data,PARTICIPANTS_CREATED);
            //console.log('Candidates Uploaded manual ' + this.candidatesUploaded);
            //console.log('Max Candidate Count manual ' + this.maxCandidateCount);
            //console.log('Participants Created '+this.particpantsCreated);
            this.jobRegion = getFieldValue(data, JOB_REGION);
            this.isRepeatable = getFieldValue(data, IS_REPEATABLE);
            this.isGCSC = getFieldValue(data, IS_GCSC);
            //console.log('Is GCSC '+this.isGCSC);
            this.remainingCandidates = (this.maxCandidateCount == null ? 0 : this.maxCandidateCount) - (this.particpantsCreated == null ? 0 : this.particpantsCreated);
        }
    }

    connectedCallback() {
        if (this.candidateConfig) {
            //console.log('Inside iF');
            this.candidateData = JSON.parse(JSON.stringify(this.candidateConfig));
        }
        if (this.candidatesListToInsert) {
            this.candidatesListToUse = JSON.parse(JSON.stringify(this.candidatesListToInsert));
        }
        this.initData();
    }

    initData() {
        let candidatesListToUse = [];
        this.createRow(candidatesListToUse);
        this.candidatesListToUse = candidatesListToUse;
    }

    getInputValue(item) {
        const newKey = item.API_Name__c;
        var returnValue;

        if (this.candidatesListToUse) {
            const matchedElement = this.candidatesListToUse.find((element, index) => {
                if (element.hasOwnProperty(newKey) && element[newKey] !== null && item.hasOwnProperty('value')) {
                    //console.log(`Updating item.value from ${item.value} to ${element[newKey]}`);
                    return true;
                }
                return false;
            });
            //console.log('matchedElement[newKey]: ', matchedElement[newKey]);
            returnValue = matchedElement[newKey];
        }
        return returnValue;
    }

    getOptionsValues(element) {
        let arrayMap;
        if (element.Values__c != "undefined" && element.Values__c != null) {
            let temparray = element.Values__c.split(',');
            arrayMap = temparray.map(function (eachfield) {
                return { label: eachfield, value: eachfield }
            });
        }
        return arrayMap;
    }

    createRow(candidatesListToUse) {
        let accountObject = {};
        this.showSave = true;
        this.candidateData.forEach(item => {
            const newKey = item.API_Name__c;
            if (!accountObject.hasOwnProperty(newKey)) {
                accountObject[newKey] = null;
            }
            if (item.hasOwnProperty("value") && item.value === "undefined") {
                item.value = null;
            }
            if (item.hasOwnProperty('Values__c') && item.Values__c != null) {
                item.options = this.getOptionsValues(item);
            }
        });
        /*
        this.candidateData = this.candidateData.map(item => {
            return {
                ...item,
                value: item.value === "undefined" ? null : item.value,
            };
        });

        this.candidateData = this.candidateData.map(item => {
            return {
                ...item,
                options: item.options == "undefined" ? item.options : this.getOptionsValues(item),
            };
        });
        */
        if (this.candidatesListToUse != null) {
            this.candidatesListToUse.forEach((element, index) => {
                if (!element.hasOwnProperty("index")) {
                    element["index"] = index + 1;
                }
            });
        }

        if (candidatesListToUse.length > 0) {
            accountObject.index = candidatesListToUse[candidatesListToUse.length - 1].index + 1;
        } else {
            accountObject.index = 1;
        }

        if (!accountObject.hasOwnProperty("columnJson")) {
            accountObject["columnJson"] = this.candidateData;
        }
        //console.log('accountObject after: ', JSON.stringify(accountObject));
        candidatesListToUse.push(accountObject);
        //console.log('candidatesListToUse: after push ', JSON.stringify(this.candidatesListToUse));
    }

    addNewRow() {
        //console.log(('remaining candidates '+this.remainingCandidates));
        ////console.log('Candidate list count '+this.this.candidatesListToUse.length);
        
        if (!this.isGCSC) {
            if (this.candidatesListToUse.length < this.remainingCandidates) {
                this.createRow(this.candidatesListToUse);
            }
            else {
                //console.log('Limit Reached ' + this.remainingCandidates);
                this.limitReached = true;
            }
        }
        else {
            this.createRow(this.candidatesListToUse);
        }

    }

    removeRow(event) {
        if (this.limitReached) {
            this.limitReached = false;
        }
        let toBeDeletedRowIndex = event.target.name;
        //console.log('toBeDeletedRowIndex: ', toBeDeletedRowIndex);
        this.candidatesListToUse.splice(toBeDeletedRowIndex - 1, 1);
        if (this.candidatesListToUse != null) {
            this.candidatesListToUse.forEach((element, index) => {
                element.index = index + 1;
            });
        } else {
            this.showSave = false;
        }
        //console.log('this.candidatesListToUse: ', JSON.stringify(this.candidatesListToUse));
    }

    removeAllRows() {
        this.limitReached = false;
        this.candidatesListToUse = [];
        this.candidatesListToUse = candidatesListToUse;
        this.showSave = false;
        //this.createRow(this.candidatesListToUse);
    }

    handleInputChange(event) {
        let indexValue = event.target.dataset.index;
        //console.log('indexValue: ', indexValue);
        let fieldAPIName = event.target.dataset.api;
        //console.log('fieldAPIName: ', fieldAPIName);
        let value1 = event.target.value;
        //console.log('value1: ', value1);
        let valueToUse;
        this.candidatesListToUse.forEach((element) => {
            if (element.index == indexValue) {
                if (event.target.type == "checkbox") {
                    element[fieldAPIName] = event.target.checked;
                    valueToUse = event.target.checked;
                } else {
                    element[fieldAPIName] = value1;
                    valueToUse = value1;
                }
                element.columnJson = element.columnJson.map((item) => {
                    return {
                        ...item,
                        valueData: item.API_Name__c == fieldAPIName ? valueToUse : item.valueData
                    };
                });
            }
        });

        //console.log('Value put this.candidatesListToUse: ', JSON.stringify(this.candidatesListToUse));
    }

    createCandidates() {

        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Candidate Details are saved successfully. Please click Submit button to submit the Request Form.',
            variant: 'success'
        });
        this.dispatchEvent(event);

        let candidatesToInsert = [];
        this.candidatesListToUse.forEach(item => {
            item["Job_Region__c"] = this.jobRegion;
            item["Candidate_Unique_Id__c"] = this.jobId + item.First_Name__c + item.Last_Name__c + item.Email__c;
        });

        candidatesToInsert = JSON.parse(JSON.stringify(this.candidatesListToUse));

        candidatesToInsert.forEach(item => {
            delete item.index;
            delete item.columnJson;
        });

        //console.log('candidatesToInsert: ', JSON.stringify(candidatesToInsert));
        //console.log('candidatesListToUse: save  ', JSON.stringify(this.candidatesListToUse));

        let errorMessage = '';
        this.errorMessage = [];
        //var result = this.validateData(errorMessage, candidatesToInsert);
        //var result = this.validateData();
        let result = true;
        var validateDataFlag = this.validateData();
        if (validateDataFlag) {
            //console.log('validateDataFlag: ', validateDataFlag);
            var isDuplicate = this.hasDuplicate(candidatesToInsert, "Candidate_Unique_Id__c");
            //console.log('isDuplicate: ', isDuplicate);
            result = isDuplicate;
        } else {
            result = validateDataFlag;
        }
        //console.log('result: ', result);

        //If any error found show error message
        if (!result) {
            this.showErrorMessage = true;
        }
        //If no error
        else {
            this.errorMessage = [];
            this.showErrorMessage = false;
            const submitEvent = new CustomEvent('create', {
                bubbles: true,
                composed: true,
                detail: {
                    listOfCandidates: this.candidatesListToUse,
                    listOfCandidatesToInsert: candidatesToInsert
                }
            });
            // Fire the custom event
            this.dispatchEvent(submitEvent);
        }

        /*if (this.candidatesListToUse != null) {
            this.candidatesListToUse.forEach((element, index) => {
                element["index"] = index + 1;
            });
        }*/
        //console.log('After candidatesListToUse ', JSON.stringify(this.candidatesListToUse));
    }

    validateData() {
        //console.log('Update Form ' + JSON.stringify(this.customFields));
        let inputFieldIsValid = true;
        let textareaFieldIsValid = true;
        let comboboxFieldIsValid = true;
        let checkboxgroupFieldIsValid = true;
        let radioboxgroupFieldIsValid = true;

        let inputfields = this.template.querySelectorAll('lightning-input');
        inputfields.forEach(field => {
            //console.log('Validity input field ', field.type, " ", field.checkValidity());
            if (!field.checkValidity()) {
                field.reportValidity();
                inputFieldIsValid = false;
            }
        });
        let textareafields = this.template.querySelectorAll('lightning-textarea');
        textareafields.forEach(field => {
            //console.log('Validity input field ', field.type, " ", field.checkValidity());
            if (!field.checkValidity()) {
                field.reportValidity();
                textareaFieldIsValid = false;
            }
        });
        let combocboxfields = this.template.querySelectorAll('lightning-combobox');
        combocboxfields.forEach(field => {
            //console.log('Validity input field ', field.type, " ", field.checkValidity());
            if (!field.checkValidity()) {
                field.reportValidity();
                comboboxFieldIsValid = false;
            }
        });
        let checkboxgroupfields = this.template.querySelectorAll('lightning-checkbox-group');
        checkboxgroupfields.forEach(field => {
            //console.log('Validity input field ', field.type, " ", field.checkValidity());
            if (!field.checkValidity()) {
                field.reportValidity();
                checkboxgroupFieldIsValid = false;
            }
        });
        let radiogroupfields = this.template.querySelectorAll('lightning-radio-group');
        radiogroupfields.forEach(field => {
            //console.log('Validity input field ', field.type, " ", field.checkValidity());
            if (!field.checkValidity()) {
                field.reportValidity();
                radioboxgroupFieldIsValid = false;
            }
        });
        if (inputFieldIsValid && textareaFieldIsValid && comboboxFieldIsValid && checkboxgroupFieldIsValid && radioboxgroupFieldIsValid) {
            return true;
        }
        return false;
    }


    validateDataTemp(errorMessage, candidatesToInsert) {
        var result = true;
        let lineNo;

        candidatesToInsert.forEach((row, index) => {
            lineNo = index + 1;
            this.candidateData.forEach(element => {
                if (!row[element.API_Name__c]) {
                    result = false;
                    errorMessage = "Line " + lineNo + ": Required Field: " + element.Label__c + " is blank." + "\n";
                    this.errorMessage.push(errorMessage);
                } else {
                    if (element.Data_Type__c == 'email') {
                        let emailValue = row[element.API_Name__c];
                        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                        if (!emailValue.match(emailRegex)) {
                            result = false;
                            errorMessage = "Line " + lineNo + ": Invalid Email Address\n";
                            this.errorMessage.push(errorMessage);
                        }
                    }
                }
            });
        });
        return result;
    }

    hasDuplicate(array, colName) {
        let errorMessage = '';
        const uniqueItems = new Set();
        let flag = true;
        array.every(element => {
            if (uniqueItems.has(element[colName])) {
                errorMessage = "Duplicate rows found!!!\n";
                flag = false;
                return flag;
            } else {
                uniqueItems.add(element[colName]);
            }
            return true;
        });
        this.errorMessage.push(errorMessage);
        return flag;
    }
}