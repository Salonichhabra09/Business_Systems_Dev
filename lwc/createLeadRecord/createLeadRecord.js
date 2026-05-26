import { LightningElement, api, track, wire } from 'lwc';
import Lead_OBJECT from '@salesforce/schema/Lead';
import Id from '@salesforce/user/Id';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import createLeadRecords from '@salesforce/apex/LeadCreationController.createLeadRecords';
import getAppDefination from '@salesforce/apex/LeadCreationController.getAppDefination';
import updateContactRecord from '@salesforce/apex/LeadCreationController.updateContactRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const ContactFields = ['Contact.FirstName', 'Contact.Title', 'Contact.Job_Function__c', 'Contact.Job_Level__c', 'Contact.Phone', 'Contact.Email', 'Contact.Mailing_Address_Line_1__c',
    'Contact.Mailing_Address_Line_2__c', 'Contact.Mailing_City__c', 'Contact.Mailing_State_County__c', 'Contact.Mailing_ZIP_Postal_Code__c', 'Contact.Area_of_Interest__c'
    , 'Contact.Global_Mailing_Country__c', 'Contact.LastName', 'Contact.Salutation', 'Contact.Account.Name', 'Contact.Account.Size_of_Workforce__c'];
export default class CreateLeadRecord extends NavigationMixin(LightningElement) {

    @api recordId;
    @track selectedValue = '';
    @track options = [];
    @track showdropdown = false;
    @track RecordTypeName = 'Referral';
    showRecordForm = false;
    HQStateDisabled = true;
    HQStateValue;
    HQStateOptions;
    userId = Id;
    companyName;
    name;
    email;
    error;
    phoneNumber;
    profileName;
    leadRecord = {};
    isCreated = false;
    validationError = true;
    isButtonDisabled = false;
    isStandard = true;
    contactName;
    contactTitle;
    contactJobFunction;
    contactJobLevel;
    contactLeadCountry;
    contactCompany;
    contactPhone;
    contactEmail;
    contactAddress1;
    contactAddress2;
    contactStateCounty;
    contactCityTown;
    contactZipCode;
    contactAreaOfInterest;
    contactSizeOfWork;
    contactRecordToUpdate = {};
    updateContact = false;
    connectedCallback() {
        this.companyName = "SHL";
    }

