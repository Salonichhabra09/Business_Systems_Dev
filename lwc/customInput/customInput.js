import { LightningElement, api } from 'lwc';

export default class CustomInput extends LightningElement {

    @api value;
    @api recordId;
    @api type;
    @api isDisabled;
    currentValue;
    step;
    isTopUp;

    connectedCallback() {
        // if(this.type=='quantity'){
        //     this.step = 0.01;
        // }else if(this.type == 'solutionCap'){
        //     this.step = 0;
        // }else{
        //     this.step = 0.00000001;
        // }

        if (this.type == 'solutionCap') {
            this.step = 0;
        } else if (this.type == 'solutionCapTopUp') {
            this.step = 0;
            this.isTopUp = true;
        } else {
            this.step = 0.01;
        }
    }
    handleChange(event) {
        let currentValue = event.target.value;
        let validity = event.target.checkValidity();
        if (currentValue == null) {
            currentValue = 1;
        }
        if (Number.isFinite(Number(currentValue))) {
            this.dispatchEvent(new CustomEvent('updatevalue', { bubbles: true, composed: true, detail: { currentValue: currentValue, type: this.type, recordId: this.recordId, validity: validity } }));
        }
    }

    handleChangeTopUp(event) {
        let currentValue = event.target.value;
        let validity = event.target.checkValidity();
        this.dispatchEvent(new CustomEvent('updatevalue', { bubbles: true, composed: true, detail: { currentValue: currentValue, type: this.type, recordId: this.recordId, validity: validity } }));
    }
}