import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import createCustomerRequestFromCustomForm from '@salesforce/apex/CustomerRequestController.createCustomerRequestFromCustomForm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import getRecentCRF from '@salesforce/apex/CustomerRequestController.getRecentCRF';
import createFormAttribute from '@salesforce/apex/CustomerRequestController.createFormAttribute';
import CONTACTID_FIELD from "@salesforce/schema/Job__c.Opportunity__r.Primary_Contact__c";
import JOB_NAME from "@salesforce/schema/Job__c.Name";
import SENDER_EMAIL from "@salesforce/schema/Job__c.Sender_Email__c";
import PRIMARY_CONTACT_NAME from "@salesforce/schema/Job__c.Opportunity__r.Primary_Contact__r.Name";
import PROJECT_MANAGER_NAME from "@salesforce/schema/Job__c.Project_Manager__r.Name";
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import NoHeader from '@salesforce/resourceUrl/NoHeader';

export default class dregComponent extends NavigationMixin(LightningElement) {
    recordId;
    jobNumber;
    showPreview = false;
    @track allvalue = [];
    @track ExistingFields = [];
    updatedValues = null;
    value = '12';
    indexToStart;
    childVisible = false;
    showSystemSelector = true;
    error;
    systemSelected;
    lastSystemSelected = null;
    systemValueChanged = false;
    showFormCreation = true;
    showCandidateFields = false;
    showNextButton = false;
    @track candidateFieldsList;
    accountId;
    textUnderLogo;
    candidateUpdatedValues = null;
    @track candidateFieldsListSize = 0;
    @track showGenerateUrl = false;
    wrfClientName;
    solutionSelected;
    candidateInstruction;

    get options() {
        return [
            { label: '1', value: '12' },
            { label: '2', value: '6' },
        ];
    }

    /*get showGenerateUrl() {
        if (this.showCandidateFields && this.candidateFieldsListSize > 0)
            return true;
        else
            return false;
    }*/

