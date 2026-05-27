import { LightningElement, api, track } from 'lwc';
import getOrderData from '@salesforce/apex/GenericClassToGetData.getOrderData';

const columnsToDisplayOrderDetails = [
    {
        label: 'Order Number', fieldName: 'orderRecordId', type: 'url',
        typeAttributes: { label: { fieldName: 'OrderNumber' }, target: '_blank' }
    },
    {
        label: 'Status', fieldName: 'orderValueData',
    },
    {
        label: 'OAT Status', fieldName: 'Oats_Status__c',
    },
    {
        label: 'Order Start Date', fieldName: 'EffectiveDate', type: 'date-local',
        typeAttributes: { day: '2-digit', month: '2-digit', year: 'numeric'},
    },
    {
        label: 'Booking Date', fieldName: 'Booking_Date__c',  type: 'date-local',
        typeAttributes: { day: '2-digit', month: '2-digit', year: 'numeric'},
    },
    {
        label: 'Total Order Value', fieldName: 'TotalAmount', type: 'currency',
        typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: 'code'},
        cellAttributes: { alignment: 'left'},
    },
];

export default class GenericComponentToDisplayDataUsingDataTable extends LightningElement {

    @api recordId;
    columns = columnsToDisplayOrderDetails;
    data = [];
    filterValue;
    @track showLoadingSpinner;
    @track dataCount = 0;
    @track tableHeader;

    connectedCallback(){
        this.getOrderData();
    }

    getOrderData() {
        this.tableHeader = 'Orders (' + this.dataCount + ')';
        getOrderData({ jobId: this.recordId, offSetValue: 0, filterValue: this.filterValue })
            .then(result => {
                this.showLoadingSpinner = false;
                var tempData = [];
                tempData = result;
                let tempRecords = JSON.parse(JSON.stringify(result));
                let isoCode;
                let orderValueISO;
                let statusValue;
                tempRecords = tempRecords.map((row,index) => {

                    isoCode = row.CurrencyIsoCode;
                    orderValueISO = isoCode + ' ' + row.TotalAmount;

                    if(row.Status == 'In Approval'){
                        statusValue = 'Under Review';
                    }else if(row.Status == 'Activated'){
                        statusValue = 'Fully Activated';
                    }else{
                        statusValue = row.Status;
                    }
                    
                    return {
                        ...row,
                        orderRecordId: (row ? ('/lightning/r/Order/' + row.Id+'/view') : null),
                        orderValueData: statusValue
                    };
                })
                console.log('tempRecords ====> ' + JSON.stringify(tempRecords));
                this.data = tempRecords;
                this.dataCount = this.data.length;
                this.tableHeader = 'Orders (' + this.dataCount + ')';
            })
            .catch(error => {
                console.log('error ====> ', error);
            });
    }

}