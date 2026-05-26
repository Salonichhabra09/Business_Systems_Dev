import { LightningElement , track,api} from 'lwc';
import getProjectData from '@salesforce/apex/UpdateProjectDetailsOnInvHeader.getProjectData';
import updateProjectNumber from '@salesforce/apex/UpdateProjectDetailsOnInvHeader.updateProjectNumber';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';

export default class UpdateProjectDetailsForInvoiceHeader extends LightningElement {
    @api recordId;
    @track isDisabled = true;
    @track showRadioButtons = false;
    @track showError =false;  
    @track selectedValue;
    @track updateProjectError ='';
    @track ErrorMessage ='';
    @track showUpdateProjectError = false;
    @track options = [];
    @track showSpinner= false;
    @track isProjectCancelled = false;
    @track showCancelledWarningMessage = false;
    @track recordsToDisplay;
    @track preSelectedRows = [];
    @track showTitle = "Add Project Number to Invoice";
    @track showAddProjectWarning = false;
    selectedValue;

    @track columnsToUse = [
        { label: 'Project Name', fieldName: 'projectURL',type:'url',hideDefaultActions:true,
        typeAttributes: { label: { fieldName: 'ProjectNumber'},target:'_blank' }},
        { label: 'Project Manager', fieldName: 'ProjectManager' ,hideDefaultActions:true ,wrapText:true},
        { label: 'Status', fieldName: 'ProjectStatus',hideDefaultActions:true ,wrapText:true },
];
    connectedCallback(){
        
        getProjectData({invoiceHeaderId : this.recordId}).then(Response => {
            console.log('Response --->' , JSON.stringify(Response))
        if(Response.MessageType == 'SUCCESS'){
            if(Response.showRadioButtons){
              this.showRadioButtons = true;
              this.isProjectCancelled = false;
              this.recordsToDisplay = Response.ProjectList;   
              this.showCancelledWarningMessage = false;  
              this.showAddProjectWarning = true;
              this.isDisabled = true; 

              if(Response.isProjectCancelled){
                this.isProjectCancelled = true; 
                this.showCancelledWarningMessage = false;
                this.showAddProjectWarning = false;
            }
             else if(Response.invoiceHasMultipleProject && !Response.isProjectCancelled){            
                let selectedProject = [];
                selectedProject.push(Response.currentProjectSelected);
                this.preSelectedRows = selectedProject;
                this.showTitle = 'Projects Available for Selection';
                this.showAddProjectWarning = false;
                this.isProjectCancelled = false;
             
             }     

        else{
            this.isProjectCancelled = false; 
        }
        }
        else{
           
            if(Response.isProjectCancelled){
                
                this.showCancelledWarningMessage = true; 
             
        }  
        }
           
        
           
        }
        if(Response.MessageType == 'ERROR'){
           this.showRadioButtons = false; 
           this.showError = true;
           this.ErrorMessage = Response.Message;
          
         
       }
    }).catch(Error => {
        console.log(Error);
    })
    }
    
    handleRowSelection = event => {
        let selectedRows = event.detail.selectedRows;
        this.selectedValue = selectedRows[0].ProjectNumber;
        this.isDisabled = false;
        console.log('selectedValue' + JSON.stringify(selectedRows )); 
       
}

  
    updateProjectNumber(event){
        this.showRadioButtons = false;
         this.showSpinner = true;
         this.isDisabled = false;
         updateProjectNumber({invoiceHeaderId : this.recordId , projectName : this.selectedValue}).then(Response => {
           
            if(Response.MessageType == 'SUCCESS'){
               
                const event = new ShowToastEvent({
                    title: 'Sucess',
                    message: 'Project Number have been updated Successfully.',
                    variant : 'success',
                    mode:'dismissible',    
                });
                this.dispatchEvent(event);
                this.showSpinner =false;
                this.dispatchEvent(new RefreshEvent()); 
                this.connectedCallback();
                
            }
            if(Response.MessageType == 'ERROR'){
               this.showRadioButtons = true; 
               this.showUpdateProjectError = true;
               this.updateProjectError = Response.Message;
               this.isDisabled = false;
               this.showSpinner =false;
               
              
             
           }
        }).catch(Error => {
            console.log(Error);
        })
    }

}