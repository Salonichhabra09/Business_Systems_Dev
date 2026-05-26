import { LightningElement, api, wire, track } from 'lwc';
//import getOppAndJobDetails from '@salesforce/apex/CustomerRequestController.getOppAndJobDetails';
//import createGCSCOpp from '@salesforce/apex/CustomerRequestController.createGCSCOpp';
//import getProductDetails from '@salesforce/apex/CustomerRequestController.getProductDetails';
import createSubmitRequest from '@salesforce/apex/CustomerRequestController.createSubmitRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import ImageName_FIELD from "@salesforce/schema/Account.Company_Logo_Name__c";
import ACCOUNTID_FIELD from "@salesforce/schema/Work_Request__c.Account__c";
import SYSTEM_FIELD from "@salesforce/schema/Work_Request__c.System_Used__c";
import TEXT_UNDER_LOGO_FIELD from "@salesforce/schema/Work_Request__c.Text_Under_Logo__c";
import CANDIDATE_FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Candidate_Field_Configuration__c';
import FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Field_Configuration__c';
import RECORDTYPE_FIELD from '@salesforce/schema/Work_Request__c.RecordType.Name';
import CLIENT_NAME from '@salesforce/schema/Work_Request__c.WRF_Client_Name__c';
import ISACTIVE from '@salesforce/schema/Work_Request__c.Is_Active__c';
import JOBID from '@salesforce/schema/Work_Request__c.Job_Id_System_Used__c';
import MAX_CANDIDATE_COUNT_JOB from '@salesforce/schema/Job__c.Solution_Cap__c';
import CANDIDATES_UPLOADED from '@salesforce/schema/Job__c.Candidate_Max_Sequence_No_New__c';
import PARTICIPANTS_CREATED from '@salesforce/schema/Job__c.Number_of_Participants_New__c';
import IS_REPEATABLE from '@salesforce/schema/Job__c.Account__r.Is_Repeatable_Business__c';
import IS_GCSC from '@salesforce/schema/Job__c.Is_GCSC_Opp__c';
import WRF_Footer from '@salesforce/label/c.WRF_Footer';

//import IMAGES from "@salesforce/resourceUrl/static_images";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getAccountLogo from '@salesforce/apex/CustomerRequestController.relatedFilesWire';
import connectedCallbackApex from '@salesforce/apex/CustomerRequestController.connectedCallbackApex';
import WRF_Client_Banner from '@salesforce/resourceUrl/WRF_Client_Banner'; // Replace 'myImage' with your static resource name



//const fields = [CompanyLogo_FIELD];

export default class CrfClientForm extends LightningElement {
    label = {
        WRF_Footer
    };

    imageUrl = WRF_Client_Banner; // Testing image for Banner
    heading = 'Work Request Form';
    @api RN;
    @track record = { "reportsPermission": [], "ufcReport": '' };
    @track customFields = [];
    @track productDetails = [];
    accountId;
    textUnderLogo;
    data;
    error;
    listOfCandidates = [];
    candidates;
    isCRF = true; //changed by aashi
    isAuthenticationUI = true; //changed by aashi
    isSubmitUI = false;
    showSpinner = false;
    isDynamicForm = true;
    isStaticForm = false;
    successMessage = '';
    showCandidateScreen = false;//aashi
    AccountLogo;
    showSubmit = false;
    uploadFileId;
    rowHeaderToImport = [];
    candidateData;
    documentName;
    bulkScreen = false;
    showManualCandidateScreen = false;
    disableSubmit = false;
    nameFromAuthentication;
    emailFromAuthentication;
    candidateRequestedCount;
    readonlyMode = true;
    wrfClientName;
    isActive = true;
    jobId;
    maxCandidateCount;
    candidatesUploaded;
    participantCreated;
    limitReached = false;
    isRepeatable;
    candidatesToInsert;
    candidatesToPass;
    candidateRequestType;
    isGCSC;
    participantRequestedCount;
    deadlineDate;
    currentYear = new Date().getFullYear(); //added by Ravi to show current copyright year on page footer


