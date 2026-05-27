import { LightningElement, track, api, wire } from 'lwc';
import SYSTEM_USED_FOR_SYSTEMS from '@salesforce/label/c.System_Used_values_for_Systems';
import ERROR_MESSAGE from '@salesforce/label/c.Error_message_for_invalid_System_Used_for_Systems';
import NO_SYSTEM_ERROR_MESSAGE from '@salesforce/label/c.No_System_Used_selected';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
const fields = ['Job__c.System_Used__c'];

export default class SystemManager extends LightningElement {
    @api recordId;
    dataLoaded = true;
    manageData = false;
    systemInfo;
    systemUsed = false;
    errorMessage = ERROR_MESSAGE;

    showEditTable(event) {
        this.dataLoaded = false;
        this.manageData = true;
        this.systemInfo = event.detail;
    }

    showTable(event) {
        this.dataLoaded = true;
        this.manageData = false;
    }

    @wire(getRecord, { recordId: '$recordId', fields})
    jobRecord({ data, error }) {
        if(data!=undefined) {
            let sysUsed = data.fields.System_Used__c.value;
            if(sysUsed!=null) {
                let updatedSysUsed = sysUsed.split(';')
            console.log('updatedSysUsed###'+updatedSysUsed)
            for(let i=0; i<updatedSysUsed.length; i++) {
                console.log('This is valid value ###'+updatedSysUsed[i])
                if(SYSTEM_USED_FOR_SYSTEMS.includes(updatedSysUsed[i])) {
                    console.log('Valid value ###'+updatedSysUsed)
                    this.systemUsed = true;
                    break;
                 }
            }
            }
            else {
                this.errorMessage = NO_SYSTEM_ERROR_MESSAGE;
            }
        }
    }
}