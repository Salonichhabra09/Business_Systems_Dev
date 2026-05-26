import { LightningElement,api } from 'lwc';
import updateHierarchyOnReparent from '@salesforce/apex/ACR_RelationshipMapController.updateRelationshipMap';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Acr_reparentNodeInRelationshipMap extends LightningElement {

    @api allEligibleNodes;
    @api allNodes;
    @api currentNode;
    @api hierarchyInformationId;
    @api modalresize;
    showSpinner = false;
    selectedRow;
    isReparentDisabled = true;


    columns = [
        { label: 'Name', fieldName: 'Name',hideDefaultActions:true },
        { label: 'Is Placeholder', fieldName: 'IsPlaceholder', type: 'boolean',hideDefaultActions:true }
    ];

    handleRowSelection(event){
        this.selectedRow = event.detail.selectedRows[0];
        this.isReparentDisabled = this.selectedRow ? false : true;
    }

    handleCloseReparent(){
        const closeReparentPopup = new CustomEvent("closereparentpopup");
        this.dispatchEvent(closeReparentPopup);
    }

    handleReparent(){
        this.showSpinner = true;
        let finalNodeList = JSON.parse(JSON.stringify(this.allNodes));
        if(this.currentNode.Children && JSON.stringify(this.currentNode.Children).includes(this.selectedRow.Id)){
            finalNodeList.forEach(element => {
                if (element.Id == this.selectedRow.Id) {
                    element.ReportsTo = this.currentNode.ReportsTo;
                }
            });
            
        }
        finalNodeList.forEach(element => {
            if(element.Id == this.currentNode.Id){
                element.ReportsTo = this.selectedRow.Id;
            }
            element.Children = [];
        });
        
        updateHierarchyOnReparent({ hierarchyList: finalNodeList, hierarchyInformationId: this.hierarchyInformationId})
        .then((result) => {
            this.toast('Success!', '', 'success', 'dismissible');

            const refreshEvent = new CustomEvent("refreshhierarchy");
            this.dispatchEvent(refreshEvent);
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