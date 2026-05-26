import { LightningElement, api, track } from 'lwc';
import authenticateUser from '@salesforce/apex/JobPasswordController.authenticateUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AuthPage extends LightningElement {
    @api recordId; // Job__c record ID
    email = '';
    password = '';
    isLoading = false;
    isAuthenticated = false;
    errorMessage = '';

    handleEmailChange(event) {
        this.email = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    handleLogin() {
        this.isLoading = true;
        this.errorMessage = '';
        this.isAuthenticated = false;

        authenticateUser({ email: this.email, password: this.password, jobId: this.recordId })
            .then((isValid) => {
                if (isValid) {
                    this.isAuthenticated = true;
                    //this.showToast('Success', 'Authentication Successful!', 'success');
                      const eve = new CustomEvent('authentication',{
                    detail:{
                    status : 'Success',
                }
                })
                this.dispatchEvent(eve);
                } else {
                    this.errorMessage = 'Invalid Email or Password! ❌';
                }
            })
            .catch((error) => {
                this.errorMessage = 'Error: ' + error.body.message;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}