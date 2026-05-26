import { LightningElement,api,track,wire } from 'lwc';
import getPicklistValues from '@salesforce/apex/BulkTaskAccountPlanController.getPicklistValues';
import createBulkTasks from '@salesforce/apex/BulkTaskAccountPlanController.createBulkTasks';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from "lightning/platformResourceLoader";
import modalPopupCss from "@salesforce/resourceUrl/modalPopupCss";
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
export default class BulkTaskCreationOnStrategy extends LightningElement {

    @api recordId;
    objectApiName ='Strategy_and_Goal__c';
    showSpinner = true;
    isDisabled = false;

    keyIndex = 1;
    @track taskList = [
        {
            id: 1,

        }
    ];

    subjectPicklist;
    statusPicklist;
    showErrorMessage = false;
    isLoaded = false;

    connectedCallback() {
        loadStyle(this, modalPopupCss);
      }

    @wire(getPicklistValues,({strategyId:'$recordId'}))
    getPicklistValues(value){
        this.wiredData = value;
        const { error, data } = value;
        if (error) {
            this.error = error;
            this.showSpinner = false;
        } else if (data) {
            if(data.MessageType=='Success'){
                this.subjectPicklist = data.picklistValues[0];
                this.statusPicklist = data.picklistValues[1];
                this.showSpinner = false;
                this.error = undefined;
                this.isLoaded = true;
        }
        else if(data.MessageType=="NoAccess"){
            const event = new ShowToastEvent({
                title: 'No Access!',
                message:data.Message,
                variant:'error'
            });
            this.dispatchEvent(event);
            this.closeModal();
        }
        else if(data.MessageType=="Error"){
            const event = new ShowToastEvent({
                title: 'Error!',
                message:data.Message,
                variant:'error'
            });
            this.dispatchEvent(event);
            this.closeModal();
        }
        }
    }

    addRow() {
        ++this.keyIndex;
        var newItem = [{ id: this.keyIndex }];
        this.taskList = this.taskList.concat(newItem);
    }

    removeRow(event) {
        if (this.taskList.length >= 2) {
            this.isLoaded =false;
            let temp = JSON.parse(JSON.stringify(this.taskList));
            temp = temp.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
            let index = 1 ;
            temp.forEach(element => {
                element.id = index;
                index++
            });
            this.taskList = temp;
            this.keyIndex = index-1;
            setTimeout(() => {
                this.isLoaded = true;
            }, 0);
        }
    }

    handleSave() {
        this.showSpinner = true;
        let requiredFields = this.template.querySelectorAll(".required-fields");
        let allRequiredValuesPresent = true;
        requiredFields.forEach(element => {
            if(!element.value){
                allRequiredValuesPresent = false;
            }
        });
        if(!allRequiredValuesPresent){
            this.showErrorMessage = true;
            this.showSpinner = false;
        }else{
        createBulkTasks({accountPlanId : this.recordId,taskList:this.taskList}).then(Response => {
            this.showSpinner = false;
            if(Response.MessageType=='Success'){
                const event = new ShowToastEvent({
                    title: 'Success!',
                    variant:'success'
                });
                this.dispatchEvent(event);
                notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                this.closeModal();
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:Response.Message,
                    variant:'error'
                });
                this.dispatchEvent(event);
            }
        }).catch(Error => {
            this.showSpinner = false;
            let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
            const event = new ShowToastEvent({
                title: 'Error!',
                message: message,
                variant:'error'
            });
            this.dispatchEvent(event);
            this.showSpinner = false;
            //this.closeModal();
        });
    }
    }

    closeModal(){
        this.dispatchEvent(new CloseActionScreenEvent());
        this.showErrorMessage = false;
        //Changes added for SSE-22562
        // setTimeout(() => {
        //     eval("$A.get('e.force:refreshView').fire();");
        // }, 1000);
    }

    selectDate(event){
        let accessKey = event.target.accessKey
        this.taskList[accessKey-1].dueDate = event.detail.value;
    }

    selectSubject(event){
        let accessKey = event.target.accessKey
        this.taskList[accessKey-1].subject = event.detail.value;
    }

    selectStatus(event){
        let accessKey = event.target.accessKey
        this.taskList[accessKey-1].status = event.detail.value;
    }

    selectContact(event){
        let accessKey = event.target.accessKey
        this.taskList[accessKey-1].contact = event.detail.value[0];
    }

    selectUser(event){
        let accessKey = event.target.accessKey
        this.taskList[accessKey-1].assignedTo = event.detail.value[0];
    }

    selectComments(event){
        let accessKey = event.target.accessKey
        //Changes added for SSE-22562 
        this.taskList[accessKey-1].comments = event.target.value;
    }

    handleSubjectValueRemoval(event){
        let accessKey = event.detail.accessKey
        this.taskList[accessKey-1].subject = '';
    }

    handleSubjectValue(event){
        let accessKey = event.detail.accessKey
        this.taskList[accessKey-1].subject = event.detail.value;
    }
}