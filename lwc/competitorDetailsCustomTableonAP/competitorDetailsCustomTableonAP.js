import { LightningElement,api,wire,track } from 'lwc';
import getCompetitorDetails from '@salesforce/apex/CompetitorOnAccountPlanController.getCompetitorDetails';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import {loadStyle} from 'lightning/platformResourceLoader';
import LightningDatatableCSS from '@salesforce/resourceUrl/LightningDatatableCSS'


export default class CompetitorDetailsCustomTableonAP extends LightningElement {

    @api recordId;
    @api isAccountPlanUnderReview;
    @api apType;//Added as part of SSE-21664
    @api isRetired ;//Added as part of SSE-21664

    @track showNewButton = false;
    isCssLoaded = false

    objectApiName = 'Competitor__c';
  
    columns = [  
        { label: '', fieldName: 'serialNumber',wrapText:true,hideDefaultActions:true, fixedWidth:50,
        cellAttributes:{
            class:'datatable-CellColor'
        } },
        { label: 'Opportunity', fieldName: 'opportunityUrl',type:'url',wrapText:true,hideDefaultActions:true,
        typeAttributes: { label: { fieldName: 'opportunityName' },target:'_blank' },
        cellAttributes:{
            class:'datatable-CellColor'
        } },
        { label: 'Solution', fieldName: 'solution',hideDefaultActions:true,wrapText:true ,
        cellAttributes:{
            class:'datatable-CellColor'
        }},
        { label: 'Est. Customer Spend', fieldName: 'estimatedCustomerSpend',hideDefaultActions:true ,
        cellAttributes:{
            class:'datatable-CellColor'
        }},
        { label: 'Incumbent Vendor', fieldName: 'incumbentVendor',hideDefaultActions:true,wrapText:true , 
        cellAttributes:{
            class:'datatable-CellColor'
        }},
        { label: 'Incumbent Renewal Date', fieldName: 'incumbentDate',hideDefaultActions:true,wrapText:true ,
        cellAttributes:{
            class:'datatable-CellColor'
        }},
    ];

    showSpinner = false;
    showSpinner = false;
    competitorData;
    wiredData;
    openModal = false;
    showErrorMessage = false;
    error;

    renderedCallback(){
        if(this.isCssLoaded){
            return
        } 

        this.isCssLoaded = true

        loadStyle(this, LightningDatatableCSS).then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.log(error)
        });
    }
    connectedCallback(){
          if(this.isAccountPlanUnderReview == true || this.isRetired == true){
            this.showNewButton = true;
          }
          else{
            this.showNewButton = false;
          }
    }
    @wire(getCompetitorDetails,({accountId:'$recordId' , apType :'$apType'}))
    getCompetitorDetails(value){
        console.log('recordId' , this.recordId);
        console.log('apType' , this.apType);
        this.wiredData = value;
        const { error, data } = value;
        if (error) {
            console.log('inside error' , this.apType);
            const event = new ShowToastEvent({
                title: 'Error!',
                message:error.body.message,
                variant:'Error'
            });
            this.dispatchEvent(event);
        } else if (data) {
            if(data.length>0){
                console.log('data' , data);
                this.competitorData = data;
            }
            this.error = undefined;
        }
    }

    handleSuccess(){
        const event = new ShowToastEvent({
            title: 'Success!',
            variant:'success'
        });
        this.dispatchEvent(event);
        refreshApex(this.wiredData);
        this.showSpinner = false;
        this.closeModal();
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

    openModalPopup(){
        this.openModal = true;
    }

    closeModal(){
        this.openModal = false;
        this.showErrorMessage = false;
    }

}