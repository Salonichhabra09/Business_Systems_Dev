import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createContactRecords from '@salesforce/apex/ACR_RelationshipMapController.createContactRecords';
import updateAdvocacyLevelOnContact from '@salesforce/apex/ACR_RelationshipMapController.updateAdvocacyLevelOnContact';
import updateRelationshipMapOnReplace from '@salesforce/apex/ACR_RelationshipMapController.updateRelationshipMapOnReplace';
import updateHierarchyOnPlaceholderCreation from '@salesforce/apex/ACR_RelationshipMapController.updateHierarchyOnPlaceholderCreation';
import updateHierarchyOnDelete from '@salesforce/apex/ACR_RelationshipMapController.updateRelationshipMap';
import ICON from '@salesforce/resourceUrl/Linked_to_Open_and_Closed_Won_Opportunity_Icon';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ADVOCACY_LEVEL_FIELD from '@salesforce/schema/Contact.Advocacy_Level__c';
import updateHierarchyOnReparent from '@salesforce/apex/ACR_RelationshipMapController.updateRelationshipMap';
import { publish, subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import COMMUNICATION_CHANNEL from '@salesforce/messageChannel/acr_componentCommunication__c';
import updateEconomicBuyerOrIOPsychologistStatus from '@salesforce/apex/ACR_RelationshipMapController.updateEconomicBuyerOrIOPsychologistStatus';

export default class ComponentB extends LightningElement {

    @api contact; // Holds the currently selected contact
    @api contacts; // Holds a list of contacts
    @api recordId; //this is Account Id
    @api zoomLevel; // Holds the zoom level sent from parent component
    @api allContactsList;
    @api hierarchyInformationId;// this is hierarhcy Id
    @api totalPlaceholders;
    @api contactTitleToDisplay;
    @track modalresize = 'zoom:120%'; // CSS style for resizing the modal dialog
    isOpenAddPlaceholder = false;
    isOpenReparentPopup = false;
    actionType;
    //
    contactTitleValueToDisplay;


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
    isShowSpinner = false;
    isOpenUpdateContactRole = false;
    showInfluencerIcon = false;
    showBlockerIcon = false;
    showDecisionMakerIcon = false;
    isSaveDisabled = true;
    updatedName;
    contactCardClass;
    currentStickyToast;
    toggleColor;
    allRoleNames;
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
    @track advocacyLevelOptions = [];
    isLinkedToOpenAndClosedWonOpportunity = false;
    linkedToOpenAndClosedWonOpportunityIcon = ICON;
    opportunityLinkedStatus = '';
    noteIconClass;
    showPlaceholderOptions = false;
    isNotPlaceholderConversion = true;
    hasDragStartFrom = false;
    placeholderCardClass = 'placeholder-card';
    rootCardClass = 'aLinkForOpportunityCard';

    conCount = 0; // Number of child contacts
    has_conCount = false; // Indicates whether there are child contacts
    hasSourceSelected = false;
    hasTargetSelected = false;
    sourceNodeId;
    targetNodeId;
    eventHandler = null;
    isNotSelectionMode = true;
    isCloseSelectionMode = false;
    isInfluenceSelectionMode = false;

    //@api browserZoomLevel = 1; // Default 100%

    @wire(MessageContext)
    messageContext;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: ADVOCACY_LEVEL_FIELD })
    wiredcontactRoleValues({ error, data }) {
        // reset values to handle eg data provisioned then error provisioned
        this.advocacyLevelOptions = [];
        if (data) {
            const filteredOptions = data.values.filter(item => item.value !== "Champion" && item.value !== "Coach");
            this.advocacyLevelOptions = [...filteredOptions];
        } else if (error) {
            console.log(error);
        }
    }

    /**
* Initializes the component when it is connected to the DOM.
* Sets various class names and initial states based on the contact's properties.
* Counts the number of top-level contacts and determines whether to show the reparent button.
*/
    connectedCallback() {
        // Added Advocacy Level below to resolve Advocacy Level Reset Issue
        this.contactList = [{
            index: 1,
            Advocacy_Level__c: 'None',
        }];
        let self = this;

        if (self.contact.Id == 'rootlevel') {
            this.isRootLevel = true;
        }

        if (self.contact.IsActive) {
            this.contactCardClass = 'contact-card green';
        }
        else {
            this.contactCardClass = 'contact-card grey';
        }

        //SSE-27602: Start
        this.toGetTitleValueToDisplayOnContactCard(this.contactTitleToDisplay, self.contact);
        //SSE-27602: End

        this.allRoleNames = self.contact.JobRole != null ? self.contact.JobRole : 'No Roles Added';
        //this.roles != null ? this.template.querySelector('[data-id="myDiv"]').classList.remove('redBackGround') : this.template.querySelector('[data-id="myDiv"]').classList.add('redBackGround');
        self.contact.JobRole != null ? this.toggleColor = 'enlargeIcon' : this.toggleColor = 'enlargeIcon redBackGround';
        if (self.contact.OpportunityLinkedStatus == 'Linked to Open and Closed Won Opportunity') {
            this.isLinkedToOpenAndClosedWonOpportunity = true;
        } else {
            this.isLinkedToOpenAndClosedWonOpportunity = false;
        }
        if (self.contact.OpportunityLinkedStatus) {
            self.opportunityLinkedStatus = self.contact.OpportunityLinkedStatus.replaceAll(' ', '-').toLowerCase();
        }

        if (self.contact.IsNoteAdded) {
            self.noteIconClass = 'note-added-icon enlargeIcon';
        } else {
            self.noteIconClass = 'note-not-added-icon enlargeIcon';
        }

        /* SSE-27602: Calling LMS to update contact Card title instantly on user selection (by Aashi) */
        subscribe(this.messageContext, COMMUNICATION_CHANNEL, (message) => {
            if (message.action === 'selectionMode') {
                this.isInfluenceSelectionMode = message.isInfluenceSelectionMode;
                if (message.nodeType == 'Source') {
                    this.sourceNodeId = message.nodeId;
                    this.hasSourceSelected = true;
                    this.hasTargetSelected = false;
                    this.eventHandler = message.eventHandler;
                    if (this.sourceNodeId !== this.contact.Id) {
                        this.contactCardClass += ' selection-mode';
                    } else {
                        this.isCloseSelectionMode = true;
                    }
                    this.isNotSelectionMode = false;
                }
                if (message.nodeType == 'Target') {
                    this.targetNodeId = message.nodeId;
                    this.hasTargetSelected = true;
                    this.hasSourceSelected = false;
                    this.eventHandler = message.eventHandler;
                }
            }
            else if (message.action === 'drawExistingLines' && message.nodeId == this.contact.Id) {
                let influenceJson = (message.influenceJson);
                let influenceJson1 = JSON.parse(message.influenceJson);
                if (influenceJson) {
                    console.log('&&& inside influence 1');
                    influenceJson1.forEach(element => {
                        if (message.hasSource && element.target == this.contact.Id) {
                            this.sendNodePosition('Target', 'existing', 'influence');
                        }
                    });
                }
            }
            else if ((message.action === 'requestNodePositions')) {

                let influenceJson = (message.influenceJson);
                console.log('&&& influence ' + influenceJson);
                if (influenceJson) {
                    let influenceJson1 = JSON.parse(message.influenceJson);
                    console.log('&&& influence ' + influenceJson1);
                    influenceJson1.forEach(element => {
                        let hasSource = true;
                        if (element.source == this.contact.Id) {
                            this.sendNodePosition('Source', 'existing', 'influence');
                            publish(this.messageContext, COMMUNICATION_CHANNEL, {
                                action: 'drawExistingLines',
                                influenceJson: message.influenceJson,
                                hasSource: hasSource,
                                nodeId: element.target
                            });
                        }
                    });
                }
            }
            else if ((message.action === 'requestNodePositionsForConflictLines')) {
                let conflictJson = (message.conflictJson);

                if (conflictJson) {
                    let conflictJson1 = JSON.parse(message.conflictJson);
                    conflictJson1.forEach(element => {
                        let hasSource = true;
                        if (element.source == this.contact.Id) {
                            this.sendNodePosition('Source', 'existing', 'conflict');
                            publish(this.messageContext, COMMUNICATION_CHANNEL, {
                                action: 'drawExistingConflictLines',
                                conflictJson: message.conflictJson,
                                hasSource: hasSource,
                                nodeId: element.target
                            });
                        }
                    });
                }
            }
            else if (message.action === 'drawExistingConflictLines' && message.nodeId == this.contact.Id) {
                let conflictJson = (message.conflictJson);
                let conflictJson1 = JSON.parse(message.conflictJson);
                if (conflictJson) {
                    conflictJson1.forEach(element => {
                        if (message.hasSource && element.target == this.contact.Id) {
                            this.sendNodePosition('Target', 'existing', 'conflict');
                        }
                    });
                }
            }
            else if ((message.action === 'removeSelectionMode')) {
                this.hasSourceSelected = false;
                this.sourceNodeId = undefined;
                if (this.contactCardClass.includes('selection-mode')) {
                    this.contactCardClass = this.contactCardClass
                        .split(' ')
                        .filter(cls => cls !== 'selection-mode')
                        .join(' ');
                }
                this.isNotSelectionMode = true;
                this.isCloseSelectionMode = false;
            } //SSE-27602: Start
            else if (message.action === 'updateContactTitleValue') {
                this.toGetTitleValueToDisplayOnContactCard(message.contactTitleToDisplay, this.contact);
            }
            //SSE-27602: End
        });
        //}
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = ".title-helptext div.slds-form-element__icon { display: none; }";
        let inputFieldHelpText = this.template.querySelectorAll('.title-helptext');
        inputFieldHelpText.forEach(element => {
            element.appendChild(style);
        });
    }

    //SSE-27602: Start Get value based on selected contact field (by Aashi)
    toGetTitleValueToDisplayOnContactCard(contactTitleToDisplay, contact) {
        if (contactTitleToDisplay == 'Persona') {
            this.contactTitleValueToDisplay = contact.Persona;
        } else if (contactTitleToDisplay == 'JobTitle') {
            this.contactTitleValueToDisplay = contact.JobTitle;
        } else if (contactTitleToDisplay == 'AreaOfInterest') {
            this.contactTitleValueToDisplay = contact.AreaOfInterest;
        } else if (contactTitleToDisplay == 'City') {
            this.contactTitleValueToDisplay = contact.City;
        } else if (contactTitleToDisplay == 'State') {
            this.contactTitleValueToDisplay = contact.State;
        } else if (contactTitleToDisplay == 'Country') {
            this.contactTitleValueToDisplay = contact.Country;
        }
    }
    //SSE-27602: End

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

    handleOpenAddPopup(type) {
        if (this.isNotSelectionMode) {
            this.isNotReplace = type == 'replace' ? false : true;
            let calc = 100 * 100 / this.zoomLevel;
            this.modalresize = 'zoom:' + calc + '%';
            this.isAddSelectionPopup = true;
        }
    }

    handleCloseAddPopup() {
        this.isAddSelectionPopup = false;
        this.isOpenAddPlaceholder = false;
    }

    handleAddPlaceholder() {
        if (this.isNotSelectionMode) {
            if (this.isNotReplace) {
                this.isOpenAddPlaceholder = true;
            } else {
                this.showPlaceholderOptions = true;
            }
            this.isAddSelectionPopup = false;
        }
    }

    handleContactChoose(replace) {
        if (this.isNotSelectionMode) {
            let calc = 100 * 100 / this.zoomLevel;
            this.modalresize = 'zoom:' + calc + '%';
            setTimeout(() => {
                this.isAddSelectionPopup = false;
            }, 0);
            //this.isNotReplace = replace == true ? false : true;
            setTimeout(() => {
                this.showChooseContactModal = true;
            }, 0);
        }
    }

    handleBackToSelectionPopup() {
        this.isOpenAddPlaceholder = false;
        if (this.isNotReplace) {
            this.isAddSelectionPopup = true;
        } else {
            this.showPlaceholderOptions = true;
        }
    }

    handleCloseAddPlaceholderPopup() {
        this.isOpenAddPlaceholder = false;
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

    // Add Existing Conatact in Relationships

    handleChooseExistingContact() {
        this.showChooseContactModal = false;
        this.showChooseExistingContactModal = true;
        //this.isNotPlaceholderConversion = true;
        setTimeout(() => {
            this.template.querySelector("c-acr_add-existing-contact-in-relationships").handleChooseExistingContact();
        }, 0);
    }

    handleBackEventFromChooseContactPopup() {
        this.isAddSelectionPopup = true;
        this.showChooseContactModal = false;
    }

    handleCloseFromContactPopup() {
        this.showChooseExistingContactModal = false;
        this.isNotReplace = true;
    }

    handleBackFromExistingContactScreen() {
        this.showChooseContactModal = true;
        this.showChooseExistingContactModal = false;
    }

    handletoastmessagefromexistingcontactsave(event) {
        var toastInfo = event.detail.data;
        this.toast(toastInfo.title, toastInfo.message, toastInfo.variant, toastInfo.mode);
    }

    handleRefreshHierarchy() {
        this.handleCloseAddPopup();
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

    handleClosePopup() {
        this.isDelete = false;
        this.isPlaceholderEdit = false;
        this.isOpenPopup = false;
        this.isOpenReparentPopup = false;
    }

    // Create New Contact in Relationships
    /* Below Functions are used for Adding New Contact Functionality */
    handleChooseNewContact() {
        //this.isNotPlaceholderConversion = true;
        this.showChooseContactModal = false;
        this.showNewContactModal = true;
        this.isShowSpinner = true;
        // Added Advocacy Level below to resolve Advocacy Level Reset Issue
        this.contactList = [{
            index: 1,
            Advocacy_Level__c: 'None',
        }];
    }

    handleFieldsLoad() {
        this.isShowSpinner = false;
        // Commented below to reolve Advocacy Level Reset Issue
        /*this.contactList.forEach(row => {
            row.Advocacy_Level__c = 'None';
        });*/
    }

    /* Cancel Button */
    handleNewContactCancel() {
        this.showNewContactModal = false;
        this.isNotReplace = true;
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

        let accessKey = event.target.accessKey;
        if (this.updatedSelectedRoles) {
            this.contactList[accessKey - 1].JobRole = this.updatedSelectedRoles;
        }
    }

    handleInputChange(event) {
        debugger;
        let accessKey = event.target.accessKey;
        if (event.target.name) {
            if (event.target.name == 'advocacyLevelField') {
                this.contactList[accessKey - 1].Advocacy_Level__c = event.target.value;
            }
        } else {
            const row = this.template.querySelector(`div[data-key="${accessKey}"]`);

            let firstName = row.querySelector('lightning-input-field[data-name="firstName"]').value;
            let lastName = row.querySelector('lightning-input-field[data-name="lastName"]').value;
            this.contactList[accessKey - 1].Name = firstName + ' ' + lastName;

            const fields = row.querySelectorAll("lightning-input-field");
            fields.forEach(field => {
                this.contactList[accessKey - 1][field.fieldName] = field.value;
            });
        }
    }

    /* Save Button */
    handleSaveNewContact() {
        let isVal = true;
        this.errorMessage = '';
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if (!element.value && element.required) {
                isVal = false;
                element.reportValidity();
            }
        });

        if (this.isNotReplace) {

            if (isVal) {
                this.isShowSpinner = true;

                const forms = this.template.querySelectorAll('lightning-record-edit-form');

                let contactWrapper = [];
                this.contactList.forEach((form, index) => {
                    contactWrapper.push({
                        index: index + 1,
                        firstName: form.FirstName,
                        lastName: form.LastName,
                        accountId: this.recordId,
                        email: form.Email,
                        title: form.Title,
                        advocacyLevel: form.Advocacy_Level__c,
                        jobFunction: form.Job_Function__c,
                        phone: form.Phone,
                        persona: form.Contact_Persona__c,
                        areaOfInterest: form.Area_of_Interest__c
                    });
                });
                createContactRecords({
                    contactList: contactWrapper,
                    accountId: this.recordId,
                    hierarchyInformationId: this.hierarchyInformationId,
                    parentNodeId: this.contact.Id,
                    allNodes: this.allContactsList
                })
                    .then(data => {
                        this.toast('SUCCESS', 'Contact added successfully!', 'success', 'dismissible');
                    })
                    .catch(error => {
                        console.log('error: ', error);
                        if (error.body && error.body.message) {
                            let errorMessage = error.body.message;
                            this.toast('Error', errorMessage, 'error', 'dismissible');
                        } else {
                            this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                        }
                    })
                    .finally(() => {
                        this.isShowSpinner = false;
                        this.refreshPage();
                        this.showNewContactModal = false;
                    })
            } else {

            }
        } else {
            if (isVal) {
                this.isShowSpinner = true;
                let temp = JSON.parse(JSON.stringify(this.contactList));
                let contactToCreate = {};
                temp.forEach(element => {
                    contactToCreate.FirstName = element.FirstName;
                    contactToCreate.LastName = element.LastName;
                    contactToCreate.Email = element.Email;
                    contactToCreate.Phone = element.Phone;
                    contactToCreate.AccountId = element.AccountId;
                    contactToCreate.Title = element.Title;
                    contactToCreate.Advocacy_Level__c = element.Advocacy_Level__c;
                    contactToCreate.Job_Function__c = element.Job_Function__c;
                    contactToCreate.Contact_Persona__c = element.Contact_Persona__c;
                    contactToCreate.Area_of_Interest__c = element.Area_of_Interest__c;
                });
                let replacedId = 'newIdToReplace';
                let currentNodeId = this.contact.Id;
                let finalNodeList = JSON.parse(JSON.stringify(this.allContactsList));
                finalNodeList.forEach(element => {
                    if (element.Id == currentNodeId) {
                        element.Id = replacedId;
                    }
                    if (element.ReportsTo == currentNodeId) {
                        element.ReportsTo = replacedId;
                    }
                    element.Children = [];
                });
                updateRelationshipMapOnReplace({
                    hierarchyList: finalNodeList,
                    hierarchyInformationId: this.hierarchyInformationId,
                    replacedId: replacedId,
                    contactToReplace: contactToCreate,
                    contactsToUpdate: [],
                    contactToDelete: currentNodeId,
                })
                    .then((result) => {
                        const event = new ShowToastEvent({
                            title: 'Success !',
                            variant: 'success'
                        });
                        this.dispatchEvent(event);

                        this.isShowSpinner = false;
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
                        this.isShowSpinner = false;
                    });
            } else {

            }
        }
    }

    closeEditOnBlur() {
        this.template.querySelectorAll("c-multi-select-combobox-hierarchy").forEach(element => {
            element.close();
        });
    }

    // Add New Row
    addRow() {
        ++this.keyIndex;
        // Added Advocacy Level below to resolve Advocacy Level Reset Issue
        var newItem = [{ index: this.keyIndex, Advocacy_Level__c: 'None' }];
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

    refreshPage() {
        const refreshEvent = new CustomEvent("refreshhierarchy", {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(refreshEvent);
    }

    handleUpdateAdvocacyLevelOnContact(event) {
        this.isShowSpinner = true;
        var advocacyLevel = event.detail.selectedValue;
        let currentNodeId = this.contact.Id;
        let finalNodeList = JSON.parse(JSON.stringify(this.allContactsList));
        finalNodeList.forEach(element => {
            if (element.Id == currentNodeId) {
                element.AdvocacyLevel = advocacyLevel;// To add Advocacy Level
            }
            element.Children = [];
        });

        updateAdvocacyLevelOnContact({
            advocacyLevel: advocacyLevel,
            hierarchyList: finalNodeList,
            hierarchyInformationId: this.hierarchyInformationId,
            contactId: this.contact.Id
        })
            .then(data => {
                this.toast('SUCCESS', 'Contact updated successfully!', 'success', 'dismissible');
            })
            .catch(error => {
                console.log('error: ', error);
                if (error.body && error.body.message) {
                    let errorMessage = error.body.message;
                    this.toast('Error', errorMessage, 'error', 'dismissible');
                } else {
                    this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                }
            })
            .finally(() => {
                this.isShowSpinner = false;
                this.refreshPage();
            })
    }

    handleCloseChooseContactModal() {
        this.showChooseContactModal = false;
        this.isNotPlaceholderConversion = true;
        this.isNotReplace = true;
    }

    handleBackChooseContact() {
        this.showChooseContactModal = false;
        this.isAddSelectionPopup = true;
        //this.isNotPlaceholderConversion = true;
    }

    convertPlaceholderToContact() {
        if (this.isNotSelectionMode) {
            this.isNotReplace = false;
            this.isNotPlaceholderConversion = false;
            this.handleContactChoose();
        }
    }

    handleCloseReparentPopup() {
        this.isOpenReparentPopup = false;
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
            this.isNotReplace = false;
            this.handleOpenAddPopup('replace');
            //this.handleContactChoose(true);
        } else if (action == 'Delete') {
            this.isDelete = true;
            this.isOpenPopup = true;
            this.popupTitle = 'Delete Node';
        } else if (action == 'Edit') {
            this.isPlaceholderEdit = true;
            this.isOpenPopup = true;
            this.popupTitle = 'Edit Placeholder';
        } else if (action == 'Make Economic Buyer') {
            this.handleEconomicBuyerOrIOPsychologistStatus('Add', 'Economic Buyer');
        } else if (action == 'Remove as Economic Buyer') {
            this.handleEconomicBuyerOrIOPsychologistStatus('Remove', 'Economic Buyer');
        } else if (action == 'Make IO Psychologist') {
            this.handleEconomicBuyerOrIOPsychologistStatus('Add', 'IO Psychologist');
        } else if (action == 'Remove as IO Psychologist') {
            this.handleEconomicBuyerOrIOPsychologistStatus('Remove', 'IO Psychologist');
        } else if (action == 'Draw Influence Line') {
            this.dispatchEvent(new CustomEvent('influencemode', {
                bubbles: true,
                composed: true
            }));
            this.hasSourceSelected = true;
            this.handleSourceNode(true);
        } else if (action == 'Draw Conflict Line') {
            this.dispatchEvent(new CustomEvent('conflictmode', {
                bubbles: true,
                composed: true
            }));
            this.hasSourceSelected = true;
            this.handleSourceNode(false);
        }
    }

    handlePlaceholderNameChange(event) {
        this.updatedName = event.target.value;
        this.isSaveDisabled = (this.updatedName.trim() != this.contact.Name && this.updatedName.trim() != '') ? false : true;
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
                    message: 'Placeholder Updated Successfully!',
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

    handleDeleteNode() {
        this.isShowSpinner = true;
        let finalNodeList = JSON.parse(JSON.stringify(this.contacts));
        let updatedReportsToId;
        let pos = finalNodeList.map(e => e.Id).indexOf(this.contact.Id);
        updatedReportsToId = finalNodeList[pos].ReportsTo;
        finalNodeList.forEach(element => {
            if (element.ReportsTo == this.contact.Id) {
                element.ReportsTo = updatedReportsToId;
            }
            element.Children = [];
        });

        finalNodeList = finalNodeList.filter(element => element.Id != this.contact.Id);

        updateHierarchyOnDelete({ hierarchyList: finalNodeList, hierarchyInformationId: this.hierarchyInformationId, contactToDelete: this.contact.Id })
            .then((result) => {
                this.toast('Deleted Successfully !', '', 'success', 'dismissible');
                this.handleRefreshHierarchy();
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

    handleChooseExistingPlaceholder() {
        this.showPlaceholderOptions = false;
        this.isOpenAddPlaceholder = true;
        this.actionType = 'replace';
    }

    handleCreateNewPlaceholder() {
        this.showPlaceholderOptions = false;
        this.isOpenAddPlaceholder = true;
        this.actionType = 'create';
    }

    handleBackPlaceholderOptions() {
        this.showPlaceholderOptions = false;
        this.isAddSelectionPopup = true;
    }

    handleClosePlaceholderOptions() {
        this.showPlaceholderOptions = false;
        this.isAddSelectionPopup = false;
        this.isNotReplace = true;
    }

    handleEconomicBuyerOrIOPsychologistStatus(addOrRemove, role) {
        updateEconomicBuyerOrIOPsychologistStatus({
            contactId: this.contact.Id,
            accountId: this.recordId,
            type: addOrRemove,
            role: role
        })
            .then((result) => {
                this.toast('Success !', '', 'success', 'dismissible');
                this.handleRefreshHierarchy();
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

    handleOpenContactViewCard() {
        if (this.isNotSelectionMode) {
            const openEvent = new CustomEvent('viewcontact', {
                bubbles: true,
                composed: true,
                detail: {
                    contact: this.contact,
                    tab: 'Contact Details'
                }
            });
            this.dispatchEvent(openEvent);
        }
    }

    handleOpenAddNoteInViewCard() {
        if (this.isNotSelectionMode) {
            const openEvent = new CustomEvent('viewcontact', {
                bubbles: true,
                composed: true,
                detail: {
                    contact: this.contact,
                    tab: 'Notes'
                }
            });
            this.dispatchEvent(openEvent);
        }
    }

    handleDragStart(event) {
        if (this.isRootLevel) {
            event.preventDefault();
            event.stopPropagation(); // Stop the event from propagating further
        } else {
            this.hasDragStartFrom = true;
            if (this.contact.IsPlaceholder) {
                const placeholderCard = this.template.querySelector('.placeholder-card');
                placeholderCard.classList.add('addDragClass');
            }
            if (!this.contact.IsPlaceholder) {
                this.contactCardClass += ' addDragClass';
            }
            event.dataTransfer.setData('text/plain', this.contact.Id);
        }
    }

    handleDragEnd(event) {
        if (this.contact.IsPlaceholder) {
            const placeholderCard = this.template.querySelector('.placeholder-card');
            placeholderCard.classList.remove('addDragClass');
        }
        if (this.contactCardClass.includes('addDragClass')) {
            this.contactCardClass = this.contactCardClass
                .split(' ')
                .filter(cls => cls !== 'addDragClass')
                .join(' ');
        }
    }

    handleDragOver(event) {
        /*if (this.isRootLevel) {
            event.preventDefault(); // Prevent default drag behavior
            event.stopPropagation(); // Stop the event from propagating further
            return;
        }*/
        event.preventDefault(); // Necessary to allow drop
        if (!this.hasDragStartFrom && !this.contact.IsPlaceholder && !this.contactCardClass.includes('enlargeCard')) {
            this.contactCardClass += ' enlargeCard addBorder';
        }
        if (!this.hasDragStartFrom && this.contact.IsPlaceholder) {
            const placeholderCard = this.template.querySelector('.placeholder-card');
            placeholderCard.classList.add('enlargeCard', 'addBorder');
        }
        if (this.isRootLevel) {
            const rootCard = this.template.querySelector('.aLinkForOpportunityCard');
            rootCard.classList.add('enlargeCard', 'addBorder');
        }
    }

    handleDragLeave(event) {
        event.preventDefault();
        if (this.contactCardClass.includes('enlargeCard')) {
            this.contactCardClass = this.contactCardClass
                .split(' ')
                .filter(cls => cls !== 'enlargeCard')
                .join(' ');
        }
        if (this.contactCardClass.includes('addBorder')) {
            this.contactCardClass = this.contactCardClass
                .split(' ')
                .filter(cls => cls !== 'addBorder')
                .join(' ');
        }
        if (!this.hasDragStartFrom && this.contact.IsPlaceholder) {
            const placeholderCard = this.template.querySelector('.placeholder-card');
            placeholderCard.classList.remove('enlargeCard', 'addBorder');
        }
        if (this.isRootLevel) {
            const rootCard = this.template.querySelector('.aLinkForOpportunityCard');
            rootCard.classList.remove('enlargeCard', 'addBorder');
        }
    }

    handleDrop(event) {
        event.preventDefault();
        const draggedContactId = event.dataTransfer.getData('text/plain');

        if (draggedContactId !== this.contact.Id) {
            this.handleReparent(draggedContactId);
            this.dispatchEvent(new CustomEvent('reparent', {
                detail: {
                    newParentId: this.contact.Id,
                    draggedContactId: draggedContactId
                }
            }));
        } else {
            if (this.contactCardClass.includes('enlargeCard')) {
                this.contactCardClass = this.contactCardClass
                    .split(' ')
                    .filter(cls => cls !== 'enlargeCard')
                    .join(' ');
            }
            if (!this.hasDragStartFrom && this.contact.IsPlaceholder) {
                const placeholderCard = this.template.querySelector('.placeholder-card');
                placeholderCard.classList.remove('enlargeCard', 'addBorder');
            }
        }
        // Reset hasDragStartFrom after drop
        this.hasDragStartFrom = false;
    }

    findNodeById(nodes, targetId) {
        for (let node of nodes) {
            if (node.Id === targetId) {
                return node;
            }
            if (node.Children && node.Children.length > 0) {
                let foundNode = this.findNodeById(node.Children, targetId);
                if (foundNode) {
                    return foundNode;
                }
            }
        }
        return null;
    }

    handleReparent(draggedContactId) {
        this.showSpinner = true;
        let finalNodeList = JSON.parse(JSON.stringify(this.contacts));

        let contactToBeReparented = this.findNodeById(finalNodeList, draggedContactId);

        if (contactToBeReparented?.Children && JSON.stringify(contactToBeReparented?.Children).includes(this.contact.Id)) {
            finalNodeList.forEach(element => {
                if (element.Id == this.contact.Id) {
                    element.ReportsTo = contactToBeReparented.ReportsTo;
                }
            });
        }
        finalNodeList.forEach(element => {
            if (element.Id == draggedContactId) {
                element.ReportsTo = this.contact.Id;
            }
            element.Children = [];
        });

        updateHierarchyOnReparent({ hierarchyList: finalNodeList, hierarchyInformationId: this.hierarchyInformationId })
            .then((result) => {
                //this.toast('Success!', '', 'success', 'dismissible');

                this.dispatchEvent(new CustomEvent('refreshhierarchy', {
                    bubbles: true,
                    composed: true,
                    detail: this.zoomLevel
                }));
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
                console.log('finally then updateHierarchyOnReparent: ');
                this.showSpinner = false;
            });
    }

    handleTargetAction(event) {
        const fireEvent = new CustomEvent('selectnode', {
            detail: { id: this.contact.Id, name: this.contact.Name, node: event.currentTarget },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(fireEvent);
    }

    sendNodePosition(nodeType, actionType, type) {
        const rect = this.template.querySelector(`div.line-point[data-id="${this.contact.Id}"]`).getBoundingClientRect();

        publish(this.messageContext, COMMUNICATION_CHANNEL, {
            action: 'sendNodePosition',
            nodeId: this.contact.Id,
            node: rect,
            nodeType: nodeType,
            actionType: actionType,
            type: type
        });
    }

    getUpdatedPosition({ action, sourceNode, targetNode }) {
        if (action === 'sendNodePositionFromParent') {
            if (sourceNode) {
                this.getInfluenceIconCoordinates(sourceNode);
            }
            if (targetNode) {
                this.getInfluenceIconCoordinates(targetNode);
            }
        }
    }

    getInfluenceIconCoordinates(contactId) {
        // Find the icon element using the contact ID
        const iconElement = this.template.querySelector(`lightning-icon[data-id="${contactId}"]`);

        if (iconElement) {
            const rect = iconElement.getBoundingClientRect();
            const fireEvent = new CustomEvent('selectnode', {
                detail: { id: this.contact.Id, name: this.contact.Name, node: iconElement },
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(fireEvent);
        }
    }

    handleSourceNode(isInfluenceSelectionMode) {
        publish(this.messageContext, COMMUNICATION_CHANNEL, {
            action: 'selectionMode',
            nodeId: this.contact.Id,
            nodeType: 'Source',
            eventHandler: this.eventHandler,
            isInfluenceSelectionMode: isInfluenceSelectionMode
        });
    }

    handleTargetNode(event) {
        this.hasSourceSelected = null;
        const targetId = event.currentTarget.dataset.id;
        publish(this.messageContext, COMMUNICATION_CHANNEL, {
            action: 'selectionMode',
            nodeId: targetId,
            nodeType: 'Target',
            eventHandler: this.eventHandler
        });
        this.sendNodePosition('Target', 'new');
    }

    handleNodeSelection(event) {
        if (this.hasSourceSelected && this.contact.Id !== this.sourceNodeId) {
            this.dispatchEvent(new CustomEvent('newconnection', {
                detail: {
                    targetId: this.contact.Id,
                    sourceId: this.sourceNodeId,
                    isInfluenceSelectionMode: this.isInfluenceSelectionMode
                },
                bubbles: true,
                composed: true
            }));
        }
    }

    requestRemoveSelectionMode() {
        publish(this.messageContext, COMMUNICATION_CHANNEL, { action: 'removeSelectionMode' });
    }

}