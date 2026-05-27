import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class OpenMasterViewNewTab extends NavigationMixin(LightningElement) {
    @api recordId;
    navigateToComponent() {
        this.dispatchEvent(new CloseActionScreenEvent());
        this[NavigationMixin.GenerateUrl]({
          // Pass in pageReference
          type: 'standard__component',
          attributes: {
            componentName: 'c__masterProgressReportView',
          },
          state: {
            c__recordId: this.recordId,
          },
        }).then(url => {
            window.open(url, "_blank");
        });
      }
      

      connectedCallback() {

        setTimeout(() => {
            console.log('this.recordId: ', this.recordId);
            this.navigateToComponent();
        }, 1000);

        console.log('connectedcall--', this.recordId);
        
      }
}