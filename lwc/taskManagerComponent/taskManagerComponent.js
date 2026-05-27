import { LightningElement, wire, track, api } from 'lwc';
import userId from '@salesforce/user/Id';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STATUS_FIELD from '@salesforce/schema/MS_Task__c.Task_Status__c'; 
import TASK_CATEGORY_FIELD from '@salesforce/schema/MS_Task__c.Task_Category__c';
import TASK_TYPE_FIELD from '@salesforce/schema/MS_Task__c.Task_Type__c';
import TASK_OBJECT from '@salesforce/schema/MS_Task__c';
import PROJECT_MANAGER_FIELD from '@salesforce/schema/Job__c.Project_Manager__c';
import MS_LOB_FIELD from "@salesforce/schema/Job__c.MS_Line_of_Business__c";
import MS_Status_FIELD from "@salesforce/schema/Job__c.JobStatus__c";
import getTaskList from '@salesforce/apex/TaskManagerController.getTaskList';
import assignTaskToCurrentUser from '@salesforce/apex/TaskManagerController.assignTaskToCurrentUser';
import updateTaskRowData from '@salesforce/apex/TaskManagerController.updateTaskRowData';
import completeTask from '@salesforce/apex/TaskManagerController.completeTask';
import cancelTask from '@salesforce/apex/TaskManagerController.cancelTask';
import { subscribe, MessageContext } from 'lightning/messageService';
import MS_Task_Messages_CHANNEL from '@salesforce/messageChannel/MS_Task_Messages__c';
import MS_Super_User from '@salesforce/customPermission/MS_Super_User';
import cloneTasks from '@salesforce/apex/TaskManagerController.cloneTasks';
import getBureaUserList from '@salesforce/apex/BulkMSTaskCreationController.getBureaUserList';
import getQueueList from '@salesforce/apex/BulkMSTaskCreationController.getQueueList';
import getTaskRecordTypeName from '@salesforce/apex/BulkMSTaskCreationController.getTaskRecordTypeId';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import TIME_ZONE  from '@salesforce/i18n/timeZone';


const columns = [
    {
        label: 'S.No.',
        fieldName: 'serialNumber',
        type: 'number'
    },
    {
        label: 'Actions',
        fieldName: '',
        type: ''
    },
    {
        label: 'Owner',
        fieldName: 'OwnerId',
        type: 'text'
    },
    {
        label: 'Category',
        fieldName: 'Task_Category__c',
        type: 'text'
    },
    {
        label: 'Type',
        fieldName: 'Task_Type__c',
        type: 'text'
    },
    {
        label: 'Date',
        fieldName: 'Task_Date__c',
        type: 'text'
    },
    {
        label: 'Scheduled Time',
        fieldName: 'Scheduled_Time__c',
        type: 'text'
    },
    {
        label: 'Estimated Time Required (In Minutes)',
        fieldName: 'Estimated_Time_Required__c',
        type: 'number'
    },
    {
        label: 'Actual Time Taken',
        fieldName: 'Actual_Time_Taken__c',
        type: 'text'
    },
   
    {
        label: 'Comments',
        fieldName: 'Comments__c',
        type: 'text'
    },
    {
        label: 'Status',
        fieldName: 'Task_Status__c',
        type: 'text'
    }
];

const msLOBForTA = ['TA - Corporate', 'TA - Credentialing', 'TA - Vocational (Batch)', 'TA - Vocational (School)'];

export default class TaskManagerComponent extends LightningElement {

    statusFilterValue = '';
    taskOwnerFilterValue;
    statusOptions;
    showSpinner = true;
    currentUserId = userId;
    @track dragStart;
    error;
    @track taskList = [];
    ListToUpdate = [];
    taskDataToUpdateList = [];
    @api recordId;
    @track showAllTasks = true;
    @track showNewMSTask = false;
    @track jobRecord;
    @track showPriorityUpdateButton = false;
    @track columns = columns;
    @track isTaskRowDraggable = true;
    bureauUserOptions;
    taskCategoryOptions;
    taskTypeOptions;
    recordTypeName;
    recordTypeId;
    taskTypeFieldData;
    componentFirstRun = true;
    @track isJobTA = false;
    currentUserProfileName;
    timezone = TIME_ZONE;

    // Pagination Properties 
    pageSizeOptions = [50, 100, 200, 500]; //Page size options
    records = []; //All records available in the data table
    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number

    get disableFirst() {
        return this.pageNumber == 1;
    }
    get disableLast() {
        return this.pageNumber == this.totalPages;
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    // JS function to handel pagination logic 
    paginationHelper() {
        this.taskList = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.taskList.push(this.records[i]);
        }

        setTimeout(() => {
            const childTimerComponents = this.template.querySelectorAll('c-task-timer-component');
            console.log('childTimerComponents-', childTimerComponents);
            childTimerComponents.forEach( (comp) => { comp.setTimerData() });
        }, 500);
    }

    @wire(MessageContext)
    messageContext;
    subscribeToMessageChannel() {
    console.log('Inside Subscribe');
      this.subscription = subscribe(
        this.messageContext,
        MS_Task_Messages_CHANNEL,
        (message) => this.handleMessage(message)
      );
    }

    handleMessage(message) {
        console.log('Inside handler '+message);
      if(message.TaskCreated == 'True') {
          this.showNewMSTask = false;
          this.fetchTaskList();
      }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
        console.log('MS_Super_User-', this.isSuperUser);
    }

    get isSuperUser() {
        return MS_Super_User;
    }

