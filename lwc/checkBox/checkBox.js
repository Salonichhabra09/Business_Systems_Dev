import { LightningElement, api } from 'lwc';

export default class CheckBox extends LightningElement {

    @api ischecked;

    connectedCallback() {
        console.log('this.ischecked#####'+this.ischecked)
        //this.template.querySelector('lightning-input.cb').checked = this.ischecked;
    }
}