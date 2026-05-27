import { LightningElement, api, wire } from 'lwc';
import getNote from '@salesforce/apex/ACR_RelationshipMapController.getNote';
import insertNote from '@salesforce/apex/ACR_RelationshipMapController.insertNote';
import updateNote from '@salesforce/apex/ACR_RelationshipMapController.updateNote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getActivityMetricData from '@salesforce/apex/ACR_RelationshipMapController.getActivityMetricData';

export default class Acr_contactViewCard extends NavigationMixin(LightningElement) {

    @api contact;
    @api activeTab;
    enabledOptionsInRichTextToolbar = [
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'image',
    ];
    noteOfContact = 'Please add a note to this contact.';
    newNote;
    isShowSpinner = false;
    isAddNoteVisible = true;
    isNoteInserted = false;
    activeTabValue;
    isSubmitDisabled = true;

    showHierarchy = false;
    isEdit = false;
    isView = true;
    isFormLoaded = false;
    lastInboundEmailDate;
    lastActivityDate;
    homeAddressId;

    @wire(getActivityMetricData, ({ contactId: '$contact.Id' }))
    accountRecord({ error, data }) {
        if (error) {
            console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            console.log('data: ', JSON.stringify(data));
            //
            if (data?.activityData[0]?.LastEmailReceivedDateTime) {
                // Convert to a Date object
                const dateObj = new Date(data?.activityData[0]?.LastEmailReceivedDateTime);

                // Extract day, month, and year
                const day = String(dateObj.getDate()).padStart(2, '0'); // Ensures two digits
                const month = String(dateObj.getMonth() + 1).padStart(2, '0'); // Months are 0-based
                const year = dateObj.getFullYear();

                // Format as DD/MM/YYYY
                const formattedDate = `${day}/${month}/${year}`;
                this.lastInboundEmailDate = formattedDate;
            }
            if (data?.activityData[0]?.LastActivityDateTime) {
                // Convert to a Date object
                const dateObj = new Date(data?.activityData[0]?.LastActivityDateTime);

                // Extract day, month, and year
                const day = String(dateObj.getDate()).padStart(2, '0'); // Ensures two digits
                const month = String(dateObj.getMonth() + 1).padStart(2, '0'); // Months are 0-based
                const year = dateObj.getFullYear();

                // Format as DD/MM/YYYY
                const formattedDate = `${day}/${month}/${year}`;
                this.lastActivityDate = formattedDate;
            }
            if (data.addressData[0]?.Id != null) {
                this.homeAddressId = data.addressData[0]?.Id;
            }
        }
    }

    connectedCallback() {
        if (this.activeTab == 'Notes') {
            console.log(this.activeTab);
            this.activeTabValue = 2;
        }
    }

    handleGetContactNote() {
        this.isShowSpinner = true;
        getNote({
            recordId: this.contact.Id
        })
            .then((result) => {
                if (result != null) {
                    this.noteOfContact = result;
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

    handleContentChange(event) {
        this.newNote = event.target.value;
        this.isSubmitDisabled = this.newNote.trim().length >= 2 ? false : true;
    }

    handleAddNote() {
        this.isShowSpinner = true;
        if (this.contact.IsNoteAdded || this.isNoteInserted) {
            updateNote({
                content: this.newNote,
                recordId: this.contact.Id
            })
                .then((result) => {
                    this.toast('Success !', '', 'success', 'dismissible');
                    this.isAddNoteVisible = false;
                    this.isSubmitDisabled = true;
                    setTimeout(() => {
                        this.isAddNoteVisible = true;
                    }, 0);
                    this.isSubmitDisabled
                    this.handleGetContactNote();
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
            insertNote({
                content: this.newNote,
                recordId: this.contact.Id
            })
                .then((result) => {
                    this.toast('Success !', '', 'success', 'dismissible');
                    this.isAddNoteVisible = false;
                    this.isSubmitDisabled = true;
                    setTimeout(() => {
                        this.isAddNoteVisible = true;
                    }, 0);
                    this.isNoteInserted = true;
                    this.handleGetContactNote();
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

    toast(title, message, variant, mode) {

        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
        })
        this.dispatchEvent(toastEvent)
    }

    handleFormLoad() {
        this.isShowSpinner = false;
        this.isFormLoaded = true;
    }

    handleSubmit() {
        this.isShowSpinner = true;
    }

    handleSuccess() {
        this.toast('Success !', 'Contact Edited Successfully', 'success', 'dismissible');

        this.dispatchEvent(new CustomEvent('refreshhierarchy', {
            bubbles: true,
            composed: true
        }));
    }

    handleCloseEdit() {
        this.isShowSpinner = true;
        this.isEdit = false;
        this.isView = true;
        this.isFormLoaded = false;
    }

    handleEditContact() {
        this.isShowSpinner = true;
        this.isEdit = true;
        this.isView = false;
        this.isFormLoaded = false;
    }

    handleError() {
        this.isShowSpinner = false;
    }

    handleNavigateToContact() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contact.Id,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }
}