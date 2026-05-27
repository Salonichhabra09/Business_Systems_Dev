import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class PasswordManager extends LightningElement {
    @api recordId;
    @track showJobEmailManager = false;
    @track showSendExistingPassword = false;

    handleGenerateNewPassword() {
        this.showJobEmailManager = true;
        this.showSendExistingPassword = false;
    }

    handleSendExistingPassword() {
        this.showSendExistingPassword = true;
        this.showJobEmailManager = false;
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent()); // Closes the parent component
    }
}