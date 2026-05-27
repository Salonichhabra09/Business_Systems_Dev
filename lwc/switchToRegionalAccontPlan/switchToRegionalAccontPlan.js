import { LightningElement , api,track,wire} from 'lwc';
import checkRegionalAccountPlanExist from '@salesforce/apex/switchToRegionalAccountPlanController.checkRegionalAccountPlanExist';
import getStrategyandWhiteSpaceData from '@salesforce/apex/switchToRegionalAccountPlanController.getStrategyandWhiteSpaceData';
import mergeCurrentAndRegionalAP from '@salesforce/apex/switchToRegionalAccountPlanController.mergeCurrentAndRegionalAP';
import convertAccPlanToRegional from '@salesforce/apex/switchToRegionalAccountPlanController.convertAccPlanToRegional';
import convertAccPlanToGlobal from '@salesforce/apex/switchToRegionalAccountPlanController.convertAccPlanToGlobal';
import checkUserAccessOnAP from '@salesforce/apex/AccountPlanDataFetch.checkUserAccessOnAP';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';


export default class SwitchToRegionalAccontPlan extends LightningElement {
    @api recordId;
    @track showSwitchToRegional = false;
    @track showModal = false;
    regionalAPId;
    strategyData;
    whitespaceData;
    selectedStrategyFinal;
    @track selectedWSFinal;
    @track showApplicableForRegional = false;
    @track showSpinner = false;
    @track showApplicableForGlobalAndRegional = false;
    @track showApplicableForGlobal = false;
    @track showSwitchToRegionalAndGlobal = false;

