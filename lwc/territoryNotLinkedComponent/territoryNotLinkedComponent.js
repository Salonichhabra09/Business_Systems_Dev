import { LightningElement,wire,api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Account_Territory_Field from "@salesforce/schema/Opportunity.Account.Territory__c";
import Account_Territory_Active_Field from "@salesforce/schema/Opportunity.Account.Territory__r.Is_Active__c";
import Account_Territory_Name_Field from "@salesforce/schema/Opportunity.Account.Territory__r.Name";

export default class TerritoryNotLinkedComponent extends LightningElement {

   @api recordId;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            Account_Territory_Field,
            Account_Territory_Active_Field,
            Account_Territory_Name_Field
        ]
    })
	
    wireAccount({ data, error }) {
		

	
    if(data) {
	const territoryName = data.fields.Account?.value?.fields?.Territory__r?.value?.fields?.Name?.value;
	
	//const isUnassigned = territoryName && territoryName.includes('UNASSIGNED');

 // const isUnassigned = territoryName && territoryName.toLowerCase().includes('unassigned');

  const isUnassigned = territoryName && /\bunassigned\b/i.test(territoryName);


      if(isUnassigned || data.fields.Account.value.fields.Territory__c.value==null || data.fields.Account.value.fields.Territory__r.value.fields.Is_Active__c.value==false){
        this.dispatchEvent(
            new ShowToastEvent({
              title: "This opportunity's account has  inactive , missing OR Unassigned territory. Please assign an active territory to the account before proceeding.",
              //message: "The account linked to this opportunity has no territory assigned. Please assign it before proceeding with the opportunity.",
              variant: "warning",
              mode:"Sticky"
            }),
          );
  }
}
    }
}