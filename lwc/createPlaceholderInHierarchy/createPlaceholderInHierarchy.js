import { LightningElement,track,api } from 'lwc';
import updateHierarchyOnPlaceholderCreation from '@salesforce/apex/OpportunityContactHierarchy.updateHierarchyOnPlaceholderCreation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreatePlaceholderInHierarchy extends LightningElement {

    @api totalPlaceholders;
    @api parentNode;
    @api allNodes;
    @api modalresize;
    @api hierarchyInformationId;
    keyIndex = 1;
    @track placeholderList = [
        {
            index: 1,

        }
    ];
    showSpinner = false;

    addRow() {
        ++this.keyIndex;
        var newItem = [{ index: this.keyIndex }];
        this.placeholderList = this.placeholderList.concat(newItem);
    }

    removeRow(event) {
        if (this.placeholderList.length >= 2) {
            this.isLoaded =false;
            let temp = JSON.parse(JSON.stringify(this.placeholderList));
            temp = temp.filter(function (element) {
                return parseInt(element.index) !== parseInt(event.target.accessKey);
            });
            let index = 1 ;
            temp.forEach(element => {
                element.index = index;
                index++
            });
            this.placeholderList = temp;
            this.keyIndex = index-1;
            setTimeout(() => {
                this.isLoaded = true;
            }, 0);
        }
    }

    selectName(event){
        let accessKey = event.target.accessKey
        //Changes added for SSE-22562 
        let placeholderNumber = parseInt(accessKey) + parseInt(this.totalPlaceholders);
        this.placeholderList[accessKey-1].Id = 'Placeholder' + placeholderNumber;
        this.placeholderList[accessKey-1].Name = event.target.value;
    }

    handleCloseAddPlaceholderPopup(){
        const closeAddPlaceholderPopup = new CustomEvent("closeaddplaceholderpopup");
        this.dispatchEvent(closeAddPlaceholderPopup);
    }

    handleBackToSelectionPopup(){
        const backToSelectionPopup = new CustomEvent("backtoselectionpopup");
        this.dispatchEvent(backToSelectionPopup);
    }

    handleCreatePlaceholder(){
        this.showSpinner = true;
        let temp = JSON.parse(JSON.stringify(this.placeholderList));
        let tempAllNodes = JSON.parse(JSON.stringify(this.allNodes));
        let numberOfUnnamedPlaceholders = 1;
        tempAllNodes.forEach(element => {
            if(element.Name.includes('Unnamed')){
                numberOfUnnamedPlaceholders = parseInt(element.Name.substring(8)) + 1 >numberOfUnnamedPlaceholders?parseInt(element.Name.substring(8)) + 1:numberOfUnnamedPlaceholders;
            }
        });
        temp.forEach(element => {
            if(!element.Id || element.Name.trim()==''){
                element.Name = 'Unnamed ' + numberOfUnnamedPlaceholders;
                element.Id = 'Placeholder' + (parseInt(element.index) + parseInt(this.totalPlaceholders));
                numberOfUnnamedPlaceholders++;
            }
            element.ReportsTo = this.parentNode.Id;
            element.IsPlaceholder = true;
            delete element.index;
            delete element.Children;
        });

        tempAllNodes.forEach(element => {
            element.Children = [];
        });

        let finalNodeList = tempAllNodes.concat(temp);

        updateHierarchyOnPlaceholderCreation({ hierarchyList: finalNodeList, hierarchyInformationId: this.hierarchyInformationId })
        .then((result) => {
            this.toasteventForParent('Success ', 'Placeholder added successfully !', 'success', 'dismissible');

            const refreshEvent = new CustomEvent("refreshhierarchy");
            this.dispatchEvent(refreshEvent);
          })
          .catch((error) => {
            if (error.body && error.body.message) {
                let errorMessage = error.body.message;
                this.toasteventForParent('Error', errorMessage, 'error', 'dismissible');
            }else{
                this.toasteventForParent('Error', 'Something went wrong', 'error', 'dismissible');
            }
          })
          .finally(() => {
            this.showSpinner = false;
          });
    }

    toasteventForParent(title, message, variant, mode) {
        this.dispatchEvent(new CustomEvent('toastmessagefromexistingcontactsave', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { title: title, message: message, variant: variant, mode: mode }
            }
        }));
    }
}