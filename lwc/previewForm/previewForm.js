import { LightningElement, api,wire } from 'lwc';
import getAccountLogo from '@salesforce/apex/CustomerRequestController.relatedFiles';

export default class PreviewForm extends LightningElement {
    @api allvalue;
    @api accountId;
    colamsize = "12";
    AccountLogo;
    @api textUnderLogo;

    connectedCallback(){
        //console.log("INSIDE PREVIEW "+this.accountId);
        getAccountLogo({evaluatorId : this.accountId})
        .then(result =>{
            this.AccountLogo = result; 
            //console.log('DATA from imperetive '+this.AccountLogo);
        })
        .catch(error =>{
            //console.log('Error '+error);
        })
    }
   /* @wire(getAccountLogo, { evaluatorId : '$accountId' })
    idPhotoDetails({ data, error }){
    if (data) {
        this.AccountLogo = data; 
        //console.log('DATA from WIRE '+this.AccountLogo);
     }else if(error){
    }
}*/
}