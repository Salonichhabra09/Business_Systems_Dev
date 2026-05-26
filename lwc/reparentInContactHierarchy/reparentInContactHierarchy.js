import { LightningElement,api } from 'lwc';
import updateHierarchyOnReparent from '@salesforce/apex/OpportunityContactHierarchy.updateHierarchyOnReparent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReparentInContactHierarchy extends LightningElement {

    @api allEligibleNodes;
    @api allNodes;
    @api currentNode;
    @api hierarchyInformationId;
    @api modalresize;
    showSpinner = false;
    selectedRow;


    columns = [
        { label: 'Name', fieldName: 'Name',hideDefaultActions:true },
        { label: 'Is Placeholder', fieldName: 'IsPlaceholder', type: 'boolean',hideDefaultActions:true }
    ];

    handleRowSelection(event){
        console.log(event.detail.selectedRows);
        this.selectedRow = event.detail.selectedRows[0];
    }

    handleCloseReparent(){
        const closeReparentPopup = new CustomEvent("closereparentpopup");
        this.dispatchEvent(closeReparentPopup);
    }

    handleReparent(){
        this.showSpinner = true;
        let newReportsToId = this.selectedRow.IsPlaceholder || this.selectedRow.Id == 'rootlevel' ? null : this.selectedRow.Id;
        let currentNodeId = this.currentNode.IsPlaceholder ? null : this.currentNode.Id;
        let finalNodeList = JSON.parse(JSON.stringify(this.allNodes));
        let contactsToUpdate = [];
        if(this.currentNode.Children && JSON.stringify(this.currentNode.Children).includes(this.selectedRow.Id)){
            finalNodeList.forEach(element => {
                if (element.Id == this.selectedRow.Id) {
                    console.log(JSON.stringify(element));
                    if (!(element.Id).includes('Placeholder')) {
                        let reportsToIdToUse = this.currentNode.ReportsTo == 'rootlevel' || this.currentNode.ReportsTo.includes('Placeholder') ? null : this.currentNode.ReportsTo;
                        let newContact = {
                            Id: element.Id,
                            ReportsToId: reportsToIdToUse
                        };
                        contactsToUpdate.push(newContact);

                    }
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

        let isAddedToTopNode = false;
        if(this.selectedRow.Id == 'rootlevel'){
            isAddedToTopNode = true;
        }
        
        updateHierarchyOnReparent({ hierarchyList: finalNodeList, hierarchyInformationId: this.hierarchyInformationId,newReportsToId:newReportsToId,currentNodeId:currentNodeId,isAddedToTopNode:isAddedToTopNode, contactsToUpdate:contactsToUpdate })
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