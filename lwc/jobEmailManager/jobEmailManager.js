import { LightningElement, api, wire, track } from 'lwc';
import getEmailList from '@salesforce/apex/JobPasswordController.getEmailList';
import initiatePasswordGeneration from '@salesforce/apex/JobPasswordController.initiatePasswordGeneration';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class JobEmailManager extends LightningElement {
    @api recordId;
    @track emailList = [];
    @track isLoading = false;
    newEmail = '';
    showEmailError = false;

    columns = [
        { label: 'Email', fieldName: 'email', type: 'email' },
        { type: 'button-icon', initialWidth: 50, typeAttributes: { iconName: 'utility:delete', title: 'Remove', variant: 'bare', alternativeText: 'Remove', iconClass: 'slds-icon-text-error' }, cellAttributes: { alignment: 'right' }, name: 'remove' }
    ];

    get emailInputClass() {
        return this.showEmailError ? 'slds-has-error' : '';
    }

    get emailListFormatted() {
        return this.emailList.map(email => ({ id: email, email }));
    }
    
    @wire(getEmailList, { jobId: '$recordId' })
    wiredEmails({ error, data }) {
        if (data) {
            this.emailList = [...data];
        } else if (error) {
            console.error(error);
        }
    }
    
  handleEmailChange(event) {
        this.newEmail = event.target.value;
    }
    
    addEmail() {
        const inputField = this.template.querySelector('[data-email]');
        if (this.newEmail) {
            if (!this.validateEmail(this.newEmail)) {
                this.showEmailError = true;
                inputField.setCustomValidity(''); // Remove Salesforce default error
                inputField.reportValidity();
                return;
            }
            this.showEmailError = false;
            inputField.setCustomValidity('');
            inputField.reportValidity();

            if (!this.emailList.includes(this.newEmail)) {
                this.emailList = [...this.emailList, this.newEmail];
                this.newEmail = '';
            }
        }
    }
    
    validateEmail(email) {
        const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        return emailRegex.test(email);
    }
    
    handleRowAction(event) {
        const row = event.detail.row;
        this.emailList = this.emailList.filter(email => email !== row.email);
    }
    
    generateAndSendPassword() {
        this.isLoading = true;
        initiatePasswordGeneration({ jobId: this.recordId, updatedEmails: this.emailList })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Password generated and emails sent successfully',
                    variant: 'success'
                }));
                this.dispatchEvent(new CustomEvent('closeparent')); // Close the LWC after successful email send
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}