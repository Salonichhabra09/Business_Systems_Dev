import { LightningElement,api,wire,track } from 'lwc';
import getWhiteSpaceOpportunitiesDetails from '@salesforce/apex/WhiteSpaceOpportunityController.getWhiteSpaceOpportunitiesDetails';
import getConvertedWhiteSpaceOpportunities from '@salesforce/apex/WhiteSpaceOpportunityController.getConvertedWhiteSpaceOpportunities';
import NEXT_STEP from '@salesforce/schema/Whitespace_Potential_Opportunity__c.Next_Step_s__c';
import ACCOUNT_PLAN from '@salesforce/schema/Whitespace_Potential_Opportunity__c.Account_Plan__c';
import ANY_HELP_NEEDED from '@salesforce/schema/Whitespace_Potential_Opportunity__c.Any_help_needed__c';
import STATUS from '@salesforce/schema/Whitespace_Potential_Opportunity__c.Status__c';
import CONTACT from '@salesforce/schema/Whitespace_Potential_Opportunity__c.Who_do_you_need_to_speak_to__c';
import SOLUTION from '@salesforce/schema/Whitespace_Potential_Opportunity__c.Solution__c';
import POTENTIAL_VALUE from '@salesforce/schema/Whitespace_Potential_Opportunity__c.Potential_Value__c';
import OPPORTUNITY from '@salesforce/schema/Whitespace_Potential_Opportunity__c.Opportunity__c';
import STRATEGY from '@salesforce/schema/Whitespace_Potential_Opportunity__c.Strategy_and_Goals__c';
import CURRENCY from '@salesforce/schema/Whitespace_Potential_Opportunity__c.CurrencyIsoCode';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex'
import convertToOpportunity from '@salesforce/apex/WhiteSpaceOpportunityController.convertToOpportunity';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';


export default class WhiteSpaceOpportunitiesOnAccountPlan extends LightningElement {

    @api recordId;
    @api isAccPlanRetired;
    isAccountPlanUnderReview;
    accountPlanIdFromStrategy;
    objectApiName = 'Whitespace_Potential_Opportunity__c';
    showSpinner = false;
    fields = {ACCOUNT_PLAN,STATUS,STRATEGY,CONTACT,CURRENCY,POTENTIAL_VALUE,OPPORTUNITY,SOLUTION,NEXT_STEP,ANY_HELP_NEEDED};
    openModal = false;
    actions = [];
    fieldValues = {};
    wsOpportunityData;
    convertedOpportunityData;
    wiredData;
    modalTitle;
    isOnAccountPlan = false;
    relatedListClass = '';
    strategyId;
    filterForContact;
    filterForStrategy;
    selectedContactValue;
    selectedStrategyValue;
    showErrorMessage =false;
    currencyFromAccount;
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset;
    @track recordsToDisplayConverted = [];
    @track rowNumberOffsetConverted;
    isDataLoaded = false;
    activeSection = 'Potential';
    convertedPagination = true;
    potentialPagination = true;
    totalPotentialValue;
    closedWonSalesValue;
    openSalesValue;
    totalSalesValue;
    isButtonDisabled = false;

    getRowActions( row, doneCallback ) {
        const actions = [];
        if ( row.opportunityUrl ) {
            actions.push( {
                'label': 'Convert',
                'name': 'convert',
                'disabled' : true
            } );
            actions.push({
                'label': 'Edit',
                'name': 'edit',
                'disabled' : true
            });
        } 
        else{
            actions.push( {
                'label': 'Convert',
                'name': 'convert'
            } );
            actions.push({
                'label': 'Edit',
                'name': 'edit'
            });
        }
        setTimeout( () => {
            doneCallback( actions );
        }, 100 );
    }
    