    get recordUrl() {
        // Construct the URL to navigate to the record detail page
        return `/lightning/r/${this.recordId}/view`;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            loadStyle(this, NoHeader);
            this.recordId = currentPageReference.state?.c__recordId;
            this.jobNumber = currentPageReference.state?.c__jobNumber;
            this.accountId = currentPageReference.state?.c__accountId;
            this.showSystemSelector = true;
            this.showFormCreation = false;
            this.showCandidateFields = false;
            this.lastSystemSelected = null;
            this.textUnderLogo = null;
            //console.log("values " + this.recordId + "   " + this.jobNumber);
        }
    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [CONTACTID_FIELD, JOB_NAME, SENDER_EMAIL, PRIMARY_CONTACT_NAME, PROJECT_MANAGER_NAME]
    })
    jobRecord;


    /* @wire(getRecentCRF, {
         JobId: '$recordId'
     })
     wiredGetRecentCRF(result) {
         if (result.data) {
             let fields = JSON.stringify(result.data["Field_Configuration__c"]);
             let var1= fields.replace(/\\/g, "");
             var result = var1.substring(1, var1.length-1);
             this.ExistingFields = JSON.parse(result);
             //console.log('Priyank Existing WRF '+JSON.stringify(this.ExistingFields));
             this.indexToStart=Math.max(...this.ExistingFields.map(o => o.index));
             this.ExistingFields.forEach(element =>{
                 if(element.fieldtype=='checkbox'){
                     element.value=false;
                 }
                 else{
                     element.value='';
                 }
             })
             //console.log("Index to Start "+this.indexToStart);
             this.childVisible=true;
         }
         else if (result.error) {
             this.error = result.error;
             //console.log('this.error '+JSON.stringify(this.error));
             this.childVisible=true;
         }
     } */

    handleSystemSelected(event) {
        //console.log("System Selected " + event.detail.value);
        this.systemSelected = event.detail.value;
        this.solutionSelected = event.detail.solution;
        //console.log("Solution Selected " + this.solutionSelected);
        if (this.systemSelected != this.lastSystemSelected) {
            this.systemValueChanged = true;
            this.showNextButton = true;
            getRecentCRF({ accountId: this.accountId, systemused: event.detail.value })
                .then(result => {
                    /*let fields = JSON.stringify(result["Field_Configuration__c"]);
                    let var1 = fields.replace(/\\/g, "");
                    var result = var1.substring(1, var1.length - 1);*/
                    /*this.ExistingFields = JSON.parse(result[0]);
                    if(result.length==3){
                        this.textUnderLogo = result[1];
                        this.wrfClientName = result[2];
                    }
                    else{
                        this.wrfClientName = result[1];
                    }*/
                    this.ExistingFields = JSON.parse(result["Field_Configuration__c"]);
                    this.textUnderLogo = result["Text_Under_Logo__c"];
                    this.wrfClientName = result["WRF_Client_Name__c"];
                    //console.log('wrfClientName ' + this.wrfClientName);
                    //console.log('TextUnderLogo ' + this.textUnderLogo);
                    //console.log('Priyank Existing WRF ' + JSON.stringify(this.ExistingFields));
                    this.indexToStart = Math.max(...this.ExistingFields.map(o => o.index));
                    this.ExistingFields.forEach(element => {
                        if (element.fieldtype == 'date') {
                            element["cssClass"] = 'date-overflow';
                        }
                        if (element.fieldtype == 'checkbox') {
                            element.value = false;
                        }
                        else {
                            element.value = '';
                        }
                    })
                    //console.log("Index to Start " + this.indexToStart);
                    this.showSystemSelector = false;
                    this.childVisible = true;
                    this.showFormCreation = true;
                    //this.error = undefined;

                })
                .catch(error => {
                    this.error = error;
                    this.ExistingFields = undefined;
                    //console.log('this.error ' + JSON.stringify(this.error));
                    this.showSystemSelector = false;
                    this.childVisible = true;
                })
        }
        else {
            this.systemValueChanged = false;;
            this.showSystemSelector = false;
            this.childVisible = true;
            this.showFormCreation = true;
        }
        //console.log('All Value on init ' + this.allvalue);
    }

    handleDragText(event) {
        //console.log('eventttttt', event);
        event.dataTransfer.setData("", event.target.dataset.item);
        event.target.style.cursor = 'grab';
    }
    changeCusrsor(event) {
        event.target.style.cursor = 'grab';
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    showPreviewFunction() {
        //console.log('Calling Preview');
        this.showPreview = true;
        //console.log("Value in preview " + JSON.stringify(this.allvalue));
    }

    getAllValue(event) {
        //console.log('ALl value ' + event.detail);
        this.allvalue = event.detail;
        if (this.allvalue == '') {
            this.showNextButton = false;
        }
        else {
            this.showNextButton = true;
        }
    }
    getUpdatedValues(event) {
        //console.log('ALl value after update' + event.detail);
        this.updatedValues = event.detail;
    }

    getCandidateData(event) {
        let v = event.detail.candidateValue;
        //console.log('v: ', JSON.stringify(v));
        this.candidateFieldsList = event.detail.candidateValue;
    }

    cancelPreview() {
        this.showPreview = false;
    }

    async handleGenerateURL(event) {

        //console.log('this.candidateFieldsList: ', JSON.stringify(this.candidateFieldsList));
        this.showSpinner = true;
        /* this.array.forEach(arrayElement => this.selectedFieldsTest.forEach(selectedElement => {
             if (arrayElement.index__c == selectedElement.index__c) {
                 this.finalData.push(arrayElement);
             }
         }));
         //console.log("final array value " + JSON.stringify(this.finalData));*/
        //console.log("System Selected " + this.systemSelected);
        createCustomerRequestFromCustomForm({ formDetails: JSON.stringify(this.allvalue), accountId: this.accountId, candidateDetails: JSON.stringify(this.candidateFieldsList), systemSelected: this.systemSelected, jobId: this.recordId, textUnderLogo: this.textUnderLogo, wrfClientName: this.wrfClientName, Solution: this.solutionSelected, candidateInstruction: this.candidateInstruction }).then(Response => {
            const event = new ShowToastEvent({
                title: 'Success!',
                message: 'New Configuration created',
                variant: 'success'
            });
            this.dispatchEvent(event);
            //this.handleClose();
            this.handleEmail(Response);
            this.hanldeFormAttributeCreation();

        }).catch(error => {
            //console.log('Error is ' + error);
            //console.log('Error is ' + JSON.stringify(error));
            let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
            const event = new ShowToastEvent({
                title: 'Error!',
                message: message,
                variant: 'error'
            });
            this.dispatchEvent(event);
            //this.handleClose();
        });

    }

    hanldeFormAttributeCreation() {
        let fieldsToCreate = [];
        let callApex = false;

        this.candidateFieldsList.forEach(element => {
            if (element.hasOwnProperty("showEditIcon")) {
                if(element.showEditIcon==true){
                    fieldsToCreate.push(element);
                    element.showEditIcon = false;
                    callApex = true;
                } 
            }
        });

        //console.log('fieldsToCreate: ', JSON.stringify(fieldsToCreate));

        if (callApex) {
            createFormAttribute({
                jsonData: JSON.stringify(fieldsToCreate)
            })
                .then(Response => {
                    //console.log('Response: ', Response);
                    //console.log('Response: ', JSON.stringify(Response));

                }).catch(error => {
                    //console.log('Error is ' + error);
                    //console.log('Error is ' + JSON.stringify(error));
                });
        }

    }

    handleEmail(link) {
        this.showSpinner = false;
        let contactId = getFieldValue(this.jobRecord.data, CONTACTID_FIELD);
        let recieverName = getFieldValue(this.jobRecord.data, PRIMARY_CONTACT_NAME);
        let jobName = getFieldValue(this.jobRecord.data, JOB_NAME);
        let senderEmail = getFieldValue(this.jobRecord.data, SENDER_EMAIL);
        let projectManagerName = getFieldValue(this.jobRecord.data, PROJECT_MANAGER_NAME);
        let htmlbody = "Dear " + recieverName + ",<br><br>" +
            "For all requests related to " + jobName + ", I’ve created you a specific link for you to be able to place requests easily.<br>" +
            "Please use <a href=\"" + link + "\">WRF Link</a> to place your requests.<br>" +
            "If there is anything else I can help with then please do reach out to me via " + senderEmail + " quoting " + jobName + ".<br><br>" +
            "Kind Regards,<br>" + projectManagerName;


        this.cancelPreview();
        //console.log(link);
        //console.log('TO ADDRESS ' + contactId);
        let pageRef =
        {
            type: "standard__quickAction",
            attributes: {
                apiName: "Job__c.Send_Email"
            },
            state: {
                recordId: this.recordId,
                defaultFieldValues: encodeDefaultFieldValues({
                    HtmlBody: htmlbody,
                    Subject: "Customer Request Form",
                    ToIds: contactId,
                    BccAddress: '',
                }),
            },
        };
        this[NavigationMixin.Navigate](pageRef);
    }

    handleBack() {
        if (this.showCandidateFields == true) {
            this.showCandidateFields = false;
            this.showFormCreation = true;
            this.lastSystemSelected = this.systemSelected;
            this.showGenerateUrl = false;
            this.showNextButton = true;
        }
        else if (this.showFormCreation == true) {
            this.showFormCreation = false;
            this.showSystemSelector = true;
            this.showNextButton = false;
            this.lastSystemSelected = this.systemSelected;
        }

    }

    handleCandidateComponent() {
        //console.log('Client Name ' + this.wrfClientName);
        //console.log(this.template.querySelector(`lightning-input[data-name="clientName"]`).checkValidity());
        if (!this.template.querySelector(`lightning-input[data-name="clientName"]`).checkValidity()) {
            this.template.querySelector(`lightning-input[data-name="clientName"]`).reportValidity();
        }
        else {
            this.systemValueChanged = false;
            this.showFormCreation = false;
            this.showCandidateFields = true;
            this.showNextButton = false;
            setTimeout(() => {
                let child = this.template.querySelector('c-drag-candidate');
                child.getRecentCRFData();
            }, 100);
        }

    }

    getCandidateValue(event) {
        this.candidateFieldsList = event.detail.candidateValue;
        this.candidateFieldsListSize = this.candidateFieldsList?.length;
        if (this.showCandidateFields && this.candidateFieldsList?.length > 0)
            this.showGenerateUrl = true;
    }

    getDeletetedValue(event) {
        let deletedItem = event.detail.candidateValue;
        this.candidateFieldsList.forEach(element => {
            if (element.Label__c == deletedItem.Label__c) {
                this.candidateFieldsList.splice(this.candidateFieldsList.indexOf(element), 1);
            }
        });
        if (this.showCandidateFields && this.candidateFieldsList.length > 0)
            this.showGenerateUrl = true;
        else
            this.showGenerateUrl = false;
    }

    getDropEventFromCandidate(event) {
        this.candidateFieldsList = event.detail.candidateValue;
        this.showGenerateUrl = true;
    }

    getUpdatedValuesCandidate(event) {
        this.candidateUpdatedValues = event.detail.candidateValue;
        this.candidateFieldsListSize = this.candidateUpdatedValues?.length;
    }

    getCandidateInstruction(event) {
        this.candidateInstruction = event.detail.candidateInstruction;
        //console.log('this.candidateInstruction: ', this.candidateInstruction);
    }

    handleTextUnderLogo(event) {
        //console.log("Value for text under logo " + event.detail.value);
        this.textUnderLogo = event.detail.value;
    }
    handleRemove(event) {
        //console.log("Value from Child on remove " + event.detail);
        if (event.detail == '') {
            this.showNextButton = false;
        }
        else {
            this.showNextButton = true;
        }
    }

    handleClientName(event) {
        this.wrfClientName = event.target.value;
    }

}