import { LightningElement, track, wire,api} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Work_Request_OBJECT from '@salesforce/schema/Work_Request__c';
import System_Used_FIELD from '@salesforce/schema/Work_Request__c.System_Used__c';
import ISGCSCOPP from '@salesforce/schema/Job__c.Is_GCSC_Opp__c';
import SOLUTIONCAP from "@salesforce/schema/Job__c.Solution_Cap__c";
import getListOfSolutions from '@salesforce/apex/CustomerRequestController.getListOfSolutions';
import OPPORTUNITYID from "@salesforce/schema/Job__c.Opportunity__c";

export default class FormSystemInput extends LightningElement {
    @track value;
    @api jobNumber;
    SystemUsedPicklistValues=[];
    @api lastSystemSelected;
    @api lastSolutionSelected;
    solutions=[];
    showSolutions=false;
    errorMessage;
    @api recordId;
    opportunityId;
    jobRecord;
    valueSolution;
    solutionOptions=[];
    IsGCSCOpp=false;

    get recordUrl() {
        // Construct the URL to navigate to the record detail page
        return `/lightning/r/${this.recordId}/view`;
    }

    connectedCallback(){
        this.value=this.lastSystemSelected;
        this.valueSolution = this.lastSolutionSelected;
    }
    @wire(getObjectInfo, { objectApiName: Work_Request_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: System_Used_FIELD})
    SystemUsedPicklistValues;

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [SOLUTIONCAP,OPPORTUNITYID,ISGCSCOPP]
    })
    wiredRecord({ error, data }) {
        if (data) {
            this.jobRecord = data;
            this.opportunityId = getFieldValue(this.jobRecord, OPPORTUNITYID);
            this.IsGCSCOpp = getFieldValue(this.jobRecord, ISGCSCOPP);
            //console.log('ISGCSCOpp '+this.IsGCSCOpp);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.account = undefined;
        }
    }


    @wire(getListOfSolutions,{OpportunityId:'$opportunityId'})
    getListOfSolutions(result) {
        this.solutions = result.data;
        if(this.solutions){
            this.solutionOptions = this.solutions.map(item => ({
                label: item,
                value: item
            }));
        //console.log("solutions FSI" + this.solutions);
        //console.log("Solution cap FSI "+getFieldValue(this.jobRecord, SOLUTIONCAP));
        //console.log("options FSI "+this.solutionOptions);
        if(getFieldValue(this.jobRecord, SOLUTIONCAP)==null && !this.IsGCSCOpp){
            this.showSolutions=true;
        }
        //console.log('showSolutions FSI '+this.showSolutions);
    }
    }

    handleChange(event) {
        this.value = event.detail.value;
        if(this.value!=undefined){
            this.errorMessage="";
    }
        }
        
    handlenext(){
        if(this.value==undefined){
            this.errorMessage = 'Please select Form Category to proceed';
        }
        else{
            if(this.valueSolution==undefined && !this.IsGCSCOpp && getFieldValue(this.jobRecord, SOLUTIONCAP)==null){
            this.errorMessage = 'Please select Solution to proceed';
            }
            else{
                this.dispatchEvent(new CustomEvent('systemselected', {
                    detail: {
                        value: this.value,
                        solution: this.valueSolution
                    }
                }));
            }
        }
    }
    handleChangeSolution(event){
        this.valueSolution = event.detail.value;
       //console.log('Selected Solution '+this.valueSolution);
       if(this.valueSolution!=undefined){
        this.errorMessage="";
}
    }

}