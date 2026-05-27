import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import { loadStyle } from "lightning/platformResourceLoader";
import userId from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import modalPopupCss from "@salesforce/resourceUrl/CssForMoveToAccount";
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import createNewContact from '@salesforce/apex/MoveToAnotherAccountController.createNewContact';

export default class MoveToAnotherAccount extends NavigationMixin(LightningElement) {

  @api recordId;
  showContactForm = false;
  showMessage = true;
  showCreatedContactInfo = false;
  header = 'Move to Another Account';
  contact;
  isGcscGeneral = false;
  isOtherProfile = false;
  profileName;
  showSpinner = true;
  showErrorMessage = false;
  oldContactName;
  newContactName;
  oldContactAccount;
  newContactAccount;
  oldContactEmail;
  newContactEmail;
  newContactId;
  oldContactId;
  getNewContactDetails = false;
  errorMessage;
  inputVariables;
  renderFlow = false;
  errorInFlow = false;

  @wire(getRecord, { recordId: "$recordId", layoutTypes: ["Full"], modes: ["View"] })
  wiredRecord({ error, data }) {
    if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading contact",
          message,
          variant: "error",
        }),
      );
    } else if (data) {
      this.contact = data;

      this.showSpinner = false;
      if (!this.getNewContactDetails) {
        this.oldContactName = (!this.contact.fields.FirstName.value) ? this.contact.fields.LastName.value : this.contact.fields.FirstName.value + ' ' + this.contact.fields.LastName.value;
        this.oldContactAccount = this.contact.fields.Account.value.fields.Name.value;
        this.oldContactEmail = this.contact.fields.Email.value;
      } else {
        this.newContactName = (!this.contact.fields.FirstName.value) ? this.contact.fields.LastName.value : this.contact.fields.FirstName.value + ' ' + this.contact.fields.LastName.value;
        this.newContactAccount = this.contact.fields.Account.value.fields.Name.value;
        this.newContactEmail = this.contact.fields.Email.value;
        this.getNewContactDetails = false;
      }

    }
  }

  @wire(getRecord, {
    recordId: userId, fields: [PROFILE_NAME_FIELD]
  }) wireuser({
    error,
    data
  }) {
    if (error) {
      this.error = error;
    } else if (data) {
      this.profileName = data.fields.Profile.value.fields.Name.value;
      this.isGcscGeneral = this.profileName == 'GCSC General' ? true : false;
      this.isOtherProfile = this.profileName == 'System Administrator' || this.isGcscGeneral ? false : true;
    }
  }

  connectedCallback() {
    loadStyle(this, modalPopupCss);
  }

  openContactForm() {
    this.recordIdToUse = this.recordId;
    this.showMessage = false;
    this.showContactForm = true;
    this.header = 'New Contact';
  }

  handleSave(event) {
    this.showSpinner = true;
    const valid = [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
      return (validSoFar && field.reportValidity());
    }, true);
    if (!valid) {
      this.showErrorMessage = true;
      this.template.querySelectorAll('lightning-input-field').forEach(element => { element.reportValidity(); });
      this.errorMessage = 'Please fill all the required fields';
      setTimeout(() => {
        this.handleScrollToError();
      }, 0);
      this.showSpinner = false;
    } else {
      const inputFields = this.template.querySelectorAll(
        'lightning-input-field'
      );
      let contact = {};
      inputFields.forEach(element => {
        //let ele = element.fieldName;
        contact[element.fieldName] = element.value;
      });
      //this.template.querySelector('lightning-record-edit-form').submit();
      this.handleCreateNewContact(contact);
    }
  }

  handleCreateNewContact(contact) {
    createNewContact({ contact: contact }).then(Response => {
      if (Response.messageType == 'Success') {

        this.handleSuccess({ detail: { id: Response.returnInfo } });
      }
      else if (Response.messageType == "Error") {
        this.errorMessage = Response.returnInfo;
        this.handleError();
      }

      this.showSpinner = false;

    }).catch(error => {
      let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
      const event = new ShowToastEvent({
        title: 'Error!',
        message: message,
        variant: 'error'
      });
      this.dispatchEvent(event);
    });
  }

  closeModal() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleSuccess(event) {
    this.getNewContactDetails = true;
    this.newContactId = event.detail.id;
    this.updateOldContactStatus();
  }

  handleError() {
    this.showSpinner = false;
    this.showErrorMessage = true;
    setTimeout(() => {
      this.handleScrollToError();
    }, 0);
  }

  handleFinish() {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.newContactId,
        actionName: 'view'
      }
    });
    this.closeModal();

  }

  updateOldContactStatus() {
    this.oldContactId = this.recordId;
    this.recordId = this.newContactId;
    this.submitFlow();
  }

  handleScrollToError() {
    const errorDiv = this.template.querySelector('[data-id="error-message"]');
    errorDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
  }

  handleNavigateToContact(event) {

    let recordId = event.target.dataset.id;
    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        actionName: 'view'
      }
    }).then(url => {
      window.open(url, "_blank");
    });
  }

  submitFlow() {
    this.inputVariables = [
      {
        name: 'oldContactId',
        type: 'String',
        value: this.oldContactId
      }
    ]
    this.renderFlow = true;

  }

  handleStatusChange(event) {
    let flowStatus = event.detail;
    let errorMessage = flowStatus.outputVariables[0].value;
    if (flowStatus.status === 'FINISHED_SCREEN' && !errorMessage) {
      this.handleShowContactForm();
    } else if (flowStatus.status === 'FINISHED_SCREEN' && errorMessage) {
      this.errorInFlow = true;
      this.handleShowContactForm();
    }
    this.renderFlow = false;
  }

  handleShowContactForm() {
    this.showContactForm = false;
    this.showCreatedContactInfo = true;
    this.showSpinner = false;
    this.header = 'Contact moved successfully !';
  }

}