import { LightningElement,api,wire,track } from 'lwc';
import getOpenOpportunitiesDetails from '@salesforce/apex/CurrentPipelineController.getOpenOpportunitiesDetails';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CurrentOpportunitiesPipeline extends NavigationMixin(LightningElement) {

    @api recordId;
    @api isAccountPlanUnderReview;
    @api isAccPlanRetired;
    currentTab = 'Cross Sell';
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset;

    actions = [
        { label: 'Email', name: 'email' },
        { label: 'New Task', name: 'newTask' },
        { label: 'New Event', name: 'newEvent'}
    ];
    
    columns = [
        { label: '', fieldName: 'serialNumber',hideDefaultActions:true,fixedWidth:40},
        { label: 'Name', fieldName: 'opportunityUrl',type:'url',hideDefaultActions:true,typeAttributes: { label: { fieldName: 'opportunityName' },target:'_blank' } },
        { label: 'Opp. Nickname', fieldName: 'opportunityNickname',hideDefaultActions:true, wrapText:true },
        { label: 'Account Number', fieldName: 'dNumber',hideDefaultActions:true,wrapText:true},
        { label: 'Stage', fieldName: 'stageName',hideDefaultActions:true,wrapText:true},
        { label: 'Est. Booking Value', fieldName: 'amountWithCurrency',hideDefaultActions:true},
        { label: 'Est. Close Date ', fieldName: 'closeDate',hideDefaultActions:true},
        { label: 'Contract Length', fieldName: 'contractLength',hideDefaultActions:true},
        { label: 'Renewal Start Date', fieldName: 'renewalDate',hideDefaultActions:true},
        { label: 'Account BU', fieldName: 'accountBU',hideDefaultActions:true, wrapText:true },
        { label: 'Next Step(s)', fieldName: 'nextStep',hideDefaultActions:true,wrapText:true},
        { label: 'Solution', fieldName: 'solution',wrapText:true,hideDefaultActions:true },
    ];

    opportunityData;
    totalSalesValue;
    isLoaded = false;

    @wire(getOpenOpportunitiesDetails,({accountPlanId:'$recordId',businessType:'$currentTab'}))
    getOpenOpportunitiesDetails({ error, data }) {
        if (error) {
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error!',
                message:error.body.message,
                variant:'error'
            });
            this.dispatchEvent(event);
        } else if (data) {
            if(data.currentPipeline.length>0){
                this.opportunityData = data.currentPipeline;
            }
            this.totalSalesValue = data.totalSalesValue;
            this.error = undefined;
            let tempColumns = [];
            if(!this.isLoaded && (!this.isAccountPlanUnderReview || !this.isAccPlanRetired)){
                tempColumns = this.columns.concat([{ type: 'action', typeAttributes: { rowActions: this.actions, menuAlignment: 'auto' } }]);
                this.columns = tempColumns;
                this.isLoaded = true;
            }
        }
    }

    handleSectionToggle(event){
        this.opportunityData = undefined;
        this.currentTab = event.target.name;
    }

    handleSendEmail(event){
        const action = event.detail.action;
        const row = event.detail.row;
        let pageRef ={};
        switch (action.name) {
            case 'email':
                pageRef = {
                    type: "standard__quickAction",
                    attributes: {
                        apiName:"Global.SendEmail"
                    },
                    state: {
                        recordId: row.oppId
                    }
                };
                break;
            case 'newTask':
                pageRef = {
                    type: "standard__quickAction",
                    attributes: {
                        apiName:"Global.NewTask"
                    },
                    state: {
                        recordId: row.oppId
                    }
                };
                break;
            case 'newEvent':
                pageRef = {
                    type: "standard__quickAction",
                    attributes: {
                        apiName:"Global.NewEvent"
                    },
                    state: {
                        recordId: row.oppId
                    }
                };
                break;

 }
        
        this[NavigationMixin.Navigate](pageRef);
    }

    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }

}