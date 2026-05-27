import { LightningElement, wire, api, track } from 'lwc';
import getWRFvalue from '@salesforce/apex/MasterProgressReportView.getWRF';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CANDIDATE_FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Candidate_Field_Configuration__c';
import getRatingData from '@salesforce/apex/CandidateRatingManager.getRatingDataWrf';
import COLORS from '@salesforce/resourceUrl/Color';
import { loadStyle } from 'lightning/platformResourceLoader';
import getCandidateDataDynamically from '@salesforce/apex/MasterProgressReportView.getCandidateDataDynamically';
import getCustomMetadataClientReportView from '@salesforce/apex/MasterProgressReportView.getCustomMetadataClientReportView';
import { CurrentPageReference } from 'lightning/navigation';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import TC_Status__c from '@salesforce/schema/Bureau_Rating__c.TC_Status__c';
import MFS_Status__c from '@salesforce/schema/Bureau_Rating__c.MFS_Status__c';
import Bureau_Rating__c from '@salesforce/schema/Bureau_Rating__c';
// Import the system used field from job
import System_Used__c from '@salesforce/schema/Job__c.System_Used__c';
import Name from '@salesforce/schema/Job__c.Name';
import Candidate_Count__c from '@salesforce/schema/Job__c.Candidate_Count__c';
import ClientReportSystemUsedMSG from '@salesforce/label/c.ClientReportSystemUsedMSG';
import Modal from 'lightning/modal';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    {
        label: 'Rater Type', fieldName: 'raterType', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Nomination Status', fieldName: 'nominationstatus', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Participant Name', fieldName: 'participantName', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Respondent Name', fieldName: 'respondentName', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Respondent Email', fieldName: 'respondentEmail', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Participant Email', fieldName: 'participantEmail', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'VADC Status', fieldName: 'vadcStatus', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Insights Status', fieldName: 'insightStatus', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'MFS Status', fieldName: 'mfsStatus', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'TC Status', fieldName: 'tcStatus', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Overall Status(MFS + TC)', fieldName: 'overallStatus', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Rater String', fieldName: 'raterString', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Report Ready', fieldName: 'reportReady', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Report Sent', fieldName: 'reportSent', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'MFS Report Sent', fieldName: 'mfsreportSent', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'TC Report Sent', fieldName: 'tcreportSent', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Reminder', fieldName: 'reminder', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Deadline', fieldName: 'deadline', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Comments', fieldName: 'comments', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'File Name', fieldName: 'tcEmail', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Single Use Link', fieldName: 'singleUseLink', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    }, {
        label: 'EmailType', fieldName: 'emailType', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Email File Name', fieldName: 'emailFileName', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Sharepoint File Path', fieldName: 'sharepointFilePath', fixedWidth: 120,
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
];



