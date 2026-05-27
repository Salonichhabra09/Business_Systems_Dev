import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ROLE_FIELD from '@salesforce/schema/OpportunityContactRole.Role';
import updateContactRole from '@salesforce/apex/OpportunityContactHierarchy.updateContactRole';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EditContactRoleOnOppHierarchy extends LightningElement {

    @track contactRoleOptions;
    selectedRoles;
    isEdit = true;
    @track selectedOptions = [];
    updatedSelectedRoles;
    @api currentNode;
    @api hierarchyInformationId;
    @api allNodes;
    @api modalresize;
    @api oppId;
    showSpinner = false;
    showSubmit = true;
    oldRoles;

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
            this.oldRoles = this.currentNode.JobRole;
            this.updatedSelectedRoles = this.currentNode.JobRole;
            console.log('this.updatedSelectedRoles: ', this.updatedSelectedRoles);
            console.log('this.contactRoleOptions: ', JSON.stringify(this.contactRoleOptions));
        } else if (error) {
            console.log(error);
        }
    }

    handleCancelOnEditContactRole() {
        this.dispatchEvent(new CustomEvent('closeupdatecontactrolepopup'));
    }

    handleSaveOnEditContactRole() {
        this.showSpinner = true;
        let tempAllNodes = JSON.parse(JSON.stringify(this.allNodes));
        tempAllNodes.forEach(element => {
            element.Children = [];
            if (element.Id == this.currentNode.Id) {
                element.JobRole = this.updatedSelectedRoles;
            }
        });
        console.log('tempAllNodes: ', JSON.stringify(tempAllNodes));

        let oldRoleList = this.oldRoles?.split(',');
        let newRoleList = this.updatedSelectedRoles?.split(';');

        let rolesToInsertList = newRoleList?.filter(item => !oldRoleList?.includes(item));
        let rolesToInsert = rolesToInsertList?.join(';');
        console.log('rolesToInsert: ', rolesToInsert);

        let rolesToDeleteList = oldRoleList?.filter(item => !newRoleList?.includes(item));
        let rolesToDelete = rolesToDeleteList?.join(';');
        console.log('rolesToDelete: ', rolesToDelete);

        updateContactRole({
            newroleToInsert: rolesToInsert,
            oldroleToDelete: rolesToDelete,
            hierarchyList: tempAllNodes,
            hierarchyInformationId: this.hierarchyInformationId,
            contactId: this.currentNode.Id
        })
            .then(data => {
                debugger;
                this.showSpinner = false;
                console.log('data: ', data);
                const event = new ShowToastEvent({
                    title: 'Success !',
                    variant: 'success',
                    message: 'Contact Role updated successfully!'
                });
                this.dispatchEvent(event);
                this.dispatchEvent(new CustomEvent('refreshhierarchy', {
                    bubbles: true,
                    composed: true
                }));
            })
            .catch(error => {
                console.log('error: ', JSON.stringify(error));
                let errorMessage = '';
                if (error?.body) {
                    if (error.body.message == 'Primary Contact cannot be deleted.') {
                        errorMessage = 'Decision Maker role cannot be removed for this contact because this is a primary contact on Opportunity. However, you can assign more roles if needed.'
                    }
                    else if (error.body.message == 'Contact cannot be deleted as this is marked as Billing contact on Opportunity.') {
                        errorMessage = 'Billing Contact role cannot be removed for this contact because this is a billing contact on Opportunity. However, you can assign more roles if needed.'
                    }
                    else if (error.body.message == 'Primary contact Cannot be Changed, as this is associated with an Opportunity Header.') {
                        errorMessage = '1';
                    }
                    else if (error.body.message == 'Cannot mark this contact as primary contact, since the associated opportunity already has a primary contact.') {
                        errorMessage = '2';
                    }
                    else if (error.body.message == 'Role Cannot be Changed for this contact, as this is a billing contact on Opportunity Header.') {
                        errorMessage = '3';
                    }
                    else if (error.body.message == 'Contact Cannot be changed as this contact is either Billing contact or Primary contact') {
                        errorMessage = '4';
                    } else {
                        errorMessage = error.body.message;
                    }
                } else {
                    errorMessage = 'Error Occurred!';
                }
                const event = new ShowToastEvent({
                    title: 'Error !',
                    variant: 'error',
                    message: errorMessage
                });
                this.dispatchEvent(event);
            }).finally(() => {
                this.showSpinner = false;
                this.dispatchEvent(new CustomEvent('closeupdatecontactrolepopup'));
            });
    }

    handleInputRole(event) {
        this.selectedOptions = event.detail;
        let temp = [];
        this.selectedOptions.forEach(element => {
            temp.push(element.label);
        });
        this.updatedSelectedRoles = temp?.join(';');
        console.log('this.updatedSelectedRoles: ', this.updatedSelectedRoles);
        console.log('this.selectedOptions: ', this.selectedOptions);
        if (this.selectedOptions?.length > 0) {
            this.showSubmit = false;
        } else {
            this.showSubmit = true;
        }
    }

    handleClose() {
        if (this.selectedOptions?.length > 0) {
            this.isEdit = false;
        }
    }

    closeEditOnBlur() {
        if (this.selectedOptions?.length > 0) {
            this.isEdit = false;
        }
    }

    handleEdit(event) {
        event.stopPropagation();
        this.isEdit = true;

    }
}