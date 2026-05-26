import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRatingData from '@salesforce/apex/CandidateRatingManager.getRatingData';
import COLORS from '@salesforce/resourceUrl/Color';
import {loadStyle} from 'lightning/platformResourceLoader'

const columns = [
    {
        label: 'S.No.', fieldName: 'serialNumber', type: 'number', fixedWidth : 75,
        cellAttributes: {
            alignment: 'center',
            class: {fieldName:'accountColor'}
        }
    },
    {
        label: 'Candidate Id', fieldName: 'candidateRecordId', type: 'url',
        typeAttributes: { label: { fieldName: 'candidateRecord' }, target: '_blank' },
        cellAttributes: {
            class: {fieldName:'accountColor'}
        }
    },
    {
        label: 'Rating Number', fieldName: 'ratingRecordId', type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' },
        cellAttributes: {
            class: {fieldName:'accountColor'}
        }
    },
    { label: 'Participant Name', fieldName: 'participantName',
        cellAttributes: {
            class: {fieldName:'accountColor'}
        }
    },
    { label: 'Respondent Name', fieldName: 'respondentName',
        cellAttributes: {
            class: {fieldName:'accountColor'}
        }
    },
    { label: 'Respondent Email', fieldName: 'respondentEmail',
        cellAttributes: {
            class: {fieldName:'accountColor'}
        }
    },
    { label: 'Rater Type', fieldName: 'Rater_Type__c',
        cellAttributes: {
            class: {fieldName:'accountColor'}
        }
    },
    { label: 'Report Status', fieldName: 'reportStatus',
        cellAttributes: {
            class: {fieldName:'accountColor'}
        }
    },
    
];

