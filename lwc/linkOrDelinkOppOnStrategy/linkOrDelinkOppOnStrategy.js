import { LightningElement,wire,api } from 'lwc';
import getOpportunityDetails from '@salesforce/apex/StrategyAndGoalController.getOpportunityDetails';
import linkOrDelinkOpportunities from '@salesforce/apex/StrategyAndGoalController.linkOrDelinkOpportunities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import {CurrentPageReference} from 'lightning/navigation';
import { loadStyle } from "lightning/platformResourceLoader";
import modalPopupCss from "@salesforce/resourceUrl/modalPopupCss";
import { RefreshEvent } from 'lightning/refresh';

export default class LinkOrDelinkOppOnStrategy extends LightningElement {

    recordId;
    opportunityData;
    selectedRows=[];
    showSpinner = true;
    wiredData;
    isComponentLoaded = false;

    opportunityColumns = [
        { label: 'Name', fieldName: 'opportunityName',wrapText:true,hideDefaultActions:true},
        { label: 'Stage', fieldName: 'stageName',hideDefaultActions:true,wrapText:true},
        { label: 'Account Number', fieldName: 'dNumber',hideDefaultActions:true,wrapText:true},
        { label: 'Est. Booking Value', fieldName: 'amount',wrapText:true,hideDefaultActions:true},
        { label: 'Est. Close Date ', fieldName: 'closeDate',wrapText:true,hideDefaultActions:true},
        { label: 'Contract Length', fieldName: 'contractLength',wrapText:true,hideDefaultActions:true},
        { label: 'Div/BU/Country/Dept', fieldName: 'divisionDetails',wrapText:true,hideDefaultActions:true, wrapText:true },
        { label: 'Next Step(s)', fieldName: 'nextStep',hideDefaultActions:true,wrapText:true},
        { label: 'Solution', fieldName: 'solution',wrapText:true,hideDefaultActions:true},
    ];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
    if (currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
        this.handleGetOpportunityDetails();
    }
}

    connectedCallback() {
        loadStyle(this, modalPopupCss);
    }

    handleGetOpportunityDetails(){
        getOpportunityDetails({accountId : null,strategyId :this.recordId}).then(Response => {
            if(Response.MessageType=='Success'){
                let data = Response.oppList;
            if(data.length >= 1){
                this.opportunityData = data;
                let selectedRows = [];
                this.opportunityData.forEach(element => {
                    if(element.isStrategyLinked){
                        selectedRows.push(element.oppId);
                        this.selectedRows = selectedRows;
                    }
                });
                }
            else{
                this.opportunityData = '';
                
            }
        }
        else if(Response.MessageType=="NoAccess"){
            const event = new ShowToastEvent({
                title: 'No Access!',
                message:Response.Message,
                variant:'error'
            });
            this.dispatchEvent(event);
            this.closeModal();
        }
        else if(Response.MessageType=="Error"){
            const event = new ShowToastEvent({
                title: 'Error!',
                message:Response.Message,
                variant:'error'
            });
            this.dispatchEvent(event);
            this.showSpinner = false;
            this.opportunityData = '';
        }

            this.showSpinner = false;
           
        }).catch(error => {
            let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
            const event = new ShowToastEvent({
                title: 'Error!',
                message:message,
                variant:'error'
            });
            this.dispatchEvent(event);
        });
    }

    handleRowSelection(event){
        this.selectedRowsFinal = event.detail.selectedRows;
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
            linkOrDelinkOpportunities({strategyId : this.recordId,
                opportunityIdsToLink : linkedOpportunities,opportunityIdsToDelink : delinkedOpportunities,
                totalOpportunitiesLinked : this.selectedRowsFinal.length}).then(Response => {
               if(Response.MessageType=='Success'){
                let data=Response.message;
                const event = new ShowToastEvent({
                    title: 'Success!',
                    variant:'success',
                    message:Response.Message,
                });
                this.dispatchEvent(event);
                this.showSpinner = false;
                this.isOpportunityModal = true;
                //eval("$A.get('e.force:refreshView').fire();");        
                this.closeModal();
            }
            else if(Response.MessageType=="Error"){
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message:Response.Message,
                    variant:'error'
                });
                this.dispatchEvent(event);
                this.showSpinner = false;
            }
           
            }).catch(error => {
                let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message:message,
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

    closeModal(){
        //Changes added for SSE-22562
        this.dispatchEvent(new CloseActionScreenEvent());
        // setTimeout(() => {
        //     eval("$A.get('e.force:refreshView').fire();");
        // }, 1000);
        //setTimeout(() => {
            //this.dispatchEvent(new RefreshEvent()); 
        //}, 1000);
        this.showSpinner = false;
    }
}