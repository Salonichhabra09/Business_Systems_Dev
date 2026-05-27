import { LightningElement, track, api, wire } from 'lwc';
import getAllSystems from '@salesforce/apex/SystemManagerController.getAllSystems';
import createBureauSystem from '@salesforce/apex/SystemManagerController.createBureauSystem';
import getPreselectedSystem from '@salesforce/apex/SystemManagerController.getPreselectedSystem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';


export default class SystemManagerEditTable extends LightningElement {

    @api systemInfo;
    @api jobId;
    @api recordId;
    rowLimit = 25;
    rowOffSet = 0;
    @track data = [];
    languageList = []
    sysNameList = []
    reportingLangList = [] 
    projectIdList = []
    @track preSelectedRows = [];
    @track lastValidSelectedRows = []; // array of row key values (e.g. Names)
    @track lastValidRows = []; // array of row objects
    isAnyChange = false;
    allSelectedSysNames = [];
    showError = false;
    errorMessage = '';
    
    bureauSystem = [{
        name: '',
        lang: '',
    }]

    tempbureauSystem = [{
        name: '',
        lang: '',
    }]

    projectIdMap = [{
        name: '',
        projectId: '',
    }]

    isFirst = true;

    columns = [
        { label: 'SF System Id', fieldName: 'Name', wrapText: true, initialWidth: 120},
        { label: 'System Client Id', fieldName: 'System_Client_ID__c', wrapText: true, initialWidth: 120},
        { label: 'System Type', fieldName: 'System_Type__c', wrapText: true, initialWidth: 100},
        { label: 'System Name', fieldName: 'System_Name__c', wrapText: true, initialWidth: 150},
        { label: 'Client Name', fieldName: 'System_Client_Name__c', wrapText: true, initialWidth: 150},
        { label: 'Is Client System', fieldName: 'Is_Client_System__c', type:'checkbox', wrapText: true, initialWidth: 100,
        typeAttributes: {
            value: { fieldName: 'Is_Client_System__c' },
            context: { fieldName: 'Name' }
        }
        },
        { label: 'System URL', fieldName: 'System_URL__c', initialWidth: 150},
        /*{
            label: 'Report Language', fieldName: 'selectedLanguage', type: 'picklist', wrapText: true,
            typeAttributes: {
                placeholder: 'Choose Language', 
                options: this.languageList, 
                value: { fieldName: 'selectedLanguage' },
                context: { fieldName: 'Name' }
            }
        },*/
        { label: 'Project Id', fieldName: 'projectId', type:"input", wrapText: true,
        typeAttributes: {
            value: { fieldName: 'projectId' },
            context: { fieldName: 'Name' },
        }
    }
    ];

    connectedCallback() {
        this.manageSystem();
        for(let i=0; i<this.systemInfo.length; i++) {
            this.sysNameList.push(this.systemInfo[i].System__r.Name)
            //this.reportingLangList.push(this.systemInfo[i].Report_Language__c)
            this.projectIdList.push(this.systemInfo[i].Project_Id__c)
        }
    }

    /*picklistLoad(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { name: dataRecieved.context, lang: dataRecieved.value};
        this.bureauSystem.push(updatedItem);
    }

    
    picklistChanged(event) {
        this.isAnyChange = true;
        let tempList = [];
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log('dataRecieved.context ###',dataRecieved.context)
        let updatedItem = { name: dataRecieved.context, lang: dataRecieved.value};
        this.tempbureauSystem.push(updatedItem);
        if(this.allSelectedSysNames.includes(dataRecieved.context)) {
            for (const obj of this.bureauSystem) {
                if (obj.name === dataRecieved.context) {
                    obj.lang = dataRecieved.value;
                    break;
                }
            }
        }
        else {
            if(dataRecieved.value != '--None--') {
                alert('Please select row first!')
                for (const obj of this.bureauSystem) {
                    if (obj.name === dataRecieved.context) {
                        obj.lang = dataRecieved.value;
                        break;
                    }
                }
            }
        }
    }*/

    inputLoaded(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { name: dataRecieved.context, projectId: dataRecieved.value };
        this.projectIdMap.push(updatedItem);
    }

    inputChanged(event) {
        this.isAnyChange = true;
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        for (const obj of this.projectIdMap) {
            if (obj.name === dataRecieved.context) {
              obj.projectId = dataRecieved.value;
              break;
            }
        }
    }

    manageSystem() {
        getAllSystems({
            jobId : this.jobId,
            limitSize: this.rowLimit , 
            offset : this.rowOffSet
        })
        .then( result => {

            let tempList = [];

            result.forEach((record) => {
                let tempRec = Object.assign({}, record);
                    if(this.sysNameList.includes(record.Name)) {
                        let index = this.sysNameList.indexOf(record.Name)
                        //tempRec.selectedLanguage = this.reportingLangList[index];
                        tempRec.projectId = this.projectIdList[index];
                    }
                tempList.push(tempRec);
            });

            if(tempList.length!=0) {
                this.data = this.data.concat(tempList);
            }
            else {
                //this.data = result;
                this.data = this.data.concat(tempList);
            }
            
            let sysName=[];
            for(let i=0; i<this.systemInfo.length; i++) {
                sysName.push(this.systemInfo[i].System__r.Name)
            }
            this.preSelectedRows = sysName; 
            this.allSelectedSysNames = sysName;
            this.getPreselectedSystem();
        })
        .catch( error => {
            console.log('error: ', error);
        });
        
    }