    //Get user record data
    @wire(getRecord, { recordId: '$currentUserId', fields: [PROFILE_NAME_FIELD] })
    wiredUserRecord({ error, data }) {
        if(data) {
            this.currentUserProfileName = data.fields.Profile.value.fields.Name.value;
            console.log('profile name---',this.currentUserProfileName);
        } else if(error){
            console.log('error found___',error);
        }
    }

    get checkUserProfileAccess() {
        console.log('this.currentUserProfileName---',this.currentUserProfileName);
        return this.currentUserProfileName == 'System Administrator' || this.currentUserProfileName == 'Managed Service Lightning' || this.currentUserProfileName == 'Professional Services' ? true : false;
    }

    fetchBureaUserList() {
        console.log('this.recordTypeName---',this.recordTypeName);

        getBureaUserList({lineOfBusiness:this.recordTypeName})
            .then( result => {
                this.bureauUserOptions = undefined;
                if (result!=null) {
                    
                    let options = [];
                    options.push({ label: "---USERS---", value: null  });
                    for (var key in result) {
                        // Here key will have index of list of records starting from 0,1,2,....
                        options.push({ label: key, value: result[key]  });
                        console.log('key', key, result[key]);
                        // Here Name and Id are fields from sObject list.
                    }
                    getQueueList({lineOfBusiness:this.recordTypeName})
                        .then( result =>{
                            if(result!=null){
                                options.push({ label: "---QUEUE---", value: null  });
                            for (var key in result) {
                                options.push({ label: key, value: result[key] });
                                console.log('key', key, result[key]);
                            }
                        }
                        this.bureauUserOptions = options;
                        console.log('this.bureauUserOptions---',this.bureauUserOptions);
                        })
                        .catch(error => {
                            console.log('error');
                            console.log(error);
                        });
                    
                }
            })
            .catch(error => {
                console.log('error');
                console.log(error);
            });
    }


