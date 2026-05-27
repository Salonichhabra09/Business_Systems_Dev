import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import updateHierarchyOnDelete from '@salesforce/apex/OpportunityContactHierarchy.updateHierarchyOnDelete';
import updateHierarchyOnPlaceholderCreation from '@salesforce/apex/OpportunityContactHierarchy.updateHierarchyOnPlaceholderCreation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ROLE_FIELD from '@salesforce/schema/OpportunityContactRole.Role';
import getOpportunityDetails from '@salesforce/apex/OpportunityContactHierarchy.getOpportunityDetails';
import createContactRecords from '@salesforce/apex/OpportunityContactHierarchy.createContactRecords';
import updateHierarchyOnReplace from '@salesforce/apex/OpportunityContactHierarchy.updateHierarchyOnReplace';

export default class OppContactHierarchyCard extends LightningElement {

    @api contact; // Holds the currently selected contact
    @api contacts; // Holds a list of contacts
    @api recordId; //this is Account Plan Id
    @api zoomLevel; // Holds the zoom level sent from parent component
    @api allContactsList;
    @api hierarchyInformationId;
    @api totalPlaceholders;
    @track modalresize = 'zoom:120%'; // CSS style for resizing the modal dialog
    isOpenAddPlaceholder = false;
    isOpenReparentPopup = false;



    hideTheKidsClass = ''; // CSS class for hiding children elements
    lasContactedClass; // CSS class for styling the contact card bottom border based on the last contacted date

    contactedIconClass; // CSS class for styling the contacted icon
    @track hasKids; // Indicates if there are child elements
    showReplaceButton = true; // Controls the visibility of the replace button
    switchBehaviourClass; // CSS class for handling switch (expand/colapse children treen under a contact) behavior
    showTheKids = true; // Controls the visibility of child elements
    isRootLevel = false;
    showKids = true;
    isAddSelectionPopup = false;
    showChooseContactModal = false;
    isNotReplace = true;
    availableNodesToReparent;
    isDelete = false;
    isOpenPopup = false
    popupTitle;
    isPlaceholderEdit = false;
    showSpinner = false;
    isOpenUpdateContactRole = false;
    showDecisionMakerIcon = false;
    isSaveDisabled = true;
    updatedName;
    contactCardClass;
    currentStickyToast;
    ///////////////////////////////

    showNewContactModal = false;
    showChooseExistingContactModal = false;
    keyIndex = 1;
    accountId;
    oppId;
    @track contactRoleOptions;
    errorMessage = '';
    isEdit = true;
    @track selectedOptions = [];
    updatedSelectedRoles;

    @track contactList;

