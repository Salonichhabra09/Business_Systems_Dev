import { LightningElement , track, api, wire} from 'lwc'
import getRatingDataForReport from '@salesforce/apex/MasterProgressReportView.getRatingDataForReport';
import getRatingDataForReporttotalrecords from '@salesforce/apex/MasterProgressReportView.getRatingDataForReporttotalrecords';
import connectedCallbackApex from '@salesforce/apex/MasterProgressReportView.decodeurlparamater';

export default class ClientReportDashboard extends LightningElement {
    
    @api message;
    oppPieconfigVADC;
    oppPieconfigInsight;
    oppPieconfigTC;
    oppPieconfigMFS;
    recordIdJob;
    callingfrominternal;
    chartdata;
    parsedData;
    TConly = false;;
    MFSonly =false;
    VADConly =false;
    Insightonly = false;
    Onecolumn = false;;
    Twocolumn = false;;
    Threecolumn =false;;
    Fourcolumn = false;
    MFSchart = false;
    TCchart = false;
    VADCchart = false;
    Insightschart = false;
    arrayToUse;
    chartlength =0;
    mapDataVADC1;
    mapDataInsight1;
    mapDataTC1;
    mapDataMFS1;
    mapDataVADC = new Map();
    mapDataInsight = new Map();
    mapDataTC = new Map();
    mapDataMFS = new Map();
    showMessage = false;
    
    mapChartBackgroundColor = new Map();
    

      connectedCallback() {
        this.mapChartBackgroundColor.set('Completed', 'rgb(0, 158, 219)');//Rich Electric Blue
        this.mapChartBackgroundColor.set('Not Started', 'rgb(173, 216, 230)');//light blue
        this.mapChartBackgroundColor.set('In Progress', 'rgb(3, 145, 15)');//green
        this.mapChartBackgroundColor.set('Ready to Submit', 'rgb(128, 128, 0)');//Olive
        this.mapChartBackgroundColor.set('Recalled', 'rgb(75, 192, 192)');//lightgreen
       const url = new URL(window.location.href);
       this.callingfrominternal = url.searchParams.get('c__fromParent');
       //console.log(url.searchParams.get('c__fromParent'));
       //console.log(url.searchParams.get('c__jobId'));
       //console.log(url.searchParams.get('c__wrfId'));
        //console.log(this.callingfrominternal);
       
       if(this.callingfrominternal =='true'){
        //console.log('external'+url.searchParams.get('c__fromParent'));
        this.recordIdJob = url.searchParams.get('c__wrfId');
       //this.recordIdJob =  this.recordIdJob.replace(/ /g, '%20'); // Replaces all spaces
        this.fetchData();
       }
      else{
        //console.log('internal'+url.searchParams.get('c__fromParent'));
       this.recordIdJob = url.searchParams.get('c__jobId');
       }

       //console.log('recordid'+this.recordIdJob);
       //console.log('callingfrominternal value'+this.message);
       if(this.message){
        this.parsedData = JSON.parse(JSON.stringify(this.message));

        this.parsedData.forEach(element => {
            if(element.label =='MFS Status' ||element.label =='360 Status'){
                this.MFSchart = true;
            }
            if(element.label =='TC Status' ||element.label =='Assessment Status'){
                this.TCchart = true;
            }
            if(element.label =='VADC Status'){
                this.VADCchart = true;
            }
            if(element.label =='Insights Status'){
                this.Insightschart = true;
            }
        });
       }

    }

    fetchData() {

        connectedCallbackApex({ recordId: this.recordIdJob })

            .then(result => {

                this.recordIdJob = result;

            })

            .catch(error => {

                this.error = error;
                //console.error('Connected call back Error:', JSON.stringify(error));

            });

    }

   
  @wire(getRatingDataForReport,{jobId: '$recordIdJob'})
    getRatingDataForReportWire({ error, data }){
        if(data)
            {
                let datafromjason = JSON.stringify(JSON.parse(data));
                //this.chartdata = data;
                //console.log('data clientreportdata:', JSON.stringify(JSON.parse(data)));
                this.initializeChart(datafromjason);
            }
            else if (error) {
            //console.error('Error:', JSON.stringify(error, null, 2));
        }
    }

