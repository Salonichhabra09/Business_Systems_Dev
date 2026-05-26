import { api, wire, LightningElement } from 'lwc';
import getLatestAccountPlanFile from '@salesforce/apex/AccountPlanPrint_Controller.getLatestAccountPlanByRecordId';
import {CurrentPageReference} from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';

export default class PrintAccountPlan extends LightningElement {
    //fileID;
    @api recordId;
    showError = false;
    ShowPreview = false;
    showSpinner = true;
    url;
    
    //heightInRem = 6;
    //error;
    
    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //     if (currentPageReference) {
    //         this.recordId = currentPageReference.state.recordId;
    //     }
    // }

    connectedCallback() {
        let self = this;
        console.log('record ID', self.recordId );
        getLatestAccountPlanFile({ 
            recordId: self.recordId, 
        })
        .then(res => {
            let data = JSON.parse(JSON.stringify(res));
            console.log('data 1');
            console.log(data);
            self.url = '/sfc/servlet.shepherd/document/download/'+ data;
            self.error = undefined;
            self.ShowPreview = true;
            self.showSpinner = false;
        })
        .catch(error => {
            self.ShowPreview = false;
            if(self.recordId){
                this.ShowToastOnError();
            } 
            
           // err = JSON.parse(JSON.stringify(error));
           // console.log(JSON.parse(JSON.stringify(error)));
            //console.log('Failed getting Account Plan File with error: ' +  err.body.message);
            //self.error = 'There is no Account Plan File to Print!';
            //self.fileID = undefined; 
            self.showSpinner = false;
        });
    }

    ShowToastOnError(){
        const event = new ShowToastEvent({
            title: 'There is no Account Plan File to Print!',
            variant: 'Warning',
            mode:'dismissable',
            duration: '15000',
            message: 'Please generate an Account Plan PDF file before printing.'});
        this.dispatchEvent(event);
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    closeModal(){
        const closeEvent = new CustomEvent("closeprintpdfpopup",{
            detail: false
        });
        this.dispatchEvent(closeEvent);   
    }

}