const startingColumns = [
    {
        label: 'S.No.', fieldName: 'serialNumber', type: 'number', fixedWidth: 75,
        cellAttributes: {
            alignment: 'center',
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Work Request', fieldName: 'workRequestId', type: 'url', fixedWidth: 120,
        typeAttributes: { label: { fieldName: 'workRequest' }, target: '_blank' },
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    {
        label: 'Candidate Id', fieldName: 'candidateRecordId', type: 'url', fixedWidth: 120,
        typeAttributes: { label: { fieldName: 'candidateRecord' }, target: '_blank' },
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    },
    
    {
        label: 'Rating Number', fieldName: 'ratingRecordId', type: 'url', fixedWidth: 120,
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' },
        cellAttributes: {
            class: { fieldName: 'accountColor' }
        }
    }
];


export default class MasterProgressReportView extends NavigationMixin(LightningElement) {
    @track metadataMap = new Map();
    @track picklistValues = [];
    @track picklistValuesMFS = [];
    @track recordTypeId;
    @track callAgain = 0;
    @track loadMoreStatus;
    @track isModalOpen = false; //for client report select fields view
    @track isFilterSelectorOpen = false //for filter selector view
    @track showLoadingSpinner;
    @track captureLastColor;
    @track jsonString;
    @track resultFromChild;
    @track reportlistBackup;
    @api recordId;
    // Import custom label
    label = ClientReportSystemUsedMSG;

    picklistValuesREM = [
        { label: 'Eligible', value: 'Eligible' },
        { label: 'Not Eligible', value: 'Not Eligible' }
    ];

    selectedTCpicklist;
    selectedMFSpicklist;
    data = [];
    ratingData;
    dataCount;
    jobName;
    columns = columns;
    //TCOnlycolumns = TCOnlycolumns;
    tableElement;
    isCssLoaded = false
    varSerialNumber;
    tableData;
    data;
    error;
    generatedWRFId;
    candidateJSON;
    rowHeaderToImport;
    candidateFilterValue;
    jasonstring;
    column2;
    apiListVar;
    reportlist;
    Systemused;
    selectedItemValue;
    metadataRecords;
    totalRatings;
    showExportModal = false;
    updateCandidate = false;
    updatePlatform = false;
    showsystemusemessage = false;

    @wire(CurrentPageReference)
    currentPageRef;

    get recordId() {
        return this.currentPageRef.state.c__recordId;
    }

    get recordUrl() {
        // Construct the URL to navigate to the record detail page
        return `/lightning/r/${this.recordId}/view`;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [System_Used__c, Name, Candidate_Count__c] })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('data: ', JSON.stringify(data));
            // console.log('recordId', this.recordId);
            this.Systemused = data.fields.System_Used__c.value;
            this.jobName = data.fields.Name.value;
            this.totalRatings = data.fields.Candidate_Count__c.value;
            console.log('this.totalRatings: ', this.totalRatings);
            //console.log('system used value', this.Systemused);
        } else if (error) {
            //console.error('Error fetching record:', error);
        }
    }

    @wire(getObjectInfo, { objectApiName: Bureau_Rating__c })
    objectInfo({ error, data }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
            //this.loadPicklistValues(); // Load picklist values initially
        } else if (error) {
            //console.error('Error fetching object info:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: TC_Status__c })
    wiredPicklistValues({ error, data }) {
        if (data) {
            //console.log('Picklist values TC', data.values);
            this.picklistValues = data.values;
        } else if (error) {
            //console.error('Error fetching picklist values: ', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: MFS_Status__c })
    wiredPicklistValuesMFS({ error, data }) {
        if (data) {
            //console.log('Picklist values MFS', data.values);
            this.picklistValuesMFS = data.values;
        } else if (error) {
            //console.error('Error fetching picklist values: ', error);
        }
    }

    @wire(getWRFvalue, { jobId: '$recordId' })
    wiredContacts({ error, data }) {
        if (data) {
            //console.log('Hello' + data);
            this.generatedWRFId = data;
            //console.log('generatedWrfId parent ' + this.generatedWRFId);
            //this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getRecord, { recordId: '$generatedWRFId', fields: [CANDIDATE_FIELD_CONFIGURATION] })
    getCandidateDataFromgeneratedWRF({ error, data }) {
        if (data) {
            let classObject = {};
            let classObject2 = {};
            let dynamicJsonList = [];
            let dynamicJsonListforreport = [];
            let apiList = '';

            this.candidateJSON = JSON.parse(data.fields.Candidate_Field_Configuration__c.value);
            if (!classObject.hasOwnProperty("fieldName")) {
                classObject["fieldName"] = 'accountColor';
            }
            if (!classObject2.hasOwnProperty("class")) {
                classObject2["class"] = classObject;
            }

            //this.createMetadataMap(this.Systemused);

            if (Array.isArray(this.metadataRecords) && this.metadataRecords.length > 0) {
                this.createMetadataMap(this.Systemused);
            }


            this.candidateJSON.forEach(element => {

                let progressObject = {};
                let progressObjectforreport = {};
                if (element.API_Name__c !== 'Category__c') {
                    if (apiList === '') {
                        apiList = element.API_Name__c;
                    } else {
                        apiList = apiList + ',' + element.API_Name__c;
                    }
                    //const key = String(element.Label__c).trim();
                    const key = element.Label__c != null ? String(element.Label__c).trim() : String(element.Label__c);
                    const mapKeysArray = [...this.metadataMap.keys()];

                    if (!progressObject.hasOwnProperty("label")) {
                        progressObject["label"] = element.Label__c;
                    }
                    if (!progressObject.hasOwnProperty("fieldName")) {
                        progressObject["fieldName"] = element.API_Name__c;
                    }
                    if (!progressObject.hasOwnProperty("fixedWidth")) {
                        progressObject["fixedWidth"] = 120;
                    }
                    if (mapKeysArray.includes(key)) { // Corrected key existence check
                        if (!progressObject.hasOwnProperty("readonly")) {
                            progressObject["readonly"] = this.metadataMap.get(key);
                        }
                    }
                    else {
                        progressObject["readonly"] = false;

                    }
                    if (!progressObject.hasOwnProperty("cellAttributes")) {
                        progressObject["cellAttributes"] = classObject2;
                    }

                    //if (!mapKeysArray.includes(key)) { 
                    if (mapKeysArray.some(key => key === element.Label__c) && (element.Label__c === 'First Name' || element.Label__c === 'Last Name' || element.Label__c === 'Email')) {
                        if (!progressObjectforreport.hasOwnProperty("label")) {
                            progressObjectforreport["label"] = element.Label__c;
                        }
                        if (!progressObjectforreport.hasOwnProperty("fieldName")) {
                            progressObjectforreport["fieldName"] = element.API_Name__c;
                        }
                        if (!progressObjectforreport.hasOwnProperty("fixedWidth")) {
                            progressObjectforreport["fixedWidth"] = 120;
                        }
                        if (mapKeysArray.includes(key)) { // Corrected key existence check
                            if (!progressObjectforreport.hasOwnProperty("readonly")) {
                                progressObjectforreport["readonly"] = this.metadataMap.get(key);
                            }
                        }
                        else {
                            progressObjectforreport["readonly"] = false;
                        }
                        if (!progressObjectforreport.hasOwnProperty("cellAttributes")) {
                            progressObjectforreport["cellAttributes"] = classObject2;
                        }
                    }
                    else if (element.Label__c !== 'First Name' && element.Label__c !== 'Last Name' && element.Label__c !== 'Email') {
                        if (!progressObjectforreport.hasOwnProperty("label")) {
                            progressObjectforreport["label"] = element.Label__c;
                        }
                        if (!progressObjectforreport.hasOwnProperty("fieldName")) {
                            progressObjectforreport["fieldName"] = element.API_Name__c;
                        }
                        if (!progressObjectforreport.hasOwnProperty("fixedWidth")) {
                            progressObjectforreport["fixedWidth"] = 120;
                        }
                        if (mapKeysArray.includes(key)) { // Corrected key existence check
                            if (!progressObjectforreport.hasOwnProperty("readonly")) {
                                progressObjectforreport["readonly"] = this.metadataMap.get(key);
                            }
                        }
                        else {
                            progressObjectforreport["readonly"] = false;
                        }
                        if (!progressObjectforreport.hasOwnProperty("cellAttributes")) {
                            progressObjectforreport["cellAttributes"] = classObject2;
                        }
                    }
                    //}

                    // Only push progressObjectforreport if it has properties
                    if (Object.keys(progressObjectforreport).length > 0) {
                        dynamicJsonListforreport.push(progressObjectforreport);
                    }

                    dynamicJsonList.push(progressObject);

                }
            });

            this.apiListVar = apiList;

            //get the field nane and is selected from metdata based on system used on job

            var tempList = [];
            var tempListforreport = [];



            const mapKeysArrayagain = [...this.metadataMap.keys()];
            this.columns.forEach(element => {
                let progressObjectcolumn = {};
                if (mapKeysArrayagain.some(key => key === element.label)) {
                    if (!progressObjectcolumn.hasOwnProperty("label")) {
                        progressObjectcolumn["label"] = element.label;
                    }
                    if (!progressObjectcolumn.hasOwnProperty("fieldName")) {
                        progressObjectcolumn["fieldName"] = element.fieldName;
                    }
                    if (!progressObjectcolumn.hasOwnProperty("fixedWidth")) {
                        progressObjectcolumn["fixedWidth"] = 120;
                    }
                    if (!progressObjectcolumn.hasOwnProperty("readonly")) {
                        progressObjectcolumn["readonly"] = this.metadataMap.get(element.label);
                    }

                    if (!progressObjectcolumn.hasOwnProperty("cellAttributes")) {
                        progressObjectcolumn["cellAttributes"] = classObject2;
                    }
                    //console.log('has which value',element.label);
                    tempListforreport.push(progressObjectcolumn);
                }

                tempList.push(element);
            });



            var newList = [...startingColumns, ...dynamicJsonList, ...tempList];
            var reportinglist = [...tempListforreport];
            //console.log('this.startingColumns saloni',JSON.stringify(startingColumns));
            //console.log('this.dynamicJsonList saloni',JSON.stringify(dynamicJsonList));
            //console.log('this.tempList saloni',JSON.stringify(tempList));
            //console.log('this.tempListforreport saloni',JSON.stringify(tempListforreport));
            //console.log('this.dynamicJsonListforreport saloni',JSON.stringify(dynamicJsonListforreport));
            if (dynamicJsonListforreport == []) {

                this.reportlist = [...reportinglist];
            }
            else {
                this.reportlist = [...dynamicJsonListforreport, ...reportinglist];
            }
            //console.log('this.reportlist',JSON.stringify(this.reportlist));
            this.column2 = [...newList];
            //console.log('this.column2',JSON.stringify(this.column2));
            //console.log('this.apiListVar',JSON.stringify(this.apiListVar));
            this.getRatingData();
        }
    }

    openModal() {
        //console.log('this.Systemusedin openclientview',this.Systemused);
        if (!this.Systemused.includes('MFS') && !this.Systemused.includes('TalentCentral')) {
            //console.log('showsystemusemessage ifststmt',this.showsystemusemessage);
            this.showsystemusemessage = true;
        }
        else {
            //console.log('showsystemusemessage else',this.showsystemusemessage);
            this.isModalOpen = true;
        }


    }

    closeModal() {
        this.isModalOpen = false;
        this.showsystemusemessage = false;
        this.isFilterSelectorOpen = false;
        this.updateCandidate = false;
        this.updatePlatform = false;
    }

    handleChildSave(event) {
        this.resultFromChild = event.detail.selectedFields; // Get data from the child
        console.log('Data from child:', JSON.stringify(this.resultFromChild));
        this.reportlistBackup = event.detail.allfields;
        console.log('Data from child all fields ' + JSON.stringify(this.reportlistBackup));
        //console.log('reportlistBackup backup:', JSON.stringify(this.reportlistBackup));
    }
    handleFilterFieldsSelection(event) {
        this.selectedFilterFields = event.detail; // Get data from the child
        console.log('Selected Filter Fields: ', JSON.stringify(this.selectedFilterFields));
    }

    openfilterselectorview() {
        this.isModalOpen = false;
        this.isFilterSelectorOpen = true;

    }

    openclientview() {
        if (this.selectedFilterFields == null || this.selectedFilterFields == undefined || this.selectedFilterFields.length == 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'At least one filter should be selected before moving ahead.',
                    variant: 'error',
                    mode: 'auto'
                })
            );
            return;
        }
        //this.isModalOpen = false;
        this.isFilterSelectorOpen = false;
        //Convert JSON object to string
        const selectedFieldsString = JSON.stringify(this.resultFromChild);
        const selectedFilterString = JSON.stringify(this.selectedFilterFields);
        // Prepare the selected fields for the new tab
        const selectedFieldsQueryParam = encodeURIComponent(selectedFieldsString);
        const selectedFilterParam = encodeURIComponent(selectedFilterString);

        // Construct URL for the new tab with query params
        //const newTabUrl = `/c/popup?selectedFields=${selectedFieldsQueryParam}`;


        // Use NavigationMixin to navigate to the child LWC with a parameter
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage', // You can also use 'standard__recordPage'
            attributes: {
                apiName: 'ClientReportView'  // This should be the API name of the Lightning Page that hosts the child LWC
            },
            state: {
                c__selectedFields: selectedFieldsQueryParam,
                c__selectedFilters: selectedFilterParam,
                c__jobId: this.recordId,
                c__hideButton: false,
                c__fromParent: false,
            }
        });
        // Open a new tab
        //window.open(url, '_blank');


    }



    //On TC picklist value change
    handleChange(event) {
        this.selectedTCpicklist = event.detail.value;
        //console.error('selected value TC: ', this.candidateFilterValue);
        this.callAgain += 1;
        this.getRatingData();
    }

    //On MFS picklist value change
    handleChangeMFS(event) {
        this.selectedMFSpicklist = event.detail.value;
        //console.error('selected value MFS: ', this.candidateFilterValue);
        this.callAgain += 1;
        this.getRatingData();
    }

    //On Reminder picklist value change
    handleChangeREM(event) {
        this.selectedREMpicklist = event.detail.value;
        //console.error('selected value Reminder: ', this.candidateFilterValue);
        this.callAgain += 1;
        this.getRatingData();
    }

    // Convert list of strings to JSON object
    handleBuildJSON() {
        let jsonObject = {};

        jasonstring.forEach(item => {
            //let [key, value] = item.split(',');
            jsonObject[key.trim()] = item.split(',');
        });

        // Convert JSON object to string
        this.jsonString = JSON.stringify(jsonObject, null, 2);
    }

    connectedCallback() {
        //console.log('Record ID on load:', this.recordId);

        this.showLoadingSpinner = true;
        this.loadMetadata();
    }

    loadMetadata() {
        getCustomMetadataClientReportView()
            .then(data => {
                this.metadataRecords = data;

                //console.log('Custom Metadata:', JSON.stringify(data));
            })
            .catch(error => {
                //console.error('Error fetching metadata:', error);
            });
    }


    createMetadataMap(systemUsed) {
        if (!this.metadataRecords || !Array.isArray(this.metadataRecords)) {
            //console.error('metadataRecords is undefined or not an array');
            this.metadataMap = new Map();
            return;
        }
        //const systemUsedKeywords = systemUsed.split(';').map(s => s.trim().toLowerCase().replace(/\+/g, '')); // Remove all '+' characters
        //const systemUsedKeywords = systemUsed.trim().toLowerCase().replace(/\+/g, ''); // Remove all '+' characters
        const systemUsedKeywords = systemUsed && systemUsed.trim() !== ''
            ? systemUsed.trim().toLowerCase().replace(/\+/g, '')
            : systemUsed?.toLowerCase().replace(/\+/g, '');


        const filteredRecords = this.metadataRecords.filter(record => {
            if (!record.System_Used__c) return false; // Skip records without System_Used__c
            const systemList = record.System_Used__c.trim().toLowerCase().replace(/\+/g, '');

            return systemUsedKeywords === systemList;


        });

        //console.log('filteredRecords:', JSON.stringify(filteredRecords)); // Debugging: Check the filteredRecords
        this.metadataMap = new Map(filteredRecords.map(record => [record.Field_Name__c, record.Is_Selected__c]));
        const keysArray = [...this.metadataMap.keys()]; // Convert Map keys to an array
        //console.log('Map Keys:', JSON.stringify(keysArray)); // Log the keys to the console
    }



    renderedCallback() {
        if (this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(() => {
        }).catch(error => {
            //console.error("Error in loading the colors", error);
        })
    }

    loadData(event) {
        event.preventDefault();
        //console.log('Inside Load More Data');
        if (event.target) {
            //console.log('Inside If Load More Data');
            event.target.isLoading = true;
        }
        this.tableElement = event.target;
        this.loadMoreStatus = 'Loading';
        this.getMoreRatingData();
    }

    handleCandidateFilterValue(event) {
        this.candidateFilterValue = event.detail.value;
        this.handleSearchAction();
    }

    handleEnter(event) {
        if (event.keyCode === 13) {
            this.handleSearchAction();
        }
    }

    handleSearchAction(event) {
        this.callAgain += 1;
        this.getRatingData();
    }

    getMoreRatingData() {
        this.tableElement.isLoading = true;
        //console.log('this.dataCount moredata in masterview',this.dataCount);
        getRatingData({ soqlQueryList: this.apiListVar, jobId: this.recordId, offSetValue: this.dataCount, filterValue: this.candidateFilterValue, TCstatus: this.selectedTCpicklist, MFSstatus: this.selectedMFSpicklist, ReminderVal: this.selectedREMpicklist })
            .then(result => {
                let tempRecords = JSON.parse(JSON.stringify(result.ratingData));
                //console.log('tempRecords masterview getmoredata: ', JSON.stringify(tempRecords));
                let tempRecordsCandidate = JSON.parse(JSON.stringify(result.candidateData));
                //console.log('tempRecordsCandidate: ', JSON.stringify(tempRecordsCandidate));
                let finalData = {};
                tempRecords = tempRecords.map(item => {
                    // const additionalData = this.data.find(attr => attr.Id === item.Participant__r.Id);
                    let index = tempRecordsCandidate.findIndex(attr => item.Respondent__r.Id === attr.Id);

                    let additionalData = tempRecordsCandidate[index];
                    if (additionalData) {
                        finalData = { ...additionalData, ...item };
                        item = finalData;
                    }
                    return item;
                });

                let selfIndexCounter;

                tempRecords = tempRecords.map((row, index) => {
                    selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : (row.Rater_Type__c == 'Manager') ? 1 : (row.Rater_Type__c == 'Colleagues') ? 2 : (row.Rater_Type__c == 'Others') ? 3 : (row.Rater_Type__c == 'Direct Reports') ? 4 : 5;
                    return {
                        ...row,
                        selfIndex: selfIndexCounter,
                    };
                });

                tempRecords.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.Participant__r.Email__c.localeCompare(b.Participant__r.Email__c) || a.selfIndex - b.selfIndex);

                let rowColor1;
                let serialNumberCount;
                let serialNumber1;

                serialNumberCount = this.dataCount;
                tempRecords = tempRecords.map((row, index) => {
                    if (index == 0) {
                        serialNumber1 = serialNumberCount + 1;
                    }
                    rowColor1 = (row.Rater_Type__c == 'Self') ? 'datatable-green' : (row.Rater_Type__c == 'Manager') ? 'datatable-grey' : (row.Rater_Type__c == 'Colleagues') ? 'datatable-orange' : (row.Rater_Type__c == 'Others') ? 'datatable-blue' : (row.Rater_Type__c == 'Direct Reports') ? 'datatable-yellow' : 'datatable-grey';
                    return {
                        ...row,
                        ratingRecordId: (row ? ('/lightning/r/Bureau_Rating__c/' + row.Id + '/view') : null),
                        candidateRecordId: (row ? ('/lightning/r/Bureau_Candidate__c/' + row.Respondent__c + '/view') : null),
                        candidateRecord: (row.Respondent__r ? row.Respondent__r.Name : null),
                        workRequestId: (row ? ('/lightning/r/Work_Request__c/' + row.Participant__r.Work_Request__c + '/view') : null),
                        workRequest: (row.Participant__r.Work_Request__r ? row.Participant__r.Work_Request__r.Name : null),
                        raterType: (row.Rater_Type__c),
                        participantName: (row.Participant__r ? row.Participant__r.Full_Name__c : null),
                        participantEmail: (row.Participant__r ? row.Participant__r.Email__c : null),
                        respondentName: (row.Respondent__r ? row.Respondent__r.Full_Name__c : null),
                        respondentEmail: (row.Respondent__r ? row.Respondent__r.Email__c : null),
                        reportStatus: (row.Participant__r ? row.Participant__r.Reports_Status__c : null),
                        vadcStatus: (row.Participant__r ? row.VADC_Status__c : null),
                        insightStatus: (row.Participant__r ? row.Insights_Status__c : null),
                        nominationstatus: (row.Participant__r ? row.Nomination_Status__c : null),
                        mfsStatus: (row.Participant__r ? row.MFS_Status__c : null),
                        tcStatus: (row.Participant__r ? row.TC_Status__c : null),
                        overallStatus: (row.Participant__r ? row.Overall_Status__c : null),
                        raterString: (row.Rater_Type__c != 'Self') ? (row.Rater_String__c) : null,
                        reportReady: (row.Rater_Type__c == 'Self') ? (row.Report_Ready__c) : null,
                        reportSent: (row.Participant__r ? row.Report_Sent__c : null),
                        mfsreportSent: (row.Participant__r ? row.MFS_Report_Sent__c : null),
                        tcreportSent: (row.Participant__r ? row.TC_Report_Sent__c : null),
                        reminder: (row.Reminder__c),
                        deadline: (row.Participant__r ? row.Deadline__c : null),
                        comments: (row.Participant__r ? row.Comments__c : null),
                        tcEmail: (row.Participant__r ? row.File_Name__c : null),
                        singleUseLink: (row.Participant__r ? row.Single_Use_Link__c : null),
                        emailType: (row.Participant__r ? row.EmailType__c : null),
                        emailFileName: (row.Participant__r ? row.Email_File_Name__c : null),
                        sharepointFilePath: (row.Participant__r ? row.Sharepoint_File_Path__c : null),
                        accountColor: rowColor1,
                        serialNumber: serialNumber1 + index,
                    };
                })
                this.data = this.data.concat(tempRecords);
                this.dataCount = this.data.length;
                this.loadMoreStatus = '';
                if (this.tableElement) {
                    this.tableElement.isLoading = false;
                }
                if (tempRecords.length < 200) {
                    this.tableElement.enableInfiniteLoading = false;
                    this.loadMoreStatus = 'No more data to load';
                }
            })
            .catch(error => {
                //console.log('error ====> ', error);
            });
    }

    getRatingData() {
        getRatingData({ soqlQueryList: this.apiListVar, jobId: this.recordId, offSetValue: 0, filterValue: this.candidateFilterValue, TCstatus: this.selectedTCpicklist, MFSstatus: this.selectedMFSpicklist, ReminderVal: this.selectedREMpicklist })
            .then(result => {
                this.showLoadingSpinner = false;
                let tempRecords = JSON.parse(JSON.stringify(result.ratingData));
                let tempRecordsCandidate = JSON.parse(JSON.stringify(result.candidateData));
                let finalData = {};
                tempRecords = tempRecords.map(item => {
                    let index = tempRecordsCandidate.findIndex(attr => item.Respondent__r.Id === attr.Id);

                    let additionalData = tempRecordsCandidate[index];
                    if (additionalData) {
                        finalData = { ...additionalData, ...item };
                        item = finalData;
                    }
                    return item;
                });

                let selfIndexCounter;
                tempRecords = tempRecords.map((row, index) => {
                    selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : (row.Rater_Type__c == 'Manager') ? 1 : (row.Rater_Type__c == 'Colleagues') ? 2 : (row.Rater_Type__c == 'Others') ? 3 : (row.Rater_Type__c == 'Direct Reports') ? 4 : 5;
                    return {
                        ...row,
                        selfIndex: selfIndexCounter,
                    };
                });
                let rowColor1;
                let counterFlag1 = true;
                let counter1;
                let colorList1 = ['datatable-orange', 'datatable-grey'];
                tempRecords.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.Participant__r.Email__c.localeCompare(b.Participant__r.Email__c) || a.selfIndex - b.selfIndex);
                tempRecords = tempRecords.map((row, index) => {
                    rowColor1 = (row.Rater_Type__c == 'Self') ? 'datatable-green' : (row.Rater_Type__c == 'Manager') ? 'datatable-grey' : (row.Rater_Type__c == 'Colleagues') ? 'datatable-orange' : (row.Rater_Type__c == 'Others') ? 'datatable-blue' : (row.Rater_Type__c == 'Direct Reports') ? 'datatable-yellow' : 'datatable-grey';

                    return {
                        ...row,
                        ratingRecordId: (row ? ('/lightning/r/Bureau_Rating__c/' + row.Id + '/view') : null),
                        candidateRecordId: (row ? ('/lightning/r/Bureau_Candidate__c/' + row.Respondent__c + '/view') : null),
                        candidateRecord: (row.Respondent__r ? row.Respondent__r.Name : null),
                        workRequestId: (row ? ('/lightning/r/Work_Request__c/' + row.Participant__r.Work_Request__c + '/view') : null),
                        workRequest: (row.Participant__r.Work_Request__r ? row.Participant__r.Work_Request__r.Name : null),
                        raterType: (row.Rater_Type__c),
                        participantName: (row.Participant__r ? row.Participant__r.Full_Name__c : null),
                        participantEmail: (row.Participant__r ? row.Participant__r.Email__c : null),
                        respondentName: (row.Respondent__r ? row.Respondent__r.Full_Name__c : null),
                        respondentEmail: (row.Respondent__r ? row.Respondent__r.Email__c : null),
                        reportStatus: (row.Participant__r ? row.Participant__r.Reports_Status__c : null),
                        vadcStatus: (row.Participant__r ? row.VADC_Status__c : null),
                        insightStatus: (row.Participant__r ? row.Insights_Status__c : null),
                        nominationstatus: (row.Participant__r ? row.Nomination_Status__c : null),
                        mfsStatus: (row.Participant__r ? row.MFS_Status__c : null),
                        tcStatus: (row.Participant__r ? row.TC_Status__c : null),
                        overallStatus: (row.Participant__r ? row.Overall_Status__c : null),
                        raterString: (row.Rater_Type__c != 'Self') ? (row.Rater_String__c) : null,
                        reportReady: (row.Rater_Type__c == 'Self') ? (row.Report_Ready__c) : null,
                        reportSent: (row.Participant__r ? row.Report_Sent__c : null),
                        mfsreportSent: (row.Participant__r ? row.MFS_Report_Sent__c : null),
                        tcreportSent: (row.Participant__r ? row.TC_Report_Sent__c : null),
                        reminder: (row.Reminder__c),
                        deadline: (row.Participant__r ? row.Deadline__c : null),
                        comments: (row.Participant__r ? row.Comments__c : null),
                        tcEmail: (row.Participant__r ? row.File_Name__c : null),
                        singleUseLink: (row.Participant__r ? row.Single_Use_Link__c : null),
                        emailType: (row.Participant__r ? row.EmailType__c : null),
                        emailFileName: (row.Participant__r ? row.Email_File_Name__c : null),
                        sharepointFilePath: (row.Participant__r ? row.Sharepoint_File_Path__c : null),
                        accountColor: rowColor1,
                        serialNumber: index + 1,
                    };
                })
                this.data = tempRecords;
                this.loadMoreStatus = '';
                this.dataCount = this.data.length;
                if (this.tableElement) {
                    this.tableElement.isLoading = false;
                    this.tableElement.enableInfiniteLoading = true;
                }
            })
            .catch(error => {
                console.log('error ====> ', JSON.stringify(error));
            });
    }

    //@wire(getCandidateDataDynamically, { soqlQueryList: '$apiListVar', jobId: '$recordId', resetVar: '$callAgain' })
    getCandidateData() {
        getCandidateDataDynamically({
            soqlQueryList: this.apiListVar, jobId: this.recordId, offSetValue: 0, filterValue: this.candidateFilterValue
        })
            .then(data => {
                //console.log('candidate data count: ', data.length);
                //console.log('data ', JSON.stringify(data));
                let tempRecords = JSON.parse(JSON.stringify(data));
                let selfIndexCounter;
                let finalData = {};
                tempRecords = tempRecords.map(item => {
                    // const additionalData = this.data.find(attr => attr.Id === item.Participant__r.Id);
                    let index = this.ratingData.findIndex(attr => item.Id === attr.Participant__r.Id);

                    let additionalData = this.ratingData[index];
                    if (additionalData) {

                        //console.log('item: ', JSON.stringify(item));
                        finalData = { ...item, ...additionalData };
                        //console.log('finalData: ', finalData);
                        item = finalData;
                    }
                    return item;
                });
                this.data = tempRecords;
                this.loadMoreStatus = '';
                this.dataCount = this.data.length;
                if (this.tableElement) {
                    this.tableElement.isLoading = false;
                    this.tableElement.enableInfiniteLoading = true;
                }
            })
            .catch(error => {
                //console.log('error ', JSON.stringify(error));
            });
    }

    handleRefresh() {
        this.candidateFilterValue = '';
        this.selectedTCpicklist = '';
        this.selectedMFSpicklist = '';
        this.selectedREMpicklist = '';
        this.getRatingData();
        this.callAgain += 1;
    }

    handleOnselect(event) {
        this.selectedItemValue = event.detail.value;
        this.showExportModal = true;
    }

    resetChildComponent() {
        this.showExportModal = false;
    }

    openUpdateCandidate() {
        this.updateCandidate = true;
    }

    openUpdatePlatform() {
        this.updatePlatform = true;
    }

    updateDone() {
        this.updatePlatform = false;
        this.updateCandidate = false;
        this.handleRefresh();
    }

    handleBack() {
        if (this.reportlistBackup) {
            this.reportlist = JSON.parse(JSON.stringify(this.reportlistBackup));
        }
        this.isModalOpen = true;
        this.isFilterSelectorOpen = false;
    }
}