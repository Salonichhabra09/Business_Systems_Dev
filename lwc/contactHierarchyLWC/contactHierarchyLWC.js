import { api, LightningElement, track, wire } from 'lwc';
import getContacts from '@salesforce/apex/Account_Contacts_Hierarchy.getContacts';
import getContactHierarchyDetails from '@salesforce/apex/Account_Contacts_Hierarchy.getContactHierarchyDetails';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import UploadContactCSS from '@salesforce/resourceUrl/UploadContactCSS';
import saveContacts from '@salesforce/apex/BulkContactsFromAPController.saveContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ImportTemplate from '@salesforce/label/c.Import_Contact_Template';

const FIELDS = ['Account.Account_Number__c'];

/**
 * This component displays a contact hierarchy based on the provided recordId and accountplanId. It includes 
 * functionality to zoom in and out of the hierarchy, navigate to the record page of a contacted contact, 
 * and handle refreshing the hierarchy.
 * 
 */
export default class ContactHierarchy extends NavigationMixin(LightningElement) {
    // static renderMode = 'light';
    @api recordId; //Represents the recordId used for retrieving contacts.
    @api accountplanId; //Represents the accountplanId used for retrieving contacts.
    @api filtersFromParent;
    @api isAccPlanRetired;
    @api isExpanded;


    subject; //Holds the subject of the last contacted contact.
    contactedRecord; //Stores the name of the last contacted contact.
    contactedRecordId; //Stores the ID of the last contacted contact.

    contacts = []; //Holds the array of retrieved contacts.

    @api zoomLevel = 80; //Represents the zoom level for the contact hierarchy.
    minimum = 30; //Specifies the minimum value for the zoom level.

    spinnerClass = 'slds-show'; //Controls the visibility of the spinner.
    scriptsInitialized = false; //Tracks whether the scripts have been initialized.
    errorAccessingRecId = ''; //Stores an error message related to recordId access.
    errorGettingContacts = ''; //Stores an error message related to contact retrieval.
    showErrorMessage = false;
    showContacts = false; //Controls the visibility of the contacts in the component.
    @track ele; //Represents a reference to the '.dragContainer' element.
    
    @track shouldReload = false; //Determines whether the hierarchy should be reloaded.
    
    //Added by Prachi SSE-21596

    @api isStatusUnderReview ;
    @track disableUploadButton = false;
    @track accountNumber;
    @track showUploadContactButtons = true;
    contactData;
    data;
    error;
    accountNumberList =[];
    rowHeaderToImport =['Account Number','First Name','Last Name','Email','Phone','Title' , 'Area of Interest','Reports To Email','Reports To Account Number','Top Level Contact(Y/N)'];
     
    filesList =[]; 
    //changes end Prachi SSE-21596

    //changes start Jai SSE-21273
    isRegionalOrGlobal = false;
    dNumberList;
    currentAccount;
    @api currentAccountFromParent;
    showHierarchy = true;
    iconName = 'utility:chevronright';
    expandedClass;
    expandedClassForAcc;
    showFilters = true;
    allContactsList;

    //changes end Jai SSE-21273

    @track selectedFilters = {
        filter1: false,
        filter2: false,
        filter3: false,
        filter4: '',
        filter5: ''
    };


      //Added by Prachi SSE-21596

      showToast(title, message ,variant) {
        
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        this.spinnerClass = 'slds-hide';
    }

  

    @wire(getRecord, { recordId: '$recordId', fields : FIELDS})
    wiredAccountPlan({ error, data }) {
        if (data) {
           
            this.accountNumber = data.fields.Account_Number__c.value;
           
           
        }
       else if (error) {
            
            let message = 'Something went wrong while accessing the data.\n Please contact your system Admin';
            this.showToast('Error', message ,'error');
            this.spinnerClass = 'slds-hide';

        }
    }
   

    handleFileUpload(event) {
       
        this.spinnerClass = 'slds-show'; //Controls the visibility of the spinner.
        const files = event.detail.files;
        this.disableUploadButton = true;
    
        if (files.length > 0) {
          const file = files[0];
          
          // start reading the uploaded csv file
          this.read(file);
        }
      }
      
      async read(file) {
        try {
          const result = await this.load(file);
          // execute the logic for parsing the uploaded csv file
          this.parse(result);
        } catch (e) {
          this.error = e;
        }
      }
    
