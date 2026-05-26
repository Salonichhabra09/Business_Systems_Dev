import { LightningElement,api,wire,track } from 'lwc';
import getRelationshipDetails from '@salesforce/apex/StrategyAndGoalController.getRelationshipDetails';
import addOrRemoveRelationship from '@salesforce/apex/StrategyAndGoalController.addOrRemoveRelationship';
import getStrategyRelationshipDetails from '@salesforce/apex/StrategyAndGoalController.getStrategyRelationshipDetails';
import addNewRelationshipToStrategy from '@salesforce/apex/StrategyAndGoalController.addNewRelationshipToStrategy';
import CONTACT from '@salesforce/schema/AccountContactRelation.ContactId';
import ACCOUNT from '@salesforce/schema/AccountContactRelation.AccountId';
import ROLES from '@salesforce/schema/AccountContactRelation.Roles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex'
import DataTableResource from '@salesforce/resourceUrl/customDatatable';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';


export default class AccConRelationshipOnStrategy extends LightningElement {

    @api recordId;
    isAccountPlanUnderReview;
    accountId;
    strategyName;
    relationshipData;
    objectApiName='AccountContactRelation';
    fields = {ACCOUNT,CONTACT,ROLES};
    availableRelationshipData;
    wiredData;
    showSpinner = false;
    currentStrategy;
    isRelationshipModal = false;
    selectedRows =[];
    selectedRowsFinal;
    error;
    //objectApiName='Contact';
    contactRowId;
    openModal = false;
    showEditContact=false;
    @track picklistValues =[];
    isRolesChanged = false;
    isRowsChanged = false;
    @track columns = [
        { label: 'Contact', fieldName: 'linkToContact',type:'url',wrapText:true,hideDefaultActions:true,typeAttributes: { label: { fieldName: 'contactName' },target:'_blank' } },
        { label: 'Account Number', fieldName: 'dNumber',wrapText:true,hideDefaultActions:true}
    ];
    isLoaded = false;
    errorMessage =  'Unknown Error Occurred. Please refresh or contact System Administrator';
    isSaveDisabled = true;

