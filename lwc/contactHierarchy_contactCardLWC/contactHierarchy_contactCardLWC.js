import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getContactOpportunities from '@salesforce/apex/Account_Contacts_Hierarchy.getContactOpportunities';
import getContactStrategies from '@salesforce/apex/Account_Contacts_Hierarchy.getContactStrategies';
import createContact from '@salesforce/apex/Account_Contacts_Hierarchy.createContact';
import reparentContact from '@salesforce/apex/Account_Contacts_Hierarchy.reparentContact'; 
import getActiveContacts from '@salesforce/apex/Account_Contacts_Hierarchy.getActiveContacts';//Added by Prachi SSE-21273
import updateReportsToId from '@salesforce/apex/Account_Contacts_Hierarchy.updateReportsToId';//Added by Prachi SSE-21273 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContactHierarchy_contactCard extends NavigationMixin(LightningElement) {
    @api contact; // Holds the currently selected contact
    @api contacts; // Holds a list of contacts
    @api recordId; //this is Account Plan Id
    @api zoomLevel; // Holds the zoom level sent from parent component
    @api allContactsList;
    @api isAccPlanRetired;
    


    hideTheKidsClass = ''; // CSS class for hiding children elements
    lasContactedClass; // CSS class for styling the contact card bottom border based on the last contacted date
    
    contactedIconClass; // CSS class for styling the contacted icon
    @track hasKids; // Indicates if there are child elements
    showReplaceButton = true; // Controls the visibility of the replace button
    switchBehaviourClass; // CSS class for handling switch (expand/colapse children treen under a contact) behavior
    showTheKids = true; // Controls the visibility of child elements

    //lasContacted;
    //lasActivityClass;
    //pos = { top: 0, left: 0, x: 0, y: 0 };

    hoverOS = 'hoverConOppStrat'; // CSS class for hovering over the contact, opportunity, and strategy elements
    hoverClass = 'hoverClassOut'; // CSS class for handling hover behavior when the mouse leaves the contact

    oppStratButton = 'slds-button oppStratButton'; // CSS class for styling the opportunity strategy button
    oppButtonDiv ='slds-col slds-size_6-of-12 oppButtonDiv'; // CSS class for styling the opportunity button container
    stratButtonDiv ='slds-col slds-size_6-of-12 stratButtonDivOut'; // CSS class for styling the strategy button container

    showSpinner = true; // Controls the visibility of the spinner

    showOpp = false; // Controls the visibility of the opportunity datatable data section
    showErrorOpp = false; // Controls the visibility of the opportunity error message
    errorOpp = ''; // Holds the error message for the opportunity section

    showStrat = false; // Controls the visibility of the strategy datatable data section
    showErrorStrat = false; // Controls the visibility of the strategy error message
    errorStrat = '';  // Holds the error message for the strategy section
    topLevelContactsCount = 0; // Holds the count of top-level contacts (with Report to id = null)
    showButtons = true;//Changes By Jai
    isRootLevel = false;//Changes By Jai
    showKids = true;//Changes By Jai

    showChooseContactModal=false;//Added by Prachi SSE-21273
    showChooseExistingContactModal = false;//Added by Prachi SSE-21273
    disableSaveChooseExisting=false;//Added by Prachi SSE-21273
    activeContactData;//Added by Prachi SSE-21273
    data;//Added by Prachi SSE-21273
    selectedRowsFinal;//Added by Prachi SSE-21273
    buttonType;//Added by Prachi SSE-21273
    reportsToDisable = true;//Added by Prachi SSE-21273
    @track selectedRows;//Added by Prachi SSE-21273
    reparentContactFieldRequired = true;//Added by Prachi SSE-21273
    reparentContactFieldDisabled = false;//Added by Prachi SSE-21273
    isTopLevelContact = false;//Added by Prachi SSE-21273
    isTopContactCheckboxRequired = false;//Added by Prachi SSE-21273
  

    activeContactColumns=[{ label: 'Name', fieldName: 'ContactUrl', type:'url',
     typeAttributes: { label: { fieldName: 'Name' },linkUrl:{ fieldName: 'ContactUrl' },target:'_blank' }},
                          { label: 'Job Level', fieldName: 'JobLevel', wrapText:true  },
                          { label: 'Job Function', fieldName: 'JobFunction', wrapText:true  },
                          { label: 'Title', fieldName: 'Title', wrapText:true },
                          { label: 'Reports To', fieldName: 'reportsToUrl', type:'url',
                          typeAttributes: { label: { fieldName: 'ReportsToName' },linkUrl:{ fieldName: 'reportsToUrl' },target:'_blank' }},
                          
                        ]//Added by Prachi SSE-21273
   
    columnsOpp = [
        { label: 'Opportunity', fieldName: 'OppUrl', type:'url',initialWidth:120, typeAttributes: { label: { fieldName: 'OppShortName' },target:'#' }},
        { label: 'Role', fieldName: 'ConRole', wrapText:true  }
    ];
    dataOpp = [];

    columnsStrat = [
        { label: 'Strategy', fieldName: 'StratUrl', type:'url',initialWidth:120, typeAttributes: { label: { fieldName: 'StratName' },target:'#' }},
        { label: 'Role', fieldName: 'ConRole', wrapText:true  }
    ];
    dataStrat = [];


    @api
    get filters() {
        return this._filters;
    }
    set filters(value) {
        this._filters = value;
        this.updateContactClass();
    }
    _filters = {};
    
    @track filterClass = '';

    contactMatchesFilters(contact) {

        const { filter1, filter2, filter3, filter4, filter5 } = this.filters;
        
        // Implement the logic to check if the contact matches the selected filters
        if (
          (filter1 && contact.CountOpportunities == 0) ||
          (filter2 && contact.CountStrategies == 0) ||
          (filter3 && contact.IsActive == true) ||
          (filter4 && contact.JobLevel !== filter4) ||
          (filter5 && contact.JobFunction !== filter5)
        ) {
          return false;
        }
        
        return true;
    }

    updateContactClass() {
        // Assuming you have a function to determine if a contact meets the selected filters
        // Replace 'contactMeetsFilters' with your own logic
        const res = this.contactMatchesFilters(this.contact);
    
        //const contact = this.contacts.find(contactMeetsFilters);
    
        this.filterClass = res ? 'filteredin' : 'filteredout';
            if(this.filterClass === 'filteredout'){ //Changes By Jai
                this.showButtons = false;
            }else{
                this.showButtons = true;
            }
    }


    /**
     * Initializes the component when it is connected to the DOM.
     * Sets various class names and initial states based on the contact's properties.
     * Counts the number of top-level contacts and determines whether to show the reparent button.
     */
    connectedCallback(){
        let self = this;
        // Check if the contact is active
        if(self.contact.IsActive){
             // If the contact has had activity within the last 6 days, set the class to green
            if(self.contact.LastActivityInterval <= 6){
                self.lasContactedClass = self.contact.isFromDiffAccount?'aLinkForDiffAccount green':'aLink green';
            } else {
                 // If the contact has not had activity within the last 6 days, set the class to orange
                self.lasContactedClass = self.contact.isFromDiffAccount?'aLinkForDiffAccount orange':'aLink orange';   
            }
        } else{  
            // If the contact is not active, set the class to grey
            self.lasContactedClass = self.contact.isFromDiffAccount?'aLinkForDiffAccount grey':'aLink grey';
        }
        
        this.updateContactClass();
        // if(self.contactMatchesFilters(self.contact)){
        //     console.log('filtered in');
        //     self.lasContactedClass = self.lasContactedClass  + ' filteredin';
        // } else {
        //     console.log('filtered out');
        //     self.lasContactedClass = self.lasContactedClass  + ' filteredout';
        // }
        console.log(this.isAccPlanRetired);
        if(this.isAccPlanRetired){
            this.showButtons = false;
        }
        // Check if the contact was last contacted
        if(self.contact.IsLastContacted){
             // If the contact was last contacted, show the last contacted buble icon
            self.contactedIconClass = 'contactedIconVisible';
        } else {
            // If the contact was not last contacted, hide the icon
            self.contactedIconClass = 'contactedIconNotVisible';
        }

        // Set the initial state of hoverClass, oppStratButton, oppButtonDiv, and stratButtonDiv
        self.hoverClass = 'hoverClassOut';
        self.oppStratButton = 'slds-button oppStratButton';
        self.oppButtonDiv ='slds-col slds-size_6-of-12 oppButtonDiv';
        self.stratButtonDiv ='slds-col slds-size_6-of-12 stratButtonDivOut';

         // Set the initial state of showOpp, showErrorOpp, errorOpp, showStrat, showErrorStrat, and errorStrat
        self.showOpp = false;
        self.showErrorOpp = false;
        self.errorOpp = '';

        self.showStrat = false;
        self.showErrorStrat = false;
        self.errorStrat = '';

        // Count the number of top-level contacts
        self.contacts.forEach(function(cont){
            if(cont.ReportsToId == null || cont.ReportsToId == ''){
                self.topLevelContactsCount++;
            }
        });

        // Check if there is only one top-level contact and the current contact is also a top-level contact
        if(self.topLevelContactsCount <= 1 && (self.contact.ReportsToId == null || self.contact.ReportsToId == '')){
            // If there is only one top-level contact and the current contact is also a top-level contact, hide the reparent button
            self.showReparentButton = false;
        }

        if(self.contact.Id=='rootlevel'){
            this.isRootLevel = true;
        }
    }


    /**
     * Handles the event when the contact's "hasKids" property changes.
     * Updates the "hasKids" property of the component based on the event detail.
     * Shows or hides the down arrow icon used to expande colapse the contact subordinates
     * based on the updated "hasKids" value.
     */
    handleHasKids(event){
        // Update the "hasKids" property of the component with the new value from the event
        this.hasKids = event.detail;

        // Check if the contact has kids
        if(this.hasKids > 0){
            // If the contact has kids, show the replace button and set the class to show the switch button to expande or 
            // colapse the subordinates contacts
                this.showReplaceButton = true; 
            this.switchBehaviourClass = 'switchBtnOn';
        }else if(this.contact.Id=='rootlevel' && this.contacts.length>1){ //Changes By Jai
            this.switchBehaviourClass = 'switchBtnOn';
        }else if(this.contact.Id=='rootlevel' && this.contacts.length==1){//Changes By Jai
            this.showKids = false;
            this.switchBehaviourClass = 'switchBtnOff';
        } else {
            // If the contact does not have kids, set the class to hide the switch button to expande or colapse the subordinates contacts
            this.switchBehaviourClass = 'switchBtnOff';
            // If the contact does not have kids Check if the contact is not active, and hide the Replace Contact button
            if(!this.contact.IsActive){
                this.showReplaceButton = false;
            } 
        }
    }

    /**
     * Toggles the visibility of children contacts cards tree.
     * If "showTheKids" is true, hides the children by applying the "hideTheKids" class and sets "showTheKids" to false.
     * If "showTheKids" is false, shows the children by applying the "showTheKids" class and sets "showTheKids" to true.
     */
    hideChildren() {
        let self = this;
        // Check the value of "showTheKids" to determine the current visibility state
        if(self.showTheKids){
            // If the children are currently shown, hide them by applying the "hideTheKids" class
            self.hideTheKidsClass = 'hideTheKids';
            self.showTheKids = false;
        } else {
            // If the children are currently hidden, show them by applying the "showTheKids" class
            self.hideTheKidsClass = 'showTheKids';
            self.showTheKids = true;
        }
    }

    /**
     * Opens the contact record in a new browser tab.
     * Constructs the URL for the contact record based on the "contact.Id" property and opens it in a new tab using the "window.open()" method.
     */
    openContact() {
        // Construct the URL for the contact record using the "contact.Id" property
        let url;
        if(this.contact.Id=='rootlevel'){ // Changes by Jai
            url = `/lightning/r/Account/${this.contact.AccountId}/view`;
        }else{
            url = `/lightning/r/Account/${this.contact.Id}/view`;
        }

        // Open the contact record URL in a new browser tab
        window.open(url, "_blank");

        // The code below is an alternative approach to navigate to the contact record using the NavigationMixin.
        // But it open the contact in the same browser tab
        // It has been commented out, and the window.open() method is used instead.
        // If desired, the NavigationMixin code can be uncommented and used instead.
        // let self = this;
        // this[NavigationMixin.Navigate]({
        //     type : 'standard__recordPage',
        //     attributes: {
        //         recordId: self.contact.Id,
        //         actionName: 'view'
        //     }
        // }, {
        //     target: '_blank'
        // });
    }

    /**
     * Handles the hover event on the contact card element.
     * Updates the CSS class for the hover effect which opens the hover card, 
     * invokes the "seeRelatedOpp()" method, which loads the list of the contact related Opp on hover, 
     * and adjusts the size and position of the "resize" element based on the zoom level
     * that comes from the parent component contactHierarckyLWC.
     */
    hoverContact(){
        if(this.filterClass == 'filteredin'){ //<--- Uncomment this if only the contacts that meet the filters should expand on mouse hover
            // Update the CSS class for the hover effect
            this.hoverClass = 'slds-popover slds-popover_tooltip hoverClass';
            this.seeRelatedOpp();// Invoke the "seeRelatedOpp()" method

            // Retrieve the "resize" element from the template
            var resize = this.template.querySelector('[data-id="resize"]');

            // Adjust the size and position of the "resize" element based on the zoom level
            if(resize){
                if(parseInt(this.zoomLevel) >= 90  ){
                    resize.style.zoom = '100%';
                    resize.style.left = '130px'
                } else if(parseInt(this.zoomLevel) < 90 && parseInt(this.zoomLevel) >= 80 ){
                    resize.style.zoom = '110%';
                    resize.style.left = '120px'
                } else if(parseInt(this.zoomLevel) < 80 && parseInt(this.zoomLevel) >= 70 ){
                    resize.style.zoom = '120%';
                    resize.style.left = '110px'
                } else if(parseInt(this.zoomLevel) < 70 && parseInt(this.zoomLevel) >= 60 ){
                    resize.style.zoom = '130%';
                    resize.style.left = '100px'
                } else if(parseInt(this.zoomLevel) < 60 && parseInt(this.zoomLevel) >= 50 ){
                    resize.style.zoom = '140%';
                    resize.style.left = '90px'
                } else if(parseInt(this.zoomLevel) < 50 && parseInt(this.zoomLevel) >= 45 ){
                    resize.style.zoom = '160%';
                    resize.style.left = '80px'
                } else if(parseInt(this.zoomLevel) < 45 && parseInt(this.zoomLevel) > 35 ){
                    resize.style.zoom = '180%';
                    resize.style.left = '70px'
                } else if(parseInt(this.zoomLevel) <= 35 ){
                    resize.style.zoom = '200%';
                    resize.style.left = '60px'
                }
            }

        }
    }

    /**
     * Fetches and displays related opportunities for the contact.
     * Updates data, flags, and error messages based on the retrieved opportunities.
     */
    seeRelatedOpp() {        
        let self = this;
        self.showSpinner = true;

        //sets some variables when the user hovers the Opportunities tab
        self.setHoverContactOpp(self);

        // Checks if it is the first time that the user is hovering the Opportunities tab, when hovering the contact
        // If it is the first time, it fetchs the relates Opportunies, If it's not the first time, it just shows the 
        // alredy fecthed data or error message. Avoiding unecessary server calls when the user changes between 
        // Opportunities and Strategies tabs
        if(self.dataOpp.length == 0 && self.errorOpp == ''){
            
            self.dataOpp = []; //resets the varaible that holds the Opportunities data
            self.dataStrat = []; //resets the varaible that holds the Strategies data

            // Call the server-side method to retrieve contact opportunities
            getContactOpportunities({ 
                conId: self.contact.Id,
                accId: self.contact.AccountId
            })
            .then(res => {
                let result = JSON.parse(JSON.stringify(res));

                if(result.length > 0){
                    // Set the retrieved opportunities and update flags to show the opportunities 
                    self.dataOpp = result;

                    self.showOpp = true;  
                    self.errorOpp = '';
                    self.showErrorOpp = false;              
                } else {
                    // No opportunities found for the contact, sets error message and flags to let the user know
                    self.dataOpp = [];

                    self.showOpp = false; //hides the empty table
                    self.errorOpp = 'This Contact has no Opportunities to show related to its account.';
                    self.showErrorOpp = true; //shows the error message instead the empty table
                }
                self.showSpinner = false;  // Hide the spinner after data retrieval
            })
            .catch(error => {
                // Handle the error while retrieving opportunities
                let localRerror = 'Unknown error';
                if (Array.isArray(error.body)) {
                    localRerror = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    localRerror = error.body.message;
                }
                
                // Reset the data variable and update error flags and message
                self.dataOpp = [];

                self.showOpp=false; //hides the empty table
                self.errorOpp = 'Failed getting Related Opportunities with error: ' +  localRerror; 
                self.showErrorOpp = true; //shows the error message instead the empty table
                self.showSpinner = false;  // Hide the spinner
            }); 

        } else {     
        // IF it's not the first time that the user is hovering the Opportunities tab, 
        // it just shows the already fecthed data or error message, avoiding another server call
            if(self.dataOpp.length == 0){
                self.showErrorOpp = true; 
                self.showOpp=false; 
            } else {
                self.showErrorOpp = false; 
                self.showOpp=true; 
            }
            self.showSpinner = false;
        }
    }

    /**
     * Updates the flags and classes when the user hovers the Opportunities tab
     * hides/resets the information in the Strategies tab, and highlights the Opportunities tab .
     */
    setHoverContactOpp(self){
        self.oppButtonDiv ='slds-col slds-size_6-of-12 oppButtonDiv';
        self.stratButtonDiv ='slds-col slds-size_6-of-12 stratButtonDivOut';
        
        self.showErrorStrat = false;
        self.showStrat=false;   
    }

    /**
     * Fetches and displays related Strategies for the contact.
     * Updates data, flags, and error messages based on the retrieved Strategies.
     */
    seeRelatedStrat(){
        let self = this;
        self.showSpinner = true;

        //sets some variables when the user hovers the Strategies tab
        self.setHoverContactStrat(self);

        // Checks if it is the first time that the user is hovering the Strategies tab, when hovering the contact
        // If it is the first time, it fetchs the relates Strategies, If it's not the first time, it just shows the 
        // alredy fecthed data or error message. Avoiding unecessary server calls when the user changes between 
        // Opportunities and Strategies tabs
        if(self.dataStrat.length == 0 && self.errorStrat == ''){

            self.dataOpp = []; //resets the varaible that holds the Opportunities data
            self.dataStrat = []; //resets the varaible that holds the Strategies data

            // Call the server-side method to retrieve contact Strategies
            getContactStrategies({ 
                conId: self.contact.Id,
                accId: self.contact.AccountId,
                accPlanId: self.recordId
            })
            .then(res => {

                let result = JSON.parse(JSON.stringify(res));

                if(result.length > 0){
                    // Set the retrieved Strategies and update flags to show the Strategies 
                    self.dataStrat = result;

                    self.showStrat = true;  
                    self.errorStrat = '';
                    self.showErrorStrat = false;              
                } else {
                    // No Strategies found for the contact, sets error message and flags to let the user know
                    self.dataStrat = [];

                    self.showStrat = false; //hides the empty table
                    self.errorStrat = 'This Contact has no related Strategies to show.';
                    self.showErrorStrat = true; //shows the error message instead the empty table
                }

                self.showSpinner = false; // Hide the spinner after data retrieval
            })
            .catch(error => {
                self.dataStrat = [];
                // Handle the error while retrieving Strategies
                let localRerror = 'Unknown error';
                if (Array.isArray(error.body)) {
                    localRerror = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    localRerror = error.body.message;
                }

                // Reset the data variable and update error flags and message
                self.showStrat=false; //hides the empty table
                self.errorStrat = 'Failed getting Related Strategies with error: ' +  localRerror; 
                self.showErrorStrat = true; //shows the error message instead the empty table
                self.showSpinner = false; // Hide the spinner
            });
        } else {
        // IF it's not the first time that the user is hovering the Strategies tab, 
        // it just shows the already fecthed data or error message, avoiding another server call
            if(self.dataStrat.length == 0){
                self.showErrorStrat = true; 
                self.showStrat=false; 
            } else {
                self.showErrorStrat = false; 
                self.showStrat=true; 
            }

            self.showSpinner = false; 
        }
    }
    
    /**
     * Updates the flags and classes when the user hovers the Strategies tab
     * hides/resets the information in the Opportunities tab, and highlights the Strategies tab .
    */
    setHoverContactStrat(self){
        self.oppButtonDiv ='slds-col slds-size_6-of-12 oppButtonDivOut';
        self.stratButtonDiv ='slds-col slds-size_6-of-12 stratButtonDiv';
        self.showOpp = false;
        self.showErrorOpp = false;
    }

    /**
     * Handles the mouseout event on the contact element.
     * Calls the "clearHoverCard()" method to clear the hover card and updates the CSS class 
     * for the hover effect which closes the hover card.
     */
    outContact() {
        this.clearHoverCard();
        this.hoverClass = 'slds-popover slds-popover_tooltip hoverClassOut';
    }

    /**
     * Resettes various properties and flags when the user leaves the contcat card.
    */
    clearHoverCard(){
        let self = this;

        self.showSpinner = true;

        // Reset properties and flags related to hover card display
        self.hoverOS = 'hoverCon';
        self.oppButtonDiv ='slds-col slds-size_6-of-12 oppButtonDivOut';
        self.stratButtonDiv ='slds-col slds-size_6-of-12 stratButtonDivOut';

        // Reset data and flags related to opportunities
        self.dataOpp = [];
        self.showOpp=false;
        self.errorOpp = '';
        self.showErrorOpp = false;

        // Reset data and flags related to strategies
        self.dataStrat = [];
        self.showStrat=false;
        self.errorStrat = '';
        self.showErrorStrat = false;
    }


