import { LightningElement, api, track, wire } from 'lwc';
import getRecentCRFCandidate from '@salesforce/apex/CustomerRequestController.getRecentCRFCandidate';
import getFormFields from '@salesforce/apex/CustomerRequestController.getFormFields';

export default class DragCandidate extends LightningElement {
    @api fieldName;
    @api recordId;// job Id
    showPreview = false;
    @api allvalue = [];
    @track ExistingFields = [];
    value = '12';
    indexToStart;
    childVisible = false;

    @track candidateAvailableFields = [];
    @track candidateExistingFields = [];
    showListofFields = false;
    startExecution;
    @api systemUsed;
    @api accountId;
    @api candidateUpdatedValues;

    data = [];
    columns;
    showSpinner = true;
    @api lastSystemUsed;
    @api systemValueChanged;
    candidateInstruction;

    @api getRecentCRFData() {
        if (this.systemUsed != this.lastSystemUsed) {
            getRecentCRFCandidate({
                accountId: this.accountId,
                systemused: this.systemUsed
            })
                .then(data => {
                    this.showSpinner = false;
                    if (data) {
                        this.candidateExistingFields = JSON.parse(data["Candidate_Field_Configuration__c"]);
                        this.candidateInstruction = data["Candidate_Template_Instructions__c"];
                        if (this.candidateInstruction) {
                            const submitEvent = new CustomEvent('instruction', {
                                bubbles: true,
                                composed: true,
                                detail: { candidateInstruction: this.candidateInstruction }
                            });
                            // Fire the custom event
                            this.dispatchEvent(submitEvent);
                        }
                        //console.log('this.candidateExistingFields: ', JSON.stringify(this.candidateExistingFields));
                        if (!this.systemUsed.includes('360')) {
                            this.candidateExistingFields = this.candidateExistingFields.filter(element => {
                                return element.Label__c !== 'Category';
                            });
                        }
                        //console.log('After filter this.candidateExistingFields: ', JSON.stringify(this.candidateExistingFields));
                        this.indexToStart = Math.max(...this.candidateExistingFields.map(o => o.index));
                        //console.log('this.indexToStart: ', this.indexToStart);
                    }
                    this.childVisible = true;
                    this.startExecution = 'Start';
                })
                .catch(error => {
                    this.error = error;

                    this.childVisible = true;
                    this.startExecution = 'Start';
                })
        }
        else {
            this.showSpinner = false;
            this.childVisible = true;
            this.startExecution = 'Start';
        }
    }

    @wire(getFormFields, {
        startExecution: '$startExecution'
    })
    formFieldValues({ error, data }) {
        if (data) {
            this.array = JSON.parse(JSON.stringify(data));
            this.array.forEach(element => {
                if (element.Category__c == 'Candidate Import Template') {
                    this.candidateAvailableFields.push(element);
                }
                this.showListofFields = true;
            })
            if (!this.systemUsed.includes('360')) {
                this.candidateAvailableFields = this.candidateAvailableFields.filter(element => {
                    return element.Label__c !== 'Category';
                });
            }
            //console.log('this.candidateAvailableFields: ', JSON.stringify(this.candidateAvailableFields));
            if (this.candidateExistingFields != null) {
                this.candidateExistingFields.forEach(element => {
                    this.candidateAvailableFields.forEach(newElement => {
                        if (element.Label__c == newElement.Label__c) {
                            this.candidateAvailableFields.splice(this.candidateAvailableFields.indexOf(newElement), 1);
                        }
                    })
                })
                if (this.candidateAvailableFields.length == 0) {
                    this.showListofFields = false;
                }
            }
        }
        if (error) {

        }
    }

    handleSearchInput(event) {
        const inputVal = event.target.value;
        this.candidateAvailableFields.forEach(element => {
            if (!element.Label__c?.toLowerCase().includes(inputVal?.toLowerCase())) {
                this.template.querySelector(`lightning-layout-item[data-name="${element.Label__c}"]`)?.classList.add('hideClass');
            }
            else {
                this.template.querySelector(`lightning-layout-item[data-name="${element.Label__c}"]`)?.classList.remove('hideClass');
            }
        })
    }

    handleDragText(event) {
        event.dataTransfer.setData("", event.target.dataset.item);
        event.target.style.cursor = 'grab';
    }

    handleDragCandidate(event) {
        event.dataTransfer.setData("divId", event.target.dataset.item + ';' + event.target.dataset.type + ';' + event.target.dataset.values + ';' + event.target.dataset.api);
        event.target.style.cursor = 'grab';
    }

    changeCursor(event) {
        event.target.style.cursor = 'grab';
    }

    getAllValue(event) {
        //list of selected fields
        this.candidateExistingFields = event.detail.candidateValue;

    }

    getDeletetedValue(event) {
        //Removed field
        this.candidateAvailableFields.push(event.detail.candidateValue);
        if (this.candidateAvailableFields.length != 0) {
            this.showListofFields = true;
        }
        this.sortByName(this.candidateAvailableFields);
    }

    getDropItem(event) {
        //list of selected fields
        this.candidateExistingFields = event.detail.candidateValue;
        this.candidateExistingFields.forEach(element => {
            this.candidateAvailableFields.forEach(newElement => {
                if (element.Label__c == newElement.Label__c) {
                    this.candidateAvailableFields.splice(this.candidateAvailableFields.indexOf(newElement), 1);
                }
            })
        });
        if (this.candidateAvailableFields.length == 0) {
            this.showListofFields = false;
        }
        this.sortByName(this.candidateAvailableFields);
    }

    sortByName(arrayToSort) {
        arrayToSort.sort((a, b) => {
            const nameA = a.Label__c.toUpperCase(); // ignore upper and lowercase
            const nameB = b.Label__c.toUpperCase(); // ignore upper and lowercase
            if (nameA < nameB) {
                return -1;
            }
            if (nameA > nameB) {
                return 1;
            }

            // names must be equal
            return 0;
        });
    }

    handleCandidateInstruction(event) {
        //console.log("Value for text under logo " + event.detail.value);
        this.candidateInstruction = event.detail.value;

        const submitEvent = new CustomEvent('instruction', {
            bubbles: true,
            composed: true,
            detail: { candidateInstruction: this.candidateInstruction }
        });
        // Fire the custom event
        this.dispatchEvent(submitEvent);
    }
}