    fetchTaskList(){
        console.log('inside fetchTaskList', this.statusFilterValue, this.taskOwnerFilterValue);
        this.showSpinner = true;
        getTaskList({taskOwnerValue: this.taskOwnerFilterValue, statusValue: this.statusFilterValue, jobRecordId: this.recordId})
            .then( result => {
                console.log('inside getTaskList', JSON.stringify(result));
                if (result.length > 0) {
                        let taskDataList = result;
                        taskDataList.forEach((taskData) => {

                            //Handle 15 digit id if task owner is queue to fix owner edit functionality.
                            if(!taskData.OwnerId.startsWith('005')) {
                                taskData.OwnerId = taskData.OwnerId.substring(0,15);
                            }
                            
                            //Handle comments editability for template.
                            if(taskData.Comments__c) {

                                let commentLines = taskData.Comments__c.split('\n');

                                for (var i = commentLines.length - 1; i >= 0; i--) {
                                    console.log('commentLines[i]---',commentLines[i]);
                                    if ((commentLines[i].match(/-/g) || []).length === 2 && (commentLines[i].match(/:/g) || []).length === 2 &&
                                        (new Date(commentLines[i]).toString() !== "Invalid Date" && !isNaN(new Date(commentLines[i])))
                                    ) {
                                        let templateData = commentLines.splice(i+1, commentLines.length).join('\n');
                                        console.log('templateData---',templateData);
                                        taskData.Comments_Modified__c = templateData;
                                        break;
                                    }
                                }

                                }

                            //Convert scheduled time from milliseconds to hh:mm:ss
                            if(taskData.Scheduled_Time__c != null && taskData.Scheduled_Time__c != undefined) {
                                taskData.Scheduled_Time__c = this.msToHMS(taskData.Scheduled_Time__c);
                            }

                            //Convert Actual Time value from Minute to time text.
                            if(taskData.Actual_Time_Taken__c) {
                                let timeInMinutes = Number(taskData.Actual_Time_Taken__c);
                                taskData.Actual_Time_Taken__c = this.minuteToHm(timeInMinutes);
                            }

                            let key = this.taskTypeFieldData.controllerValues[taskData.Task_Category__c];
                            taskData.taskTypeOptions = this.taskTypeFieldData.values.filter(opt => opt.validFor.includes(key));

                            let buttonStatus = {
                                showConfirmButton: true,
                                showEditButton: true,
                                showCompleteButton: false,
                                showPlayButton: false,
                                showPauseButton: false,
                                showCancelButton: true,
                                showCloneButton: true
                            };

                            if(
                                (
                                    taskData.OwnerId != this.currentUserId &&
                                    (taskData.Task_Status__c == 'Not Started' || taskData.Task_Status__c == 'Accepted') &&
                                    (this.isSuperUser || this.isCurrentUserProjectManager)
                                ) ||
                                taskData.OwnerId == this.currentUserId
                            ) {
                                buttonStatus.showEditButton = true;
                            } else {
                                buttonStatus.showEditButton = false;
                            }

                            if(taskData.OwnerId != this.currentUserId || (taskData.Task_Status__c && taskData.Task_Status__c == 'Completed')) {
                                buttonStatus.showCompleteButton = false;
                                buttonStatus.showPlayButton = false;
                                buttonStatus.showPauseButton = false;
                            }

                            if(taskData.Task_Status__c && taskData.Task_Status__c == 'Completed') {
                                buttonStatus.showEditButton = false;
                            }

                            if(taskData.Task_Status__c && taskData.Task_Status__c == 'Completed' && this.isSuperUser) {
                                buttonStatus.showEditButton = true;
                            }

                            if(
                                (taskData.OwnerId == this.currentUserId && taskData.Task_Status__c && taskData.Task_Status__c == 'In Progress') ||
                                (taskData.Task_Status__c == 'In Progress' && this.isSuperUser)
                            ) {
                                buttonStatus.showCompleteButton = true;
                            }

                            buttonStatus.showCancelButton = ((taskData.Task_Status__c == 'Not Started' || taskData.Task_Status__c == 'Accepted') && taskData.OwnerId == this.currentUserId) || (taskData.Task_Status__c == 'Not Started' && this.isCurrentUserProjectManager) ? true : false;

                            if(taskData.Task_Status__c && taskData.Task_Status__c != 'Not Started' ) {
                                buttonStatus.showConfirmButton = false;
                            }

                            // if(taskData.OwnerId && taskData.OwnerId.startsWith('005') ) {
                            //     buttonStatus.showConfirmButton = false;
                            // }

                            if(taskData.OwnerId && taskData.OwnerId.startsWith('005') && (taskData.Task_Status__c == 'Not Started' || taskData.Task_Status__c == 'Accepted') ) {
                                buttonStatus.showConfirmButton = true;
                            }

                            if(taskData.OwnerId == this.currentUserId) {
                                buttonStatus.showConfirmButton = false;
                            }

                            if(taskData.OwnerId == this.currentUserId && !taskData.Task_Start_Time__c) {
                                buttonStatus.showPlayButton = true;
                                buttonStatus.showPauseButton = false;
                            }

                            if(taskData.Task_Status__c == 'Cancelled') {
                                buttonStatus.showConfirmButton = false;
                                buttonStatus.showEditButton = false;
                                buttonStatus.showCompleteButton = false;
                                buttonStatus.showPlayButton = false;
                                buttonStatus.showPauseButton = false;
                                buttonStatus.showCancelButton = false;
                            }

                            // Dont allow task clone in completed, closed and cancelled job status
                            if(this.msTaskButtonDisabled) {
                                buttonStatus.showCloneButton = false;
                            }

                            if(taskData.OwnerId == this.currentUserId && taskData.Task_Status__c != 'Completed' && taskData.Task_Status__c != 'Cancelled' && taskData.Task_Start_Time__c) {
                                console.log('Id---', taskData.Id);
                                console.log(taskData.Timer_Stopped_At__c, taskData.Timer_Resumed_At__c);
                                if(!taskData.Timer_Stopped_At__c) {
                                    console.log('inside 1st');
                                    buttonStatus.showPlayButton = false;
                                    buttonStatus.showPauseButton = true;
                                }
                                if(taskData.Timer_Stopped_At__c && !taskData.Timer_Resumed_At__c) {
                                    console.log('inside 2nd');
                                    buttonStatus.showPlayButton = true;
                                    buttonStatus.showPauseButton = false;
                                }
                                if(taskData.Timer_Stopped_At__c && taskData.Timer_Resumed_At__c
                                    && new Date(taskData.Timer_Stopped_At__c).getTime() < new Date(taskData.Timer_Resumed_At__c).getTime()
                                ) {
                                    console.log('inside 3rd');
                                    buttonStatus.showPlayButton = false;
                                    buttonStatus.showPauseButton = true;
                                }
                                if(taskData.Timer_Stopped_At__c && taskData.Timer_Resumed_At__c
                                    && new Date(taskData.Timer_Stopped_At__c).getTime() > new Date(taskData.Timer_Resumed_At__c).getTime()
                                ) {
                                    console.log('inside 3rd');
                                    buttonStatus.showPlayButton = true;
                                    buttonStatus.showPauseButton = false;
                                }
                                }

                            //Hide action buttons if profile access is not there.
                            if(!this.checkUserProfileAccess) {
                                buttonStatus.showConfirmButton = false;
                                buttonStatus.showEditButton = false;
                                buttonStatus.showCompleteButton = false;
                                buttonStatus.showPlayButton = false;
                                buttonStatus.showPauseButton = false;
                                buttonStatus.showCancelButton = false;
                                buttonStatus.showCloneButton = false;
                            }

                            // add buttonStatus object into original task data list for conditional rendering of action buttons.
                            taskData.buttonStatus = buttonStatus;

                            // status logic
                            taskData = this.calculateTaskStatus(taskData);  
                            console.log('taskData.displayCount '+taskData.displayCount);
                        });
                        // SSE-18926  Sort Tasks based on Task Status and Last Modified Date Added by Aashi
                        taskDataList.sort((a,b) => a.displayCount - b.displayCount || b.dateOrder - a.dateOrder);
                        // SSE-18926  Added Serial Number by Aashi
                        taskDataList.forEach((taskData, index) => {
                            taskData.serialNumber = index + 1;
                        });
                        // this.taskList = taskDataList;
                        // console.log('success---', this.taskList);
                        // console.log(Object.assign({}, this.taskList));
                        // this.template.querySelector('[name="recordsPerPage"]').selectedIndex = 0;
                        this.records = taskDataList;
                    } else {
                        this.taskList = null;
                        this.records = [];
                    }
                    this.totalRecords = this.records.length; // update total records count                 
                    this.pageSize = this.pageSize ? this.pageSize : this.pageSizeOptions[0]; //set pageSize with default value as first option
                    this.paginationHelper(); // call helper menthod to update pagination logic

                this.showSpinner = false;
                })
            .then(data => {
                setTimeout(() => {
                    const childTimerComponents = this.template.querySelectorAll('c-task-timer-component');
                    console.log('childTimerComponents-', childTimerComponents);
                    childTimerComponents.forEach( (comp) => { comp.setTimerData() });
                }, 500);
            })
            .catch(error => {
                console.log('error', error);
                this.error = error.body ? error.body.message : error;
                this.showSpinner = false;
            });
    }

