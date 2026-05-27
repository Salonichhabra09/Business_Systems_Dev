import { LightningElement, track, api , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CANDIDATE_OBJECT from '@salesforce/schema/Bureau_Candidate__c';
import JOB_FIELD from '@salesforce/schema/Bureau_Candidate__c.Bureau_Job__c';
import FIRST_NAME_FIELD from '@salesforce/schema/Bureau_Candidate__c.First_Name__c';
import LAST_NAME_FIELD from '@salesforce/schema/Bureau_Candidate__c.Last_Name__c';
import EMAIL_FIELD from '@salesforce/schema/Bureau_Candidate__c.Email__c';
import Phone_Number from '@salesforce/schema/Bureau_Candidate__c.Phone_Number__c';
import GENDER_FIELD from '@salesforce/schema/Bureau_Candidate__c.Gender__c';
import COUNTRY_FIELD from '@salesforce/schema/Bureau_Candidate__c.Country__c';
import LANGUAGE_FIELD from '@salesforce/schema/Bureau_Candidate__c.Language__c';
import REPORT_STATUS_FIELD from '@salesforce/schema/Bureau_Candidate__c.Reports_Status__c';
import Status_Field from '@salesforce/schema/Bureau_Candidate__c.Status2__c';
import Username_FIELD from '@salesforce/schema/Bureau_Candidate__c.Username__c';
import ProductAssessment_FIELD from '@salesforce/schema/Bureau_Candidate__c.Product_Assessment__c';
import System_FIELD from '@salesforce/schema/Bureau_Candidate__c.System_s__c';
import ID_FIELD from '@salesforce/schema/Bureau_Candidate__c.Id';
import NAME_FIELD from '@salesforce/schema/Bureau_Candidate__c.Name';
import getCandidateData from '@salesforce/apex/MsCandidateDataTableController.getCandidateData';
import LightningConfirm from "lightning/confirm";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Talent_Management_LOB_Status from '@salesforce/label/c.Talent_Management_LOB_Status';
import TA_Corporate_and_TA_Vocational_LOB_Status from '@salesforce/label/c.TA_Corporate_and_TA_Vocational_LOB_Status';
import deleteCandidateRecord from '@salesforce/apex/MsCandidateDataTableController.deleteCandidateRecord';
import updateCandidateRecord from '@salesforce/apex/MsCandidateDataTableController.updateCandidateRecord';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';
const FIELDS = ['Job__c.MS_Line_of_Business__c']

const actions = [
    { label: 'Edit', name: 'edit_details' },
    { label: 'Delete', name: 'delete' },
];

const columns = [
    {
        label: 'S.No.', fieldName: 'serialNumber', type: 'number', fixedWidth : 75,
        cellAttributes: {
            alignment: 'center',
        }
    },
    {
        label: 'Candidate Id', fieldName: 'candidateRecord', type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    { label: 'First Name', fieldName: 'First_Name__c' },
    { label: 'Last Name', fieldName: 'Last_Name__c' },
    { label: 'Email ', fieldName: 'Email__c' },
    { label: 'Phone Number ', fieldName: 'Phone_Number__c' },
    { label: 'Gender', fieldName: 'Gender__c' },
    { label: 'Language', fieldName: 'Language__c' },
    { label: 'Country', fieldName: 'Country__c' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Report Status', fieldName: 'Reports_Status__c' },
    { label: 'User Name', fieldName: 'Username_New__c' },
    { label: 'Product/Assessment', fieldName: 'Product_Assessment__c' },
    { label: 'System(s)', fieldName: 'System_s__c' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class MsCandidateDataTable extends LightningElement {
    @api recordId;
    @track showCandidateValue = false;
    @track data = [];
    @track showLoadingSpinner = false;
    @track dataCount;
    @track candidateRecordId;
    @track createNewCandidate = false;
    @track showCandidateScreen = true;
    @track loadMoreStatus;
    lobValue = 'TA';
    statusOptions = [];
    status;
    showButtonPanel=true;
    

    candidateFilterValue;
    tableColumns = columns;
    tableElement;
    maxRows = 1000;
    candidateObject = CANDIDATE_OBJECT;
    jobField = JOB_FIELD;
    firstNameField = FIRST_NAME_FIELD;
    lastNameField = LAST_NAME_FIELD;
    emailField = EMAIL_FIELD;
    genderField = GENDER_FIELD;
    countryField = COUNTRY_FIELD;
    languageField = LANGUAGE_FIELD;
    reportStatusField = REPORT_STATUS_FIELD;
    candidateIdField = ID_FIELD;
    nameField = NAME_FIELD;
    statusField=Status_Field;
    usernameField=Username_FIELD;
    productAssessmentField=ProductAssessment_FIELD;
    systemField=System_FIELD;
    PhoneNumber= Phone_Number;


    connectedCallback() {
        this.showAllCandidates();
    }

    handleJobNameChange() {
    }

    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        let userProfileName;
        if (data) { 
            if (data.fields.Profile.displayValue != null) {
                userProfileName = data.fields.Profile.displayValue;
                console.log('1. this.superUser ###'+userProfileName);
               if(userProfileName != 'Managed Service Lightning' && userProfileName != 'System Administrator'){
                    this.showButtonPanel =false;
                }
            }
        }
    }

    handleSubmit(event) {
        console.log('Handle submit status value ###'+this.status)
        event.preventDefault();
        // Get data from submitted form
        const fields = event.detail.fields;
        fields.Status2__c = this.status;
        console.log('test*'+JSON.stringify(fields));
        updateCandidateRecord({
        jobId : this.recordId,
        candidateRec : fields,
        candidateId : this.candidateRecordId
        })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated successfully',
                    variant: 'success'
                })
            );
            this.getCandidateData();
            this.closeModal();
        }).catch(error => {
            console.log('error ====> ', error);
            const evt = new ShowToastEvent({
                title: '',
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        })
    }

    handleStatusChange(event) {
        this.status = event.target.value;
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    jobRecord({ data, error }) {
        if(data) {
            this.lobValue = data.fields.MS_Line_of_Business__c.value;
            this.setStatusValue();
        }
    }       

        setStatusValue() {
            
            let talentManagement = Talent_Management_LOB_Status.split(',');
            let TATM = TA_Corporate_and_TA_Vocational_LOB_Status.split(',');
            let tempStatus = [];
            
            if(this.lobValue.includes('TA - Vocational')) {
                for(let i=0; i<TATM.length; i++) {
                    tempStatus.push({label:TATM[i], value:TATM[i]});
                }
            }
            else {
                for(let i=0; i<talentManagement.length; i++) {
                    tempStatus.push({label:talentManagement[i], value:talentManagement[i]});
                }
            }

            this.statusOptions = [...tempStatus];

            console.log('2. Status Option implemented #####'+JSON.stringify(this.statusOptions))
        }

        onStatusChange(event) {
            this.status = event.target.value;
        }

    getCandidateData() {
        console.log('this.recordId: ', this.recordId);
        getCandidateData({ jobId: this.recordId, offSetValue: 0, filterValue: this.candidateFilterValue })
            .then(result => {
                this.showLoadingSpinner = false;
                console.log('result ====> ' + JSON.stringify(result));
                var tempData = [];
                tempData = result;
                let tempRecords = JSON.parse(JSON.stringify(result));
                tempRecords = tempRecords.map((row,index) => {
                    return {
                        ...row,
                        candidateRecord: (row ? ('/lightning/r/Bureau_Candidate__c/' + row.Id+'/view') : null),
                        serialNumber: index + 1,
                        };
                })
                console.log('tempRecords ====> ' + JSON.stringify(tempRecords));
                this.data = tempRecords;
                this.dataCount = this.data.length;
                this.jobName = JSON.stringify(tempData[0].Bureau_Job__r.Name);
                if(this.tableElement)
                this.tableElement.enableInfiniteLoading = true;
                this.loadMoreStatus = '';
                console.log('more data to load');
                
            })
            .catch(error => {
                if (this.tableElement && this.data.length >= this.dataCount) {
                    this.tableElement.enableInfiniteLoading = false;
                    this.loadMoreStatus = 'No more data to load';
                }
            });
    }

    handleRowAction(event) {
      if(this.showButtonPanel){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'edit_details':
                this.editRowDetails(row);
                break;
            default:
        }
      }else{
        const evt = new ShowToastEvent({
            title: 'Action Denied',
            message: 'You are not allowed to perform this action.',
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);

      }
    }

    editRowDetails(row) {
        console.log('This is Status value ####'+row.Status__c)
        this.status = row.Status__c;
        console.log('This.Status ###'+this.status)
        this.candidateRecordId = row?.Id;
        this.showLoadingSpinner = true;
        this.showCandidateScreen = false;
        this.createNewCandidate = true;
    }

    closeModal(){
        this.createNewCandidate = false;
        this.showCandidateScreen = true;
    }

    async deleteRow(row){
        const result = await LightningConfirm.open({
            message: "Are you sure you want to delete this record?",
            theme: "warning",
            label: "Confirm Delete"
        });
        if(result == true){
            this.deleteRow1(row);
        }
    }

    deleteRow1(row) {
        let rowIdToDelete = row?.Id;
        deleteCandidateRecord({
            jobId : this.recordId,
            candidateId : rowIdToDelete
        })
            .then(() => {
                const { Id } = row;
                const index = this.findRowIndexById(Id);
                if (index !== -1) {
                    this.data = this.data.slice(0, index).concat(this.data.slice(index + 1));
                }
                const successEvent = new CustomEvent("deletecandidate", {
                    detail: 'success'
                });
                this.dispatchEvent(successEvent);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted successfully',
                        variant: 'success'
                    })
                );
            }).catch(error => {
                console.log('error ====> ', error);
                const evt = new ShowToastEvent({
                    title: '',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            })
    }

    findRowIndexById(Id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.Id === Id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    loadData(event) {
        if (event.target) {
            event.target.isLoading = true;
        }
        this.tableElement = event.target;
        //Display "Loading" when more data is being loaded
        this.loadMoreStatus = 'Loading';
        this.getMoreCandidateData();
    }

    getMoreCandidateData() {
        getCandidateData({ jobId: this.recordId, offSetValue: this.dataCount , filterValue: this.candidateFilterValue})
            .then(result => {
                var tempData = [];
                tempData = result;
                let tempRecords = JSON.parse(JSON.stringify(result));
                let serialNumberCount;
                let serialNumber1;

                serialNumberCount = this.dataCount;
                tempRecords = tempRecords.map((row, index) => {
                    if(index == 0){
                        serialNumber1 = serialNumberCount + 1;
                    }
                    return {
                        ...row,
                        candidateRecord: (row ? ('/lightning/r/Bureau_Candidate__c/' + row.Id+'/view') : null),
                        serialNumber: serialNumber1 + index,
                     };
                })
                this.data = this.data.concat(tempRecords);
                this.dataCount = this.data.length;
                this.loadMoreStatus = '';
                if (this.tableElement) {
                    this.tableElement.isLoading = false;
                }
                this.jobName = JSON.stringify(tempData[0].Bureau_Job__r.Name);
            })
            .catch(error => {
                if (this.tableElement && this.data.length >= this.dataCount) {
                    this.tableElement.enableInfiniteLoading = false;
                    this.loadMoreStatus = 'No more data to load';
                }
            });
    }

    handleRecordLoad(event) {
        this.createNewCandidate = true;
        this.showLoadingSpinner = false;
    }

    // Handle events after save
    handleSingleCandidateCreation() {
        this.createNewCandidate = false;
        this.showCandidateScreen = true;
        // To refresh or reload data table
        this.getCandidateData();
        const evt = new ShowToastEvent({
            title: "Success!",
            message: "Candidate's record has been successfully saved.",
            variant: "success",
        });
        this.dispatchEvent(evt);
    }

    handleCandidateCancel() {
        this.createNewCandidate = false;
        this.showCandidateScreen = true;
    }

    handleCandidateFilterValue(event){
        this.candidateFilterValue = event.detail.value;
    }

    handleEnter(event) {
        console.log('inside search action'+event.keyCode);
        if(event.keyCode === 13){
            this.handleSearchAction();
        }
    }

    handleSearchAction(event) {
        this.getCandidateData();
    }

    @api showAllCandidates(){
        this.candidateFilterValue='';
        this.getCandidateData();
    }
}