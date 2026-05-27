import { LightningElement, track,wire, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';
import SYSTEM_USED_FOR_CANDIDATE from '@salesforce/label/c.System_Used_values_for_Candidates';
import SYSTEM_USED_FOR_SYSTEMS from '@salesforce/label/c.System_Used_values_for_Systems';
import checkButtonVisibility from '@salesforce/apex/CustomerRequestController.checkButtonVisibility';
import ERROR_MESSAGE from '@salesforce/label/c.Error_message_for_invalid_System_Used_for_Candidate';
import handleButtonVisibilityApex from '@salesforce/apex/CandidateUploadContoller.handleButtonVisibilityApex';
import handleCandidateComponentVisibility from '@salesforce/apex/MsCandidateDataTableController.handleCandidateComponentVisibility';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import deleteCandidateList from '@salesforce/apex/MsCandidateDataTableController.deleteCandidateList';

const fields = ['Job__c.System_Used__c', 'Job__c.MS_Line_of_Business__c', 'Job__c.Count_of_Candidates_pass__c', 'Job__c.Count_of_Candidates_fail__c', 'Job__c.Count_of_Candidates_DNA__c', 'Job__c.Count_of_candidates_invited__c', 'Job__c.Actual_Count_of_Candidates__c']
export default class CandidateButtonPanel extends LightningElement {
 
    @api recordId;
    @track showCandidateCreation;
    @track showCandidateImport;
    @track showCandidateList;
    @track showButtonPanel = true;
    @track showExportUpdateBtn = false;
    @track showSpinner = false;

    @track exportCandidateLabel = 'Export Candidates';
    @track importCandidateLabel = 'Import New Candidate List';
    @track updateCandidateLabel = 'Update Candidates';
    systemDataList;
    isShowModal
    lobValue
    showVocational=false;
    pass;
    fail;
    dna;
    invited;
    actual;
    superUser = false;
    systemUsed = false;
    sysAvailable = false;
    systemUsedError = false;
    errorMessage = ERROR_MESSAGE;

    @wire(checkButtonVisibility, { jobId: '$recordId' })
    buttonVisibility({ data, error }) {
        if (data) {
            //console.log('data from apex '+JSON.stringify(data));
            if(data=='false'){
                this.showButtonPanel = false;
            }
        } else if (error) {
            //console.log('error from apex '+JSON.stringify(error));
        }
    }

    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        let userProfileName;
        if (error) {
            this.error = error;
        } else if (data) { 
            //console.log('Data Profile ###'+JSON.stringify(data.fields.Profile.displayValue))
            if (data.fields.Profile.displayValue != null) {
                userProfileName = data.fields.Profile.displayValue;
                //console.log('1. this.superUser ###'+this.superUser)
                if(userProfileName == 'System Administrator') {
                    this.superUser = true;
                    //console.log('2. this.superUser ###'+this.superUser)
                }else if(userProfileName != 'Managed Service Lightning'){	
                    this.showButtonPanel =false;	
                }
            }
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields})
    jobRecord({ data, error }) {
        if(data!=undefined) {

            

            this.lobValue = data.fields.MS_Line_of_Business__c.value;
            let sysUsed = data.fields.System_Used__c.value;
            
            //console.log('systemDataList ###'+this.systemDataList);

            if(sysUsed!=null) {
                let updatedSysUsed = sysUsed.split(';')
                for(let i=0; i<updatedSysUsed.length; i++) {
                    if(SYSTEM_USED_FOR_SYSTEMS.includes(updatedSysUsed[i])) {
                        //console.log('System used values as correct for Systems')
                        handleCandidateComponentVisibility({ jobId: this.recordId })
                        .then(result => {
                            this.systemDataList=result;
                            //console.log('this.systemDataList length###'+this.systemDataList.length)
                            if(this.systemDataList!= undefined && this.systemDataList.length >0) {
                                if(SYSTEM_USED_FOR_CANDIDATE.includes(updatedSysUsed[i])) {
                                    //console.log('System used values as correct for Candidates')
                                    this.systemUsed = true;
                                    errorMessage = '';
                                }
                            }
                            else {
                                if(this.systemUsed!=true) {
                                    this.systemUsed = false;
                                    this.errorMessage = 'Please select system before uploading candidate data in "System Used" tab';
                                }
                               }
                        })
                        .catch(error => {
                            //console.log('error ====> ', error);
                        });
                    }
                    else {
                        if(SYSTEM_USED_FOR_CANDIDATE.includes(updatedSysUsed[i])) {
                            this.systemUsed = true;
                            break;
                        }
                    }
                    
                }
            }
            if(this.lobValue!=null || this.lobValue!=undefined) {
                if(this.lobValue.includes('TA - Vocational')) {
                    this.showVocational = true; 
                    this.pass = data.fields.Count_of_Candidates_pass__c.value==null?0:data.fields.Count_of_Candidates_pass__c.value;
                    this.fail = data.fields.Count_of_Candidates_fail__c.value==null?0:data.fields.Count_of_Candidates_fail__c.value;
                    this.dna = data.fields.Count_of_Candidates_DNA__c.value==null?0:data.fields.Count_of_Candidates_DNA__c.value;
                }
                else {
                    this.showVocational = false;
                    this.invited = data.fields.Count_of_candidates_invited__c.value==null?0:data.fields.Count_of_candidates_invited__c.value;
                    this.actual = data.fields.Actual_Count_of_Candidates__c.value==null?0:data.fields.Actual_Count_of_Candidates__c.value;
                }
            }
        }
        else {
            //console.log(error);
        }
    } 

    connectedCallback() {
        //console.log('testts')
        this.handleComponentVisibility(false, false, true);
        this.getCandidateCount();
    }

    handleUpdateUsage() {
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    handleCandidateComponentVisibility(){
        //console.log('handleComponentVisibility')
        handleCandidateComponentVisibility({ jobId: this.recordId })
        .then(result => {
           this.systemDataList=result;
           //console.log('this.systemDataList ###'+this.systemDataList)
        })
        .catch(error => {
            //console.log('error ====> ', error);
        });
    }

    handleNumberChange(event) {
        let buttonName = event.target.name;
        if(buttonName == 'pass') {
            this.pass = event.target.value;
        }
        if(buttonName == 'fail') {
            this.fail = event.target.value;
        }
        if(buttonName == 'dna') {
            this.dna = event.target.value;
        }
        if(buttonName == 'invited') {
            this.invited = event.target.value;
        }
        if(buttonName == 'actual') {
            this.actual = event.target.value;
        }
    }

    save(event) {
        this.isShowModal = false;
        //console.log('Pass ###'+this.pass)
        //console.log('Fail ###'+this.fail)
        //console.log('DNA ###'+this.dna)
        //console.log('parseInt(this.pass) ###'+parseInt(this.pass))
        //console.log('parseInt(this.pass) ###'+parseInt(this.fail))
        //console.log('parseInt(this.dna) ###'+parseInt(this.dna))
        let actual
        let invited
        if((this.pass!=undefined ) || (this.fail!=undefined) ||(this.dna!=undefined)) {
            //console.log('Pass Fail DNA')
            actual = parseInt(this.pass) + parseInt(this.fail);
            invited = parseInt(this.pass) + parseInt(this.fail) + parseInt(this.dna);
        }
        else {
            //console.log('Not pass fail DNA')
            //console.log('this.actual ###'+this.actual)
            //console.log('this.invited ###'+this.invited)
            actual = this.actual;
            invited = this.invited;
        }
        

        //console.log('Invited ###'+invited)
        //console.log('Actual ###'+actual)

        let fields = {
            Id: this.recordId,
            Count_of_Candidates_pass__c: this.pass,
            Count_of_Candidates_fail__c: this.fail,
            Count_of_Candidates_DNA__c: this.dna,
            Count_of_candidates_invited__c: invited,
            Actual_Count_of_Candidates__c: actual,
        }
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!',
                    message: 'Count updated successfully',
                    variant: 'success'
                })
            )
        })
        .catch(error =>{
            //console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Something went wrong while updating count',
                    variant: 'error'
                })
            )
        })
    }

    get systemUsed() {
        let systemUsedAvailable=false;
        //console.log('sysUsedsysUsed '+this.systemDataList);
        if(this.systemDataList != undefined && this.systemDataList.length >0){
            systemUsedAvailable=true;
        }
        return systemUsedAvailable;
    }

    handleCandidateCreationSuccess(event) {
        if(event.detail == 'success') {
            this.handleComponentVisibility(false, false, true);
            this.template.querySelector('c-ms-candidate-data-table').showAllCandidates();
            this.handleButtonVisibility(true);
        }
    }

    handleCandidateCreationCancel(event) {
        if(event.detail == 'cancel') {
            this.handleComponentVisibility(false, false, true);
        }
    }

    handleCandidateCreation() {
        this.handleComponentVisibility(true, false, true);
    }

    handleCandidateImport() {
        this.handleComponentVisibility(false, true, false);
    }

    handleCandidateList() {
        this.handleComponentVisibility(false, false, true);
        setTimeout(() => this.template.querySelector("c-ms-candidate-data-table").showAllCandidates());
        //this.template.querySelector("c-ms-candidate-data-table").showAllCandidates();
    }

    handleComponentVisibility(showCandidateCreation, showCandidateImport, showCandidateList) {
        this.handleCandidateComponentVisibility();
        this.showCandidateCreation = showCandidateCreation;
        this.showCandidateImport = showCandidateImport;
        this.showCandidateList = showCandidateList;
    }

    handleImportCandidate1(){
        this.showButtonPanel = false;
        this.handleComponentVisibility(false, true, false);
        setTimeout(() => this.template.querySelector("c-process-c-s-v-file-and-split").handleImportCandidate());
    }

    handleExportCandidate1() {
        this.handleComponentVisibility(false, true, true);
        setTimeout(() => this.template.querySelector("c-process-c-s-v-file-and-split").handleExportCandidate());
    }

    handleCandidateExportAction(event) {
        this.handleComponentVisibility(false, false, true);
        this.showSpinner = false;
    }

    handleUpdateCandidate1(){
        this.showButtonPanel = false;
        this.handleComponentVisibility(false, true, false);
        setTimeout(() => this.template.querySelector("c-process-c-s-v-file-and-split").handleUpdateCandidate());
    }

    handleButtonPanel(event) {
        if(event.detail == 'success') {
            this.showButtonPanel = true;
            this.handleComponentVisibility(false, false, true);
            this.getCandidateCount();
        }
    }

    handleButtonVisibility(isDisplay){
        this.showExportUpdateBtn = isDisplay;
    }

    handleUpdateExportBtn(event){
        if(event.detail == 'success') {
            this.getCandidateCount();
        }
    }

    getCandidateCount(){
        handleButtonVisibilityApex({
            jobId : this.recordId
        })
        .then(result => {
            //console.log('result: ', result);
            if(result > 0){
                this.handleButtonVisibility(true);
            }else{
                this.handleButtonVisibility(false);
            }
        })
        .catch(error => {
            //console.log('error: ', error);
            this.handleButtonVisibility(false);
        });
    }

    async deleteCandidateList(){
      const result = await LightningConfirm.open({
            message: 'Are you sure you want to delete Candidates?',
            variant: 'header',
            label: 'Please Confirm',
            theme: 'warning',
      });

      if(result==true){
        deleteCandidateList({
            jobId : this.recordId
        })
        .then(result => {
            //console.log('result11: ', result);
            const evt = new ShowToastEvent({
                title: 'Candidate Deletion',
                message: result,
                variant: 'success',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            this.handleCandidateList();
            this.handleButtonVisibility(false);
        })
        .catch(error => {
            //console.log('error: ', error);
            const evt = new ShowToastEvent({
                title: '',
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        });
      }
    }


}