import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getActiveContacts from '@salesforce/apex/ACR_RelationshipMapController.getActiveContacts';
import updateHierarchyOnExistingContactSelection from '@salesforce/apex/ACR_RelationshipMapController.updateHierarchyOnExistingContactSelection';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import BUYING_CENTRE_ID_FIELD from '@salesforce/schema/Account.Buying_Centre_Id__c';
import PERSONA_FIELD from '@salesforce/schema/Contact.Contact_Persona__c';
import updateRelationshipMapOnReplace from '@salesforce/apex/ACR_RelationshipMapController.updateRelationshipMapOnReplace';

export default class Acr_addExistingContactInRelationships extends LightningElement {

    @api contactHierarchyId;
    @api allNodes;
    @api parentNode;
    @api modalresize;
    @api isNotReplace;
    @api accountId;

    @track listOfContacts;
    @track contactRoleOptions;
    @track createdRecordIds;
    @track loadMoreStatus;
    @track data = [];
    @track selectedRows = [];
    @track selectedRowsIds = [];
    @track selectedOptions = [];
    @track existingContactList = [];
    @track listOfContactIdAlreadyInHierarchy = [];
    @track contactList = [
        {
            index: 1,
        }
    ];

    objectApiName = 'Contact';
    oppId;
    dataCount;
    tableElement;
    contactFilterValue;
    updatedSelectedRoles;
    selectedRowForReplace;
    errorToDisplay;
    buyingCentreId;
    personaOptions;
    isShowSpinner = false;
    showChooseExistingContactModal = false;
    disableNextChooseExisting = false;
    isLoading = false;
    contactExistsInHierarchy = false;
    showTable = false;
    showNextScreen = false;
    disableSaveChooseExisting = false;

    // List of table columns
    columns = [
        {
            label: 'Name', fieldName: 'contactRecordId', type: 'url', hideDefaultActions: true, fixedWidth: 190, wrapText: true,
            typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
        },
        {
            label: 'Account Name', fieldName: 'accountRecordId', type: 'url', hideDefaultActions: true, wrapText: true, fixedWidth: 190,
            typeAttributes: { label: { fieldName: 'accountName' }, target: '_blank' }
        },
        {
            label: 'Created Date', fieldName: 'CreatedDate', type: 'date', wrapText: true, hideDefaultActions: true, fixedWidth: 150,
            typeAttributes: { day: "2-digit", month: "2-digit", year: "numeric" }
        },
        { label: 'Persona', fieldName: 'Contact_Persona__c', wrapText: true, hideDefaultActions: true, fixedWidth: 150, },
        { label: 'Title', fieldName: 'Title', wrapText: true, hideDefaultActions: true, fixedWidth: 120, },
        {
            label: 'Reports To', fieldName: 'reportsToRecordId', type: 'url', hideDefaultActions: true, wrapText: true,
            typeAttributes: { label: { fieldName: 'ReportsToName' }, linkUrl: { fieldName: 'reportsToRecordId' }, target: '_blank' }
        },
    ]

