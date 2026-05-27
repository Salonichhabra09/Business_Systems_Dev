import { LightningElement, wire, track, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import TASK_CATEGORY_FIELD from '@salesforce/schema/MS_Task__c.Task_Category__c';
import TASK_TYPE_FIELD from '@salesforce/schema/MS_Task__c.Task_Type__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getBureaUserList from '@salesforce/apex/BulkMSTaskCreationController.getBureaUserList';
import getQueueList from '@salesforce/apex/BulkMSTaskCreationController.getQueueList';
import getProjectManager from '@salesforce/apex/BulkMSTaskCreationController.getProjectManager';
import insertTasks from '@salesforce/apex/BulkMSTaskCreationController.insertTasks';
import { publish, MessageContext } from 'lightning/messageService';
import MS_Task_Messages_CHANNEL from '@salesforce/messageChannel/MS_Task_Messages__c';
import MS_Super_User from '@salesforce/customPermission/MS_Super_User';
import Current_User_Id from '@salesforce/user/Id';

const columnsConst = [
    {
        label: 'Owner',
        fieldName: 'OwnerId',
        type: 'text',
        adjustWidth: false,
        required: true
    },
    {
        label: 'Category',
        fieldName: 'Task_Category__c',
        type: 'text',
        adjustWidth: false,
        required: true
    },
    {
        label: 'Type',
        fieldName: 'Task_Type__c',
        type: 'text',
        adjustWidth: false,
        required: true
    },
    {
        label: 'Date',
        fieldName: 'Task_Date__c',
        type: 'text',
        adjustWidth: false,
        required: true
    },
    {
        label: 'Scheduled Time',
        fieldName: 'Scheduled_Time__c',
        type: 'text',
        adjustWidth: false,
        required: false
    },
    {
        label: 'Estimated Time Required',
        fieldName: 'Estimated_Time_Required__c',
        type: 'text',
        adjustWidth: false,
        required: true
    },
    {
        label: 'Comments',
        fieldName: 'Comments__c',
        type: 'text',
        adjustWidth: true,
        required: false
    },
    {
        label: '',
        fieldApiName: '',
        type: '',
        adjustWidth: false,
        required: false
    }
];

export default class BulkTaskCreationComponent extends LightningElement {

    @track listOfTasks;
    @track columns;
    bureauUserOptions=[];
    taskCategoryOptions;
    taskTypeOptions;
    @api showSpinner = false;
    @api jobRecordId;
    @api tasksFromFlow;
    @api recordTypeId;
    @api recordTypeName;
    taskTypeFieldData;
    //@track showEstimatedTimeColoumn = true;
    projectManagerId;

    @wire(MessageContext)
  messageContext;

  get isSuperUser() {
    return MS_Super_User;
}

    async connectedCallback() {
        //console.log("Value from list "+this.TasksFromFlow[0].Task_Category__c);
        //this.initData();
        this.projectManagerId = await getProjectManager({JobId:this.jobRecordId});
        console.log('Project Manager Id ',this.projectManagerId);
        console.log('MS_Super_User-', this.isSuperUser);
        //this.showEstimatedTimeColoumn = true;
        this.columns = JSON.parse(JSON.stringify(columnsConst));
        
       /* if(this.recordTypeName=='Talent Management' || this.recordTypeName=='MS Analytics'){
            this.showEstimatedTimeColoumn = false;
            for(let i=0;i<columnsConst.length;i++){
                if(columnsConst[i].label=='Estimated Time Required'){
                    this.columns.splice(i,1);
                }
            }
        } */
        let options = [];
        await getBureaUserList({lineOfBusiness:this.recordTypeName})
            .then( result => {
                this.bureauUserOptions = undefined;
                if (result!=null) {
                    //if(this.isSuperUser || (Current_User_Id==this.projectManagerId)){
                    options.push({ label: "---USERS---", value: null  });
                    //}
                    for (var key in result) {
                        //if(this.isSuperUser || (Current_User_Id==this.projectManagerId)){
                        options.push({ label: key, value: result[key]  });
                        //}
                        /*else{
                            if(result[key]==Current_User_Id){
                                options.push({ label: key, value: result[key]  }); 
                            }
                        } */
                    }
                }
                })
                .catch(error => {
                    this.error = error;
                    console.log('error');
                    console.log(error);
                });
                 
        //if(this.isSuperUser ||(Current_User_Id==this.projectManagerId)){
            await getQueueList({lineOfBusiness:this.recordTypeName})
                        .then( result =>{
                            if(result!=null){
                                options.push({ label: "---QUEUE---", value: null  });
                            for (var key in result) {
                                options.push({ label: key, value: result[key] });
                                console.log('key', key, result[key]);
                            }
                        }
                        })
                        .catch(error => {
                            this.error = error;
                            console.log('error');
                            console.log(error);
                        });   
                   // }
                this.bureauUserOptions = options;
                this.initData();
                console.log('Result '+JSON.stringify(options));
            
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
         this.taskTypeOptions = undefined;
        if (data) {
            //this.taskTypeOptions = data.values;
            this.taskTypeFieldData = data;
            console.log('Dependent values '+JSON.stringify(this.taskTypeFieldData));
        } else if (error) {
            console.log(error);
        }
    }

    initData() {
        let listOfTasks = [];
        //this.createRow(listOfTasks);
        if(this.tasksFromFlow!=undefined){
            this.createDefaultTasks(listOfTasks);
            console.log('Inside default');
        }
        else{
            this.createRow(listOfTasks);
            console.log('Inside new');
        }
        this.listOfTasks = listOfTasks;
    }

    createRow(listOfTasks) {
        let taskObject = {};
        if(listOfTasks.length > 0) {
            taskObject.index = listOfTasks[listOfTasks.length - 1].index + 1;
        } else {
            taskObject.index = 1;
        }
        console.log('length '+this.bureauUserOptions.length);
        /*if(this.bureauUserOptions.length==1){
            taskObject.ownerId = this.bureauUserOptions[0].value;
        } */
        //else{
            taskObject.ownerId = null;
        //}
        taskObject.Task_Category__c = null;
        taskObject.Scheduled_Time__c = null;
        taskObject.Task_Type__c = null;
        taskObject.Task_Date__c = null;
        taskObject.Estimated_Time_Required__c = null;
        taskObject.Comments__c = null;
        listOfTasks.push(taskObject);
    }

    createDefaultTasks(listOfTasks){
        this.tasksFromFlow.forEach((task,index) => {
            let taskObject = {};
            taskObject.index = index+1;
            console.log('length '+this.bureauUserOptions.length);
          /*  if(this.bureauUserOptions.length==1){
                    taskObject.ownerId = this.bureauUserOptions[0].value;  
            } */
           // else{
               /* if(task.OwnerId==null){
                    taskObject.ownerId = null;
                } */
               // else{
                    taskObject.ownerId = task.OwnerId;
                //}
            //}
            taskObject.Task_Category__c = task.Task_Category__c;
            taskObject.Task_Type__c = task.Task_Type__c;
            taskObject.Task_Date__c = null;
            taskObject.Scheduled_Time__c = null;
            taskObject.Estimated_Time_Required__c = null;
            taskObject.Comments__c = task.Comments__c;
            let key = this.taskTypeFieldData.controllerValues[task.Task_Category__c];
            taskObject.taskTypeOptions = this.taskTypeFieldData.values.filter(opt => opt.validFor.includes(key));
            listOfTasks.push(taskObject);
        });
    }

    /**
     * Adds a new row
     */
    addNewRow() {
        this.createRow(this.listOfTasks);
    }

    /**
     * Removes the selected row
     */
    removeRow(event) {
        let toBeDeletedRowIndex = event.target.name;
        let listOfTasks = [];
        for(let i = 0; i < this.listOfTasks.length; i++) {
            let tempRecord = Object.assign({}, this.listOfTasks[i]); //cloning object
            if(tempRecord.index !== toBeDeletedRowIndex) {
                listOfTasks.push(tempRecord);
            }
        }

        for(let i = 0; i < listOfTasks.length; i++) {
            listOfTasks[i].index = i + 1;
        }

        this.listOfTasks = listOfTasks;
    }

    /**
     * Removes all rows
     */
    removeAllRows() {
        let listOfTasks = [];
        this.createRow(listOfTasks);
        this.listOfTasks = listOfTasks;
    }

    handleInputChange(event) {
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        for(let i = 0; i < this.listOfTasks.length; i++) {
            if(this.listOfTasks[i].index === parseInt(index)) {
                this.listOfTasks[i][fieldName] = value;
            }
        }
    }

    createTasks() {
        this.showSpinner = true;
        let todayDate = new Date().toJSON().slice(0,10);
        console.log(todayDate);
        let dateFieldList  = this.template.querySelectorAll('.dateField');
        let ifDateValid = true;
        dateFieldList.forEach(element => {
            console.log(todayDate);
            if(element.value && element.value<todayDate){
                element.setCustomValidity('You cannot schedule a task in the past.')
                ifDateValid = false;
            }
            else{
                element.setCustomValidity('');
            }
            element.reportValidity();
            this.showSpinner =false;
        });
        const All_Compobox_Valid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, input_Field_Reference) => {
                input_Field_Reference.reportValidity();
                return validSoFar && input_Field_Reference.checkValidity();
            }, true);
        const All_Field_Valid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, input_Field_Reference) => {
            input_Field_Reference.reportValidity();
            return validSoFar && input_Field_Reference.checkValidity();
        }, true);     
        if(All_Compobox_Valid && All_Field_Valid && ifDateValid){
            console.log('All valid');
            console.log('taskList--->', JSON.stringify(this.listOfTasks));
        let listOfTasksToCreate = [];
        this.listOfTasks.forEach((task,index) => {
            let taskObject = {};
            taskObject.sobjectType='MS_Task__c',
            //taskObject.index = index+1;
            taskObject.OwnerId = task.ownerId;
            taskObject.RecordTypeId = this.recordTypeId;
            taskObject.Task_Category__c = task.Task_Category__c;
            taskObject.Scheduled_Time__c = task.Scheduled_Time__c;
            taskObject.Task_Type__c = task.Task_Type__c;
            taskObject.Task_Date__c = task.Task_Date__c;
            taskObject.Estimated_Time_Required__c = task.Estimated_Time_Required__c;
            taskObject.Comments__c = task.Comments__c;
            listOfTasksToCreate.push(taskObject);
        });
        this.handleSpinnerState('true');
        insertTasks({
            ListOfTasks: listOfTasksToCreate,
            jobRecordId: this.jobRecordId
        })
            .then(data => {
                this.handleSpinnerState('false');
                //this.initData();
                this.showSpinner = false;
                const payload = { 
                    TaskCreated: 'True'
                  };
                  publish(this.messageContext, MS_Task_Messages_CHANNEL, payload);
                let event = new ShowToastEvent({
                    message: "Tasks successfully created!",
                    variant: "success",
                    duration: 2000
                });
                this.dispatchEvent(event);

                const taskCreationSuccess = new CustomEvent('gettaskcreationstatus', {
                    detail: 'success'
                });
                this.dispatchEvent(taskCreationSuccess);
            })
            .catch(error => {
                console.log(error);
                this.showSpinner =false;
                this.handleSpinnerState('false');
                let errorString = error.body.message;
                /*if(errorString.includes('Owner ID: owner cannot be blank: [OwnerId]')){
                    let event = new ShowToastEvent({
                        title: "Error in Task Creation!",
                        message: 'Task Owner cannot be blank.',
                        variant: "error",
                        mode: "sticky"
                    });
                    this.dispatchEvent(event);
                }
                else{*/
                    let event = new ShowToastEvent({
                        title: "Error in Task Creation!",
                        message: error.body.message,
                        variant: "error",
                        mode: "sticky"
                    });
                    this.dispatchEvent(event);
                //}
            });
        }   
        else if(All_Compobox_Valid && All_Field_Valid && !ifDateValid){
            this.showSpinner =false;
            let event = new ShowToastEvent({
                title: "Required Fields Missing!",
                message: "Please enter all the required fields",
                variant: "error",
            });
            this.dispatchEvent(event);
        }
        
    }

    handleSpinnerState(state) {
        console.log('inside handleSpinnerState', state, typeof state);
        const spinnerEvent = new CustomEvent('getspinnerstate', {
            detail: state
        });
        this.dispatchEvent(spinnerEvent);
    }

    handleTaskCategoryChange(event) {
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        for(let i = 0; i < this.listOfTasks.length; i++) {
            
            if(this.listOfTasks[i].index === parseInt(index)) {
                this.listOfTasks[i][fieldName] = value;
                let key = this.taskTypeFieldData.controllerValues[value];
                this.listOfTasks[i].taskTypeOptions = this.taskTypeFieldData.values.filter(opt => opt.validFor.includes(key));
            }
        }
        }

        CloneRow(event){
            let toBeClonesRowIndex = event.target.name;
        for(let i = 0; i < this.listOfTasks.length; i++) {
            let tempRecord = Object.assign({}, this.listOfTasks[i]); //cloning object
            if(tempRecord.index == toBeClonesRowIndex) {
                tempRecord.index = this.listOfTasks.length+1;
                this.listOfTasks.push(tempRecord);
            }
        }
        }
}