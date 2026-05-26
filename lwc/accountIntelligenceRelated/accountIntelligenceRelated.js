import { LightningElement,api,wire,track } from 'lwc';
import getSystemData from '@salesforce/apex/getAccountIntelligenceData.getSystemDetailsOpp'; 
import getSystem from '@salesforce/apex/getAccountIntelligenceData.getSystem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import {NavigationMixin} from 'lightning/navigation'


export default class CreateAccountIntelligence extends NavigationMixin(LightningElement) {
    strOutput;
    @api recordId;
    @track showNew = true;
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
    @track rowNumberOffset;
    wiredData;
    displayList;
    cardTitle = "Account Intelligence"
    opportunityName;
    error;
    data;
    recordTypeId;
    isModalPopupSystem = false;
    isAccountNotSanctioned = false;

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
    ];
    @track technology = '';
    @track technographicCategory = '';
    @track subCategory = '';
    Allrecords = true; // Controls the visibility of only 3 or all records 
    @track CallAuraRedirect = false; //calls aura on click of view all
    @api calledFromAura = false;
    @track selectedSystemId;

   /* @api handleChange1(){
        console.log('from child to lwc',this.systemData);
        this.Allrecords = false;    
        console.log(this.Allrecords);
    }*/

    fetchValue( event ) {

        console.log( 'Value from Child LWC is ' + event.detail );
        this.strOutput = event.detail;

    }

    @track progressValue = '';
    hanldeProgressValueChange(event) {
    this.progressValue = event.detail;
    console.log( 'Value from Child LWC is progress value' + this.progressValue );
  }
 
    
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

    @wire(getSystemData,({OppId:'$recordId'}))
    getSystemData(value){
        console.log('inside Wire' , this.recordId);
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
            let initialData = data.aiData;
            this.displayList = [...initialData].splice(0,3);
            this.accId = data.AccountId;
            this.Currency = data.currCode;
            this.opportunityName= data.oppName;
            this.recordTypeId = data.genericRecordTypeId;
            this.isAccountNotSanctioned = !data.isAccountSanctioned;
            if(data.aiData.length <= 0){
                
                this.cardTitle = "Account Intelligence (0)";
                if(this.calledFromAura){
                    this.Allrecords = false;
                    this.showMessage = false;
                    this.systemData =''
                }
                else{
                    this.Allrecords = true; 
                    this.showMessage = true;

                }
            }
            else if(data.aiData.length > 0){
                this.showMessage = false; 
                this.cardTitle = "Account Intelligence (" + data.aiData.length + ")" ;
                if(this.calledFromAura){
                    this.Allrecords = false;
                  
                }
                else{
                    this.Allrecords = true; 
                   
                }
            }
           
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

    closeModal(){
        this.openModal = false;
        this.showSpinner = false;
    }

    handleSave(){
        this.showSpinner = true;
    }

    handleSuccess(){
        const event = new ShowToastEvent({
            title: 'Success!',
            variant: 'Success',
            mode:'pester',
            message: 'Account Intelligence is created Successfully'
        });
        this.dispatchEvent(event);
        refreshApex(this.wiredData);
        this.closeModal();
    }

    handleSubmit(event){

        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.CurrencyIsoCode = this.Currency;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    callParent(event){
   
        console.log('from parent');
        refreshApex(this.wiredData); 
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: "c__relatedaccountintelligence"
                },
                state: {
                    c__recordId: this.recordId
                }
              
            });  
                         
    }

    navigateToOppRecordPage(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }


    navigateToOppObjectPage(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
          }
        }); 
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