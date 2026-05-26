import { LightningElement,wire,api } from 'lwc';
import getAddressAndTaxType from '@salesforce/apex/MarkInactiveAddressAndTaxController.getAddressAndTaxType';
import markInactive from '@salesforce/apex/MarkInactiveAddressAndTaxController.markInactive';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from "lightning/refresh";
import { NavigationMixin } from 'lightning/navigation';

export default class MarkAddressAndTaxAsInactive extends NavigationMixin(LightningElement) {

    @api recordId;
    data;
    error;
    message = '';
    showSpinner = true;

    @wire(getAddressAndTaxType,({recordId:'$recordId'}))
    wiredData({ error, data }) {
    if (data) {
      this.showSpinner = false;
      this.message = data;
      this.error = undefined;
    } else if (error) {
      this.showSpinner = false;
      this.error = error;
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
    }
  }

  handleMarkInactive(){
    this.showSpinner = true;
    markInactive({recordId : this.recordId}).then(Response => {
        if(Response=='Success'){ 
            const event = new ShowToastEvent({
                title: 'Success!',
                message:'Marked inactive successfully',
                variant:'success'
            });
            this.dispatchEvent(event);
        }
        else{
            const event = new ShowToastEvent({
                title: 'Error!',
                message:Response,
                variant:'error'
            });
            this.dispatchEvent(event);
        }  
    this.handleClose();
       
    }).catch(error => {
        let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
        const event = new ShowToastEvent({
            title: 'Error!',
            message:message,
            variant:'error'
        });
        this.dispatchEvent(event);
        this.handleClose();
    });
    }

  handleClose(){
    this.showSpinner = false;
    this.dispatchEvent(new CloseActionScreenEvent());
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            actionName: 'view'
        }
    }).then((url) => {
        window.location.href = url;
    });
  }

  
}