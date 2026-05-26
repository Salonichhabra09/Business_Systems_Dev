import { LightningElement,api,track,wire } from 'lwc';
import Case_OBJECT from '@salesforce/schema/Case';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import System_Used from '@salesforce/schema/Job__c.System_Used__c';
import Preferred_Language from '@salesforce/schema/Job__c.Preferred_Language__c';
import Primary_Contact from '@salesforce/schema/Job__c.Opportunity__r.Primary_Contact__c';
//import Parent_Job_Region from '@salesforce/schema/Job__c.Parent_Job__r.Job_Region__c';
import Job_Region from '@salesforce/schema/Job__c.Job_Region__c';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
//import getJobDetails from'@salesforce/apex/JobTriggerManager_2.getJobDetails';
export default class CreateCaseRecord extends NavigationMixin(LightningElement) {

    @api recordId;
    @track selectedValue
    @track options = [];
    showdropdown=false;
    @track RecordTypeName;
    systemUsed;
    PreferredLanguage;
    @track oppId;
    primaryContact;
    jobRegion;
    parentJobRegion;

    @wire(getRecord, { recordId: '$recordId', fields: [Job_Region,System_Used,Preferred_Language,Primary_Contact] })
    wiredRecord({ error, data }) {
        if(data) {
            this.primaryContact = data.fields.Opportunity__r.value.fields.Primary_Contact__c.value;
            this.systemUsed = data.fields.System_Used__c.value;
            this.PreferredLanguage = data.fields.Preferred_Language__c.value;
            this.jobRegion = data.fields.Job_Region__c.value;
        }else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
    };

    @wire(getObjectInfo, { objectApiName: Case_OBJECT })
    caseObjectInfo({data, error}) {
        this.showdropdown=true;
        if(data) {
            let optionsValues = [];
            // map of record type Info
            const rtInfos = data.recordTypeInfos;
            // getting map values
            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].available && rtValues[i].name != 'Master'){
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    });

                    if(rtValues[i].name == 'Information only – Services'){
                        this.selectedValue=rtValues[i].recordTypeId;
                        this.RecordTypeName=rtValues[i].name;
                    }
                }
            }

            this.options = optionsValues;
        }
        else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
    }
     
    // Handling on change value
    handleChange(event) {
        this.selectedValue = event.detail.value;
        for(let i = 0; i < this.options.length; i++) {
            if(this.options[i].value == this.selectedValue){
                this.RecordTypeName=this.options[i].label;
            }
        }

    }

    handleNext(){
        //getJobDetails({jobId:this.recordId}).then((result) => {
           //console.log('Result '+result.Id);
           let defaultvaluesObj={
            Bureau_Job__c: this.recordId,
            ContactId: this.primaryContact,
            Case_Region__c: this.jobRegion
        };
        if(!this.systemUsed.includes(';')){  
            defaultvaluesObj.System__c= this.systemUsed;   
            if(this.RecordTypeName =='Information only – Services') {
                defaultvaluesObj.Product__c = this.systemUsed;
                defaultvaluesObj.Assigned_To__c= 'Managed Services';
            }
        }
        
        if(this.PreferredLanguage){
            defaultvaluesObj.Preferred_Language__c = this.PreferredLanguage;
         
        }

        let defaultValues = encodeDefaultFieldValues(defaultvaluesObj); 
 
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues,
                recordTypeId: this.selectedValue,
                backgroundContext: '/lightning/r/Job__c/'+this.recordId+'/view'    
            }
        });
   /* }).catch((error) => {
        console.log('error '+error);
       });*/

        

    }

    closeModal(){
        this.showdropdown=false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Job__c',
                actionName: 'view'
            }
        });
    }
}