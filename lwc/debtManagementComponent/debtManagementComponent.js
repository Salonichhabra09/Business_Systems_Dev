import { LightningElement,api,wire } from 'lwc';
import getDebtInformation from '@salesforce/apex/DebtManagementController.getDebtInformation';
import debt_icon_amber from '@salesforce/resourceUrl/Amber_Status_Icon';
import debt_icon_red from '@salesforce/resourceUrl/Red_Status_Icon';
import debt_icon_green from '@salesforce/resourceUrl/Green_Status_Icon';

export default class DebtManagementComponent extends LightningElement {

    @api recordId;
    @api objectApiName;
    debtInformation;
    error;
    debtStatusIcon;
    isHighRisk;
    isRisk;
    debtDetail;
    isOpenDebtDetails = false;
    numberOfOpportunities = 0;
    isClickMoreVisible = false;
    isOrder;
    isOrderInDebt;
    debtMessageOrderClass;
    formatter = new Intl.NumberFormat('en-US', {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2
                    });

    @wire(getDebtInformation, { recordId: '$recordId', objectApiName: '$objectApiName' })
    wiredData({ error, data }) {
        if (data) {
            this.debtInformation = JSON.parse(JSON.stringify(data));
            this.debtInformation.unpaidAmount = this.debtInformation.accountCurrency +' '+ this.formatter.format(this.debtInformation.unpaidAmount);
            if(this.debtInformation.debtStatus == 'Red'){
                this.debtStatusIcon = debt_icon_red;
                this.isHighRisk = true;
                this.isClickMoreVisible = this.objectApiName == 'Account';
                this.isRisk = true;
            }else if(this.debtInformation.debtStatus == 'Amber'){
                this.debtStatusIcon = debt_icon_amber;
                this.isRisk = true;
            }else{
                this.debtStatusIcon = debt_icon_green;
            }

            if(this.objectApiName == 'Order'){
                    this.isOrder = true;
                    if(this.debtInformation.debtStatus == 'Red'){
                        this.debtMessageOrderClass = 'high-risk-order';
                    }else if(this.debtInformation.debtStatus == 'Amber'){
                        this.debtMessageOrderClass = 'moderate-risk-order';
                    }else{
                        this.debtMessageOrderClass = 'low-risk-order';
                    }
                }
            if(this.objectApiName == 'Account' && this.debtInformation.opportunityDetailsMap){
                this.debtDetail = Object.entries(this.debtInformation.opportunityDetailsMap).map(([oppNumber, invoices]) => {
                return {
                    id: oppNumber,
                    name: oppNumber,
                    link: `/lightning/r/Opportunity/${invoices[0].Order__r.OpportunityId}/view`,
                    invoices: invoices.map(inv => ({
                        id: inv.Id,
                        name: inv.Name,
                        unpaidAmount: inv.CurrencyIsoCode+' '+this.formatter.format(inv.Unpaid_Amount__c),
                        status: inv.Debt_Status__c.includes('Red') ? debt_icon_red : debt_icon_amber,
                        statusMessage: inv.Debt_Status__c.includes('Red') ? 'High Risk' : 'Moderate Risk',
                        dueDate: inv.Invoice_Due_Date__c,
                        invoiceLink: `/lightning/r/Contract_Invoice_Header__c/${inv.Id}/view`
                    }))
                };
            });
                this.numberOfOpportunities = this.debtDetail.length;
            }
            this.error = undefined;
            console.log(this.debtInformation);
        } else if (error) {
            this.error = error;
            this.debtInformation = undefined;
        }
    }

    openDebtDetails(){
        this.isOpenDebtDetails = true;
    }

    closeDebtDetails(){
        this.isOpenDebtDetails = false;
    }
}