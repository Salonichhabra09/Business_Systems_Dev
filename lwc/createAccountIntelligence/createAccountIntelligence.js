import { LightningElement,api,wire,track } from 'lwc';
import getSystemData from '@salesforce/apex/getAccountIntelligenceData.getSystemDetails'; 
import getSystem from '@salesforce/apex/getAccountIntelligenceData.getSystem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex'

export default class CreateAccountIntelligence extends LightningElement {
    @api recordId;
    @api isRetired = false;//SSE-23166
    @track showNew = false;
    systemData;
    wiredData;
    openModal = false;
    modalTitle='';
    showSpinner = false;
    fieldValues ={}
    systemID;
    objectApiName = 'Account_Intelligence__c';
    accId;
    Status;
    Currency;
    @track showMessage = false;
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset;
    paginationVisible = true;
    wiredData;
    recordTypeId;
    isModalPopupSystem = false;


    columns = [
        { label: '', fieldName: 'serialNumber',hideDefaultActions:true,fixedWidth:40},
        { label: 'Account Intelligence Name', fieldName: 'aiUrl',type:'url',
        wrapText:true,hideDefaultActions:true,
        typeAttributes: { label: { fieldName: 'technology' },target:'_blank' } },
        { label: 'HRMS System', fieldName: 'systemURL',type:'url' , 
        wrapText:true,hideDefaultActions:true, 
        typeAttributes: { label: { fieldName: 'systemName' },target:'_blank' }},
        { label: 'Short Description', fieldName: 'Description',wrapText:true,hideDefaultActions:true},
        { label: 'Technographic Category', fieldName: 'technographicCategory',wrapText:true,hideDefaultActions:true },
        { label: 'Sub Category', fieldName: 'subCategory',wrapText:true,hideDefaultActions:true },
        { label: 'Technology', fieldName: 'technology',wrapText:true,hideDefaultActions:true }
        // { label: 'Account Intelligence Type', fieldName: 'Type',wrapText:true,hideDefaultActions:true },
    ];
    @track technology = '';
    @track technographicCategory = '';
    @track subCategory = '';

    getFieldsValues(event){
        this.technology = '';
        this.technographicCategory = '';
        this.subCategory = '';

        let value = event.currentTarget.value;
        if(value){
        getSystem({ 
            systemId: value
        })
        .then(res => {
            var result = JSON.parse(JSON.stringify(res));
            if(result.MessageType=='Success'){
                if(result.systemRecord != null){
                    this.technology = (result.systemRecord.Technology__c)?result.systemRecord.Technology__c:null;
                    this.technographicCategory = (result.systemRecord.Technographic_Category__c)?result.systemRecord.Technographic_Category__c:null;
                    this.subCategory = (result.systemRecord.Sub_Category__c)?result.systemRecord.Sub_Category__c:null;
                }
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:result.Message,
                    variant:'error'
                });
                this.dispatchEvent(event);
            }
        })
        .catch(error => {
            let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
            const event = new ShowToastEvent({
                title: 'Error!',
                message:message,
                variant:'error'
            });
            this.dispatchEvent(event);
        });
    }
    }

    // connectedCallback(){
    //     getSystemData({accountPlanId:this.recordId }).then(Response => {

    //         console.log('this--Daata -- ', Response);
    //         this.systemData = Response.aiData;
    //         this.accId = Response.AccountId;
    //         this.Status = Response.Status;
    //         this.Currency = Response.currCode;
    //         if( this.Status == 'In Review'){
    //             this.showNew = false;
    //         }
    //         else{
    //             this.showNew = true;
    //         }
    //         if(Response.aiData.length <= 0){
    //             this.showMessage = true;
    //         }
    //         else if(Response.aiData.length > 0){
    //             this.showMessage = false;
    //         }
    //         this.paginationVisible = true;
    //         console.log('Response-- > ' , Response)
    //     }).then(Error => {
    //         console.log('this--Error -- ', Error);
    //     })
    // }

    @wire(getSystemData,({accountPlanId:'$recordId'}))
    getSystemData(value){
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
            this.systemData = data.aiData;
            this.accId = data.AccountId;
            this.Status = data.Status;
            this.recordTypeId = data.genericRecordTypeId;
            this.Currency = data.currCode;
            if( this.Status == 'In Review' || this.Status == 'Retired'|| this.isRetired == true){
                this.showNew = false;
            }
            else{
                this.showNew = true;
            }
            if(data.aiData.length <= 0){
                this.showMessage = true;
            }
            else if(data.aiData.length > 0){
                this.showMessage = false;
            }
            this.paginationVisible = true;
            this.error = undefined;
        }
    }


    openModalPopup(){
        this.technology = '';
        this.technographicCategory = '';
        this.subCategory = '';
        this.modalTitle = 'Create Account Intelligence';
        this.openModal = true;
    }

    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }

    closeModal(){
        this.openModal = false;
        this.showSpinner = false;
    }

    handleSave(){
        this.showSpinner = true;
    }

    handleError(){
        this.showSpinner = false;
    }

    handleSuccess(){
        const event = new ShowToastEvent({
            title: 'Success!',
            variant: 'Success',
            mode:'pester',
            message: 'Account Intelligence is created Successfully'
        });
        this.dispatchEvent(event);
        this.paginationVisible = false;
        refreshApex(this.wiredData);
        this.closeModal();
    }

    handleSubmit(event){

        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.CurrencyIsoCode = this.Currency;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    openModalPopupSystem(){
        this.isModalPopupSystem = true;
    }

    closeSystemModal(){
        this.isModalPopupSystem = false;
    }

    handleSuccessSystem(event) {
        this.isModalPopupSystem = false;
        const evt = new ShowToastEvent({
          title: 'Success !',
          message: 'System created Successfully',
          variant: 'success',
        });
        
        this.dispatchEvent(evt);
    
      }

}