import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe} from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountMergePOC extends NavigationMixin(LightningElement) {

    mergeOption = 'Account';
    isLookupVisible = true;
    accountId;
    isAccountChecked = true;
    isContactChecked = false;
    lookupClass = "slds-m-top_small hide-lookup";

    get options() {
        return [
            { label: 'Account', value: 'Account' },
            { label: 'Contact', value: 'Contact' },
        ];
    }

    handleChange(event){
        this.mergeOption = event.currentTarget.name;
        this.lookupClass = this.mergeOption =='Contact'?"slds-m-top_small":"slds-m-top_small hide-lookup";
        if(this.mergeOption == 'Contact'){
            this.isAccountChecked = false;
            this.isContactChecked = true;
        }else{
            this.isAccountChecked = true;
            this.isContactChecked = false;
        }
        
    }

    handleAccountRemoval(event){
        this.accountId = '';
    }

    handleAccountSelection(event){
        this.accountId = event.detail.projectId;
    }

    handleOpenMergeWiz(){

        let url = this.mergeOption == 'Account'? '/merge/accmergewizard.jsp':'/merge/conmergewizard.jsp?&id='+this.accountId;
        console.log(url);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: url
            }
        });
    }
    
    subscription = {};
    @api channelName = '/event/Accounts_Merged__e';

    connectedCallback() {
        this.handleSubscribe();
        //this.handleOpenWizard();
    }

    proxyToObj(obj){
        return JSON.parse(JSON.stringify(obj));
    }
 
    handleSubscribe() {
        const self = this;
        const messageCallback = function (response) {
            self.handleNavigate(response);
        };
 
        subscribe(this.channelName, -1, messageCallback).then(response => {
            this.subscription = response;
        });
    }

    handleNavigate(response){
        const event = new ShowToastEvent({
            title: 'Merged Successfully !',
            variant:'success'
        });
        this.dispatchEvent(event);
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: response.data.payload.Merged_Account__c,
                objectApiName: this.mergeOption,
                actionName: 'view'
            },
        }).then((url) => {
            window.location.href = url;
        });
        this[NavigationMixin.Navigate]({
            
        });
    }
}