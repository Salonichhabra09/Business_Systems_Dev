import { LightningElement,wire,track,api } from 'lwc';
import { getObjectInfo ,getPicklistValues} from 'lightning/uiObjectInfoApi';
import getTaskList from '@salesforce/apex/MsCandidateDataTableController.getMSTaskDetails';
import MS_Task__c from '@salesforce/schema/MS_Task__c';
import MS_Status_FIELD from "@salesforce/schema/Job__c.JobStatus__c";
import userId from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PROJECT_MANAGER_FIELD from '@salesforce/schema/Job__c.Project_Manager__c';
import MS_LOB_FIELD from "@salesforce/schema/Job__c.MS_Line_of_Business__c";
import assignTaskToCurrentUser from '@salesforce/apex/TaskManagerController.assignTaskToCurrentUser';
import UpdateTasks from '@salesforce/apex/TaskManagerController.updateTaskPriority';
import updateTaskRowData from '@salesforce/apex/MsCandidateDataTableController.updateTaskRowData';
import completeTask from '@salesforce/apex/TaskManagerController.completeTask';
import cancelTask from '@salesforce/apex/TaskManagerController.cancelTask';
import { subscribe, MessageContext } from 'lightning/messageService';
import MS_Task_Messages_CHANNEL from '@salesforce/messageChannel/MS_Task_Messages__c';
import Id from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';
import cloneTasks from '@salesforce/apex/MsCandidateDataTableController.cloneTasks';
import TASK_CATEGORY_FIELD from '@salesforce/schema/MS_Task__c.Task_Category__c';
import TASK_TYPE_FIELD from '@salesforce/schema/MS_Task__c.Task_Type__c';
import getTaskRecordTypeName from '@salesforce/apex/BulkMSTaskCreationController.getTaskRecordTypeId';

const columns = [  
    {
        label: 'Actions',
        fieldName: '',
        type: ''
    },
    {
        label: 'Task Category',
        fieldName: 'Task_Category__c',
        type: 'text'
    },
    {
        label: 'Task Type',
        fieldName: 'Task_Type__c',
        type: 'text'
    },
    {
        label: 'Systems',
        fieldName: 'Systems__c',
        type: 'text'
    },
    {
        label: 'Task Date',
        fieldName: 'Task_Date__c',
        type: 'text'
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
        label: 'Created Date',
        fieldName: 'CreatedDate',
        type: 'text'
    },
    {
        label: 'Status',
        fieldName: 'Task_Status__c',
        type: 'text'
    }
];  

export default class GeneralMSTaskGridView extends LightningElement {
    columns=columns;
    msTaskItems;
    showcreationpage=false;
    statusOptions = [
        { value: '', label: ' All ' },
        { value: 'In Progress', label: 'In Progress' },
        { value: 'Completed', label: 'Completed' },
    ];

    statusFilterValue = '';
    taskOwnerFilterValue;
    showSpinner = true;
    currentUserId = userId;
    @track dragStart;
    error;
    @track taskList ;
    taskownername;
    ListToUpdate = [];
    taskDataToUpdateList = [];
    @api recordId;
    @track showAllTasks = true;
    @track showNewMSTask = false;
    @track jobRecord;
    @track showPriorityUpdateButton = false;
    columns = columns;
    @track isTaskRowDraggable = true;
    bureauUserOptions;
    taskCategoryOptions;
    taskTypeOptions;
    recordTypeName;
    currentUserName;
    userId=Id;
    isReadOnly=true;
    taskTypeFieldData;
    @track recordTypeInfo;
    @wire(getRecord, { recordId: '$userId', fields: [UserNameFld ]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
        } else if (error) {
            this.error = error ;
        }

        getTaskRecordTypeName({taskRecordTypeName:'General MS Task'})
                .then((result) =>{
                    this.recordTypeInfo = result;
                    console.log('method return '+this.recordTypeId);
                })
                .catch((error) => {
                    console.log(error);
                });
    }