    loadMoreData(event) {
        if(this.isFirst == false){
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            this.manageSystem(); 
        }else{
            this.isFirst = false;
        }
    }

getSelectedName(event) {
    const selectedRows = event.detail.selectedRows;
    this.isAnyChange = true;
    let validRowKeys = [];
    let systemTypes = new Set();
    let hasDuplicateType = false;
    let tempValidRows = [];

    for (let row of selectedRows) {
        const systemType = row.System_Type__c;

        if (systemTypes.has(systemType)) {
            hasDuplicateType = true;
        } else {
            systemTypes.add(systemType);
            validRowKeys.push(row.Name);         // Assuming key-field = Name
            tempValidRows.push(row);
        }
    }

    if (hasDuplicateType) {
        this.showError = true;
        this.errorMessage = 'You cannot select more than one system of the same System Type.';
         this.showToastMessage(this.errorMessage,'error', 'dismissable');
        // ❗ Revert to last valid selection
        this.preSelectedRows = [...this.lastValidSelectedRows];
        this.systemToInsert = [...this.lastValidRows];
        this.allSelectedSysNames = this.lastValidRows.map(r => r.Name);
    } else {
        this.showError = false;
        this.errorMessage = '';
        this.preSelectedRows = [...validRowKeys];

        // ✅ Update valid snapshot
        this.lastValidSelectedRows = [...validRowKeys];
        this.lastValidRows = [...tempValidRows];

        this.systemToInsert = [...tempValidRows];
        this.allSelectedSysNames = [...validRowKeys];
    }
}

    getPreselectedSystem() {
        getPreselectedSystem({
            systemNameList : this.preSelectedRows,
            jobId : this.jobId
        })
        .then( result => {
            this.systemToInsert = result;
            this.initializeValidSelection();
        })
        .catch( error => {
            console.log('error: ', error);
        });
    }

    handleSave(event) {

        let error;
        let label;
        /*for (const obj of this.projectIdMap) {
            console.log('obj.projectId ###'+obj.projectId)
            console.log('this.allSelectedSysNames.includes(obj.name) ###'+this.allSelectedSysNames.includes(obj.name))
            if(!this.allSelectedSysNames.includes(obj.name) && ((obj.projectId!='') || (obj.projectId!=undefined))) {
                error = 'Please select row first, Project Id added.'
                label = 'Select row before saving.'
                
            }
        }*/


        if(error == undefined) {
            if(this.systemToInsert==undefined || this.isAnyChange==false) {
                this.showToastMessage('No changes made', 'info', 'dismissable');
                this.dispatchEvent( new CustomEvent( 'showtable', {
                } ) );
            }
            else {
                createBureauSystem({
                    systemList : this.systemToInsert,
                    bureauSystem: JSON.stringify(this.bureauSystem),
                    projectIdMap : JSON.stringify(this.projectIdMap),
                    jobId : this.jobId
                })
                .then( result => {
                    console.log('result ####'+result)
                    if(result=='' || result==null) {
                        this.showToastMessage('Systems successfully updated.', 'success', 'dismissable');
                        this.dispatchEvent( new CustomEvent( 'showtable', {} ) );
                    }
                })
                .catch( error => {
                    console.log('error: ', error);
                    this.showToastMessage(error, 'error', 'dismissable');
                });
            }
        }
        else {
            this.handleConfirmClick(error, label);
        }
        
    }

    handleCancel(event) {
        this.dispatchEvent( new CustomEvent( 'showtable', {
        } ) );
    }

    showToastMessage(message, variant, mode) {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    async handleConfirmClick(Displaymessage, label) {
        const result = await LightningConfirm.open({
          message: Displaymessage,
          variant: 'header',
          label: label,
          theme: 'error'
        });
    }

    initializeValidSelection() {
    if (this.preSelectedRows?.length > 0 && this.data?.length > 0) {
        const validRows = this.data.filter(row => this.preSelectedRows.includes(row.Name));
        let systemTypes = new Set();
        let hasDuplicate = false;

        for (let row of validRows) {
            if (systemTypes.has(row.System_Type__c)) {
                hasDuplicate = true;
                break;
            }
            systemTypes.add(row.System_Type__c);
        }

        if (!hasDuplicate) {
            this.lastValidSelectedRows = [...this.preSelectedRows];
            this.lastValidRows = [...validRows];
        } else {
            this.lastValidSelectedRows = [];
            this.lastValidRows = [];
            console.warn('Initial selection contains duplicates. Ignoring them for validation snapshot.');
        }
    }
}

}