////// -->  SECTION related to ADD Child Contact; REPLACE Contact; REPARENT Contact 

    @track showModal = false; // Controls the visibility of the modal dialog
    @track showSpinnerModal = false; // Controls the visibility of the spinner in the modal dialog
    @track modalresize = 'zoom:120%'; // CSS style for resizing the modal dialog
    actionType = ''; // Represents the type of action being performed - Add Contact, Replace Contact, Reparent Contact
    reportsTo = ''; // Holds the value of the Reports To field
    showReparentModal = false; // Controls the visibility of the reparent modal dialog
    selectedNewReportsTo = ''; // Holds the value of the selected new Reports To contact
    reparentErrorMessage = ''; // Holds the error message for the reparenting action
    disableSaveReparent = true; // Controls the availability of the Save button in the reparent modal dialog(changed by Prachi)
    showReparentButton = true; // Controls the visibility of the reparent button
    showSpinnerReparentModal = false; // Controls the visibility of the spinner in the reparent modal dialog
    newReplaceModalTitle = 'New Contact'; // Hold the Header title for the AddChild/Replace modal


    /**
     * Handles the click action to create a new child contact.
     * Sets the action type to 'NEW' and the reportsTo field to the current contact's ID.
     * Calculates the modal size based on the zoom level of the outer component. 
     * Ensuring the user always sees the modal at 100% regadless the zoom of the outter component
     * Displays the modal by setting the showModal variable to true.
     */
    handleCreateNewContact(event) {
        let self = this;
        self.actionType = 'NEW'; //Flag that indicates that the ADD Child contact button was clicked
        self.reportsTo = self.contact.Id; // Set the reportsTo field to the current contact's ID
        
        

        let calc = 100 * 100 / self.zoomLevel; // Calculate the modal size based on the zoom level of the outer component
        self.modalresize = 'zoom:'+calc +'%';
        //Changes start Prachi SSE-21273
        //this.showModal = true; // Display the modal(Commented by Prachi)
        this.buttonType = event.currentTarget.dataset.id;
        this.showChooseContactModal = true;
        this.showSpinnerModal = false;
        //Changes end  Prachi SSE-21273
    }

    //Changes Start Prachi SSE-21273
    
    //Used to show list of existing contact click of button added by Prachi SSE-21273
    handleChooseExistingContact(event){
        this.showChooseContactModal = false;
        this.showChooseExistingContactModal = true;
        this.disableSaveChooseExisting = true;
        let self = this;
        let accountId;
        let newReportsToId;
        if(this.buttonType == 'Contact'){
            if(self.contact.isFromDiffAccount){
                accountId = self.contact.diffAccountId
            }else{
                accountId = self.contact.AccountId;
            }
             newReportsToId = self.contact.Id; // Set the reportsTo field to the current contact's ID
        }
        else if(this.buttonType == 'Account'){
             accountId =self.contact.AccountId;
             newReportsToId ='';

        }
   
        this.data='';
        this.activeContactData ='';
        this.selectedRows='';

        

        getActiveContacts({accountPlanId : this.recordId , contactCardID : newReportsToId, accountId : accountId ,
                           buttonType :this.buttonType}).then(Response => {
          
          if(Response.MessageType == 'Success'){
          if(Response.contactsList.length>0){
           this.activeContactData= Response.contactsList;
           this.data = Response.contactsList;
          }
          else{
           
            this.data = '';
          }
        }
        else if(Response.MessageType == 'Error'){
          this.showToast('Error getting active contacts', Response.message, 'error');
        }
        }).catch(error => {
            console.log('error' , JSON.stringify(error));
            this.showToast('Error getting active contacts', 'Please Refresh and try again. If issue continues please contact system admin.' , 'error');
        })
    }
    //Close the modal on click of button added by Prachi SSE-21273
    handleCloseChooseContactModal(){
      this.showChooseContactModal=false;
    }

    //Used to Close the existing contact modal
    handleCloseChooseExistingContactModal(){
        this.showChooseExistingContactModal = false;
    }
