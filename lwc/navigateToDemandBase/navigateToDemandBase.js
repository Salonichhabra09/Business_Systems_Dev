import { LightningElement } from 'lwc';
import Demandbase_Sales_Intelligence_Url from '@salesforce/label/c.Demandbase_Sales_Intelligence_Url';
import { NavigationMixin } from 'lightning/navigation';
export default class NavigateToDemandBase extends NavigationMixin(LightningElement) {

    connectedCallback(){
        this.handleOpenExternalLink();
    }

    handleOpenExternalLink(){

        setTimeout(() => {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: Demandbase_Sales_Intelligence_Url
                },
                state: {
                    target: '_blank'
                }
            });
        }, 3000);
    }

}