    calculateTaskStatus(taskData) {

         if(taskData.Task_Status__c=='Completed'){
            taskData.Status = 'Done';
            taskData.StatusMessage ='Completed';
        }else if(taskData.Task_Status__c=='In Progress'){
            taskData.Status = 'Processing';
            taskData.StatusMessage ='In Progress';
        }else if(taskData.Task_Status__c=='Cancelled'){
            taskData.Status = 'R';
            taskData.StatusMessage ='Cancelled';
        }else if(taskData.Task_Date__c != null){
            const date = new Date();
            let todayDate = new Date([date.getFullYear(), date.getMonth() + 1, date.getDate()].join('-'));
            let activityDate = new Date(taskData.Task_Date__c.toString());
            let Difference_In_Time = todayDate.getTime() - activityDate.getTime();
            var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            Difference_In_Days = Math.ceil(Difference_In_Days);
            if(activityDate<todayDate){
                taskData.Status = 'Overdue';
                taskData.StatusMessage ='Overdue by ' + Difference_In_Days + ' days';
            }else{
                taskData.Status = 'Due';
                taskData.StatusMessage ='Due in ' + (-1)*Difference_In_Days + ' days';
            }
            if(Difference_In_Days == 0) {
                taskData.StatusMessage ='Due Today';
            }
        } else {
            taskData.Status = taskData.Task_Status__c;
            taskData.StatusMessage = taskData.Task_Status__c;
        }
        
        // SSE-18926  Setting "diplayCount" based on Task Status in blow block - Added by Aashi
        if(taskData.Status == 'Done') {
            taskData.statusIconName = 'action:approval';
            taskData.statusBackgroundColor = 'green';
            taskData.displayCount = 5;
            let dateToUse;
            if(taskData.Task_Completed_On__c){
                dateToUse = taskData.Task_Completed_On__c;
            }
            else {
                dateToUse = taskData.Task_End_Time__c;
            }
            taskData.dateOrder = new Date(dateToUse).getTime();
        } else if(taskData.Task_Status__c=='Cancelled') {
            taskData.statusBackgroundColor = 'grey';
            taskData.displayCount = 6;
            taskData.dateOrder = 0;
        } else if(taskData.Status == 'Due') {
            taskData.statusIconName = 'action:defer';
            taskData.statusBackgroundColor = 'yellow';
            taskData.displayCount = 3;
            taskData.dateOrder = 0;
        } else if(taskData.Task_Status__c=='Not Started' && !taskData.Task_Date__c) {
            taskData.statusBackgroundColor = 'transparent';
            taskData.displayCount = 4;
            taskData.dateOrder = 0;
        } else if(taskData.Status == 'Accepted') {
            taskData.statusBackgroundColor = 'orange';
            taskData.displayCount = 2;
            taskData.dateOrder = 0;
        } else if(taskData.Status == 'Processing'){
            taskData.statusBackgroundColor = 'blue';
            taskData.displayCount = 1;
            taskData.dateOrder = 0;
        } else {
            taskData.statusIconName = 'action:info';
            taskData.statusBackgroundColor = 'red';
            taskData.displayCount = 0;
            taskData.dateOrder = 0;
        }
        taskData.statusBackgroundColor += ' task-status-column';
        return taskData;
    }

    calculateFieldsEditability(taskData, editAction) {
        console.log('editAction+++',editAction);

        if(editAction == 'Discard') {
            taskData.Owner__Editable = false;
            taskData.Task_Category__Editable = false;
            taskData.Task_Type__Editable = false;
            taskData.Task_Date__Editable = false;
            taskData.Scheduled_Time__Editable = false;
            taskData.Actual_Time_Taken__Editable = false;
            taskData.UnScheduled__Editable = false;
            taskData.Comments__Editable = false;
            taskData.Estimated_Time_Required__Editable = false;

            taskData.editMode = false;

            return taskData;
        }

        if(this.isSuperUser && taskData.Task_Status__c == 'Completed') {
            taskData.Actual_Time_Taken__Editable = true;
            
            taskData.editMode = true;
        } 
        
        if( taskData.OwnerId == this.currentUserId && (taskData.Task_Status__c == 'Accepted' || taskData.Task_Status__c == 'In Progress') ) {
            taskData.Comments__Editable = true;
            taskData.Task_Date__Editable = true;
            
            taskData.editMode = true;
        }

        if(
            (this.isSuperUser || this.isCurrentUserProjectManager) &&
            (taskData.Task_Status__c == 'Not Started' || taskData.Task_Status__c == 'Accepted')
        ) {
            taskData.Owner__Editable = true;
            taskData.Task_Category__Editable = true;
            taskData.Task_Type__Editable = true;
            taskData.Task_Date__Editable = true;
            taskData.Scheduled_Time__Editable = true;
            taskData.UnScheduled__Editable = true;
            taskData.Comments__Editable = true;
            taskData.Estimated_Time_Required__Editable = true;
            

            taskData.editMode = true;
        }

        if(
            this.isSuperUser &&
            taskData.Task_Status__c == 'Completed'
        ) {
            taskData.Comments__Editable = true;
            taskData.editMode = true;
        }

        //Allow only Owner Date and Comment field editable for MS User in clone mode.
        if(taskData.cloneMode && !this.isSuperUser && !this.isCurrentUserProjectManager) {
            taskData.Owner__Editable = true;
            taskData.Task_Category__Editable = true;
            taskData.Task_Type__Editable = true;
            taskData.Task_Date__Editable = true;
            taskData.Scheduled_Time__Editable = true;
            taskData.UnScheduled__Editable = true;
            taskData.Comments__Editable = true;
            taskData.Estimated_Time_Required__Editable = true;
        }

        return taskData;

    }