    @wire(getRatingDataForReporttotalrecords,{jobId: '$recordIdJob'})
    getRatingDataForReporttotalrecordswire({ error, data }){
        if(data)
            {
                this.chartlength = data;
                //console.log('this.chartlength '+this.chartlength );
            }
            else if (error) {
            //console.error('Error:', JSON.stringify(error, null, 2));
        }
    }


    

    initializeChart(datafromjason){
        //console.log('data clientreportdata:', JSON.stringify(JSON.parse(datafromjason)));
                let listOfVADCStatus = [];
                let listOfInsightStatus = [];
                let listOfTCStatus = [];
                let listOfMFSStatus = [];
                let listOfOppStatusDataCountVADC = [];
                let listOfOppStatusDataCountInsight = [];
                let listOfOppStatusDataCountTC =[];
                let listOfOppStatusDataCountMFS =[];
                let listOfBackgroundColorVADC = [];
                let listOfBackgroundColorInsight = [];
                let listOfBackgroundColorTC = [];
                let listOfBackgroundColorMFS= [];
                
                
                let bgColor = this.mapChartBackgroundColor;

                this.arrayToUse = JSON.parse(datafromjason);

                if (this.arrayToUse != null && typeof this.arrayToUse === 'object') {
                    // Loop through the keys in the object
                    Object.entries(this.arrayToUse).forEach(([key, value]) => {
                        
                        // check for MFS_Status
                        if (key === "MFS_Status") {
                            //console.log('---> has MFS', JSON.stringify(value));
                            this.mapDataMFS1 = value;
                            
                        }

                        //  check for TC_Status
                        if (key === "TC_Status") {
                            //console.log('---> has TC', JSON.stringify(value));
                            this.mapDataTC1 = value;
                        }

                        //  check for VADC_Status
                        if (key === "VADC_Status") {
                            //console.log('---> has VADC', JSON.stringify(value));
                            this.mapDataVADC1 = value;
                        }

                        //  check for Insights_Status
                        if (key === "Insights_Status") {
                            //console.log('---> has Insights_Status', JSON.stringify(value));
                            this.mapDataInsight1 = value;
                        }
                    });
                }

                //console.log('mapDataVADC1'+this.mapDataVADC1);
                //console.log('mapDataInsight1'+this.mapDataInsight1);
                //console.log('mapDataMFS1'+this.mapDataMFS1);
                //console.log('mapDataTC1'+this.mapDataTC1);
                if (this.mapDataMFS1 != null && typeof this.mapDataMFS1 === 'object') {
                    // Assuming mapDataMFS1 is an object
                    Object.entries(this.mapDataMFS1).forEach(([key, value]) => {
                        this.mapDataMFS.set(key, value); 
                        //console.log('mapDataMFS key:', key);
                        //console.log('mapDataMFS value:', value);
                        //console.log('mapDataMFS:', this.mapDataMFS);
                    });
                }

                if (this.mapDataTC1 != null && typeof this.mapDataTC1 === 'object') {
                    // Assuming mapDataTC1 is an object
                    Object.entries(this.mapDataTC1).forEach(([key, value]) => {
                        this.mapDataTC.set(key, value); 
                        //console.log('mapDataTC key:', key);
                        //console.log('mapDataTC value:', value);
                        //console.log('mapDataTC:', this.mapDataTC);
                    });
                }

                if (this.mapDataVADC1 != null && typeof this.mapDataVADC1 === 'object') {
                    // Assuming mapDataVADC1 is an object
                    Object.entries(this.mapDataVADC1).forEach(([key, value]) => {
                        this.mapDataVADC.set(key, value); 
                        //console.log('mapDataVADC key:', key);
                        //console.log('mapDataVADC value:', value);
                        //console.log('mapDataVADC:', this.mapDataVADC);
                    });
                }

                if (this.mapDataInsight1 != null && typeof this.mapDataInsight1 === 'object') {
                    // Assuming mapDataInsight1 is an object
                    Object.entries(this.mapDataInsight1).forEach(([key, value]) => {
                        this.mapDataInsight.set(key, value); 
                        //console.log('mapDataInsight key:', key);
                        //console.log('mapDataInsight value:', value);
                        //console.log('mapDataInsight:', this.mapDataInsight);
                    });
                }
                
                
                //for VADC
                this.mapDataVADC.forEach((value, key) => { // Use arrow function here
                    if (key !== undefined) {
                        //console.log('Key vadc-> ' + key + '  value -> ' + value);
                        listOfVADCStatus.push(key);
                        listOfOppStatusDataCountVADC.push(this.mapDataVADC.get(key));
                        listOfBackgroundColorVADC.push(bgColor.get(key));
                    }
                });

                //for TC
                this.mapDataTC.forEach((value, key) => { // Use arrow function here
                    if (key !== undefined) {
                        //console.log('Key TC-> ' + key + '  value -> ' + value);
                        listOfTCStatus.push(key);
                        listOfOppStatusDataCountTC.push(this.mapDataTC.get(key));
                        listOfBackgroundColorTC.push(bgColor.get(key));
                    }
                });

                //for MFS
                this.mapDataMFS.forEach((value, key) => { // Use arrow function here
                    if (key !== undefined) {
                        //console.log('Key MFS-> ' + key + '  value -> ' + value);
                        listOfMFSStatus.push(key);
                        listOfOppStatusDataCountMFS.push(this.mapDataMFS.get(key));
                        listOfBackgroundColorMFS.push(bgColor.get(key));
                    }
                });

                //for Insights
                this.mapDataInsight.forEach((value, key) => { // Use arrow function here
                    if (key !== undefined) {
                        //console.log('Key insights-> ' + key + '  value -> ' + value);
                        listOfInsightStatus.push(key);
                        listOfOppStatusDataCountInsight.push(this.mapDataInsight.get(key));
                        listOfBackgroundColorInsight.push(bgColor.get(key));
                    }
                });

               

                //console.log('listOfInsightStatus'+listOfInsightStatus);
                //console.log('listOfMFSStatus'+listOfMFSStatus);
                //console.log('listOfTCStatus'+listOfTCStatus);
                //console.log('listOfVADCStatus'+listOfVADCStatus);

                if(listOfBackgroundColorTC != ''  && this.TCchart == true){
                    this.TConly = true;
                }

                if(listOfBackgroundColorMFS != '' && this.MFSchart == true ){
                    this.MFSonly = true;
                }
                if(listOfBackgroundColorVADC != '' && this.VADCchart == true){
                    this.VADConly = true;

                }
                if(listOfBackgroundColorInsight != '' && this.Insightschart == true){
                    this.Insightonly = true;

                }
                //console.log('this.Insightonly'+this.Insightonly);
                //console.log('this.TConly'+this.TConly);
                //console.log('this.MFSonly'+this.MFSonly);
                //console.log('this.VADConly'+this.VADConly);
                
                //return 1 column, 2 column, 3 column or 4 column
                if(this.TConly && this.Insightonly && this.MFSonly && this.VADConly){
                    this.Fourcolumn = true;
                }
                if((this.TConly && this.Insightonly && this.MFSonly && !this.VADConly) || (!this.TConly && this.Insightonly && this.MFSonly && this.VADConly)
                || (this.TConly && !this.Insightonly && this.MFSonly && this.VADConly) || (this.TConly && this.Insightonly && !this.MFSonly && this.VADConly)){
                    this.Threecolumn = true;
                }
                if((this.TConly && this.Insightonly && !this.MFSonly && !this.VADConly) || (!this.TConly && this.Insightonly && this.MFSonly && !this.VADConly)
                    || (this.TConly && !this.Insightonly && this.MFSonly && !this.VADConly) || (!this.TConly && this.Insightonly && !this.MFSonly && this.VADConly)
                || (this.TConly && !this.Insightonly && !this.MFSonly && this.VADConly) || (!this.TConly && !this.Insightonly && this.MFSonly && this.VADConly)){
                        this.Twocolumn = true;
                    }
                if((this.TConly && !this.Insightonly && !this.MFSonly && !this.VADConly) || (!this.TConly && this.Insightonly && !this.MFSonly && !this.VADConly)
                ||(!this.TConly && !this.Insightonly && this.MFSonly && !this.VADConly || (!this.TConly && !this.Insightonly && !this.MFSonly && this.VADConly))){
                    this.Onecolumn = true;
                }
                //console.log('this.Onecolumn'+this.Onecolumn);
                //console.log('this.Twocolumn'+this.Twocolumn);
                //console.log('this.Threecolumn'+this.Onecolumn);
                //console.log('this.Fourcolumn'+this.Fourcolumn);

                
                //console.log('listOfVADCStatus'+listOfVADCStatus);
                //console.log('listOfTCStatus'+listOfTCStatus);

                if( !this.Onecolumn && !this.Twocolumn && !this.Threecolumn && !this.Fourcolumn){
                    this.showMessage = true;
                }

        if (listOfOppStatusDataCountVADC.length > 0 && this.chartlength >= 1000) {
                this.oppPieconfigVADC = {
                type: "horizontalBar",
                data: {
                    labels: listOfVADCStatus,
                    datasets: [{
                        label: '',
                        data: listOfOppStatusDataCountVADC,
                        backgroundColor: listOfBackgroundColorVADC,
                        borderColor: listOfBackgroundColorVADC,
                        borderWidth: 1,
                        skipNull: true
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
                
            };
        }
        else if (listOfOppStatusDataCountVADC.length > 0 && this.chartlength < 1000) {
                           
                this.oppPieconfigVADC = {
                type: "horizontalBar",
                data: {
                    labels: listOfVADCStatus,
                    datasets: [{
                        label: '',
                        data: listOfOppStatusDataCountVADC,
                        backgroundColor: listOfBackgroundColorVADC,
                        borderColor: listOfBackgroundColorVADC,
                        borderWidth: 1,
                        skipNull: true
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
                                stepSize: 1 // Ensure the tick spacing is 1
                            }
                        }],
                    }
                },
                
            };
        }

        if (listOfBackgroundColorInsight.length > 0 && this.chartlength >= 1000) {
                
                this.oppPieconfigInsight = {
                type: "horizontalBar",
                data: {
                    labels: listOfInsightStatus,
                    datasets: [{
                        label: '',
                        data: listOfOppStatusDataCountInsight,
                        backgroundColor: listOfBackgroundColorInsight,
                        borderColor: listOfBackgroundColorInsight,
                        borderWidth: 1,
                        skipNull: true
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
                
            };
        }
        else if (listOfBackgroundColorInsight.length > 0 && this.chartlength < 1000) {
            
                
                this.oppPieconfigInsight = {
                type: "horizontalBar",
                data: {
                    labels: listOfInsightStatus,
                    datasets: [{
                        label: '',
                        data: listOfOppStatusDataCountInsight,
                        backgroundColor: listOfBackgroundColorInsight,
                        borderColor: listOfBackgroundColorInsight,
                        borderWidth: 1,
                        skipNull: true
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
                                    // Get the total of all data points
                                    const total = ctx.dataset.data.reduce((sum, value) => sum + value, 0);
                            
                                    // Calculate the percentage
                                    const percentage = ((value / total) * 100).toFixed(2);
                            
                                    return `${percentage}%`; // Display percentage
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
                                stepSize: 1 // Ensure the tick spacing is 1
                            }
                        }],
                    }
                },
                
            };
        }
        if (listOfOppStatusDataCountTC.length > 0 && this.chartlength >= 1000) {
            const maxDataValue = Math.max(...listOfOppStatusDataCountTC); // Find the max value in dataset
          const nextRoundedMax = Math.ceil(maxDataValue / 100) * 100; // Round up to the nearest 10
            this.oppPieconfigTC = {
                type: "horizontalBar",
                data: {
                    labels: listOfTCStatus,
                    datasets: [{
                        label: '',
                        data: listOfOppStatusDataCountTC,
                        backgroundColor: listOfBackgroundColorTC,
                        borderColor: listOfBackgroundColorTC,
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
                                stepSize: 100, // Ensure the tick spacing is 1
                                max: nextRoundedMax // Dynamically set max scale value
                            }
                        }],
                    }
                },
            }; 
            
        }
        else if (listOfOppStatusDataCountTC.length > 0 && this.chartlength < 1000) {
            // Calculate max scale value (round up to the next multiple of 10, 50, or 100)
        const maxDataValue = Math.max(...listOfOppStatusDataCountTC); // Find the max value in dataset
        const nextRoundedMax = Math.ceil(maxDataValue / 100) * 100; // Round up to the nearest 10
            
            this.oppPieconfigTC = {
                type: "horizontalBar",
                options: {
                    legend:
                        {
                            display: false
                        },
                        plugins: {
                            responsive :true,
                            datalabels: {
                                formatter: (value, ctx) => {
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
                                stepSize: 1, // Ensure the tick spacing is 1
                                max: nextRoundedMax // Dynamically set max scale value
                            }
                        }],
                    }
                },
                data: {
                    labels: listOfTCStatus,
                    datasets: [{
                        label: '',
                        data: listOfOppStatusDataCountTC,
                        backgroundColor: listOfBackgroundColorTC,
                        borderColor: listOfBackgroundColorTC,
                        borderWidth: 1
                    }]
                },
                
            }; 
            
        }
        
