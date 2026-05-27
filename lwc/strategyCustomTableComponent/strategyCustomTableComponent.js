import { LightningElement, api, track } from 'lwc';
import getStrategyAndGoalsDetails from '@salesforce/apex/StrategyAndGoalController.getStrategyAndGoalsDetails';
import getActivityDetails from '@salesforce/apex/StrategyAndGoalController.getActivityDetails';
import getCompletedStrategyAndGoalsDetails from '@salesforce/apex/StrategyAndGoalController.getCompletedStrategyAndGoalsDetails';
import getOpportunityDetails from '@salesforce/apex/StrategyAndGoalController.getOpportunityDetails';
import getAllActivityDetailsOnAccountPlan from '@salesforce/apex/StrategyAndGoalController.getAllActivityDetailsOnAccountPlan';
import linkOrDelinkOpportunities from '@salesforce/apex/StrategyAndGoalController.linkOrDelinkOpportunities';
import NAME from '@salesforce/schema/Strategy_and_Goal__c.Strategy_Name__c';
import ACCOUNT_PLAN from '@salesforce/schema/Strategy_and_Goal__c.Account_Plan__c';
import ESTIMATED_COMPLETION_DATE from '@salesforce/schema/Strategy_and_Goal__c.Estimated_Completion_Date__c';
import STATUS from '@salesforce/schema/Strategy_and_Goal__c.Strategy_Status__c';
import CONTACT from '@salesforce/schema/Strategy_and_Goal__c.Key_Contact_Sponsor__c';
import SOLUTION from '@salesforce/schema/Strategy_and_Goal__c.Solution_Product_Area__c';
import TYPE from '@salesforce/schema/Strategy_and_Goal__c.Strategy_Type__c';
import BUSINESS_PROBLEM_ADDRESSED from '@salesforce/schema/Strategy_and_Goal__c.Business_Problem_Addressed__c';
import COMMENTS from '@salesforce/schema/Strategy_and_Goal__c.Comments_Next_Steps__c';
import MILESTONES from '@salesforce/schema/Strategy_and_Goal__c.Key_Milestones__c';
import RESOURCES from '@salesforce/schema/Strategy_and_Goal__c.Resources_Required__c';
import SOLUTION_GOAL from '@salesforce/schema/Strategy_and_Goal__c.Solution_Goal__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex'
import { NavigationMixin } from 'lightning/navigation';
import getInactiveStrategyAndGoalsDetails from '@salesforce/apex/StrategyAndGoalController.getInactiveStrategyAndGoalsDetails';

export default class TableStartegy extends NavigationMixin(LightningElement) {

    @api recordId;
    @api isAccountPlanUnderReview;
    @api isAccPlanRetired;
    isActionVisible;


    @track strategyData;
    @track ActivityRecords;
    activitiesRecordsToDisplay;
    recordsToDisplay;
    rowNumberOffset;
    isExpanded = false;
    checkExpanded = false;
    showSpinnerforChild = false;
    showExpandedTable = false;
    strategyLength = 0;
    completedRecords;
    opportunityData;
    recordsToDisplayCompleted;
    wiredData;
    objectApiName = 'Strategy_and_Goal__c';
    showSpinner = false;
    fields = { ACCOUNT_PLAN, STATUS, CONTACT, NAME, SOLUTION_GOAL, RESOURCES, SOLUTION, MILESTONES, TYPE, ESTIMATED_COMPLETION_DATE, BUSINESS_PROBLEM_ADDRESSED, COMMENTS };
    openModal = false;
    fieldValues = {};
    isOpportunityModal = false;
    modalTitle = '';
    @track selectedRows = [];
    selectedRowsFinal;
    selectedRowsInitial;
    currentStrategy;
    showErrorMessage = false;
    showPagination = true;
    widthLength = "";
    openActivityModal = false;
    isTaskModal;
    activityApiName;
    activityId;
    // Added by Prachi as part of SSE-21114 
    @track allActivityData;
    activityPicklistValue = 'all';
    allActivitiesForAccountPlan;
    @track showActivityPagination = true;
    @track ActivityTitle = 'All Open/Completed Activities'
    isDisabled = false;
    @track inactiveRecords;
    recordsToDisplayInactive;