      async load(file) {
        return new Promise((resolve, reject) => {
          const reader = new FileReader();
    
          reader.onload = () => {
            resolve(reader.result);
          };
          reader.onerror = () => {
            reject(reader.error);
          };
          reader.readAsText(file);
        });
      }


      parse(csv) {
        // parse the csv file and treat each line as one item of an array
       
        const lines = csv.split(/\r\n|\n/);
       
        let tempContactList;
        
        // parse the first line containing the csv column headers
        const headers = lines[0].split(',');
        
         console.log('(headers.length' + headers.length); 
       //Check headers in CSV are in correct order 
        if(headers.length > 0){
           
          
            if((headers[0].toUpperCase() != "ACCOUNT NUMBER" || headers[1].toUpperCase() != "FIRST NAME" || 
            headers[2].toUpperCase() != "*LAST NAME" || headers[3].toUpperCase() != "*EMAIL"
               || headers[4].toUpperCase() != "*PHONE" || headers[5].toUpperCase() != "*TITLE" ||
                headers[6].toUpperCase() != "*AREA OF INTEREST" || headers[7].toUpperCase() != "REPORTS TO EMAIL" ||
                headers[8].toUpperCase() != "REPORTS TO ACCOUNT NUMBER" || 
                headers[9].toUpperCase() != "TOP LEVEL CONTACT(Y/N)" ||  headers[10].toUpperCase() != "JOB FUNCTION" ||
                headers[11].toUpperCase() != "JOB LEVEL" || headers.length != 12)){
        
           
            let message = "Please ensure the File uploaded is CSV(Comma Delimited).Also, please ensure that the csv file has the columns: Account Number, First Name, Last Name, Email, Phone, Title , Area of Interest , REPORTS TO EMAIL , REPORTS TO ACCOUNT NUMBER , TOP LEVEL CONTACT(Y/N) , Job Function and Job Level. \n Please ensure that the csv file cells have no line breaks before or after the text!";
            this.disableUploadButton = false;
            
            this.showToast('Error', message ,'error');

            }

            else{
     
                this.contactData = lines;
                let data = [];


        if(lines.length <= 1){
           
        
         let  message = 'File has no data to upload!';
         this.showToast('Error', message ,'Error');
         this.disableUploadButton = false;
        } 
       else{

       // iterate through csv file rows and transform them to format supported by the datatable
          lines.forEach((line, i) => {

        
          if (i === 0)return;
           
          const obj = {};
          const currentline = line.split(',');
          let mandatoryFieldsPresent = true;

          if(currentline.length > 1){
          
          
                if((currentline[0] == '' || currentline[0] == null ) &&
                  ((currentline[1] != '' && currentline[1] != null) ||
                  (currentline[2] != '' && currentline[2] != null) ||
                  (currentline[3] != '' && currentline[3] != null) ||
                  (currentline[4] != '' && currentline[4] != null) ||
                  (currentline[5] != '' && currentline[5] != null) ||
                  (currentline[6] != '' && currentline[6] != null) ||
                  (currentline[7] != '' && currentline[7] != null) ||
                  (currentline[8] != '' && currentline[8] != null) ||
                  (currentline[9] != '' && currentline[9] != null) ||
                  (currentline[10] != '' && currentline[10] != null) ||
                  (currentline[11] != '' && currentline[11] != null) 
                   )){
                    currentline[0] = this.accountNumber;
                }
                if((currentline[7] != '' && currentline[7] != null )&&
                (currentline[8] == '' || currentline[8] == null )){
                    currentline[8] = this.accountNumber;
                }
                for (let j = 0; j < headers.length; j++) {
                   obj[headers[j]] = currentline[j];  
    
             }

            if((currentline[0] != '' && currentline[0] != null )){
                data.push(obj);
            }
               
            
  
  
                  

          }
        
  });

console.log('data' + JSON.parse(JSON.stringify(data)));
console.log('data' +(JSON.stringify(data)));
  // assign the converted csv data for the lightning datatable
     
        let contactWrapperFinal=[] ;
        let count =0 ;
           
  
        (data).forEach(function(e) {
          count =   count+1;
          let wrapper = {
              AccountNumber : e["Account Number"],
              FirstName: e["First Name"],
              LastName: e["*Last Name"],
              Email: e["*Email"],
              Phone: e["*Phone"],
              Title: e["*Title"],
              AreaOfInterest: e["*Area of Interest"],
              ReportsToEmail: e["Reports To Email"],
              ReportsToAccount: e["Reports To Account Number"],
              isTopContact: e["Top Level Contact(Y/N)"],
              JobFunction : e["Job Function"],
              JobLevel : e["Job Level"]
         
            };
           
             contactWrapperFinal.push(wrapper)  ;
            
        })
  
  console.log('Calling Class');
saveContacts({contactWrapperList : contactWrapperFinal , accplanId : this.accountplanId}).then(Response => {
    console.log('inside Class');
          if(Response){
              this.spinnerClass = 'slds-hide'; //Controls the visibility of the spinner.
              console.log('Response.MessageType' + Response.Message);  
              if(Response.MessageType == 'Success' ){
                if(Response.errorContacts > 0){
                    if(Response.totalContacts == Response.errorContacts){
                        let   message = 'There were ' +  Response.errorContacts + ' errors while uploading csv. Please refer to Contacts Imported file saved in Files';
                        this.showToast('Error', message ,'error');
                    }
                    else{
                        let   message = 'Contacts have been uploaded successfully! \n There were ' +  Response.errorContacts + ' errors. Please refer to Contacts Imported file saved in Files';
                        this.showToast('Success', message ,'success');
                    }
        
                }
                else{
                    this.showToast('Success', 'Contacts have been uploaded successfully! Please refer to Contacts Imported file saved in Related List.' ,'success');
                }
                 
                let event = setTimeout(() => {
                    this.handleGoBackToHierarchy();
                  }, 4000);
                
              }
              else if(Response.MessageType == 'ERROR' ){
                this.showToast('ERROR', Response.Message ,'error');
                this.disableUploadButton = false;
                this.handleRefreshHierarcky();
            }
             
          }
        }).catch(Error =>{ 
             console.log(Error);  
        })
     
 


            }
        }
      
      }
    }
      downloadCSVFile(){
   
        window.location.href = `/sfc/servlet.shepherd/document/download/${ImportTemplate}`
    }
      

