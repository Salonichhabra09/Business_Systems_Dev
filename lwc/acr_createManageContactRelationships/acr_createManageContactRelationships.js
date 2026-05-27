import { LightningElement, api, wire, track } from 'lwc';
import createHierarchyOnAccount from '@salesforce/apex/ACR_RelationshipMapController.createHierarchyOnAccount';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";
import getListOfRelationships from '@salesforce/apex/ACR_RelationshipMapController.getListOfRelationships';
import deleteHierarchy from '@salesforce/apex/ACR_RelationshipMapController.deleteHierarchy';
import renameHierarchy from '@salesforce/apex/ACR_RelationshipMapController.renameHierarchy';

export default class Acr_createManageContactRelationships extends NavigationMixin(LightningElement) {

    @api recordId;
    @track existingHierarchyList;

    isShowSpinner = true;
    hasNoContactHierarchy = true;
    hasContactHierarchy = false;
    isOpenPopup = false
    isCreateRecord = false;
    isSubmitDisabled = true;
    isComponentVisible = true;
    isDeleteVisible = true;
    isDeleteRecord = false;
    isRenameRecord = false;

    headerTitle = 'Create Relationship Map';
    hierarchyName = '';
    wiredData;
    hierarchyId;

    @wire(getListOfRelationships, ({ accountId: '$recordId' }))
    getHierarchyList(value) {
        this.wiredData = value;
        const { error, data } = value;
        if (error) {
            console.log('error: ', JSON.stringify(error));
        } else if (data) {
            this.isShowSpinner = false;
            console.log('Wire data: ', JSON.stringify(data));
            this.hasNoContactHierarchy = data.length === 0;
            let tempRecords = JSON.parse(JSON.stringify(data));
            tempRecords = tempRecords.map((element) => {
                // Convert to a Date object
                const dateObj = new Date(element.LastModifiedDate);

                // Extract day, month, and year
                const day = String(dateObj.getDate()).padStart(2, '0'); // Ensures two digits
                const month = String(dateObj.getMonth() + 1).padStart(2, '0'); // Months are 0-based
                const year = dateObj.getFullYear();

                // Format as DD/MM/YYYY
                const formattedDate = `${day}/${month}/${year}`;
                console.log(formattedDate);
                return {
                    ...element,
                    formattedDate: formattedDate
                };
            });
            console.log('tempRecords: ', JSON.stringify(tempRecords));
            this.existingHierarchyList = tempRecords;
        }
    }

    /**
     * @description : Function to open the create hierarchy popup
     * @return : void
    **/
    handleCreateHierarchyPopupOpen() {
        this.isDeleteRecord = false;
        this.isSubmitDisabled = true;
        this.headerTitle = 'Create Relationship Map';
        this.isOpenPopup = true;
    }

    /**
     * @description : Function to close the create hierarchy popup
     * @return : void
    **/
    handleCreateHierarchyPopupClose() {
        this.isOpenPopup = false;
    }

    /**
     * @description : Function to handle the change in hierarchy name
     * @param event : Change event object
     * @return : void
    **/
    handleChangeOfHierarchyName(event) {
        this.hierarchyName = event.target.value;
        this.isSubmitDisabled = this.hierarchyName.trim().length >= 2 ? false : true;
    }

    /**
     * @description : Function to create hierarchy
     * @return : void
    **/
    handleCreateHierachy() {
        this.isShowSpinner = true;
        let isDuplicate = this.handleDuplicateNameCheck();
        if (isDuplicate) {
            this.toast('Error', 'Relationship Map name already exists.', 'error', 'dismissible');
            this.isShowSpinner = false;
            return;
        }
        createHierarchyOnAccount({ accountId: this.recordId, hierarchyName: this.hierarchyName })
            .then((result) => {

                if (result != '') {
                    refreshApex(this.wiredData);
                    this[NavigationMixin.GenerateUrl]({
                        type: "standard__navItemPage",
                        attributes: {
                            apiName: 'Contact_Relationship_Map'
                        },
                        state: {
                            c__recordId: result,
                            c__hierarchyName: this.hierarchyName
                        }
                    }).then(url => {
                        window.open(url, "_blank");
                    });
                    //this.handleCreateHierarchyPopupClose();
                    this.handleClose();
                }
            })
            .catch((error) => {
                if (error.body && error.body.message) {
                    let errorMessage = error.body.message;
                    this.toast('Error', errorMessage, 'error', 'dismissible');
                } else {
                    this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                }
            })
            .finally(() => {
                this.isShowSpinner = false;
            });
    }