    get activityPicklistoptions() {
        return [
            { label: 'All Activities', value: 'all' },
            { label: 'Open Activities', value: 'open' },
            { label: 'Completed Activities', value: 'completed' },
        ];
    }
    // Change Ends SSE-21114 



    ActivityCols = [
        {
            label: 'Subject', fieldName: 'ActivityURL', type: 'customLinkForActivities', wrapText: true,
            hideDefaultActions: true, typeAttributes: {
                label: { fieldName: 'ActivityName' },
                linkUrl: { fieldName: 'ActivityURL' }, taskEvent: { fieldName: 'taskEvent' }
            }
        },
        { label: 'Due Date', fieldName: 'DueDate', hideDefaultActions: true, wrapText: true },
        {
            label: 'Name', fieldName: 'WhoIdURL', type: 'url', wrapText: true,
            hideDefaultActions: true, typeAttributes: { label: { fieldName: 'WhoId' }, linkUrl: { fieldName: 'WhoIdURL' }, target: '_blank' }
        },
        { label: 'Status', fieldName: 'Status', hideDefaultActions: true, wrapText: true },
        { label: 'Assigned To', fieldName: 'Owner', hideDefaultActions: true, wrapText: true },
        {
            type: 'button-icon', fixedWidth: 30,
            typeAttributes: {
                iconName: 'utility:edit',
                name: 'edit', variant: 'bare',
                iconClass: 'slds-button_icon-xx-small'
            },
        },
    ];
    // Added by Prachi as part of SSE-21114 
    allActivityCols = [
        { label: '', fieldName: 'SNo', hideDefaultActions: true, fixedWidth: 50 },
        {
            label: 'Subject', fieldName: 'ActivityURL', type: 'customLinkForActivities', wrapText: true,
            hideDefaultActions: true, typeAttributes: {
                label: { fieldName: 'ActivityName' },
                linkUrl: { fieldName: 'ActivityURL' }, taskEvent: { fieldName: 'taskEvent' }
            }
        },
        {
            label: 'Startegy Name', fieldName: 'strategyURL', hideDefaultActions: true, wrapText: true, type: 'url',
            typeAttributes: { label: { fieldName: 'strategyName' }, linkUrl: { fieldName: 'strategyURL' }, target: '_blank' }
        },
        // { label: 'Created Date', fieldName: 'CreatedDate',hideDefaultActions:true,wrapText:true},
        { label: 'Due Date', fieldName: 'DueDate', hideDefaultActions: true, wrapText: true },
        {
            label: 'Name', fieldName: 'WhoIdURL', type: 'url', wrapText: true,
            hideDefaultActions: true, typeAttributes: { label: { fieldName: 'WhoId' }, linkUrl: { fieldName: 'WhoIdURL' }, target: '_blank' }
        },
        { label: 'Status', fieldName: 'Status', hideDefaultActions: true, wrapText: true },
        { label: 'Assigned To', fieldName: 'Owner', hideDefaultActions: true, wrapText: true },

    ];
    //Change ends

    completedColumns = [
        { label: '', fieldName: 'SNo', hideDefaultActions: true, fixedWidth: 50 },
        { label: 'Name', fieldName: 'strategyUrl', type: 'url', wrapText: true, hideDefaultActions: true, typeAttributes: { label: { fieldName: 'strategyName' }, linkUrl: { fieldName: 'strategyUrl' }, target: '_blank' } },
        { label: 'Strategy Type', fieldName: 'type', hideDefaultActions: true, wrapText: true },
        { label: 'Strategy Status', fieldName: 'status', hideDefaultActions: true, wrapText: true, },
        { label: 'Solution / Product Area', fieldName: 'productSolution', wrapText: true, hideDefaultActions: true, wrapText: true },
        { label: 'Key Contact Sponsor', fieldName: 'contactUrl', type: 'url', wrapText: true, hideDefaultActions: true, typeAttributes: { label: { fieldName: 'contactName' }, target: '_blank' } },
        { label: 'Short / Long Term', fieldName: 'term', hideDefaultActions: true },
        { label: 'Est. Completion Date', fieldName: 'estimatedCompletionDate', wrapText: true, hideDefaultActions: true },

    ];

