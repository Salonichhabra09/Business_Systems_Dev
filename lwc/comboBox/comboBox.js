import { LightningElement, api, wire, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LANGUAGE_FIELD from '@salesforce/schema/Bureau_System__c.Report_Language__c';

export default class ComboBox extends LightningElement {

    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @track languageList;

    connectedCallback() {
        console.log('Values#####',this.value)
        this.dispatchEvent(new CustomEvent('picklistload', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: LANGUAGE_FIELD })
    picklistValue({ data, error }) {
        this.languageList =undefined;
        if(data) {
            try {
                this.languageList = [{label: '--None--', value: '--None--'}, ...data.values ];
             }
             catch (error) {
                console.log('Error on PP Catch' + error);
             }
        }
    }

    handleChange(event) {
        //show the selected value on UI
        this.value = event.target.value;
        console.log('Event Value ####', event.target.value)
        console.log('Picklist Changed')
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
    }

    clicked() {
        alert('Clicked')
    }
}