    /**
     * @description : Function to show toast
     * @param title : Title of the toast
     * @param message : Message to be displayed in the toast
     * @param variant : Variant of the toast (success, error, warning, info)
     * @param mode : Mode of the toast (dismissible, persistent)
     * @return : void
    **/
    toast(title, message, variant, mode) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
        })
        this.dispatchEvent(toastEvent)
    }

    /**
     * @description : Function to manage hierarchy
     * @param event : Click event object
     * @return : void
    **/
    handleManageHierarchy(event) {
        let hierarchyId = event.target.accessKey;
        let hierarchyName = event.target.dataset.name;
        this[NavigationMixin.GenerateUrl]({
            type: "standard__navItemPage",
            attributes: {
                apiName: 'Contact_Relationship_Map'
            },
            state: {
                c__recordId: hierarchyId,
                c__hierarchyName: hierarchyName
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    /**
     * @description : Function to manage delete hierarchy
     * @param event : Click event object
     * @return : void
    **/
    handleDeleteHierarchy(event) {
        this.hierarchyId = event.target.accessKey;
        this.headerTitle = 'Delete Contact Relationship Map';
        this.isDeleteRecord = true;
        this.isOpenPopup = true;
    }

    /**
     * @description : Function to delete hierarchy record
     * @return : void
    **/
    handleDeleteOnHierarchy() {

        this.isShowSpinner = true;

        deleteHierarchy({ hierarchyInformationId: this.hierarchyId })
            .then((result) => {
                refreshApex(this.wiredData);
                this.handleClose();
                this.toast('Relationship Map deleted successfully !', '', 'success', 'dismissible');
            })
            .catch((error) => {
                if (error.body && error.body.message) {
                    let errorMessage = error.body.message;
                    this.toast('Error', errorMessage, 'error', 'dismissible');
                } else {
                    this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                }
            })
            .finally(() => {
                this.isShowSpinner = false;
            });
    }

    /**
     * @description : Function to close the popup
     * @return : void
    **/
    handleClose() {
        this.isOpenPopup = false;
        this.isDeleteRecord = false;
        this.hierarchyName = '';
        this.isSubmitDisabled = true;
        this.isRenameRecord = false;
    }

    /**
     * @description : Function to check the duplicate
     * @return : True if the name is duplicate else false
    **/
    handleDuplicateNameCheck() {
        let isDuplicate = false;
        this.existingHierarchyList.forEach(element => {
            if (element.Hierarchy_Name__c.trim().toLowerCase() == this.hierarchyName.trim().toLowerCase()) {
                isDuplicate = true;
            }
        });

        return isDuplicate;
    }

    handleRenameHierarchy(event) {
        this.isOpenPopup = true;
        this.isRenameRecord = true;
        this.headerTitle = 'Rename Hierarchy';
        this.hierarchyName = event.target.dataset.name;
        this.hierarchyId = event.target.accessKey;
    }

    handleRenameOnHierarchy() {

        this.isShowSpinner = true;
        this.isRenameRecord = false;

        renameHierarchy({ hierarchyName: this.hierarchyName, hierarchyInformationId: this.hierarchyId })
            .then((result) => {
                refreshApex(this.wiredData);
                this.handleClose();
                this.toast('Relationship Map renamed successfully !', '', 'success', 'dismissible');
            })
            .catch((error) => {
                if (error.body && error.body.message) {
                    let errorMessage = error.body.message;
                    this.toast('Error', errorMessage, 'error', 'dismissible');
                } else {
                    this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                }
            })
            .finally(() => {
                this.isShowSpinner = false;
            });
    }

}