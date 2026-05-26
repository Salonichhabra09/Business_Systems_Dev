import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SystemCreateComponent extends LightningElement {

    @api recordTypeId;
    showSpinner = false;
    showErrorMessage = false;
    isInternalSystem = true;

    handleSuccess(){
        const event = new ShowToastEvent({
            title: 'Success!',
            variant:'success'
        });
        this.dispatchEvent(event);
        const closeModal = new CustomEvent('closesystemmodal');
        this.dispatchEvent(closeModal);
        this.showSpinner = false;
        this.showErrorMessage = false;
    }

    handleSubmit(event){
        event.preventDefault();  
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
        }
        else{
            const fields = event.detail.fields;
            fields.RecordTypeId = this.recordTypeId;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    }

    handleError(){
        this.showSpinner = false;
    }
    closeModal(){
        const closeModal = new CustomEvent('closesystemmodal');
        this.dispatchEvent(closeModal);
    }
}