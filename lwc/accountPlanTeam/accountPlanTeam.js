import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveAccountTeamMembers from '@salesforce/apex/AccountPlanTeam_Controller.saveAccountTeamMembers';
import getAccountTeamMembers from '@salesforce/apex/AccountPlanTeam_Controller.getAccountTeamMembers';
import getAllAccountTeamMembers from '@salesforce/apex/AccountPlanTeam_Controller.getAllAccountTeamMembers';
import getCurrentAccountPlanTeamMembers from '@salesforce/apex/AccountPlanTeam_Controller.getCurrentAccountPlanTeamMembers';
import linkAccountTeamMembers from '@salesforce/apex/AccountPlanTeam_Controller.linkAccountTeamMembers';
import ACCOUNTPLAN_NAME from '@salesforce/schema/Account_Plan__c.Name';
import ACCOUNTPLAN_STATUS from '@salesforce/schema/Account_Plan__c.Account_Plan_Status__c';
import ACCOUNTPLAN_ACCOUNTID from '@salesforce/schema/Account_Plan__c.Account_Name__c';

const fields = [ACCOUNTPLAN_NAME, ACCOUNTPLAN_ACCOUNTID, ACCOUNTPLAN_STATUS];

export default class AccountPlanTeam extends LightningElement {
    @api recordId;
    @api isRetired ;//Added as part of SSE-21664
    disabled = false;

    showCurrent = true;
    showNew = false;
    showExisting = false;
    showSpinnerForCurrent = true;
    @track showButtons = true;

    @track selectedUserId;
    @track selectedTeamRole;
    @track accountPlan;
    @track accountPlanName;
    @track accountPlanStatus;
    @track accountPlanAccountID;
  

    @track newRecord = {
        UserId : '', 
        TeamMemberRole : '',
        AccountId: this.accountPlanAccountID,
        Account_Plans__c: this.accountPlanName, 
        CaseAccessLevel: 'None',
        ContactAccessLevel: 'Read', 
        OpportunityAccessLevel:'Read' 
    };
    @track newRecords = [];


    @wire(getRecord, { recordId: '$recordId', fields })
    wiredAccountPlan({ error, data }) {
        console.log('inside wire' + this.isRetired );
        this.showSpinnerForCurrent = true;
        if (data) {
            console.log('inside data');
            this.accountPlan = data;
            this.accountPlanName = data.fields.Name.value;
            this.accountPlanAccountID = data.fields.Account_Name__c.value;
            this.accountPlanStatus = data.fields.Account_Plan_Status__c.value;
            if(this.accountPlanStatus == 'In Review' || this.isRetired == true){
                this.showButtons = false;
            } else {
                this.showButtons = true;
            }
            this.errorMessageCurrent = '';
        } else if (error) {
            console.log('inside error');
            this.hasCurrent = false;
            this.errorMessageCurrent = 'Something went wrong while accessing the Account Plan data.';
            this.accountPlan = undefined;
        }
        this.showSpinnerForCurrent = false;
    }
   

    connectedCallback(){
        console.log('inside connected call');
        let  newRec = {
            UserId : '', 
            TeamMemberRole : '',
            AccountId: this.accountPlanAccountID,
            Account_Plans__c: this.accountPlanName, 
            CaseAccessLevel: 'None',
            ContactAccessLevel: 'Read', 
            OpportunityAccessLevel:'Read' 
        };
        this.newRecords.push(newRec);

       /* getCurrentAccountPlanTeamMembers,({recordId:this.recordId, accPlanName: this.accountPlanName}).then(response => {
            console.log('response --> ' + response);
            this.showSpinnerForCurrent = true;
            if (response.MessageType  == 'Error') {
                this.hasCurrent = false;
                this.errorMessageCurrent = 'Something went wrong while getting the Account Plan Team Members.' + '\n' +
                ' If the issue persistes please contact your System Administrator and provide the following error: \n' + response.Message;
            } else if (response.MessageType  == 'Success' ) {
                if(response.data.length>0){
                    this.accountPlanCurrentTeamMembers = result.data;
                    this.errorMessageCurrent = '';
                    this.hasCurrent = true;
                } else {
                    this.hasCurrent = false;
                    this.errorMessageCurrent = 'The Account Plan has no Team Members to display.';
                }
            }
            this.showSpinnerForCurrent = false;
            
        }).catch(error => {
        console.log('error' + error);
        })*/
    }