     //changes end Prachi SSE-21596
    
    handleFilterSelection(event) {
        if(event){
            const { name, value, type } = event.target;

        if (type === 'checkbox') {
          this.selectedFilters = {
            ...this.selectedFilters,
            [name]: event.target.checked
          };
        } else {
          this.selectedFilters = {
            ...this.selectedFilters,
            [name]: value
          };
        }
        }else{
            if(this.filtersFromParent){
                this.selectedFilters = this.filtersFromParent;
            }
        }
        const filtersToParent = new CustomEvent("filtertoparent",{detail:this.selectedFilters});
        this.dispatchEvent(filtersToParent);
    }


    /**
    Handles the refresh hierarchy event triggered by the parent component generateAccountPlan.
    Dispatches a custom event to notify the parent component to refresh the hierarchy.
    */
    handleRefreshHierarcky() {
        //const refreshEventOnParent = new CustomEvent("refreshhierarckyonparent");
        //this.dispatchEvent(refreshEventOnParent);
        this.handleChange();
    }

    //Added by Prachi
    handleGoBackToHierarchy(){
       
        const refreshEventOnParent = new CustomEvent("refreshhierarckyonparent");
        this.dispatchEvent(refreshEventOnParent);
    }

    /**
     * Callback function triggered after the component finishes rendering.
     * Performs specific actions to manipulate the rendered elements.
     * Also initializes scripts if not already initialized.
     */
    renderedCallback(){
        // Create a style element and set its inner text to define custom CSS styles.
        //added by Prachi SSE-21596
       if(this.isStatusUnderReview == true || this.isAccPlanRetired == true){
             this.showUploadContactButtons = false;
       }
       else{
        this.showUploadContactButtons = true;
       }
        Promise.all([
            loadStyle( this, UploadContactCSS )
            ]).then(() => {
              
            })
            .catch(error => {
                console.log( error.body.message );
        });
//Change ends SSE-21596
        const style = document.createElement('style');
        style.innerText = `.slider .slds-form-element__label {
            display: none !important;
        }
        
        .slider .slds-form-element__control {
            margin-top: 7px !important;
        }
        
        .slider .slds-slider__range {
            width: 100%;
        }`;

        // Retrieve the 'div.slider' element from the template.
        var temp = this.template.querySelector('div.slider'); //this.template.querySelector('[data-id="slider"]');
        if(temp != null){
            temp.appendChild(style);// Append the style element to the 'div.slider' element.
        }
        
        // Retrieve the '.resize' element from the template.
        var mainPattElem = this.template.querySelector('.resize');
        if(mainPattElem){
            // Adjust the zoom level of the '.resize' element based on the 'zoomLevel' property.
            mainPattElem.style.zoom = this.zoomLevel + '%';
        }

        // Retrieve the '.dragContainer' element from the template.
        this.ele = this.template.querySelector('.dragContainer');
        if(this.ele != null){
            let centerX = (this.ele.scrollWidth - this.ele.clientWidth) / 2;
            this.ele.scrollTo(centerX, 0);  // Scroll the '.dragContainer' element horizontally to center its content.                         
        } 

        if(this.scriptsInitialized){
            return;
        }

        this.scriptsInitialized = true;
    }

