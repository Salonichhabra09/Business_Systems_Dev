import { LightningElement,api,wire } from 'lwc';
import createHierarchyOnOpportunity from '@salesforce/apex/OpportunityContactHierarchy.createHierarchyOnOpportunity';
import getHierarchyInformationOfOpportunity from '@salesforce/apex/OpportunityContactHierarchy.getHierarchyInformationOfOpportunity';
import deleteHierarchy from '@salesforce/apex/OpportunityContactHierarchy.deleteHierarchy';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

const FIELDS = ["Opportunity.StageName", "Opportunity.IsClosed"];


export default class CreateContactHierarchyOnOpp extends NavigationMixin(LightningElement) {

    @api recordId;
    showSpinner = true;
    hasNoContactHierarchy = false;
    hasContactHierarchy = false;
    isOpenPopup = false
    isCreateRecord = false;
    isDeleteRecord = false;
    headerTitle = 'Create Contact Hierarchy';
    hierarchyValue = 'Default Heirarchy';
    hierarchyInformation;
    lastModifiedDate;
    createdDate;
    wiredData;
    isOpportunityNotClosed = true;
    opportunity;

    // get hierarchyOptions() {
    //     return [
    //         { label: 'Default Heirarchy', value: 'Default Heirarchy' },
    //         { label: 'Custom Heirarchy', value: 'Custom Heirarchy' },
    //     ];
    // }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
        let message = "Unknown error";
        if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(", ");
        } else if (typeof error.body.message === "string") {
            message = error.body.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
            title: "Error loading hierarchy details",
            message,
            variant: "error",
            }),
        );
        } else if (data) {
        this.opportunity = data;
        this.isOpportunityNotClosed = this.opportunity.fields.IsClosed.value ? false : true;
        this.showSpinner = false;
        }
    }

    @wire(getHierarchyInformationOfOpportunity , {opportunityId : '$recordId'})
    wiredHierarchyInformation(value) {
        this.wiredData = value;
        const { error, data } = value;
        if(data){
            if (data.length>0) {
                this.hasContactHierarchy = true;
                this.hasNoContactHierarchy = false;
                this.hierarchyInformation = data[0];
                this.lastModifiedDate = String(this.hierarchyInformation.LastModifiedDate).substring(0,10);
                this.createdDate = String(this.hierarchyInformation.CreatedDate).substring(0,10);
            }else{
                this.hasContactHierarchy = false;
                this.hasNoContactHierarchy = true;
            }
            
            this.showSpinner = false; // Hide the spinner since the contacts retrieval is complete.
            this.error = undefined;
        } else if (error) {
            console.log(JSON.stringify(error));
            this.showSpinner = false;
            this.showErrorMessage = true;
            this.error = error;
            this.contacts = undefined;
        }

    }

    get isCreateVisible(){
        return this.isOpportunityNotClosed && !this.hasContactHierarchy;
    }

    get isDeleteVisible(){
        return this.isOpportunityNotClosed && this.hasContactHierarchy;
    }

    get isComponentVisible(){
        return this.isOpportunityNotClosed || this.hasContactHierarchy;
    }

    // handleHierarchyTypeChange(event){
    //     this.hierarchyValue = event.target.value;
    // }

    handleCreateHierarchy() {
        // this.headerTitle = 'Create Contact Hierarchy';
        // this.isCreateRecord = true;
        // this.isOpenPopup = true;
        this.handleSubmit();
    }

    handleManageHierarchy(){
        this[NavigationMixin.GenerateUrl]({
            type: "standard__navItemPage",
            attributes: {
                apiName: 'Contact_Hierarchy'
            },
            state: {
              c__recordId : this.hierarchyInformation.Id
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    handleDeleteHierarchy(){
        this.headerTitle = 'Delete Contact Hierarchy';
        this.isDeleteRecord = true;
        this.isOpenPopup = true;
    }

    handleClose(){
        this.isOpenPopup = false;
        //this.isCreateRecord = false;
        this.isDeleteRecord = false;
    }

    handleSubmit(){
        this.showSpinner = true;
        createHierarchyOnOpportunity({ opportunityId: this.recordId, hierarchyType: this.hierarchyValue, hierarchyType: this.hierarchyValue })
        .then((result) => {
            
            if(result!=''){
                refreshApex(this.wiredData);
                this[NavigationMixin.GenerateUrl]({
                    type: "standard__navItemPage",
                    attributes: {
                        apiName: 'Contact_Hierarchy'
                    },
                    state: {
                      c__recordId : result
                    }
                }).then(url => {
                    window.open(url, "_blank");
                });
                this.handleClose();
            }
          })
          .catch((error) => {
            if (error.body && error.body.message) {
                let errorMessage = error.body.message;
                this.toast('Error', errorMessage, 'error', 'dismissible');
            }else{
                this.toast('Error', 'Something went wrong', 'error', 'dismissible');
            }
          })
          .finally(() => {
            this.showSpinner = false;
          });
    }

    deleteHierarchy(){
        this.showSpinner = true;
        deleteHierarchy({ hierarchyInformationId: this.hierarchyInformation.Id })
        .then((result) => {
            refreshApex(this.wiredData);
            this.handleClose();
            this.toast('Hierarchy deleted successfully !', '', 'success', 'dismissible');
            
          })
          .catch((error) => {
            if (error.body && error.body.message) {
                let errorMessage = error.body.message;
                this.toast('Error', errorMessage, 'error', 'dismissible');
            }else{
                this.toast('Error', 'Something went wrong', 'error', 'dismissible');
            }
          })
          .finally(() => {
            this.showSpinner = false;
          });
    }

    toast(title, message, variant, mode) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
        })
        this.dispatchEvent(toastEvent)
    }
        
}