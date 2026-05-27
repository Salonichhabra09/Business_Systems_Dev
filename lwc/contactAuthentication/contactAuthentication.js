import { LightningElement, api, wire, track } from 'lwc';
import authenticateContact from '@salesforce/apex/CustomerRequestController.authenticateContact';
import WRF_Footer from '@salesforce/label/c.WRF_Footer';
export default class ContactAuthentication extends LightningElement {
    label = {
        WRF_Footer
    };
    @api recordId;
    //AccountDNumber='';
    Submittername='';
    Submitteremail='';
    errorMsg='';
    successMSG ='';
    showSpinner=false;

   

    handleClick(){
       
        this.showSpinner=true;
        this.Submittername = this.template.querySelector("lightning-input[data-id=Submittername]").value;
        this.Submitteremail = this.template.querySelector("lightning-input[data-id=Submitteremail]").value;
              
        authenticateContact({Submittername:this.Submittername,Submitteremail:this.Submitteremail,recordId:this.recordId}).then(Response =>{
            if(Response=='Success'){
                //console.log('Contact Found');
                this.showSpinner=false;
                const eve = new CustomEvent('authentication',{
                    detail:{
                    status : 'Success',
                    name : this.Submittername,
                    email : this.Submitteremail
                }
                })
                this.dispatchEvent(eve);
                this.successMSG = 'Authentication Successful!';
                this.errorMsg ='';
            }
            else if(Response =='BlankValues'){
                this.showSpinner=false;
                this.errorMsg = 'Please add details before verifying credentials.';
                this.successMSG =''; 
            }
            else {
            this.showSpinner=false;
            this.errorMsg = 'Error: Please enter correct Name and Email Address.';
            this.successMSG ='';
            }
        })
        .catch(error =>{
            //console.log('Error '+JSON.stringify(error));
            this.showSpinner=false;
            const eve = new CustomEvent('authentication',{
                detail:{
                    status: 'Failure'}
            })
            this.dispatchEvent(eve);
            this.errorMsg = 'System Error! Please contact the system admin.';
            this.successMSG ='';
        })

}
}