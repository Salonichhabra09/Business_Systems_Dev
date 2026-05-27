import { LightningElement, wire, api } from 'lwc';
import getDashboardData from '@salesforce/apex/ProjectDashboardController.getDashboardData';
import shlLogo from '@salesforce/resourceUrl/SHLLogo';
import { loadScript } from 'lightning/platformResourceLoader';
import ChartJS from '@salesforce/resourceUrl/ChartJs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProjectDashboard extends LightningElement {
    @api recordId; // Job__c Record ID
    contractNumber;
    startDate;
    endDate;
    projectContacts = [];
    resourceLinks = [];
    chartLibrariesLoaded = false;
    newRequestForm;
    shlSupportPage = 'https://support.shl.com/';
    isLoading = true; 
    isGCSC;
    
    /*@wire(getDashboardData, { jobId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            this.contractNumber = data.contractNumber;
            this.startDate = data.startDate;
            this.endDate = data.endDate;
            this.newRequestForm = data.newRequestForm;
            this.dataforChart = data;
            console.log('newRequestForm', this.newRequestForm);
            console.log('before  ', JSON.stringify(data.projectContacts));
            this.projectContacts = data.projectContacts.map(contact => ({
                ...contact,
                initials: this.getInitials(contact.name)
            }));
            this.resourceLinks = data.resourceLinks;
            console.log('after  ', JSON.stringify(this.projectContacts));
            if (this.chartLibrariesLoaded) {
                    this.initializeCharts(this.dataforChart);
            }
        } else if (error) {
            console.error('Error loading dashboard data:', error);
        }
    }*/

    connectedCallback() {
        this.isLoading = true;
        Promise.all([loadScript(this, ChartJS)])
            .then(() => {
                this.chartLibrariesLoaded = true;
                this.fetchDashboardData(); 
            })
            .catch(error => {
                console.error('Error loading Chart.js:', error);
            });
    }

    fetchDashboardData() {
        // Call Apex method manually
        getDashboardData({ jobId: this.recordId })
            .then(data => {
                this.dashboardData = data;
                this.contractNumber = data.contractNumber;
                this.startDate = data.startDate;
                this.endDate = data.endDate;
                this.newRequestForm = data.newRequestForm;
                this.isGCSC = data.Is_GCSC_Opp;
                //console.log('Dashboard Data1:', data);
                this.projectContacts = data.projectContacts.map(contact => ({
                    ...contact,
                    initials: this.getInitials(contact.name.trim())
                }));
                this.resourceLinks = data.resourceLinks;

                //console.log('Dashboard Data2:', data);

                // Ensure charts are initialized only when Chart.js is loaded
                if (this.chartLibrariesLoaded) {
                    setTimeout(() => {
                        this.initializeCharts(data);
                    }, 500);
                }
                this.isLoading = false; 
            })
            .catch(error => {
                this.isLoading = false; 
                console.error('Error fetching dashboard data:', JSON.stringify(error)); 
            });
    }


    copyEmail(event) {
        const email = event.currentTarget.dataset.email;
        navigator.clipboard.writeText(email).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Copied!',
                    message: `Email copied: ${email}`,
                    variant: 'success'
                })
            );
        });
    }

    getInitials(name) {
        return name
            .split(' ')
            .map(word => word[0].toUpperCase())
            .join('');
    }

initializeCharts(data) {
    // Pie Chart: Processed vs. Remaining
    //console.log('inside chart');
    //console.log('data', data);
    const total = data.processed + data.remaining;
        const processedPercentage = ((data.processed / total) * 100);
        const remainingPercentage = ((data.remaining / total) * 100);
        let formattedprocessedPercentage = (processedPercentage < 1 && processedPercentage >0) ? processedPercentage.toFixed(4) : processedPercentage.toFixed(0);
        let formattedremainingPercentage = (processedPercentage < 1 && processedPercentage >0) ? remainingPercentage.toFixed(4) : remainingPercentage.toFixed(0);
    const canvas = this.template.querySelector('canvas.donutChart');

if (canvas) {
const ctx1 = canvas.getContext('2d');
new Chart(ctx1, {
    type: 'doughnut',
    data: {
        labels: [`Processed (${formattedprocessedPercentage}%)`, `Remaining (${formattedremainingPercentage}%)`],
        datasets: [{
            data: [data.processed, data.remaining],
            backgroundColor: ['#4CAF50', '#BDBDBD']
        }]
    },
    options: {
        rotation: Math.PI,
        circumference: Math.PI,
        responsive: false,
        maintainAspectRatio: false,
        cutout: '70%', // Controls the donut hole size
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            boxWidth: 12
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(tooltipItem) {
                                let dataset = tooltipItem.dataset;
                                let value = dataset.data[tooltipItem.dataIndex];
                                let percentage = ((value / total) * 100);
                                let formattedPercentage = (percentage < 1 && percentage>0) ? percentage.toFixed(4) : percentage.toFixed(0);
                                return ` ${formattedPercentage}%`;
                            }
                        }
                    }
                }
    }
});
} else {
console.error('Canvas element not found.');
}
//console.log('after chart');

      /* const canvas2 = this.template.querySelector('canvas.barChart');
if (canvas2) {
const ctx2 = canvas2.getContext('2d');
new Chart(ctx2, {
    type: 'horizontalBar',
    data: {
        labels: ['Completed', 'In Progress', 'Not Started', 'Recalled'],
        datasets: [{
            label: 'Count',
            data: [data.completed || 0, data.inProgress || 0, data.notStarted || 0, data.recalled || 0], // Avoid undefined values
            backgroundColor: 'rgba(54, 162, 235, 0.6)',
            borderColor: 'rgba(54, 162, 235, 1)',
            borderWidth: 1
        }]
    },
    options: {
        legend:
            {
                display: false
            },
        plugins: {
            responsive :true,
            datalabels: {
            formatter: (value, ctx) => {
                //console.log('--ctx--'+ctx);
            // Get the total of all data points
            const total = ctx.dataset.data.reduce((sum, value) => sum + value, 0);

            // Calculate the percentage
            const percentage = ((value / total) * 100).toFixed(2);

            return `${percentage}%`;; // Display percentage
        },
                color: '#000',  // Label color (can be customized)
                anchor: 'center',  // Anchor label at the end of the bar
                align: 'center',   // Align the label
                font: {
                    weight: 'bold' // Bold font
                }
            }
        },
        scales: {
            xAxes: [{ // For horizontal bar, the x-axis is the scale for the data
                ticks: {
                    beginAtZero: true, // Start x-axis at 0
                    stepSize: 100 // Ensure the tick spacing is 1
                }
            }],
        }
    },
});
        console.log('after chart2');
}*/
       
    } 





    get shlLogo() {
        return shlLogo;
    }
}