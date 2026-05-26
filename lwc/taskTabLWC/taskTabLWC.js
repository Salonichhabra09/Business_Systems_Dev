import { LightningElement,api,wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import MS_LOB_FIELD from "@salesforce/schema/Job__c.MS_Line_of_Business__c";
import getTaskRecordTypeName from '@salesforce/apex/BulkMSTaskCreationController.getTaskRecordTypeId';

const fields = [MS_LOB_FIELD];
export default class TaskTabLWC extends LightningElement {
    @api recordId;
    @api taskrecords;
    showFlow=false;
    showComponent=false;
    @api recordTypeId;
    jobRecord;
    recordTypeName;
   @wire(getRecord, {recordId: "$recordId",fields})
   wiredJob({ error, data }) {
    if (data) {
        console.log('Job data '+JSON.stringify(data));
        this.jobRecord = data;
        this.error = undefined;
        console.log('MS LOB '+this.MSLob);
        if(this.MSLob == 'TA - Corporate' || this.MSLob == 'TA - Credentialing'){
            this.recordTypeName = 'TA - Corporate';
        }
        else if(this.MSLob == 'TA - Vocational (Batch)' || this.MSLob == 'TA - Vocational (School)' || this.MSLob == 'TA - Vocational (Analytics)'){
            this.recordTypeName = 'TA - Vocational';
        }
        else if(this.MSLob == 'Talent Management'){
            this.recordTypeName = 'Talent Management';
        }
        else if(this.MSLob == 'Talent Management (Dashboards)'){
            this.recordTypeName = 'MS Analytics';
        }
        getTaskRecordTypeName({taskRecordTypeName:this.recordTypeName})
            .then((result) =>{
                this.recordTypeId = result;
                console.log('method return '+this.recordTypeId);
                if(this.MSLob=='Talent Management'  ||
                this.MSLob == 'TA - Vocational (Analytics)' ||  this.MSLob == 'Talent Management (Dashboards)'){
                    this.showComponent = true;
                }
                else{
                    this.showFlow=true;
                }
            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
            });
        
    } else if (error) {
        this.error = error;
        this.jobRecord = undefined;
    }
}

      get MSLob() {
        return getFieldValue(this.jobRecord, MS_LOB_FIELD);
      }

    get inputVariables() {
        return [
            {
                name: 'jobRecordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    handleStatusChange(event) {
        console.log('handleStatusChange', event.detail.status);
        console.log('output variables '+JSON.stringify(event.detail.outputVariables));
       /* if(event.detail.status=='STARTED'){
            console.log('MS LOB Value '+this.MSLob);
            if(this.MSLob == 'TA - Corporate' || this.MSLob == 'TA - Credentialing'){
                recordTypeName = 'TA - Corporate';
            }
            else if(this.MSLob == 'TA - Vocational (Batch)' || this.MSLob == 'TA - Vocational (School)'){
                recordTypeName = 'TA - Vocational';
            }
            else if(this.MSLob == 'Talent Management'){
                recordTypeName = 'Talent Management';
            }
            else if(this.MSLob == 'TA - Vocational (Analytics)' || this.MSLob == 'Talent Management - Dashboards'){
                recordTypeName = 'MS Analytics';
            }
            getTaskRecordTypeName({taskRecordTypeName:recordTypeName})
                .then((result) =>{
                    this.recordTypeId = result;
                })
                .catch((error) => {
                    this.error = error;
                    this.contacts = undefined;
                });
        }*/
        
        if(event.detail.status=='FINISHED'){
            this.showFlow = false;
            this.showComponent = true;
            this.taskrecords = event.detail.outputVariables[0].value;
            console.log('Task record type Id '+this.recordTypeId);
            console.log('Task Records at source '+JSON.stringify(this.taskrecords));
        }
    }
}