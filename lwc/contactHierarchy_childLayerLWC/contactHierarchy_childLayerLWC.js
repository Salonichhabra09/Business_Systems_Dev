import { api, LightningElement } from 'lwc';
import hasChildren from '@salesforce/apex/Account_Contacts_Hierarchy.hasChildren';

export default class ContactHierarchy_childLayer extends LightningElement {
    @api contact; // The current contact being displayed
    @api contacts = []; // List of contacts sent from parent component and back to the parent component, since this component works with recursion
    @api recordId; // The Account Plan Id
    @api zoomLevel; // The zoom level of the component sent from the parent component
    conCount = 0; // Number of child contacts
    has_conCount = false; // Indicates whether there are child contacts
    @api filters = {};
    //accCount = 0; // Number of associated accounts - not used in practice but needed to keep the css structure integrity
    //con_acc_Count = false; // Indicates whether there are child contacts or associated accounts
    //has_accCount = false; // Indicates whether there are associated accounts
    //accounts = [];
    //show = true; 
    //isChild = false; 
    @api allContactsList;
    @api isAccPlanRetired;

    renderedCallback(){
        let self = this;

        if(self.conCount > 0){
            // Dynamically create and append a style element to modify the CSS based on the li elemnte being a only child element
            const style = document.createElement('style');
            style.innerText = `    
            li:only-child {
               margin-top: 0.8em;
            }
            ul:before {
                height: 3em !important
            }
            `;
            var temp = this.template.querySelector('[data-id="childs"]');
            if(temp != null){
                temp.appendChild(style);
            }
        }
        

    }

    connectedCallback(){
        let self = this;
        let contactsToSend = [];
        this.contacts.forEach(element => {
            if(element.Id!='rootlevel'){
                contactsToSend.push(element);
            }
        });
        // Retrieve the count of child contacts from the server
        hasChildren({ 
            conId: self.contact.Id,
            accId: self.contact.AccountId,
            allContactsList:contactsToSend
        })
        .then(res => {
            self.conCount = res;
            // Check if there are child contacts
            if(res > 0){
                self.has_conCount = true;
                //self.con_acc_Count = true;
            }else if(self.contact.Id=='rootlevel'){
                self.has_conCount = true;
            }
            // if(self.accCount > 1){
            //     self.has_accCount = true;
            //     self.con_acc_Count = true;
            // }

            // Dispatch a custom event to notify the parent components about the presence of child contacts
            const hasKidsEvent = new CustomEvent("haskidsevent", {
                detail: res
            });
            self.dispatchEvent(hasKidsEvent);
        })
        .catch(error => {
            console.log('Failed with error: ' +  JSON.stringify(error));
        });

         // Create a deep copy of the contacts array and add the 'isChild' property
        var result = JSON.parse(JSON.stringify(self.contacts));
        let myList = result.map(row => ({
            ...row,
            isChild: (row.ReportsToId == self.contact.Id)
        }));
         // Update the contacts array with the modified version
        self.contacts = myList;
    }

}