    /* Get picklist values from Contact Persona field on Contact */
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: PERSONA_FIELD })
    wiredPersonaValues({ error, data }) {
        // reset values to handle eg data provisioned then error provisioned
        this.personaOptions = [];
        if (data) {
            this.personaOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
            console.log('this.personaOptions: ', JSON.stringify(this.personaOptions));
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getRecord, {
        recordId: '$accountId', fields: [BUYING_CENTRE_ID_FIELD]
    })
    accountRecord({ error, data }) {
        if (error) {
            console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            console.log('data: ', data);
            this.buyingCentreId = getFieldValue(data, BUYING_CENTRE_ID_FIELD);
            console.log('this.buyingCentreId: ', this.buyingCentreId);
        }
    }

    /* This public function is used to open Add Contacts modal pop up 
     *and to call getContactData to get first set of contact data
     */
    @api handleChooseExistingContact() {
        //this.showChooseContactModal = false;
        this.showChooseExistingContactModal = true;
        this.disableNextChooseExisting = true;
        this.isShowSpinner = true;
        this.data = '';
        this.selectedRows = '';
        this.getContactData();
    }

    /* This function is called on click of Next button on Add Existing Contact screen. 
     * If no selection is made on the screen then Next button should be non-clickable
     */
    handleNextOnAddContactModal() {
        this.showNextScreen = true;
        this.disableSaveChooseExisting = true;
        let indexVal = 1;
        if (this.isNotReplace) {
            this.selectedRows.forEach(row => {
                row.index = indexVal++;
                if (row.Contact_Persona__c != null) {
                    row.Persona = row.Contact_Persona__c;
                }
            });
        } else {
            let selectedRowsList = [];
            selectedRowsList.push(this.selectedRowForReplace);
            this.selectedRows = [...selectedRowsList];// JSON.parse(JSON.stringify(this.selectedRowForReplace));
            this.selectedRows.forEach(row => {
                row.index = indexVal++;
                if (row.Contact_Persona__c != null) {
                    row.Persona = row.Contact_Persona__c;
                }
            });
        }
        console.log('this.selectedRows: ', JSON.stringify(this.selectedRows));
        this.disableSaveChooseExisting = this.selectedRows.some((contact) => !contact.Persona);
    }

    /* This function is called on click of Save button.
     * To Add selected contacts in the Relationship Map.
     * And in case of replace contact will get replaced with the newly selected contact.
     * If no role has been selected for all the selected contacts on the add contact role screen
     * then Save button should be non-clickable
     */
    handleSaveAddContact() {
        debugger;
        this.isShowSpinner = true;
        if (this.isNotReplace) {
            let contactIdsListFromHierarchy = this.getContactIdsListFromHierarchy();
            this.selectedRows.forEach(item => {
                if (!contactIdsListFromHierarchy.includes(item.Id.toString())) {
                    this.existingContactList.push(item);
                }
            });
            let temp = JSON.parse(JSON.stringify(this.existingContactList));
            temp.forEach(element => {
                element.ReportsTo = this.parentNode.Id;
                element.IsPlaceholder = false;
                //element.JobRole: ;
                delete element.ReportsToName;
                delete element.reportsToRecordId;
                delete element.contactRecordId;
            });

            let tempAllNodes = JSON.parse(JSON.stringify(this.allNodes));
            tempAllNodes.forEach(element => {
                element.Children = [];
            });
            let finalNodeList = tempAllNodes.concat(temp);
            finalNodeList.forEach(element => {
                if (this.selectedRowsIds.includes(element.Id)) {
                    element.ReportsTo = this.parentNode.Id;
                }
                element.Children = [];
            });

            let contactWrapper = [];
            this.existingContactList.forEach((form, index) => {
                contactWrapper.push({
                    id: form.Id,
                    persona: form.Persona
                });
            });

            updateHierarchyOnExistingContactSelection({
                contactList: contactWrapper,
                accountId: this.accountId,
                hierarchyInformationId: this.contactHierarchyId,
                parentNodeId: this.parentNode.Id,
                allNodes: finalNodeList
            })
                .then(data => {
                    this.toasteventForParent('SUCCESS', 'Contact added successfully!', 'success', 'dismissible');
                })
                .catch(error => {
                    console.log('error: ', error);
                    if (error?.body && error?.body?.message) {
                        this.toasteventForParent('Error', error.body.message, 'error', 'dismissible');
                    } else {
                        this.toasteventForParent('Error', 'Something went wrong', 'error', 'dismissible');
                    }
                })
                .finally(() => {
                    this.isShowSpinner = false;
                    this.refreshPage();
                })

        } else {
            let replacedId = this.selectedRowForReplace.Id;
            let personaToUse = this.selectedRowForReplace.Persona;
            let currentNodeId = this.parentNode.Id;
            let finalNodeList = JSON.parse(JSON.stringify(this.allNodes));
            let contactsToUpdate = [];
            let replacedNode = finalNodeList.filter(element => element.Id == replacedId);

            if (replacedNode.length > 0 && JSON.stringify(replacedNode[0].Children).includes(currentNodeId)) {
                finalNodeList.forEach(element => {
                    if (element.ReportsTo == replacedNode[0].Id) {
                        if (!(replacedNode[0].ReportsTo).includes('Placeholder') && !(element.Id).includes('Placeholder')) {
                            let newContact = {
                                Id: element.Id,
                                Contact_Persona__c: personaToUse
                            };
                            contactsToUpdate.push(newContact);
                        }
                        element.ReportsTo = replacedNode[0].ReportsTo;
                    }
                });
            }

            finalNodeList = finalNodeList.filter(element => element.Id != replacedId);
            finalNodeList.forEach(element => {
                if (element.Id == currentNodeId) {
                    //Commented below line to resolve issue of persona in case of Placeholder conversion (SSE-27585)
                    //if (!(element.ReportsTo).includes('Placeholder')) {
                    let newContact = {
                        Id: replacedId,
                        Contact_Persona__c: personaToUse
                    };
                    contactsToUpdate.push(newContact);
                    //}
                    element.Id = replacedId;
                    element.Persona = personaToUse;
                    element.IsPlaceholder = false;
                    element.Name = this.selectedRowForReplace.Name;
                }
                // Child of Current Node
                if (element.ReportsTo == currentNodeId) {
                    if (element.IsPlaceholder == false) {
                        let con = {
                            Id: element.Id,
                            Contact_Persona__c: element.Persona
                        }
                        contactsToUpdate.push(con);
                    }
                    element.ReportsTo = replacedId;
                }
                element.Children = [];
            });

            updateRelationshipMapOnReplace({
                hierarchyList: finalNodeList,
                hierarchyInformationId: this.contactHierarchyId,
                replacedId: replacedId,
                contactToReplace: null,
                contactsToUpdate: contactsToUpdate,
                contactToDelete: currentNodeId
            })
                .then((result) => {
                    this.toasteventForParent('SUCCESS', 'Contact added successfully!', 'success', 'dismissible');

                    const refreshEvent = new CustomEvent("refreshhierarchy");
                    this.dispatchEvent(refreshEvent);
                })
                .catch((error) => {
                    console.log('error: ', JSON.stringify(error));
                    if (error?.body && error?.body?.message) {
                        this.toasteventForParent('Error', error.body.message, 'error', 'dismissible');
                    } else {
                        this.toasteventForParent('Error', 'Something went wrong', 'error', 'dismissible');
                    }
                })
                .finally(() => {
                    this.isShowSpinner = false;
                });
        }

    }

    /* This function is used to get first 100 contact records. Also, it will sort the contacts 
     * linked to the current account then display those on top and rest will be arranged alphabetically.
     */
    getContactData() {

        let contactIdsListFromHierarchy = this.getContactIdsListFromHierarchy();
        let currentId = this.parentNode.Id.startsWith('003') ? this.parentNode.Id : null;
        console.log('currentId: ', currentId);
        let contantIdToPass = this.isNotReplace ? contactIdsListFromHierarchy : currentId;
        console.log('this.accountId: ', this.accountId);
        console.log('this.contactFilterValue: ', this.contactFilterValue);
        console.log('this.buyingCentreId: ', this.buyingCentreId);
        console.log('this.isNotReplace: ', this.isNotReplace);
        console.log('contantIdToPass: ', contantIdToPass);


        getActiveContacts({ offSetValue: 0, filterValue: this.contactFilterValue, currentContactIdsInHierarchy: contantIdToPass, accountId: this.accountId, isNotReplace: this.isNotReplace, buyingCentreId: this.buyingCentreId })
            .then(result => {
                this.isShowSpinner = false;
                console.log('result ====> ' + JSON.stringify(result));
                let tempRecords = JSON.parse(JSON.stringify(result.contacts));

                tempRecords = tempRecords.map((row) => {
                    let indexCounter = (row.AccountId == this.accountId) ? 0 : 1;
                    return {
                        ...row,
                        contactRecordId: (row ? ('/lightning/r/Contact/' + row.Id + '/view') : null),
                        reportsToRecordId: (row.ReportsTo ? ('/lightning/r/Contact/' + row.ReportsToId + '/view') : null),
                        ReportsToName: (row.ReportsTo ? row.ReportsTo.Name : null),
                        accountName: (row.Account ? row.Account.Name : null),
                        accountRecordId: (row.Account ? ('/lightning/r/Account/' + row.AccountId + '/view') : null),
                        indexCounter: indexCounter
                    };
                });

                tempRecords.sort((a, b) => a.indexCounter - b.indexCounter);

                this.data = tempRecords;
                if (tempRecords.length == 0) {
                    this.showTable = false;
                    if (result.message == 'Contact already present in hierarchy!') {
                        this.contactExistsInHierarchy = true;
                        this.errorToDisplay = result.message;
                    } else if (result.message == 'Contact does not exist or is not accessible.') {
                        this.data = [];
                        this.contactExistsInHierarchy = true;
                        this.errorToDisplay = result.message;
                    } else {
                        this.data = [];
                        this.contactExistsInHierarchy = false;
                    }
                } else {
                    this.showTable = true;
                    this.contactExistsInHierarchy = false;
                }
                this.dataCount = this.data.length;

                this.loadMoreStatus = '';
                this.dataCount = this.data.length;
                if (this.tableElement) {
                    //this.tableElement.isLoading = false;
                    this.tableElement.enableInfiniteLoading = true;
                }
            })
            .catch(error => {
                console.log('1 error 123 ====> ', JSON.stringify(error));
            })
            .finally(() => {
                if (this.tableElement) {
                    this.tableElement.isLoading = false;
                }
            });
    }

    /* This function is used to get next set of contact records upto 100 and will sort them alphabetically. */
    getMoreContactData() {
        console.log('getMoreContactData: ');
        this.tableElement.isLoading = true;
        let contactIdsListFromHierarchy = this.getContactIdsListFromHierarchy();
        let currentId = this.parentNode.Id.startsWith('003') ? this.parentNode.Id : null;
        let contantIdToPass = this.isNotReplace ? contactIdsListFromHierarchy : currentId;
        getActiveContacts({ offSetValue: this.dataCount, filterValue: this.contactFilterValue, currentContactIdsInHierarchy: contantIdToPass, accountId: this.accountId, isNotReplace: this.isNotReplace, buyingCentreId: this.buyingCentreId })
            .then(result => {
                let tempRecords = JSON.parse(JSON.stringify(result.contacts));
                tempRecords = tempRecords.map((row) => {
                    let indexCounter = (row.AccountId == this.accountId) ? 0 : 1;
                    return {
                        ...row,
                        contactRecordId: (row ? ('/lightning/r/Contact/' + row.Id + '/view') : null),
                        reportsToRecordId: (row.ReportsTo ? ('/lightning/r/Contact/' + row.ReportsToId + '/view') : null),
                        ReportsToName: (row.ReportsTo ? row.ReportsTo.Name : null),
                        accountName: (row.Account ? row.Account.Name : null),
                        accountRecordId: (row.Account ? ('/lightning/r/Account/' + row.AccountId + '/view') : null),
                        indexCounter: indexCounter
                    };
                });

                tempRecords.sort((a, b) => a.indexCounter - b.indexCounter);

                this.data = [...this.data, ...tempRecords];
                this.dataCount = this.data.length;
                console.log('this.dataCount: ', this.dataCount);
                this.loadMoreStatus = '';
                /*if (this.tableElement) {
                    this.tableElement.isLoading = false;
                }*/
                if (tempRecords.length < 10) {
                    this.tableElement.enableInfiniteLoading = false;
                    this.loadMoreStatus = 'No more data to load';
                }
            })
            .catch(error => {
                console.log('2 error ====> ', error);
            })
            .finally(() => {
                if (this.tableElement) {
                    this.tableElement.isLoading = false;
                }
            });
    }

    // Back Button
    handleBackAddContactModal() {
        if (this.showNextScreen) {
            this.showNextScreen = false;
        } else {
            this.showChooseExistingContactModal = false;
            this.showChooseContactModal = true;
            const submitEvent = new CustomEvent('backfromexistingcontactscreen');
            this.dispatchEvent(submitEvent);
        }
    }

    // Cancel Button
    handleCancelOnAddExistingContactModal() {
        this.showChooseExistingContactModal = false;
        const submitEvent = new CustomEvent('closefromcontactpopup');
        this.dispatchEvent(submitEvent);
    }

    // Captures user input in search box
    handleSearchContact(event) {
        this.contactFilterValue = event.detail.value;
    }

    // Search button
    handleSearchAction() {
        this.getContactData();
    }

    // This function is used to load more data on scroll, part of infinite loading on table.
    loadData(event) {
        event.preventDefault();
        console.log('Inside Load More Data');

        if (event.target.isLoading) {
            return; // Prevent multiple simultaneous calls
        }
        console.log('this.dataCount in load more : ', this.dataCount);
        if (this.dataCount >= 10) {
            if (event.target) {
                event.target.isLoading = true;
            }
            this.tableElement = event.target;
            this.loadMoreStatus = 'Loading';
            console.log('Call getMoreContactData');
            this.getMoreContactData();
        } else {
            this.loadMoreStatus = 'No more data to load';
        }
    }

    // This function is used to get list of Ids of the contacts present in the Account Relationship Map.
    getContactIdsListFromHierarchy() {
        let data = JSON.parse(JSON.stringify(this.allNodes));
        const ids = new Set(); // Using Set to avoid duplicate IDs
        const extract = (items) => {
            items.forEach(item => {
                if (item.Id && item.Id.startsWith('003')) ids.add(item.Id);
                if (item.Children && item.Children.length > 0) {
                    extract(item.Children);
                }
            });
        };
        extract(data);
        return Array.from(ids);
    }

    //This is the function used for handling the row selection to add contacts in the Relationship Map
    handleRowSelection(event) {
        let selectedItemsSet = event.detail.selectedRows.map((row) => {
            return row.Id
        });
        this.selectedRowsIds = [...selectedItemsSet];
        this.selectedRows = [...event.detail.selectedRows];



        this.selectedRows.forEach((row, index) => {
            if (row.Contact_Persona__c != null) {
                row.Persona = row.Contact_Persona__c;
            }
        });

        console.log('this.selectedRows[accessKey]?.Contact_Persona__c: ', (JSON.stringify(this.selectedRows)));
        if (this.selectedRows.length > 0) {
            this.disableNextChooseExisting = false;
        }
        else {
            this.disableNextChooseExisting = true;
        }
    }

    //This is the function used for handling the row selection to replace contact or convert a placeholder as a contact in the Relationship Map
    handleRowSelectionForReplace(event) {
        this.selectedRowForReplace = event.detail.selectedRows[0];
        this.disableNextChooseExisting = false;
    }

    // This function is used to close the contact role dropdown if any opens.
    handleCloseEditOnBlur() {
        this.template.querySelectorAll("c-multi-select-combobox-hierarchy").forEach(element => {
            element.close();
        });
    }

    //This function is used to capture the user selected values from the persona dropdown 
    handlePersonaOnNextScreen(event) {
        this.selectedOptions = event.detail;
        let accessKey = event.target.accessKey;
        if (this.selectedOptions) {
            this.selectedRows[accessKey].Persona = this.selectedOptions.label;
        }
        this.disableSaveChooseExisting = this.selectedRows.some((contact) => !contact.Persona);
    }

    // Refresh Hierarchy after adding contact(s)
    refreshPage() {
        const submitEvent = new CustomEvent('refreshhierarchy',
            {
                bubbles: true,
                composed: true
            });
        this.dispatchEvent(submitEvent);
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
}