    handleShowNew(){
       this.syncCurrentList();
      // this.connectedCallback();
        this.showNew = true;
        this.showExisting = false;
        this.showCurrent = false;
        this.errorStartingNew = ''
        this.showSpinnerForNew = true;
        this.getAllAccountTeamMembers();
    }
    
    handleShowExisting(){
        this.showExisting = true;
        this.showNew = false;
        this.showCurrent = false;
        this.spinnerClassExisting = 'slds-show';
        this.accountTeamMemberError = '';
        this.syncCurrentList();
       // this.connectedCallback();
        this.getExistingAccountTeamMembers();
        //Commented by Prachi SSE-22562
       // this.handleSelected();

    }

    //START --- CURRENT MEMBERS Section --- 
        
        hasCurrent = false;
        errorMessageCurrent = '';

        columnsCurrentAccountTeam = [    
            { label: 'User', fieldName: 'userUrl',type:'url', typeAttributes: { label: { fieldName: 'userName' },target:'#' }  },
            { label: 'Team Role', fieldName: 'teamMemberRole', wrapText:true  },
            { label: 'Email', fieldName: 'userEmail', wrapText:true , type:'email' }
        ];

        accountPlanCurrentTeamMembers = [];
        //res = [];
        @track  wiredaccountPlanCurrentTeamMembers = [];

       
        @wire(getCurrentAccountPlanTeamMembers,({recordId:'$recordId', accPlanName: '$accountPlanName'}))
        wiredAccountPlanTeamMenbers(result){
            console.log('inside wire 2')
            this.showSpinnerForCurrent = true;
            this.wiredaccountPlanCurrentTeamMembers = result;
            console.log('inside wire 2' + JSON.stringify(result));
            if (result.error) {
                this.hasCurrent = false;
                this.errorMessageCurrent = 'Something went wrong while getting the Account Plan Team Members.' + '\n' +
                ' If the issue persistes please contact your System Administrator and provide the following error: \n' + error;
            } else if (result.data) {
                if(result.data.MessageType  == 'Success'){
                if(result.data.atmwList.length>0){
                    this.accountPlanCurrentTeamMembers = result.data.atmwList;
                    this.errorMessageCurrent = '';
                    this.hasCurrent = true;
                } else {
                    this.hasCurrent = false;
                    this.errorMessageCurrent = 'The Account Plan has no Team Members to display.';
                }
            }
            else if(result.data.MessageType  == 'Error'){
                this.hasCurrent = false;
                this.errorMessageCurrent = 'Something went wrong while getting the Account Plan Team Members.' + '\n' +
                ' If the issue persistes please contact your System Administrator and provide the following error: \n' + result.data.Message;
            }
            }
            this.showSpinnerForCurrent = false;
        }

        syncCurrentList(){
            refreshApex(this.wiredaccountPlanCurrentTeamMembers);
        };

    //END --- CURRENT MEMBERS Section --- Functions




    //START --- NEW MEMBERS Section --- Functions
        disableSaveNew = true;
        showSpinnerForNew = true;
        showSpinnerForSavingNew = false;
        errorStartingNew = '';
        childObjectApiName = 'AccountTeamMember'; //Objeto com campo lookup
        userLookupFieldApiName = 'UserId'; //Nome do campo lookup
        rolePicklistFieldApiName = 'TeamMemberRole';
        @track userAlreadyExistsErrorMessage = '';
        @track listAllSccountTeamMembers = new Map();
        @track selectedUsers = [];
        @track duplicateUsers = [];