            if (listOfOppStatusDataCountMFS.length > 0 && this.chartlength >= 1000 ) {
                const maxDataValue = Math.max(...listOfOppStatusDataCountMFS); // Find the max value in dataset
                const nextRoundedMax = Math.ceil(maxDataValue / 100) * 100; // Round up to the nearest 10
                this.oppPieconfigMFS = {
                    type: "horizontalBar",
                    data: {
                        labels: listOfMFSStatus,
                        datasets: [{
                            label: '',
                            data: listOfOppStatusDataCountMFS,
                            backgroundColor: listOfBackgroundColorMFS,
                            borderColor: listOfBackgroundColorMFS,
                            borderWidth: 1,
                            skipNull: true
                        }]
                    },
                    options: {
                        legend:
                        {
                            display: false,
                            maintainAspectRatio: false // Allows the chart to resize freely
                        },
                        plugins: {
                            responsive :true,
                            datalabels: {
                                formatter: (value, ctx) => {
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
                                    stepSize: 100, // Ensure the tick spacing is 1
                                    max: nextRoundedMax // Dynamically set max scale value
                                }
                            }],
                        }
                       
                    },
                }; 

            }
            else if (listOfOppStatusDataCountMFS.length > 0 && this.chartlength < 1000 ) {
                const maxDataValue = Math.max(...listOfOppStatusDataCountMFS); // Find the max value in dataset
                const nextRoundedMax = Math.ceil(maxDataValue / 100) * 100; // Round up to the nearest 10
                this.oppPieconfigMFS = {
                    type: "horizontalBar",
                    data: {
                        labels: listOfMFSStatus,
                        datasets: [{
                            label: '',
                            data: listOfOppStatusDataCountMFS,
                            backgroundColor: listOfBackgroundColorMFS,
                            borderColor: listOfBackgroundColorMFS,
                            borderWidth: 1,
                            skipNull: true
                        }]
                    },
                    options: {
                        legend:
                        {
                            display: false,
                            maintainAspectRatio: false // Allows the chart to resize freely
                        },
                        plugins: {
                            responsive :true,
                            datalabels: {
                                formatter: (value, ctx) => {
                                    
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
                                    stepSize: 1, // Ensure the tick spacing is 1
                                    max: nextRoundedMax // Dynamically set max scale value
                                }
                            }],
                        }
                       
                    },
                }; 
            }
    }


};