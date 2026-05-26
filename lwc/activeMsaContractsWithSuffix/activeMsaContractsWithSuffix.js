import { LightningElement, api } from 'lwc';
import getAccountNames from '@salesforce/apex/ContractAccountHelper.getAccountNames';

export default class ActiveMsaContractsWithSuffix extends LightningElement {
    @api activeContractsFromFlow = [];
    activeContracts = [];

    connectedCallback() {
        let url = window.location.origin;
        const contractIds = this.activeContractsFromFlow.map(c => c.Id);

        getAccountNames({ contractIds })
            .then(accountMap => {
                console.log("Priyank Inside component");
                const contracts = [];
                this.activeContractsFromFlow.forEach(element => {
                    let contract = {};
                    contract.linkToMsa = url + '/' + element.Id;
                    contract.contractNumber = element.ContractNumber;
                    contract.MSATitle = element.MSA_Title__c;
                    contract.startDate = element.StartDate;
                    contract.endDate = element.Contract_End_Date__c;

                    if (element.MSA_R_G_Status_indicator__c) {
                        contract.MSARGIndicator = element.MSA_R_G_Status_indicator__c.substring(
                            element.MSA_R_G_Status_indicator__c.indexOf('src="') + 5,
                            element.MSA_R_G_Status_indicator__c.indexOf('" alt')
                        );
                    } else {
                        contract.MSARGIndicator = element.MSA_R_G_Status_indicator__c;
                    }

                    contract.accountName = accountMap[element.Id] || '—';
                    contract.accountLink = url + '/' + element.AccountId;
                    contracts.push(contract);
                    console.log('Priyank Contract:', contract);
                });
                this.activeContracts = contracts;
                console.log('Priyank COntracts '+JSON.stringify(this.activeContracts));
            })
            .catch(error => {
                console.error('Error fetching account names:', error);
            });
    }
}