import { LightningElement, api, wire, track } from 'lwc';
import { getRecord} from "lightning/uiRecordApi";
import Opportunity__c from "@salesforce/schema/Job__c.Opportunity__c";
import getOpportunityLineItems from '@salesforce/apex/MsCandidateDataTableController.getOpportunityLineItems';
import getProjectDetails from '@salesforce/apex/MsCandidateDataTableController.getProjectDetails';
import getNonMSOpportunityLineItems from '@salesforce/apex/MsCandidateDataTableController.getNonMSOpportunityLineItems';
import getOrderDetails from '@salesforce/apex/MsCandidateDataTableController.getOrderDetails';
 
const columns = [  
    {label: 'Name', fieldName: 'ProductLineRecord', type: 'url',
        typeAttributes: { label: { fieldName: 'productName' }, target: '_blank' }}, 
    { label: 'Basis of Fees', fieldName: 'Basis_of_Fees__c'}, 
    { label: 'Quantity', fieldName: 'Quantity' }, 
    { label: 'Use-case', fieldName: 'Proposition__c' }, 
    { label: 'Solution', fieldName: 'Package__c' }, 
    { label: 'Solution Cap', fieldName: 'Solution_Cap__c' }, 
    { label: 'Line Description', fieldName: 'Description' }
];  

const projectcolumns = [  
    { label: 'Project Number', fieldName: 'ProjectRecord' , type: 'url',
    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }}, 
    { label: 'Project Manager', fieldName: 'ProjectManager'}, 
    { label: 'Project Status', fieldName: 'Project_Status__c' }, 
    { label: 'BU', fieldName: 'LBU__c' }
];  


export default class ContractDetailsTab extends LightningElement {
    @api recordId;
    productLineItems;
    projectItems;
    oppId;
    tableColumns=columns;
    projecttableColumns=projectcolumns;
    showproductTable=false;
    showproductServiceTable=false;
    NonproductLineItems;
    orderID;
    orderRecordType;

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [Opportunity__c]
    })
    wiredRecord({ error, data }) {
        if(data) {
            this.job = data;
            this.oppId = this.job.fields.Opportunity__c.value;
            this.getOpportunityLineItems();
            this.getNonMSOpportunityLineItems();
            this.getProjectDetails();
            this.getOrderDetails();
        }
    };

    getOrderDetails(){
        getOrderDetails({ oppId: this.oppId })
        .then(result => {
            this.orderID=result[0].Id;
            let orderRecordName=result[0].Opportunity.Actual_Record_Type_Name__c;
            if(orderRecordName ==='GCSC Opportunity'){
                this.orderRecordType=true;
            }else{
                this.orderRecordType=false;
            }
        })
        .catch(error => {
            console.log('error ====> ', error);
        });
    }

    getOpportunityLineItems(){
        getOpportunityLineItems({ oppId: this.oppId })
        .then(result => {
            var tempData = [];
            tempData = result;
            let tempRecords = JSON.parse(JSON.stringify(result));
            tempRecords = tempRecords.map(row => {
                    return {
                        ...row,
                        ProductLineRecord: (row.Product2 ? ('/' + row.Id) : null),
                        productName: (row.Product2 ? row.Product2.Name : null)
                    };
            })
           this.productLineItems=tempRecords;
            })
        .catch(error => {
            console.log('error ====> ', error);
        });
    }

    getNonMSOpportunityLineItems(){
        getNonMSOpportunityLineItems({ oppId: this.oppId })
        .then(result => {
            var tempData = [];
            tempData = result;
            let tempRecords = JSON.parse(JSON.stringify(result));
            tempRecords = tempRecords.map(row => {
                return {
                    ...row,
                    ProductLineRecord: (row.Product2 ? ('/' + row.Id) : null),
                    productName: (row.Product2 ? row.Product2.Name : null)
                };
            })
           this.NonproductLineItems=tempRecords;
           if(this.NonproductLineItems.length > 0 ){
            this.showproductServiceTable = true;
            }
        })
        .catch(error => {
            console.log('error ====> ', error);
        });
    }

    getProjectDetails(){
        getProjectDetails({ oppId: this.oppId })
        .then(result => {
            let tempData = [];
            tempData = result;
            let tempRecords = JSON.parse(JSON.stringify(result));
            tempRecords = tempRecords.map(row => {
                    return {
                        ...row,
                        ProjectRecord: (row.Id ? ('/' + row.Id) : null),
                        ProjectManager:(row.Project_Manager__r ? row.Project_Manager__r.Name : null)
                    };
            })
            this.projectItems=tempRecords;
            if(this.projectItems.length > 0 ){
                 this.showproductTable = true;
            }
        })
        .catch(error => {
            console.log('error ====> ', error);
        });
        
    }
}