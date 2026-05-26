import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReportFilterSelector extends LightningElement {
    @api message = []; // Receiving field names from Parent
    @api system // Receiving system value from Parent
    @track selectedFields = [];
    fields = [];

    // Static lists for different filter fields
    TCFilterFields = ['First Name', 'Email', 'TC Status'];
    MFSFilterFields = ['Rater Type', 'Participant Email', 'Respondent Email','MFS Status','MFS Report Sent'];
    CombinedFilterFields = ['Rater Type', 'Participant Email', 'Respondent Email','MFS Status','MFS Report Sent','Overall Status(MFS + TC)'];

    connectedCallback() {
        if (this.message && this.system) {
            this.parsedData = JSON.parse(JSON.stringify(this.message));

            this.parsedData.forEach(element => {
                // Reset selection
                element.selected = false;

                // Check system value and update selection accordingly
                if (this.system?.includes('TalentCentral') && !this.system?.includes('MFS') && this.TCFilterFields.includes(element.label)) {
                    element.selected = true;
                } else if (this.system?.includes('MFS') && !this.system?.includes('TalentCentral') && this.MFSFilterFields.includes(element.label)) {
                    element.selected = true;
                } else if (this.system?.includes('TalentCentral') && this.system?.includes('MFS') && this.CombinedFilterFields.includes(element.label)) {
                    element.selected = true;
                }
                if(element.selected){
                    this.selectedFields = [...this.selectedFields, element];
                }    
            });
            this.sendDataToParent();
            console.log('Fields for filter:', JSON.stringify(this.parsedData));
        }
    }

    handleCheckboxChange(event) {
        const fieldName = event.target.label;
        const isChecked = event.target.checked;
        let alldata = JSON.parse(JSON.stringify(this.message));

        console.log('Field selected:', fieldName);

        // Update the `isSelected` property in the fields array
        if (isChecked) {
            if (this.selectedFields.length >= 10) {
                event.target.checked = false; // Uncheck the latest selection
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Validation Error',
                        message: 'You can select up to 10 fields only.',
                        variant: 'error',
                        mode: 'auto'
                    })
                );
                return;
            }
            const selectedItem = alldata.find(item => item.label === fieldName);
            if (selectedItem) {
                console.log('Inside selected item');
                this.selectedFields = [...this.selectedFields, selectedItem];
            }
        } else {
            // Remove the field from the selected list if unchecked
            this.selectedFields = this.selectedFields.filter(item => item.label !== fieldName);
        }

        console.log('Selected Fields:', JSON.stringify(this.selectedFields));
        this.sendDataToParent();
    }

    sendDataToParent() {
        const saveEvent = new CustomEvent('save', {
            detail: this.selectedFields  // Sending input data back to parent
        });
        this.dispatchEvent(saveEvent);
    }
}