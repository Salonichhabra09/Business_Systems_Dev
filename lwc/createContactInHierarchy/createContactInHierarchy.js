import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from "lightning/uiRecordApi";
import ROLE_FIELD from '@salesforce/schema/OpportunityContactRole.Role';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityDetails from '@salesforce/apex/OpportunityContactHierarchy.getOpportunityDetails';
import createContactRoleRecords from '@salesforce/apex/OpportunityContactHierarchy.createContactRoleRecords';
import getActiveContacts from '@salesforce/apex/OpportunityContactHierarchy.getActiveContacts';
import updateHierarchyOnPlaceholderCreation from '@salesforce/apex/OpportunityContactHierarchy.updateHierarchyOnPlaceholderCreation';
import createContactRecords from '@salesforce/apex/OpportunityContactHierarchy.createContactRecords';
import updateHierarchyOnReplace from '@salesforce/apex/OpportunityContactHierarchy.updateHierarchyOnReplace';
import updateHierarchyOnExistingContactSelection from '@salesforce/apex/OpportunityContactHierarchy.updateHierarchyOnExistingContactSelection';

export default class CreateContactInHierarchy extends LightningElement {

    @api contactHierarchyId;
    @api modalresize;
    showNewContactModal = false;
    showChooseContactModal = true;
    showChooseExistingContactModal = false;
    keyIndex = 1;
    @track listOfContacts;
    objectApiName = 'Contact';
    accountId;
    oppId;
    @api allNodes;
    @api parentNode;
    @track contactRoleOptions;
    @track createdRecordIds;
    newChildList;
    showSpinner = false;
    errorMessage = '';

    @track loadMoreStatus;
    @track data = [];
    dataCount;
    tableElement;
    contactFilterValue;
    @track selectedRows = [];
    disableNextChooseExisting = false;
    isLoading = false;
    @track existingContactList = [];
    contactExistsInHierarchy = false;
    showTable = false;
    @track listOfContactIdAlreadyInHierarchy = [];
    @track selectedRowsIds = [];

    isEdit = true;
    @track selectedOptions = [];
    updatedSelectedRoles;
    @api isNotReplace;
    selectedRowForReplace;
    showNextScreen = false;
    disableSaveChooseExisting = false;
    errorToDisplay;

    @track contactList = [
        {
            index: 1,
            isEdit: true,
        }
    ];
    value1;
    columns = [
        {
            label: 'Name', fieldName: 'contactRecordId', type: 'url', hideDefaultActions: true, fixedWidth: 180, wrapText: true,
            typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
        },
        {
            label: 'Account Name', fieldName: 'accountRecordId', type: 'url', hideDefaultActions: true, wrapText: true, fixedWidth: 180,
            typeAttributes: { label: { fieldName: 'accountName' }, target: '_blank' }
        },
        { label: 'Job Level', fieldName: 'Job_Level__c', wrapText: true, hideDefaultActions: true, fixedWidth: 120, },
        { label: 'Job Function', fieldName: 'Job_Function__c', wrapText: true, hideDefaultActions: true, fixedWidth: 150, },
        { label: 'Title', fieldName: 'Title', wrapText: true, hideDefaultActions: true, fixedWidth: 100, },
        {
            label: 'Reports To', fieldName: 'reportsToRecordId', type: 'url', hideDefaultActions: true, wrapText: true,
            typeAttributes: { label: { fieldName: 'ReportsToName' }, linkUrl: { fieldName: 'reportsToRecordId' }, target: '_blank' }
        },
    ]

    get oppName() {
        const rootObject = this.allNodes.find(item => item.Id === "rootlevel");
        return rootObject ? rootObject.Name : null;
    }

