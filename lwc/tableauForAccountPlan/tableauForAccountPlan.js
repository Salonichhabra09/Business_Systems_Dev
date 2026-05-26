import { LightningElement,api,wire } from 'lwc';
import dashboardUrl from '@salesforce/label/c.Tableau_URL_for_Account_Plan';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import BUYING_CENTRE_ID_AP from '@salesforce/schema/Account_Plan__c.Account_Name__r.Buying_Centre_Id__c';
import BUYING_CENTRE_ID from '@salesforce/schema/Account.Buying_Centre_Id__c';

const FIELDS = [BUYING_CENTRE_ID_AP,BUYING_CENTRE_ID];   

export default class TableauForAccountPlan extends LightningElement {

    @api recordId;
    @api objectApiName;
    tableauDashboardUrl ='';
    activeSections='';
    showDashboard = false;
    iconName = 'utility:chevronright';
    record;

    @wire(getRecord, { recordId: '$recordId', optionalFields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in Usage Details ',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.record = data;
            let buyingCentreId;
            if(this.objectApiName!='Account'){
                buyingCentreId = this.record.fields.Account_Name__r.value.fields.Buying_Centre_Id__c.value;
            }else{
                buyingCentreId = this.record.fields.Buying_Centre_Id__c.value;

            }
            //buyingCentreId = buyingCentreId?buyingCentreId.replaceAll(',','%5C%2C'):buyingCentreId;
            let url = dashboardUrl;
            url = url+'?&:refresh=y&Buying%20Centre%2FId='+encodeURI(buyingCentreId);
            this.tableauDashboardUrl = url.replaceAll(',','%5C%2C');
        }
    }

    handleDashboardVisibility(){
        this.showDashboard = this.showDashboard?false:true;
        this.iconName = this.showDashboard?'utility:chevrondown':'utility:chevronright';
    }
}