import { LightningElement, wire, track } from 'lwc';
import GetGroupList from '@salesforce/apex/TaskSearchController.returnManagedServiceGroups';
import GetTaskList from '@salesforce/apex/TaskSearchController.returnTasks';
import getQueueList from '@salesforce/apex/TaskSearchController.getQueueList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE  from '@salesforce/i18n/timeZone';
import LOCALE from '@salesforce/i18n/locale';

const columns = [
    { label: 'Scheduled time', fieldName: 'Scheduled_Time__c'},
    { label: 'Date of Task', fieldName: 'Task_Date__c',type: 'date', 
    typeAttributes:{
        year: "numeric",
        month: "short",
        day: "2-digit",
        timeZone: TIME_ZONE
     }},
    { label: 'Assigned To', fieldName: 'OwnerName' },
    {
        label: 'Job Number',
        fieldName: 'JobUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'JobNumber' }, 
        target: '_blank'},
    },
    //{ label: 'Job Number', fieldName: 'JobNumber' },
    { label: 'Project Name', fieldName: 'ProjectName',initialWidth: 140,wrapText:true },
    { label: 'Account Name', fieldName: 'AccountName',initialWidth: 140,wrapText:true },
    { label: 'Task Description', fieldName: 'Task_Type__c',initialWidth: 140,wrapText:true },
    //{ label: 'Estimated Time(mins)', fieldName: 'EstimatedDurationInMinutes__c' },
    { label: 'Actual Time(mins)', fieldName: 'ActualTimeTaken' },
    { label: 'Task Status', fieldName: 'Task_Status__c' },
    { label: 'Start Date', fieldName: 'Task_Start_Time__c',type: 'date', 
    typeAttributes:{
        year: "numeric",
        month: "short",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
        timeZone: TIME_ZONE
     }, wrapText:true },
    { label: 'End Date', fieldName: 'Task_End_Time__c',type: 'date', 
    typeAttributes:{
        year: "numeric",
        month: "short",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
        timeZone: TIME_ZONE
    },wrapText:true }
];
export default class MultiSelectPicklist extends LightningElement {
    startDate='';
    endDate='';
    lstSelected = [];
    @track lstOptions = [];
    taskData;
    columns = columns;
    @track lstTaskStatusOptions = [{label:'All Tasks',value:'All Tasks'},
    {label:'Completed',value:'Completed'},
    {label:'Not Completed',value:'Not Completed'}];
    lstTaskStatusSelected = [];
    taskOwner = '';
    TableVisibility = false;
    JobNumbersString;
    JobNumbersList;
    ValidtionExist = false;
    showSpinner = false;

    @wire (getQueueList)
    QueueList({error,data}){
        if(data){
            console.log('Queue list '+JSON.stringify(data));
            for (var key in data) {
                this.lstOptions.push({ label: key, value: data[key] });
                console.log('key', key, data[key]);
            }
           /* data.forEach(element => {
                //console.log(element.Name);
                this.lstOptions.push({
                    label: element.Name,
                    value: element.Id
                });
            });*/
        }
        else if(error){
            console.log(error);
        }
    };

    handleChange(event) {
        this.lstSelected = event.detail.value;
        console.log('Group List '+this.lstSelected);
    }

    handleTaskStatusChange(event) {
        this.lstTaskStatusSelected = event.detail.value;
        console.log('Task Status List '+this.lstTaskStatusSelected);
    }

    handleOwnerLookup(event){
        this.taskOwner = ''+event.detail.value;
        console.log('Task Owner '+this.taskOwner);
    }

