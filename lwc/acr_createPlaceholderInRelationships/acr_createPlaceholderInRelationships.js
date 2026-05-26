import { LightningElement, track, api } from 'lwc';
import updateHierarchyOnPlaceholderCreation from '@salesforce/apex/ACR_RelationshipMapController.updateHierarchyOnPlaceholderCreation';
import updateRelationshipMapOnReplace from '@salesforce/apex/ACR_RelationshipMapController.updateRelationshipMapOnReplace';

export default class Acr_createPlaceholderInRelationships extends LightningElement {

    @api totalPlaceholders;
    @api parentNode;
    @api allNodes;
    @api modalresize;
    @api hierarchyInformationId;
    @api isNotReplace;
    @api actionType;
    @track placeholderList = [
        {
            index: 1,
        }
    ];
    keyIndex = 1;
    isShowSpinner = false;
    selectedRow;
    placeholderNodes;
    showPlaceholderList = false;
    isReplaceDisabled = true;
    isExistingPlaceholderAvailable = false;

    columns = [
        { label: 'Name', fieldName: 'Name', hideDefaultActions: true },
    ];

    connectedCallback() {
        if (!this.isNotReplace && this.actionType == 'replace') {
            let placeholderNodes = [];
            let finalNodeList = JSON.parse(JSON.stringify(this.allNodes));
            finalNodeList.forEach(element => {
                if (element.IsPlaceholder) {
                    placeholderNodes.push(element);
                }
                element.Children = [];
            });
            this.placeholderNodes = [...placeholderNodes];
            this.showPlaceholderList = true;
            if(this.placeholderNodes.length > 0) {
                this.isExistingPlaceholderAvailable = true;
            }
        }
    }

    // This function is used to create Placeholder(s) and add those in the Relationship Map.
    handleCreatePlaceholder() {
        this.isShowSpinner = true;
        let finalNodeList = [];
        if (this.isNotReplace) {
            let temp = JSON.parse(JSON.stringify(this.placeholderList));
            let tempAllNodes = JSON.parse(JSON.stringify(this.allNodes));
            let numberOfUnnamedPlaceholders = 1;
            tempAllNodes.forEach(element => {
                if (element.Name.includes('Unnamed')) {
                    numberOfUnnamedPlaceholders = parseInt(element.Name.substring(8)) + 1 > numberOfUnnamedPlaceholders ? parseInt(element.Name.substring(8)) + 1 : numberOfUnnamedPlaceholders;
                }
            });
            temp.forEach(element => {
                if (!element.Id || element.Name.trim() == '') {
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

            finalNodeList = tempAllNodes.concat(temp);
        } else {
            let currentNodeId = this.parentNode.Id;
            console.log(currentNodeId);
            finalNodeList = JSON.parse(JSON.stringify(this.allNodes));
            let replacedId;
            let numberOfUnnamedPlaceholders = 1;
            finalNodeList.forEach(element => {
                if (element.Name.includes('Unnamed')) {
                    numberOfUnnamedPlaceholders = parseInt(element.Name.substring(8)) + 1 > numberOfUnnamedPlaceholders ? parseInt(element.Name.substring(8)) + 1 : numberOfUnnamedPlaceholders;
                }
            });
            finalNodeList.forEach(element => {
                if (element.Id == currentNodeId) {
                    console.log('this.placeholderList[0].Name: ', this.placeholderList[0].Name);
                    console.log('this.placeholderList[0].Id: ', this.placeholderList[0].Id);
                    console.log('this.totalPlaceholders: ', this.totalPlaceholders);
                    element.Name = this.placeholderList[0].Name;
                    replacedId = this.placeholderList[0].Id;
                    element.Id = replacedId;
                    if (!element.Id || element.Name.trim() == '') {
                        element.Name = 'Unnamed ' + numberOfUnnamedPlaceholders;
                        element.Id = 'Placeholder' + (parseInt(this.placeholderList[0].index) + parseInt(this.totalPlaceholders));
                        replacedId = element.Id;
                        numberOfUnnamedPlaceholders++;
                    }
                    element.Persona = null;
                    element.IsEconomicBuyer = null;
                    element.IsActive = null;
                    element.AdvocacyLevel = null;
                    element.EconomicBuyerCategory = null;
                    element.JobRole = null;
                    element.JobFunction = null;
                    element.IsPlaceholder = true;
                }
                if (element.ReportsTo == currentNodeId) {
                    element.ReportsTo = replacedId;
                }
                element.Children = [];
            });
            console.log('finalNodeList: ', JSON.stringify(finalNodeList));
        }

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
                } else {
                    this.toasteventForParent('Error', 'Something went wrong', 'error', 'dismissible');
                }
            })
            .finally(() => {
                this.isShowSpinner = false;
            });
    }