    @track columns = [
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

    @track columnsForStrategy = [
        { label: 'Strategy', fieldName: 'strategyUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'strategyName'},target:'_blank' }},
        { label: 'Opportunity', fieldName: 'opportunityUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'opportunityName'},target:'_blank' }},
        { label: 'Status', fieldName: 'status',hideDefaultActions:true},
        { label: 'Who do you need to speak to?', fieldName: 'contactUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'contactName'},target:'_blank' }},
        { label: 'Potential Value', fieldName: 'potentialValueWithCurrency',hideDefaultActions:true},
        { label: 'Solution', fieldName: 'solution',wrapText:true,hideDefaultActions:true },
    ];

    @track columnsForConverted = [
        { label: '', fieldName: 'serialNumber',hideDefaultActions:true,fixedWidth:50},
        { label: 'Strategy', fieldName: 'strategyUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'strategyName'},target:'_blank' }},
        { label: 'Opp. Nickname', fieldName: 'opportunityNickname',hideDefaultActions:true,wrapText:true},
        { label: 'Opportunity', fieldName: 'opportunityUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'opportunityName'},target:'_blank' }},
        { label: 'Status', fieldName: 'status',hideDefaultActions:true,wrapText:true},
        { label: 'Primary Contact', fieldName: 'contactUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'contactName'},target:'_blank' }},
        { label: 'Sales Price', fieldName: 'salesPriceWithCurrency',hideDefaultActions:true},
        { label: 'Close Date', fieldName: 'closeDate',hideDefaultActions:true,wrapText:true },
        { label: 'Stage', fieldName: 'stageName',wrapText:true,hideDefaultActions:true },
    ];

    @track columnsToUse = [];
  
    @wire(getWhiteSpaceOpportunitiesDetails,({recordId:'$recordId'}))
    getOpenOpportunitiesDetails(value){
        this.wiredData = value;
        const { error, data } = value;
        if (error) {
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error',
                message:this.error.body.message,
                variant:'error'
            });
            this.dispatchEvent(event);
        } else if (data) {
            console.log(data);
            if(data.MessageType=='Success'){
            if(data.detailsWrapper.whiteSpaceOppList.length>0){
                this.wsOpportunityData = data.detailsWrapper.whiteSpaceOppList;
            }else{
                this.wsOpportunityData = undefined;
            }
            this.isAccountPlanUnderReview = data.detailsWrapper.isAccountPlanUnderReview;
            this.currencyFromAccount = data.detailsWrapper.currencyFromAccount;
            let tempColumns=[];
            if(data.detailsWrapper.accountPlanId){
                this.isOnAccountPlan = false;
                this.relatedListClass = 'slds-border_left slds-border_right slds-border_top slds-border_bottom slds-p-around_medium';
                this.accountPlanIdFromStrategy = data.detailsWrapper.accountPlanId;
                this.strategyId = this.recordId;
                if(!data.detailsWrapper.isAccountPlanUnderReview && !this.isAccPlanRetired){
                    tempColumns = this.columnsForStrategy.concat([{ type: 'action', typeAttributes: { rowActions: this.getRowActions, menuAlignment: 'auto' }}]);
                }else{
                    tempColumns = this.columnsForStrategy;
                }
                this.columnsToUse = tempColumns;
            }else{
                this.totalPotentialValue = data.detailsWrapper.totalPotentialValue;
                this.isOnAccountPlan = true;
                if(!data.detailsWrapper.isAccountPlanUnderReview && !this.isAccPlanRetired){
                    tempColumns = this.columns.concat([{ type: 'action', typeAttributes: { rowActions: this.getRowActions, menuAlignment: 'auto' }}]);
                }else{
                    tempColumns = this.columns;
                }
                this.columnsToUse = tempColumns;
            }
            this.potentialPagination = true;
            this.isDataLoaded = true;
            this.error = undefined;
            this.filterForStrategy = 'Account_Plan__c=\''+this.accountPlanIdFromStrategy+'\'';
            this.filterForContact =  'AccountId=\''+data.detailsWrapper.accountId+'\'';
            this.isButtonDisabled = this.isAccPlanRetired || this.isAccountPlanUnderReview?true:false ;
        }else{
            const event = new ShowToastEvent({
                title: 'Error',
                message:data.Message,
                variant:'error'
            });
            this.dispatchEvent(event);
        }
    }
    }

    connectedCallback(){
        if(!this.accountPlanIdFromStrategy){
            this.accountPlanIdFromStrategy = this.recordId;
        }
    }

    handleConvertToOpp(event){
        this.showSpinner = true;
        const action = event.detail.action;
        const row = event.detail.row;
        if(action.name=='convert'){
            convertToOpportunity({accountPlanId : this.accountPlanIdFromStrategy ,wsOpp: row}).then(Response => {
                this.showSpinner = false;
                if(Response.MessageType=='Success'){
                const event = new ShowToastEvent({
                    title: 'Success!',
                    variant:'success'
                });
                this.dispatchEvent(event);
                this.potentialPagination = false;
                refreshApex(this.wiredData);
                if(!this.isOnAccountPlan){
                    this.dispatchEvent(new RefreshEvent());         
                }
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:Response.Message,
                    variant:'error'
                });
                this.dispatchEvent(event);
            }
            }).catch(error => {
                this.showSpinner = false;
                let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message,
                    variant: 'error',
                }),
            );
            });
        }
        else if(action.name=='edit'){
            this.modalTitle = 'Edit White Space Potential Opportunity';
            this.fieldValues.contact = row.contactId;
            this.selectedContactValue = row.contactId;
            this.fieldValues.contactName = row.contactName;
            this.fieldValues.potentialValue = row.potentialValue;
            this.fieldValues.nextStep = row.nextStep;
            this.fieldValues.solution = row.solution;
            this.fieldValues.helpNeeded = row.helpNeeded;
            this.fieldValues.whiteSpaceId = row.whiteSpaceOppId;
            this.fieldValues.strategyId = row.strategy;
            this.selectedStrategyValue = row.strategy;
            this.fieldValues.strategyName = row.strategyName;
            this.fieldValues.currency = row.whiteSpaceCurrency;
            this.showSpinner = false;
            this.openModal = true;
        }
    }

