import { LightningElement,api } from 'lwc';

export default class ActiveMsaContractsOnAccount extends LightningElement {

@api activeContractsFromFlow=[];
activeContracts=[];

connectedCallback(){
    let url = window.location.origin;
    this.activeContractsFromFlow.forEach(element => {
        let contract = {};
        contract.linkToMsa = url + '/' + element.Id;
        contract.contractNumber = element.ContractNumber;
        contract.MSATitle = element.MSA_Title__c; //Change added for SSE-20458
				contract.startDate = element.StartDate; //Change added for SSE-20458
				contract.endDate = element.Contract_End_Date__c;
                //Changes added for SSE-20458
                if(element.MSA_R_G_Status_indicator__c){
                    contract.MSARGIndicator = element.MSA_R_G_Status_indicator__c.substring(element.MSA_R_G_Status_indicator__c.indexOf('src="')+5,element.MSA_R_G_Status_indicator__c.indexOf('" alt'));
                }else{
                    contract.MSARGIndicator = element.MSA_R_G_Status_indicator__c;
                }
        this.activeContracts.push(contract);
    });}
}