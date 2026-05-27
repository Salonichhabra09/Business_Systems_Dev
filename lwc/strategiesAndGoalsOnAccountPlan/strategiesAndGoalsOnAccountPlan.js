import { LightningElement,api,wire,track } from 'lwc';
import getStrategyAndGoalsDetails from '@salesforce/apex/StrategyAndGoalController.getStrategyAndGoalsDetails';
import getOpportunityDetails from '@salesforce/apex/StrategyAndGoalController.getOpportunityDetails';
import linkOrDelinkOpportunities from '@salesforce/apex/StrategyAndGoalController.linkOrDelinkOpportunities';
import NAME from '@salesforce/schema/Strategy_and_Goal__c.Strategy_Name__c';
import ACCOUNT_PLAN from '@salesforce/schema/Strategy_and_Goal__c.Account_Plan__c';
import ESTIMATED_COMPLETION_DATE from '@salesforce/schema/Strategy_and_Goal__c.Estimated_Completion_Date__c';
import STATUS from '@salesforce/schema/Strategy_and_Goal__c.Strategy_Status__c';
import CONTACT from '@salesforce/schema/Strategy_and_Goal__c.Key_Contact_Sponsor__c';
import SOLUTION from '@salesforce/schema/Strategy_and_Goal__c.Solution_Product_Area__c';
import TYPE from '@salesforce/schema/Strategy_and_Goal__c.Strategy_Type__c';
import BUSINESS_PROBLEM_ADDRESSED from '@salesforce/schema/Strategy_and_Goal__c.Business_Problem_Addressed__c';
import COMMENTS from '@salesforce/schema/Strategy_and_Goal__c.Comments_Next_Steps__c';
import MILESTONES from '@salesforce/schema/Strategy_and_Goal__c.Key_Milestones__c';
import RESOURCES from '@salesforce/schema/Strategy_and_Goal__c.Resources_Required__c';
import SOLUTION_GOAL from '@salesforce/schema/Strategy_and_Goal__c.Solution_Goal__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex'
import { NavigationMixin } from 'lightning/navigation';


export default class StrategiesAndGoalsOnAccountPlan extends NavigationMixin(LightningElement) {

    @api recordId;
    @api isAccountPlanUnderReview;

    actions = [
        { label: 'Link/De-link Opportunities', name: 'linkOrDelink' },
        { label: 'Email', name: 'email' },
        { label: 'New Task', name: 'newTask' },
        { label: 'New Event', name: 'newEvent'}
    ];
 
