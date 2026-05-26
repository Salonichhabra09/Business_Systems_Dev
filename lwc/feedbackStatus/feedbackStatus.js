import { LightningElement, track, api, wire} from 'lwc';
    import getDefaultRecordTypeId from '@salesforce/apex/RatingController.getDefaultRecordTypeId';
    import getPicklistValues from '@salesforce/apex/RatingController.getPicklistValues';
    //import getPicklistValuesMFSStatus from '@salesforce/apex/RatingController.getPicklistValuesMFSStatus';
    import getRatingData from '@salesforce/apex/RatingController.getRatingDataTCStatus';
    import getRatingDataMFS from '@salesforce/apex/RatingController.getRatingDataMFSStatus';
    import getRatingDataSELF from '@salesforce/apex/RatingController.getRatingDataSELFStatus';
    import chartjs from '@salesforce/resourceUrl/ChartJs';
    import chartJsDatatables from '@salesforce/resourceUrl/chartJsDatatables';
    import { loadScript } from 'lightning/platformResourceLoader';
    //import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
    //import BUREAU_RATING_OBJECT from '@salesforce/schema/Bureau_Rating__c';
    //import TC_STATUS from '@salesforce/schema/Bureau_Rating__c.TC_Status__c';
    //import MFS_STATUS from '@salesforce/schema/Bureau_Rating__c.MFS_Status__c';

    const COLUMNS = [
        { label: 'Assessment Status', fieldName: 'status', type: 'text', cellAttributes: { alignment: 'left' , class: { fieldName: 'rowClass' }}},
        { label: 'Number of Individuals', fieldName: 'count', type: 'number', cellAttributes: { alignment: 'left' ,class: { fieldName: 'rowClass' }}},
        { label: 'Percentages', fieldName: 'percentage', type: 'text', cellAttributes: { alignment: 'left' ,class: { fieldName: 'rowClass' }}}
    ];

    const COLUMNSMFS = [
        { label: 'Feedback Status', fieldName: 'status', type: 'text', cellAttributes: { alignment: 'left' ,class: { fieldName: 'rowClass' }}},
        { label: 'Number of Feedbacks', fieldName: 'count', type: 'number', cellAttributes: { alignment: 'left' ,class: { fieldName: 'rowClass' }}},
        { label: 'Percentages', fieldName: 'percentage', type: 'text', cellAttributes: { alignment: 'left' ,class: { fieldName: 'rowClass' }}}
    ];

    const COLUMNSSELF = [
        { label: 'Self Feedback Status', fieldName: 'status', type: 'text', cellAttributes: { alignment: 'left' ,class: { fieldName: 'rowClass' }}},
        { label: 'Number of Individuals', fieldName: 'count', type: 'number', cellAttributes: { alignment: 'left' ,class: { fieldName: 'rowClass' }}},
        { label: 'Percentages', fieldName: 'percentage', type: 'text', cellAttributes: { alignment: 'left' ,class: { fieldName: 'rowClass' }}}
    ];

    export default class FeedbackStatus extends LightningElement {
        @track data = [];
        @track dataMFS = [];
        @track dataSELF = [];
        @track picklistTCStatusOptions = [];
        @track picklistMFSStatusOptions =[];
        @track recordTypeId;
        @api jobId;
        columns;
        columnsMFS;
        columnsSELF;
        recordIdJob;
        chart;
        chartLoaded = false;
        chartLoadedMFS = false;
        chartLoadedSELF = false;

        /*@wire(getObjectInfo, { objectApiName: BUREAU_RATING_OBJECT })
        objectInfo({ data, error }) {
            if (data) {
                this.recordTypeId = data.defaultRecordTypeId;
            } else if (error) {
                console.error('Error fetching object info:', error);
            }
        }
        
        @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: TC_STATUS })
        wiredPicklistValues({ error, data }) {
            if (data) {
                this.picklistTCStatusOptions = data.values.map(option => option.label); // Get only labels
                //.filter(option => option.active) // Only active values
                
                console.log('Active Picklist TC Status Values:', JSON.stringify(this.picklistTCStatusOptions));
            } else if (error) {
                console.error('Error fetching picklist values:', error);
            }
        }

        @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: MFS_STATUS })
        wiredPicklistValuesMFS({ error, data }) {
            if (data) {
                this.picklistMFSStatusOptions = data.values.map(option => option.label); // Get only labels
                //.filter(option => option.active) // Only active values
                
                console.log('Active Picklist MFS Status Values:', JSON.stringify(this.picklistMFSStatusOptions));
            } else if (error) {
                console.error('Error fetching picklist values:', error);
            }
        }*/

        connectedCallback() {
            const urlParams = new URL(window.location.href).searchParams;
            //this.recordIdJob = urlParams.get('c__jobId');
            this.recordIdJob = urlParams.get('c__jobId') || this.jobId;
            this.combinedCall();
            //this.loadObjectInfo();
            //this.loadData();
            //this.loadDataMFS();
            //this.loadDataSELF();
            
        }

        combinedCall(){
            let getDefaultRecordType = getDefaultRecordTypeId({ objectApiName: 'Bureau_Rating__c' });
            let tcStatusResult =  getPicklistValues({ objectApiName: 'Bureau_Rating__c', fieldApiName: 'TC_Status__c' });
            let mfsStatusResult = getPicklistValues({ objectApiName: 'Bureau_Rating__c', fieldApiName: 'MFS_Status__c' });
            let getData = getRatingData({ raterType: 'Self', jobId: this.recordIdJob });
            let getDataMFS = getRatingDataMFS({ raterType: 'Self', jobId: this.recordIdJob });
            let getDataSELF = getRatingDataSELF({ raterType: 'Self', jobId: this.recordIdJob });

            Promise.all([getDefaultRecordType,tcStatusResult,mfsStatusResult,getData,getDataMFS,getDataSELF]).then(results => {
                //console.log(results[0]);
                this.recordTypeId = results[0];
                this.picklistTCStatusOptions = results[1];
                this.picklistMFSStatusOptions = results[2];
                this.loadData(results[3]);
                this.loadDataMFS(results[4]);
                this.loadDataSELF(results[5]);
                //console.log(results[1]);
            })
            .catch(error => {

            });

        }

        async loadObjectInfo() {
            try {
                const recordTypeId = await getDefaultRecordTypeId({ objectApiName: 'Bureau_Rating__c' });
                this.recordTypeId = recordTypeId;
                await this.loadPicklistValues();
            } catch (error) {
                //console.error('Error fetching object info:', error);
            }
        }
        
        async loadPicklistValues() {
            try {
                //const tcStatusResult = await getPicklistValues({ objectApiName: 'Bureau_Rating__c', fieldApiName: 'TC_Status__c' });
                let tcStatusResult =  getPicklistValues({ objectApiName: 'Bureau_Rating__c', fieldApiName: 'TC_Status__c' });
                this.picklistTCStatusOptions = tcStatusResult;
        
                const mfsStatusResult = await getPicklistValues({ objectApiName: 'Bureau_Rating__c', fieldApiName: 'MFS_Status__c' });
                this.picklistMFSStatusOptions = mfsStatusResult;
                await Promise.all([loadData]);
                //console.log('Active Picklist TC Status Values:', JSON.stringify(this.picklistTCStatusOptions));
                //console.log('Active Picklist MFS Status Values:', JSON.stringify(this.picklistMFSStatusOptions));
            } catch (error) {
                //console.error('Error fetching picklist values:', error);
            }
        }
        

        renderedCallback() {    
            Promise.all([loadScript(this, chartjs), loadScript(this, chartJsDatatables)])
                .then(() => {        
                    const ctx = this.template.querySelector("canvas");
                    this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartDataset)));         
                })
                .catch(error => {
                    //console.error('Error loading Chart:', error);
                });
        }
        

        loadData(result) {
            /*console.log('loadmoredata',this.recordIdJob);
            console.log('Active Picklist TC Status Values:', JSON.stringify(this.picklistTCStatusOptions));
            console.log('Active Picklist MFS Status Values:', JSON.stringify(this.picklistMFSStatusOptions));*/
           /* getRatingData({ raterType: 'Self', jobId: this.recordIdJob })
                .then(result => {*/
                    if (result) {
                        let total = result.reduce((sum, item) => sum + item.totalCount, 0);

                        this.data = result.map(item => ({
                            status: item.TC_Status__c,
                            count: item.totalCount,
                            percentage: ((item.totalCount / total) * 100).toFixed(2) + '%',
                            rowClass: item.TC_Status__c === 'Total' ? 'bold-row' : '' // Fix check here

                        }));

                        // Create a set of existing statuses
                        const existingStatuses = new Set(this.data.map(item => item.status));
                        //console.log('existingStatuses', JSON.stringify([...existingStatuses]));

                        if (existingStatuses && existingStatuses.size > 0){
                            //Add missing statuses from picklist with count = 0
                            this.picklistTCStatusOptions.forEach(status => {
                                if (!existingStatuses.has(status)) {
                                    //console.log('inside if for 0 value tC status',status);
                                    this.data.push({
                                        status: status,
                                        count: 0,
                                        percentage: '0.00%',
                                        rowClass: ''
                                    });
                                }
                            });

                            this.data.push({
                                status: 'Total',
                                count: total,
                                percentage: '',
                                rowClass: 'bold-row'
                            });
                        }

                        // ✅ Check if all rows except "Total" are empty
                        if (this.data.filter(item => item.status !== 'Total').length === 0) {
                            
                            this.data = [];
                        }

                        if(this.data.length>0){
                            this.columns = COLUMNS;
                        }
                        
                        

                        // Load Chart.js after data is ready
                        if (!this.chartLoaded && this.data.length > 0) {
                            this.chartLoaded = true;
                            loadScript(this, chartjs)
                                .then(() => this.initializeChart(total))
                                .catch(error => console.error('Error loading Chart.js:', error));
                        }
                    }
                
        }

        loadDataMFS(result) {
            //console.log('loadmoredataMFS');
            /*getRatingDataMFS({ raterType: 'Self', jobId: this.recordIdJob })
                .then(result => {*/
                    if (result) {
                        let total = result.reduce((sum, item) => sum + item.totalCount, 0);

                        this.dataMFS = result.map(item => ({
                            status: item.MFS_Status__c,
                            count: item.totalCount,
                            percentage: ((item.totalCount / total) * 100).toFixed(2) + '%',
                            rowClass: item.MFS_Status__c === 'Total' ? 'bold-row' : '' // Fix check here
                        }));

                        // Create a set of existing statuses
                        const existingStatuses = new Set(this.dataMFS.map(item => item.status));
                        if (existingStatuses && existingStatuses.size > 0){
                            //Add missing statuses from picklist with count = 0
                            this.picklistMFSStatusOptions.forEach(status => {
                                if (!existingStatuses.has(status)) {
                                    this.dataMFS.push({
                                        status: status,
                                        count: 0,
                                        percentage: '0.00%',
                                        rowClass: ''
                                    });
                                }
                            });
                            

                            this.dataMFS.push({
                                status: 'Total',
                                count: total,
                                percentage: '',
                                rowClass: 'bold-row'
                            });
                        }
                        // ✅ Check if all rows except "Total" are empty
                        if (this.dataMFS.filter(item => item.status !== 'Total').length === 0) {
                            this.dataMFS = [];
                        }

                        if(this.dataMFS.length > 0) {
                            this.columnsMFS = COLUMNSMFS; // ✅ Show columns if data exists
                        }
                        

                        // Load Chart.js after data is ready
                        if (!this.chartLoadedMFS && this.dataMFS.length > 0) {
                            this.chartLoadedMFS = true;
                            loadScript(this, chartjs)
                                .then(() => this.initializeChartMFS(total))
                                .catch(error => console.error('Error loading Chart.js MFS:', error));
                        }
                    }
                /*})
                .catch(error => {
                    console.error('Error fetching data MFS:', JSON.stringify(error));
                });*/
        }

        loadDataSELF(result) {
            //console.log('loadmoredataSELF');
            /*getRatingDataSELF({ raterType: 'Self', jobId: this.recordIdJob })
                .then(result => {*/
                    if (result) {
                        //console.log('loadDataSELF',result);
                        let total = result.reduce((sum, item) => sum + item.totalCount, 0);

                        /*this.dataSELF = result.map(item => ({
                            status: item.MFS_Status__c,
                            count: item.totalCount,
                            percentage: ((item.totalCount / total) * 100).toFixed(2) + '%',
                            rowClass: item.MFS_Status__c === 'Total' ? 'bold-row' : '' // Fix check here
                        }));
                        

                        this.dataSELF.push({
                            status: 'Total',
                            count: total,
                            percentage: '100.00%',
                            rowClass: 'bold-row'
                        });

                        // ✅ Check if all rows except "Total" are empty
                        if (this.dataSELF.filter(item => item.status !== 'Total' && item.count > 0).length === 0) {
                            this.dataSELF = [];
                        }*/
                        let filteredData = result
                            .filter(item => item.MFS_Status__c !== 'Total' && item.totalCount > 0) // ✅ Filter before adding total
                            .map(item => ({
                                status: item.MFS_Status__c,
                                count: item.totalCount,
                                percentage: ((item.totalCount / total) * 100).toFixed(2) + '%',
                                rowClass: item.MFS_Status__c === 'Total' ? 'bold-row' : ''
                            }));
                        
                        //  Create a set of existing statuses
                        const existingStatuses = new Set(filteredData.map(item => item.status));

                        if (existingStatuses && existingStatuses.size > 0){
                            // Add missing statuses from picklist with count = 0
                            this.picklistMFSStatusOptions.forEach(status => {
                                if (!existingStatuses.has(status)) {
                                    filteredData.push({
                                        status: status,
                                        count: 0,
                                        percentage: '0.00%',
                                        rowClass: ''
                                    });
                                }
                            });
                                
                            //console.log('filteredData: ', JSON.stringify(filteredData ));
                            if (filteredData.length > 0) {
                                // ✅ Add Total row only if data exists
                                filteredData.push({
                                    status: 'Total',
                                    count: total,
                                    percentage: '',
                                    rowClass: 'bold-row'
                                });
                            
                                this.dataSELF = filteredData;
                                this.columnsSELF = COLUMNSSELF; // ✅ Show columns if data exists
                            } else {
                                this.dataSELF = [];
                            }
                        }
                        
                    
                        // Load Chart.js after data is ready
                        if (!this.chartLoadedSELF && this.dataSELF.length > 0) {
                            this.chartLoadedSELF = true;
                            loadScript(this, chartjs)
                                .then(() => this.initializeChartSELF(total))
                                .catch(error => console.error('Error loading Chart.js Self:', error));
                        }
                    }
                /*})
                .catch(error => {
                    console.error('Error fetching data SELF:', JSON.stringify(error));
                });*/
        }

        initializeChart(total) {
            const canvas = this.template.querySelector('canvas[data-id="chartCanvas"]');
            if (!canvas) {
                //console.error('Canvas element not found');
                return;
            }

            const ctx = canvas.getContext('2d');
            //const labels = this.data.map(item => item.status);
            const labels = this.data.filter(item => item.status !== 'Total').map(item => item.status);
            const percentages = this.data.map(item => parseFloat(item.percentage));

            const colors = ['#C8E6C9', '#FFCC80', '#FFF9C4', '#E57373'];
            const borderColors = ['#A5D6A7', '#FFB74D', '#FFF59D', '#EF9A9A'];
            const colorMap = {
                'Not Started': '#E57373',
                'In Progress': '#FFCC80',
                'Ready to Submit': '#FFF9C4',
                'Completed': '#C8E6C9',
                'Recalled':'#E6E6FA' 
            };

            // Calculate dynamic max value to stop bar before end of chart
            //const maxValue = Math.ceil((total / 100) * 1.1); // ✅ Scale up by 10% for padding
            const maxValue = '100';
            if (this.chart) {
                this.chart.destroy(); // Destroy existing chart if present
            }

            this.chart = new window.Chart(ctx, {
                type: 'horizontalBar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Percentage',
                        data: percentages,
                        backgroundColor: labels.map(label => colorMap[label]),
                        borderColor: labels.map(label => colorMap[label]),
                        borderWidth: 1,
                        barPercentage: 0.6,
                        categoryPercentage: 0.7
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    
                    plugins: {
                        
                        datalabels:{
                            display: false
                        } 

                    },
                    scales: {
                        xAxes: [{
                            ticks: {
                                beginAtZero: true,
                                max: maxValue, // ✅ Dynamic max value to stop before end
                                callback: value => `${value}%`,
                                fontColor: '#888'
                            },
                            gridLines: {
                                display: true
                            }
                        }],
                        yAxes: [{
                            ticks: {
                                fontColor: '#888'
                            },
                            gridLines: {
                                display: false
                            }
                        }]
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        enabled: true,
                        callbacks: {
                            label: function(tooltipItem, data) {
                                let value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                                return `${value}%`;
                            }
                        }
                    }
                }
            });
        }

        initializeChartMFS(total) {
            const canvas = this.template.querySelector('canvas[data-id="chartCanvasMFS"]');
            if (!canvas) {
                //console.error('Canvas element not found');
                return;
            }

            const ctx = canvas.getContext('2d');
            const labels = this.dataMFS.filter(item => item.status !== 'Total').map(item => item.status);
            //console.log('labels: '+labels);
            //console.log('this.dataMFS',JSON.stringify(this.dataMFS));
            const percentages = this.dataMFS.map(item => parseFloat(item.percentage));

            const colors = ['#C8E6C9', '#FFCC80', '#FFF9C4', '#E57373'];
            const borderColors = ['#A5D6A7', '#FFB74D', '#FFF59D', '#EF9A9A'];
            const colorMap = {
                'Not Started': '#E57373',
                'In Progress': '#FFCC80',
                'Ready to Submit': '#FFF9C4',
                'Completed': '#C8E6C9',
                'Recalled':'#E6E6FA' 
            };

            // Calculate dynamic max value to stop bar before end of chart
            //const maxValue = Math.ceil((total / 100) * 1.1); // ✅ Scale up by 10% for padding
            const maxValue = '100';
            if (this.chartMFS) {
                this.chartMFS.destroy(); // Destroy existing chart if present
            }

            this.chartMFS = new window.Chart(ctx, {
                type: 'horizontalBar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Percentage',
                        data: percentages,
                        backgroundColor: labels.map(label => colorMap[label]),
                        borderColor: labels.map(label => colorMap[label]),
                        borderWidth: 1,
                        barPercentage: 0.6,
                        categoryPercentage: 0.7
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        
                        datalabels:{
                            display: false
                        } 

                    },
                    scales: {
                        xAxes: [{
                            ticks: {
                                beginAtZero: true,
                                max: maxValue, // ✅ Dynamic max value to stop before end
                                callback: value => `${value}%`,
                                fontColor: '#888'
                            },
                            gridLines: {
                                display: true
                            }
                        }],
                        yAxes: [{
                            ticks: {
                                fontColor: '#888'
                            },
                            gridLines: {
                                display: false
                            }
                        }]
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        enabled: true,
                        callbacks: {
                            label: function(tooltipItem, data) {
                                let value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                                return `${value}%`;
                            }
                        }
                    }
                }
            });
        }

        initializeChartSELF(total) {
            const canvas = this.template.querySelector('canvas[data-id="chartCanvasSELF"]');
            if (!canvas) {
                //console.error('Canvas element not found');
                return;
            }

            const ctx = canvas.getContext('2d');
            const labels = this.dataSELF.filter(item => item.status !== 'Total').map(item => item.status);

            const percentages = this.dataSELF.map(item => parseFloat(item.percentage));

            const colors = ['#C8E6C9', '#FFCC80', '#FFF9C4', '#E57373'];
            const borderColors = ['#A5D6A7', '#FFB74D', '#FFF59D', '#EF9A9A'];
            const colorMap = {
                'Not Started': '#E57373',
                'In Progress': '#FFCC80',
                'Ready to Submit': '#FFF9C4',
                'Completed': '#C8E6C9',
                'Recalled':'#E6E6FA' 
            };

            // Calculate dynamic max value to stop bar before end of chart
            //const maxValue = Math.ceil((total / 100) * 1.1); // ✅ Scale up by 10% for padding
            const maxValue = '100';
            if (this.chartSELF) {
                this.chartSELF.destroy(); // Destroy existing chart if present
            }

            this.chartSELF = new window.Chart(ctx, {
                type: 'horizontalBar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Percentage',
                        data: percentages,
                        backgroundColor: labels.map(label => colorMap[label]),
                        borderColor: labels.map(label => colorMap[label]),
                        borderWidth: 1,
                        barPercentage: 0.6,
                        categoryPercentage: 0.7
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    
                    plugins: {
                    datalabels:{
                            display: false
                        } 

                    },
                    scales: {
                        xAxes: [{
                            ticks: {
                                beginAtZero: true,
                                max: maxValue, // ✅ Dynamic max value to stop before end
                                callback: value => `${value}%`,
                                fontColor: '#888'
                            },
                            gridLines: {
                                display: true
                            }
                        }],
                        yAxes: [{
                            ticks: {
                                fontColor: '#888'
                            },
                            gridLines: {
                                display: false
                            }
                        }]
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        enabled: true,
                        callbacks: {
                            label: function(tooltipItem, data) {
                                let value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                                return `${value}%`;
                            }
                        }
                    }
                }
            });
        }
    
    }