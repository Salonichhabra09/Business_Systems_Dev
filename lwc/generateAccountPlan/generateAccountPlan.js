import { LightningElement , api , track ,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import fetchFields from '@salesforce/apex/HighlightPanelController.fetchFields';
import callapproval from '@salesforce/apex/GenerateAccountPlanController.callapproval';
import syncAccountPlan from '@salesforce/apex/GenerateAccountPlanController.syncAccountPlan';
//import cloneAccountPlan from '@salesforce/apex/GenerateAccountPlanController.cloneAccountPlan';
import updateLastContactedDetails from '@salesforce/apex/GenerateAccountPlanController.updateLastContactedDetails';
//import uploadFile from '@salesforce/apex/GenerateAccountPlanController.uploadFile';
import SystemAdminProfiles from '@salesforce/label/c.SystemAdminProfiles';
import { updateRecord } from 'lightning/uiRecordApi';
import Status_Value from '@salesforce/schema/Account_Plan__c.Account_Plan_Status__c';
import { getRecord } from 'lightning/uiRecordApi';


const FIELDS = ['Account_Plan__c.History_trend_Screenshot__c', 'Account_Plan__c.Contact_Relationship_Screenshot__c'];



export default class GenerateAccountPlan extends NavigationMixin(LightningElement) {
  
    @api recordId;
    @api inputDisabled;
    @api isUpdateTab;
    @api tabNameFromAura;
    @track pdfButton=false;

    @api objectApiName;
    @api fieldSet;
    nameField = '';
    fieldList = [];
    @track checkStatus = true;
    isStatusUnderReview = false;
    accountId = this.recordId;
    @track RequestRecords = [];
    @track challengeRecords = [];
    @track visionRecords = [];
    @track activeTab;
    @track date;
    @track checkButtonVisible;
    @track ClearVisible;
    @track isReadOnly;
    @track GeneratePDF = false;
    @track accountPlanObject;
    @track showAccountData = true;
    @track showSpinner= false;
    @track checkUnapprovedStrat = false;
    @track accplanId ;
    @track input = 'input';
    @track showActiveAPField= false;
    @track addReadOnly ='';

    accId;
    status;

    data;
    error;
    chartConfigurationForYearWise;
    accountPlanId='a2m3G0000003gLKQAY';
    imgUrl;
    isBulkTaskPopup = false;

    historyTrendBeforeEdit;
    contactRelationshipBeforeEdit;
    isDisabled = false;
    showSpinner = false;
    DaysForNextReview;
    filtersForContactHeirarchy;
    showContactHierarchyModal=true;    

    //activeSections = ["Basic Details","Usage Details","Organisation Overview","Customer Profile","Help needed","Biggest challenges to be overcome","Salesforce Overview","History of Total Spend" , "Contacts Relationship"];
    activeSections = ["Organisation Overview","Salesforce Overview","Customer Profile"];

    @track showEdit = true;
    @track showEditbutton = true;
    @track showSave = false;
    @track isFieldsChanged = false; // Change by Joana -> feddback: 3) Add message on click of Close or refresh browser tab. Don't let user cancel or refresh without saving account plan.

    @track apType;//Added as part of SSE-21663 Account Plan Phase 4 

    currentAccountFromParent;
    isAccPlanRetired = false;
    
    handleEditAP(event){
        this.isDisabled = true;
        this.showSpinner = true;
        this.handleAfterSave(); 
        /*event.preventDefault();  
          
        const fields = event.detail.fields;
        if(fields.History_trend_Screenshot__c!=this.historyTrendBeforeEdit ){
            console.log('History Trend --> ' , fields.History_trend_Screenshot__c);
        }
        if(fields.Contact_Relationship_Screenshot__c!=this.Contact_Relationship_Screenshot__c ){
            console.log('Contact_Relationship_Screenshot__c--> ' , fields.Contact_Relationship_Screenshot__c);
        }
        if(fields.History_trend_Screenshot__c!=this.historyTrendBeforeEdit || fields.Contact_Relationship_Screenshot__c!=this.contactRelationshipBeforeEdit){
            setTimeout(() => {  

            let historyTrendUpdated = fields.History_trend_Screenshot__c!=this.historyTrendBeforeEdit?true:false;
            let contactRelationshipUpdated = fields.Contact_Relationship_Screenshot__c!=this.contactRelationshipBeforeEdit?true:false;
            
            uploadFile({accountPlanId:this.recordId,
                        historyTrend:fields.History_trend_Screenshot__c,
                        contactRelationship:fields.Contact_Relationship_Screenshot__c,
                        historyTrendUpdated:historyTrendUpdated,
                        contactRelationshipUpdated:contactRelationshipUpdated}).then(Response => {
                this.historyTrendBeforeEdit = fields.History_trend_Screenshot__c;
                this.contactRelationshipBeforeEdit = fields.contactRelationshipBeforeEdit;
            }).catch(Error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error while uploading the screenshots. Please try again or contact system admin.',
                        variant: 'error',
                    }),
                );
            }).finally(() =>{
                this.handleAfterSave(fields);
            })
            
        }, 2000);
        }else{
            this.handleAfterSave(fields);   
        }*/
    }

    handleAfterSave(){
            //this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.showEdit = true;
            this.showEditbutton = true;
            this.isDisabled = false;
            this.showSpinner = false;
            this.isFieldsChanged = false; // Change by Joana -> feddback: 3) Add message on click of Close or refresh browser tab. Don't let user cancel or refresh without saving account plan.
    }

     //This is used to fetch the History Image and Contact Relationship Image currently present in the 
     //accountplan to compare whether the value is changed or not
    /* @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
     wiredRecord({ error, data }) {
         if (error) {
             let message = 'Unknown error';
             if (Array.isArray(error.body)) {
                 message = error.body.map(e => e.message).join(', ');
             } else if (typeof error.body.message === 'string') {
                 message = error.body.message;
             }
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Error!',
                     message,
                     variant: 'error',
                 }),
             );
         } else if (data) {
             this.historyTrendBeforeEdit = data.fields.History_trend_Screenshot__c.value;
             this.contactRelationshipBeforeEdit = data.fields.Contact_Relationship_Screenshot__c.value;
 
            
         }
     }*/

    handleSave(){
      
        this.showEdit = true;
        this.showEditbutton = true;
      //  this.showSave= false;
    }

    handleapproval(){
        callapproval({accountplanId : this.recordId}).then(Response => {
            
            if(Response.MessageType == 'SUCCESS'){
                this.showToast('SUCCESS' , Response.Message);
               this.connectedCallback();
               window.location.reload();
              
            }
            if(Response.MessageType == 'ERROR'){
               this.showToast('Error' , Response.Message);
             
           }
        }).catch(Error => {
            console.log(error);
        })
    }

    handleSuccess(){
        updateLastContactedDetails({accountplanId : this.recordId}).then(Response => {
             
             if(Response.MessageType == 'ERROR'){
                this.showToast('Error' , Response.Message);
              
            }
        }).catch(Error => {
          console.log(error);
        })
    }
    
    handleEdit(){
       
        this.showEdit = false;
        this.showEditbutton = false;
    }

    handleCancel(){
        this.showEdit = true;
        this.showEditbutton = true;
        this.isFieldsChanged = false; // Change by Joana -> feddback: 3) Add message on click of Close or refresh browser tab. Don't let user cancel or refresh without saving account plan.
    }

    handleGeneratePDF(){
        this.pdfButton = true;
        this.GeneratePDF = true;
    }
    
    handleSync(){
        syncAccountPlan({accountplanId : this.recordId}).then(Response => {
            if(Response.MessageType == 'SUCCESS'){
               
            
            }
            else if(Response.MessageType == 'ERROR'){
                this.showToast('Error' , Response.Message);
              
            }
        }).catch(error => {
            console.log('HEllo in error--->' , JSON.stringify(error));
           
            //this.showToast('ERROR' , error);
        })
    }

    connectedCallback() {
    
        fetchFields({
            recordId : this.recordId,
            objectName : this.objectApiName,
            fieldSetName : this.fieldSet
            
        }).then(result => {
            if(result) {
                 //Added as part of SSE-23166
               if(result.accessLevel == 'Read'){
                this.isAccPlanRetired = true;
                this.showEditbutton = false;
                this.checkUnapprovedStrat = false;
                this.checkStatus = false;
                this.showActiveAPField = true;
                this.isStatusUnderReview = true;
                
                this.addReadOnly = '(Read Only View)';
                
                this.handleSync();
                if(result.message != undefined) {
                    this.showToast('Error', 'error', result.message);
                    return;
                }
                this.nameField = result.nameField;
                this.fieldList = result.fieldsAPI;
                this.accId = result.AccountID;
                this.DaysForNextReview = result.DaysForNextReview;
                this.apType = result.AccountPlanType;//Added as part of SSE-21663 Account Plan Phase 4 
               }
                //Added as part of SSE-23166
               else if(result.accessLevel == 'Edit'){
                if(result.message != undefined) {
                    this.showToast('Error', 'error', result.message);
                    return;
                }
                this.nameField = result.nameField;
                this.fieldList = result.fieldsAPI;
                this.accId = result.AccountID;
                this.DaysForNextReview = result.DaysForNextReview;
                this.apType = result.AccountPlanType;//Added as part of SSE-21663 Account Plan Phase 4 
              
                if(result.Status  == 'Retired'){
                    this.isAccPlanRetired = true;
                    this.showEditbutton = false;
                    this.checkUnapprovedStrat = false;
                    this.checkStatus = false;
                    this.showActiveAPField = true;

                }
               else {
                this.showActiveAPField = false;
                if(result.UnapprovedStrat > 0){
                    this.checkUnapprovedStrat = true;
                }
                else if(result.UnapprovedStrat == 0 || result.Status  == 'In Review' ){
                    this.checkUnapprovedStrat = false;
                }
                
                if(result.Status  == 'In Review'){
                
                    this.checkStatus = false;
                    this.isStatusUnderReview =true;
                    this.showEditbutton = false;
                    this.checkUnapprovedStrat = false;
                }
                else if( result.Status  == 'Draft' || result.Status  == 'Rejected'  || result.Status  == 'Approved'){
                    
                    this.checkStatus = true;
                    this.isStatusUnderReview =false;
                    this.showEditbutton = true;
                    this.handleSync();

                }

                if(result.Status  != 'In Review' && result.DaysForNextReview >= 0){
                    this.checkUnapprovedStrat = true;
                }
            }
        }
            }
        }).catch(error => {
            if(error && error.body && error.body.message) {
                console.log('error' ,error );
                this.showToast('Error', 'error', error.body.message);
            }
        });
        this.accplanId = this.recordId;

        
       

        //Joana Changes for SSE-20681 and SSE-20718
            if(this.accId == null || this.accId == undefined){
                this.accId = localStorage.getItem('accId');
            }
            this.activeTab = localStorage.getItem('activeTab');
            localStorage.removeItem('activeTab');
            localStorage.removeItem('accId');
        //End joana changes SSE-20681 and SSE-20718


        // Change by Joana -> feddback: 3) Add message on click of Close or refresh browser tab. Don't let user cancel or refresh without saving account plan.
            window.addEventListener('beforeunload', this.handleBeforeUnload.bind(this));
        // End Joana Change -> feddback: 3)
    }


    // Change by Joana -> feddback: 3) Add message on click of Close or refresh browser tab. Don't let user cancel or refresh without saving account plan.
        disconnectedCallback() {
            window.removeEventListener('beforeunload', this.handleBeforeUnload.bind(this));
        }
        
        // function called from all input fields when form is edited
        handleFieldChange() { 
            this.isFieldsChanged = true;
        }

        handleBeforeUnload(event) {
            if (this.isFieldsChanged) {
                event.preventDefault();
                event.returnValue = '';
                // NOTE: The ability to customize the browser's confirmation dialog is limited by its security. 
                //       The behavior and appearance of the confirmation message may vary across different browsers. 
                //       Some browsers may not display the custom message and instead show a generic message for security reasons.
                const confirmationMessage = 'Please save Account Plan before closing/refreshing!';
                event.returnValue = confirmationMessage; // For older browsers
                return confirmationMessage; 
            }
        }
    // End Joana Change -> feddback: 3)
    
  /*  handleClone(){
        cloneAccountPlan({accountplanId : this.recordId}).then(Response => {
            console.log('this.handleCreateAccPlan',Response);
            if(Response.MessageType == 'SUCCESS'){
               // this.accountPlanId = Response.AccountPlanId;
               console.log('Response.AccountPlanId' ,Response.AccountPlanId);
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: Response.AccountPlanId,
                        actionName: 'view'
                    }
                }).then(url => {
                    console.log('Navigate--->');
                    window.open(url, "_blank");
                });
                
            }
            else if(Response.MessageType == 'ERROR'){
                console.log('HEllo in error--->');
                this.showToast('Error' , Response.Message);
              
            }
            
            }).catch(Error => {
            this.showToast('ERROR' , Error);
            consoel.log('Inside Clone Error--> ',Error )
            console.log('Error',Error.body);
            })
    }*/

    renderedCallback(){
        
        const style = document.createElement('style');
        style.innerText = `.input .slds-input[disabled] {
           background-color : rgb(248,248,248);
           border : none;
        }
        .input .slds-textarea[disabled] {
            background-color : rgb(248,248,248);
            border : none;
        
        
        }`;
        var temp = this.template.querySelector('div.input');
        if(temp != null){
            temp.appendChild(style);
        }
    }

    //Joana Changes for SSE-20681 and SSE-20718
        handleRefreshOnParent(){
           
            localStorage.setItem('activeTab', "Contact Relationship");
            localStorage.setItem('accId', this.accId);
            if(this.showContactHierarckyModal){
                this.showContactHierarchyModal = false;
                setTimeout(() => {
                    this.showContactHierarchyModal = true;
                }, 0); 
            }else{
                this.showContactHierarckyModal = true;
                setTimeout(() => {
                    this.showContactHierarckyModal = false;
                }, 0); 
            }
            window.location.reload();
            this.activeTab = localStorage.getItem('activeTab');
        }
    //End joana changes for SSE-20681 and SSE-20718
    

    handleTabChange(event){
        //Joana Changes for SSE-20681 and SSE-20718
            localStorage.removeItem('activeTab');
            localStorage.removeItem('accId');
        //End joana changes for SSE-20681 and SSE-20718 

        // Change by Joana -> feddback: 3) Show message when user tries to chnage component tab with unsaved changes. 
        //                                 Don't let user chnage tab without saving changes on account plan Information.
            this.activeTab = '';
            let tabname = event.target.value;

            if(tabname != 'Account Plan' && this.isFieldsChanged){
                event.preventDefault();
                this.activeTab = 'Account Plan';
                const toastEvent = new ShowToastEvent({
                    variant: 'warning',
                    title: 'Unsaved Changes',
                    message: 'Please save your changes on "Account Plan Information" before switching tabs.',
                    mode: 'dismissable',
                    duration: 8000 
                });
                this.dispatchEvent(toastEvent);
            }
        // END Change by Joana for feddback: 3) 

        /*
        //console.log(this.tabNameFromAura);
        let tabname = event.target.value;
        if(!this.isUpdateTab){
            this.activeTab = tabname;
            //console.log('Hello '+event.target.value);
             const answerEvent = new CustomEvent("updatetab", { detail: { tabname },});
             this.dispatchEvent(answerEvent); 
        }else if(this.isUpdateTab && !this.tabNameFromAura){
            this.activeTab = tabname;
        }else if(this.isUpdateTab && this.tabNameFromAura){
            this.activeTab = this.tabNameFromAura;
        }
        this.isUpdateTab = false;
        */
    }
   
    @track showContactHierarckyModal = false; 

    handleExpandContactHierarckyModal(){
        this.showContactHierarckyModal = true; 
    }

    closeExpandContactHierarckyModal() {
        this.showContactHierarckyModal = false;
    }

    handleFiltersForContactHeirarchy(event){
        this.filtersForContactHeirarchy = event.detail;
    }

    handleSelectionForContactHeirarchy(event){
        this.currentAccountFromParent = event.detail;
    }
      
    showToast(MessageType, Message){
     
        const event = new ShowToastEvent({
            title: MessageType,
            variant: MessageType,
            mode:'pester',
            message: Message
        });
        this.dispatchEvent(event);
    }

    handlenavigateaction(event){
        //console.log("inside parent--");
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accplanId,
                actionName: 'view'
            }
        });
    }

    // openBulkTaskPopup(){
    //     this.isBulkTaskPopup = true;
    // }

    // closeBulkTaskPopup(){
    //     this.isBulkTaskPopup = false;
    // }

    @track showPrintPdf = false;
    handlePrintPDF(){
        this.showPrintPdf = true;
    }

    handleClosPrintPDF(event){
      
        this.showPrintPdf = event.detail;
    }

    handleStrategyCreated(){
        this.connectedCallback();
    }

}