import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";

export default class EditContactOnOppHierarchy extends NavigationMixin(LightningElement) {

    @api contact;
    showHierarchy = false;
    isEdit = false;
    isView = true;
    showSpinner = true;
    isFormLoaded = false;

    handleFormLoad(){
        this.showSpinner = false;
        this.isFormLoaded = true;
    }

    handleSubmit(){
        this.showSpinner = true;
    }

    handleSuccess(){
        const event = new ShowToastEvent({
            title: 'Contact Edited Successfully',
            variant:'success'
        });
        this.dispatchEvent(event);
        
        this.dispatchEvent(new CustomEvent('refreshhierarchy', {
            bubbles: true,
            composed: true
        }));
    }

    handleCloseEdit(){
        this.showSpinner = true;
        this.isEdit = false;
        this.isView = true;
        this.isFormLoaded = false;
    }

    handleEditContact(){
        this.showSpinner = true;
        this.isEdit = true;
        this.isView = false;
        this.isFormLoaded = false;
    }

    handleError(){
        this.showSpinner = false;
    }

    handleNavigateToContact(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contact.Id,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }
}