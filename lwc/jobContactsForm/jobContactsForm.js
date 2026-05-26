import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import CONTACT_DETAILS_FIELD from '@salesforce/schema/Job__c.Contact_Details__c';
import JOB_ID_FIELD from '@salesforce/schema/Job__c.Id';

const FIELDS = [CONTACT_DETAILS_FIELD];

// Regular Expressions for Validation
const NAME_REGEX = /^(?!.*\s{2,})[a-zA-Z\s\-']{2,50}$/;// Allows letters, spaces, hyphens, and apostrophes (2 to 50 characters)
const EMAIL_REGEX = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/; // Standard email format

export default class jobContactsForm extends LightningElement {
    @api recordId;
    @track contacts = [];
    roleOptions = [
        { label: 'Project Sponsor', value: 'Project Sponsor' },
        { label: 'Delivery Manager', value: 'Delivery Manager' }
    ];

    // Fetch existing Contact_Details__c from Job__c
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredJob({ error, data }) {
        if (data) {
            const contactDetails = data.fields.Contact_Details__c.value;
            if (contactDetails) {
                try {
                    this.contacts = JSON.parse(contactDetails);
                } catch (e) {
                    console.error('Error parsing Contact_Details__c:', e);
                }
            }
        } else if (error) {
            console.error('Error loading job record:', error);
        }
    }

    get disableAddButton() {
        return this.contacts && this.contacts.length >= 3;
    }

    get disableSaveButton() {
        return this.contacts.length === 0;
    }

    handleChange(event) {
        const index = event.target.dataset.id;
        const field = event.target.name;
        this.contacts[index][field] = event.target.value;
    }

    handleAdd() {
        if (this.contacts.length < 3) {
            this.contacts = [...this.contacts, { name: '', email: '', role: '' }];
        }
    }

    handleDelete(event) {
        const index = event.target.dataset.id;
        this.contacts.splice(index, 1);
        this.contacts = [...this.contacts];
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave() {
        // Validate all contacts before saving
        let isValid = true;
        let errorMessage = '';

        this.contacts.forEach(contact => {
            if (!contact.name || !NAME_REGEX.test(contact.name.trim())) {
                isValid = false;
                errorMessage = 'Invalid name format. Use only letters, spaces, hyphens, and apostrophes (2-50 characters).';
            }
            if (!contact.email || !EMAIL_REGEX.test(contact.email.trim())) {
                isValid = false;
                errorMessage = 'Invalid email format. Please enter a valid email address.';
            }
        });

        if (!isValid) {
            this.showToast('Error', errorMessage, 'error');
            return;
        }

        const fields = {};
        fields[JOB_ID_FIELD.fieldApiName] = this.recordId;

        if (this.contacts.length === 0) {
            this.contacts = null;
        }

        fields[CONTACT_DETAILS_FIELD.fieldApiName] = this.contacts ? JSON.stringify(this.contacts) : null;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.showToast('Success', 'Contacts updated successfully', 'success');
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                console.error('Error updating contacts:', error);
                this.showToast('Error', 'Error saving contacts', 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}