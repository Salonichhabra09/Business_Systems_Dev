import { LightningElement, api} from 'lwc';

export default class ClientResponse extends LightningElement {
    //accountId;
    //textUnderLogo;
    //candidateData;
    @api customFields;
    colamsize = "12";
    @api accountLogo;
    @api clientName;


   /* @wire(getRecord, {
        recordId: "$recordId",
        fields: [ACCOUNTID_FIELD, SYSTEM_FIELD, TEXT_UNDER_LOGO_FIELD, CANDIDATE_FIELD_CONFIGURATION, FIELD_CONFIGURATION],
    })
    workRequest({ error, data }) {
        if (error) {
            console.log('WIRE ERROR ' + JSON.stringify(error));
        }
        else if (data) {
            
            this.accountId = getFieldValue(data, ACCOUNTID_FIELD);
            console.log('WIRE ID ' + getFieldValue(data, ACCOUNTID_FIELD));
            this.textUnderLogo = getFieldValue(data, TEXT_UNDER_LOGO_FIELD);
            console.log('WIRE ID ' + getFieldValue(data, TEXT_UNDER_LOGO_FIELD));
            //this.candidateData = JSON.parse(getFieldValue(data, CANDIDATE_FIELD_CONFIGURATION));
            //console.log('WIRE ID ' + getFieldValue(data, CANDIDATE_FIELD_CONFIGURATION));
            this.customFields = JSON.parse(getFieldValue(data, FIELD_CONFIGURATION));
            console.log('WIRE ID ' + getFieldValue(data, FIELD_CONFIGURATION));
            //this.handleVisibility();
            console.log('this.formData: ', JSON.stringify(this.customFields));
            getAccountLogo({evaluatorId : this.accountId})
        .then(result =>{
            this.AccountLogo = result; 
            console.log('DATA from imperetive '+this.AccountLogo);
        })
        .catch(error =>{
            console.log('Error '+error);
        })

        }
    } */

  /*  @wire(getAccountLogo, { evaluatorId: '$accountId' })
    idPhotoDetails({ data, error }) {
        if (data) {
            this.AccountLogo = data;
            console.log('Account Logo '+this.AccountLogo);
        } else if (error) {
            console.log('error '+JSON.stringify(error));
        }
    }*/
}