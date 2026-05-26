import { LightningElement,api,track } from 'lwc';

export default class CustomSearchComponent extends LightningElement {

    @api searchPlaceholder='Search';
    @api inputClassFromParent;
    @api subjectFromParent;
    @track selectedName;
    @api picklist;
    @api accessKey;
    @track blurTimeout;
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    isPointerInside = false;
    itemToSearch;
    @track picklistToUse = [];

    connectedCallback(){
        let temp = JSON.parse(JSON.stringify(this.picklist));
        temp.unshift({label:'--None--',value:''});
        this.picklistToUse = temp;
        if(this.subjectFromParent){
            this.selectedName = this.subjectFromParent;
        }else{
            this.onSelect();
        }
    }

    handleClick() {
        this.inputClass = this.inputClassFromParent;
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur(event) {
        if(!this.isPointerInside){
            this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 100);
        }
            const valueSelectedEvent = new CustomEvent('customvalueselected', {detail: {value:event.target.value,accessKey:this.accessKey}   });
            this.dispatchEvent(valueSelectedEvent);
    }

    handleMouseEnter(){
        this.isPointerInside = true;
    }

    handleMouseLeave(){
        this.isPointerInside = false;
        setTimeout(()=>this.template.querySelector('[data-id="inputBox"]').focus());
    }

    onSelect(event) {
        let selectedId = event?event.currentTarget.dataset.id:'Call';
        let selectedName = event?event.currentTarget.dataset.name:'Call';
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail: {value:selectedId,accessKey:this.accessKey}});
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    onChange(event){
        if(event.target.value){
            this.itemToSearch = event.target.value;
            this.handleSearch();
        }else{
            this.picklistToUse = this.picklist;
        }
    }

    handleSearch(){
            
            if (this.picklistToUse) {
                let searchResults = [];
                let searchKey = this.itemToSearch.toLowerCase();
                for (let record of this.picklist) {
                    let valuesList = Object.values(record);
 
                    for (let val of valuesList) {
                        let str = String(val);
 
                        if (str) {
 
                            if (str.toLowerCase().includes(searchKey)) {
                                searchResults.push(record);
                                break;
                            }
                        }
                    }
                }
                 this.picklistToUse = searchResults;
            }
        } 
}