    minuteToHm(d){
        d = Number(d)
        const h = Math.floor(d / 60);
        const m = d % 60;
        const hDisplay = h > 0 ? h + (h == 1 ? ' hour, ' : ' hours, ') : '';
        const mDisplay = m > 0 ? m + (m == 1 ? ' minute ' : ' minutes ') : '';
        return hDisplay + mDisplay;// + sDisplay; 
    }

   //Get Job record data
    @wire(getRecord, { recordId: '$recordId', fields: [PROJECT_MANAGER_FIELD, MS_LOB_FIELD,MS_Status_FIELD] })
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
                    title: 'Error loading Job Record',
                    message,
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        } else if (data) {
            this.jobRecord = data;

            if(this.JobStatusValue ==='Completed' || this.JobStatusValue ==='Cancelled' || this.JobStatusValue==='Closed'){
               this.showNewMSTask=false;
            }

            if(this.MSLob == 'TA - Corporate' || this.MSLob == 'TA - Credentialing'){
                this.recordTypeName = 'TA - Corporate';
            }
            else if(this.MSLob == 'TA - Vocational (Batch)' || this.MSLob == 'TA - Vocational (School)'){
                this.recordTypeName = 'TA - Vocational';
            }
            else if(this.MSLob == 'Talent Management'){
                this.recordTypeName = 'Talent Management';
            }
            else if(this.MSLob == 'TA - Vocational (Analytics)' || this.MSLob == 'Talent Management (Dashboards)'){
                this.recordTypeName = 'MS Analytics';
            }
            getTaskRecordTypeName({taskRecordTypeName:this.recordTypeName})
                .then((result) =>{
                    this.recordTypeId = result;
                    console.log('method return '+this.recordTypeId);
                    this.fetchBureaUserList();
                })
                .catch((error) => {
                    console.log(error);
                });

            if(msLOBForTA.includes(this.MSLob)) {
                this.isJobTA = true;
            }

            
        }
    }

    get projectManagerValue() {
        return getFieldValue(this.jobRecord, PROJECT_MANAGER_FIELD);
    }

    get isCurrentUserProjectManager() {
        return this.projectManagerValue == userId ? true : false;
    }

    get JobStatusValue(){
        return getFieldValue(this.jobRecord, MS_Status_FIELD);
    }

    get msTaskButtonDisabled(){
        let isDisabled=false;
        if(this.JobStatusValue ==='Completed' || this.JobStatusValue ==='Cancelled' || this.JobStatusValue==='Closed'){
           isDisabled=true;
        }
        return isDisabled;
    }

    get msTaskButtonHelpText(){
        let helpText='';
        if(this.JobStatusValue ==='Completed' || this.JobStatusValue ==='Cancelled' || this.JobStatusValue==='Closed'){
            helpText='You cannot create task(s) on a Completed or Cancelled Job';
         }
         return helpText;
    }

    get MSLob() {
        return getFieldValue(this.jobRecord, MS_LOB_FIELD);
    }

    // GET OBJECT INFO
    @wire (getObjectInfo, {objectApiName: TASK_OBJECT})
    taskObjectInfo  

    // GET PICKLIST VALUES 
    @wire (getPicklistValues, {recordTypeId: '012000000000000AAA', fieldApiName: STATUS_FIELD})
    wiredPicklistValues({ error, data }) {
         // reset values to handle eg data provisioned then error provisioned
         this.statusOptions = undefined;
        if (data) {
            this.statusOptions = [  {label: 'All', value: ''}, ...data.values ];
        } else if (error) {
            console.log(error);
        }
    } 

    @wire (getPicklistValues, {recordTypeId: '$recordTypeId' , fieldApiName: TASK_CATEGORY_FIELD})
    wiredTaskCategoryValues({ error, data }) {
         // reset values to handle eg data provisioned then error provisioned
         this.taskCategoryOptions = undefined;
        if (data) {
            this.taskCategoryOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire (getPicklistValues, {recordTypeId: '$recordTypeId' , fieldApiName: TASK_TYPE_FIELD})
    wiredTaskTypeValues({ error, data }) {
         // reset values to handle eg data provisioned then error provisioned
        this.taskTypeFieldData = undefined;
        if (data) {
            this.taskTypeFieldData = data;
            console.log('Dependent values '+JSON.stringify(this.taskTypeFieldData));
            this.fetchTaskList();
        } else if (error) {
            console.log(error);
        }
    }

    handleTaskCreationStatus(event) {
        console.log('inside handleTaskCreationStatus', event.detail);
        if(event.detail && event.detail == 'success') {
            this.fetchTaskList();
        }
    }

    handleSpinnerAction(event) {
        console.log('inside handleSpinnerAction', event.detail);
        if(event.detail && event.detail == 'true') {
            this.showSpinner = true;
        }

        if(event.detail && event.detail == 'false') {
            this.showSpinner = false;
        }
    }

    handleStatusChange(event) {
        this.statusFilterValue = event.detail.value;
        this.pageNumber = 1;
        // Show filtered data on status change.
        this.fetchTaskList();
    }

    handleTaskOwnerFilterValue(event) {
        this.taskOwnerFilterValue = event.detail.value;
    }

    handleEnter(event) {
        if(event.keyCode === 13){
            this.handleSearchAction();
        }
    }

    handleSearchAction(event) {
        this.pageNumber = 1;
        //filter records
        console.log('inside search action');
        this.fetchTaskList();
    }

    handleAddTask(event) {

    }

    handleConfirmAction(event) {
        console.log('inside confirm action');
        this.showSpinner = true;
        const taskId = event.target.dataset.id;
        // update task owner id with current user id.
        assignTaskToCurrentUser({taskId: taskId})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Task Assigned Successfully',
                    variant: 'success',
                    duration: 2000
                })
            );
            this.fetchTaskList();
        })
        .catch(error => {
            console.log(error);
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in Assigning Task!',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            if(error.body && error.body.message == 'Task already assigned to owner') {
                this.fetchTaskList();
            }
        });

    }

    handleEditAction(event) {
        console.log('inside edit action');
        let taskId = event.target.dataset.id;
        
        this.taskList.map((taskData) => {
            if(taskData && taskData.Id == taskId) {
                taskData = this.calculateFieldsEditability(taskData);
            }
            return taskData;
        });
    }

    handleCompleteAction(event) {
        this.showSpinner = true;
        const taskId = event.target.dataset.id;
        let startTime;
        let stopTime;
        let currentTimerAction;
        let currentTime = new Date().toISOString();
        this.taskList.map((taskData) => {
            if(taskData && taskData.Id == taskId) {
                startTime = taskData.Task_Start_Time__c;
            
                if(!taskData.Timer_Stopped_At__c) {
                    currentTimerAction = 'Pause';
                }
                if(taskData.Timer_Stopped_At__c && !taskData.Timer_Resumed_At__c) { 
                    currentTimerAction = 'Play';
                }
                if(taskData.Timer_Stopped_At__c && taskData.Timer_Resumed_At__c
                    && new Date(taskData.Timer_Stopped_At__c).getTime() < new Date(taskData.Timer_Resumed_At__c).getTime()
                ) { 
                    currentTimerAction = 'Pause';
                }
                if(taskData.Timer_Stopped_At__c && taskData.Timer_Resumed_At__c
                    && new Date(taskData.Timer_Stopped_At__c).getTime() > new Date(taskData.Timer_Resumed_At__c).getTime()
                ) { 
                    currentTimerAction = 'Play';
                }

                if(currentTimerAction == 'Pause') {
                    stopTime = currentTime;
                } else {
                    stopTime = taskData.Timer_Stopped_At__c;
                }

            }

            return taskData;
        });
        
        // Update the task as completed
        completeTask({taskId: taskId, startTime: startTime, stopTime: stopTime, currentTime: currentTime})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Task Completed Successfully',
                    variant: 'success',
                    duration: 2000
                })
            );
            this.fetchTaskList();
        })
        .catch(error => {
            console.log(error);
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in Completing Task!',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        });
    }

    handleCancelAction(event) {
        
        this.showSpinner = true;
        const taskId = event.target.dataset.id;
        // Update the task as cancelled
        cancelTask({taskId: taskId})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Task Cancelled Successfully',
                    variant: 'success',
                    duration: 2000
                })
            );
            this.fetchTaskList();
        })
        .catch(error => {
            console.log(error);
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in Cancelling Task!',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        });
    }

    handleCloneAction(event) {

        this.showSpinner = true;
        const taskId = event.target.dataset.id;
        let rowIndex = event.target.dataset.index;
        rowIndex = Number(rowIndex);
        // let taskListToClone = [];
        let taskObject = {};

        this.taskList.map((taskData) => {
            if(taskData && taskData.Id == taskId) {
                console.log(JSON.parse(JSON.stringify(taskData)));
                console.log(JSON.parse(JSON.stringify(taskData.Owner)));
                taskObject.OwnerId = taskData.OwnerId;
                taskObject.Owner = taskData.Owner;
                taskObject.RecordTypeId = taskData.RecordTypeId;
                taskObject.Task_Category__c = taskData.Task_Category__c;
                taskObject.Task_Type__c = taskData.Task_Type__c;
                taskObject.Task_Date__c = taskData.Task_Date__c;
                taskObject.UnScheduled__c = taskData.UnScheduled__c;
                taskObject.Task_Status__c = taskData.OwnerId.startsWith('005') ? 'Accepted' : 'Not Started';
                taskObject.Job__c = this.recordId;
                taskObject.Job_Region__c = taskData.Job_Region__c;
                taskObject.Estimated_Time_Required__c = taskData.Estimated_Time_Required__c;
                taskObject.cloneMode = true;
                taskObject.editMode = true;
                taskObject.index = rowIndex + 1;
                taskObject = this.calculateFieldsEditability(taskObject);

                if(taskObject.Task_Category__c) {
                    let key = this.taskTypeFieldData.controllerValues[taskObject.Task_Category__c];
                    taskObject.taskTypeOptions = this.taskTypeFieldData.values.filter(opt => opt.validFor.includes(key));
                }
            }
            return taskData;
        });

        this.taskList.splice(rowIndex + 1, 0 , taskObject);
        taskObject.cloneElementIndex = this.taskDataToUpdateList.length;
        this.taskDataToUpdateList.push(taskObject);
        this.showSpinner = false;

        
    }

    handleTimerPlaybackAction(event) {
        const taskId = event.target.dataset.id;
        const playbackAction = event.target.dataset.playback;
        if(playbackAction == 'play') {
            event.target.iconName = 'utility:pause';
            event.target.dataset.playback = 'pause';
            event.target.title = 'Pause';
            setTimeout(() => {
                let childTimerComponents = this.template.querySelectorAll('c-task-timer-component');
                childTimerComponents.forEach( (comp) => { 
                    if(comp.taskId == taskId) {

                        this.taskList.map((taskData) => {
                            if(taskData && taskData.Id == taskId) {
                                const startOrResumeTime = new Date().toISOString();
                                taskData.buttonStatus.showPlayButton = false;
                                taskData.buttonStatus.showPauseButton = true;
                                if(!comp.taskStartTime) {
                                    comp.taskStartTime = startOrResumeTime;
                                    comp.startOrResumeAction = 'startTimer';
                                    taskData.Task_Start_Time__c = startOrResumeTime;
                                    taskData.Task_Status__c = 'In Progress';
                                    taskData.buttonStatus.showCompleteButton = true;
                                    taskData.buttonStatus.showCancelButton = false;
                                    
                                    taskData = this.calculateTaskStatus(taskData);

                                } else {
                                    comp.timerResumedAt = startOrResumeTime;
                                    taskData.Timer_Resumed_At__c = startOrResumeTime;
                                    const offsetSecsDiff = new Date().getTime() - new Date(taskData.Timer_Stopped_At__c).getTime();
                                    const newTimerOffsetValue = taskData.Timer_Offset__c ? Number(taskData.Timer_Offset__c) + offsetSecsDiff + 500 : offsetSecsDiff;
                                    comp.timerOffset = newTimerOffsetValue;
                                    comp.startOrResumeAction = 'resumeTimer';
                                    taskData.Timer_Offset__c = newTimerOffsetValue;
                                }
                            }
                            return taskData;
                        });
                        comp.resumeTimer();
                    }
                });
            }, 500);
        }
        if(playbackAction == 'pause') {
            event.target.iconName = 'utility:play';
            event.target.dataset.playback = 'play';
            event.target.title = 'Play';
            setTimeout(() => {
                let childTimerComponents = this.template.querySelectorAll('c-task-timer-component');
                childTimerComponents.forEach( (comp) => { 
                    if(comp.taskId == taskId) {
                        let timerStoppedAt = new Date().toISOString();
                        comp.timerStoppedAt = timerStoppedAt;
                        this.taskList.map((taskData) => {
                            if(taskData && taskData.Id == taskId) {
                                taskData.buttonStatus.showPlayButton = true;
                                taskData.buttonStatus.showPauseButton = false;
                                taskData.Timer_Stopped_At__c = timerStoppedAt;
                            }
                            return taskData;
                        });
                        comp.stopTimer();
                    }
                });
            }, 500);
        }
    }
    handleCommentEdit(event) {
        let taskId = event.target.dataset.id;
        
        this.taskList.map((taskData) => {
            if(taskData && taskData.Id == taskId) {
                taskData.editMode = true;
                taskData.Comments__Editable = true;
            }
            return taskData;
        });
    }

    handleTaskDataEdit(event) {
        let taskFieldName = event.target.dataset.fieldname;
        let taskId = event.target.dataset.id;
        let rowindex = event.target.dataset.index;
        let cloneIndex = event.target.dataset.cloneindex;
        let taskFieldValue = taskFieldName == 'UnScheduled__c' ? event.detail.checked : event.detail.value;
        console.log('taskFieldValue--',taskFieldValue);
        
        
        if(taskFieldName == 'Task_Category__c') {
            this.taskList.map((taskData, index) => {
                if(taskData && taskData.cloneMode && rowindex == index) {
                    console.log('inside dynamic picklist');
                    let key = this.taskTypeFieldData.controllerValues[taskFieldValue];
                    taskData.taskTypeOptions = this.taskTypeFieldData.values.filter(opt => opt.validFor.includes(key));
                }
                else if(taskData && taskData.Id && taskData.Id == taskId) {
                    let key = this.taskTypeFieldData.controllerValues[taskFieldValue];
                    taskData.taskTypeOptions = this.taskTypeFieldData.values.filter(opt => opt.validFor.includes(key));     
                }
                return taskData;
            });
        }


         if(this.taskDataToUpdateList && this.taskDataToUpdateList.length > 0) {
                let taskDataExist = false;
                this.taskDataToUpdateList.map((taskData, index) => {
                    if(taskData && taskData.cloneMode && cloneIndex == index) {
                        console.log('inside cloned element');
                        taskDataExist = true;
                        taskData[taskFieldName] = taskFieldValue;
                    }
                    else if(taskData && taskData.Id && taskData.Id == taskId) {
                        taskDataExist = true;
                        taskData[taskFieldName] = taskFieldValue;
                    }
                    return taskData;
                });

                if(!taskDataExist) {
                    console.log('inside new element');
                    this.taskDataToUpdateList.push({
                        'sobjectType': 'MS_Task__c',
                        'Id': taskId,
                        [taskFieldName]: taskFieldValue
                    });
                }
            } else {
                console.log('inside empty list');
                this.taskDataToUpdateList.push({
                    'sobjectType': 'MS_Task__c',
                    'Id': taskId,
                    [taskFieldName]: taskFieldValue
                });
            }
        // }
    }

    handleRowEditAction(event) {
        let taskId = event.target.dataset.id;
        let action = event.target.dataset.action;
        let rowIndex = event.target.dataset.index;
        let cloneIndex = event.target.dataset.cloneindex;
        let cloneMode = event.target.dataset.clonemode;


        if(action == 'Save' && this.taskDataToUpdateList.length > 0) {
            this.showSpinner = true;
            let finalListToUpdate = [];
            console.log('taskId###',taskId);
            console.log('taskDataToUpdateList***', JSON.stringify(this.taskDataToUpdateList));

            const All_Field_Valid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, input_Field_Reference) => {
                input_Field_Reference.reportValidity();
                return validSoFar && input_Field_Reference.checkValidity();
            }, true);

            if(!All_Field_Valid) {
                this.showSpinner = false;
                return;
            }

            this.taskDataToUpdateList.forEach((taskData, index) => {
                console.log('taskData^^^',taskData);
                // if(taskData && taskData.Id == taskId) {
                if((taskData.Id && taskData.Id == taskId) || cloneIndex == index) {
                    if(cloneMode) {
                        let taskObject = {};
                        taskObject.OwnerId = taskData.OwnerId;
                        taskObject.RecordTypeId = taskData.RecordTypeId;
                        taskObject.Task_Category__c = taskData.Task_Category__c;
                        taskObject.Task_Type__c = taskData.Task_Type__c;
                        taskObject.Task_Date__c = taskData.Task_Date__c;
                        taskObject.Scheduled_Time__c = taskData.Scheduled_Time__c ? taskData.Scheduled_Time__c + 'Z' : taskData.Scheduled_Time__c;
                        taskObject.UnScheduled__c = taskData.UnScheduled__c;
                        taskObject.Task_Status__c = taskData.OwnerId.startsWith('005') ? 'Accepted' : 'Not Started';
                        taskObject.Comments__c = taskData.Comments__c;
                        taskObject.Job__c = this.recordId;
                        taskObject.Job_Region__c = taskData.Job_Region__c;
                        taskObject.Estimated_Time_Required__c = taskData.Estimated_Time_Required__c;
                        finalListToUpdate.push(taskObject);
                    } else {
                        let existingTaskData;
                        this.taskList.forEach((taskDataValue) => {
                            if(taskDataValue.Id == taskId) {
                                existingTaskData = taskDataValue;
                                return;
                            }
                        });
                        if(taskData.OwnerId && (existingTaskData.Task_Status__c == 'Accepted' || existingTaskData.Task_Status__c == 'Not Started')) {
                            taskData.Task_Status__c = taskData.OwnerId.startsWith('005') ? 'Accepted' : 'Not Started';
                        }
                        finalListToUpdate.push(taskData);
                    }
                }
            });
            console.log('finalListToUpdate***', finalListToUpdate);
            if(cloneMode) {
                cloneTasks({jsonOfListOfTasks: JSON.stringify(finalListToUpdate), jobRecordId: this.recordId})
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Task Cloned Successfully',
                            variant: 'success',
                            duration: 2000
                        })
                    );
                    this.taskDataToUpdateList = [];
                    this.fetchTaskList();
                })
                .catch(error => {
                    console.log(error);
                    this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in Cloning Task!',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
            } else {
                updateTaskRowData({ taskToUpdateList: finalListToUpdate })
                .then((result) => {
                    console.log('result*****', result);
                    this.taskDataToUpdateList = [];
                    this.fetchTaskList();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Task Updated Successfully',
                            variant: 'success',
                            duration: 2000
                        })
                    );
                    this.showSpinner = false;
                })
                .catch((error) => {
                    console.log('Error***', error);
                    console.log("###Error : ", error.body ? error.body.message : error.body);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in Updating Task!',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    this.showSpinner = false;
                });
            }
        }

        if(action == 'Discard') {

            if(cloneMode) {
                this.taskList.splice(rowIndex, 1);
                this.taskDataToUpdateList.splice(cloneIndex, 1);
            } else {
                let task;
                this.taskList.map((taskData) => {
                    if(taskData && taskData.Id == taskId) {
                        task = taskData;
                        taskData = this.calculateFieldsEditability(taskData, 'Discard');
                    }
                    return taskData;
                });

                setTimeout(() => {
                    let childTimerComponents = this.template.querySelectorAll('c-task-timer-component');
                    console.log('childTimerComponents-', childTimerComponents);
                    childTimerComponents.forEach( (comp) => {
                        if(comp.taskId == taskId) {
                            console.log('task.Task_Start_Time__c--',task.Task_Start_Time__c);
                            comp.taskStartTime = task.Task_Start_Time__c;
                            comp.timerStoppedAt = task.Timer_Stopped_At__c;
                            comp.timerResumedAt = task.Timer_Resumed_At__c;
                            comp.timerOffset = task.Timer_Offset__c;
                            comp.setTimerData();
                        }
                    });
                }, 500);
            }

            
        }
    }

    handleActive(event) {
        console.log('inside handleActive');

        if(this.componentFirstRun) {
            console.log('componentfirst run '+this.componentFirstRun);
            this.componentFirstRun = false;
            return;
        }

        const tabValue = event.target.value;
        console.log('tab value '+tabValue);
        if(tabValue == '1') {
            this.showAllTasks = true;
            this.taskOwnerFilterValue = '';
            this.fetchTaskList();
        }

        if(tabValue == '2') {
            this.showAllTasks = false;
            this.taskOwnerFilterValue = this.currentUserId;
            this.fetchTaskList();
        }
    }

    handleShowMSTask() {
        this.showNewMSTask = this.showNewMSTask ? false : true;
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

   handleRefreshList() {
        this.fetchTaskList();
   }
    
}