//Used to search the contact in existing layout
    handleSearchContact(event) {
       
        const searchKey = event.target.value.toLowerCase();
        let searchedRows = this.selectedRows;
       
        if (searchKey) {
            this.data = this.activeContactData;

            if (this.data) {
                let searchRecords = [];

                for (let record of this.data) {
                    let valuesArray = Object.values(record);

                    for (let val of valuesArray) {
                       
                        let strVal = String(val);

                        if (strVal) {

                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
               
                this.data = searchRecords;
            }
        } else {
            this.data = this.activeContactData;
        }
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
    }

    //This is the function used for handling the row selection
    handleRowSelection(event){

        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selectedRows);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();
        this.data.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });
        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });
            // Add any new items to the selectedRows list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });

        this.selectedRows = [...selectedItemsSet];
       


        if( this.selectedRows.length>0){
            this.disableSaveChooseExisting = false; 
            
        }
        else{
            this.disableSaveChooseExisting = true;
        }
        
       
    }

   //Display the first modal on click of button added by Prachi SSE-21273
    handleNewContactChoose(){
        let self = this;
        self.actionType = 'NEW'; //Flag that indicates that the ADD Child contact button was clicked
        if(this.buttonType == 'Account'){
            self.reportsTo = ''; 
            self.reportsToDisable = true;
        }
        else if(this.buttonType == 'Contact'){
        self.reportsTo = self.contact.Id; // Set the reportsTo field to the current contact's ID
        self.reportsToDisable = true;
        }
        let calc = 100 * 100 / self.zoomLevel; // Calculate the modal size based on the zoom level of the outer component
        self.modalresize = 'zoom:'+calc +'%';
        this.showModal = true; // Display the modal
        this.showChooseContactModal = false;

    }
    //Update the Existing Contact Reports ID added by Prachi SSE-21273
    handleSaveChooseExistingContact(event){
       
        let self = this;
        self.showSpinnerModal = true;
        let newReportsToId = self.contact.Id; // Set the reportsTo field to the current contact's ID
        let oldReportsToID = self.contact.ReportsToId;
        let contactIds = [];
        let recordsCheck = false;
       
        
        self.selectedRows.forEach(element => {
          
            if(element.ReportsToId == newReportsToId){
                recordsCheck == true;
            }
            contactIds.push(element);
        });
       
       

        updateReportsToId({newReportsToId:newReportsToId , 
                           conId:contactIds, buttonType:this.buttonType
                           }).then(Response => {

            if(Response='Success'){
                this.showToast('Contacts are updated', Response.message, 'success');
                this.showChooseExistingContactModal = false;
                self.showSpinnerModal = false;
                setTimeout(() => {
                    self.handleRefresh(); 
                }, 0);  
                
            }
            else{
                this.showToast('Error getting active contacts', Response.message, 'error');
            }
        }).catch(error => {
            this.showToast('Error getting active contacts', 'Please Refresh and try again. If issue continues please contact system admin.' , 'error');
        })
    
        
    }
    handleBackChooseContactModal(event){
        this.showChooseExistingContactModal = false;
        this.showChooseContactModal=true;
    }

    handleReparentAsTopContact(event){
       let checboxValue = event.target.checked;
       console.log('checboxValue' + checboxValue);
       this.isTopLevelContact = checboxValue;
       if(checboxValue){
           this.reparentContactFieldRequired = false;
           this.reparentContactFieldDisabled = true;
           this.disableSaveReparent = false;
        //Change the dataID from 'parentLookup' to 'topLevel' Prachi SSE-22562
           const field =  this.template.querySelector('[data-id="topLevel"]');
          field.setCustomValidity('');
          field.reportValidity();
       }
       else{
        this.reparentContactFieldRequired = true;
        this.reparentContactFieldDisabled = false;
        this.disableSaveReparent = true;
       }
    }
    //Changes End Prachi SSE-21273

    /**
     * Handles the action to create a replacement contact.
     * Sets the action type to 'REPLACE' and the reportsTo field to the current contact's ReportsToId.
     * Calculates the modal size based on the zoom level of the outer component.
     * Ensuring the user always sees the modal at 100% regadless the zoom of the outter component
     * Displays the modal by setting the showModal variable to true.
     */
    handleCreateReplaceContact() {
        let self = this;
        self.actionType = 'REPLACE'; //Flag that indicates that the REPLACE contact button was clicked
        self.reportsTo = self.contact.ReportsToId; // Set the reportsTo field to the current contact's ReportsToId

        // Calculate the modal size based on the zoom level of the outer component
        let calc = 100 * 100 / self.zoomLevel; 
        self.modalresize = 'zoom:'+calc +'%';
        this.showModal = true; // Display the modal
    }

    /**
     * Handles the saving of a new contact.
     * Performs form validation and creates a new contact record if the form is valid.
     * Displays a spinner while saving the contact.
     * Handles success and error scenarios after creating the contact.
     */
    handleSaveNewContact(event) {
        let self = this;
        // Perform form validation by checking the validity of each lightning-input-field
        const valid = [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);

        if(valid){
            this.showSpinnerModal = true;

            //Fetch the input fields values
            const fields = this.template.querySelectorAll("lightning-input-field");

            // Prepare the contact record input object with the field values
            const recordInput = { apiName: 'Contact' };
            fields.forEach(field => {
              recordInput[field.fieldName] = field.value;
            });

            /*
            The following IF ELSE determines the value of the originalConId variable based on the value of the actionType property. 
            It is used to differentiate between creating a new contact and replacing an existing contact.
            If actionType is 'NEW', a new contact is being created. So the originalConId is set to an empty string, 
            indicating that there is no original contact being replaced.
            If actionType is 'REPLACE', an existing contact is being replaced. In this case, the originalConId is set 
            to the Id of the current contact (this.contact.Id), indicating that the new contact will replace the existing contact with this ID.
            The originalConId value is used in the apex method as an input
            */
            let originalConId = '';
            let isRootLevel = false;//Change Added by Prachi SSE-21273
            //Set the originalConId
            if(this.actionType == 'NEW'){
                originalConId = ''; // If the action type is 'NEW', set the original contact ID to an empty string
            } else if (this.actionType == 'REPLACE'){ 
                originalConId = this.contact.Id; // If the action type is 'REPLACE', set the original contact ID to the ID of the current contact
                isRootLevel = this.contact.isRootLevel;//Change Added by Prachi SSE-21273
            }

            // Call the createContact Apex method to create the contact record
            createContact({ 
                contactRecord: recordInput,
                originalContcatId: originalConId,
                buttonType: this.buttonType,//Change Added by Prachi SSE-21273
                isRootLevel: isRootLevel//Change Added by Prachi SSE-21273
            })
            .then(res => {
                let result = JSON.parse(JSON.stringify(res));

                this.showSpinnerModal = false;

                if(result == 'Success'){

                    // Close the modal and refresh the contact hierarchy
                    this.handleClose();
                    //this.showToast('Success', 'Contact created successfully.', 'success'); 

                    // setTimeout to ensure that the event is dispatched asynchronously after all synchronous code 
                    // has been executed and  the parent component has had a chance to register the event listener
                    setTimeout(() => {
                        self.handleRefresh(); 
                    }, 0);                  
                } else {
                    // Display an error toast with the result message
                    this.showToast('Error creating contact', result, 'error');
                }
            })
            .catch(error => {
                let localRerror = 'Unknown error';
                if (Array.isArray(error.body)) {
                    localRerror = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    localRerror = error.body.message;
                }
                console.log(JSON.parse(JSON.stringify(error)));

                this.showSpinnerModal = false; //Hide spinner

                // Display an error toast with the error message
                this.showToast('Error creating contact', localRerror, 'error');
            }); 
        }
    }


    /**
     * Handles the action to reparent a contact.
     * Sets the action type to 'REPARENT'.
     * Calculates the modal size based on the zoom level of the outer component.
     * Ensuring the user always sees the modal at 100% regadless the zoom of the outter component
     * Displays the modal by setting the showModal variable to true.
     */
    handleReparentContact(){
        let self = this;
        self.actionType = 'REPARENT'; //Flag that indicates that the REPARENT contact button was clicked

        // Calculate the modal size based on the zoom level of the outer component
        let calc = 100 * 100 / self.zoomLevel;
        self.modalresize = 'zoom:'+calc +'%';

        self.reparentErrorMessage = ''; // Resests the reparent action error message 
        self.showReparentModal = true; // Display the modal
    }

    /**
     * handles the selection of a new parent contact for reparenting. It updates the selectedNewReportsTo property with the ID of the 
     * selected contact and performs validation to determine whether the save reparent button should be enabled or disabled.
     */
    handleParentSelected(event){
        this.reparentErrorMessage = ''; // Reset the reparent error message
        const selectedContactId = event.detail.value; // Get the selected contact ID from the event
        this.selectedNewReportsTo = JSON.parse(JSON.stringify(selectedContactId)); // Make a deep copy of the selected contact ID
        
        if(this.selectedNewReportsTo != '' &&  this.selectedNewReportsTo != null){ // Check if a contact is selected
            this.isTopContactCheckboxRequired = true;// Prachi  SSE-21273
            let valid = this.isSelectedReportsToValid(); // If a valid contact is selected, it calls the isSelectedReportsToValid() function to perform additional validation.
            if(valid){
                    this.disableSaveReparent = false; // Enable the save reparent button if the selected contact is valid
            } else {
                    this.disableSaveReparent = true; // Disable the save reparent button if the selected contact is invalid
            }; 
        } else {
            this.disableSaveReparent = false; // Enable the save reparent button if no contact is selected
            this.isTopContactCheckboxRequired = false;// Prachi  SSE-21273
            
        }   
        console.log('selectedContactId' ,this.selectedNewReportsTo );
        console.log('selectedContactId',selectedContactId);
        //Added byy Prachi  SSE-21273
        if(this.selectedNewReportsTo.length == 0){
            this.disableSaveReparent = true;
        }    
    }

    /**
     * Validates the selected contact for reparenting.
     * Checks if the selected contact meets certain conditions and provides an error message if it doesn't pass the validation.
     * @returns {boolean} True if the selected contact is valid for reparenting, false otherwise.
     */
    isSelectedReportsToValid(){
        // Check if the selected contact is found in the list of contacts
        const isContactFound = this.allContactsList.some((contact) => contact.Id == this.selectedNewReportsTo);
        if(isContactFound){   
            // let childrenPool = [];    
            // this.contacts.forEach(con => {
            //     if(con.ReportsToId != null && con.ReportsToId != '' && con.ReportsToId == this.contact.Id){
            //         childrenPool.push(con);
            //     }
            // });
            // console.log('childrenPool');
            // console.log(JSON.parse(JSON.stringify(childrenPool)));

            // Check if the selected contact is the same as the contact being reparented
            if(this.selectedNewReportsTo == this.contact.Id){
                this.reparentErrorMessage = "The selected contact is the contact you are trying to reparent! \n Please, select a different 'Reports To' contact.";
                return false;
            } 
            // Check if the selected contact is already the parent of the contact being reparented
            else if(this.selectedNewReportsTo == this.contact.ReportsToId){
                this.reparentErrorMessage = "The current contact already reports to the selected Contact! \n Please, select a different 'Reports To' contact.";
                return false;
            } 
            // else if (childrenPool.some((contact) => contact.Id == this.selectedNewReportsTo)){
            //     this.reparentErrorMessage = "A contact can not be reparented to one of its subordinates contacts! \n Please, select a different 'Reports To' contact.";
            //     return false;
            // } 
            else {
                this.reparentErrorMessage = ''; // No validation errors, clear the reparent error message
                return true; 
            }
        } else {
            // The selected contact is not found in the list of contacts, which means it is under a different account
           /* this.reparentErrorMessage = "The selected contact is under a different Account as the contact you are trying to reparent! \n" 
            +" Please, select a 'Reports To' contact under the account '"+ this.contact.AccountName +"'.";*/
            this.reparentErrorMessage ="The selected contact does not have any active relationship. \n" +
                                    "Please choose a contact that is present in the hierarchy."
            return false;
        }
    }

    /**
     * Handles the saving of the reparented contact.
     * Performs form field validity check before submitting the reparenting request.
     * If the form fields are valid, it calls the server-side Apex method to reparent the contact.
     * Displays success or error messages based on the response from the server.
     * Finally, closes the modal and refreshes the contact hierarchy if the reparenting is successful.
     * @param {Event} event - The event object.
     */
    handleSaveReparentContact(event){
        event.preventDefault();

        // Check the form fields validity before submitting
        const valid = [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);

       
        if(valid){
            this.showSpinnerReparentModal = true; //show spinner
            // If valid Call the server-side Apex method to reparent the contact
            //Change start Prachi  SSE-21273 
            let reportsToIdOfParent;
            if(this.isTopLevelContact){
                reportsToIdOfParent = '';
            }
            else{
                reportsToIdOfParent =  this.selectedNewReportsTo[0];
            }
           
            //Change End Prachi SSE-21273 
            reparentContact({ 
                contactId: this.contact.Id,
                //newReportsToId: this.selectedNewReportsTo[0],  --- commented by Prachi
                newReportsToId : reportsToIdOfParent, //Added by Prachi  SSE-21273 
                isTopContact:this.isTopLevelContact //Added by Prachi  SSE-21273 
            })
            .then(res => {
                let result = JSON.parse(JSON.stringify(res));
                if(result == 'Success'){
                    this.handleClose();
                    //this.showToast('Success', 'Contact reparented successfully.', 'success'); 

                    // setTimeout to ensure that the event is dispatched asynchronously after all synchronous code 
                    // has been executed and  the parent component has had a chance to register the event listener
                    setTimeout(() => { 
                        this.showSpinnerReparentModal = false;
                        this.handleRefresh(); 
                    }, 0);                  
                } else {
                    this.showSpinnerReparentModal = false; //hide spinner
                    this.showToast('Error reparenting contact!', result, 'error'); //Show error message
                }
                
            })
            .catch(error => {
                let localRerror = 'Unknown error';
                if (Array.isArray(error.body)) {
                    localRerror = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    localRerror = error.body.message;
                }

                this.showSpinnerReparentModal = false; //hide spinner
                this.showToast('Error reparenting contact', localRerror, 'error'); //Show error message
            }); 

        } else {
            this.disableSaveReparent = false; // Enable Save button
        } 
    }

    /**
     * Handles the close action of the modal.
     * Resets the state variables related to the modal and reparenting.
     */
    handleClose() {
        this.actionType = ''; // Reset the action type
        this.showModal = false; // Hide the modal for AddChild / Replace Contact
        this.showReparentModal = false; // Hide the modal for Reparent Contact
        this.reparentErrorMessage = ''; // Clear the reparent error message
        this.disableSaveReparent = true; // Disable the save reparent button
    }

    /**
     * Opens the associated account record in a new browser tab.
     * Constructs the URL for the account record based on the "contact.AccountId" property and opens it in a new tab using the "window.open()" method.
     */
    openAccount() {
        // Construct the URL for the account record using the "contact.AccountId" property
        const url = `/lightning/r/Account/${this.contact.AccountId}/view`;

        // Open the account record URL in a new browser tab
        window.open(url, "_blank");
    }

    /**
     * Opens the record of the contact's "ReportsTo" in a new browser tab.
     * Constructs the URL for the "ReportsTo" record based on the "contact.ReportsToId" property and opens it in a new tab using the "window.open()" method.
     */
    openReportsTo() {
        // Construct the URL for the "ReportsTo" record using the "contact.ReportsToId" property
        const url = `/lightning/r/Account/${this.contact.ReportsToId}/view`;

        // Open the "ReportsTo" record URL in a new browser tab
        window.open(url, "_blank");
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable',
            duration: 9000
        });
        this.dispatchEvent(evt);
    }

    /**
     * Handles the refresh action triggered by the user.
     * Fires a custom event "refreshhierarcky" to notify the parent component (contactHierarchyLWC) that a refresh is needed.
    */
    handleRefresh() {
        let self = this;
        // Create a custom event to signal the need for a refresh
        const refreshEvent = new CustomEvent("refreshhierarcky", {
            bubbles: true,
            composed: true
        });
        // Dispatch the custom event to notify the parent component
        self.dispatchEvent(refreshEvent);
    }

}