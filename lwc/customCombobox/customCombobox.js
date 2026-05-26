import { LightningElement,api } from 'lwc';

export default class CustomCombobox extends LightningElement {

    isEdit = false;
    @api options;
    @api selectedRoles;
    @api relationshipId;
    selectedOptions = [];
    updatedSelectedRoles;
    
      connectedCallback(){
        this.updatedSelectedRoles = this.selectedRoles;
      }

      closeEditOnBlur(){
        this.isEdit = false;
        this.dispatchEvent(new CustomEvent('checkdisablesave', { bubbles:true, composed:true}));
      }

      handleChange(event) {
        this.selectedOptions = event.detail;
        let temp =[];
        this.selectedOptions.forEach(element => {
          temp.push(element.label); 
        });
        this.updatedSelectedRoles = temp.join(';');
      }

      handleEdit(event){
        event.stopPropagation()
        this.isEdit = true;
        this.dispatchEvent(new CustomEvent('disablesave', { bubbles:true, composed:true}));
      }

      handleClose(){
        this.isEdit = false;
        this.dispatchEvent(new CustomEvent('updateroles', { bubbles:true, composed:true,detail: {relationshipId:this.relationshipId,updatedSelectedRoles:this.updatedSelectedRoles}}));
      }
      
}