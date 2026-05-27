import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import createCandidateRecords from '@salesforce/apex/CandidateCreationController.createCandidateRecords';
import { getRecord} from 'lightning/uiRecordApi';
import Talent_Management_LOB_Status from '@salesforce/label/c.Talent_Management_LOB_Status';
import TA_Corporate_and_TA_Vocational_LOB_Status from '@salesforce/label/c.TA_Corporate_and_TA_Vocational_LOB_Status';

const FIELDS = ['Job__c.MS_Line_of_Business__c']
const vocationalStatusList = [{label:'Pass', value:'Pass'},
{label:'Fail', value:'Fail'}, {label:'DNA', value:'DNA'}];
const otherStatusList = [{label:'Not Started', value:'Not Started'},
{label:'In Progress	', value:'In Progress'}, {label:'Completed', value:'Completed'}];
export default class CandidateCreation extends

    NavigationMixin(LightningElement) {

        @api recordId;
        @track candidateList = [];
        finalCandidateList = [];
        lobValue = 'TA';
        statusOptions = [];
        status;
        

        connectedCallback() {
            console.log('Connected callback in candidate creation')
            this.addRow();
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
    
        addRow() {
            this.finalCandidateList.push({
                'sobjectType': 'Bureau_Candidate__c','Bureau_Job__c': this.recordId,'First_Name__c': null,'Last_Name__c': null,'Email__c': null,'Gender__c': null,'Status2__c':null,'Country__c': null,'Language__c': null,'Username__c': null,'Product_Assessment__c': null,'System_s__c': null
            });
            this.candidateList.push({
                'sobjectType': 'Bureau_Candidate__c','Bureau_Job__c': this.recordId,'First_Name__c': null,'Last_Name__c': null,'Email__c': null,'Gender__c': null,'Status2__c':null,'Country__c': null,'Language__c': null,'Username__c': null,'Product_Assessment__c': null,'System_s__c': null
            });
        }

        cloneRow(event) {
            let currentIndex = parseInt(event.target.accessKey);
            let currentListItem = this.finalCandidateList[currentIndex];
            this.finalCandidateList.push(JSON.parse(JSON.stringify(currentListItem)));
            this.candidateList = JSON.parse(JSON.stringify(this.finalCandidateList));
        }
    
        removeRow(event) {
            if(this.candidateList.length > 1) {
                let currentIndex = parseInt(event.target.accessKey);
                this.finalCandidateList.splice(currentIndex, 1);
                this.candidateList = JSON.parse(JSON.stringify(this.finalCandidateList));
            }
        }
    
        handleSubmit() {
            console.log('candidateList', JSON.parse(JSON.stringify(this.candidateList)));
            console.log('finalCandidateList', JSON.parse(JSON.stringify(this.finalCandidateList)));
            var isVal = true;
            let errorMessage = 'Please enter all the required fields';
            this.template.querySelectorAll('lightning-input-field').forEach(element => {
                isVal = isVal && element.reportValidity();
            });

            if(isVal){
                for(let i = 0; i < this.finalCandidateList.length; i++ ) {
                    let candidateData = this.finalCandidateList[i];
                    let candidateUniqueId = candidateData.Bureau_Job__c + candidateData.First_Name__c + candidateData.Last_Name__c + candidateData.Email__c + candidateData.Username__c;
                    for(let j = 0; j < this.finalCandidateList.length; j++ ) {
                        if (i !== j) {
                            let candidateDataToCheck = this.finalCandidateList[j];
                            let candidateUniqueIdToCheck = candidateDataToCheck.Bureau_Job__c + candidateDataToCheck.First_Name__c + candidateDataToCheck.Last_Name__c + candidateDataToCheck.Email__c + candidateDataToCheck.Username__c;
                            if(candidateUniqueId === candidateUniqueIdToCheck) {
                                isVal = false;
                                errorMessage = 'Duplicate candidate data. Combination of candidate first name, last name, email and username should be unique.';
                                break;
                            }
                        }
                    }
                    if(!isVal) {
                        break;
                    }
                }
            }
            if (isVal) {
                createCandidateRecords({
                    candidateList: this.finalCandidateList
                })
                .then( (result) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Candidates successfully created',
                            variant: 'success'
                        }),
                    );

                    getRecordNotifyChange([{recordId: this.recordId}]);

                    const successEvent = new CustomEvent("candidatecreationsuccess", {
                        detail: 'success'
                    });
                    this.dispatchEvent(successEvent);
                    })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body ? error.body.message : error.message,
                            variant: 'error',
                            mode: 'sticky'
                        }),
                    );
                })

                
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: errorMessage,
                        variant: 'error'
                    }),
                );
            }
        }
    
        handleInputFieldChange(event) {
            
            if(event.target.label == 'Status') {
                let currentIndex = parseInt(event.target.accessKey);
                console.log('currentIndex ###'+currentIndex)
                console.log('event.target.value ###'+event.target.value)
                let fieldName = 'Status2__c';
                this.finalCandidateList[currentIndex][fieldName] = event.target.value;
            }
            else {
                let currentIndex = parseInt(event.target.accessKey);
                console.log('currentIndex ###'+currentIndex)
                let fieldName = event.target.fieldName;
                this.finalCandidateList[currentIndex][fieldName] = event.target.value;
            }
        }

        handleCandidateCancel(event) {
            const cancelEvent = new CustomEvent("candidatecreationcancel", {
                detail: 'cancel'
            });
            this.dispatchEvent(cancelEvent);
        }
    }