    /*connectedCallback() {
        this.handleChooseExistingContact();
    }*/

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
            //console.log('this.contactRoleOptions: ', JSON.stringify(this.contactRoleOptions));
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
            //console.log('data: ', JSON.stringify(data));
            this.accountId = data[0].AccountId;
            this.oppId = data[0].Id;
        }
    }

    handleCloseChooseContactModal() {
        this.showChooseContactModal = false;
        const submitEvent = new CustomEvent('closefromcontactpopup');
        this.dispatchEvent(submitEvent);
    }

    handleBackChooseContact() {
        this.showChooseContactModal = false;
        const submitEvent = new CustomEvent('backfromchoosecontactpopup');
        this.dispatchEvent(submitEvent);
    }

    handleChooseNewContact() {
        this.showChooseContactModal = false;
        this.showNewContactModal = true;
    }

    @api handleChooseExistingContact() {
        //this.showChooseContactModal = false;
        this.showChooseExistingContactModal = true;
        this.disableNextChooseExisting = true;
        this.showSpinner = true;
        this.data = '';
        this.selectedRows = '';
        this.getContactData();
    }

    /* Below Functions are used for Choose Existing Contact Functionality */
    /* Cancel Button */
    handleNewContactCancel() {
        this.showNewContactModal = false;
        const submitEvent = new CustomEvent('closefromcontactpopup');
        this.dispatchEvent(submitEvent);
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

    handleValidate(event) {
        let accessKey = event.target.accessKey;
        //console.log('accessKey: ', accessKey);
    }

    /* Save Button */
    handleSaveNewContact() {
        if (this.isNotReplace) {
            let isVal = true;
            this.errorMessage = '';

            /*this.template.querySelectorAll("c-multi-select-combobox-hierarchy").forEach(element => {
                isVal = isVal && element.checkValidity1();
                console.log('isVal: ', isVal);
            });*/
            this.template.querySelectorAll('lightning-input-field').forEach(element => {
                isVal = isVal && element.reportValidity();
            });

            this.contactList.forEach(element => {
                if (!element.JobRole) {
                    this.errorMessage = 'Role is mandatory.';
                    isVal = false;
                } else {
                    this.errorMessage = '';
                    isVal = true;
                }
            });

            if (isVal) {
                this.showSpinner = true;
                const createdRecordIds = [];
                const errors = [];
                let formsProcessed = 0;

                const forms = this.template.querySelectorAll('lightning-record-edit-form');
                //console.log('forms: ', JSON.stringify(forms));

                const totalForms = forms.length;
                //console.log('contactList: ', JSON.stringify(this.contactList));
                let contactWrapper = [];
                this.contactList.forEach((form, index) => {
                    contactWrapper.push({
                        index: index + 1,
                        salutation: form.Salutation,
                        firstName: form.FirstName,
                        lastName: form.LastName,
                        accountId: this.accountId,
                        email: form.Email,
                        jobFunction: form.Job_Function__c,
                        role: form.JobRole,
                        phone: form.Phone
                    });
                });
                //console.log('contactWrapper: ', JSON.stringify(contactWrapper));
                createContactRecords({
                    contactList: contactWrapper,
                    oppId: this.oppId,
                    hierarchyInformationId: this.contactHierarchyId,
                    parentNodeId: this.parentNode.Id,
                    allNodes: this.allNodes
                })
                    .then(data => {
                        //console.log('data: ', JSON.stringify(data));
                        //this.toast('SUCCESS', 'Contact added successfully!', 'success', 'dismissible');
                        const event = new ShowToastEvent({
                            title: 'Success !',
                            message: 'Contact added successfully!',
                            variant: 'success'
                        });
                        this.dispatchEvent(event);

                    })
                    .catch(error => {
                        console.log('error: ', error);
                        //this.toast('Error', 'Error Occurred ', 'error', 'dismissible');
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Error Occurred !',
                            variant: 'error'
                        });
                        this.dispatchEvent(event);
                    })
                    .finally(() => {
                        this.showSpinner = false;
                        this.refreshPage();
                        this.showNewContactModal = false;
                    })
                /*forms.forEach(element => {
                    // Handle success event listener
                    element.addEventListener('success', event => {
                        formsProcessed++;
                        // Capture the ID of the created or updated record
                        const contactRecordId = event.detail.id;
                        createdRecordIds.push(contactRecordId);
                        if (formsProcessed === totalForms) {
                            this.createdRecordIds = [...createdRecordIds];
                            this.addChildrenToJSON()
                                .then(() => {
                                    return this.createContactRole();
                                })
                                .then(() => {

                                    console.log('Contact Role created after');
                                    this.toast('SUCCESS', 'Contacts and Roles created successfully!', 'success', 'dismissible');

                                })
                                .catch(error => {
                                    console.error('Error during processing:', error);
                                    this.toast('Error', 'An error occurred. Please try again.', 'error', 'dismissible');
                                });
                        }
                        //this.handleRefresh();
                    });

                    // Handle error
                    element.addEventListener('error', event => {
                        formsProcessed++;
                        errors.push(event.detail); // Capture the error details
                        console.error('Error occurred during record creation:', event.detail);
                        if (formsProcessed === totalForms) {
                            this.toast('Error', errors, 'error', 'dismissible');
                        }
                    });
                    // Submit the form
                    element.submit();
                });*/
            } else {

            }
        } else {
            this.showSpinner = true;
            //console.log(JSON.stringify(this.contactList));
            let temp = JSON.parse(JSON.stringify(this.contactList));
            let contactToCreate = {};
            let jobRoleToUse;
            temp.forEach(element => {
                contactToCreate.FirstName = element.FirstName;
                contactToCreate.LastName = element.LastName;
                contactToCreate.Email = element.Email;
                contactToCreate.Phone = element.Phone;
                contactToCreate.AccountId = element.AccountId;
                contactToCreate.Salutation = element.Salutation;
                contactToCreate.Job_Function__c = element.Job_Function__c;
                jobRoleToUse = element.JobRole;
            });
            let replacedId = 'newIdToReplace';
            let currentNodeId = this.parentNode.Id;
            let finalNodeList = JSON.parse(JSON.stringify(this.allNodes));
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
            //console.log('finalNodeList: ', JSON.stringify(finalNodeList));

            updateHierarchyOnReplace({
                hierarchyList: finalNodeList,
                hierarchyInformationId: this.contactHierarchyId,
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

                    const refreshEvent = new CustomEvent("refreshhierarchy");
                    this.dispatchEvent(refreshEvent);
                })
                .catch((error) => {
                    console.log('error: ', JSON.stringify(error));
                })
                .finally(() => {
                    this.showSpinner = false;
                });
        }
    }

    addChildrenToJSON() {
        return new Promise((resolve, reject) => {
            let index = 0;
            let newChildList = this.contactList.map(contact => ({
                ReportsTo: this.parentNode.Id,
                Name: contact.Name,
                JobRole: contact.JobRole,
                IsPlaceholder: false,
                Id: this.createdRecordIds[index++] || '',
                //Children: []
            }));

            this.newChildList = [...newChildList];

            let tempAllNodes = JSON.parse(JSON.stringify(this.allNodes));
            tempAllNodes.forEach(element => {
                element.Children = [];
            });

            let finalNodeList = tempAllNodes.concat(newChildList);

            this.callApexToAddContactInHierarchy(finalNodeList);
        });
    }

    createContactRole() {

        // Add Contact Role to Opportunity
        let fields = this.newChildList.map(contact => ({
            OpportunityId: this.oppId,
            ContactId: contact.Id,
            Role: contact.JobRole,
            //IsPrimary: true,
        }));

        const recordInput = { apiName: 'OpportunityContactRole', fields };
        let errors = [];
        createContactRoleRecords({ contactRoleList: fields })
            .then(data => {
                if (data == 'Success') {
                    this.showNewContactModal = false;
                    this.showSpinner = false;
                    this.refreshPage();
                    this.showNewContactModal = false;
                    this.toast('SUCCESS', 'Contact Role added', 'success', 'dismissible');
                } else {
                    console.log('Error adding Contact Role:', JSON.stringify(data));
                    this.toast('Error', data, 'error', 'dismissible');
                }
            })
            .catch(error => {
                console.log('Error adding Contact Role:', JSON.stringify(error));
                errors.push(error);
                this.toast('Error', 'Failed to add Contact Role', 'error', 'dismissible');
            });
    }

    addChildrenById(json, newChildren) {
        const addChildrenRecursive = (nodes) => {
            nodes.forEach(node => {
                if (node.Id === this.parentNode.Id) {
                    // Add new children to the target node
                    node.Children.push(...newChildren.map(child => ({
                        Id: child.Id,
                        Name: child.Name,
                        IsPlaceholder: child.IsPlaceholder,
                        ReportsTo: child.ReportsTo,
                        JobRole: child.JobRole || null,
                        Children: child.Children || []
                    })));
                }
                // Recursively process child nodes
                if (node.Children && node.Children.length > 0) {
                    addChildrenRecursive(node.Children);
                }
            });
        };

        // Check if the input JSON is an array or object
        if (Array.isArray(json)) {
            addChildrenRecursive(json);
        } else {
            addChildrenRecursive([json]);
        }

        return json;
    }

    toggleSpinner() {
        // Dispatch event to parent to toggle spinner in grandparent
        const spinnerState = new CustomEvent('triggercontacthierarchyspinner', {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(spinnerState);
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

    handleRefresh() {
        let self = this;
        // Create a custom event to signal the need for a refresh
        const refreshEvent = new CustomEvent("refreshhierarcky", {
            bubbles: true,
            composed: true
        });
        // Dispatch the custom event to notify the parent component
        self.dispatchEvent(refreshEvent);
    }

    // Add New Row
    addRow() {
        ++this.keyIndex;
        var newItem = [{ index: this.keyIndex, isEdit: true }];
        this.contactList = this.contactList.concat(newItem);
    }

    // Remove or Delete Row
    removeRow(event) {

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

    // Below Functions are used for Choose Existing Contact Functionality
    // Back Button
    handleBackChooseContactModal() {
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
    handleCancelChooseExistingContactModal() {
        this.showChooseExistingContactModal = false;
        const submitEvent = new CustomEvent('closefromcontactpopup');
        this.dispatchEvent(submitEvent);
    }

    // Save Button
    handleSaveChooseExistingContact() {

        this.showSpinner = true;
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
            // list to create contact role
            this.newChildList = [...temp];

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
                    role: form.JobRole,
                });
            });

            updateHierarchyOnExistingContactSelection({
                contactList: contactWrapper,
                oppId: this.oppId,
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
                    this.showSpinner = false;
                    this.refreshPage();
                    this.showNewContactModal = false;
                })
            /*this.callApexToAddContactInHierarchy(finalNodeList);
            this.createContactRole();*/

        } else {
            let jobRoleOfContactToReplace = this.selectedRows[0].JobRole;
            let replacedId = this.selectedRowForReplace.Id;
            let currentNodeId = this.parentNode.Id;
            let finalNodeList = JSON.parse(JSON.stringify(this.allNodes));
            let oldNode = {};
            let contactsToUpdate = [];
            let replacedNode = finalNodeList.filter(element => element.Id == replacedId);
            if (replacedNode.length > 0 && JSON.stringify(replacedNode[0].Children).includes(currentNodeId)) {
                finalNodeList.forEach(element => {
                    if (element.ReportsTo == replacedNode[0].Id) {
                        if (!(replacedNode[0].ReportsTo).includes('Placeholder') && !(element.Id).includes('Placeholder')) {
                            let reportsToIdToUse = replacedNode[0].ReportsTo == 'rootlevel' ? null : replacedNode[0].ReportsTo;
                            let newContact = {
                                Id: element.Id,
                                ReportsToId: reportsToIdToUse
                            };
                            contactsToUpdate.push(newContact);
                        }
                        element.ReportsTo = replacedNode[0].ReportsTo;
                        console.log(JSON.stringify(element));
                    }
                });
            }
            finalNodeList = finalNodeList.filter(element => element.Id != replacedId);

            finalNodeList.forEach(element => {
                if (element.Id == currentNodeId) {
                    if (!(element.ReportsTo).includes('Placeholder')) {
                        let reportsToIdToUse = element.ReportsTo == 'rootlevel' ? null : element.ReportsTo;
                        let newContact = {
                            Id: replacedId,
                            ReportsToId: reportsToIdToUse
                        };
                        contactsToUpdate.push(newContact);
                    }

                    element.Id = replacedId;
                    element.IsPlaceholder = false;// added by aashi for placeholder conversion
                    //element.JobRole = ;// To add Job Role
                }
                //Child of Current Node
                if (element.ReportsTo == currentNodeId) {
                    if (element.IsPlaceholder == false) {
                        let con = {
                            Id: element.Id,
                            ReportsToId: replacedId
                        }
                        contactsToUpdate.push(con);
                    }
                    element.ReportsTo = replacedId;

                }
                element.Children = [];
            });

            console.log('finalNodeList: ', JSON.stringify(finalNodeList));

            updateHierarchyOnReplace({
                hierarchyList: finalNodeList,
                hierarchyInformationId: this.contactHierarchyId,
                replacedId: replacedId,
                contactToReplace: null,
                contactsToUpdate: contactsToUpdate,
                contactToDelete: currentNodeId,
                jobRoleOfContactToReplace: jobRoleOfContactToReplace
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
                    this.showSpinner = false;
                });
        }

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

    callApexToAddContactInHierarchy(finalNodeList) {
        updateHierarchyOnPlaceholderCreation({ hierarchyList: finalNodeList, hierarchyInformationId: this.contactHierarchyId })
            .then((result) => {
                this.showChooseExistingContactModal = false;
                console.log('result: ', JSON.stringify(result));
                const event = new ShowToastEvent({
                    title: 'Contact(s) added successfully !',
                    variant: 'success'
                });
                this.dispatchEvent(event);

                const refreshEvent = new CustomEvent("refreshhierarchy");
                this.dispatchEvent(refreshEvent);
            })
            .catch((error) => {
                console.log('error: ', JSON.stringify(error));
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    refreshPage() {
        const submitEvent = new CustomEvent('refreshhierarchy',
            {
                bubbles: true,
                composed: true
            });
        this.dispatchEvent(submitEvent);
    }

    handleSearchContact(event) {
        this.contactFilterValue = event.detail.value;
    }

    handleSearchAction() {
        this.getContactData();
    }

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

    loadData(event) {
        event.preventDefault();
        console.log('Inside Load More Data');
        if (event.target.isLoading) {
            return; // Prevent multiple simultaneous calls
        }
        if (event.target) {
            event.target.isLoading = true;
        }
        this.tableElement = event.target;
        this.loadMoreStatus = 'Loading';
        this.getMoreContactData();
    }

    getContactData() {

        let contactIdsListFromHierarchy = this.getContactIdsListFromHierarchy();
        let currentId = this.parentNode.Id.startsWith('003') ? this.parentNode.Id : null;
        let contantIdToPass = this.isNotReplace ? contactIdsListFromHierarchy : currentId;
        console.log('this.accountId: ', this.accountId);
        getActiveContacts({ offSetValue: 0, filterValue: this.contactFilterValue, currentContactIdsInHierarchy: contantIdToPass, accountId: this.accountId, isNotReplace: this.isNotReplace })
            .then(result => {
                this.showSpinner = false;
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
                console.log('1 error ====> ', error);
            })
            .finally(() => {
                if (this.tableElement) {
                    this.tableElement.isLoading = false;
                }
            });
    }

    getMoreContactData() {
        this.tableElement.isLoading = true;
        let contactIdsListFromHierarchy = this.getContactIdsListFromHierarchy();
        let currentId = this.parentNode.Id.startsWith('003') ? this.parentNode.Id : null;
        let contantIdToPass = this.isNotReplace ? contactIdsListFromHierarchy : currentId;
        getActiveContacts({ offSetValue: this.dataCount, filterValue: this.contactFilterValue, currentContactIdsInHierarchy: contantIdToPass, accountId: this.accountId, isNotReplace: this.isNotReplace })
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

    //This is the function used for handling the row selection
    handleRowSelection(event) {
        let selectedItemsSet = event.detail.selectedRows.map((row) => {
            return row.Id
        });
        this.selectedRowsIds = [...selectedItemsSet];
        this.selectedRows = [...event.detail.selectedRows];

        this.selectedRows.forEach(row => {
            row.isEdit = true;
        });
        //console.log('selectedItemsSet: ', JSON.stringify(this.selectedRows));
        if (this.selectedRows.length > 0) {
            this.disableNextChooseExisting = false;
        }
        else {
            this.disableNextChooseExisting = true;
        }
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

    handleEdit(event) {
        let accessKey = event.target.accessKey;
        event.stopPropagation();
        this.contactList[accessKey - 1].isEdit = true;

    }

    handleRowSelectionForReplace(event) {
        this.selectedRowForReplace = event.detail.selectedRows[0];
        this.disableNextChooseExisting = false;
    }

    handleInputRoleOnNextScreen(event) {
        this.selectedOptions = event.detail;
        let temp = [];
        this.selectedOptions.forEach(element => {
            temp.push(element.label);
        });
        this.updatedSelectedRoles = temp.join(';');

        let accessKey = event.target.accessKey;
        if (this.updatedSelectedRoles) {
            /*this.contactList.forEach(element => {
                if (element.Id == this.selectedRows[accessKey].Id) {
                    element.JobRole = this.updatedSelectedRoles;
                }
            });*/
            this.selectedRows[accessKey].JobRole = this.updatedSelectedRoles;
        } else {
            this.selectedRows[accessKey].JobRole = '';
            this.selectedRows[accessKey].isEdit = true;
        }
        this.disableSaveChooseExisting = this.selectedRows.some((contact) => !contact.JobRole);
    }

    handleCloseOnNextScreen(event) {
        let accessKey = event.target.accessKey;
        this.selectedRows[accessKey].isEdit = false;
        /*if (this.selectedOptions.length > 0) {
            this.selectedRows[accessKey].isEdit = false;
        } else {
            this.selectedRows[accessKey].isEdit = true;
        }*/
    }

    handleEditOnNextScreen(event) {
        let accessKey = event.target.accessKey;
        event.stopPropagation();
        this.selectedRows[accessKey].isEdit = true;
    }

    handleNextChooseExistingContactModal() {
        this.showNextScreen = true;
        this.disableSaveChooseExisting = true;
        let indexVal = 1;
        if (this.isNotReplace) {
            this.selectedRows.forEach(row => {
                row.index = indexVal++;
            });
        } else {
            let selectedRowsList = [];
            selectedRowsList.push(this.selectedRowForReplace);
            this.selectedRows = [...selectedRowsList];// JSON.parse(JSON.stringify(this.selectedRowForReplace));
            this.selectedRows.forEach(row => {
                row.index = indexVal++;
                row.isEdit = true;
            });
        }
    }
}