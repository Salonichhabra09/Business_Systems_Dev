import { LightningElement, api, wire } from 'lwc';
import getDifferentRegionJobs from '@salesforce/apex/JobTriggerManager_2.getDifferentRegionJobs';
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import COMMENCED_RECORD_TYPE_ID from '@salesforce/label/c.CommencedRecordTypeId';

const columns = [
  { label: 'Job Number', fieldName: 'Name' },
  { label: 'Account', fieldName: 'AccountName' },
  { label: 'Project Manager', fieldName: 'ProjectManager' },
  { label: 'Total Time Spent (In Minutes)', fieldName: 'Total_Time_Spent__c' },
  { label: 'Overall Time Spent (In Minutes)', fieldName: 'Total_Time_Spent_All_Jobs__c' },
];

export default class DifferentRegionChildJobs extends NavigationMixin(LightningElement) {
  @api recordId;
  columns = columns;
  jobRecords = [];
  rowOffset = 0;
  cardHeaderName = '';
  showTable = false;
  showSpinner = false;
  buttonName;

  connectedCallback() {
    this.handleRefreshList();
    window.addEventListener('onnavigate', this.handleRefreshList);
  }

  handleRefreshList() {
    getDifferentRegionJobs({ parentJobId: this.recordId })
      .then((data) => {
        this.jobRecords = JSON.parse(JSON.stringify(data));
        if (this.jobRecords != '') {
          this.showSpinner = true;
          if (this.jobRecords[0].Job_Region__c == 'China') {
            this.buttonName = 'New China Job';
            this.cardHeaderName = 'China - Child Jobs ' + '(' + this.jobRecords.length + ')';
          }
          else {
            this.buttonName = 'New Non China Job';
            this.cardHeaderName = 'Non-China - Child Jobs ' + '(' + this.jobRecords.length + ')';
          }
          for (var i = 0; i < this.jobRecords.length; i++) {
            this.jobRecords[i]['AccountName'] = this.jobRecords[i].Account__r.Name;
            this.jobRecords[i]['ProjectManager'] = this.jobRecords[i].Project_Manager__r.Name;
          }
          this.showTable = true;
          this.showSpinner = false;
        }
      })
      .catch((error) => {
        this.error = error;
      });
  }

  /* SSE-28013: Added default field mapping for child job creation (by Aashi) */
  handleNew() {
    const today = new Date().toISOString().split('T')[0];
    const defaultValues = encodeDefaultFieldValues({
      Job_Region__c: this.jobRecords[0].Job_Region__c,
      Parent_Job__c: this.jobRecords[0].Parent_Job__c,
      // SSE-28013: Start
      MS_Line_of_Business__c: this.jobRecords[0].MS_Line_of_Business__c,
      Project_Manager__c: this.jobRecords[0].Project_Manager__c,
      JobStatus__c: 'Booked',
      Opportunity__c: this.jobRecords[0].Opportunity__c,
      Client_Domain__c: this.jobRecords[0].Client_Domain__c,
      Sender_Email__c: this.jobRecords[0].Sender_Email__c,
      Start_Date__c: today,
      End_Date__c: this.jobRecords[0].Contract_End_Date__c,
      Ext_Template_Folder__c: this.jobRecords[0].Ext_Template_Folder__c,
      Generic_Date_Field_MS_One__c: this.jobRecords[0].Generic_Date_Field_MS_One__c,
      // SSE-28013: End
    });

    console.log(defaultValues);

    // SSE-28013: Set Record type to Commenced
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Job__c",
        actionName: "new",
      },
      state: {
        defaultFieldValues: defaultValues,
        recordTypeId: COMMENCED_RECORD_TYPE_ID,
        useRecordTypeCheck: 'true',
        navigationLocation: 'RELATED_LIST'
      },

    });
    /*.then(() => {
      this.handleRefreshList();
   }) */


  }

}