import { LightningElement,wire,api } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_FIELD from "@salesforce/schema/Contact.Account.Id";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";

export default class HomeAddressOnContact extends LightningElement {

    @api recordId;
    records;
    homeAddress;
    error;
    hasHomeAddress = false;
    noHomeAddress = false;
    isCreateRecord = false;
    wiredData;
    showSpinner = true;
    editRecordId;
    headerTitle = 'Create Home Address';
    addressRecordTypeId;
    addressToShow ='';

    @wire(getObjectInfo, { objectApiName: 'India_GST__c' })
    
    getObjectInfo({ error, data }) {
        if (data) {
            this.lstRecordTypes = [];
            for (let key in data.recordTypeInfos) {
                if(data.recordTypeInfos[key].name=='Address'){
                  this.addressRecordTypeId = key;
                  break;
                }
            }
        }
        else if (error) {
            console.log('Error while get record types');
            this.lstRecordTypes = [];
        }
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [ACCOUNT_FIELD],
      })
      contact;

    get accountId() {
      return getFieldValue(this.contact.data, ACCOUNT_FIELD);
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Address_Tax_Information__r',
        fields: [        
            'India_GST__c.Id',         
            'India_GST__c.Address_Line_1__c',
            'India_GST__c.Address_Line_2__c',
            'India_GST__c.Address_Line_3__c',
            'India_GST__c.Address_Line_4__c',
            'India_GST__c.City__c' , 'India_GST__c.State_County__c',
            'India_GST__c.Global_Country__c' , 'India_GST__c.ZIP_Postal_Code__c'
        ]
      })
      listInfo(value) {
        this.wiredData = value;
        const { error, data } = value;
        if (data) {
          this.records = data.records;
          if(this.records.length>0){
            this.hasHomeAddress = true;
            this.homeAddress = this.records[0].fields;
            this.addressToShow = (this.homeAddress.Address_Line_1__c.value) + ((this.homeAddress.Address_Line_2__c.value)?', ' +this.homeAddress.Address_Line_2__c.value:'') + ((this.homeAddress.Address_Line_3__c.value)?', ' +this.homeAddress.Address_Line_3__c.value:'') + ((this.homeAddress.Address_Line_4__c.value)?', ' +this.homeAddress.Address_Line_4__c.value:'');
            this.noHomeAddress = false;
          }else{
            this.noHomeAddress = true;
          }
          this.showSpinner = false;
          this.error = undefined;
        } else if (error) {
          console.log(JSON.stringify(error));
          this.error = error;
          this.records = undefined;
        }
      }

      handleCreate(){
        this.isCreateRecord = true;
      }

      handleClose(){
        this.isCreateRecord = false;
      }

      handleCreateSuccess(){
        refreshApex(this.wiredData);
        this.isCreateRecord = false;
        let message = this.editRecordId ? 'Home Address Edited Successfuly !':'Home Address Created Successfuly !';
        const event = new ShowToastEvent({
            title: message,
            variant:'success'
        });
        this.dispatchEvent(event);
      }

      handleError(){
        this.showSpinner = false;
        //this.isCreateRecord = false;
      }

      handleSubmit(event){
        this.showSpinner = true;
        event.preventDefault();  
        const fields = event.detail.fields;
        fields.Is_Home_Address__c = true;
        fields.Transfer_Status__c = 'N/A';
        this.template.querySelector('lightning-record-edit-form').submit(fields);
      }

      handleEdit(){
        this.editRecordId = this.homeAddress.Id.value;
        this.headerTitle = 'Edit Home Address';
        this.isCreateRecord = true;
      }
}