    opportunityColumns = [
        { label: 'Name', fieldName: 'opportunityName', wrapText: true, hideDefaultActions: true },
        { label: 'Account Number', fieldName: 'dNumber', wrapText: true, hideDefaultActions: true },
        { label: 'Stage', fieldName: 'stageName', hideDefaultActions: true, wrapText: true },
        { label: 'Est. Booking Value', fieldName: 'amount', wrapText: true, hideDefaultActions: true },
        { label: 'Est. Close Date ', fieldName: 'closeDate', wrapText: true, hideDefaultActions: true },
        { label: 'Contract Length', fieldName: 'contractLength', wrapText: true, hideDefaultActions: true },
        { label: 'Div/BU/Country/Dept', fieldName: 'divisionDetails', wrapText: true, hideDefaultActions: true, wrapText: true },
        { label: 'Next Step(s)', fieldName: 'nextStep', hideDefaultActions: true, wrapText: true },
        { label: 'Solution', fieldName: 'solution', wrapText: true, hideDefaultActions: true },
    ];

    connectedCallback() {
        this.isDisabled = this.isAccPlanRetired || this.isAccountPlanUnderReview;
    }

    handleOpenStrategies() {

        this.isActionVisible = this.isAccountPlanUnderReview || this.isAccPlanRetired ? false : true;
        getStrategyAndGoalsDetails({ accountPlanId: this.recordId }).then(Response => {

            if (Response.MessageType == "Success") {
                let data = Response.strategyList;
                let myList = data.map(row => ({
                    ...row,
                    isExpanded: false,
                }));
                this.strategyData = myList;
                if (data.length > 0) {
                    this.strategyData = data;
                }
                else {
                    this.strategyData = ''
                }
                this.showPagination = true;
                this.error = undefined;
            }
            else if (Response.MessageType == "Error") {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: Response.Message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.strategyData = ''
            }
        }).catch(error => {
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(event);
            this.strategyData = ''
        })
    }

    handleCompletedStrategies() {

        getCompletedStrategyAndGoalsDetails({ accountPlanId: this.recordId }).then(Response => {

            if (Response.MessageType == "Success") {
                let data = Response.strategyList;
                if (data.length > 0) {

                    this.completedRecords = data;
                }
                else {
                    this.completedRecords = '';
                }

            }
            else if (Response.MessageType == "Error") {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: Response.Message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.strategyData = ''
            }



        }).catch(error => {

            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(event);

        })
    }

    handlePaginatorChange(event) {
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
    }

    handleCompletedPaginatorChange(event) {
        this.recordsToDisplayCompleted = event.detail;
        this.rowNumberOffset = this.recordsToDisplayCompleted[0].rowNumber - 1;
    }

    handleInactivePaginatorChange(event) {
        this.recordsToDisplayInactive = event.detail;
        this.rowNumberOffset = this.recordsToDisplayInactive[0].rowNumber - 1;
    }

    handleActivitiesPaginatorChange(event) {
        this.activitiesRecordsToDisplay = event.detail;
        this.rowNumberOffset = this.activitiesRecordsToDisplay[0].rowNumber - 1;
    }