    columnsWithActions = [
      /*  { label: 'Name', fieldName: 'strategyUrl',type:'url',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'strategyName' },target:'_blank' } },
        { label: 'Est. Completion Date', fieldName: 'estimatedCompletionDate',wrapText:true,hideDefaultActions:true },
        { label: 'Short / Long Term', fieldName: 'term',hideDefaultActions:true},
        { label: 'Key Contact Sponsor', fieldName: 'contactUrl',type:'url',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'contactName' },target:'_blank' } },
        { label: 'Strategy Type', fieldName: 'type',hideDefaultActions:true,wrapText:true},
        { label: 'Strategy Status', fieldName: 'status',hideDefaultActions:true ,wrapText:true,},
        { label: 'Solution / Product Area', fieldName: 'productSolution',wrapText:true,hideDefaultActions:true, wrapText:true },
        { type: 'action', typeAttributes: { rowActions: this.actions, menuAlignment: 'auto' } }*/

        { label: 'Name', fieldName: 'strategyUrl',type:'customHyperlink',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'strategyName' },linkUrl:{ fieldName: 'strategyUrl' },isApproved:{fieldName:'isApproved'}} },
        { label: 'Strategy Type', fieldName: 'type',hideDefaultActions:true,wrapText:true},
        { label: 'Strategy Status', fieldName: 'status',hideDefaultActions:true ,wrapText:true,},
        { label: 'Solution / Product Area', fieldName: 'productSolution',wrapText:true,hideDefaultActions:true, wrapText:true },
        { label: 'Key Contact Sponsor', fieldName: 'contactUrl',type:'url',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'contactName' },target:'_blank' } },
        { label: 'Short / Long Term', fieldName: 'term',hideDefaultActions:true},
        { label: 'Est. Completion Date', fieldName: 'estimatedCompletionDate',wrapText:true,hideDefaultActions:true },
        { type: 'action', typeAttributes: { rowActions: this.actions, menuAlignment: 'auto' } }
    ];

    columnsWithNoActions = [
       /* { label: 'Name', fieldName: 'strategyUrl',type:'customHyperlink',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'strategyName' },linkUrl:{ fieldName: 'strategyUrl' },isApproved:{fieldName:'isApproved'}} },
        { label: 'Est. Completion Date', fieldName: 'estimatedCompletionDate',wrapText:true,hideDefaultActions:true },
        { label: 'Short / Long Term', fieldName: 'term',hideDefaultActions:true},
        { label: 'Key Contact Sponsor', fieldName: 'contactUrl',type:'url',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'contactName' },target:'_blank' } },
        { label: 'Strategy Type', fieldName: 'type',hideDefaultActions:true,wrapText:true},
        { label: 'Strategy Status', fieldName: 'status',hideDefaultActions:true ,wrapText:true,},
        { label: 'Solution / Product Area', fieldName: 'productSolution',wrapText:true,hideDefaultActions:true, wrapText:true },*/

        { label: 'Name', fieldName: 'strategyUrl',type:'customHyperlink',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'strategyName' },linkUrl:{ fieldName: 'strategyUrl' },isApproved:{fieldName:'isApproved'}} },
        { label: 'Strategy Type', fieldName: 'type',hideDefaultActions:true,wrapText:true},
        { label: 'Strategy Status', fieldName: 'status',hideDefaultActions:true ,wrapText:true,},
        { label: 'Solution / Product Area', fieldName: 'productSolution',wrapText:true,hideDefaultActions:true, wrapText:true },
        { label: 'Key Contact Sponsor', fieldName: 'contactUrl',type:'url',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'contactName' },target:'_blank' } },
        { label: 'Short / Long Term', fieldName: 'term',hideDefaultActions:true},
        { label: 'Est. Completion Date', fieldName: 'estimatedCompletionDate',wrapText:true,hideDefaultActions:true },
    ];

    opportunityColumns = [
        { label: 'Name', fieldName: 'opportunityName',wrapText:true,hideDefaultActions:true},
        { label: 'Stage', fieldName: 'stageName',hideDefaultActions:true,wrapText:true},
        { label: 'Est. Booking Value', fieldName: 'amount',wrapText:true,hideDefaultActions:true},
        { label: 'Est. Close Date ', fieldName: 'closeDate',wrapText:true,hideDefaultActions:true},
        { label: 'Contract Length', fieldName: 'contractLength',wrapText:true,hideDefaultActions:true},
        { label: 'Div/BU/Country/Dept', fieldName: 'divisionDetails',wrapText:true,hideDefaultActions:true, wrapText:true },
        { label: 'Next Step(s)', fieldName: 'nextStep',hideDefaultActions:true,wrapText:true},
        { label: 'Solution', fieldName: 'solution',wrapText:true,hideDefaultActions:true},
    ];

    @track columns = [];

    opportunityData;
    strategyData;
    wiredData;
    objectApiName = 'Strategy_and_Goal__c';
    showSpinner = false;
    fields = {ACCOUNT_PLAN,STATUS,CONTACT,NAME,SOLUTION_GOAL,RESOURCES,SOLUTION,MILESTONES,TYPE,ESTIMATED_COMPLETION_DATE,BUSINESS_PROBLEM_ADDRESSED,COMMENTS};
    openModal = false;
    fieldValues = {};
    isOpportunityModal = false;
    modalTitle='';
    @track selectedRows=[];
    selectedRowsFinal;
    selectedRowsInitial;
    currentStrategy;
    showSpinner = false;
    showErrorMessage = false;

    @wire(getStrategyAndGoalsDetails,({accountPlanId:'$recordId'}))
    getStrategyAndGoalsDetails(value){
        this.wiredData = value;
        const { error, data } = value;
        if (error) {
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error!',
                message:error.body.message,
                variant:'error'
            });
            this.dispatchEvent(event);
        } else if (data) {
            if(data.length>0){
                this.strategyData = data;
            }
            this.error = undefined;
        }
    }

    renderedCallback(){
        if(this.isAccountPlanUnderReview){
            this.columns = this.columnsWithNoActions;
        }else{
            this.columns = this.columnsWithActions;
        }
    }

    handleSuccess(){
        const event = new ShowToastEvent({
            title: 'Success!',
            variant:'success'
        });
        this.dispatchEvent(event);
        refreshApex(this.wiredData);
        this.closeModal();
        this.oncreation();
    }

    openModalPopup(){
        this.modalTitle = 'Create Strategy And Goal';
        this.isOpportunityModal = false;
        this.openModal = true;
    }

    closeModal(){
        this.openModal = false;
        this.showSpinner = false;
        this.showErrorMessage = false;
    }

    handleSave(){
        this.showSpinner = true;
        let requiredFields = this.template.querySelectorAll(".required-fields");
        let allRequiredValuesPresent = true;
        requiredFields.forEach(element => {
            if(!element.value){
                allRequiredValuesPresent = false;
            }
        });
        if(!allRequiredValuesPresent){
            this.showErrorMessage = true;
            this.showSpinner = false;
        }
    }

    handleError(){
        this.showSpinner = false;
    }

    linkOrDelinkOpportunities(){
        let linkedOpportunities = [];
        let delinkedOpportunities = [];
        this.selectedRowsFinal.forEach(element => {
            linkedOpportunities.push(element.oppId);
        });

        this.selectedRows.forEach(element => {
            if(!linkedOpportunities.includes(element)){
                delinkedOpportunities.push(element);
            }else{
                linkedOpportunities.splice(linkedOpportunities.indexOf(element), 1);
            }
        });
        if(linkedOpportunities.length>0 || delinkedOpportunities.length>0){
            this.showSpinner = true;
            linkOrDelinkOpportunities({strategyId : this.currentStrategy,opportunityIdsToLink : linkedOpportunities,opportunityIdsToDelink : delinkedOpportunities,totalOpportunitiesLinked : this.selectedRowsFinal.length}).then(Response => {
                const event = new ShowToastEvent({
                    title: 'Success!',
                    variant:'success'
                });
                this.dispatchEvent(event);
                this.showSpinner = false;
                this.isOpportunityModal = true;
                this.closeModal();
            }).catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message:error.body.message,
                    variant:'error'
                });
                this.dispatchEvent(event);
                this.showSpinner = false;
            });
        }
        else{
            this.isOpportunityModal = false;
            this.closeModal();
        }
    }

    handleLinkOrDelink(event){
        this.showSpinner = true;
        this.selectedRows = [];
        const action = event.detail.action.name;
        const row = event.detail.row;
        this.currentStrategy = row.strategyId;
        if(action=='linkOrDelink'){
            this.modalTitle = 'Link Or De-link Opportunities';
            this.isOpportunityModal = true;
            this.openModal = true;
            getOpportunityDetails({accountId : row.accountId,strategyId : row.strategyId}).then(Response => {
                this.opportunityData = Response;
                let selectedRows = [];
                this.opportunityData.forEach(element => {
                    if(element.isStrategyLinked){
                        selectedRows.push(element.oppId);
                        this.selectedRows = selectedRows;
                    }
                });
                this.showSpinner = false;
            }).catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message:error.body.message,
                    variant:'error'
                });
                this.dispatchEvent(event);
            });
        }else{
            let pageRef ={};
        switch (action) {
            case 'email':
                pageRef = {
                    type: "standard__quickAction",
                    attributes: {
                        apiName:"Global.SendEmail"
                    },
                    state: {
                        recordId: row.strategyId
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
                        recordId: row.strategyId
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
                        recordId: row.strategyId
                    }
                };
                break;
            }
            this[NavigationMixin.Navigate](pageRef);
        }
          
    }

    handleRowSelection(event){
        this.selectedRowsFinal = event.detail.selectedRows;
    }

    oncreation(event){
        let ev = new CustomEvent('creation');
        this.dispatchEvent(ev);
    }
}