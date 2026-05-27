import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Opportunity from '@salesforce/schema/Opportunity';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Business_Type__c from '@salesforce/schema/Opportunity.Business_Type__c';
import getOpportunitiesStageHistory from '@salesforce/apex/OpportunityStageSummaryController.getOpportunitiesStageHistory';

/*const staticColumns = [ {label: 'Name', fieldName: 'oppId', type: 'url', fixedWidth: 90,wrapText: true, hideDefaultActions: true,
    typeAttributes: { label: { fieldName: 'name' }, target: '_blank' }
    },
    { label: 'Opportunity Type', fieldName: 'type', wrapText: true, hideDefaultActions: true,fixedWidth: 140, typeAttributes: { alignment: 'center' } },
    { label: 'Region', fieldName: 'region', wrapText: true, hideDefaultActions: true,fixedWidth: 100, typeAttributes: { alignment: 'center' } },
    { label: 'Owner', fieldName: 'owner', wrapText: true, hideDefaultActions: true,fixedWidth: 140, typeAttributes: { alignment: 'center' } },
    { label: 'Closed Date', fieldName: 'closeDate', wrapText: true, hideDefaultActions: true,fixedWidth: 100, typeAttributes: { alignment: 'center' } }
];*/

const staticColumns = [ {label: 'Name', fieldName: 'oppId', type: 'url', wrapText: true, hideDefaultActions: true,
    typeAttributes: { label: { fieldName: 'name' }, target: '_blank' }
    },
    { label: 'Opportunity Type', fieldName: 'type', wrapText: true, hideDefaultActions: true,typeAttributes: { alignment: 'center' } },
    { label: 'Stage', fieldName: 'currentStage', wrapText: true, hideDefaultActions: true,typeAttributes: { alignment: 'center' } },
    { label: 'Region', fieldName: 'region', wrapText: true, hideDefaultActions: true,typeAttributes: { alignment: 'center' } },
    { label: 'Owner', fieldName: 'owner', wrapText: true, hideDefaultActions: true,typeAttributes: { alignment: 'center' } },
    { label: 'Closed Date', fieldName: 'closeDate', wrapText: true, hideDefaultActions: true, typeAttributes: { alignment: 'center' } }
];

export default class OpportunityStageSummary extends NavigationMixin(LightningElement) {

    @api recordId;
    @api flexipageRegionWidth; // Automatically reports the region width
    opportunitySummary;
    wrapperData
    startDate;
    endDate;
    // do not hold a live reference to the datatable element; use reactive flags instead
    tableElement;
    // rename to avoid name collision with handler; use string for UI status
    loadMoreStatus = '';
    rowOffSet = 0;
    dataCount;
    showSpinner = false;
    isOpportunityView = false;
    columns = [];
    selectedType;
    selectedStatus;
    dateError;
    recordTypeId;
    chartData;
    chartLabel;
    chartConfiguration = false;
    hasMoreRecords = false;

    // infinite loading state
    pageSize = 20;
    isTableLoading = false;
    hasMore = true;

    // Computed class to dim the card content when global spinner is shown
    get cardContainerClass() {
        return this.showSpinner ? 'dim-card' : '';
    }

    // Compute cell class for Days column in chart table to match datatable red styling
    computeCellClass = (row) => {
        try {
            return Number(row?.days) > 5 ? 'slds-theme_error slds-text-color_inverse' : '';
        } catch (e) {
            return '';
        }
    };

    // Compute row CSS class to mirror per-cell red styling when any stage exceeds threshold
    computeRowClass(row) {
        try {
            // any field ending with '_class' is added when days > 5 for that stage
            const hasRed = Object.keys(row || {}).some(k => k.endsWith('_class') && row[k]);
            return hasRed ? 'row-theme-error' : '';
        } catch (e) {
            return '';
        }
    }

    get hasData() {
        return Array.isArray(this.wrapperData) && this.wrapperData.length > 0;
    }