    /**
     * Callback function triggered when the component is connected to the DOM.
     * Performs initialization tasks and retrieves contact data based on recordId and accountplanId.
    */
    connectedCallback() {
        if(this.isExpanded){
            this.expandedClass = 'slds-m-left_x-large';
            this.expandedClassForAcc = 'slds-m-left_small'
            this.showFilters = false;
        }
        let self = this; // Store the component's instance reference for later use.

        // Check if recordId and accountplanId are present.
        if(self.recordId && self.accountplanId){            
            self.getAllContacts(self.recordId, self.accountplanId);// Retrieve contacts based on recordId and accountplanId.
            self.errorAccessingRecId = ''; // Clear the error message related to recordId access.
        } else { 
            // Set an error message for recordId access failure.
            self.errorAccessingRecId = 'Error Accessing the record Id! \n Please Contact your System Administrator.';
            self.spinnerClass = 'slds-hide'; // Hide the spinner since an error occurred.
        }
        this.handleFilterSelection();
    }

    handleFiltersVisibility(){
        this.showFilters = this.showFilters?false:true;
        this.iconName = this.showFilters?'utility:chevrondown':'utility:chevronright';
    }

    /**
     * Retrieves contacts based on the provided recordId and accountplanId.
     * @param {String} recordId - The recordId used for retrieving contacts.
     * @param {String} accountplanId - The accountplanId used for retrieving contacts.
     */
    getAllContacts(recordId, accountplanId){
        let self = this;// Store the component's instance reference for later use.
        let accId = this.currentAccountFromParent?this.currentAccountFromParent:recordId;
        getContactHierarchyDetails({ 
            accId: accId, 
            accPlanId: accountplanId
        })
        .then(res => {
            // Check if contacts were successfully retrieved
            this.currentAccount = accId;
            if(res.isRegionalOrGlobal){
                this.isRegionalOrGlobal = res.isRegionalOrGlobal;
                this.dNumberList = res.dNumberList;
            }
            if(res.contactsList != null && res.contactsList.length > 0){
                var result = JSON.parse(JSON.stringify(res.contactsList));
                // Iterate through the contacts
                result.forEach(function(con){
                    // Check if the contact is the last contacted contact
                    if(con.IsLastContacted){
                    self.subject = con.SubjectDiscussed;  // Set the subject of the last contacted contact
                    self.contactedRecord = con.Name; // Set the name of the last contacted contact
                    self.contactedRecordId = con.Id; // Set the ID of the last contacted contact
                    }
                });
                // Create a new list with additional properties
                let myList = result.map(row => ({
                    ...row,
                    condition: (row.ReportsToId == null)
                }));
                if(res.message){
                    this.showErrorMessage = true;
                    self.errorGettingContacts = res.message;// Clear the error message related to contact retrieval.
                }
                self.contacts = myList; // Set the retrieved contacts to the component's contacts property.
                self.showContacts = true; // Show the contacts in the component.
                self.allContactsList = res.allContactsList;
            } else {
                self.errorGettingContacts = res.message; // Set an error message if no contacts were retrieved.
                self.showContacts = false; // Hide the contacts in the component.
            }
            self.spinnerClass = 'slds-hide'; // Hide the spinner since the contacts retrieval is complete.
        })
        .catch(error => {
            console.log('ERROR', JSON.parse(JSON.stringify(error)));
            self.showContacts = false; // Hide the contacts in the component.
            // Set an error message for contact retrieval failure.
            self.errorGettingContacts = 'Failed getting related Contacts with error: \n' +  error +'\n'+'\n'+ 'Please contact your System Administrator';
            self.spinnerClass = 'slds-hide';  // Hide the spinner since an error occurred.
        });
    }

