import { LightningElement, api } from 'lwc';

export default class InputText extends LightningElement {

    @api value;
    @api context;
    @api disabled;

    connectedCallback() {
        this.dispatchEvent(new CustomEvent('inputload', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
    }

    handleChange(event) {
        //show the selected value on UI
        this.value = event.target.value;
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('inputchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
    }
}