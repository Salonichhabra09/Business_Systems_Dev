import { LightningElement, api, wire, track } from 'lwc';
import getRequiredLookupRecords from '@salesforce/apex/CustomLookupController.getRequiredLookupRecords';


export default class CustomLookupComponent extends LightningElement {

    @api objectName;
    @api preSelectedName;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder = 'Search';
    @api label = '';
    @api isRequired;
    @api inputClassFromParent;
    @api accountPlanId = '';
    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    @api isDisabled;
    itemToSearch;
    @api indexVal;
    indexToSend;


    @wire(getRequiredLookupRecords, { itemToSearch: '$itemToSearch', objectName: '$objectName', filter: '$filter', accountPlanId: '$accountPlanId' })
    getRequiredLookupRecords({ error, data }) {
        if (data) {
            console.log('data: ', data);
            this.error = undefined;
            this.records = data;
        } else if (error) {
            console.log('error: ', error);
            this.error = error;
            this.records = undefined;
        }
    }

    get hideCloseButton() {
        return !(this.isDisabled);
    }

    connectedCallback() {
        if (this.preSelectedName) {
            this.selectedName = this.preSelectedName;
            this.isValueSelected = true;
        }
        var css = this.template.host.style;
        if (this.label == '') {
            css.setProperty('--topMargin', '50%');
            css.setProperty('--inputFieldWidth', '140px');
        }
    }

    handleClick(event) {
        this.itemToSearch = '';
        //this.inputClass = 'slds-has-focus input-required';
        this.inputClass = this.inputClassFromParent;
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';

        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        this.indexToSend = key;
    }

    onBlur() {
        this.blurTimeout = setTimeout(() => { this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus' }, 300);
        let input;
        if (this.objectName == 'Contact') {
            input = this.template.querySelector(".input-contact");
        } else {
            input = this.template.querySelector(".input-strategy");
        }
        if (!this.isValueSelected) {
            input.setCustomValidity("Complete this field");
        } else {
            input.setCustomValidity(""); // clear previous value
        }
        input.reportValidity();
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', { detail: selectedId });
        //const valueSelectedEvent = new CustomEvent('lookupselected', { detail: { data: selectedId } });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    onSelectAura(event) {
        console.log('onSelectAura: ');
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        let indexId = this.indexToSend;
        console.log('indexId: ', indexId);
        //const valueSelectedEvent = new CustomEvent('lookupselected', { detail: selectedId });
        const valueSelectedEvent = new CustomEvent('lookupselected', { detail: { projectId: selectedId, indexId: indexId } });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.isValueSelected = false;
        this.itemToSearch = '';
        this.selectedName = '';
        const valueUnSelectedEvent = new CustomEvent('lookupunselect');
        this.dispatchEvent(valueUnSelectedEvent);
    }

    handleRemovePillAura(event) {
        this.isValueSelected = false;
        this.itemToSearch = '';
        this.selectedName = '';
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        this.indexToSend = key;
        console.log('key: ', key);
        const valueUnSelectedEvent = new CustomEvent('lookupunselect', { detail: { indexId: key } });
        this.dispatchEvent(valueUnSelectedEvent);
    }

    onChange(event) {
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        console.log('key: ', key);
        this.itemToSearch = event.target.value;
        this.indexToSend = key;
    }

    @api
    handleRequiredFieldValidation(type) {

        let inputForContact;
        let inputForStrategy;
        this.inputClass = this.inputClassFromParent;
        if (type == 'contact') {
            console.log('inside contact');
            inputForContact = this.template.querySelector(".input-contact");
            inputForContact.setCustomValidity("Complete this field");
            inputForContact.reportValidity();
        }
        if (type == 'strategy') {
            console.log('inside strategy');

            inputForStrategy = this.template.querySelector(".input-strategy");
            inputForStrategy.setCustomValidity("Complete this field"); // clear previous value
            inputForStrategy.reportValidity();
        }
    }
}