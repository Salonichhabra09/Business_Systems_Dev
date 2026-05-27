import { LightningElement,wire,api,track } from 'lwc';
import getAccountOwnerDetails from '@salesforce/apex/AccountOwnerController.getAccountOwnerDetails'; 
import customerConnectEmailAddress from '@salesforce/label/c.Customer_Connect_Mail_Box_Address'
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex"

export default class AccountOwnerComponent extends LightningElement {

    @api recordId;
    @track accountRecord ={};
    wiredData;
    newOwner;
    isGcscAccount;
    isCustomerConnectAccount;
    isGCSCChanged = false;
    isCustomerConnectChanged = false;
    showSpinner = true;
    hasNoAccess=false;
    hasNoEditAccess = false;
    hasNoEditAccessOnCustomerConnect = false;
    hasNoEditAccessOnGcscOwned = false;

    @wire(getAccountOwnerDetails,({recordId:'$recordId'}))
    wiredAccountDetails(value) {
        this.wiredData = value;
        const { error, data } = value;
        if (error) {         
            console.log(JSON.stringify(error));
        } else if (data) {
            this.accountRecord = {};
            this.accountRecord = data;
            this.isGCSCChanged = false;
            this.isCustomerConnectChanged = false;
            this.newOwner = undefined;
            this.isGcscAccount = this.accountRecord.isGcscAccount;
            this.isCustomerConnectAccount = this.accountRecord.isCustomerConnectAccount;
            this.hasNoAccess = this.accountRecord.hasTransferAccess ? false : true;
            this.hasNoEditAccess = this.accountRecord.hasEditAccess ? false : true;
            this.hasNoEditAccessOnCustomerConnect = this.accountRecord.hasEditAccessOnCustomerConnect ? false : true;
            this.hasNoEditAccessOnGcscOwned = this.accountRecord.hasEditAccessOnGcscOwned ? false : true;
            this.showSpinner = false;
        }
    }

    handleGcscAccountChange(event){
        this.isCustomerConnectAccount = false;
        this.isGcscAccount = event.target.checked;
        this.isGCSCChanged = true;
    }

    handleCustomerConnectAccountChange(event){
      this.isGcscAccount = false;
      this.isCustomerConnectAccount = event.target.checked;
      this.isCustomerConnectChanged = true;
  }

    handleOwnerChange(event){
        this.newOwner = event.target.value;
    }

    handleGcscOwnerUpdate(){
        this.showSpinner = true;
        const fields = {};
        fields.Id = this.recordId;
        if(this.isGCSCChanged && this.isGcscAccount!=this.accountRecord.isGcscAccount && !this.isCustomerConnectAccount){
          fields.GCSC_Owned_Account__c = this.isGcscAccount;
          if(this.isGcscAccount && this.accountRecord.isCustomerConnectAccount){
            fields.Customer_Connect_Account__c = false;
          }
        }else if(this.isCustomerConnectChanged && this.isCustomerConnectAccount!=this.accountRecord.isCustomerConnectAccount){
          fields.Customer_Connect_Account__c = this.isCustomerConnectAccount;
          if(this.isCustomerConnectAccount){
            fields.GCSC_Account_Owner__c = customerConnectEmailAddress;
            if(this.accountRecord.isGcscAccount){
              fields.GCSC_Owned_Account__c = false;
            }
          }
        }
        const recordInput = { fields };
      updateRecord(recordInput)
        .then(() => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Account Owner Updated Successfully",
              variant: "success",
            }),
          );
           refreshApex(this.wiredData);
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error updating the owner",
              message: error.body.message,
              variant: "error",
            }),
          );
          this.showSpinner = false;
        });
    }

    handleAccountOwnerUpdate(event){
        event.preventDefault(); 
         
        
        if((this.isGCSCChanged || this.isCustomerConnectChanged) && !this.newOwner && (this.isGcscAccount!=this.accountRecord.isGcscAccount || this.isCustomerConnectAccount!=this.accountRecord.isCustomerConnectAccount)){
          this.handleGcscOwnerUpdate();
        }else if(this.newOwner && this.accountRecord.ownerDetails!=this.newOwner){
            this.showSpinner = true;  
            const fields = {};
            fields.OwnerId = this.newOwner;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        } 
        
    }

    handleSuccess(){
      refreshApex(this.wiredData);
        this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Account Owner Updated Successfully",
              variant: "success",
            }),
          );
        this.showSpinner = false;
    }

    handleError(event){
      this.showSpinner = false;
      let message = event.detail.detail ? event.detail.detail: event.detail.message;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error Occurred !",
          message: message,
          variant: "error",
          mode: "sticky"
        }),
      );
    }
}