        getAllAccountTeamMembers(){
            let self = this;
            self.listSllSccountTeamMembers = new Map();
            getAllAccountTeamMembers({ 
                recordId: self.recordId, 
                accPlanName: self.accountPlanName
            })
            .then(res => {
                var result = JSON.parse(JSON.stringify(res));
 
                if(result != null && result.length > 0){
                    result.forEach(element => {
                        self.listAllSccountTeamMembers.set((element.userId), (element.userName));
                    });        
                } else {
                    self.errorStartingNew = ''
                    console.log('The Account has no Team Members');
                }
                self.showSpinnerForNew = false;
            })
            .catch(error => {
                self.errorStartingNew = 'Failled Starting Add New Seciton. \n Please refresh. \n If the error continues, please contact your System Administrator.'
                console.log('Failed getting Account Team Members with error: ' + JSON.parse(JSON.stringify(error)) );
                self.showSpinnerForNew = false;
            });
        }

        addRow(){
            let  newRec = {
                UserId : '', 
                TeamMemberRole : '',
                AccountId: this.accountPlanAccountID,
                Account_Plans__c: this.accountPlanName, 
                CaseAccessLevel: 'None',
                ContactAccessLevel: 'Read', 
                OpportunityAccessLevel:'Read' 
            };
            this.newRecords.push(newRec);
            this.disableSaveNew = true;
        }

        clearAll(){
            this.newRecords = [];
            this.resetDuplicateUsersError();
            this.addRow();
            this.resetFormfields();
        }

        removeRow(event){
            let self = this;

            var key = event.currentTarget.dataset.id;

            if(this.newRecords.length > 1){

                let temp =JSON.parse(JSON.stringify(this.newRecords));
                temp.splice(key,1);
                self.newRecords = temp;

                this.selectedUsers = [];

                temp.forEach(element => {
                    if(element.UserId){
                        this.selectedUsers.push(element.UserId);
                    }
                });

                this.handleCheckNewSelectedUser();

                for (let index = 0; index < this.newRecords.length; index++) {
                    this.handleSaveNewDisabled(index);
                }
            }else if(this.newRecords.length == 1){
                
                this.newRecords = [];
                let newRec = {
                    UserId : '', 
                    TeamMemberRole : '',
                    AccountId: this.accountPlanAccountID,
                    Account_Plans__c: this.accountPlanName, 
                    CaseAccessLevel: 'None',
                    ContactAccessLevel: 'Read', 
                    OpportunityAccessLevel:'Read' 
                };
                this.newRecords = [newRec];

                this.resetFormfields();

                this.resetDuplicateUsersError();

                this.disableSaveNew = true;
            }
        }

        handleUserSelected(event) {
            var selectedRow = event.currentTarget;
            var key = selectedRow.dataset.id;
            this.newRecords[key].UserId = event.target.value;

            this.selectedUsers = [];
            this.newRecords.forEach(element => {
                if(element.UserId){
                    this.selectedUsers.push(element.UserId);
                }
            });
            this.handleCheckNewSelectedUser();
            this.handleSaveNewDisabled(key);
        }

        handleTeamRoleSelected(event){
            var selectedRow = event.currentTarget;
            var key = selectedRow.dataset.id;
            this.newRecords[key].TeamMemberRole = event.target.value;
            this.handleSaveNewDisabled(key);
        }

        handleCheckNewSelectedUser(){
            let self = this;

            self.duplicateUsers = [];

            (self.selectedUsers).forEach(item => {
                if(self.listAllSccountTeamMembers.has(item)){
                    (self.duplicateUsers).push(self.listAllSccountTeamMembers.get(item))
                }
            });

            if(self.duplicateUsers.length == 0){
                self.userAlreadyExistsErrorMessage = '';
            } else {
                self.userAlreadyExistsErrorMessage = 'The following users are duplicate Account Team Members:' 
                +'\n\n'
                + JSON.parse(JSON.stringify(self.duplicateUsers))
                + '\n\n' 
                + 'Please remove the duplicate users before saving.'; 
            }  
        }