    @wire (getPicklistValues, {recordTypeId: '$recordTypeInfo' , fieldApiName: TASK_CATEGORY_FIELD})
    wiredTaskCategoryValues({ error, data }) {
         // reset values to handle eg data provisioned then error provisioned
         this.taskCategoryOptions = undefined;
        if (data) {
            this.taskCategoryOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire (getPicklistValues, {recordTypeId: '$recordTypeInfo' , fieldApiName: TASK_TYPE_FIELD})
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

    @wire(MessageContext)
    messageContext;
    subscribeToMessageChannel() {
      this.subscription = subscribe(
        this.messageContext,
        MS_Task_Messages_CHANNEL,
        (message) => this.handleMessage(message)
      );
    }

    @wire(getObjectInfo, { objectApiName: MS_Task__c })
    objectInfo;

    get recordTypeId() {
        console.log('get recordtypeid');
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        console.log('rtis'+JSON.stringify(rtis));
       Object.keys(rtis).find(rti => rtis[rti].name === 'General MS Task');
        return Object.keys(rtis).find(rti => rtis[rti].name === 'General MS Task');;
    }

    handleMessage(message) {
        console.log('Inside handler '+message);
      if(message.TaskCreated == 'True') {
          this.showNewMSTask = false;
          this.fetchTaskList();
      }
    }

    connectedCallback() {
        this.fetchTaskList();
        this.subscribeToMessageChannel();
        console.log('MS_Super_User-', this.isSuperUser);
    }

   
    fetchTaskList(){
        console.log('inside fetchTaskList', this.statusFilterValue);
        this.showSpinner = true;
        getTaskList({ statusValue: this.statusFilterValue})
            .then( result => {
                console.log('inside getTaskList', JSON.stringify(result));
                if (result.length > 0) {
                        let taskDataList = result;
                        this.showPriorityUpdateButton = this.isCurrentUserProjectManager ? true : false;
                        taskDataList.forEach((taskData) => {

                            //Convert scheduled time from milliseconds to hh:mm:ss
                            if(taskData.Scheduled_Time__c != null && taskData.Scheduled_Time__c != undefined){
                                taskData.Scheduled_Time__c = this.msToHMS(taskData.Scheduled_Time__c);
                            }

                            //Convert Actual Time value from Minute to time text.
                            if(taskData.Actual_Time_Taken__c) {
                                let timeInSeconds = Number(taskData.Actual_Time_Taken__c);	
                                 taskData.Actual_Time_Taken__c = this.minuteToHm(timeInSeconds);
                            }

                            if(taskData.CreatedDate) {
                                let crDate=new Date(taskData.CreatedDate);
                                let month =crDate.getMonth();
                                month =month+1;
                                taskData.CreatedDate = crDate.getDate()+'-'+month+'-'+crDate.getFullYear();
                             }

                            let buttonStatus = {
                                showConfirmButton: true,
                                showEditButton: true,
                                showCompleteButton: false,
                                showPlayButton: false,
                                showPauseButton: false,
                                showCancelButton: true,
                                showCloneButton: false
                            };

                            if(taskData.OwnerId == this.currentUserId || (taskData.OwnerId != this.currentUserId && this.isCurrentUserProjectManager) ) {
                                buttonStatus.showCloneButton = true;
                            }

                            if((taskData.OwnerId != this.currentUserId && this.isCurrentUserProjectManager && taskData.Task_Status__c == 'Not Started') || taskData.OwnerId == this.currentUserId) {
                                buttonStatus.showEditButton = true;
                            } else {
                                buttonStatus.showEditButton = false;
                            }

                            if(taskData.OwnerId != this.currentUserId || taskData.Task_Status__c && taskData.Task_Status__c == 'Completed') {
                                buttonStatus.showCompleteButton = false;
                                buttonStatus.showPlayButton = false;
                                buttonStatus.showPauseButton = false;
                            }

                            if(taskData.Task_Status__c && taskData.Task_Status__c == 'Completed') {
                               buttonStatus.showEditButton = true;
                               buttonStatus.showPlayButton = false;
                               buttonStatus.showPauseButton = false;
                            }

                            if(taskData.Task_Status__c && taskData.Task_Status__c == 'In Progress') {
                                buttonStatus.showCompleteButton = true;
                            }

                            buttonStatus.showCancelButton = ((taskData.Task_Status__c == 'Not Started' || taskData.Task_Status__c == 'Accepted') && taskData.OwnerId == this.currentUserId) ? true : false;

                            if(taskData.Task_Status__c == 'Cancelled') {
                                buttonStatus.showConfirmButton = false;
                                buttonStatus.showEditButton = false;
                                buttonStatus.showCompleteButton = false;
                                buttonStatus.showPlayButton = false;
                                buttonStatus.showPauseButton = false;
                                buttonStatus.showCancelButton = false;
                            }

                            if(taskData.OwnerId == this.currentUserId) {
                                buttonStatus.showConfirmButton = false;
                            }
                            if(taskData.Task_Status__c && taskData.Task_Status__c != 'Not Started' ) {	
                                buttonStatus.showConfirmButton = false;	
                            }	
                            if(taskData.OwnerId && taskData.OwnerId.startsWith('005') ) {	
                                buttonStatus.showConfirmButton = false;	
                            }

                            if(taskData.OwnerId == this.currentUserId && !taskData.Task_Start_Time__c && taskData.Task_Status__c != 'Completed' && taskData.Task_Status__c != 'Cancelled') {
                                buttonStatus.showPlayButton = true;
                                buttonStatus.showPauseButton = false;
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

                           taskData.buttonStatus = buttonStatus;
                            taskData = this.calculateTaskStatus(taskData);  
                        });
                        taskDataList.sort((a,b) => a.displayCount - b.displayCount || b.dateOrder - a.dateOrder);
                        this.taskList = taskDataList;
                        this.taskownername=this.taskList[0].Owner.Name;
                        console.log('success---', JSON.stringify(this.taskList));
                        console.log(Object.assign({}, this.taskList));
                    } else {
                        this.taskList = null;
                    }

                this.showSpinner = false;
                //refresh timer components in all rows
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

        if(taskData.Task_Status__c=='Accepted') {	
            taskData.Status = 'Accepted';	
            taskData.StatusMessage ='Accepted';	
        }else if(taskData.Task_Status__c=='Completed'){
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
        }else {
            taskData.Status = taskData.Task_Status__c;
            taskData.StatusMessage = taskData.Task_Status__c;
        }

        if(taskData.Status == 'Done') {
            taskData.statusIconName = 'action:approval';
            taskData.statusBackgroundColor = 'green';
            taskData.displayCount = 5;
            taskData.dateOrder = new Date(taskData.Task_Completed_On__c).getTime();
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

            taskData.editMode = false;

            return taskData;
        }

        if( taskData.Task_Status__c == 'Completed') {
            taskData.Actual_Time_Taken__Editable = true;
            taskData.editMode = true;
        } 
        
        if( taskData.OwnerId == this.currentUserId) {
            taskData.Comments__Editable = true;
            taskData.editMode = true;
            if(taskData.Task_Status__c == 'Accepted' || taskData.Task_Status__c == 'In Progress' ||  taskData.Task_Status__c == 'Not Started'){
                taskData.Task_Date__Editable = true;
            }
        }

        if((this.isSuperUser || this.isCurrentUserProjectManager) &&
            (taskData.Task_Status__c == 'Not Started' || taskData.Task_Status__c == 'Accepted')) {
            taskData.Owner__Editable = true;
            taskData.Task_Category__Editable = true;
            taskData.Task_Type__Editable = true;
            taskData.Task_Date__Editable = true;
            taskData.Scheduled_Time__Editable = true;
            taskData.UnScheduled__Editable = true;
            taskData.Comments__Editable = true;
            taskData.editMode = true;
        }

        if(taskData.cloneMode) {
            taskData.Task_Category__Editable = true;
            taskData.Task_Type__Editable = true;
            taskData.Task_Date__Editable = true;
            taskData.Comments__Editable = true;
            taskData.Actual_Time_Taken__Editable = false;
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
                }),
            );
        } else if (data) {
            this.jobRecord = data;
            this.isTaskRowDraggable = this.isCurrentUserProjectManager ? true : false;

            this.showPriorityUpdateButton = this.isCurrentUserProjectManager && this.taskList && this.taskList.length > 0 ? true : false;
        }
    }

    get projectManagerValue() {
        return getFieldValue(this.jobRecord, PROJECT_MANAGER_FIELD);
    }

    get isCurrentUserProjectManager() {
        return this.projectManagerValue == userId ? true : false;
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
        // Show filtered data on status change.
        this.fetchTaskList();
    }

    handleTaskOwnerFilterValue(event) {
        this.taskOwnerFilterValue = event.detail.value;
    }

    handleSearchAction(event) {
        //filter records
        console.log('inside search action');
        this.fetchTaskList();
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
        console.log(JSON.stringify(this.taskList));
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
        let taskObject = {};

        this.taskList.map((taskData) => {
            if(taskData && taskData.Id == taskId) {
                taskObject.OwnerId = taskData.OwnerId;
                taskObject.RecordTypeId = taskData.RecordTypeId;
                taskObject.Task_Category__c = taskData.Task_Category__c;
                taskObject.Task_Type__c = taskData.Task_Type__c;
                taskObject.Task_Date__c = taskData.Task_Date__c;
                taskObject.Scheduled_Time__c = taskData.Scheduled_Time__c;
                taskObject.Task_Status__c = 'Not Started';
                console.log('taskData.Comments__c'+taskData.Comments__c);
                taskObject.Comments__c = taskData.Comments__c;
                taskObject.Job__c = this.recordId;
                taskObject.Systems__c = taskData.Systems__c;
                taskObject.IT_Ticket_Number__c = taskData.IT_Ticket_Number__c;
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
                                console.log('timerss+'+comp.taskStartTime);
                                if(!comp.taskStartTime) {	
                                    comp.taskStartTime = startOrResumeTime;	
                                    comp.startOrResumeAction = 'startTimer';	
                                    taskData.Task_Start_Time__c = startOrResumeTime;	
                                    taskData.Task_Status__c = 'In Progress';	
                                    taskData.buttonStatus.showCompleteButton = true;	
                                    taskData.buttonStatus.showCancelButton = false;	
                                    	
                                    taskData = this.calculateTaskStatus(taskData);	
                                }else {
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
    DragStart(event) {
        this.dragStart = event.currentTarget.dataset.index;
        event.target.classList.add("drag");
      }
    
      DragOver(event) {
        event.preventDefault();
        return false;
      }
    
      Drop(event) {
        event.stopPropagation();
        const DragValName = this.dragStart;
        const DropValName = event.currentTarget.dataset.index;
        console.log('Event',event.currentTarget.dataset.index);
        if (DragValName === DropValName) {
          return false;
        }
        const index = DropValName;
        const currentIndex = DragValName;
        const newIndex = DropValName;
       
        if(parseInt(newIndex)>=0){
            this.taskList[currentIndex].Manager_Priority__c = newIndex;
            this.ListToUpdate.push(this.taskList[currentIndex]);
            Array.prototype.move = function (from, to) {
                this.splice(to, 0, this.splice(from, 1)[0]);
              };
              this.taskList.move(parseInt(currentIndex),parseInt(newIndex));
              if(parseInt(currentIndex)>parseInt(newIndex)){
            for(var i=parseInt(newIndex)+1;i<=parseInt(currentIndex);i++){
                console.log('index changing '+i);
                this.taskList[i].Manager_Priority__c=parseInt(this.taskList[i].Manager_Priority__c)+1;
                this.ListToUpdate.push(this.taskList[i]);
                
            }
        }
        if(parseInt(currentIndex)<parseInt(newIndex)){
            for(var i=parseInt(currentIndex);i<parseInt(newIndex);i++){
                console.log('index changing '+i);
                this.taskList[i].Manager_Priority__c=parseInt(this.taskList[i].Manager_Priority__c)-1;
                this.ListToUpdate.push(this.taskList[i]);
            } 
        }
        
         }
        console.log('List to update '+JSON.stringify(this.ListToUpdate));
      }
      handleUpdate(){
        let finalListToUpdate=[];
        console.log('List to update '+JSON.stringify(this.ListToUpdate));
        this.ListToUpdate.forEach(element => {
            finalListToUpdate.push({
                'sobjectType': 'MS_Task__c',
                'Id':element.Id,
                'Manager_Priority__c': element.Manager_Priority__c});
        });
        UpdateTasks({ TasksToUpdate: finalListToUpdate })
        .then((result) => {
        if(result=='Success'){
          this.ListToUpdate = [];
            console.log('Success');
            this.taskList=[];
            this.fetchTaskList();
        const event = new ShowToastEvent({
            title: 'Success',
		    message: 'Priority updated Successfully',		
            variant: 'success',		
            duration: 2000
        });
        this.dispatchEvent(event);
        }
        })
        .catch((error) => {
        console.log("###Error : " + error.body.message);
        });
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
                    this.taskDataToUpdateList.push({
                        'sobjectType': 'MS_Task__c',
                        'Id': taskId,
                        [taskFieldName]: taskFieldValue
                    });
                }
        }else {
                this.taskDataToUpdateList.push({
                    'sobjectType': 'MS_Task__c',
                    'Id': taskId,
                    [taskFieldName]: taskFieldValue
                });
        }
        
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
            console.log('taskDataToUpdateList***', this.taskDataToUpdateList);
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
                taskObject.Scheduled_Time__c = taskData.Scheduled_Time__c;
                taskObject.UnScheduled__c = taskData.UnScheduled__c;
                taskObject.Task_Status__c = 'Not Started';
                taskObject.Comments__c = taskData.Comments__c;
                taskObject.Job__c = this.recordId;
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
                    taskData.editMode = false;
                    taskData.Comments__Editable = false;
                    taskData.Task_Date__Editable = false;
                    taskData.Actual_Time_Taken__Editable=false;
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
        const tabValue = event.target.value;

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

    CreateNewTask(){
      this.showcreationpage=true;
      this.isReadOnly = true; 
    }

    closeModal() {
        this.showcreationpage = false;
    }

    handleSuccess(event) {
        this.closeModal();
        this.fetchTaskList();
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        
        if(fields.Task_Status__c =='Completed'){
            let d = new Date();
            fields.Task_Completed_On__c = d.toISOString();
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleTaskStatusChange(event){
        if(event.detail.value === 'Completed'){
            this.isReadOnly = false;
        }else{
            this.isReadOnly = true; 
        }
        this.template.querySelectorAll('lightning-input-field[data-id="reset"]').forEach(element => {
            element.value = null;
        });
    }

}