    @wire(getStrategyRelationshipDetails,({strategyId:'$recordId'}))
    getStrategyRelationshipDetails(value){
        this.wiredData = value;
        const { error, data } = value;
        if (error) {
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error!',
                message:this.error.body.message,
                variant:'error'
            });
            this.dispatchEvent(event);
        } else if (data) {
            this.picklistValues = data.rolePicklist;
            if(!this.isLoaded){
                let tempColumns = this.columns.concat([{ label: 'Roles', fieldName: 'Id',type:'customCombobox',fixedWidth:300,wrapText:true,hideDefaultActions:true,typeAttributes:{options:this.picklistValues,selectedRoles :{fieldName:'rolesToUse'},relationshipId:{fieldName:'relationshipId'}} }]);
                this.columns = tempColumns;
                this.isLoaded = true;
            }
            if(data.relationshipData.length>0){
                this.relationshipData = data.relationshipData;
            }else{
                this.relationshipData = undefined;
            }
            this.accountId = data.accountId;
            this.strategyName = data.strategyName;
            this.isAccountPlanUnderReview = data.isAccountPlanUnderReview;
            this.error = undefined;
        }
    }

    connectedCallback() {
        loadStyle(this, DataTableResource);
      }

    openModalPopup(){
        this.modalTitle = 'New Account Contact Relationship';
        this.isRelationshipModal = false;
        this.openModal = true;
    }

    closeModal(){
        this.openModal = false;
        this.showSpinner = false;
    }

    handleContactSave(){
        this.showSpinner = true;  
    }
    handleSave(event){
        event.preventDefault();   
        this.showSpinner = true;  
        const fields = event.detail.fields;
        fields.Strategies__c = this.strategyName;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleError(event){
        this.showSpinner=false;
    }
    handleSuccess(event){
        addNewRelationshipToStrategy({strategyId : this.recordId,relationshipId : event.detail.id}).then(Response => {
            if(Response.MessageType=='Success'){
                const eve = new ShowToastEvent({
                    title: 'Success!',
                    variant:'success'
                });
                this.dispatchEvent(eve);
                refreshApex(this.wiredData);
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:Response.Message,
                    variant:'error'
                });
                this.dispatchEvent(event);
            }
        }).catch(Error => {
            const event = new ShowToastEvent({
                title: 'Error',
                message:this.errorMessage,
                variant:'error'
            });
            this.dispatchEvent(event);
        });
        this.closeModal();
    }

    handleError(){
        this.showSpinner = false;
    }

    handleLinkOrDelink(event){
        this.isSaveDisabled = true;
        this.isRolesChanged = false;
        this.isRowsChanged = false;
        this.showSpinner = true;
        this.selectedRows = [];
            this.modalTitle = 'Link Or De-link Relationship';
            this.isRelationshipModal = true;
            this.openModal = true;
            this.availableRelationshipData = undefined;
            getRelationshipDetails({accountId : this.accountId,strategyId : this.recordId}).then(Response => {
                if(Response.MessageType=='Success'){
                    this.availableRelationshipData = Response.relationshipList;
                let selectedRows = [];
                let selectedRowIds = [];
                this.availableRelationshipData.forEach(element => {
                    if(element.isStrategyLinked){
                        selectedRows.push(element.relationshipId);
                        this.selectedRows = selectedRows;
                        selectedRowIds.push(element);
                    }
                });
                this.selectedRowsFinal = selectedRowIds;
                }else{
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message:Response.Message,
                        variant:'error'
                    });
                    this.dispatchEvent(event);
                }
                this.showSpinner = false;
            }).catch(Error => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:this.errorMessage,
                    variant:'error'
                });
                this.dispatchEvent(event);
            });
          
    }

    handleDisableSave(){
        this.isSaveDisabled = true;
    }

    handleCheckDisableSave(){
        this.isSaveDisabled = this.isRowsChanged || this.isRolesChanged?false:true;
    }

    linkOrDelinkRelationships(){
        let linkedRelationships = [];
        if(this.selectedRowsFinal){
            this.selectedRowsFinal.forEach(element => {
                linkedRelationships.push(element.relationshipId);
            });
        }
        if(linkedRelationships.length>0 || this.isRolesChanged){
            this.showSpinner = true;
            addOrRemoveRelationship({strategyId : this.recordId,selectedRelationships : linkedRelationships,relationshipList:this.availableRelationshipData}).then(Response => {
                if(Response.MessageType=='Success'){
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        variant:'success'
                    });
                    this.dispatchEvent(event);
                    this.showSpinner = false;
                    this.isRelationshipModal = true;
                    refreshApex(this.wiredData);
                    this.closeModal();
                }else{
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message:Response.Message,
                        variant:'error'
                    });
                    this.dispatchEvent(event);
                    this.showSpinner = false;
                }
            }).catch(Error => {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message:this.errorMessage,
                    variant:'error'
                });
                this.dispatchEvent(event);
                this.showSpinner = false;
            });
        }
        else{
            this.isRelationshipModal = false;
            this.closeModal();
        }
    }
    handleRowSelection(event){
        this.selectedRowsFinal = event.detail.selectedRows;
        let finalSelectedIds=[];
        let selectedIds  = this.selectedRows;
        this.selectedRowsFinal.forEach(element => {
            finalSelectedIds.push(element.relationshipId);
        });
        finalSelectedIds.sort();
        selectedIds.sort();
        this.isRowsChanged = JSON.stringify(finalSelectedIds)!=JSON.stringify(selectedIds)?true:false;
        this.isSaveDisabled = this.isRowsChanged || this.isRolesChanged?false:true;
    }

    handleUpdateRoles(event){
        let relationshipId = event.detail.relationshipId; 
        let temp = JSON.parse(JSON.stringify(this.availableRelationshipData));
        temp.forEach(element => {
            if(element.relationshipId==relationshipId){
                element.rolesToUse = event.detail.updatedSelectedRoles;
            }
        });
        this.availableRelationshipData = temp;
        this.isRolesChanged = true;
        this.isSaveDisabled = false;
    }

    handleEditContact(event){
        var rowId = event.currentTarget.dataset.recordId;
        this.contactRowId = rowId;
        this.showEditContact= true;      
        }

        handleContactEditSuccess(){
            this.showEditContact= false;
            refreshApex(this.wiredData);
            this.showSpinner = false;
        }

        handleCloseContactEditForm(){
            this.showEditContact= false;
        }

        handleContactError(event){
            console.log('inside error' );
            this.showSpinner = false;
            let message = JSON.stringify(event.detail.detail);
            let message2 = JSON.stringify(event.detail.message);
            let toastMessage;
          if(message.includes('Duplicate Contact!')){
                
                toastMessage='Duplicate Contact! Contact with the same Account and Email already exists in the system.'
            }
             
            else{
                if(message=='""'){
                   if(message2.includes('The requested resource does not exist') ){
                    
                    toastMessage='Oops!Looks like you do not have access to edit this contact.Please contact your system administrator for further assistance.';
                   }
                   else if(JSON.stringify(event.detail.output.fieldErrors).includes('Area_of_Interest__c')){
                  
                    toastMessage=JSON.stringify(event.detail.output.fieldErrors.Area_of_Interest__c[0].message);
                   }
                   else if(JSON.stringify(event.detail.output.fieldErrors).includes('Title')){
                    toastMessage=JSON.stringify(event.detail.output.fieldErrors.Title[0].message);
                   }
                   
                }
                else{
                    toastMessage=message;
                }  
            }
           
        }

    
}