    handleRefreshActivityTable(event) {
        this.showSpinnerforChild = true;
        var selectedRow = event.currentTarget;
        this.isActionVisible = false;
        var key = selectedRow.dataset.id;
        var rowId = event.currentTarget.dataset.recordId;

        let tempvar = JSON.parse(JSON.stringify(this.recordsToDisplay));
        tempvar.forEach(element => {

            if (element.id === key) {

                element.isExpanded = true;
            }
            else {
                element.isExpanded = false;
            }

        });
        this.recordsToDisplay = tempvar;

        getActivityDetails({ strategyId: key }).then(Response => {

            if (Response.MessageType == 'Success') {
                let data = Response.actList;

                if (data.length > 0) {
                    this.ActivityRecords = data;
                    this.showExpandedTable = true;
                    this.showSpinnerforChild = false;

                }

                else {
                    this.ActivityRecords = ''
                    this.showSpinnerforChild = false;
                }

            }
            else if (Response.MessageType == "Error") {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: Response.Message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.ActivityRecords = ''
            }

        }).catch(Error => {

        })

    }
    handleExpand(event) {
        this.showSpinnerforChild = true;
        var selectedRow = event.currentTarget;
        this.isActionVisible = false;
        var key = selectedRow.dataset.id;
        var iconName = selectedRow.dataset.id;
        var rowId = event.currentTarget.dataset.recordId;
        this.widthLength = "max-width:6.9rem";

        let tempvar = JSON.parse(JSON.stringify(this.recordsToDisplay));
        tempvar.forEach(element => {

            if (element.id === rowId) {

                element.isExpanded = true;
            }
            else {
                element.isExpanded = false;
            }

        });
        this.recordsToDisplay = tempvar;

        getActivityDetails({ strategyId: rowId }).then(Response => {

            if (Response.MessageType == 'Success') {
                let data = Response.actList;

                if (data.length > 0) {
                    this.ActivityRecords = data;
                    this.showExpandedTable = true;
                    this.showSpinnerforChild = false;

                }

                else {
                    this.ActivityRecords = ''
                    this.showSpinnerforChild = false;
                }

            }
            else if (Response.MessageType == "Error") {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: Response.Message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.ActivityRecords = ''
            }

        }).catch(Error => {

        })
    }

    handleClose(event) {
        this.showSpinnerforChild = false;
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        var iconName = selectedRow.dataset.id;
        var rowId = event.currentTarget.dataset.recordId;
        this.widthLength = "";
        if (this.isAccountPlanUnderReview == false && this.isAccPlanRetired == false) {
            this.isActionVisible = true;
        } else {
            this.isActionVisible = false;
        }

        let tempvar = JSON.parse(JSON.stringify(this.recordsToDisplay));
        tempvar.forEach(element => {

            if (element.id === rowId) {

                element.isExpanded = false;
            }
            else {
                element.isExpanded = false;
            }

        });
        this.recordsToDisplay = tempvar;


    }