    handleSuccess(){
        const event = new ShowToastEvent({
            title: 'Success!',
            variant:'success'
        });
        this.dispatchEvent(event);
        this.potentialPagination = false;
        refreshApex(this.wiredData);
        this.closeModal();
    }

    handleError(){
        this.showSpinner = false;
    }

    handleSubmit(event){
        this.showSpinner = true;
        event.preventDefault();  
        let customLookups = this.template.querySelectorAll('c-custom-lookup-component');
        if(!this.selectedContactValue) {
            customLookups[0].handleRequiredFieldValidation('contact');
            this.showSpinner = false;
            this.showErrorMessage = true;
        }if(!this.selectedStrategyValue && this.isOnAccountPlan){
            customLookups[1].handleRequiredFieldValidation('strategy');
            this.showSpinner = false;
            this.showErrorMessage = true;
        }
        if(this.selectedContactValue && (this.selectedStrategyValue || !this.isOnAccountPlan)){
        const fields = event.detail.fields;
        fields.Who_do_you_need_to_speak_to__c = this.selectedContactValue;
        if(!this.strategyId){
            fields.Strategy_and_Goals__c = this.selectedStrategyValue;
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    }

    openModalPopup(){
        this.modalTitle = 'Create White Space Potential Opportunity';
        this.openModal = true;
    }

    closeModal(){
        this.openModal = false;
        this.showSpinner = false;
        this.fieldValues = {};
        this.selectedContactValue = undefined;
        this.selectedStrategyValue = undefined;
        this.showErrorMessage = false;
    }

    handleContactSelection(event){
        this.selectedContactValue = event.detail;
    }

    handleStrategySelection(event){
        this.selectedStrategyValue = event.detail;
    }

    handleContactRemoval(){
        this.selectedContactValue = undefined;
    }

    handleStrategyRemoval(){
        this.selectedStrategyValue = undefined;
    }

    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }

    handlePaginatorChangeForConverted(event){
        this.recordsToDisplayConverted = event.detail;
        this.rowNumberOffsetConverted = this.recordsToDisplayConverted[0].rowNumber-1;
    }
    
    handleSectionToggle(){
            this.convertedPagination = false;
            getConvertedWhiteSpaceOpportunities({recordId : this.recordId}).then(Response => {
                if(Response.MessageType=='Success'){
                    if(Response.listWrapper.whiteSpaceOppList.length>0){
                        this.convertedOpportunityData = Response.listWrapper.whiteSpaceOppList;
                    }
                    this.closedWonSalesValue = Response.listWrapper.closedWonSalesValue;
                    this.openSalesValue = Response.listWrapper.openSalesValue;
                    this.totalSalesValue = Response.listWrapper.totalSalesValue;
                    this.convertedPagination = true;
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: Response.Message,
                            variant: 'error',
                        }),
                    );
                }
            }).catch(error => {
                this.showSpinner = false;
                let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message,
                    variant: 'error',
                }),
            );
            });
    }

}