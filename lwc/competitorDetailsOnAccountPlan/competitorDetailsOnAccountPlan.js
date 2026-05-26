import { LightningElement,api,wire } from 'lwc';
import getCompetitorDetails from '@salesforce/apex/CompetitorOnAccountPlanController.getCompetitorDetails';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex'

export default class CompetitorDetailsOnAccountPlan extends LightningElement {

    @api recordId;
    @api isAccountPlanUnderReview;
    @api apType;//Added as part of SSE-21664

    objectApiName = 'Competitor__c';
  
    columns = [
        { label: 'Name', fieldName: 'competitorUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'competitorName' },target:'_blank' } },
        { label: 'Solution', fieldName: 'solution',hideDefaultActions:true,wrapText:true},
        { label: 'Est. Customer Spend', fieldName: 'estimatedCustomerSpend',hideDefaultActions:true},
        { label: 'Opportunity', fieldName: 'opportunityUrl',type:'url',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'opportunityName' },target:'_blank' } },
        { label: 'Incumbent Vendor', fieldName: 'incumbentVendor',hideDefaultActions:true,wrapText:true},
        { label: 'Incumbent Renewal Date', fieldName: 'incumbentDate',hideDefaultActions:true,wrapText:true},
    ];

    showSpinner = false;
    showSpinner = false;
    competitorData;
    wiredData;
    openModal = false;
    showErrorMessage = false;
    error;

    @wire(getCompetitorDetails,({accountId:'$recordId' , apType :'$apType'}))
    getCompetitorDetails(value){
      
        this.wiredData = value;
        const { error, data } = value;
        if (error) {
            const event = new ShowToastEvent({
                title: 'Error!',
                message:error.body.message,
                variant:'success'
            });
            this.dispatchEvent(event);
        } else if (data) {
            if(data.length>0){
                this.competitorData = data;
            }
            this.error = undefined;
        }
    }

    handleSuccess(){
        const event = new ShowToastEvent({
            title: 'Success!',
            variant:'success'
        });
        this.dispatchEvent(event);
        refreshApex(this.wiredData);
        this.showSpinner = false;
        this.closeModal();
    }

    handleSave(){
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
    }

    handleError(){
        this.showSpinner = false;
    }

    openModalPopup(){
        this.openModal = true;
    }

    closeModal(){
        this.openModal = false;
        this.showErrorMessage = false;
    }

}