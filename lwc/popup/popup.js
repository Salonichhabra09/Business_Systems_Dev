import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getRatingData from '@salesforce/apex/CandidateRatingManager.getRatingDataForReportView';
import sendEmailClientReport from '@salesforce/apex/MasterProgressReportView.sendEmailClientReport';
import decodeurlparamater from '@salesforce/apex/MasterProgressReportView.decodeurlparamater';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACTID_FIELD from "@salesforce/schema/Job__c.Opportunity__r.Primary_Contact__c";
import JOB_NAME from "@salesforce/schema/Job__c.Name";
import SENDER_EMAIL from "@salesforce/schema/Job__c.Sender_Email__c";
import PRIMARY_CONTACT_NAME from "@salesforce/schema/Job__c.Opportunity__r.Primary_Contact__r.Name";
import PROJECT_MANAGER_NAME from "@salesforce/schema/Job__c.Project_Manager__r.Name";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import CANDIDATE_FIELD_CONFIGURATION from '@salesforce/schema/Work_Request__c.Candidate_Field_Configuration__c';
import JOB_ID from '@salesforce/schema/Work_Request__c.Job__c';
import JOB_NAME_WRF from '@salesforce/schema/Work_Request__c.Job__r.Name';
import COLORS from '@salesforce/resourceUrl/Color';
import System_Used__c from '@salesforce/schema/Job__c.System_Used__c';
import { loadStyle } from 'lightning/platformResourceLoader';
import WRF_Footer from '@salesforce/label/c.WRF_Footer';
import WRF_Client_Banner from '@salesforce/resourceUrl/WRF_Client_Banner'; // Replace 'myImage' with your static resource name
import getPicklistValues from '@salesforce/apex/CandidateRatingManager.getPicklistValues';
import getBanner from '@salesforce/apex/CustomerRequestController.relatedFilesWire';
const arrayMap4 = { "Participant__r.Full_Name__c": "Participant Name", "Participant__r.Email__c": "Participant Email","Respondent__r.Full_Name__c": "Respondent Name", "Respondent__r.Email__c": "Respondent Email", "Rater_Type__c": "Rater Type", "MFS_Status__c": "MFS Status", "TC_Status__c": "TC Status", "Overall_Status__c": "Overall Status", "Nomination_Status__c":"Nomination Status","Report_Ready__c": "Report Ready", "Report_Sent__c": "Report Sent", "MFS_Report_Sent__c": "MFS Report Sent", "TC_Report_Sent__c": "TC Report Sent", "Reminder__c": "Reminder", "Deadline__c": "Deadline", "Comments__c": "Comments", "File_Name__c": "File Name", "Single_Use_Link__c": "Single Use Link", "VADC_Status__c": "VADC Status", "Insights_Status__c": "Insights Status", };
const arrayMap7 = {  "Participant__r.Full_Name__c": "Participant Name", "Participant__r.Email__c": "Participant Email", "Respondent__r.Full_Name__c": "Respondent Name", "Respondent__r.Email__c": "Respondent Email", "Rater_Type__c": "Rater Type", "MFS_Status__c": "360 Status", "TC_Status__c": "Assessment Status", "Overall_Status__c": "Overall Status", "Nomination_Status__c":"Nomination Status","Report_Ready__c": "Report Ready", "Report_Sent__c": "Report Sent", "MFS_Report_Sent__c": "360 Report Sent", "TC_Report_Sent__c": "Assessment Report Sent", "Reminder__c": "Reminder", "Deadline__c": "Deadline", "Comments__c": "Comments", "File_Name__c": "File Name", "Single_Use_Link__c": "Single Use Link", "VADC_Status__c": "VADC Status", "Insights_Status__c": "Insights Status", };
const arrayMap1 = {  "participantName": "Participant Name", "participantEmail": "Participant Email", "respondentName": "Respondent Name", "respondentEmail": "Respondent Email", "Rater_Type__c": "Rater Type", "MFS_Status__c": "MFS Status", "TC_Status__c": "TC Status", "Overall_Status__c": "Overall Status(MFS + TC)", "nominationstatus":"Nomination Status","Report_Ready__c": "Report Ready", "Report_Sent__c": "Report Sent", "MFS_Report_Sent__c": "MFS Report Sent", "TC_Report_Sent__c": "TC Report Sent", "Reminder__c": "Reminder", "Deadline__c": "Deadline", "Comments__c": "Comments", "File_Name__c": "File Name", "Single_Use_Link__c": "Single Use Link", "VADC_Status__c": "VADC Status", "Insights_Status__c": "Insights Status", };
const arrayMap2 = {  "participantName": "Participant Name", "participantEmail": "Participant Email","respondentName": "Respondent Name", "respondentEmail": "Respondent Email", "Rater_Type__c": "Rater Type", "MFS_Status__c": "MFS Status", "TC_Status__c": "TC Status", "Overall_Status__c": "Overall Status(MFS + TC)", "nominationstatus":"Nomination Status","Report_Ready__c": "Report Ready", "Report_Sent__c": "Report Sent", "MFS_Report_Sent__c": "MFS Report Sent", "TC_Report_Sent__c": "TC Report Sent", "Reminder__c": "Reminder", "Deadline__c": "Deadline", "Comments__c": "Comments", "File_Name__c": "File Name", "Single_Use_Link__c": "Single Use Link", "VADC_Status__c": "VADC Status", "Insights_Status__c": "Insights Status", };
const arrayMap5 = { "Foci Name": "Foci Name","Participant Email": "Participant Email", "Respondent Name": "Respondent Name", "Respondent Email": "Respondent Email", "Rater Type": "Rater Type", "360 Status": "MFS Status", "Assessment Status": "TC Status", "Overall Status(360 + Assessment)": "Overall Status(MFS + TC)", "Nomination Status":"Nomination Status", "Report Ready": "Report Ready", "Report Sent": "Report Sent", "360 Report Sent": "MFS Report Sent", "Assessment Report Sent": "TC Report Sent", "Reminder": "Reminder", "Deadline": "Deadline", "Comments": "Comments", "File Name": "File Name", "Single Use Link": "Single Use Link", "VADC Status": "VADC Status", "Insights Status": "Insights Status", };
const arrayMap6 = {  "Participant__r.Full_Name__c": "Foci Name", "MFS_Status__c": "MFS Status", "TC_Status__c": "TC Status", "Overall_Status__c": "Overall Status(MFS + TC)", "Nomination_Status__c" :"Nomination Status ", "MFS_Report_Sent__c": "MFS Report Sent", "TC_Report_Sent__c": "TC Report Sent" };
import shlLogo from '@salesforce/resourceUrl/ClientDashboardBanner';
import ISACTIVE from '@salesforce/schema/Work_Request__c.Is_Active__c';
const labelUpdates = {
    "Overall Status(MFS + TC)": "Overall Status(360 + Assessment)",
    "MFS Report Sent": "360 Report Sent",
    "MFS Status": "360 Status",
    "TC Status": "Assessment Status",
    "TC Report Sent": "Assessment Report Sent"
};
export default class CheckboxFields extends NavigationMixin(LightningElement) {
    @api message;
    @api messageview;
    @track loadMoreStatus;
    @track loadMoreStatusSelf;
    @track showLoadingSpinner;
    @track selectedFields = [];
    @track selectedFilters = [];
    @track dataToSendBack = ''; // Data to be sent back to the parent
    @track columns = [];
    parsedData;
    newObject;
    fields;
    dynamicJsonList;
    data = [];
    tableElement;
    tableElementSelf;
    jasondata;
    selectedFieldsData;
    selectedFieldsDataRaw;
    selectedFieldsDataSelfExport;
    selectedFieldsConfiguration;
    // Wire the CurrentPageReference to get the parameters
    @wire(CurrentPageReference)
    pageRef;
    candidateFilterValue;
    jsonData;
    jsonDataSelf;
    jobId;
    tabledata = [];
    columnvalue;
    columnvalueself;
    columnvalueFromWRF;
    dataCount;
    dataCountself;
    apilistforserach = '';
    disableSubmit = false;
    showSpinner = false;
    successMessage = '';
    isSubmitUI = false;
    hidebutton = false;
    isAuthenticationUI = false;
    emailData;
    recordIdjob;
    reffromParent = false;
    wrfId;
    exportReportFlag = false;
    exportReportFlagSelf = false;
    isCssLoaded = false;
    jobnameWRF = '';
    isMFSview = false;
    dynamicHeight = '600px';  // Default height for full report
    dynamicHeightSelf = '600px';  // Default height for self report
    filters = {};
    // Set both sections to be open by default
    activeSections = ['section1', 'section2', 'section3'];
    label = {
         WRF_Footer
    };
    imageUrl = WRF_Client_Banner; // Testing image for Banner
    ratingApiNameList;
    candidateApiNameList;
    heading = 'Access your Report & Dashboard';
    isActive=true;
    jsonDataSelfBackup;
    dropdownFilterFields = ['Rater_Type__c', 'MFS_Status__c', 'TC_Status__c', 'Report_Ready__c','TC_Report_Sent__c','MFS_Report_Sent__c','Reminder__c','Overall_Status__c'];
    dropdownFilterFieldslabels = ['Rater Type', '360 Status', 'Assessment Status', 'Assessment Report Sent','360 Report Sent','Reminder','Overall Status(MFS + TC)'];
    @track dropdownOptions = {};
    /*get shlLogo() {
        return shlLogo;
    }*/
             fetchDropdownOptions() {
                //console.log('Inside fetchDropdownOptions');
                const objectName = 'Bureau_Rating__c'; // Replace with your actual object API name
                const picklistFields = this.dropdownFilterFields; // List of dropdown fields
            
                if (!picklistFields || picklistFields.length === 0) {
                    //console.warn('No dropdown fields found.');
                    return Promise.resolve();
                }
            
                return getPicklistValues({ objectName, fieldNames: picklistFields })
                    .then(result => {
                        if (!this.dropdownOptions) {
                            this.dropdownOptions = {};
                        }
            
                        Object.keys(result).forEach(fieldName => {
                            this.dropdownOptions[fieldName] = [
                                { label: '-- None --', value: null }, // Adding the null option
                                ...result[fieldName].map(value => ({
                                    label: value,
                                    value: value
                                }))
                            ];
                        });
                        this.dropdownOptions['Reminder__c'] = [
                            { label: '-- None --', value: null },
                            { label: 'Eligible', value: 'Eligible' },
                            { label: 'Not Eligible', value: 'Not Eligible' }
                        ];
                        this.dropdownOptions['Overall_Status__c'] = [
                            { label: '-- None --', value: null },
                            { label: 'Not Started', value: 'Not Started' },
                            { label: 'In Progress', value: 'In Progress' },
                            { label: 'Completed', value: 'Completed' },
                            { label: 'Ready to Submit', value: 'Ready to Submit' }
                        ];

            
                        //console.log('Dropdown options updated:', JSON.stringify(this.dropdownOptions));
                    })
                    .catch(error => {
                        //console.error('Error fetching picklist values:', error);
                    });
            }
            
            
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            const stateParams = currentPageReference.state;
            // Check if the stateParams contains the 'recordIdjob' parameter
            if (stateParams && stateParams.c__jobId) {
                this.recordIdJob = stateParams.c__jobId;
                //console.log('recordIdjob:', this.recordIdJob);
            } else {
                //console.error('recordIdjob parameter is not available in the URL');
            }

        }
        else {
            //console.error('currentPageReference is undefined');
        }
    }

    @wire(getBanner, { evaluatorId: '$jobId' })
    idPhotoDetails({ data, error }) {
        if (data!=null) {
            //console.log('data', data);
            this.shlLogo = data;
        }
        else if(data==null){
            this.shlLogo = shlLogo;
        }
         else if (error) {
        }
    }

    @wire(getRecord, {
        recordId: "$jobId",
        fields: [CONTACTID_FIELD, JOB_NAME, SENDER_EMAIL, PRIMARY_CONTACT_NAME, PROJECT_MANAGER_NAME]
    })
    jobRecord;

    @wire(getRecord, { recordId: '$jobId', fields: [System_Used__c] })
    wiredRecord({ error, data }) {
        if (data) {
            this.Systemused = data.fields.System_Used__c.value;
            if(this.Systemused.includes('MFS')){
                this.isMFSview = true;
                this.showLoadingSpinner = false;
            }
            //console.log('system used value', this.Systemused);
        } else if (error) {
            //console.error('Error fetching record:', error);
        }
    }

    @wire(getRecord, { recordId: '$wrfId', fields: [CANDIDATE_FIELD_CONFIGURATION, JOB_ID, JOB_NAME_WRF,ISACTIVE] })
    getCandidateDataFromReportingWRF({ error, data }) {
        if (data) {
            this.jobnameWRF = data.fields.Job__r.value.fields.Name.value;
            this.showLoadingSpinner = false;
            this.isActive = getFieldValue(data, ISACTIVE);
            //this.heading = 'Report View for Request:' + this.jobnameWRF;
            //console.log('getCandidateDataFromgeneratedWRF data: ', JSON.stringify(data));
            if (data.fields.Job__c.value) {
                this.jobId = data.fields.Job__c.value;
                this.isAuthenticationUI = true;
            }
            if (data.fields.Candidate_Field_Configuration__c.value) {
                this.selectedFieldsData = JSON.parse(data.fields.Candidate_Field_Configuration__c.value);
                this.columnvalueFromWRF = JSON.parse(data.fields.Candidate_Field_Configuration__c.value);
            }
            //console.log('this.columnvalue in wire: ', JSON.stringify(this.columnvalueFromWRF));
            //console.log('this.selectedFieldsData: ', JSON.stringify(this.selectedFieldsData));
            this.messageview = true;
            this.createJSONForColumns();
        }
    }

    createJSONForColumns() {
        if (this.selectedFieldsData) {
            let classObject = {};
            let classObject2 = {};
            let dynamicJsonListagain = [];
            let dynamicJsonListagainself = [];
            let ratingApiNameList = 'Id';
            let candidateApiNameList = 'Id';

            const tempList = this.selectedFieldsData;
            this.fields = [...tempList];
            
            this.fields.forEach(element => {
                if(this.reffromParent){
                    if (element.label) {
                        //console.log('element.label nomination label',element.label);
                        let rowKey = this.getKeyByValue(arrayMap7, element.label) ? this.getKeyByValue(arrayMap7, element.label) : this.getKeyByValue(arrayMap6, element.label);
                        if (rowKey) {
                            ratingApiNameList += ', ' + rowKey;
                        }
                        if (element.label == 'Overall Status(360 + Assessment)') {
                            ratingApiNameList += ', ' + 'Overall_Status__c';
                        }
                        //console.log('external ratingApiNameList', ratingApiNameList);
                    }

                }
                else{
                    if (element.label) {
                        //console.log('--apivalue--'+this.getKeyByValue(arrayMap4, element.label)?this.getKeyByValue(arrayMap4, element.label):this.getKeyByValue(arrayMap6, element.label));
                        let rowKey = this.getKeyByValue(arrayMap4, element.label) ? this.getKeyByValue(arrayMap4, element.label) : this.getKeyByValue(arrayMap6, element.label);
                        if (rowKey) {
                            ratingApiNameList += ', ' + rowKey;
                        }
                        if (element.label == 'Overall Status(360 + Assessment)') {
                            ratingApiNameList += ', ' + 'Overall_Status__c';
                        }
                       // console.log('internal ratingApiNameList', ratingApiNameList);
                    }
                }

                if (!this.wrfId && element.hasOwnProperty('fieldName')) {
                    candidateApiNameList += ', ' + element.fieldName;
                }
                
                if (this.wrfId && element.hasOwnProperty('fieldName')) {
                    if (element.fieldName.includes('__c') && (element.fieldName == 'Email__c' || (!ratingApiNameList.includes(element.fieldName)))) {
                        candidateApiNameList += ', ' + element.fieldName;
                    }
                }
                
            });
            if(!ratingApiNameList.includes('Participant__r.Email__c')){
                ratingApiNameList += ', ' + 'Participant__r.Email__c';
            }
            if(!ratingApiNameList.includes('Respondent__r.Email__c')){
                ratingApiNameList += ', ' + 'Respondent__r.Email__c';
            }
            if(!ratingApiNameList.includes('Participant__r.Full_Name__c')){
                ratingApiNameList += ', ' + 'Participant__r.Full_Name__c';
            }
            if(!candidateApiNameList.includes('Email__c')){
                candidateApiNameList += ', ' + 'Email__c';
            }
            if(!candidateApiNameList.includes('First_Name__c')){
                candidateApiNameList += ', ' + 'First_Name__c';
            }
            if(!candidateApiNameList.includes('Last_Name__c')){
                candidateApiNameList += ', ' + 'Last_Name__c';
            }
            //console.log('jobId', this.jobId);
            //console.log('wrfId', this.wrfId);
            //console.log('ratingApiNameList: ', ratingApiNameList);
            //console.log('candidateApiNameList: ', JSON.stringify(candidateApiNameList));


            if (!classObject.hasOwnProperty("fieldName")) {
                classObject["fieldName"] = 'accountColor';
            }
            if (!classObject2.hasOwnProperty("class")) {
                classObject2["class"] = classObject;
            }

            //console.log('before column structure: ', JSON.stringify(this.fields));
            //construct table jason structure for data 
            const progressObject = {
                label: 'S.No.',
                fieldName: 'serialNumber',
                minColumnWidth: 75,  // Minimum width
                maxColumnWidth: 300,   // Maximum width
                cellAttributes: classObject2
            };
            dynamicJsonListagain.push(progressObject);
            dynamicJsonListagainself.push(progressObject);
            if(!dynamicJsonListagainself.some(item => item.label === 'First Name')){
                //console.log('first name before dynamicJsonListagainself ', JSON.stringify(dynamicJsonListagainself));
                const progressObject = {
                    label: 'First Name',
                    fieldName: 'First_Name__c',
                    minColumnWidth: 180,  // Minimum width
                    maxColumnWidth: 300,   // Maximum width
                    cellAttributes: classObject2
                };
                dynamicJsonListagainself.push(progressObject);
                //console.log('first name after dynamicJsonListagainself ', JSON.stringify(dynamicJsonListagainself));
            }
            if(!dynamicJsonListagainself.some(item => item.label === 'Last Name')){
                const progressObject = {
                    label: 'Last Name',
                    fieldName: 'Last_Name__c',
                    minColumnWidth: 180,  // Minimum width
                    maxColumnWidth: 300,   // Maximum width
                    cellAttributes: classObject2
                };
                dynamicJsonListagainself.push(progressObject);
            }
            if(!dynamicJsonListagainself.some(item => item.label === 'Email')){
                const progressObject = {
                    label: 'Email',
                    fieldName: 'Email__c',
                    minColumnWidth: 180,  // Minimum width
                    maxColumnWidth: 300,   // Maximum width
                    cellAttributes: classObject2
                };
                dynamicJsonListagainself.push(progressObject);
            }
            //console.log('before dynamicJsonListagain ', JSON.stringify(dynamicJsonListagain));
            this.fields.forEach(element => {
                //if (this.getKeyByValue(arrayMap4, element.label)) {
                //let progressObjectagain = {};
                if(this.reffromParent){
                    if (element.label != 'S.No.') {
                        const progressObject = {
                            label: this.getKeyByValue(arrayMap5, element.label) ? this.getKeyByValue(arrayMap5, element.label) : element.label,
                            fieldName: element.fieldName && element.fieldName.includes('__c') ? element.fieldName : this.getKeyByValue(arrayMap2, element.label),
                            minColumnWidth: 180,  // Minimum width
                            maxColumnWidth: 300,   // Maximum width
                            cellAttributes: classObject2
                        };
                        dynamicJsonListagain.push(progressObject);
                    if(element.label !== 'Participant Name' && element.label !== 'Participant Email' && element.label !== 'Respondent Name' && element.label !== 'Respondent Email' && element.label !== 'Rater Type'){
                        const progressObject = {
                            label: this.getKeyByValue(arrayMap5, element.label) ? this.getKeyByValue(arrayMap5, element.label) : element.label,
                            fieldName: element.fieldName && element.fieldName.includes('__c') ? element.fieldName : this.getKeyByValue(arrayMap2, element.label),
                            minColumnWidth: 180,  // Minimum width
                            maxColumnWidth: 300,   // Maximum width
                            cellAttributes: classObject2
                        };
                        dynamicJsonListagainself.push(progressObject);
                    }
                    
                    //console.log('external view dynamicJsonListagainself ', JSON.stringify(dynamicJsonListagainself));

                    }
                }
            
                else{
                    if (element.label != 'S.No.') {
                        const progressObject = {
                            label: this.getKeyByValue(arrayMap5, element.label) ? this.getKeyByValue(arrayMap5, element.label) : element.label,
                            fieldName: element.fieldName && element.fieldName.includes('__c') ? element.fieldName : this.getKeyByValue(arrayMap1, element.label),
                            minColumnWidth: 180,  // Minimum width
                            maxColumnWidth: 300,   // Maximum width
                            cellAttributes: classObject2
                        };
                        dynamicJsonListagain.push(progressObject);
                        if(element.label !== 'Participant Name' && element.label !== 'Participant Email' && element.label !== 'Respondent Name' && element.label !== 'Respondent Email' && element.label !== 'Rater Type'){
                            const progressObject = {
                                label: this.getKeyByValue(arrayMap5, element.label) ? this.getKeyByValue(arrayMap5, element.label) : element.label,
                                fieldName: element.fieldName && element.fieldName.includes('__c') ? element.fieldName : this.getKeyByValue(arrayMap2, element.label),
                                minColumnWidth: 180,  // Minimum width
                                maxColumnWidth: 300,   // Maximum width
                                cellAttributes: classObject2
                            };
                            dynamicJsonListagainself.push(progressObject);
                        }
                        
                        //console.log('internal view dynamicJsonListagainself ', JSON.stringify(dynamicJsonListagainself));
                        //console.log('External view dynamicJsonListagain ', JSON.stringify(dynamicJsonListagain));

                    }
                }
            });

            
            //console.log('Final dynamicJsonListagain: ', JSON.stringify(dynamicJsonListagain));

            this.columnvalue = [...dynamicJsonListagain];
            this.columnvalueself =[...dynamicJsonListagainself];
            //console.log('Column Value : ', JSON.stringify(this.columnvalue));
            //console.log('Selected Filter :', JSON.stringify(this.selectedFilters));
            this.selectedFilters = this.selectedFilters.map(item => {
                return {
                    ...item,
                    label: labelUpdates[item.label] || item.label // Replace if exists in mapping
                };
            });
            //console.log('Selected Filter modified:', JSON.stringify(this.selectedFilters));
            if(this.selectedFilters.length > 0){
            let hasDropdownFilter = this.selectedFilters.some(filter => 
                this.dropdownFilterFieldslabels.includes(filter.label)
            );
            //console.log('hasDropdownFilter '+hasDropdownFilter);
            if (hasDropdownFilter) {
            this.fetchDropdownOptions().then(() => {
                //console.log('dropdownOptions ',JSON.stringify(this.dropdownOptions));
                    this.columnvalue = this.columnvalue.map(field => {
                        // Check if the fieldName exists in selectedFilters
                        const filterField = this.selectedFilters.find(filter => filter.label === field.label);
                        const isDropdownField = this.dropdownFilterFields.includes(field.fieldName);
                        let isDateField = field.fieldName === 'Deadline__c';
                            // Add 'filter' attribute
                            return {
                                ...field, // Spread the original properties
                                filter: filterField ? true : false, // Add 'filter' attribute (true or false)
                                dropdownfield: isDropdownField,
                                isDateField: isDateField,
                                dropdownOptions: isDropdownField ? (this.dropdownOptions[field.fieldName] || []) : [] 
                            };
                        });
                        this.selectedFieldsConfiguration = JSON.stringify(this.columnvalue);
            });
            //console.log('Getting data back from parent after submission :', JSON.stringify(this.fields));
            }
            else{
                    this.columnvalue = this.columnvalue.map(field => {
                        // Check if the fieldName exists in selectedFilters
                        const filterField = this.selectedFilters.find(filter => filter.label === field.label);
                        let isDateField = field.fieldName === 'Deadline__c';
                            // Add 'filter' attribute
                            return {
                                ...field, // Spread the original properties
                                isDateField: isDateField,
                                filter: filterField ? true : false, // Add 'filter' attribute (true or false)
                            };
                        });
                        this.selectedFieldsConfiguration = JSON.stringify(this.columnvalue);
                    }
        }
        else{
            this.columnvalue = [...this.columnvalueFromWRF];
            this.selectedFieldsConfiguration = JSON.stringify(this.columnvalue);
        }
        //console.log('Column Value after changes : ', JSON.stringify(this.columnvalue));
           //console.log('this.columnvalueself',JSON.stringify(this.columnvalueself));
           let exportSelfJSON = [];
           this.columnvalueself.forEach(element => {
            const projectobjectExport = {
                label: element.label,
                selected:true,
                fieldName: element.fieldName && element.fieldName.includes('__c') ? element.fieldName : this.getKeyByValue(arrayMap2, element.label),
                readonly: true
            };
            exportSelfJSON.push(projectobjectExport);
        });
        this.selectedFieldsDataSelfExport = exportSelfJSON;
          // console.log('this.selectedFieldsDataSelfExport',JSON.stringify(this.selectedFieldsDataSelfExport));
            if (candidateApiNameList) {
                this.candidateApiNameList = candidateApiNameList;
            }
            if (ratingApiNameList) {
            
                this.ratingApiNameList = ratingApiNameList;
                //console.log('this.ratingApiNameList before rating data',this.ratingApiNameList);
                this.getRatingData();
                this.apilistforserach = ratingApiNameList;
                //console.log('this.apilistforserach: ', this.apilistforserach);
            }
        }
    }

    connectedCallback() {

        let encodedData = [];
        let encodedselectedFilters = [];
        this.reffromParent = this.pageRef.state.c__fromParent;
        this.hidebutton = this.pageRef.state.c__hideButton;
        //console.log('jason Data from parent:', JSON.stringify(this.message));
        // Parse the JSON string into a JavaScript object


        if (this.message) {

            this.parsedData = JSON.parse(JSON.stringify(this.message));
            let dynamicJsonList = [];
            //console.log('parsedData',JSON.stringify(this.parsedData));
            this.parsedData.forEach(element => {
                let progressObject = {};
                if (element.label != 'Category' && element.label != 'Rater String' && element.label != 'S.No.' ) {
                    if (!progressObject.hasOwnProperty("label")) {
                        progressObject["label"] = element.label;
                    }
                    if (!progressObject.hasOwnProperty("selected")) {
                        progressObject["selected"] = true;
                        if(element.hasOwnProperty("selected") && element.selected === false){
                            progressObject["selected"] = false;
                        }
                    }
                    if (!progressObject.hasOwnProperty("fieldName") && element.hasOwnProperty("fieldName") && element.fieldName.includes('__c')) {
                        progressObject["fieldName"] = element.fieldName;
                    }
                    if (!progressObject.hasOwnProperty("readonly")) {
                            progressObject["readonly"] = element.readonly;
                        }

                    //console.log('progressObject ', JSON.stringify(progressObject));
                    dynamicJsonList.push(progressObject);
                    this.selectedFields = [...dynamicJsonList];
                    this.fields = [...dynamicJsonList];
                }
            });
            this.sendDataToParent();
        }
        else {

            this.showLoadingSpinner = true;
            //console.log('reffromParent' + this.reffromParent);
            if (this.reffromParent) {
                //console.log('client side calling');
                //console.log('wrfid from url' + this.pageRef.state.c__wrfId);

                const urlParams = new URLSearchParams(window.location.search);
                let encryptedParam = urlParams.get('c__wrfId');

                // Decode the parameter (if it's URL-encoded)
                if (encryptedParam) {
                    encryptedParam = decodeURIComponent(encryptedParam);
                }
                this.wrfId = encryptedParam;
                if (this.wrfId != null) {
                    this.wrfId = this.wrfId.replace(/ /g, '+'); // Replaces all spaces
                }

                this.fetchData();
            }
            else {
                this.encodedData = this.pageRef.state.c__selectedFields;
                this.encodedselectedFilters = this.pageRef.state.c__selectedFilters;
                this.jobId = this.pageRef.state.c__jobId;
            }
            //console.log('this.encodedData',JSON.stringify(this.encodedData));
            // Extract the 'data' parameter from the URL
            this.hidebutton = this.pageRef.state.c__hideButton;

            if (this.encodedData) {

             //hide selected checkboxes and show table data instead
                this.messageview = true;

                //console.log('Selected Fields Data from parent after submit:', this.encodedData);
                // Decode the URI component and parse the JSON string
                this.selectedFieldsDataRaw = this.encodedData;
                this.selectedFieldsData = JSON.parse(decodeURIComponent(this.encodedData));
                if(this.encodedselectedFilters){
                    this.selectedFilters = JSON.parse(decodeURIComponent(this.encodedselectedFilters));
                }
                //console.log('Selected Fields Data:', JSON.stringify(this.selectedFieldsData));
                this.createJSONForColumns();
                //console.log('this.selectedFilters',JSON.stringify(this.selectedFilters));
            }

            if (this.columnvalue === undefined) {
                this.jobId = this.pageRef.state.c__jobId;
                //console.log('after email sent', this.jobId);
                // Method to navigate to job record after email detection

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.jobId,
                        actionName: 'view',
                    },
                });

            }

        }
    }

    fetchData() {

        decodeurlparamater({ recordId: this.wrfId })
            .then(result => {
                this.wrfId = result;
             })

            .catch(error => {
                this.error = error;
            });

    }

    renderedCallback() {
        if (this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(() => {
        }).catch(error => {
            //console.error("Error in loading the colors", error);
        })
    }

    //This function helps to find value based on key
    getKeyByValue(object, value) {
        return Object.keys(object).find(key => object[key] === value);
    }


    handleFilterChange(event) {
        this.callAgain += 1;
        //console.log('search apilist ', this.apilistforserach);
        const field = event.target.dataset.field;
        let value = null;
        if(event.target.value!=null){
            value = event.target.value.trim();
            if (field === 'Deadline__c'){
                value = new Date(value).toISOString();
            }
        }
        if (value) {
            this.filters[field] = value;
        } else {
            delete this.filters[field]; // Remove filter if input is empty
        }
    }

    handleRefresh() {
        this.candidateFilterValue = '';
        this.filters = {};
        let inputs = this.template.querySelectorAll('lightning-input, lightning-combobox');
    if (inputs) {
        inputs.forEach(input => {
            input.value = '';
        });
    }
        this.getRatingData(this.apilistforserach);
        this.callAgain += 1;
    }

    handleOnselect(event) {
        this.selectedItemValue = event.detail.value;
        this.showExportModal = true;
    }
    //search action
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
        //console.log('search apilist ', this.apilistforserach);
        this.getRatingData(this.apilistforserach);
    }

    handleCheckboxChange(event) {
        const fieldName = event.target.label;
        const isChecked = event.target.checked;
        let alldata = this.fields;
        // Update the `isSelected` property in the fields array
        this.fields = alldata.map(field => {
            if (field.label === fieldName) {
                field.selected = isChecked;
            }
            return field;
        });
        //console.log('list after changes '+JSON.stringify(this.fields));
        //if (!isChecked) {
            this.selectedFields = this.fields.filter(field => field.selected === true);
        //}

        this.sendDataToParent();
    }

    // Dispatch custom event to parent with the input data
    sendDataToParent() {
        const saveEvent = new CustomEvent('save', {
            detail: {
                selectedFields: this.selectedFields,
                allfields: this.fields  // Now both values are inside 'detail'
            }
        });
        this.dispatchEvent(saveEvent);
    }

    get shouldDisplayMessage() {
        return this.messageview && !this.isSubmitUI;
    }

    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.jobId,
                actionName: 'view'
            }
        });
    }

    getreportconfig() {
        getRecentCRF({ jobrecordId: this.jobId })
            .then(result => {
                //console.log('result from client wrf ' + result);
                this.columnvalue = result;
                //console.log('result from client wrf encodedData' + this.columnvalue);


            })
            .catch(error => {
                //console.log('Error is ' + error);
                //console.log('Error is ' + JSON.stringify(error));

            });
    }




    //generate client report view WRF
    sendClientReport(event) {
        //console.log('selectedFieldsConfiguration '+this.selectedFieldsConfiguration);
        sendEmailClientReport({ jobrecordId: this.jobId, selectedfieldsvalue: this.selectedFieldsDataRaw, fieldconfiguration: this.selectedFieldsConfiguration })
            .then(result => {
                const event = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Client Report Generated',
                    variant: 'success'
                });
                this.dispatchEvent(event);
                this.handleEmail(result);
                //this.isSubmitUI = true;

            })
            .catch(error => {
                //console.log('Error is ' + error);
                //console.log('Error is ' + JSON.stringify(error));
                let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                //this.handleClose();
            });

    }

    //send email to client for Report View link
    handleEmail(link) {
        //console.log('jobRecord ' + this.jobRecord?.data?.fields?.Name?.value);
        this.showSpinner = false;
        let contactId = getFieldValue(this.jobRecord.data, CONTACTID_FIELD);
        //let contactId = 'saloni.chhabra@shl.com'
        let recieverName = getFieldValue(this.jobRecord.data, PRIMARY_CONTACT_NAME);
        let jobName = getFieldValue(this.jobRecord.data, JOB_NAME);
        let senderEmail = getFieldValue(this.jobRecord.data, SENDER_EMAIL);
        let projectManagerName = getFieldValue(this.jobRecord.data, PROJECT_MANAGER_NAME);
        let htmlbody = "Dear " + recieverName + ",<br><br>" +
            "Please use <a href=\"" + link + "\">Report Link</a> to view candidates progress for all requests related to " + jobName + ".<br>" +
            "If there is anything else I can help with then please do reach out to me via " + senderEmail + ".<br><br>" +
            "Kind Regards,<br>" + projectManagerName



        //this.cancelPreview();
        //console.log(link);
        //console.log('TO ADDRESS ' + contactId);
        let pageRef =
        {
            type: "standard__quickAction",
            attributes: {
                apiName: "Job__c.Send_Email"
            },
            state: {
                recordId: this.jobId,
                defaultFieldValues: encodeDefaultFieldValues({
                    HtmlBody: htmlbody,
                    Subject: "New Report View Generated for request: " + jobName,
                    ToIds: contactId,
                    BccAddress: '',
                }),
            },
        };
        // Send the email and then navigate to the record page
        this[NavigationMixin.Navigate](pageRef);
    }



    loadData(event) {
        //console.log('Inside Load More Data Client report view non self');
        //event.preventDefault(); // Prevent default action, if any
        this.tableElement = event.target;

        // Target the correct datatable using data-id
        const table = this.template.querySelector('[data-id="table2"]');

        if (event.target && event.target === table) {
            event.target.isLoading = true; // Indicate loading state
            this.loadMoreStatus = 'Loading'; // Update loading status
            //console.log('this.loadMoreStatus ' + this.loadMoreStatus);
    
            // Load more data for this table
            this.getMoreRatingData();
        }

        // Check if event.target is defined and is the datatable
        /*if (event.target && event.target === this.template.querySelector('lightning-datatable')) {
            //console.log('Inside If Load More Data Client report view');
            event.target.isLoading = true; // Indicate loading state
            //console.log('event.target.isLoading '+event.target.isLoading);
            this.loadMoreStatus = 'Loading'; // Update loading status
            console.log('this.loadMoreStatus '+this.loadMoreStatus);

            // Call your function to load more data
            this.getMoreRatingData();
        }*/
    }
    loadDataSelf(event) {
       
        //console.log('Inside Load More Data Client report view self');
        //event.preventDefault(); // Prevent default action, if any
        this.tableElementSelf = event.target;
        // Target the second datatable using data-id
        const table = this.template.querySelector('[data-id="table1"]');
        //console.log('Table 1:', table);

        // Check if event.target is defined and is the datatable
        if (event.target && event.target === table) {

            event.target.isLoadingSelf = true; // Indicate loading state
            this.loadMoreStatusSelf = 'Loading'; // Update loading status
            //console.log('this.loadMoreStatusSelf ' + this.loadMoreStatusSelf);
    
            // Load more data for this table
            this.getMoreRatingDataSelf();
        }
    
    
        
    
        /*if (event.target && event.target === this.template.querySelector('lightning-datatable')) {
            //console.log('Inside If Load More Data Client report view');
            event.target.isLoading = true; // Indicate loading state
            //console.log('event.target.isLoading '+event.target.isLoading);
            this.loadMoreStatusSelf = 'Loading'; // Update loading status
            console.log('this.loadMoreStatusSelf '+this.loadMoreStatusSelf);

            // Call your function to load more data
            this.getMoreRatingData();
        }*/
    }



    getRatingData() {
        //console.log('Filters from LWC '+JSON.stringify(this.filters));
        //console.log('Fields to query '+JSON.stringify(this.ratingApiNameList));
        //console.log('candidate fields to query '+JSON.stringify(this.candidateApiNameList));
        let filtersArray = Object.keys(this.filters).map(key => ({
            key: key,
            value: this.filters[key]
        }));
       filtersArray = filtersArray.map(item => {
            if (this.candidateApiNameList.includes(item.key)) {
                return { ...item, key: `participant__r.${item.key}` };
            }

            return item;
        });
        filtersArray = filtersArray.map(item => {
            // Find the key in arrayMap4 where the value matches item.key
            let mappedKey = Object.keys(arrayMap7).find(mapKey => arrayMap7[mapKey] === item.key);
            return mappedKey ? { ...item, key: mappedKey } : item;
        });

        //console.log('Modified filters '+JSON.stringify(filtersArray));
        getRatingData({ soqlQueryList: this.ratingApiNameList, soqlQueryCandidateList: this.candidateApiNameList, jobId: this.jobId, offSetValue: 0, filters: filtersArray })
            .then(result => {
                this.showLoadingSpinner = false;
                let tempRecords = JSON.parse(JSON.stringify(result.ratingData));
                let tempRecordsCandidate = JSON.parse(JSON.stringify(result.candidateData));
                //console.log('tempRecords: ', JSON.stringify(tempRecords));
                //console.log('tempRecordsCandidate: ', JSON.stringify(tempRecordsCandidate));
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

               
                //console.log('Merged tempRecords: ', JSON.stringify(tempRecords));
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
                //tempRecords.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.selfIndex - b.selfIndex);
                tempRecords.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.Participant__r.Email__c.localeCompare(b.Participant__r.Email__c) || a.selfIndex - b.selfIndex);
                tempRecords = tempRecords.map((row, index) => {
                    let formattedDate = '';
                    if (row.Deadline__c != null) {
                        let dateObj = new Date(row.Deadline__c);
                        formattedDate = new Intl.DateTimeFormat('en-US', {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit',
                            hour: '2-digit',
                            minute: '2-digit',
                            second: '2-digit',
                            hour12: true,
                            timeZone: 'UTC'  // Set the timezone to UTC (GMT)
                        }).format(dateObj);

                        //console.log('-->formattedDate'+formattedDate);
                    }
                    rowColor1 = (row.Rater_Type__c == 'Self') ? 'datatable-green' : (row.Rater_Type__c == 'Manager') ? 'datatable-grey' : (row.Rater_Type__c == 'Colleagues') ? 'datatable-orange' : (row.Rater_Type__c == 'Others') ? 'datatable-blue' : (row.Rater_Type__c == 'Direct Reports') ? 'datatable-yellow' : 'datatable-grey';
                    return {
                        ...row,
                        participantName: (row.Participant__r ? row.Participant__r.Full_Name__c : null),
                        participantEmail: (row.Participant__r ? row.Participant__r.Email__c : null),
                        respondentName: (row.Respondent__r ? row.Respondent__r.Full_Name__c : null),
                        respondentEmail: (row.Respondent__r ? row.Respondent__r.Email__c : null),
                        vadcStatus: row.VADC_Status__c,
                        insightStatus: row.Insights_Status__c,
                        mfsStatus: row.MFS_Status__c,
                        nominationstatus:row.Nomination_Status__c,
                        tcStatus: row.TC_Status__c,
                        overallStatus: row.Overall_Status__c,
                        reportReady: row.Report_Ready__c,
                        reportSent: row.Report_Sent__c,
                        mfsreportSent: row.MFS_Report_Sent__c,
                        tcreportSent: row.TC_Report_Sent__c,
                        reminder: row.Reminder__c,
                        //deadline: row.Deadline__c,
                        deadline: formattedDate,
                        comments: row.Comments__c,
                        tcEmail: row.File_Name__c,
                        singleUseLink: row.Single_Use_Link__c,
                        accountColor: rowColor1,
                        serialNumber: index + 1,
                    };
                })

            
            //data setup for self table in case of MFS or MFS+TC
            let tempRecordsself = tempRecords;
            tempRecordsself = tempRecordsself.map(item => {
                let indexself = tempRecordsCandidate.findIndex(attr => item.Respondent__r.Id === attr.Id);

                let additionalData = tempRecordsCandidate[indexself];
                if (additionalData) {
                    finalData = { ...additionalData, ...item };
                    item = finalData;
                }
                return item;
            });
            tempRecordsself = tempRecordsself.map((row, indexself) => {
                selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : 1;
                return {
                    ...row,
                    selfIndex: selfIndexCounter,
                };
            });
            tempRecordsself.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) ||  a.selfIndex - b.selfIndex);
                
            tempRecordsself = tempRecordsself
            .filter(row => row.Rater_Type__c === 'Self')
            .map((row, indexself) => {
                let formattedDate = '';
                if (row.Deadline__c != null) {
                    let dateObj = new Date(row.Deadline__c);
                    formattedDate = new Intl.DateTimeFormat('en-US', {
                        year: 'numeric',
                        month: '2-digit',
                        day: '2-digit',
                        hour: '2-digit',
                        minute: '2-digit',
                        second: '2-digit',
                        hour12: true,
                        timeZone: 'UTC'  // Set the timezone to UTC (GMT)
                    }).format(dateObj);

                    //console.log('-->formattedDate'+formattedDate);
                }
                rowColor1 = (row.Rater_Type__c == 'Self') ? 'datatable-green' : 'datatable-grey'; ;
                return {
                    ...row,
                    participantName: (row.Participant__r ? row.Participant__r.Full_Name__c : null),
                    participantEmail: (row.Participant__r ? row.Participant__r.Email__c : null),
                    respondentName: (row.Respondent__r ? row.Respondent__r.Full_Name__c : null),
                    respondentEmail: (row.Respondent__r ? row.Respondent__r.Email__c : null),
                    vadcStatus: row.VADC_Status__c,
                    insightStatus: row.Insights_Status__c,
                    mfsStatus: row.MFS_Status__c,
                    tcStatus: row.TC_Status__c,
                    nominationstatus: row.Nomination_Status__c,
                    overallStatus: row.Overall_Status__c,
                    reportReady: row.Report_Ready__c,
                    reportSent: row.Report_Sent__c,
                    mfsreportSent: row.MFS_Report_Sent__c,
                    tcreportSent: row.TC_Report_Sent__c,
                    reminder: row.Reminder__c,
                    //deadline: row.Deadline__c,
                    deadline: formattedDate,
                    comments: row.Comments__c,
                    tcEmail: row.File_Name__c,
                    singleUseLink: row.Single_Use_Link__c,
                    accountColor: rowColor1,
                    serialNumber: indexself + 1,
                    };
                })

                this.jsonData = tempRecords;
                //console.log('this.jsonData: ', JSON.stringify(this.jsonData));
                //console.log('datacount: ', this.jsonData.length);
                this.loadMoreStatus = '';
                this.dataCount = this.jsonData.length;
                if (this.tableElement) {
                    this.tableElement.isLoading = false;
                    this.tableElement.enableInfiniteLoading = true;
                }
                if (!this.jsonDataSelfBackup) {
                    this.jsonDataSelfBackup = [...tempRecordsself];  // Store the original Self Report data
                }
                this.jsonDataSelf = [...this.jsonDataSelfBackup];

                    //console.log('this.jsonDataSelf rating data: ', JSON.stringify(this.jsonDataSelf));
                    //console.log('this.jsonData: ', JSON.stringify(this.jsonData));
                    //console.log('datacount: ', this.jsonData.length);
                    this.loadMoreStatus = '';
                    this.loadMoreStatusSelf = '';
                    this.dataCount = this.jsonData.length;
                    this.dataCountself = this.jsonDataSelf.length;
                    //console.log('this.dataCountself rating date', this.dataCountself);
                    if (this.tableElement) {
                        this.tableElement.isLoading = false;
                        this.tableElement.enableInfiniteLoading = true;
                        //this.tableElement.enableInfiniteLoadingSelf = true;
                    }
                    //console.log('abc outside', tempRecordsself.length);

                    if (this.tableElementSelf) {
                        //console.log('abc', tempRecordsself.length);
                        this.tableElementSelf.isLoadingSelf = false;
                        this.tableElementSelf.enableInfiniteLoading = true;
                        //this.loadMoreStatusSelf = 'No more data to load';
                        //this.tableElement.enableInfiniteLoadingSelf = true;
                    }
                const rowHeight = 50; // Height per row in pixels (adjust as needed)
                const maxHeight = 600; // Maximum height of the datatable
               // console.log('this.tableElementSelf.enableInfiniteLoading', this.tableElementSelf.enableInfiniteLoading);
                // If there are more rows, increase the height dynamically
                const height = this.jsonData.length * rowHeight;
                const heightself = this.jsonDataSelf.length * rowHeight;
                this.dynamicHeight = height > maxHeight ? `${maxHeight}px` : `${height}px`;
                //this.dynamicHeightSelf = heightself > maxHeight ? `${maxHeight}px` : `${heightself}px`;
                this.dynamicHeightSelf = `${Math.min(heightself, maxHeight)}px`;

                })
                .catch(error => {
                    console.log('error ====> ', JSON.stringify(error));
                });
    }


    //load more rating data
    getMoreRatingData() {
        //this.tableElement.isLoading = true;
        let filtersArray = Object.keys(this.filters).map(key => ({
            key: key,
            value: this.filters[key]
        }));
       filtersArray = filtersArray.map(item => {
            if (this.candidateApiNameList.includes(item.key)) {
                return { ...item, key: `participant__r.${item.key}` };
            }
            return item;
        });
        filtersArray = filtersArray.map(item => {
            // Find the key in arrayMap4 where the value matches item.key
            let mappedKey = Object.keys(arrayMap7).find(mapKey => arrayMap7[mapKey] === item.key);
            return mappedKey ? { ...item, key: mappedKey } : item;
        });
        //console.log('Modified filters '+JSON.stringify(filtersArray));
        
        //console.log('---this.datacount load moredata'+this.dataCount);
        getRatingData({ soqlQueryList: this.ratingApiNameList, soqlQueryCandidateList: this.candidateApiNameList, jobId: this.jobId, offSetValue: this.dataCount, filters: filtersArray })
            .then(result => {
                //console.log('result ====> ' + JSON.stringify(result));
                let tempRecords = JSON.parse(JSON.stringify(result.ratingData));
                let tempRecordsCandidate = JSON.parse(JSON.stringify(result.candidateData));
                //console.log('tempRecords: ', JSON.stringify(tempRecords));
                //console.log('tempRecordsCandidate: ', JSON.stringify(tempRecordsCandidate));
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

                //tempRecords.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.selfIndex - b.selfIndex);
                tempRecords.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.Participant__r.Email__c.localeCompare(b.Participant__r.Email__c) || a.selfIndex - b.selfIndex);
                let rowColor1;
                let serialNumberCount;
                let serialNumber1;

                serialNumberCount = this.dataCount;
                tempRecords = tempRecords.map((row, index) => {
                    let formattedDate = '';
                    if (row.Deadline__c != null) {
                        let dateObj = new Date(row.Deadline__c);
                        formattedDate = new Intl.DateTimeFormat('en-US', {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit',
                            hour: '2-digit',
                            minute: '2-digit',
                            second: '2-digit',
                            hour12: true,
                            timeZone: 'UTC'  // Set the timezone to UTC (GMT)
                        }).format(dateObj);

                        //console.log('-->formattedDate' + formattedDate);
                    }
                    if (index == 0) {
                        serialNumber1 = serialNumberCount + 1;
                    }
                    rowColor1 = (row.Rater_Type__c == 'Self') ? 'datatable-green' : (row.Rater_Type__c == 'Manager') ? 'datatable-grey' : (row.Rater_Type__c == 'Colleagues') ? 'datatable-orange' : (row.Rater_Type__c == 'Others') ? 'datatable-blue' : (row.Rater_Type__c == 'Direct Reports') ? 'datatable-yellow' : 'datatable-grey';
                    return {
                        ...row,
                        participantName: (row.Participant__r ? row.Participant__r.Full_Name__c : null),
                        participantEmail: (row.Participant__r ? row.Participant__r.Email__c : null),
                        respondentName: (row.Respondent__r ? row.Respondent__r.Full_Name__c : null),
                        respondentEmail: (row.Respondent__r ? row.Respondent__r.Email__c : null),
                        vadcStatus: row.VADC_Status__c,
                        insightStatus: row.Insights_Status__c,
                        mfsStatus: row.MFS_Status__c,
                        nominationstatus: row.Nomination_Status__c,
                        tcStatus: row.TC_Status__c,
                        overallStatus: row.Overall_Status__c,
                        reportReady: row.Report_Ready__c,
                        reportSent: row.Report_Sent__c,
                        mfsreportSent: row.MFS_Report_Sent__c,
                        tcreportSent: row.TC_Report_Sent__c,
                        reminder: row.Reminder__c,
                        //deadline: row.Deadline__c,
                        deadline: formattedDate,
                        comments: row.Comments__c,
                        tcEmail: row.File_Name__c,
                        singleUseLink: row.Single_Use_Link__c,
                        accountColor: rowColor1,
                        serialNumber: serialNumber1 + index,
                    };
                })

                //data setup for self table in case of MFS or MFS+TC
                let tempRecordsself = tempRecords;
                tempRecordsself = tempRecordsself.map(item => {
                    let indexself = tempRecordsCandidate.findIndex(attr => item.Respondent__r.Id === attr.Id);

                    let additionalData = tempRecordsCandidate[indexself];
                    if (additionalData) {
                        finalData = { ...additionalData, ...item };
                        item = finalData;
                    }
                    return item;
                });
                tempRecordsself = tempRecordsself.map((row, indexself) => {
                    selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : 1;
                    return {
                        ...row,
                        selfIndexself: selfIndexCounter,
                    };
                });
                tempRecordsself.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) ||  a.selfIndexself - b.selfIndexself);
                tempRecordsself = tempRecordsself.filter(row => row.Rater_Type__c === 'Self');
                let selfRecordCount = this.dataCountself;
                //console.log('selfRecordCount ', selfRecordCount);
                if(selfRecordCount !== 0){
                let serialNumberSelf1;
                tempRecordsself = tempRecordsself.map((row, indexself) => {
                    let formattedDate = '';
                    if (row.Deadline__c != null) {
                        let dateObj = new Date(row.Deadline__c);
                        formattedDate = new Intl.DateTimeFormat('en-US', {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit',
                            hour: '2-digit',
                            minute: '2-digit',
                            second: '2-digit',
                            hour12: true,
                            timeZone: 'UTC'  // Set the timezone to UTC (GMT)
                        }).format(dateObj);

                        //console.log('-->formattedDate'+formattedDate);
                    }
                    rowColor1 = (row.Rater_Type__c == 'Self') ? 'datatable-green' : 'datatable-grey'; ;
                    if (indexself == 0) {
                        serialNumberSelf1 = selfRecordCount+1;
                        //console.log('serialNumberSelf1 ', serialNumberSelf1);
                    }
                    return {
                        ...row,
                        participantName: (row.Participant__r ? row.Participant__r.Full_Name__c : null),
                        respondentName: (row.Respondent__r ? row.Respondent__r.Full_Name__c : null),
                        respondentEmail: (row.Respondent__r ? row.Respondent__r.Email__c : null),
                        vadcStatus: row.VADC_Status__c,
                        insightStatus: row.Insights_Status__c,
                        mfsStatus: row.MFS_Status__c,
                        tcStatus: row.TC_Status__c,
                        nominationstatus: row.Nomination_Status__c,
                        overallStatus: row.Overall_Status__c,
                        reportReady: row.Report_Ready__c,
                        reportSent: row.Report_Sent__c,
                        mfsreportSent: row.MFS_Report_Sent__c,
                        tcreportSent: row.TC_Report_Sent__c,
                        reminder: row.Reminder__c,
                        //deadline: row.Deadline__c,
                        deadline: formattedDate,
                        comments: row.Comments__c,
                        tcEmail: row.File_Name__c,
                        singleUseLink: row.Single_Use_Link__c,
                        accountColor: rowColor1,
                        serialNumber: serialNumberSelf1 + indexself,
                    };
                })
            }   
                this.jsonData = this.jsonData.concat(tempRecords);
                //if(tempRecordsself.length >0){
                    //this.jsonDataSelf = this.jsonDataSelf.concat(tempRecordsself);
                    //this.dataCountself = this.jsonDataSelf.length;
               // }
                this.dataCount = this.jsonData.length;
                this.loadMoreStatus = '';
                //this.loadMoreStatusSelf = '';
                if (tempRecords.length>200 && tempRecords.length >0) {
                    this.tableElement.isLoading = true;
                }

               /* if (tempRecordsself.length>200 && tempRecordsself.length >0) {
                    this.tableElementSelf.isLoadingSelf = true;
                }*/
                
                /*console.log('this.dataCount loadmore',this.dataCount);
                console.log('this.loadMoreStatus loadmore',this.loadMoreStatus);
                console.log('this.loadMoreStatusSelf loadmore',this.loadMoreStatusSelf);
                console.log('this.loadMoreStatusSelf length',this.loadMoreStatusSelf.length);*/
                if (tempRecords.length < 200 ) {
                    this.tableElement.enableInfiniteLoading = false;
                    this.loadMoreStatus = 'No more data to load';
                }
               /* if(tempRecordsself.length < 200){
                    
                    this.tableElementSelf.enableInfiniteLoading = false;
                    this.loadMoreStatusSelf = 'No more data to load';

                }
                console.log('this.loadMoreStatusSelf loadmore after',this.loadMoreStatusSelf);*/

                if (this.tableElement) {
                    this.tableElement.isLoading = false;
                }

                /*if (this.tableElementSelf) {
                    this.tableElementSelf.isLoadingSelf = false;
                }*/
                //console.log('this.tableElement.enableInfiniteLoading', this.tableElement.enableInfiniteLoading);
                //console.log('this.tableElement.isLoading', this.tableElement.isLoading);
                const rowHeight = 50; // Height per row in pixels (adjust as needed)
                const maxHeight = 600; // Maximum height of the datatable

                // If there are more rows, increase the height dynamically
                const height = this.jsonData.length * rowHeight;
                /*if(tempRecordsself.length >0){
                const heightself = this.jsonDataSelf.length * rowHeight;
                //console.log('this.jsonDataSelf.length',this.jsonDataSelf.length);
                //console.log('this.heightself',heightself);
                this.dynamicHeightSelf = heightself > maxHeight ? `${maxHeight}px` : `${heightself}px`;
                }*/
                this.dynamicHeight = height > maxHeight ? `${maxHeight}px` : `${height}px`;
                //this.dynamicHeightSelf = heightself > maxHeight ? `${maxHeight}px` : `${heightself}px`;
                //console.log('this.dynamicHeightSelf',this.dynamicHeightSelf);

                })
            .catch(error => {
                //console.log('error ====> ', error);
            });
    }
    getMoreRatingDataSelf() {
        getRatingData({ soqlQueryList: this.ratingApiNameList, soqlQueryCandidateList: this.candidateApiNameList, jobId: this.jobId, offSetValue: this.dataCount})
            .then(result => {
                //console.log('result ====> ' + JSON.stringify(result));
                let tempRecords = JSON.parse(JSON.stringify(result.ratingData));
                let tempRecordsCandidate = JSON.parse(JSON.stringify(result.candidateData));
                //console.log('tempRecords: ', JSON.stringify(tempRecords));
                //console.log('tempRecordsCandidate: ', JSON.stringify(tempRecordsCandidate));
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

                //tempRecords.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.selfIndex - b.selfIndex);
                tempRecords.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.Participant__r.Email__c.localeCompare(b.Participant__r.Email__c) || a.selfIndex - b.selfIndex);
                let rowColor1;
                let serialNumberCount;
                let serialNumber1;

                serialNumberCount = this.dataCount;
                tempRecords = tempRecords.map((row, index) => {
                    let formattedDate = '';
                    if (row.Deadline__c != null) {
                        let dateObj = new Date(row.Deadline__c);
                        formattedDate = new Intl.DateTimeFormat('en-US', {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit',
                            hour: '2-digit',
                            minute: '2-digit',
                            second: '2-digit',
                            hour12: true,
                            timeZone: 'UTC'  // Set the timezone to UTC (GMT)
                        }).format(dateObj);

                        //console.log('-->formattedDate' + formattedDate);
                    }
                    if (index == 0) {
                        serialNumber1 = serialNumberCount + 1;
                    }
                    rowColor1 = (row.Rater_Type__c == 'Self') ? 'datatable-green' : (row.Rater_Type__c == 'Manager') ? 'datatable-grey' : (row.Rater_Type__c == 'Colleagues') ? 'datatable-orange' : (row.Rater_Type__c == 'Others') ? 'datatable-blue' : (row.Rater_Type__c == 'Direct Reports') ? 'datatable-yellow' : 'datatable-grey';
                    return {
                        ...row,
                        participantName: (row.Participant__r ? row.Participant__r.Full_Name__c : null),
                        participantEmail: (row.Participant__r ? row.Participant__r.Email__c : null),
                        respondentName: (row.Respondent__r ? row.Respondent__r.Full_Name__c : null),
                        respondentEmail: (row.Respondent__r ? row.Respondent__r.Email__c : null),
                        vadcStatus: row.VADC_Status__c,
                        insightStatus: row.Insights_Status__c,
                        mfsStatus: row.MFS_Status__c,
                        nominationstatus: row.Nomination_Status__c,
                        tcStatus: row.TC_Status__c,
                        overallStatus: row.Overall_Status__c,
                        reportReady: row.Report_Ready__c,
                        reportSent: row.Report_Sent__c,
                        mfsreportSent: row.MFS_Report_Sent__c,
                        tcreportSent: row.TC_Report_Sent__c,
                        reminder: row.Reminder__c,
                        //deadline: row.Deadline__c,
                        deadline: formattedDate,
                        comments: row.Comments__c,
                        tcEmail: row.File_Name__c,
                        singleUseLink: row.Single_Use_Link__c,
                        accountColor: rowColor1,
                        serialNumber: serialNumber1 + index,
                    };
                })

                //data setup for self table in case of MFS or MFS+TC
                let tempRecordsself = tempRecords;
                tempRecordsself = tempRecordsself.map(item => {
                    let indexself = tempRecordsCandidate.findIndex(attr => item.Respondent__r.Id === attr.Id);

                    let additionalData = tempRecordsCandidate[indexself];
                    if (additionalData) {
                        finalData = { ...additionalData, ...item };
                        item = finalData;
                    }
                    return item;
                });
                tempRecordsself = tempRecordsself.map((row, indexself) => {
                    selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : 1;
                    return {
                        ...row,
                        selfIndexself: selfIndexCounter,
                    };
                });
                tempRecordsself.sort((a, b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) ||  a.selfIndexself - b.selfIndexself);
                tempRecordsself = tempRecordsself.filter(row => row.Rater_Type__c === 'Self');
                let selfRecordCount = this.dataCountself;
                //console.log('selfRecordCount ', selfRecordCount);
                if(selfRecordCount !== 0){
                let serialNumberSelf1;
                tempRecordsself = tempRecordsself.map((row, indexself) => {
                    let formattedDate = '';
                    if (row.Deadline__c != null) {
                        let dateObj = new Date(row.Deadline__c);
                        formattedDate = new Intl.DateTimeFormat('en-US', {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit',
                            hour: '2-digit',
                            minute: '2-digit',
                            second: '2-digit',
                            hour12: true,
                            timeZone: 'UTC'  // Set the timezone to UTC (GMT)
                        }).format(dateObj);

                        //console.log('-->formattedDate'+formattedDate);
                    }
                    rowColor1 = (row.Rater_Type__c == 'Self') ? 'datatable-green' : 'datatable-grey'; ;
                    if (indexself == 0) {
                        serialNumberSelf1 = selfRecordCount+1;
                        //console.log('serialNumberSelf1 ', serialNumberSelf1);
                    }
                    return {
                        ...row,
                        participantName: (row.Participant__r ? row.Participant__r.Full_Name__c : null),
                        respondentName: (row.Respondent__r ? row.Respondent__r.Full_Name__c : null),
                        respondentEmail: (row.Respondent__r ? row.Respondent__r.Email__c : null),
                        vadcStatus: row.VADC_Status__c,
                        insightStatus: row.Insights_Status__c,
                        mfsStatus: row.MFS_Status__c,
                        tcStatus: row.TC_Status__c,
                        nominationstatus: row.Nomination_Status__c,
                        overallStatus: row.Overall_Status__c,
                        reportReady: row.Report_Ready__c,
                        reportSent: row.Report_Sent__c,
                        mfsreportSent: row.MFS_Report_Sent__c,
                        tcreportSent: row.TC_Report_Sent__c,
                        reminder: row.Reminder__c,
                        //deadline: row.Deadline__c,
                        deadline: formattedDate,
                        comments: row.Comments__c,
                        tcEmail: row.File_Name__c,
                        singleUseLink: row.Single_Use_Link__c,
                        accountColor: rowColor1,
                        serialNumber: serialNumberSelf1 + indexself,
                    };
                })
            }   
                //this.jsonData = this.jsonData.concat(tempRecords);
                //if(tempRecordsself.length >0){
                    this.jsonDataSelf = this.jsonDataSelf.concat(tempRecordsself);
                    this.dataCountself = this.jsonDataSelf.length;
               // }
                //this.dataCount = this.jsonData.length;
                this.loadMoreStatus = '';
                this.loadMoreStatusSelf = '';
                if (tempRecords.length>200 && tempRecords.length >0) {
                    this.tableElement.isLoading = true;
                }

                if (tempRecordsself.length>200 && tempRecordsself.length >0) {
                    this.tableElementSelf.isLoadingSelf = true;
                }
                
                /*console.log('this.dataCount loadmore',this.dataCount);
                console.log('this.loadMoreStatus loadmore',this.loadMoreStatus);
                console.log('this.loadMoreStatusSelf loadmore',this.loadMoreStatusSelf);
                console.log('this.loadMoreStatusSelf length',this.loadMoreStatusSelf.length);*/
               /* if (tempRecords.length < 200 ) {
                    this.tableElement.enableInfiniteLoading = false;
                    this.loadMoreStatus = 'No more data to load';
                }*/
                if(tempRecordsself.length < 200){
                    
                    this.tableElementSelf.enableInfiniteLoading = false;
                    this.loadMoreStatusSelf = 'No more data to load';

                }
                //console.log('this.loadMoreStatusSelf loadmore after',this.loadMoreStatusSelf);

                /*if (this.tableElement) {
                    this.tableElement.isLoading = false;
                }*/

                if (this.tableElementSelf) {
                    this.tableElementSelf.isLoadingSelf = false;
                }
                //console.log('this.tableElement.enableInfiniteLoading', this.tableElement.enableInfiniteLoading);
                //console.log('this.tableElement.isLoading', this.tableElement.isLoading);
                const rowHeight = 50; // Height per row in pixels (adjust as needed)
                const maxHeight = 600; // Maximum height of the datatable

                // If there are more rows, increase the height dynamically
                const height = this.jsonData.length * rowHeight;
                if(tempRecordsself.length >0){
                const heightself = this.jsonDataSelf.length * rowHeight;
                //console.log('this.jsonDataSelf.length',this.jsonDataSelf.length);
                //console.log('this.heightself',heightself);
                this.dynamicHeightSelf = heightself > maxHeight ? `${maxHeight}px` : `${heightself}px`;
                }
                this.dynamicHeight = height > maxHeight ? `${maxHeight}px` : `${height}px`;
                //this.dynamicHeightSelf = heightself > maxHeight ? `${maxHeight}px` : `${heightself}px`;
                //console.log('this.dynamicHeightSelf',this.dynamicHeightSelf);

                })
            .catch(error => {
                //console.log('error ====> ', error);
            });
    }

    exportReport() {
        //console.log('exportReport() called');
        this.exportReportFlag = true;
    }

    exportReportSelf() {
        
        this.exportReportFlagSelf = true;
        //console.log('self export', this.exportReportFlagSelf );
    }

    handleVisibility(event){
        if (event.detail.status == 'Success') {
            this.isAuthenticationUI = false;
        }
    }

    

}