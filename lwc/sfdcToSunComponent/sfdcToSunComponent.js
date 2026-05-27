import { LightningElement,wire,api } from 'lwc';
import { getRecord,updateRecord } from 'lightning/uiRecordApi';
import Account_Transfer_Status_Field from "@salesforce/schema/Account.SFDC2SUN_TransferStatus__c";
import Contact_Transfer_Status_Field from "@salesforce/schema/Contact.SFDC2SUN_TransferStatus__c";
import Contact_Transferred_By_Field from "@salesforce/schema/Contact.SFDC2SUN_TransferredBy__c";
import Account_Transferred_By_Field from "@salesforce/schema/Account.SFDC2SUN_TransferredBy__c";
import Account_Status_Field from "@salesforce/schema/Account.Status__c";
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import Contact_Transfer_Validity_Field from "@salesforce/schema/Contact.Is_Ready_for_Transfer__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import userId from "@salesforce/user/Id";
import UserAndProfileForAccountTransferButton from '@salesforce/label/c.UserAndProfileForAccountTransferButton';

export default class SfdcToSunComponent extends LightningElement {

    @api recordId;
    @api objectApiName;
    record;
    isNotTransferred;
    isNotReadyToTransfer;
    warningMessage;
    isButtonVisible = false;
    buttonLabel = '';
    wiredData;
    showSpinner = false;
    currentUser;

    @wire(getRecord, { recordId: '$recordId', optionalFields: [Account_Status_Field,Account_Transfer_Status_Field,Contact_Transfer_Status_Field,Contact_Transfer_Validity_Field] })
    wireContact(value) {
        this.wiredData = value;
        const { error, data } = value;
        if(data) {
            this.record = data;
            if(this.objectApiName=='Account'){
                this.isNotTransferred = this.record.fields.SFDC2SUN_TransferStatus__c.value =='Not Transferred';
                this.isNotReadyToTransfer = this.record.fields.Status__c.value !='Approved';
                this.warningMessage = 'The Account should be approved in order to make it Ready for Sun Transfer';
                this.isButtonVisible = false;
                this.currentUser = userId;
            }else{
                console.log('1');
                this.isNotTransferred = this.record.fields.SFDC2SUN_TransferStatus__c.value =='Not Transferred';
                this.isNotReadyToTransfer = !this.record.fields.Is_Ready_for_Transfer__c.value;
                this.warningMessage = 'Account , Email and Address Line 1 , City , ZIP/Postal Code , Country or Same As The Account Billing Address is required to make the contact ready for Sun transfer';
                if(this.record.fields.SFDC2SUN_TransferStatus__c.value==null || this.record.fields.SFDC2SUN_TransferStatus__c.value=='Not Transferred'){
                  this.buttonLabel = 'Transfer Contact';  
                  this.isButtonVisible = true;
                }else{
                    this.isButtonVisible = false;
                }
            }
        }
    }

    @wire(getRecord, { recordId: '$currentUser', fields: [PROFILE_NAME_FIELD]})
    wireAccount({ data, error }) {
    if(data) {
      let isUserAllowed = UserAndProfileForAccountTransferButton.includes(userId) || UserAndProfileForAccountTransferButton.includes(data.fields.Profile.value.fields.Name.value) ;
      if(this.record){
        if(!this.isNotReadyToTransfer && isUserAllowed && (this.record.fields.SFDC2SUN_TransferStatus__c.value==null || this.record.fields.SFDC2SUN_TransferStatus__c.value=='Not Transferred')){
          this.buttonLabel = 'Transfer Account';  
          this.isButtonVisible = true;
        }
      }
    }
  }


    handleStatusUpdate(){
        this.showSpinner = true;
        const fields = {};
        fields['Id'] = this.recordId;
        let message = '';
        if(this.objectApiName == 'Contact'){
          fields[Contact_Transfer_Status_Field.fieldApiName] = 'Ready for Transfer';
          fields[Contact_Transferred_By_Field.fieldApiName] = userId;
          message = 'Contact marked Ready for Transfer';
        }else{
          fields[Account_Transfer_Status_Field.fieldApiName] = 'Ready for Transfer';
          fields[Account_Transferred_By_Field.fieldApiName] = userId;
          message = 'Account marked Ready for Transfer';
        }
        const recordInput = { fields };
  
        updateRecord(recordInput)
          .then(() => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: message,
                variant: "success",
              }),
            );
            this.showSpinner = false;
            // Display fresh data in the form
            return refreshApex(this.wiredData);
          })
          .catch((error) => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error",
                message: error.body.message,
                variant: "error",
              }),
            );
            this.showSpinner = false;
          });
      }
}