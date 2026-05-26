import { api, LightningElement, track, wire } from 'lwc';
import getAccountContracts from '@salesforce/apex/AccountPlan_Contracts_Controller.getAccountContracts';

export default class AccountPlanContracts extends LightningElement {
    @api recordId;
    accountContracts;
    hasContracts = false;
    errorMessage = '';
    showSpinner = true;
    
    @wire(getAccountContracts,({recordId:'$recordId'}))
    wiredAccountContracts(result){
        console.log('result' , result);
        if (result.error) {         
            this.errorMessage = 'Error getting the related Contracts. \n Please contact your System Administrator .';
            this.hasContracts = false;
            this.showSpinner = false;
        } else if (result.data) {
            if(result.data != null && result.data.length > 0){
                //let url = window.location.origin;
                this.accountContracts = result.data;
                this.errorMessage = '';
                this.hasContracts = true;
                this.showSpinner = false;
            } else { 
                this.errorMessage = 'There are no related Contracts to display.';
                this.hasContracts = false;
                this.showSpinner = false;
            }
        }
    }

}