import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBureauSystemDetails from '@salesforce/apex/SystemManagerController.getBureauSystemDetails';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import LightningConfirm from 'lightning/confirm';

const columns = [
    {
        label: 'Action', type: 'button-icon', initialWidth: 5,
        typeAttributes: { iconName: 'utility:delete', 
                        name: 'delete', 
                        iconClass: 'slds-icon-text-error' 
                        }
    },
    {
        label: 'SF System Id', fieldName: 'manageSysName', type: 'url',
        typeAttributes: { label: { fieldName: 'sysId' }, target: '_blank' }
    },
    { label: 'System Client Id', fieldName: 'sysCliendId'},
    { label: 'System Type', fieldName: 'System_Type__c' },
    { label: 'System Name', fieldName: 'sysName' },
    { label: 'Client Name', fieldName: 'clientName' },
    { label: 'Is Client System', fieldName: 'clientSys', type:'checkbox', wrapText: true, initialWidth: 100,
        typeAttributes: {
            value: { fieldName: 'clientSys' },
            context: { fieldName: 'Name' }
        }
    },
    { label: 'System URL', fieldName: 'System_URL__c' },
    { label: 'Project Id', fieldName: 'Project_Id__c' }
];

export default class SystemManagerTable extends LightningElement {
    @api recordId
    @track data = [];
    tableColumns = columns;
    systemRecId = '';
    rowLimit = 25;
    rowOffSet = 0;
    showManageButton = false;
    showActionColumn = false;
    isFirstTime = true;

    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        let userProfileName;
        if (error) {
            this.error = error;
            console.log('Error ###'+error)
        } else if (data) { 
            console.log('Data Profile ###'+JSON.stringify(data.fields.Profile.displayValue))
            if (data.fields.Profile.displayValue != null) {
                userProfileName = data.fields.Profile.displayValue;
                console.log('1. this.superUser ###'+this.superUser)
                if(userProfileName == 'System Administrator' || userProfileName == 'Managed Service Lightning') {
                    this.showManageButton = true;
                    //hideColumn(this.tableColumns, 'actions');
                }
                else {
                    this.showManageButton = false;
                }
            }
        }
    }    

    connectedCallback(){
        this.getBureauSystemDetails();
    }

    getBureauSystemDetails(){
        getBureauSystemDetails({
            jobId : this.recordId,
            limitSize: this.rowLimit , 
            offset : this.rowOffSet
        })
        .then( result => {
                let tempList = []; 
                result.forEach((record) => {
                    let tempRec = Object.assign({}, record); 
                    tempRec.sysId = tempRec.System__r.Name;
                    tempRec.sysCliendId = tempRec.System__r.System_Client_ID__c;
                    tempRec.manageSysName = '/' + tempRec.System__c;
                    tempRec.sysName = tempRec.System__r.System_Name__c;
                    tempRec.clientName = tempRec.System__r.System_Client_Name__c;
                    tempRec.clientSys = tempRec.System__r.Is_Client_System__c;
                    tempList.push(tempRec);
                });
                this.data = this.data.concat(tempList);
                console.log('this.data ####'+this.data)
        })
        .catch( error => {
            console.log('error: ', error);
        });
    }

    loadMoreData(event) {
        //const currentRecord = this.accounts;
        //const { target } = event;
        //target.isLoading = true;
        if(this.isFirstTime == false){
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            this.getBureauSystemDetails();
        }else{
            this.isFirstTime = false;
        }
    }

    manageSystemfun() {
        this.dispatchEvent( new CustomEvent( 'managesystem', {
            detail: this.data
        } ) );

    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        if(this.showManageButton) {
            const row = event.detail.row;
        this.systemRecId = row.Id;
        let displayMessage = 'Are you sure you want to remove this System?';
        let label = 'Remove System';
        this.handleConfirmClick(displayMessage, label);
        }
        else {
            this.showToastMessage('You are not allowed to perform this action', 'error', 'dismissable');
        }
    }

    async handleConfirmClick(Displaymessage, label) {
        const result = await LightningConfirm.open({
          message: Displaymessage,
          variant: 'header',
          label: label,
          theme: 'warning'
        });
        if (result == true) {
          if (label == 'Remove System') {
            deleteRecord(this.systemRecId)
              .then(() => {
                this.showToastMessage('System is successfully deleted', 'success', 'dismissable');
                this.getBureauSystemDetails();
              })
              .catch(error => {
                this.loading = false;
                this.showToastMessage('Error deleting Systems.', 'error', 'dismissable');
              });
          }
        }
    }

    showToastMessage(message, variant, mode) {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}