    handleChange(event){
        let self = this;// Store the component's instance reference for later use.
        let accountId = event?event.target.value:this.currentAccount;
        if(event){
            const accountToParent = new CustomEvent("currentaccounttoparent",{detail:accountId});
            this.dispatchEvent(accountToParent);
        }
        this.currentAccount = accountId;
        this.showHierarchy = false;
        this.contactedRecord = undefined;
        this.subject = undefined;
        this.contactedRecordId = undefined;
        getContacts({ 
            accId: accountId, 
            accPlanId: this.accountplanId
        })
        .then(res => {
            console.log(res.contactsList);
            // Check if contacts were successfully retrieved
            if(res.contactsList != null && res.contactsList.length > 0){
                var result = JSON.parse(JSON.stringify(res.contactsList));
                // Iterate through the contacts
                result.forEach(function(con){
                    // Check if the contact is the last contacted contact
                    if(con.IsLastContacted){
                    self.subject = con.SubjectDiscussed;  // Set the subject of the last contacted contact
                    self.contactedRecord = con.Name; // Set the name of the last contacted contact
                    self.contactedRecordId = con.Id; // Set the ID of the last contacted contact
                    }
                });
                // Create a new list with additional properties
                let myList = result.map(row => ({
                    ...row,
                    condition: (row.ReportsToId == null)
                }));
                if(res.message){
                    this.showErrorMessage = true;
                    self.errorGettingContacts = res.message;// Clear the error message related to contact retrieval.
                }else{
                    this.showErrorMessage = false;
                }
                self.contacts = myList; // Set the retrieved contacts to the component's contacts property.
                self.showContacts = true; // Show the contacts in the component.
            } else {
                self.errorGettingContacts = res.message; // Set an error message if no contacts were retrieved.
                self.showContacts = false; // Hide the contacts in the component.
            }
            self.spinnerClass = 'slds-hide'; // Hide the spinner since the contacts retrieval is complete.
            this.showHierarchy = true;
        })
        .catch(error => {
            this.showHierarchy = true;
            console.log('ERROR', JSON.parse(JSON.stringify(error)));
            self.showContacts = false; // Hide the contacts in the component.
            // Set an error message for contact retrieval failure.
            self.errorGettingContacts = 'Failed getting related Contacts with error: \n' +  error +'\n'+'\n'+ 'Please contact your System Administrator';
            self.spinnerClass = 'slds-hide';  // Hide the spinner since an error occurred.
        })
    }

    // Increase the zoom level by one step
    zoomIn() {
        var zoom = this.zoomLevel; 
        if (zoom <= 99) { // Check if the zoom level is less than or equal to 99
            var newZoom = parseInt(zoom) + 1; // Increment the zoom level by 1
            this.zoomLevel = newZoom; // Update the zoom level with the new value
           // var tree = this.template.querySelector('[data-id="mainPatt"]').style.zoom = newZoom + '%';
        }
    }

    // Decrease the zoom level by one step
    zoomOut() {
        var zoom = this.zoomLevel
        if (zoom >= this.minimum) { // Check if the zoom level is greater than or equal to the minimum value
            var newZoom = parseInt(zoom) - 1; // Decrement the zoom level by 1
            this.zoomLevel = newZoom; // Update the zoom level with the new value
        }
    }

    // Handle the zoom event triggered by the slider
    handleZoom(event) {
        var sliderValue = event.target.value; // Get the value of the slider
        this.zoomLevel = sliderValue; // Update the zoom level with the value from the slider
    }

    // Navigate to the record page of the las contacted contact record
    navigateToContacted(){ 
        const url = `/lightning/r/Contact/${this.contactedRecordId}/view`;
        window.open(url, "_blank");

        // let self = this;
        // this[NavigationMixin.Navigate]({
        //     type : 'standard__recordPage', // Specify the navigation type as record page
        //     attributes: {
        //         recordId: self.contactedRecordId, // Set the record Id of the contacted record
        //         actionName: 'view' // Specify the action to perform on the record page (view in this case)
        //     }
        // });
    }


}