export default class CandidateRatingTable extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track loadMoreStatus;
    data = [];
    dataCount;
    jobName;
    columns = columns;
    tableElement;
    isCssLoaded = false
    @track showLoadingSpinner;
    varSerialNumber;
    @track captureLastColor;
    
    candidateFilterValue;

    connectedCallback(){
        this.showLoadingSpinner = true;
        this.getRatingData();
    }

    renderedCallback(){ 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(()=>{
        }).catch(error=>{ 
            console.error("Error in loading the colors",error);
        })
    }

    loadData(event) {
        event.preventDefault();
        console.log('Inside Load More Data');
        if (event.target) {
            console.log('Inside If Load More Data');
            event.target.isLoading = true;
        }
        this.tableElement = event.target;
        this.loadMoreStatus = 'Loading';
        this.getMoreRatingData();
    }

    handleCandidateFilterValue(event){
        this.candidateFilterValue = event.detail.value;
        this.handleSearchAction();
    }

    handleEnter(event) {
        if(event.keyCode === 13){
            this.handleSearchAction();
        }
    }

    handleSearchAction(event) {
        this.getRatingData();
    }

    getMoreRatingData() {
        this.tableElement.isLoading = true;
        getRatingData({ jobId: this.recordId, offSetValue: this.dataCount, filterValue: this.candidateFilterValue })
            .then(result => {
                console.log('result ====> ' + JSON.stringify(result));
                var tempData = [];
                tempData = result;
                let tempRecords = JSON.parse(JSON.stringify(result));
                let selfIndexCounter;
                
                tempRecords = tempRecords.map((row,index) => {
                    selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : (row.Rater_Type__c == 'Manager') ? 1 : (row.Rater_Type__c == 'Colleagues') ? 2 : (row.Rater_Type__c == 'Others') ? 3 : (row.Rater_Type__c == 'Direct Reports') ? 4 : 5;
                    return{
                        ...row,
                        selfIndex: selfIndexCounter,
                    };
                });

                tempRecords.sort((a,b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.selfIndex - b.selfIndex);

                let rowColor1;
                let serialNumberCount;
                let serialNumber1;

                serialNumberCount = this.dataCount;
                tempRecords = tempRecords.map((row, index) => {
                    if(index == 0){
                        serialNumber1 = serialNumberCount + 1;
                    }
                    rowColor1 = (row.Rater_Type__c == 'Self') ? 'datatable-green' : (row.Rater_Type__c == 'Manager') ? 'datatable-grey' : (row.Rater_Type__c == 'Colleagues') ? 'datatable-orange' : (row.Rater_Type__c == 'Others') ? 'datatable-blue' : (row.Rater_Type__c == 'Direct Reports') ? 'datatable-yellow' : 'datatable-grey';
                    return {
                        ...row,
                        ratingRecordId: (row ? ('/lightning/r/Bureau_Rating__c/' + row.Id+'/view') : null),
                        candidateRecordId: (row ? ('/lightning/r/Bureau_Candidate__c/' + row.Respondent__c+'/view') : null),
                        candidateRecord: (row.Respondent__r ? row.Respondent__r.Name : null),
                        participantName: (row.Participant__r ? row.Participant__r.Full_Name__c : null),
                        respondentName: (row.Respondent__r ? row.Respondent__r.Full_Name__c : null),
                        respondentEmail: (row.Respondent__r ? row.Respondent__r.Email__c : null),
                        reportStatus: (row.Participant__r ? row.Participant__r.Reports_Status__c : null),
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
                console.log('error ====> ', error);
                });
    }

    getRatingData() {
        getRatingData({ jobId: this.recordId, offSetValue: 0, filterValue: this.candidateFilterValue })
            .then(result => {
                this.showLoadingSpinner = false;
                var tempData = [];
                tempData = result;
                console.log('result: ', JSON.stringify(result));
                let tempRecords = JSON.parse(JSON.stringify(result));
                console.log('tempRecords: ', tempRecords);
                let selfIndexCounter;
                tempRecords = tempRecords.map((row,index) => {
                    selfIndexCounter = (row.Rater_Type__c == 'Self') ? 0 : (row.Rater_Type__c == 'Manager') ? 1 : (row.Rater_Type__c == 'Colleagues') ? 2 : (row.Rater_Type__c == 'Others') ? 3 : (row.Rater_Type__c == 'Direct Reports') ? 4 : 5;
                    return{
                        ...row,
                        selfIndex: selfIndexCounter,
                    };
                });
                let rowColor1;
                let counterFlag1 = true;
                let counter1;
                let colorList1 = ['datatable-orange', 'datatable-grey'];
                
                tempRecords.sort((a,b) => a.Participant__r.Full_Name__c.localeCompare(b.Participant__r.Full_Name__c) || a.selfIndex - b.selfIndex);

                tempRecords = tempRecords.map((row,index) => {
                    rowColor1 = (row.Rater_Type__c == 'Self') ? 'datatable-green' : (row.Rater_Type__c == 'Manager') ? 'datatable-grey' : (row.Rater_Type__c == 'Colleagues') ? 'datatable-orange' : (row.Rater_Type__c == 'Others') ? 'datatable-blue' : (row.Rater_Type__c == 'Direct Reports') ? 'datatable-yellow' : 'datatable-grey';

                    return {
                        ...row,
                        ratingRecordId: (row ? ('/lightning/r/Bureau_Rating__c/' + row.Id+'/view') : null),
                        candidateRecordId: (row ? ('/lightning/r/Bureau_Candidate__c/' + row.Respondent__c+'/view') : null),
                        candidateRecord: (row.Respondent__r ? row.Respondent__r.Name : null),
                        participantName: (row.Participant__r ? row.Participant__r.Full_Name__c : null),
                        respondentName: (row.Respondent__r ? row.Respondent__r.Full_Name__c : null),
                        respondentEmail: (row.Respondent__r ? row.Respondent__r.Email__c : null),
                        reportStatus: (row.Participant__r ? row.Participant__r.Reports_Status__c : null),
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
                console.log('error ====> ', error);
            });
    }

    handleRefresh(){
        this.candidateFilterValue='';
        this.getRatingData();
    }
}