    linkOrDelinkOpportunities() {
        let linkedOpportunities = [];
        let delinkedOpportunities = [];
        this.selectedRowsFinal.forEach(element => {
            linkedOpportunities.push(element.oppId);
        });

        this.selectedRows.forEach(element => {
            if (!linkedOpportunities.includes(element)) {
                delinkedOpportunities.push(element);
            } else {
                linkedOpportunities.splice(linkedOpportunities.indexOf(element), 1);
            }
        });
        if (linkedOpportunities.length > 0 || delinkedOpportunities.length > 0) {
            this.showSpinner = true;
            linkOrDelinkOpportunities({
                strategyId: this.currentStrategy,
                opportunityIdsToLink: linkedOpportunities, opportunityIdsToDelink: delinkedOpportunities,
                totalOpportunitiesLinked: this.selectedRowsFinal.length
            }).then(Response => {
                if (Response.MessageType == 'Success') {
                    let data = Response.message;
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        variant: 'success',
                        message: Response.Message,
                    });
                    this.dispatchEvent(event);
                    this.showSpinner = false;
                    this.isOpportunityModal = true;
                    this.closeModal();
                }
                else if (Response.MessageType == "Error") {
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: Response.Message,
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                    this.showSpinner = false;
                }

            }).catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.showSpinner = false;
            });
        }
        else {
            this.isOpportunityModal = false;
            this.closeModal();
        }
    }

    handleLinkOrDelink(event) {
        this.showSpinner = true;
        this.selectedRows = [];
        const action = event.currentTarget.name;
        const strategyId = event.currentTarget.dataset.recordId;
        const accountId = event.currentTarget.dataset.id;
        const getTheRow = this.recordsToDisplay.find(expanded => expanded.id == strategyId);
        const checkExpanded = getTheRow.isExpanded;


        this.currentStrategy = strategyId;

        if (action == 'linkOrDelink') {
            this.modalTitle = 'Link Or De-link Opportunities';
            this.isOpportunityModal = true;
            this.openModal = true;
            getOpportunityDetails({ accountId: accountId, strategyId: strategyId }).then(Response => {

                if (Response.MessageType == 'Success') {
                    let data = Response.oppList;
                    if (data.length >= 1) {
                        this.opportunityData = data;
                        let selectedRows = [];
                        this.opportunityData.forEach(element => {
                            if (element.isStrategyLinked) {
                                selectedRows.push(element.oppId);
                                this.selectedRows = selectedRows;
                            }
                        });
                    }
                    else {
                        this.opportunityData = '';

                    }
                }
                else if (Response.MessageType == "Error") {
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: Response.Message,
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                    this.showSpinner = false;
                    this.opportunityData = '';
                }

                this.showSpinner = false;

            }).catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
            });
        } else {

            let pageRef = {};
            switch (action) {
                case 'email':

                    pageRef = {
                        type: "standard__quickAction",
                        attributes: {
                            apiName: "Global.SendEmail"
                        },
                        state: {
                            recordId: strategyId
                        }
                    };
                    break;
                case 'newTask':

                    pageRef = {
                        type: "standard__quickAction",
                        attributes: {
                            apiName: "Global.NewTask"
                        },
                        state: {
                            recordId: strategyId
                        }
                    };
                    break;
                case 'newEvent':
                    pageRef = {
                        type: "standard__quickAction",
                        attributes: {
                            apiName: "Global.NewEvent"
                        },
                        state: {
                            recordId: strategyId
                        }
                    };
                    break;
            }
            this[NavigationMixin.Navigate](pageRef);


        }

    }

    handleRowSelection(event) {
        this.selectedRowsFinal = event.detail.selectedRows;
    }

    oncreation(event) {
        let ev = new CustomEvent('creation');
        this.dispatchEvent(ev);
    }

    renderedCallback() {
        if (this.isAccountPlanUnderReview || this.isAccPlanRetired) {
            this.columns = this.columnsWithNoActions;
        } else {
            this.columns = this.columnsWithActions;
        }
    }

    handleSuccess() {
        const event = new ShowToastEvent({
            title: 'Success!',
            variant: 'success'
        });
        this.dispatchEvent(event);
        //refreshApex(this.wiredData);
        this.showPagination = false;
        this.handleOpenStrategies();
        this.closeModal();
        this.oncreation();
    }

    openModalPopup() {
        this.modalTitle = 'Create Strategy And Goal';
        this.isOpportunityModal = false;
        this.openModal = true;
    }

    closeModal() {
        this.openModal = false;
        this.showSpinner = false;
        this.showErrorMessage = false;
    }

    handleSave() {
        this.showSpinner = true;
        let requiredFields = this.template.querySelectorAll(".required-fields");
        let allRequiredValuesPresent = true;
        requiredFields.forEach(element => {
            if (!element.value) {
                allRequiredValuesPresent = false;
            }
        });
        if (!allRequiredValuesPresent) {
            this.showErrorMessage = true;
            this.showSpinner = false;
        }
    }

    handleError() {
        this.showSpinner = false;
    }
    // SSE-21119 Account Plan Phase 3 
    handleEditActivity(event) {
        this.openActivityModal = true;
        const action = event.detail.action.name;
        const row = event.detail.row;
        console.log('row --> ', row);
        console.log('row --> ', row.ActivityType);
        console.log('row --> ', row.ActivityId);

        if (row.ActivityType == 'Event') {
            this.modalTitle = 'Update Event Details';
            // this.isTaskModal=false;
            this.activityApiName = 'Event';

        }
        if (row.ActivityType == 'Task') {
            this.modalTitle = 'Update Task Details';
            //   this.isTaskModal = true;
            this.activityApiName = 'Task';
        }

        this.activityId = row.ActivityId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.ActivityId, // pass the record id here.
                actionName: 'edit',
            },
        });

    }

    // SSE-21119 Account Plan Phase 3 
    handleCloseActivityModal() {
        this.openActivityModal = false;

    }
    // Added by Prachi as part of SSE-21114 
    handleAllActivities() {
        /* this.ActivityTitle='All Open/Completed Activities';
         this.activityPicklistValue ='all';*/
        getAllActivityDetailsOnAccountPlan({ accountPlanId: this.recordId }).then(Response => {

            if (Response.MessageType == "Success") {
                let data = Response.actList;
                if (data.length > 0) {

                    this.allActivityData = data;
                    this.allActivitiesForAccountPlan = data;
                }
                else {
                    this.allActivityData = '';
                    this.allActivitiesForAccountPlan = '';
                }

            }
            else if (Response.MessageType == "Error") {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: Response.Message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.strategyData = ''
            }



        }).catch(error => {

            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(event);

        })
    }
    // Added by Prachi as part of SSE-21114 
    handleChange(event) {
        this.showActivityPagination = false;
        this.allActivityData = '';
        let changedValue = event.detail.value
        this.activityPicklistValue = event.detail.value;
        let filteredActivityData = [];

        console.log(event.detail.value);
        console.log('changedValue', changedValue);
        let tempList = this.allActivitiesForAccountPlan;
        console.log('tempList', tempList);


        if (changedValue == 'all' && tempList.length > 0) {
            this.ActivityTitle = 'All Open/Completed Activities';
            console.log('changedValue inside all');
            let count = 0;
            tempList.forEach(element => {

                count++;
                element.SNo = count;
                filteredActivityData.push(element);

            });
            filteredActivityData = this.allActivitiesForAccountPlan;
        }
        else if (changedValue == 'open' && tempList.length > 0) {
            this.ActivityTitle = 'Open Activities';
            let count = 0;
            tempList.forEach(element => {
                let status = element.Status.indexOf("Complete");
                if ((status === -1 && element.ActivityType == 'Task') || (element.ActivityType == 'Event' && element.isCompleted == false && status === -1)) {
                    count++;
                    element.SNo = count;
                    filteredActivityData.push(element);
                }
            });
            console.log('filteredActivityData', filteredActivityData);
        }
        else if (changedValue == 'completed' && tempList.length > 0) {
            this.ActivityTitle = 'Completed Activities';
            let count = 0;
            tempList.forEach(element => {
                if (element.Status.includes("Complete") || element.isCompleted == true) {
                    count++;
                    element.SNo = count;
                    filteredActivityData.push(element);
                }
            });
        }

        console.log('filteredActivityData.length --> ', filteredActivityData.length);
        if (filteredActivityData.length == 0) {
            this.allActivityData = '';
        }
        else if (filteredActivityData.length > 0) {
            this.allActivityData = filteredActivityData;
            setTimeout(() => {
                this.showActivityPagination = true;
            }, 300);
        }
    }

    handldInactiveStrategies() {
        console.log('handldInactiveStrategies: ');
        getInactiveStrategyAndGoalsDetails({ accountPlanId: this.recordId })
            .then(Response => {
                console.log('Response: ', JSON.stringify(Response));
                if (Response.MessageType == "Success") {
                    let data = Response.strategyList;
                    let myList = data.map(row => ({
                        ...row,
                        isExpanded: false,
                    }));
                    this.inactiveRecords = myList;
                    if (data.length > 0) {
                        this.inactiveRecords = data;
                    }
                    else {
                        this.inactiveRecords = ''
                    }
                    this.showPagination = true;
                    this.error = undefined;
                }
                else if (Response.MessageType == "Error") {
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: Response.Message,
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                    this.inactiveRecords = ''
                }
            }).catch(error => {
                this.error = error;
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.inactiveRecords = ''
            })
    }
}