    get statusOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Open', value: 'Open' },
            { label: 'Closed/Won', value: 'Closed' }
        ];
    }

    // Getter to return columns with widths adjusted based on screen size
    get responsiveColumns() {
        let columnWidth;
        if (this.flexipageRegionWidth === "SMALL") {
            columnWidth = 80; // Smaller width for small screens
        } else if (this.flexipageRegionWidth === "MEDIUM") {
            columnWidth = 120; // Medium width for medium screens
        } else { // LARGE or default
            columnWidth = 160; // Larger width for large screens
        }

        // Map the base columns to new columns with dynamically set initialWidth
        return this.columns.map(col => {
            return { ...col, initialWidth: columnWidth }; // Set initialWidth dynamically
        });
    }

    @wire(getObjectInfo, { objectApiName: Opportunity })
    objectInfo({ error, data }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: Business_Type__c })
    wiredPicklistValues({ error, data }) {
        if (data) {
            console.log('Picklist values Opp', data.values);
            this.opportunityTypeOptions = [{ label: 'All', value: 'All' }, ...data.values];
        } else if (error) {
            console.error('Error fetching picklist values: ', error);
        }
    }

    connectedCallback() {
        // show initial spinner during first data bootstrap
        this.showSpinner = true;
        if(this.recordId){
            this.getOpportunitiesStageHistory();
        }else{
            this.getCurrentQuarterDates();
        }
    }

    handleTypeChange(event) {
        const val = event.detail.value;
        this.selectedType = val === '' ? null : val;
    }

    handleStartDateChange(event) {
        this.startDate = event.detail.value || null;
        this.validateDates();
    }

    handleEndDateChange(event) {
        this.endDate = event.detail.value || null;
        this.validateDates();
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value || 'All';
    }

    validateDates() {
        this.dateError = null;
        if (this.startDate && this.endDate) {
            const s = new Date(this.startDate);
            const e = new Date(this.endDate);
            if (s > e) {
                this.dateError = 'Start Date cannot be after End Date.';
            } else {
                // Calendar-year rule: invalid if endDate > startDate + 1 year (accounting for leap years)
                const addThreeMonths = new Date(s);
                addThreeMonths.setMonth(addThreeMonths.getMonth() + 3);
                if (e > addThreeMonths) {
                    this.dateError = 'Date range cannot exceed 3 months.';
                }
            }
        }

        return !this.dateError;
    }

    handleApply() {
        if (!this.validateDates()) {
            // Block action if invalid; UI error shown inline via {dateError}
            return;
        }
        // reset table and offset
        this.opportunitySummary = [];
        this.columns = [];
        this.rowOffSet = 0;
        this.hasMore = true;
        this.getOpportunitiesStageHistory();
    }

    handleReset() {
        // reset to current quarter
        this.showSpinner = true;
        this.selectedType = null;
        this.selectedStatus = 'All';
        this.dateError = null;

        // refresh data
        this.opportunitySummary = [];
        this.columns = [];
        this.rowOffSet = 0;
        this.hasMore = true;
        this.getCurrentQuarterDates();  
    }

    get processedData() {
        return this.chartData.map(row => ({
            stage: row.stage,
            days: row.days,
            col2Class: row.days > 5 ? 'highlight' : ''
        }));
    }

    getOpportunitiesStageHistory(){
        
        console.log('@@@ getOpportunitiesStageHistory');
        console.log('@@@ oppType ', this.selectedType);
        console.log('@@@ recordId ', this.recordId);
        this.isTableLoading = true;
        getOpportunitiesStageHistory({
                    opportunityId: this.recordId,
                    fromDate: this.startDate,
                    toDate: this.endDate,
                    regionFilter: null,
                    status: this.selectedStatus,
                    oppType: this.selectedType,
                    offSetValue: 0
                })
            .then(data=>{
                console.log('@@ data ', JSON.stringify(data));
                
                this.showSpinner = true;
                const response = data || [];
                this.wrapperData = response;
                
                if (!Array.isArray(response) || response.length === 0) {
                    this.columns = [...staticColumns];
                    this.opportunitySummary = [];
                    this.dataCount = 0;
                    this.hasMore = false;
                    this.isOpportunityView = true;
                    return;
                }

                let stageList = (response[0] && response[0].stageDetails) ? response[0].stageDetails : [];
                let stageColumns = [];
                let chartValues = [];
                let chartLabels = [];
                
                stageList.forEach(stage => {
                    if(this.recordId){
                        chartLabels.push(stage.stage);
                        //stage[classFieldName] = (Number(stage.days) > 5) ? 'slds-theme_error slds-text-color_inverse' : '';
                        chartValues.push(stage);
                    }else{
                        stageColumns.push({
                            label: stage.stage,
                            fieldName: stage.stage,
                            wrapText: true,
                            hideDefaultActions: true,
                            typeAttributes: { alignment: 'center' },
                            //fixedWidth: 60,
                            //initialWidth: 130,
                            cellAttributes: {
                                /*class: { fieldName: stage.stage + '_class' },*/
                                alignment: 'center'
                            }
                        });
                    }
                });
                
                if(this.recordId){
                    this.chartData = [...chartValues];
                    console.log('@@ chartdata ', this.chartData.length);
                    console.log('@@ chartdata ', JSON.stringify(this.chartData));
                    /*this.chartData.map(row => {
                        return {
                            ...row,
                            colorClass: row.days > 5 ? 'highlight' : ''
                        };
                    });*/
                    this.chartConfiguration = true;
                    console.log('@@ chartConfiguration ', this.chartConfiguration);
                }else{
                    // set columns only once at initial load
                    if (!this.columns || this.columns.length === 0) {
                        this.columns = [...staticColumns, ...stageColumns];
                    }
                    let finalRows = [];
                    let tempRecords = JSON.parse(JSON.stringify(response));
                
                tempRecords.forEach(row => {
                    //console.log('row Data: ', row.name);
                    row["oppId"] = '/lightning/r/Opportunity/' + row.id + '/view';
                    const stageSummary = row.stageDetails || [];
                    let additionalData = {};
                    stageSummary.forEach(stage => {
                        // value for the cell
                        additionalData[stage.stage] = stage.days;
                        // dynamic class for conditional styling (red background if > 5)
                        const classFieldName = stage.stage + '_class';
                        // Use SLDS error theme background with inverse text for readability
                        additionalData[classFieldName] = (Number(stage.days) > 5) ? 'slds-theme_error slds-text-color_inverse' : '';
                    });
                    delete row['stageDetails'];
                    const mergedRow = { ...row, ...additionalData };
                    finalRows.push(mergedRow);
                });
                
                console.log('@@@ finalRows: ', finalRows.length);
                
                this.opportunitySummary = finalRows;
                
                console.log('@@@ After this.opportunitySummary: ', this.opportunitySummary.length);
                
                //console.log('this.opportunitySummary: ', JSON.stringify(this.opportunitySummary));
                this.isOpportunityView = true;
                this.showSpinner = false;

                this.loadMoreStatus = '';
                this.dataCount = this.opportunitySummary.length;
                // determine if more data expected based on page size
                this.hasMore = finalRows.length === this.pageSize;
                
            }
            }) .catch(error => {
                console.log('@@ error ');
                console.log('@@ error getOpportunityLine: ', JSON.stringify(error));
                this.loadMoreStatus = 'Error loading data';
                this.hasMore = false;
            }).finally(() => {
                console.log('@@ finally ');
                // hide global spinner irrespective of success/failure
                this.showSpinner = false;
                this.isTableLoading = false;
                
            });
    }

    getMoreOpportunitiesStageHistory(){
        
        console.log('@@@ getMoreOpportunitiesStageHistory');
        this.isTableLoading = true;
        getOpportunitiesStageHistory({
                    opportunityId: this.recordId,
                    fromDate: this.startDate,
                    toDate: this.endDate,
                    regionFilter: null,
                    status: this.selectedStatus,
                    oppType: this.selectedType,
                    offSetValue: this.dataCount
                })
            .then(data=>{
                this.showSpinner = true;
                const response = data || [];
                this.wrapperData = response;

                if (!Array.isArray(response) || response.length === 0) {
                    this.hasMore = false;
                    this.loadMoreStatus = 'No more data to load';
                    return;
                }

                let stageList = (response[0] && response[0].stageDetails) ? response[0].stageDetails : [];
                let stageColumns = [];
                let chartValues = [];
                let chartLabels = [];

                stageList.forEach(stage => {
                    if(this.recordId){
                        chartLabels.push(stage.stage);
                        chartValues.push(stage.days);
                    }else{
                        stageColumns.push({
                            label: stage.stage,
                            fieldName: stage.stage,
                            wrapText: true,
                            hideDefaultActions: true,
                            typeAttributes: { alignment: 'center' },
                            //fixedWidth: 60,
                            //initialWidth: 130,
                            cellAttributes: {
                                /*class: { fieldName: stage.stage + '_class' },*/
                                alignment: 'center'
                            }
                        });
                    }
                });

                if(this.recordId){
                    this.chartLabel = [...chartLabels];
                    this.chartData = [...chartValues];
                    this.renderChart();
                }else{
                    // keep columns stable during infinite loading
                    if (!this.columns || this.columns.length === 0) {
                        this.columns = [...staticColumns, ...stageColumns];
                    }
                    let finalRows = [];
                    let tempRecords = JSON.parse(JSON.stringify(response));
                
                tempRecords.forEach(row => {
                    //console.log('row Data: ', row.name);
                    row["oppId"] = '/lightning/r/Opportunity/' + row.id + '/view';
                    const stageSummary = row.stageDetails || [];
                    let additionalData = {};
                    stageSummary.forEach(stage => {
                        // value for the cell
                        additionalData[stage.stage] = stage.days;
                        // dynamic class for conditional styling (red background if > 5)
                        const classFieldName = stage.stage + '_class';
                        // Use SLDS error theme background with inverse text for readability
                        additionalData[classFieldName] = (Number(stage.days) > 5) ? 'slds-theme_error slds-text-color_inverse' : '';
                    });
                    delete row['stageDetails'];
                    const mergedRow = { ...row, ...additionalData };
                    finalRows.push(mergedRow);
                });

                console.log('@@@ finalRows: ', finalRows.length);
                
                
                //console.log('this.opportunitySummary: ', JSON.stringify(this.opportunitySummary));
                this.isOpportunityView = true;
                this.showSpinner = false;

                this.opportunitySummary = [...(this.opportunitySummary || []), ...finalRows];
                console.log('@@@ After this.opportunitySummary: ', this.opportunitySummary.length);
                
                this.dataCount = this.opportunitySummary.length;
                this.loadMoreStatus = '';

                // decide if more data exists
                this.hasMore = finalRows.length === this.pageSize;
                if (!this.hasMore) {
                    this.loadMoreStatus = 'No more data to load';
                }
            }
            }) .catch(error => {
                console.log('error getOpportunityLine: ', JSON.stringify(error));
                this.loadMoreStatus = 'Error loading more';
                this.hasMore = false;
            }).finally(() => {
                // keep global spinner off; only row-level loading applies here
                this.showSpinner = false;
                this.isTableLoading = false;
            });
    }

    // renamed to avoid name collision with the previous property
    handleLoadMore(event) {
        event?.preventDefault?.();
        if (this.isTableLoading || !this.hasMore) {
            return;
        }
        this.loadMoreStatus = 'Loading…';
        this.getMoreOpportunitiesStageHistory();
    }

    getCurrentQuarterDates(){
        const today = new Date();
        const month = today.getMonth();
        const startMonth = Math.floor(month / 3) * 3;

        const start = new Date(today.getFullYear(), startMonth, 1);
        const end = new Date(today.getFullYear(), startMonth + 3, 0);

        const formatDate = (date) => {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        };

        this.startDate = formatDate(start);
        this.endDate = formatDate(end);

        this.getOpportunitiesStageHistory();

        // YYYY-MM-DD strings for lightning-input date
        /*
        this.startDate = start.toISOString().substring(0, 10);
        this.endDate = end.toISOString().substring(0, 10);
        */
    }
}