    // To add a new row 
    addRow() {
        ++this.keyIndex;
        var newItem = [{ index: this.keyIndex }];
        this.placeholderList = this.placeholderList.concat(newItem);
    }

    // To remove a row
    removeRow(event) {
        if (this.placeholderList.length >= 2) {
            this.isLoaded = false;
            let temp = JSON.parse(JSON.stringify(this.placeholderList));
            temp = temp.filter(function (element) {
                return parseInt(element.index) !== parseInt(event.target.accessKey);
            });
            let index = 1;
            temp.forEach(element => {
                element.index = index;
                index++
            });
            this.placeholderList = temp;
            this.keyIndex = index - 1;
            setTimeout(() => {
                this.isLoaded = true;
            }, 0);
        }
    }

    // To get placeholder name from user
    handlePlaceholderName(event) {
        let accessKey = event.target.accessKey
        //Changes added for SSE-22562 
        let placeholderNumber = parseInt(accessKey) + parseInt(this.totalPlaceholders);
        this.placeholderList[accessKey - 1].Id = 'Placeholder' + placeholderNumber;
        this.placeholderList[accessKey - 1].Name = event.target.value;
    }

    // Close Button
    handleCloseAddPlaceholderPopup() {
        const closeAddPlaceholderPopup = new CustomEvent("closeaddplaceholderpopup");
        this.dispatchEvent(closeAddPlaceholderPopup);
    }

    // Back Button
    handleBackToSelectionPopup() {
        const backToSelectionPopup = new CustomEvent("backtoselectionpopup");
        this.dispatchEvent(backToSelectionPopup);
    }

    // Toast event to parent component
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

    handleRowSelection(event) {
        this.selectedRow = event.detail.selectedRows[0];
        this.isReplaceDisabled = this.selectedRow ? false : true;
    }

    handleReplaceExistingPlaceholder() {
        this.showSpinner = true;
        let replacedId = this.selectedRow.Id;
        let currentNodeId = this.parentNode.Id;
        let finalNodeList = JSON.parse(JSON.stringify(this.allNodes));
        let replacedNode = finalNodeList.filter(element => element.Id == replacedId);

        if (replacedNode.length > 0 && JSON.stringify(replacedNode[0]?.Children)?.includes(currentNodeId)) {
            finalNodeList.forEach(element => {
                if (element.ReportsTo == replacedNode[0].Id) {
                    element.ReportsTo = replacedNode[0].ReportsTo;
                    console.log(JSON.stringify(element));
                }
            });
        }
        finalNodeList = finalNodeList.filter(element => element.Id != replacedId);

        finalNodeList.forEach(element => {
            if (element.Id == currentNodeId) {
                element.Id = replacedId;
                element.IsPlaceholder = true;
                element.Persona = null;
                element.IsEconomicBuyer = null;
                element.IsActive = null;
                element.AdvocacyLevel = null;
                element.EconomicBuyerCategory = null;
                element.JobRole = null;
                element.JobFunction = null;
                element.Name = this.selectedRow.Name;
            }

            if (element.ReportsTo == currentNodeId) {
                element.ReportsTo = replacedId;
            }
            element.Children = [];
        });

        updateRelationshipMapOnReplace({
            hierarchyList: finalNodeList,
            hierarchyInformationId: this.hierarchyInformationId,
            replacedId: null,
            contactToReplace: null,
            contactsToUpdate: [],
            contactToDelete: this.parentNode.Id
        })
            .then((result) => {
                this.toasteventForParent('Success!', '', 'success', 'dismissible');
                const refreshEvent = new CustomEvent("refreshhierarchy");
                this.dispatchEvent(refreshEvent);
            })
            .catch((error) => {
                if (error.body && error.body.message) {
                    let errorMessage = error.body.message;
                    this.toasteventForParent('Error', errorMessage, 'error', 'dismissible');
                } else {
                    this.toasteventForParent('Error', 'Something went wrong', 'error', 'dismissible');
                }
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }


}