    get oppName() {
        const rootObject = this.allContactsList.find(item => item.Id === "rootlevel");
        return rootObject ? rootObject.Name : null;
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: ROLE_FIELD })
    wiredcontactRoleValues({ error, data }) {
        // reset values to handle eg data provisioned then error provisioned
        this.contactRoleOptions = [];
        if (data) {
            this.contactRoleOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
            console.log('this.contactRoleOptions: ', JSON.stringify(this.contactRoleOptions));
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getOpportunityDetails, ({ oppName: '$oppName' }))
    getAccountId(value) {
        //this.wiredData = value;
        const { error, data } = value;
        if (error) {
            console.log('error: ', JSON.stringify(error));
            //this.error = error;
            //this.showSpinner = false;
        } else if (data) {
            console.log('data: ', JSON.stringify(data));
            this.accountId = data[0].AccountId;
            this.oppId = data[0].Id;
        }
    }

    /**
 * Initializes the component when it is connected to the DOM.
 * Sets various class names and initial states based on the contact's properties.
 * Counts the number of top-level contacts and determines whether to show the reparent button.
 */
    connectedCallback() {
        console.log('recordId ', this.recordId);
        let self = this;

        if (self.contact.Id == 'rootlevel') {
            this.isRootLevel = true;
        }
        if (self.contact.JobRole && self.contact.JobRole?.includes('Decision Maker')) {
            this.showDecisionMakerIcon = true;
        }

        if (self.contact.IsActive) {
            this.contactCardClass = 'contact-card green';
        }
        else {
            this.contactCardClass = 'contact-card grey';
        }
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = ".title-helptext div.slds-form-element__icon { display: none; }";
        let inputFieldHelpText = this.template.querySelectorAll('.title-helptext');
        inputFieldHelpText.forEach(element => {
            element.appendChild(style);
        });
    }

    /**
     * Handles the event when the contact's "hasKids" property changes.
     * Updates the "hasKids" property of the component based on the event detail.
     * Shows or hides the down arrow icon used to expande colapse the contact subordinates
     * based on the updated "hasKids" value.
     */
    handleHasKids(event) {
        // Update the "hasKids" property of the component with the new value from the event
        this.hasKids = event.detail;

        // Check if the contact has kids
        if (this.hasKids > 0) {
            // If the contact has kids, show the replace button and set the class to show the switch button to expande or 
            // colapse the subordinates contacts
            this.showReplaceButton = true;
            this.switchBehaviourClass = 'switchBtnOn';
        } else if (this.contact.Id == 'rootlevel' && this.contacts.length > 1) { //Changes By Jai
            this.switchBehaviourClass = 'switchBtnOn';
        } else if (this.contact.Id == 'rootlevel' && this.contacts.length == 1) {//Changes By Jai
            this.showKids = false;
            this.switchBehaviourClass = 'switchBtnOff';
        } else {
            // If the contact does not have kids, set the class to hide the switch button to expande or colapse the subordinates contacts
            this.switchBehaviourClass = 'switchBtnOff';
            // If the contact does not have kids Check if the contact is not active, and hide the Replace Contact button
            if (!this.contact.IsActive) {
                this.showReplaceButton = false;
            }
        }
    }

    /**
     * Toggles the visibility of children contacts cards tree.
     * If "showTheKids" is true, hides the children by applying the "hideTheKids" class and sets "showTheKids" to false.
     * If "showTheKids" is false, shows the children by applying the "showTheKids" class and sets "showTheKids" to true.
     */
    hideChildren() {
        let self = this;
        // Check the value of "showTheKids" to determine the current visibility state
        if (self.showTheKids) {
            // If the children are currently shown, hide them by applying the "hideTheKids" class
            self.hideTheKidsClass = 'hideTheKids';
            self.showTheKids = false;
        } else {
            // If the children are currently hidden, show them by applying the "showTheKids" class
            self.hideTheKidsClass = 'showTheKids';
            self.showTheKids = true;
        }
    }

    handleOpenAddPopup() {
        let calc = 100 * 100 / this.zoomLevel;
        this.modalresize = 'zoom:' + calc + '%';
        this.isAddSelectionPopup = true;
    }

    handleCloseAddPopup() {
        this.isAddSelectionPopup = false;
        this.isOpenAddPlaceholder = false;
    }

    handleAddPlaceholder() {
        this.isOpenAddPlaceholder = true;
        this.isAddSelectionPopup = false;
    }

    handleContactChoose(replace) {
        let calc = 100 * 100 / this.zoomLevel;
        this.modalresize = 'zoom:' + calc + '%';
        setTimeout(() => {
            this.isAddSelectionPopup = false;
        }, 0);
        this.isNotReplace = replace == true ? false : true;
        setTimeout(() => {
            this.showChooseContactModal = true;
        }, 0);
    }

    handleBackToSelectionPopup() {
        this.isOpenAddPlaceholder = false;
        this.isAddSelectionPopup = true;
    }

    handleCloseAddPlaceholderPopup() {
        this.isOpenAddPlaceholder = false;
    }

    handleBackEventFromChooseContactPopup() {
        this.isAddSelectionPopup = true;
        this.showChooseContactModal = false;
    }

    handleCloseFromContactPopup() {
        this.showChooseExistingContactModal = false;
    }

    handleRefreshHierarchy() {
        this.handleCloseAddPopup();
        this.isOpenReparentPopup = false;
        console.log('refresh in card');
        this.dispatchEvent(new CustomEvent('refreshhierarchy', {
            bubbles: true,
            composed: true
        }));
    }

    handleSpinnerToggle() {
        const spinnerState = new CustomEvent('triggercontacthierarchyspinner', {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(spinnerState);
    }

    handleActionSelect(event) {
        let action = event.detail.value;
        let self = this;
        if (action == 'Reparent') {
            let temp = this.contacts.filter(function (el) {
                return el.Id != self.contact.Id &&
                    el.Id != self.contact.ReportsTo
            });
            this.availableNodesToReparent = temp;
            this.isOpenReparentPopup = true;
        } else if (action == 'Replace') {
            this.handleContactChoose(true);
        } else if (action == 'Delete') {
            this.isDelete = true;
            this.isOpenPopup = true;
            this.popupTitle = 'Delete Node';
        } else if (action == 'Edit') {
            this.isPlaceholderEdit = true;
            this.isOpenPopup = true;
            this.popupTitle = 'Edit Placeholder';
        }
    }

    handleOpenContactView() {
        const openEvent = new CustomEvent('viewcontact', {
            bubbles: true,
            composed: true,
            detail: {
                contact: this.contact
            }
        });
        this.dispatchEvent(openEvent);
    }

    handleCloseReparentPopup() {
        this.isOpenReparentPopup = false;
    }

    handleCloseUpdateContactRolePopup() {
        this.isOpenUpdateContactRole = false;
    }

    handleOpenUpdateContactRolePopup() {
        this.isOpenUpdateContactRole = true;
    }

    handleClosePopup() {
        this.isDelete = false;
        this.isPlaceholderEdit = false;
        this.isOpenPopup = false;
    }

    handleDeleteNode() {
        this.showSpinner = true;
        let nodeToDeleteId = this.contact.Id;
        let finalNodeList = JSON.parse(JSON.stringify(this.contacts));
        let updatedReportsToId;
        let pos = finalNodeList.map(e => e.Id).indexOf(this.contact.Id);
        updatedReportsToId = finalNodeList[pos].ReportsTo;
        let contactsToUpdate = [];
        finalNodeList.forEach(element => {
            if (element.ReportsTo == this.contact.Id) {
                element.ReportsTo = updatedReportsToId;
                if (!element.IsPlaceholder) {
                    let reportsToIdToUse = finalNodeList[pos].ReportsTo == 'rootlevel' || finalNodeList[pos].ReportsTo.includes('Placeholder') ? null : finalNodeList[pos].ReportsTo;
                    let updatedContact = {
                        Id: element.Id,
                        ReportsToId: reportsToIdToUse
                    };
                    contactsToUpdate.push(updatedContact);
                }
            }
            element.Children = [];
        });

        finalNodeList = finalNodeList.filter(element => element.Id != this.contact.Id);

        console.log(JSON.stringify(finalNodeList));

        let contactToDelete = this.contact.IsPlaceholder ? null : this.contact.Id;

        updateHierarchyOnDelete({ hierarchyList: finalNodeList, hierarchyInformationId: this.hierarchyInformationId, contactsToUpdate: contactsToUpdate, contactToDelete: contactToDelete })
            .then((result) => {
                const event = new ShowToastEvent({
                    title: 'Success !',
                    variant: 'success'
                });
                this.dispatchEvent(event);
                this.dispatchEvent(new CustomEvent('refreshhierarchy', {
                    bubbles: true,
                    composed: true
                }));
                this.handleClosePopup();
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
                this.showSpinner = false;
            });
    }

    handlePlaceholderNameChange(event) {
        this.updatedName = event.target.value;
        this.isSaveDisabled = this.updatedName != this.contact.Name ? false : true;
    }

    handlePlaceholderEdit() {
        this.showSpinner = true;
        let finalNodeList = JSON.parse(JSON.stringify(this.contacts));
        finalNodeList.forEach(element => {
            if (element.Id == this.contact.Id) {
                element.Name = this.updatedName;
            }
            element.Children = [];
        });
        updateHierarchyOnPlaceholderCreation({ hierarchyList: finalNodeList, hierarchyInformationId: this.hierarchyInformationId })
            .then((result) => {
                const event = new ShowToastEvent({
                    title: 'Success !',
                    variant: 'success'
                });
                this.dispatchEvent(event);

                this.dispatchEvent(new CustomEvent('refreshhierarchy', {
                    bubbles: true,
                    composed: true
                }));
                this.handleClosePopup();
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
                this.showSpinner = false;
            });
    }

    convertPlaceholderToContact() {
        this.handleContactChoose(true);
    }

    //// New Contact Code
    handleCloseChooseContactModal() {
        this.showChooseContactModal = false;
    }

    handleBackChooseContact() {
        this.showChooseContactModal = false;
        this.isAddSelectionPopup = true;
    }

    handleChooseNewContact() {
        this.showChooseContactModal = false;
        this.showNewContactModal = true;
        this.showSpinner = true;
        this.contactList = [{
            index: 1,
            isEdit: true,
        }];

    }

    handleChooseExistingContact() {
        this.showChooseContactModal = false;
        this.showChooseExistingContactModal = true;
        setTimeout(() => {
            this.template.querySelector("c-create-contact-in-hierarchy").handleChooseExistingContact();
        }, 0);
    }

    handleClose(event) {
        let accessKey = event.target.accessKey;
        this.contactList[accessKey - 1].isEdit = false;
        if (this.selectedOptions.length > 0) {
            this.contactList[accessKey - 1].isEdit = false;
        } else {
            this.contactList[accessKey - 1].isEdit = true;
        }
    }

    closeEditOnBlur() {
        this.template.querySelectorAll("c-multi-select-combobox-hierarchy").forEach(element => {
            element.close();
        });
    }

    /* Below Functions are used for Adding New Contact Functionality */
    /* Cancel Button */
    handleNewContactCancel() {
        this.showNewContactModal = false;
    }

    /* Back Button */
    handleBackNewContact() {
        this.showNewContactModal = false;
        this.showChooseContactModal = true;
    }

    handleInputRole(event) {
        this.selectedOptions = event.detail;
        let temp = [];
        this.selectedOptions.forEach(element => {
            temp.push(element.label);
        });
        this.updatedSelectedRoles = temp.join(';');
        console.log('this.updatedSelectedRoles: ', this.updatedSelectedRoles);

        let accessKey = event.target.accessKey;
        console.log('accessKey: ', accessKey);
        if (this.updatedSelectedRoles) {
            this.contactList[accessKey - 1].JobRole = this.updatedSelectedRoles;
            console.log('this.contactList: ', JSON.stringify(this.contactList));
        }
    }

    handleInputChange(event) {
        let accessKey = event.target.accessKey;
        const row = this.template.querySelector(`div[data-key="${accessKey}"]`);

        let firstName = row.querySelector('lightning-input-field[data-name="firstName"]').value;
        let lastName = row.querySelector('lightning-input-field[data-name="lastName"]').value;
        this.contactList[accessKey - 1].Name = firstName + ' ' + lastName;

        const fields = row.querySelectorAll("lightning-input-field");
        fields.forEach(field => {
            this.contactList[accessKey - 1][field.fieldName] = field.value;
        });
    }

    /* Save Button */
    handleSaveNewContact() {
        let isVal = true;
        this.errorMessage = '';
        debugger;
        /*this.template.querySelectorAll("c-multi-select-combobox-hierarchy").forEach(element => {
            isVal = isVal && element.checkValidity1();
            console.log('isVal: ', isVal);
        });*/
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if (!element.value && element.required) {
                isVal = false;
                element.reportValidity();
            }
        });

        this.contactList.forEach(element => {
            if (!element.JobRole) {
                this.errorMessage = 'Role is mandatory.';
                isVal = false;
                this.toast('Error', this.errorMessage, 'error', 'dismissible');
            }
        });

        if (this.isNotReplace) {

            if (isVal) {
                this.showSpinner = true;

                const forms = this.template.querySelectorAll('lightning-record-edit-form');
                console.log('forms: ', JSON.stringify(forms));

                console.log('contactList: ', JSON.stringify(this.contactList));
                let contactWrapper = [];
                this.contactList.forEach((form, index) => {
                    contactWrapper.push({
                        index: index + 1,
                        //salutation: form.Salutation,
                        firstName: form.FirstName,
                        lastName: form.LastName,
                        accountId: this.accountId,
                        email: form.Email,
                        title: form.Title,
                        advocacyLevel: form.Advocacy_Level__c,
                        jobFunction: form.Job_Function__c,
                        role: form.JobRole,
                        phone: form.Phone
                    });
                });
                console.log('contactWrapper: ', JSON.stringify(contactWrapper));
                createContactRecords({
                    contactList: contactWrapper,
                    oppId: this.oppId,
                    hierarchyInformationId: this.hierarchyInformationId,
                    parentNodeId: this.contact.Id,
                    allNodes: this.allContactsList
                })
                    .then(data => {
                        console.log('data: ', JSON.stringify(data));
                        this.toast('SUCCESS', 'Contact added successfully!', 'success', 'dismissible');
                        /*const event = new ShowToastEvent({
                            title: 'Success !',
                            message: 'Contact added successfully!',
                            variant: 'success'
                        });
                        this.dispatchEvent(event);*/
                    })
                    .catch(error => {
                        console.log('error: ', error);
                        if (error.body && error.body.message) {
                            let errorMessage = error.body.message;
                            this.toast('Error', errorMessage, 'error', 'dismissible');
                        } else {
                            this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                        }

                        /*const event = new ShowToastEvent({
                            title: 'Error',
                            message: errorMessage,
                            variant: 'error'
                        });
                        this.dispatchEvent(event);*/
                    })
                    .finally(() => {
                        this.showSpinner = false;
                        this.refreshPage();
                        this.showNewContactModal = false;
                    })
            } else {

            }
        } else {
            if (isVal) {
                this.showSpinner = true;
                console.log(JSON.stringify(this.contactList));
                let temp = JSON.parse(JSON.stringify(this.contactList));
                let contactToCreate = {};
                let jobRoleToUse;
                temp.forEach(element => {
                    contactToCreate.FirstName = element.FirstName;
                    contactToCreate.LastName = element.LastName;
                    contactToCreate.Email = element.Email;
                    contactToCreate.Phone = element.Phone;
                    contactToCreate.AccountId = element.AccountId;
                    //contactToCreate.Salutation = element.Salutation;
                    contactToCreate.Title = element.Title;
                    contactToCreate.Advocacy_Level__c = element.Advocacy_Level__c;
                    contactToCreate.Job_Function__c = element.Job_Function__c;
                    jobRoleToUse = element.JobRole;
                });
                let replacedId = 'newIdToReplace';
                let currentNodeId = this.contact.Id;
                let finalNodeList = JSON.parse(JSON.stringify(this.allContactsList));
                finalNodeList.forEach(element => {
                    if (element.Id == currentNodeId) {
                        element.Id = replacedId;
                        element.JobRole = jobRoleToUse;// To add Job Role
                    }
                    if (element.ReportsTo == currentNodeId) {
                        element.ReportsTo = replacedId;
                    }
                    element.Children = [];
                });
                console.log('finalNodeList: ', JSON.stringify(finalNodeList));
                console.log('this.hierarchyInformationId,: ', this.hierarchyInformationId);
                updateHierarchyOnReplace({
                    hierarchyList: finalNodeList,
                    hierarchyInformationId: this.hierarchyInformationId,
                    replacedId: replacedId,
                    contactToReplace: contactToCreate,
                    contactsToUpdate: [],
                    contactToDelete: currentNodeId,
                    jobRoleOfContactToReplace: jobRoleToUse
                })
                    .then((result) => {
                        const event = new ShowToastEvent({
                            title: 'Success !',
                            variant: 'success'
                        });
                        this.dispatchEvent(event);

                        this.showSpinner = false;
                        this.refreshPage();
                        this.showNewContactModal = false;
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
                        this.showSpinner = false;
                    });
            } else {

            }
        }
    }

    toast(title, message, variant, mode) {
        // Close all sticky toasts if the new toast is not sticky
        /*if (this.currentStickyToast && mode !== 'sticky') {
            this.currentStickyToast.close();
            this.currentStickyToast = null;
        }*/

        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
        })

        // If the new toast is sticky, store it for future reference
        /*if (mode === 'sticky') {
            this.currentStickyToast = toastEvent;
        }*/
        this.dispatchEvent(toastEvent)
    }

    refreshPage() {
        const refreshEvent = new CustomEvent("refreshhierarchy", {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(refreshEvent);
    }

    // Add New Row
    addRow() {
        ++this.keyIndex;
        var newItem = [{ index: this.keyIndex, isEdit: true }];
        this.contactList = this.contactList.concat(newItem);
    }

    // Remove or Delete Row
    removeRow(event) {
        debugger;
        if (this.contactList.length >= 2) {
            let temp = JSON.parse(JSON.stringify(this.contactList));
            temp = temp.filter(function (element) {
                return parseInt(element.index) !== parseInt(event.target.accessKey);
            });
            let index = 1;
            temp.forEach(element => {
                element.index = index;
                index++
            });
            this.contactList = temp;
            this.keyIndex = index - 1;
        }
    }

    handleEdit(event) {
        let accessKey = event.target.accessKey;
        event.stopPropagation();
        console.log('accessKey: ', accessKey);
        this.contactList[accessKey - 1].isEdit = true;
    }

    handleBackFromExistingContactScreen() {
        this.showChooseContactModal = true;
        this.showChooseExistingContactModal = false;
    }

    handleFieldsLoad() {
        this.showSpinner = false;
    }

    handletoastmessagefromexistingcontactsave(event) {
        console.log('in toast');
        var toastInfo = event.detail.data;
        this.toast(toastInfo.title, toastInfo.message, toastInfo.variant, toastInfo.mode);
    }

}