    @wire(getObjectInfo, { objectApiName: Lead_OBJECT })
    leadObjectInfo({ data, error }) {
        if (data) {
            // map of record type Info
            const rtInfos = data.recordTypeInfos;
            // getting map values
            let rtValues = Object.values(rtInfos);

            for (let i = 0; i < rtValues.length; i++) {
                if (rtValues[i].name =='Referral') {
                    this.selectedValue = rtValues[i].recordTypeId;
                    this.RecordTypeName = rtValues[i].name;
                }
            }
            this.getAppDefinationName();
        }
        else if (error) {
            window.console.log('Error ===> ' + JSON.stringify(error));
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: ContactFields })
    contactDetails({ error, data }) {
        if (data) {
            this.contactName = {
                Salutation: data.fields.Salutation.value,
                FirstName: data.fields.FirstName.value,
                LastName: data.fields.LastName.value
            };
            this.contactTitle = data.fields.Title.value;
            this.contactJobFunction = data.fields.Job_Function__c.value;
            this.contactJobLevel = data.fields.Job_Level__c.value;
            this.contactLeadCountry = data.fields.Global_Mailing_Country__c.value;
            this.contactPhone = data.fields.Phone.value;
            this.contactEmail = data.fields.Email.value;
            this.contactStateCounty = data.fields.Mailing_State_County__c.value;
            this.contactCityTown = data.fields.Mailing_City__c.value;
            this.contactAddress1 = data.fields.Mailing_Address_Line_1__c.value;
            this.contactAddress2 = data.fields.Mailing_Address_Line_2__c.value;
            this.contactZipCode = data.fields.Mailing_ZIP_Postal_Code__c.value;
            this.contactAreaOfInterest = data.fields.Area_of_Interest__c.value;
            this.contactCompany = data.fields.Account.value.fields.Name.value;
            this.contactSizeOfWork = data.fields.Account.value.fields.Size_of_Workforce__c.value;
            this.setPredefinedvaluesforLeadRecord(data);
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getRecord, { recordId: Id, fields: [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD, PROFILE_NAME_FIELD] })
    userDetails({ error, data }) {
        if (data) {
            this.name = data.fields.Name.value;
            this.email = data.fields.Email.value;
            this.phoneNumber = data.fields.Phone.value;
            this.profileName = data.fields.Profile.value.fields.Name.value;

            this.leadRecord['sobjectType'] = 'Lead';
            this.leadRecord['Opportunity_Submitted__c'] = Id;
            this.leadRecord['Submitter_s_Company__c'] = 'SHL';
            this.leadRecord['Submitter_s_Referrer_s_name__c'] = this.name;
            this.leadRecord['Submitter_s_Email_Address__c'] = this.email;
            this.leadRecord['Submitter_s_Referrer_s_telephone_number__c'] = this.phoneNumber;
            this.leadRecord['Lead_Source_Most_Recent__c'] = 'Reputation / Referral';
            this.leadRecord['Lead_Source_Detail_Most_Recent__c'] = 'Internal New Lead Form';
            this.leadRecord['LeadSource'] = 'Reputation / Referral';
            this.leadRecord['Lead_Source_Detail__c'] = 'Internal New Lead Form';
            this.leadRecord['Lead_System_Source__c'] = 'Non-Eloqua';
            this.leadRecord['Inactive_in_Eloqua__c'] = false;
            //this.leadRecord['Eloqua_Description__c'] = 'This lead has been created internally by SHL using the new lead form. They are interested in  ';
        } else if (error) {
            this.error = error;
        }
    }

    setPredefinedvaluesforLeadRecord(data) {
        this.leadRecord['FirstName'] = data.fields.FirstName.value;
        this.leadRecord['LastName'] = data.fields.LastName.value;
        this.leadRecord['Salutation'] = data.fields.Salutation.value;
        this.leadRecord['Title'] = this.contactTitle;
        this.leadRecord['Job_Function__c'] = this.contactJobFunction;
        this.leadRecord['Job_Level__c'] = this.contactJobLevel;
        this.leadRecord['Global_Lead_Country__c'] = this.contactLeadCountry;
        this.leadRecord['Company'] = this.contactCompany;
        this.leadRecord['Phone'] = this.contactPhone;
        this.leadRecord['Email'] = this.contactEmail;
        this.leadRecord['State_County__c'] = this.contactStateCounty;
        this.leadRecord['City_Town__c'] = this.contactCityTown;
        this.leadRecord['Address_1__c'] = this.contactAddress1;
        this.leadRecord['Address_2__c'] = this.contactAddress2;
        this.leadRecord['Zip_Postcode__c'] = this.contactZipCode;
        this.leadRecord['Size_Of_Workforce__c'] = this.contactSizeOfWork;
        this.leadRecord['Area_of_Interest__c'] = this.contactAreaOfInterest;
        this.leadRecord['Eloqua_Description__c'] = 'This lead has been created internally by SHL using the new lead form. They are interested in  ' + this.contactAreaOfInterest;
        this.leadRecord['RecordTypeId'] = this.selectedValue;
    }


    closeModal() {
        this.showdropdown = false;
        this.showRecordForm = false;
        this.HQStateDisabled = true;
        if (this.isStandard) {
            if (this.recordId) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: "Contact",
                        actionName: "view"
                    },
                });
            } else {
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Lead',
                        actionName: 'home',
                    },
                });
            }
        } else {
            this.dispatchEvent(new CustomEvent('closeTab', {
                detail: {
                    data: 'closeTab'
                }
            }));
        }
    }

    naviagteToExternalUrl() {
        let url = 'https://engage.shl.com/GCSCInboundSalesInquiry';
        window.open(url);
        this.closeModal();
    }

    validateFields() {
        return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
        }, true);
    }

    handleSubmitButtonClick() {
        this.isButtonDisabled = true;
        this.isCreated = true;
        let validatedFields = this.validateFields();
        this.validationError = validatedFields;
        if (validatedFields) {
            this.leadRecord['RecordTypeId'] = this.selectedValue;
            let leadRecList = [this.leadRecord];
            createLeadRecords({
                leadRecordList: leadRecList,
                profileName: this.profileName
            })
                .then((result) => {
                    if (!this.isStandard && this.recordId) {
                        //this.closeModal();
                    }
                    const updatedRecord = result;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: updatedRecord,
                            objectApiName: 'Lead',
                            actionName: 'view'
                        },
                        state: {}
                    }, {
                        target: '_self',
                    }
                    );
                    this.dispatchEvent(new CustomEvent('setTabName', {
                        detail: {
                            data: this.leadRecord['FirstName'] + ' ' + this.leadRecord['LastName'] + ' | Lead'
                        }
                    }));
                    this.updateContactRecordLocal();
                    this.isCreated = false;
                    this.isButtonDisabled = false;


                })
                .catch((error) => {
                    this.isButtonDisabled = false;
                    this.isCreated = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body ? error.body.message : error.message,
                            variant: 'error',
                            mode: 'sticky'
                        }),
                    );
                })
        } else {
            this.isButtonDisabled = false;
            this.isCreated = false;
        }
    }

    updateContactRecordLocal() {
        if (this.updateContact) {
            this.contactRecordToUpdate['Id'] = this.recordId;
            updateContactRecord({
                contact: this.contactRecordToUpdate
            })
                .then((result) => {
                    console.log('This is result '+result);
                })
                .catch(error => {
                    console.log('Error while updating contact from lead ' + JSON.stringify(error));
                })
        }
    }

    handleInputFieldChange(event) {
        let fieldName = event.target.fieldName;
        if (fieldName == 'Global_Lead_Country__c') {
            this.leadRecord[fieldName] = event.target.value;
            this.onCountryChange(event);
        }
        if (fieldName == 'HQStateName') {
            this.leadRecord['HQ_State_Province__c'] = event.target.value;
        } else if (fieldName == 'Name') {
            this.leadRecord['FirstName'] = event.target.value.FirstName;
            this.leadRecord['LastName'] = event.target.value.LastName;
            this.leadRecord['Salutation'] = event.target.value.Salutation;
        } else if (fieldName == 'Global_Lead_Country__c') {
            this.leadRecord['HQ_State_Province__c'] = '';
        } else if (fieldName == 'Area_of_Interest__c') {
            this.leadRecord['Eloqua_Description__c'] = 'This lead has been created internally by SHL using the new lead form. They are interested in  ' + event.target.value;
            this.leadRecord['Area_of_Interest__c'] = event.target.value;
            this.updateContact = true;
            this.contactRecordToUpdate['Area_of_Interest__c'] = event.target.value;
        } else if (fieldName == 'Phone') {
            this.leadRecord[fieldName] = event.target.value;
            this.updateContact = true;
            this.contactRecordToUpdate['Phone'] = event.target.value;
        } else if (fieldName == 'Email_Opted_In__c') {
            this.leadRecord[fieldName] = event.target.value;
            this.updateContact = true;
            if(event.target.value=='Yes'){
                this.contactRecordToUpdate['Do_Not_Contact__c'] = 'false'
            }
            else{
                this.contactRecordToUpdate['Do_Not_Contact__c'] = 'true';
                this.contactRecordToUpdate['Do_Not_Contact_Reason__c']='Customer Requested - no contact from anyone';
            }
        } else if (fieldName == 'Job_Level__c') {
            this.leadRecord[fieldName] = event.target.value;
            this.updateContact = true;
            this.contactRecordToUpdate['Job_Level__c'] = event.target.value;
        }
        else if (fieldName == 'Job_Function__c') {
            this.leadRecord[fieldName] = event.target.value;
            this.updateContact = true;
            this.contactRecordToUpdate['Job_Function__c'] = event.target.value;
        }
        else if (fieldName == 'Title') {
            this.leadRecord[fieldName] = event.target.value;
            this.updateContact = true;
            this.contactRecordToUpdate['Title'] = event.target.value;
        }
        else {
            this.leadRecord[fieldName] = event.target.value;
        }

    }

    onCountryChange(event) {

        this.HQStateValue = event.detail.value;
        if (this.HQStateValue == "UNITED STATES" || this.HQStateValue == "CANADA") {
            this.HQStateDisabled = false;
            if (this.HQStateValue == "UNITED STATES") {
                this.HQStateOptions = [
                    { label: 'Alabama', value: 'Alabama' }, { label: 'Alaska', value: 'Alaska' }, { label: 'Arizona', value: 'Arizona' },
                    { label: 'Arkansas', value: 'Arkansas' }, { label: 'California', value: 'California' }, { label: 'Colorado', value: 'Colorado' },
                    { label: 'Connecticut', value: 'Connecticut' }, { label: 'Delaware', value: 'Delaware' }, { label: 'District Of Columbia', value: 'District Of Columbia' },
                    { label: 'Florida', value: 'Florida' }, { label: 'Georgia', value: 'Georgia' }, { label: 'Hawaii', value: 'Hawaii' },
                    { label: 'Idaho', value: 'Idaho' }, { label: 'Illinois', value: 'Illinois' }, { label: 'Indiana', value: 'Indiana' },
                    { label: 'Iowa', value: 'Iowa' }, { label: 'Kansas', value: 'Kansas' }, { label: 'Kentucky', value: 'Kentucky' },
                    { label: 'Louisiana', value: 'Louisiana' }, { label: 'Maine', value: 'Maine' }, { label: 'Maryland', value: 'Maryland' },
                    { label: 'Massachusetts', value: 'Massachusetts' }, { label: 'Michigan', value: 'Michigan' }, { label: 'Minnesota', value: 'Minnesota' },
                    { label: 'Mississippi', value: 'Mississippi' }, { label: 'Missouri', value: 'Missouri' }, { label: 'Montana', value: 'Montana' },
                    { label: 'Nebraska', value: 'Nebraska' }, { label: 'Nevada', value: 'Nevada' }, { label: 'New Hampshire', value: 'New Hampshire' },
                    { label: 'New Jersey', value: 'New Jersey' }, { label: 'New Mexico', value: 'New Mexico' }, { label: 'New York', value: 'New York' },
                    { label: 'North Carolina', value: 'North Carolina' }, { label: 'North Dakota', value: 'North Dakota' }, { label: 'Ohio', value: 'Ohio' },
                    { label: 'Oklahoma', value: 'Oklahoma' }, { label: 'Oregon', value: 'Oregon' }, { label: 'Pennsylvania', value: 'Pennsylvania' },
                    { label: 'Puerto Rico', value: 'Puerto Rico' }, { label: 'Rhode Island', value: 'Rhode Island' }, { label: 'South Carolina', value: 'South Carolina' },
                    { label: 'South Dakota', value: 'South Dakota' }, { label: 'Tennessee', value: 'Tennessee' }, { label: 'Texas', value: 'Texas' },
                    { label: 'Utah', value: 'Utah' }, { label: 'Vermont', value: 'Vermont' }, { label: 'Virgin Islands', value: 'Virgin Islands' },
                    { label: 'Virginia', value: 'Virginia' }, { label: 'Washington', value: 'Washington' }, { label: 'West Virginia', value: 'West Virginia' },
                    { label: 'Wisconsin', value: 'Wisconsin' }, { label: 'Wyoming', value: 'Wyoming' }
                ];
            } else {
                this.HQStateOptions = [
                    { label: 'Alberta', value: 'Alberta' }, { label: 'British Columbia', value: 'British Columbia' }, { label: 'Manitoba', value: 'Manitoba' },
                    { label: 'New Brunswick', value: 'New Brunswick' }, { label: 'Newfoundland and Labrador', value: 'Newfoundland and Labrador' }, { label: 'Nova Scotia', value: 'Nova Scotia' },
                    { label: 'Northwest Territories', value: 'Northwest Territories' }, { label: 'Nunavut', value: 'Nunavut' }, { label: 'Ontario', value: 'Ontario' },
                    { label: 'Prince Edward Island', value: 'Prince Edward Island' }, { label: 'Quebec', value: 'Quebec' }, { label: 'Saskatchewan', value: 'Saskatchewan' },
                    { label: 'Yukon Territory', value: 'Yukon Territory' }, { label: 'Other', value: 'Other' }
                ];
            }
        } else {
            this.HQStateDisabled = true;
            this.HQStateValue = null;
        }
    }

    getAppDefinationName() {
        getAppDefination()
            .then((result) => {
                const updatedRecord = result;
                if (updatedRecord == 'Console') {
                    this.isStandard = false;
                } else {
                    this.isStandard = true;
                }
                this.showRecordForm = true;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body ? error.body.message : error.message,
                        variant: 'error',
                        mode: 'sticky'
                    }),
                );
            })
    }


}