    disconnectedCallback() {
        // Remove the event listener for the beforeunload event
        window.removeEventListener('beforeunload', this.handleBeforeUnload);
    }

    handleBeforeUnload(event) {
        // Custom message shown in confirmation dialog
        //console.log('Flag Value '+this.isSubmitUI)
        if (!this.isSubmitUI) {
            const confirmationMessage = 'Are you sure you want to leave? Any unsaved changes will be lost.';
            event.preventDefault();
            // Setting the returnValue property is required for some browsers
            event.returnValue = confirmationMessage;
            return confirmationMessage;
        }
    }

    //logoUrl = '/sfc/servlet.shepherd/version/download/069Pu00000A0qp0IAB';
    logoUrl = '/sfc/servlet.shepherd/version/download/069Pu000009yr7XIAQ';
    //https://shl--findev.sandbox.lightning.force.com/lightning/r/ContentDocument/069Pu000009yr7XIAQ/view
    get optionsCombobox() {
        return [
            { label: 'Candidate', value: 'Candidate' },
            { label: 'Manager', value: 'Manager' }
        ];
    }

    get optionsCheckbox() {
        return [
            { label: 'UFC Feedback Report', value: 'UFC Feedback Report' },
            { label: 'UFC Report with Development Tips', value: 'UFC Report with Development Tips' }
        ];
    }