    handleJobNumbers(event){
        this.JobNumbersList = event.detail.value.split(',');
        console.log('Job number list '+this.JobNumbersList);
    }
    handleDateChange(event){
        console.log('event '+JSON.stringify(event.detail));
        console.log('event '+JSON.stringify(event.target.name));
        if(event.target.name=='StartDate'){
            this.startDate=event.detail.value;
            this.checkStartDateVaildations();
        }
        else{
            this.endDate=event.detail.value;
            this.checkEndDateVaildations();
        }
    }
    checkStartDateVaildations(){
      this.checkEndDateVaildations();
        let startDateField = this.template.querySelector('.StartDate');
        console.log('Start Date '+this.startDate);
        if(this.endDate!='' && this.startDate!='' && this.startDate!=null){
            if(this.startDate>this.endDate){
                       console.log('Date validation');
                       this.ValidtionExist=true;
                       startDateField.setCustomValidity('Start Date should be less than End Date');
                    }
                    else{
                        console.log(startDateField);
                        this.ValidtionExist=false;
                        startDateField.setCustomValidity('');
                    }
                    startDateField.reportValidity();    
        }

    }
    checkEndDateVaildations(){
        let endDateField = this.template.querySelector('.EndDate');
        let startDateField = this.template.querySelector('.StartDate');
        if(this.startDate!='' && this.startDate!=null && (this.endDate!=null && this.endDate!='')){
            if(this.startDate>this.endDate){
                       console.log('Date validation');
                       this.ValidtionExist=true;
                       endDateField.setCustomValidity('End Date should be greater than Start Date');
                    }
                    else{
                        this.ValidtionExist=false;
                        startDateField.setCustomValidity('');
                        endDateField.setCustomValidity('');
                    }    
        }
        if((this.startDate=='' || this.startDate==null) && (this.endDate!='' && this.endDate!=null)){
            this.ValidtionExist=true;
            endDateField.setCustomValidity('Please select start date when you select end date.');
        }
        if(this.endDate=='' || this.endDate==null){
            this.ValidtionExist=false;
            endDateField.setCustomValidity('');
        }
        endDateField.reportValidity();
        startDateField.reportValidity();
      }


    SearchTasks(event){
        if(this.lstSelected.length == 0 && this.lstTaskStatusSelected.length == 0 && (this.startDate == '' || this.startDate == null )&& (this.endDate == '' || this.endDate == null ) && this.taskOwner == '' && (this.JobNumbersList == undefined || this.JobNumbersList == '')){
            const event = new ShowToastEvent({
                title: 'No filters Selected',
                message:
                    'Please select atleast one filter to search. ',
            });
            this.dispatchEvent(event);
        }
        else {
        if(this.ValidtionExist){
            const event = new ShowToastEvent({
                title: 'Validation Exists',
                variant: 'error',
                message:
                    'Please rectify the validations before the search.',
            });
            this.dispatchEvent(event);
        }
        else{
            this.showSpinner = true;
            if(this.JobNumbersList==''){
                this.JobNumbersList = undefined;
            }
        GetTaskList({
            AssignedToGroups : this.lstSelected,
            TaskStatusList: this.lstTaskStatusSelected,
            StartDate: this.startDate,
            EndDate: this.endDate,
            SelectedOwner: this.taskOwner,
            JobNumbers: this.JobNumbersList
        })
        .then((data) =>{
            if(data){
                console.log('data '+data.length);
                console.log('data value '+JSON.stringify(data));
                if(data.length==0){
                    this.TableVisibility = false;
                    const event = new ShowToastEvent({
                        title: 'No Data Available',
                        message:
                            'No data available for the selected filters.',
                    });
                    this.dispatchEvent(event);
                }
                else{
                    this.TableVisibility = true;
                    data.map((e) => {
                        if(e.OwnerId!=null){
                            e["OwnerName"]=e.Owner.Name;
                        }
                        e["JobNumber"]=e.Job__r.Name;
                        e["ProjectName"]=e.Job__r.Project_Name__c;
                        if(e.Job__r.Account__c!=null){
                            e["AccountName"]=e.Job__r.Account__r.Name;
                        }
                        e["JobUrl"] = `/lightning/r/Job__c/${e.Job__r.Id}/view`;
                        if(e.Actual_Time_Taken__c==null){
                            e["ActualTimeTaken"]=e.Original_Time_Taken__c;
                        }
                        else{
                                let timeInMinutes = Number(e.Actual_Time_Taken__c);
                            e["ActualTimeTaken"]=this.minuteToHm(timeInMinutes);
                        }
                        if(e.Scheduled_Time__c != null && e.Scheduled_Time__c != undefined) {
                            e.Scheduled_Time__c = this.msToHMS(e.Scheduled_Time__c);
                        }
                        if(e.Task_Start_Time__c !=null && e.Task_Start_Time__c !=undefined){
                            //e.Task_Start_Time__c = String(e.Task_Start_Time__c).split("T")[0]+"\r\n"+String(e.Task_Start_Time__c).split("T")[1].slice(0,-5);
                        }
                        if(e.Task_End_Time__c !=null && e.Task_End_Time__c !=undefined){
                            //e.Task_End_Time__c = String(e.Task_End_Time__c).split("T")[0]+"\r\n"+String(e.Task_End_Time__c).split("T")[1].slice(0,-5);
                        }
                      });
                      this.taskData = data;
                }
                this.showSpinner = false;
                //console.log('After Changes '+JSON.stringify(this.taskData));
            }
        })
        .catch((error)=>{
            this.showSpinner = false;
            if(error){
                console.log('Error '+error);
                const event = new ShowToastEvent({
                    title: 'Error Occured',
                    variant: 'error',
                    message: error.body.message,
                });
                this.dispatchEvent(event);
            }
        })
    }
    }
}

