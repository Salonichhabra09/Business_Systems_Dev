import { LightningElement,api } from 'lwc';

export default class OppContactHierarchyChildLayer extends LightningElement {

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
    @api totalPlaceholders;
    @api hierarchyInformationId;

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
        // Retrieve the count of child contacts from the server
        if(this.contact.Children && this.contact.Children.length>0){
                self.has_conCount = true;

            // Dispatch a custom event to notify the parent components about the presence of child contacts
            const hasKidsEvent = new CustomEvent("haskidsevent", {
                detail: this.contact.Children.length
            });
            self.dispatchEvent(hasKidsEvent);
        }else{
            const hasKidsEvent = new CustomEvent("haskidsevent", {
                detail: 0
            });
            self.dispatchEvent(hasKidsEvent);
        }

         // Create a deep copy of the contacts array and add the 'isChild' property
        var result = JSON.parse(JSON.stringify(self.contacts));
        let myList = result.map(row => ({
            ...row,
            isChild: (row.ReportsTo == self.contact.Id)
        }));
         // Update the contacts array with the modified version
        self.contacts = myList;
    }
}