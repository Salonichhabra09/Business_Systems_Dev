import { LightningElement , track ,api,wire} from 'lwc';
import generateAccountPlan from '@salesforce/apex/GenerateAccountPlanController.generateAccountPlan';
import openAccounPlan from '@salesforce/apex/GenerateAccountPlanController.openAccounPlan';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';



export default class CreateAccountPlanComponent extends NavigationMixin(LightningElement) {
   @api recordId; 
   //@track isgenerateAccountPlan = true;//SSE-21127(Account Plan Phase 3)
   @track isgenerateAccountPlan = false;//SSE-21127(Account Plan Phase 3)
   @track showWaring= false;
   @track Message = '';
   @track showMessageBool = false;
   @track openComponent = false;
   @track ErrorMessage = '';
   @track showErrorMessage = false;
   

   accountPlanId;
   wiredData;
   @track showSpinner = false;

//Account Plan Phase 4 changes start
   currentAccountPlan ='margin-left:20rem;margin-right:20rem';
   regionalAccountPlan;
   globalAccountPlan;
   @track showGlobal = false;
   @track showRegional = false;
   @track showAPList = false;
   @track apList;
   @track showGlobalOnAPList = false;

   apColoumns=[
    { label: 'Account Plan Name', fieldName: 'apURL',hideDefaultActions:true ,wrapText:true ,type:'url',
    typeAttributes: { label: { fieldName: 'apName' },linkUrl:{ fieldName: 'apURL' },target:'_blank' }
    },
    { label: 'Account Plan Type', fieldName: 'apType',hideDefaultActions:true,wrapText:true},
    { label: 'Date For Next Review', fieldName: 'nextReview',hideDefaultActions:true,wrapText:true},
   
];

  //Account Plan Phase 4 changes end


//Added as part of SSE-21127(Account Plan Phase 3)
@wire(openAccounPlan,{accountId:'$recordId'})
openAccounPlan(value ) {
    this.wiredData = value;
    const { data, error} = value;
    if(this.openComponent == false){
    if (data) {
        console.log(' this.wiredData',data);
        this.openComponent = true;
        
         if(data.Message == 'Account Plan Exists' ){
            /*if(((data.showGlobal == false) || (data.showGlobal == true && data.globalAPExists == true)) && 
            data.apList.length == 1 ){
                this.showGlobalOnAPList = false;
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: data.AccountPlanId,
                        actionName: 'view'
                    }
                }).then(url => {
                    window.open(url, "_blank");
                });
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            else if((data.showGlobal == true && data.globalAPExists == false)){
                this.showGlobalOnAPList = true;
                this.showAPList = true;
                this.isgenerateAccountPlan = false;
                this.apList = data.apList;
            }*/
         if(data.apList.length == 1){
            this.showGlobalOnAPList = false;
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: data.AccountPlanId,
                    actionName: 'view'
                }
            }).then(url => {
                window.open(url, "_blank");
            });
            this.dispatchEvent(new CloseActionScreenEvent());    
         }
            else if(data.apList.length > 1){
               this.showGlobalOnAPList = false; 
               this.showAPList = true;
               this.isgenerateAccountPlan = false;
               this.apList = data.apList;
            }
       
        }
         else if(data.Message == 'No Account Plan Found'){
          
            this.isgenerateAccountPlan= true;
            this.showGlobal = data.showGlobal;
            this.showRegional = data.showRegional;
           
         }
         else if(data.MessageType == 'ERROR'){
            this.isgenerateAccountPlan = false;
            this.showAPList = false;
            this.ErrorMessage = data.Message;
            this.showErrorMessage = true;

         }
         if( this.showRegional == true && this.showGlobal == true){
            this.currentAccountPlan = 'margin-left:25px;margin-right:25px';
            this.globalAccountPlan = 'margin-right:25px';
            this.regionalAccountPlan = 'margin-right:25px';
         }
         else if( this.showRegional == true && this.showGlobal == false){
            this.currentAccountPlan = 'margin-left:8rem';
            this.regionalAccountPlan = 'margin-right:25px';
         }
         else if( this.showRegional == false && this.showGlobal == true){
            this.currentAccountPlan = 'margin-left:8rem';
            this.globalAccountPlan = 'margin-right:25px';
         }
    } else if (error) {
        console.log(error);
        
    }
}
}

handleClose(){
    this.dispatchEvent(new CloseActionScreenEvent());
}
handleCreateAccPlan(event){
    this.showSpinner = true;
    let apType = event.currentTarget.dataset.id;
   
    generateAccountPlan({accountId : this.recordId ,
        apType : apType }).then(Response => {
        console.log('this.handleCreateAccPlan',Response);
        if(Response.MessageType == 'SUCCESS'){
           this.showWaring = true;
           console.log('Response.AccountPlanId' ,Response.AccountPlanId);
           this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: Response.AccountPlanId,
                    actionName: 'view'
                }
            }).then(url => {
                window.open(url, "_blank");
            });

           // this.dispatchEvent(new RefreshEvent()); 
            
            this.dispatchEvent(new CloseActionScreenEvent());
            refreshApex(this.wiredData);
             
           
            
        }
        else if(Response.MessageType == 'ERROR'){
            this.showToast('Error' , Response.Message);
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        
        }).catch(Error => {
        this.showToast('ERROR' , Error);
        console.log('Error',Error);
        })
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

}