    exportTaskData(){
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columns.forEach(element => {            
            doc += '<th>'+ element.label +'</th>'           
        });
        doc += '</tr>';
        // Add the data rows
        this.taskData.forEach(record => {
            let formattedStartDate ='';
            let formattedEndDate ='';
            let formattedTaskDate = '';
            doc += '<tr>';
            if(record.Scheduled_Time__c==undefined){
                record.Scheduled_Time__c='';
            }
            if(record.Task_Date__c==undefined){
                record.Task_Date__c ='';  
            }
            else{
                formattedTaskDate = new Date(record.Task_Date__c).toLocaleString(LOCALE, {year: "numeric",
                month: "short",
                day: "2-digit",
                timeZone: TIME_ZONE});
            }
            if(record.OwnerName==undefined){
                record.OwnerName='';
            }
            if(record.JobNumber==undefined){
                record.JobNumber='';
            }
            if(record.ProjectName==undefined){
                record.ProjectName='';
            }
            if(record.AccountName==undefined){
                record.AccountName='';
            }
            if(record.ActualTimeTaken==undefined){
                record.ActualTimeTaken='';
            }
            if(record.Task_Status__c==undefined){
                record.Task_Status__c='';
            }
            if(record.Task_Start_Time__c==undefined){
                record.Task_Start_Time__c='';
            }
            else{
                formattedStartDate = new Date(record.Task_Start_Time__c).toLocaleString(LOCALE, {year: "numeric",
                month: "short",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit",
                timeZone: TIME_ZONE});
            }
            if(record.Task_End_Time__c==undefined){
                record.Task_End_Time__c='';
            }
            else{
                formattedEndDate = new Date(record.Task_End_Time__c).toLocaleString(LOCALE, {year: "numeric",
                month: "short",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit",
                timeZone: TIME_ZONE});
            }
            if(record.Task_Type__c==undefined){
                record.Task_Type__c='';
            }
            doc += '<th>'+record.Scheduled_Time__c+'</th>'; 
            doc += '<th>'+formattedTaskDate+'</th>'; 
            doc += '<th>'+record.OwnerName+'</th>';
            doc += '<th>'+record.JobNumber+'</th>';  
            doc += '<th>'+record.ProjectName+'</th>';
            doc += '<th>'+record.AccountName+'</th>';
            doc += '<th>'+record.Task_Type__c+'</th>';
            doc += '<th>'+record.ActualTimeTaken+'</th>';
            doc += '<th>'+record.Task_Status__c+'</th>'; 
            doc += '<th>'+formattedStartDate+'</th>'; 
            doc += '<th>'+formattedEndDate+'</th>'; 
            doc += '</tr>';
        });
        doc += '</table>';
        var universalBOM = "\uFEFF";
        var element = 'data:application/vnd.ms-excel;charset=utf-8,' + encodeURIComponent(universalBOM +doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Task Results.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    msToHMS( duration ) {
        let milliseconds = parseInt((duration % 1000) / 100),
            seconds = parseInt((duration / 1000) % 60),
            minutes = parseInt((duration / (1000 * 60)) % 60),
            hours = parseInt((duration / (1000 * 60 * 60)) % 24);
         hours = (hours < 10) ? "0" + hours : hours;
         minutes = (minutes < 10) ? "0" + minutes : minutes;
         seconds = (seconds < 10) ? "0" + seconds : seconds;
         return hours + ":" + minutes + ":" + seconds ;
   }

   minuteToHm(d){
    d = Number(d)
    const h = Math.floor(d / 60);
    const m = d % 60;
    // const s = Math.floor(d % 3600 % 60);
    const hDisplay = h > 0 ? h + (h == 1 ? ' hour, ' : ' hours, ') : '';
    const mDisplay = m +' minute';
    // const sDisplay = s > 0 ? s + (s == 1 ? ' second' : ' seconds') : '';
    // console.log('time---', hDisplay + mDisplay + sDisplay);
    return hDisplay + mDisplay;// + sDisplay;
}
}