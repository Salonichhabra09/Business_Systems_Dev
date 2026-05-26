import { LightningElement,api,wire } from 'lwc';
import getOpportunitiesYearWiseWithCI from '@salesforce/apex/ChartsOnAccountPlanController.getOpportunitiesYearWiseWithCI';
import { NavigationMixin } from 'lightning/navigation';
import reportId from '@salesforce/label/c.History_Trend_Based_On_Client_Interest_Report_Id';

export default class CIientInterestGraphOnAccountPlan extends NavigationMixin(LightningElement) {

    @api recordId;
    chartConfigurationForYearWise;
    accountId;


    @wire(getOpportunitiesYearWiseWithCI,({accountPlanId:'$recordId'}))
    getOpportunitiesYearWise({ error, data }) {
        if (error) {
            this.error = error;
            this.chartConfigurationForYearWise = undefined;
        } else if (data) {
            let tAData =[];
            let tMData =[];
            let chartLabel = [];
            let dataForChart = data.dataMap;
            let dataForChart1 = data.dataMap1;
            this.accountId = data.accountId;
            for (let key in dataForChart) {
                tAData.push(dataForChart[key]);
                tMData.push(dataForChart1[key]);
                chartLabel.push(key);
            };
            this.chartConfigurationForYearWise = {
                type: 'bar',
                data: {
                    datasets: [{
                        label: 'Talent Acquisition',
                        backgroundColor: "rgba(82, 183, 216, 1)",
                        data: tAData,
                        borderColor:"rgba(82, 183, 216, 1)",
                        borderWidth:1,
                        stack:'1',
                    },{
                        label: 'Talent Management',
                        backgroundColor: "rgba(32, 6, 71, 1)",
                        data: tMData,
                        borderColor:"rgba(32, 6, 71, 1)",
                        borderWidth:1,
                        stack:'1',
                    }],
                    labels: chartLabel,
                },
                options: {
                    legend: {
                        display:false
                    },
                        title: {
                            display: true,
                            text: 'Amount in USD',
                            position:'bottom'
                        }
                }
            };
            this.error = undefined;
        }
    }

    navigateToReport(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: reportId,
                objectApiName: 'Report',
                actionName: 'view'
            },
            state: {
                fv1: this.accountId
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }
}