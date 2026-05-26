import { LightningElement,api,wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { getRecord} from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Job__c.Name";
import Account_FIELD from "@salesforce/schema/Job__c.Account__c";

const fields = [NAME_FIELD,Account_FIELD] ;

export default class NavigateToWRFTabPage extends NavigationMixin(LightningElement) {
    @api recordId;
    
    @wire(getRecord, {
        recordId: "$recordId",
        fields
      })
      getJobDetails({ error, data }){
        if(data){
            this[NavigationMixin.Navigate]({
                type: "standard__navItemPage",
                attributes: {
                  apiName: "Work_Request_Form",
                },
                state: {
                    c__recordId: this.recordId,
                    c__jobNumber: data.fields.Name.value,
                    c__accountId: data.fields.Account__c.value
                },
              });
        }
        else if(error){
            //console.log('Error '+JSON.stringify(error));
        }      
      };
}