        handleSaveNewDisabled(key){
            if( this.newRecords.length > 0 && 
                this.newRecords[key].TeamMemberRole != '' && 
                this.newRecords[key].TeamMemberRole != null && 
                this.newRecords[key].UserId != '' && 
                this.newRecords[key].UserId != null) {
                    if(this.duplicateUsers.length == 0 ){
                        this.disableSaveNew = false;
                    }
            } else {
                this.disableSaveNew = true;
            }
        }

        resetDuplicateUsersError(){
            this.userAlreadyExistsErrorMessage = '';
            this.selectedUsers = [];
            this.duplicateUsers = [];
        }

        resetFormfields(){
            const inputFields = this.template.querySelectorAll(
                'lightning-input-field'
            );
            if (inputFields) {
                inputFields.forEach(field => {
                    field.reset();
                });
            }
        }

        handleSaveNew(event){
            let self = this;
            event.preventDefault();

            const valid = [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
                return (validSoFar && field.reportValidity());
            }, true);

            if(valid){
                self.errorStartingNew = ''
                self.showSpinnerForNew = true;

                (this.newRecords).forEach(element => {
                    element.AccountId = this.accountPlanAccountID;
                    element.Account_Plans__c =  this.accountPlanName;
                });

                saveAccountTeamMembers({ 
                    records: JSON.stringify(this.newRecords), 
                })
                .then(res => {
                    console.log(res);
                    
                    self.selectedUserId = null;
                    self.selectedTeamRole = null;
                    self.newRecords = [self.newRecord];
                    self.disableSaveNew = true;

                    const event = new ShowToastEvent({
                        title: '',
                        variant: 'success',
                        mode:'dismissable',
                        duration: '15000',
                        message: 'Success creating the new Account Plan Team Members!'});
                    this.dispatchEvent(event);
                    self.showSpinnerForNew = false;
                   self.syncCurrentList();
                  // self.connectedCallback();
                    self.handleCancelNew();
                })
                .catch(error => {
                    console.log('ERROR: ', JSON.parse(JSON.stringify(error)));
                    self.newRecords = [];
                    self.selectedUserId = null;
                    self.selectedTeamRole = null;
                    self.errorStartingNew = 'Failed creating new Account Plan Team Members.';
                    self.showSpinnerForNew = false;
                });
            }
        }

        handleCancelNew(){
            this.showNew = false;
            this.showCurrent = true;
            this.showNewExisting = false;
            this.clearAll()
        }
    //END --- NEW MEMBERS Section --- Functions


    //START --- LINK EXISTING MEMBERS Section --- Functions
        spinnerClassExisting = 'slds-show';
        accountTeamMemberError = '';
        selectedIds;

        disableSaveExisting = true;

        columnsAccountTeam = [    
            { label: 'User', fieldName: 'userUrl',type:'url', typeAttributes: { label: { fieldName: 'userName' },target:'#' }  },
            { label: 'Account Number', fieldName: 'accountNumber', wrapText:true  },
            { label: 'Team Role', fieldName: 'teamMemberRole', wrapText:true  },
            { label: 'Email', fieldName: 'userEmail', wrapText:true , type:'email' }
        ];
        accountTeamMenbersList = [];

        getExistingAccountTeamMembers(){
            let self = this;
            self.spinnerClassExisting ='slds-show';
            self.accountTeamMenbersList = [];

            getAccountTeamMembers({ 
                recordId: self.recordId, 
                accPlanName: self.accountPlanName
            })
            .then(res => {
                var result = JSON.parse(JSON.stringify(res));
                if(result != null && result.length > 0){
                    let tempList = [];
                    let url = window.location.origin;
                    for (let index = 0; index < result.length; index++) {
                        const element = result[index];
                        let rec = {};
                        rec.accountId = element.accountId;
                        rec.accountPlanId = element.accountPlanId;
                        rec.userEmail = element.userEmail;
                        rec.userUrl = url + '/lightning/r/User/' + element.userId + '/view';
                        rec.userId = element.userId;
                        rec.teamMemberRole = element.teamMemberRole;
                        rec.userName = element.userName;
                        rec.id = element.id;
                        //Added by Prachi
                        rec.accountNumber = element.accountNumber;
                        tempList.push(rec);
                    }
                    self.accountTeamMenbersList = JSON.parse(JSON.stringify(tempList));
                    self.accountTeamMemberError = '';
                    self.spinnerClassExisting = 'slds-hide';  
                     //Added by Prachi SSE-22562
                    this.handleSelected();                           
                } else {
                    self.accountTeamMenbersList = [];
                    self.accountTeamMemberError = 'There are no Account Team Members to link to this Account Plan. \n Please click "Cancel" and "Add New"'; 
                    self.spinnerClassExisting = 'slds-hide';
                }
            })
            .catch(error => {
                self.accountTeamMenbersList = [];
                self.accountTeamMemberError = 'Failed getting Account Team Members with error: ' +  error; 
                self.spinnerClassExisting = 'slds-hide';
            });
        }

        handleSelected(event){
            //Commented by Prachi SSE-22562
            //var selectedRecords =  this.template.querySelector('[data-id="table-02"]').getSelectedRows();
            //Added by Prachi SSE-22562
            var selectedRecords =  this.template.querySelector('.datatableClass').getSelectedRows();
            console.log('selectedRecords' + selectedRecords);
            if(selectedRecords.length > 0){
                this.disableSaveExisting = false;
            } else {
                this.disableSaveExisting = true;
            }
        }

        handleSaveExisting(event) {
            let self = this;
            self.spinnerClassExisting = 'slds-show';
            
            //Commented by Prachi SSE-22562
            //var selectedRecords =  this.template.querySelector('[data-id="table-02"]').getSelectedRows();
            //Added by Prachi SSE-22562
           
            var selectedRecords =  this.template.querySelector('.datatableClass').getSelectedRows();
        
            if(selectedRecords.length > 0){

                let ids = [];
                selectedRecords.forEach(currentItem => {
                    ids.push(currentItem.id)
                });
                this.selectedIds = ids;

                linkAccountTeamMembers({ 
                    recordsIds: JSON.stringify(this.selectedIds), 
                    accountPlanName: self.accountPlanName
                })
                .then(res => {
                    console.log(res);
                    if(res == 'SUCCESS'){
                        self.accountTeamMenbersList = [];
                        self.spinnerClassExisting = 'slds-hide';
    
                        const event = new ShowToastEvent({
                            title: '',
                            variant: 'success',
                            mode:'dismissable',
                            duration: '15000',
                            message: 'Success linking the Account Team menbers with the Account Plan!'});
                        this.dispatchEvent(event);
    
                       self.syncCurrentList();
                     //  self.connectedCallback();
                        self.handleCancelExisting();
                    }
                   
                    else if(res.includes("insufficient access rights on object id")){
                        self.accountTeamMenbersList = [];
                        self.accountTeamMemberError = 'Failed linking the Account Team members with the Account Plan: Looks like the Account of user is Submit For Approval' ; 
                        self.spinnerClassExisting = 'slds-hide';
                    }
                    else{
                        self.accountTeamMenbersList = [];
                        self.accountTeamMemberError = 'Failed linking the Account Team members with the Account Plan: Looks like the Account of user is Submit For Approval' ; 
                        self.spinnerClassExisting = 'slds-hide';
                    }
                })
                .catch(error => {
                    self.accountTeamMenbersList = [];
                    self.accountTeamMemberError = 'Failed linking the Account Team members with the Account Plan: ' +  error.body.message; 
                    self.spinnerClassExisting = 'slds-hide';
                }); 
            }
        }

        handleCancelExisting(){
            this.showExisting = false;
            this.showCurrent = true;
            this.showNewExisting = false;
        }
}