    strategyColumns=[
        { label: '', fieldName: 'SNo',hideDefaultActions:true,fixedWidth:50},
        { label: 'Name', fieldName: 'strategyUrl',type:'url',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'strategyName' },linkUrl:{ fieldName: 'strategyUrl' },target:'_blank'} },
        { label: 'Strategy Type', fieldName: 'type',hideDefaultActions:true,wrapText:true},
        { label: 'Strategy Status', fieldName: 'status',hideDefaultActions:true ,wrapText:true,},
        { label: 'Solution / Product Area', fieldName: 'productSolution',wrapText:true,hideDefaultActions:true, wrapText:true },
        { label: 'Key Contact Sponsor', fieldName: 'contactUrl',type:'url',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'contactName' },target:'_blank' } },
        { label: 'Short / Long Term', fieldName: 'term',hideDefaultActions:true},
        { label: 'Est. Completion Date', fieldName: 'estimatedCompletionDate',wrapText:true,hideDefaultActions:true },

    ];

    whiteSpaceColumns = [
        { label: '', fieldName: 'serialNumber',hideDefaultActions:true,fixedWidth:50},
        { label: 'Strategy', fieldName: 'strategyUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'strategyName'},target:'_blank' }},
        // { label: 'Opportunity', fieldName: 'opportunityUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'opportunityName'},target:'_blank' }},
        { label: 'Status', fieldName: 'status',hideDefaultActions:true},
        { label: 'Who do you need to speak to?', fieldName: 'contactUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'contactName'},target:'_blank' }},
        { label: 'Potential Value', fieldName: 'potentialValueWithCurrency',hideDefaultActions:true},
        { label: 'Account BU', fieldName: 'accountBU',hideDefaultActions:true, wrapText:true },
        { label: 'Next Step(s)', fieldName: 'nextStep',hideDefaultActions:true,wrapText:true },
        { label: 'Solution', fieldName: 'solution',wrapText:true,hideDefaultActions:true },
        { label: 'Help Needed', fieldName: 'helpNeeded',wrapText:true,hideDefaultActions:true },
    ];

    connectedCallback(){
        checkRegionalAccountPlanExist({apId : this.recordId}).then(Response => {

            if(Response){
                if(Response.MessageType == 'Success' && Response.Message == 'Regional Account Plan Found'){
                    this.showSwitchToRegional = true;
                    this.regionalAPId = Response.accountPlanId;
                    this.showApplicableForRegional = Response.ApplicableForRegional;
                    this.showApplicableForGlobal = Response.ApplicableForGlobal;
                }
                else{
                    this.showApplicableForRegional = Response.ApplicableForRegional;
                    this.showSwitchToRegional = false;
                    this.showApplicableForGlobal = Response.ApplicableForGlobal;
                }

                if( this.showApplicableForGlobal == true && this.showApplicableForRegional == true){
                    this.showApplicableForRegional = false;
                    this.showApplicableForGlobalAndRegional = true;
                    this.showApplicableForGlobal = false;
                    this.showSwitchToRegional = false;
                }

                if(this.showApplicableForGlobal == true && this.showSwitchToRegional == true){
                    this.showApplicableForRegional = false;
                    this.showApplicableForGlobalAndRegional = false;
                    this.showApplicableForGlobal = false;
                    this.showSwitchToRegional = false;
                    this.showSwitchToRegionalAndGlobal = true;
                }
            }
        }).catch(error => {
                 console.log(error);
        })

        //Added as part of SSE-23166
        checkUserAccessOnAP({accountplanId : this.recordId}).then(Response=>{
            
        
                if(Response == 'Read'){         
                        this.showApplicableForRegional = false;
                        this.showApplicableForGlobalAndRegional = false;
                        this.showApplicableForGlobal = false;
                        this.showSwitchToRegional = false;
                        this.showSwitchToRegionalAndGlobal = false;
                        this.showSpinner = false;
                        this.showModal = false;
                     
                
                 }
                 }).catch(Error=>{
                     console.log('in error--->' , JSON.stringify(error));
                 })
                 
    }
    handleConvertAccPlan(){
        this.showSpinner = true;
        convertAccPlanToRegional({apId : this.recordId }).then(Response => {
            if(Response){
                if(Response.MessageType == 'Success'){
                    
                    this.ShowToastEvent('Success' ,'Account Plan have been converted to Regional Successfully!' ,'Success');
                   window.location.reload(); 

                    this.showSpinner = false;
                    this.showApplicableForRegional = false;
                    this.showSwitchToRegional = false;
                    this.showApplicableForGlobalAndRegional = false;
                    this.showApplicableForGlobal = false;
                }
                else{
                    this.ShowToastEvent('Error Occuerd!' ,Response.Message ,'Error');
                    window.location.reload(); 

                    this.showSpinner = false;
                }
            }
        }).catch(Error => {

        })
    }

    handleSwitchAccPlan(){
        getStrategyandWhiteSpaceData({apId : this.recordId}).then(Response => {
         if(Response){
            if(Response.MessageType == 'Success'){
            if(Response.strategyWrapper.strategyList.length > 0){
               this.strategyData = Response.strategyWrapper.strategyList;
            }
            else{
                this.strategyData ='';
            }
            if(Response.whiteSpaceWrapper.detailsWrapper.whiteSpaceOppList.length > 0){
               this.whitespaceData =  Response.whiteSpaceWrapper.detailsWrapper.whiteSpaceOppList;
            }
            else{
                this.whitespaceData = '';
            }
            }
         }
        }).catch(error => {
            console.log(error);
        })
        this.showModal = true;
    }

    closeModal(event){
        this.showModal = false;
    }
    switchAP(event){
        this.showSpinner = true;
        let strategyList = [];
        let wsList = [];
        if(this.selectedStrategyFinal != '' && this.selectedStrategyFinal != null && typeof(this.selectedStrategyFinal) != 'undefined'){
            this.selectedStrategyFinal.forEach(element => {
                strategyList.push(element.strategyId);
            });
        }
      
        
        if(this.selectedWSFinal != '' && this.selectedWSFinal != null && typeof(this.selectedWSFinal) != 'undefined'){
        this.selectedWSFinal.forEach(element => {
            wsList.push(element.whiteSpaceOppId);
        });
    }
        mergeCurrentAndRegionalAP({ currentAPId: this.recordId , regionalAPId : this.regionalAPId ,
            stList : strategyList , wsList : wsList}).then(Response => {

                if(Response){
                    if(Response.MessageType == 'Success'){
                        this.ShowToastEvent('Success' ,'Account Plan have been switched to Regional Successfully!' ,'Success');
                        this.showModal=false;
                        this.showSpinner = false;
                        window.location.reload(); 
    
                    }
                    else if(Response.MessageType == 'ERROR'){
                    
                        this.ShowToastEvent('Error Occuerd!' ,Response.Message ,'Error');
                        this.showSpinner = false; 
                    }
                }
        }).catch(error => {
            console.log(error);
        })
    }

    handleStrategySelection(event){
       
        this.selectedStrategyFinal = event.detail.selectedRows;
    }

    handleWhiteSpaceSelection(event){
       
        this.selectedWSFinal = event.detail.selectedRows;
       

        
    }

    ShowToastEvent(title,message,variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleConvertAccPlanToGlobal(){
        

        this.showSpinner = true;
        convertAccPlanToGlobal({apId : this.recordId }).then(Response => {
            if(Response){
                if(Response.MessageType == 'Success'){
                    
                    this.ShowToastEvent('Success' ,'Account Plan have been converted to Global Successfully!' ,'Success');
                   window.location.reload(); 

                    this.showSpinner = false;
                    this.showApplicableForRegional = false;
                    this.showApplicableForGlobalAndRegional = false;
                    this.showApplicableForGlobal = false;
                }
                else{
                    this.ShowToastEvent('Error Occuerd!' ,Response.Message ,'Error');
                    window.location.reload(); 

                    this.showSpinner = false;
                }
            }
        }).catch(Error => {

        })
    }
}