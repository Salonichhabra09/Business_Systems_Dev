import { LightningElement,wire,api } from 'lwc';
import getOpportunitiesYearWise from '@salesforce/apex/ChartsOnAccountPlanController.getOpportunitiesYearWise';
import { NavigationMixin } from 'lightning/navigation';
import reportId from '@salesforce/label/c.Year_Wise_Trend_Report_Id';

export default class YearWiseTrendOnAccountPlan extends NavigationMixin(LightningElement) {

    @api recordId;
    chartConfigurationForYearWise;
    accountId;


    @wire(getOpportunitiesYearWise,({accountPlanId:'$recordId'}))
    getOpportunitiesYearWise({ error, data }) {
        if (error) {
            this.error = error;
            this.chartConfigurationForYearWise = undefined;
        } else if (data) {
            let oppData =[];
            let chartLabel = [];
            let dataForChart = data.dataMap;
            this.accountId = data.accountId;
            for (let key in dataForChart) {
                oppData.push(dataForChart[key]);
                chartLabel.push(key);
            };
            this.chartConfigurationForYearWise = {
                type: 'bar',
                data: {
                    datasets: [{
                        backgroundColor: "rgba(82, 183, 216, 1)",
                        data: oppData,
                        borderColor:"rgba(82, 183, 216, 1)",
                        borderWidth:1,
                        fill:'false',
                    },],
                    labels: chartLabel,
                },
                options: {
                        title: {
                            display: true,
                            text: 'Amount in USD',
                            position:'bottom'
                        },
                    legend: {
                        display:false
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
                fv2: this.accountId
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

}