    get numberOfCandidates() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' },
            { label: '6', value: '6' },
            { label: '7', value: '7' },
            { label: '8', value: '8' },
            { label: '9', value: '9' },
            { label: '10', value: '10' },];
    }

    get todaysDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '/' + mm + '/' + dd;
        return today
    }

    get progressWidth() {
        let progress = (this.participantCreated / this.maxCandidateCount) * 100;
        let style = 'width:' + progress + '%';
        return style;
    }

    @wire(getRecord, {
        recordId: "$RN",
        fields: [ACCOUNTID_FIELD, SYSTEM_FIELD, TEXT_UNDER_LOGO_FIELD, CANDIDATE_FIELD_CONFIGURATION, FIELD_CONFIGURATION, RECORDTYPE_FIELD, CLIENT_NAME, ISACTIVE, JOBID],
    })
    workRequest({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            //console.log('WIRE ID ' + getFieldValue(data, ACCOUNTID_FIELD));
            //console.log('Record type ' + getFieldValue(data, RECORDTYPE_FIELD));
            //console.log('Is Active ' + getFieldValue(data, ISACTIVE));
            //console.log('Generated Job Id ' + getFieldValue(data, JOBID));
            this.jobId = getFieldValue(data, JOBID);
            this.isActive = getFieldValue(data, ISACTIVE);
            if (getFieldValue(data, RECORDTYPE_FIELD) != 'Submitted') {
                this.readonlyMode = false;
            }
            this.customFields = JSON.parse(getFieldValue(data, FIELD_CONFIGURATION));
            //console.log('this.formData: ', JSON.stringify(this.customFields));
            this.accountId = getFieldValue(data, ACCOUNTID_FIELD);
            this.textUnderLogo = getFieldValue(data, TEXT_UNDER_LOGO_FIELD);
            this.wrfClientName = getFieldValue(data, CLIENT_NAME);
            //console.log('this.wrfClientName: ', this.wrfClientName);
            this.candidateData = JSON.parse(getFieldValue(data, CANDIDATE_FIELD_CONFIGURATION));

            //this.handleVisibility();
            //console.log('this.candidateData: ', JSON.stringify(this.candidateData));

            this.customFields.forEach(element => {
                if (element.fieldtype == 'date') {
                    element.isDate = true;
                }
            });

            let templateHeader = [];
            this.candidateData.forEach(element => {
                templateHeader.push(element.Label__c);
            });

            this.rowHeaderToImport = [...templateHeader];
            //console.log('this.templateHeader: ', JSON.stringify(this.rowHeaderToImport));
        }
    }

    @wire(getAccountLogo, { evaluatorId: '$accountId' })
    idPhotoDetails({ data, error }) {
        if (data) {
            this.AccountLogo = data;
        } else if (error) {
        }
    }

    @wire(getRecord, {
        recordId: '$jobId',
        fields: [MAX_CANDIDATE_COUNT_JOB, CANDIDATES_UPLOADED, IS_REPEATABLE, IS_GCSC, PARTICIPANTS_CREATED],
    })
    workRequestGenerated({ error, data }) {
        if (error) {
            //console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            //console.log('MAX Candidate Count formula ' + getFieldValue(data, MAX_CANDIDATE_COUNT_JOB));
            //console.log('Candidates Uploaded ' + getFieldValue(data, CANDIDATES_UPLOADED));
            //console.log('Is Repeatable ' + getFieldValue(data, IS_REPEATABLE));
            this.maxCandidateCount = getFieldValue(data, MAX_CANDIDATE_COUNT_JOB);
            this.candidatesUploaded = getFieldValue(data, CANDIDATES_UPLOADED);
            this.participantCreated = getFieldValue(data, PARTICIPANTS_CREATED);
            this.isRepeatable = getFieldValue(data, IS_REPEATABLE);
            this.isGCSC = getFieldValue(data, IS_GCSC);
            if (this.participantCreated >= this.maxCandidateCount) {
                this.limitReached = true;
            }
            if (this.isGCSC)
                this.limitReached = false;
        }
    }



    /*@wire(getOppAndJobDetails, {
        recordId: "$recordId"
    })
    wiredJobDetails({ error, data }) {
        if (error) {
            //console.log('error ' + JSON.stringify(error));
        } else if (data) {
            //console.log('Data recieved ' + JSON.stringify(data));
            this.jobId = data.jobData.Id;
            //console.log('this.jobId: ', this.jobId);
        }
    } */

    /*@wire(getCustomerRequest, {
        recordId: "$recordId"
    })
    wiredGetDetails(result) {
        this.wiredAccountResults = result;
        if (result.data) {

            this.customFields = JSON.parse(JSON.stringify(JSON.parse(result.data)));
            this.record = JSON.parse(result.data);
            this.isDynamicForm = (this.record.formType && this.record.formType == 'Static') ? false : true;
            this.isStaticForm = (this.record.formType && this.record.formType == 'Static') ? true : false;
            //console.log('Data recieved ' + JSON.stringify(this.customFields));
        }
        else if (result.error) {
            this.error = result.error;
            //console.log('this.error ' + JSON.stringify(this.error));
        }
    } */

    companyLogo;
    /*@wire(getAccountLogo, { AccountId: '001Pu000006UTItIAO' })
    loadFields({ error, data }) {
        if (error) {
            //console.log('error ' + JSON.stringify(error));
        } else if (data) {
            const logoName = getFieldValue(data, CompanyLogo_FIELD);
            this.companyLogo = '<p><img src="https://shl--findev.sandbox.my.site.com/servlet/rtaImage?eid=001Pu000006UTIt&amp;feoid=00NPu000000qPn7&amp;refid=0EMPu0000004DJd" alt="Test.jpg"></img></p>';
            //console.log('LOGO ' + this.companyLogo);
        }
    } */


    /* @wire(getProductDetails, {
         recordId: "$recordId"
     })
     wiredGetProductDetails(result) {
         if (result.data) {
             //this.record = JSON.parse(result.data);
             this.productDetails = JSON.parse(JSON.stringify(JSON.parse(result.data)));
             //console.log('Products recieved ' + this.productDetails);
         }
         else if (result.error) {
             this.error = result.error;
             //console.log('this.error ' + JSON.stringify(this.error));
         }
     } */



    setNumberOfCandidates(event) {
        let num = parseInt(event.target.value);
        this.candidates = event.target.value;
        //console.log(this.candidates);
        let listOfCan = [];
        for (let index = 0; index < num; index++) {
            let candidateObject = {};
            if (listOfCan.length > 0) {
                candidateObject.index = listOfCan[listOfCan.length - 1].index + 1;
            } else {
                candidateObject.index = 1;
            }
            candidateObject.Name = null;
            candidateObject.Email = null;
            candidateObject.Phone = null;
            listOfCan.push(candidateObject);
        }
        this.listOfCandidates = listOfCan;
        //console.log(this.listOfCandidates);
    }

    handleInputChange(event) {
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;
        for (let i = 0; i < this.listOfCandidates.length; i++) {
            if (this.listOfCandidates[i].index === parseInt(index)) {
                this.listOfCandidates[i][fieldName] = value;
            }
        }
    }

    handleDynamicInputChange(event) {
        let index = event.target.dataset.id;
        let value = event.target.value;
        for (let i = 0; i < this.customFields.length; i++) {
            //console.log("index " + index);
            if (this.customFields[i].index__c === parseInt(index)) {
                this.customFields[i].value = value;
                //console.log("Value " + this.customFields[i].value);
            }
        }

    }

    handlePDF() {
        window.print();
    }

    handleVisibility(event) {
        //console.log('Message from child component ' + event.detail);
        if (event.detail.status == 'Success') {
            this.nameFromAuthentication = event.detail.name;
            this.emailFromAuthentication = event.detail.email;
            this.isCRF = true;
            this.isDynamicForm = true;
            this.isAuthenticationUI = false;
            this.customFields.forEach(element => {
                if (element.isMandatory) {
                    if (element.fieldLabel == 'Requester Name')
                        element.value = this.nameFromAuthentication;
                    if (element.fieldLabel == 'Requester Email')
                        element.value = this.emailFromAuthentication;
                }
            })
        }
    }

    handleCandidateExportAction(event) {
        this.isCRF = true;
        this.showSpinner = false;
    }

    handleCandidateDetails(event) {
        this.uploadFileId = event.detail.contentVersionId;
        //console.log('this.uploadFileId: ', this.uploadFileId);
        this.candidateRequestType = 'File';
        this.documentName = event.detail.documentName;
        if (this.uploadFileId == null) {
            this.showSubmit = false;
        } else {
            this.showSubmit = true;
        }
    }

    handleNext(event) {
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
            this.showCandidateScreen = true;
            this.isCRF = false;
        }

    }

    handleSubmit(event) {
        //console.log('this.uploadFileId: ', this.uploadFileId);
        //console.log('this.candidateRequestedCount: ', this.candidateRequestedCount);
        this.disableSubmit = true;
        this.showSpinner = true;
        this.customFields.forEach(element => {
            console.log('element: ', element);
            if (element.fieldLabel === 'Deadline Date') {
                this.deadlineDate = element.value;
                console.log('this.deadlineDate: ', this.deadlineDate);
            }
        });
        debugger;
        createSubmitRequest({
            formDetails: JSON.stringify(this.customFields), recordId: this.RN,
            candidateDetails: this.uploadFileId, candidateRequestedCount: this.candidateRequestedCount,
            RequestorName: this.nameFromAuthentication, RequestorEmail: this.emailFromAuthentication,
            candidateDataToInsert: JSON.stringify(this.candidatesToInsert),
            candidateRequestType: this.candidateRequestType, participantRequestedCount: this.participantRequestedCount,
            deadlineDate: this.deadlineDate
        }).then(Response => {
            if (Response != 'error') {
                this.successMessage = 'Your request has been submitted. Please save your reference number ' + Response + ' for future reference.';
                this.isCRF = false;
                this.isSubmitUI = true;
                this.showCandidateScreen = false;
                /* let message = 'Account Manager has been informed with your provided data.';
                 const event = new ShowToastEvent({
                     title: 'Account Manager Informed',
                     message: message,
                     variant: 'success'
                 });
                 this.dispatchEvent(event);*/
                this.showSpinner = false;
            } else {
                this.disableSubmit = false;
                //console.log(error);
                //console.log(JSON.stringify(error));
                const errorMessage = error.body.message;
                const duplicateErrorIndex = errorMessage.indexOf('DUPLICATE_VALUE');
                let trimmedMessage = errorMessage;  // Default in case the duplicate error is not found
                if (duplicateErrorIndex !== -1) {
                    // Extract the message starting from 'DUPLICATE_VALUE'
                    trimmedMessage = errorMessage.substring(duplicateErrorIndex);
                }
                //let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: trimmedMessage,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.showSpinner = false;
            }
        }).catch(error => {
            this.disableSubmit = false;
            //console.log(error);
            //console.log(JSON.stringify(error));
            const errorMessage = error.body.message;
            const duplicateErrorIndex = errorMessage.indexOf('DUPLICATE_VALUE');
            let trimmedMessage = errorMessage;  // Default in case the duplicate error is not found
            if (duplicateErrorIndex !== -1) {
                // Extract the message starting from 'DUPLICATE_VALUE'
                trimmedMessage = errorMessage.substring(duplicateErrorIndex);
            }

            //let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
            const event = new ShowToastEvent({
                title: 'Error!',
                message: trimmedMessage,
                variant: 'error'
            });
            this.dispatchEvent(event);
            this.showSpinner = false;
        });
    }

    handleBack(event) {
        // Do not remove this
        /*if (this.bulkScreen == true) {
            this.showCandidateScreen = true;
            this.isCRF = false;
            this.bulkScreen = false;
            setTimeout(() => {
                let child = this.template.querySelector('c-crf-f-client-file-upload');
                child.resetScreen();
            }, 100);
        } else {*/
        this.isCRF = true;
        this.showCandidateScreen = false;
        this.bulkScreen = false;
        this.showManualCandidateScreen = false;
        //}
    }

    handleCancel(event) {
        this.isAuthenticationUI = true;
        this.isCRF = false;
        this.isDynamicForm = false;
        this.showCandidateScreen = false;
        this.showManualCandidateScreen = false;
    }

    handleInputChange(event) {
        let enteredValue = event.target.value;
        let indexValue = event.target.dataset.index;
        let fieldtype = event.target.type;
        this.customFields.forEach(element => {
            if (element.index == indexValue) {
                if (fieldtype == "checkbox") {
                    element.value = event.target.checked;
                }
                else {
                    element.value = enteredValue;

                }

            }
        })
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

    getScreenInfo(event) {
        if (event.detail.screenName == 'bulkUpload') {
            this.bulkScreen = true;
        }
        if (event.detail.screenName == 'manual') {
            this.bulkScreen = true;
        }
        //console.log('this.bulkScreen: ', this.bulkScreen);
    }

    getCandidateCount(event) {
        this.candidateRequestedCount = event.detail.candidateRequestedCount;
        this.participantRequestedCount = event.detail.participantRequestedCount;
    }

    getCandidateData(event) {
        this.candidatesToPass = event.detail.listOfCandidates;
        this.candidatesToInsert = event.detail.listOfCandidatesToInsert;
        this.candidateRequestType = 'Manual';
        //console.log('this.listOfCandidates: ', JSON.stringify(this.candidatesToInsert));
        //console.log('Candidate count to Insert ' + this.candidatesToInsert.length);
        this.candidateRequestedCount = this.candidatesToInsert.length;
        if (this.candidateRequestType == 'Manual') {
            this.participantRequestedCount = this.candidatesToInsert.length;
        }
        if (this.candidatesToInsert != null) {
            this.showSubmit = true;
        } else {
            this.showSubmit = false;
        }
    }

    connectedCallback() {
        window.addEventListener('beforeunload', this.handleBeforeUnload);
        this.fetchData();
        //console.log(this.currentYear);
    }

    fetchData() {

        connectedCallbackApex({ recordId: this.RN })

            .then(result => {

                this.RN = result;

                //console.log('Data received:', JSON.stringify(result));
                //console.log('recordId decryptId', this.RN);
                //this.workrequestdata();

            })

            .catch(error => {

                this.error = error;

                console.error('Connected call back Error:', JSON.stringify(error));

            });

    }
}