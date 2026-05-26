import { LightningElement, api, track, wire } from 'lwc';
import getHierarchyDetails from '@salesforce/apex/OpportunityContactHierarchy.getHierarchyDetails';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import UploadContactCSS from '@salesforce/resourceUrl/UploadContactCSS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";

export default class OppContactHierarchy extends NavigationMixin(LightningElement) {

    @api zoomLevel = 70; //Represents the zoom level for the contact hierarchy.
    minimum = 20; //Specifies the minimum value for the zoom level.
    showHierarchy = false;
    showSpinner = true;
    scriptsInitialized = false; //Tracks whether the scripts have been initialized.
    errorGettingContacts = 'Error in displaying the hierarchy'; //Stores an error message related to contact retrieval.
    showErrorMessage = false;
    showContacts = false; //Controls the visibility of the contacts in the component.
    @track ele; //Represents a reference to the '.dragContainer' element.
    @track contacts = []; //Holds the array of retrieved contacts.
    totalPlaceholders;
    opportunityName;
    opportunityUrl;
    recordId;
    wiredData;
    hierarchySize = 12;
    isAction = false;
    isView = false;
    contact;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.c__recordId;
            console.log(this.recordId);
        }
    }

    @wire(getHierarchyDetails, { hierarchyInformationId: '$recordId' })
    wiredHierarchyDetails(value) {
        this.wiredData = value;
        const { error, data } = value;
        if (data) {
            this.contacts = [];
            console.log(data);
            this.opportunityName = data.OpportunityName;
            this.opportunityUrl = data.OpportunityUrl;
            let hierarchyList = data.HierarchyList;
            if (hierarchyList != null && hierarchyList.length > 0) {
                this.totalPlaceholders = data.TotalPlaceholders;
                console.log('data.TotalPlaceholders: ', data.TotalPlaceholders);
                console.log('this.totalPlaceholders: ', this.totalPlaceholders);
                var result = JSON.parse(JSON.stringify(hierarchyList));
                console.log(JSON.stringify(result));
                // Create a new list with additional properties
                let myList = result.map(row => ({
                    ...row,
                    condition: (!row.ReportsTo)
                }));

                console.log(JSON.stringify(myList));
                this.contacts = myList; // Set the retrieved contacts to the component's contacts property.
                this.showContacts = true; // Show the contacts in the component.
                this.allContactsList = hierarchyList;
                this.showHierarchy = true;
            } else {
                //self.errorGettingContacts = res.message; // Set an error message if no contacts were retrieved.
                this.showContacts = false; // Hide the contacts in the component.
            }
            this.showSpinner = false; // Hide the spinner since the contacts retrieval is complete.
            this.error = undefined;
        } else if (error) {
            console.log(JSON.stringify(error));
            this.showSpinner = false;
            this.showErrorMessage = true;
            this.error = error;
            this.contacts = undefined;
        }
    }
    /**
     * Callback function triggered after the component finishes rendering.
     * Performs specific actions to manipulate the rendered elements.
     * Also initializes scripts if not already initialized.
     */
    renderedCallback() {
        // Create a style element and set its inner text to define custom CSS styles.
        // Promise.all([
        //     loadStyle(this, UploadContactCSS)
        // ]).then(() => {

        // })
        //     .catch(error => {
        //         console.log(error.body.message);
        //     });
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
        if (temp != null) {
            temp.appendChild(style);// Append the style element to the 'div.slider' element.
        }

        // Retrieve the '.resize' element from the template.
        var mainPattElem = this.template.querySelector('.resize');
        if (mainPattElem) {
            // Adjust the zoom level of the '.resize' element based on the 'zoomLevel' property.
            mainPattElem.style.zoom = this.zoomLevel + '%';
        }

        // Retrieve the '.dragContainer' element from the template.
        this.ele = this.template.querySelector('.dragContainer');
        if (this.ele != null) {
            let centerX = (this.ele.scrollWidth - this.ele.clientWidth) / 2;
            this.ele.scrollTo(centerX, 0);  // Scroll the '.dragContainer' element horizontally to center its content.                         
        }

        // if (this.scriptsInitialized) {
        //     return;
        // }

        // this.scriptsInitialized = true;
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

    handleRefreshHierarchy(event) {
        console.log('handleRefreshHierarchy: ');
        this.handleActionClose();
        this.showContacts = false;
        refreshApex(this.wiredData).then(() => {
            this.showContacts = true;
        });

    }

    handleSpinnerToggle(event) {
        console.log('Inside handleSpinnerToggle: ');
        this.showSpinner = true;
    }

    handleViewContact(event) {
        if(!this.contact){
            let mapWidth = this.template.querySelector('.level-2');
            let totalWidth = this.template.querySelector('.dragContainer');
            console.log(mapWidth.getBoundingClientRect().width);
            console.log(totalWidth.getBoundingClientRect().width);
            let percent = mapWidth.getBoundingClientRect().width / totalWidth.getBoundingClientRect().width;
            console.log(percent);
            percent = percent * 100;
            if(percent <= 75){
                this.zoomLevel = 60;
            }else if(percent > 75 && percent <= 90){
                this.zoomLevel = 55;
            }else if(percent > 90 && percent <= 120){
                this.zoomLevel = 40;
            }else if(percent > 120 && percent <= 185){
                this.zoomLevel = 30;
            }else if(percent > 185){
                this.zoomLevel = 20;
            }
            this.hierarchySize = 7;
            this.isAction = true;
        }
            setTimeout(() => {
                this.isView = false;
            }, 0);
            setTimeout(() => {
                this.isView = true;
            }, 0);
            console.log('Inside handleAction: ');
            this.contact = event.detail.contact;

    }

    handleActionClose(){

        this.zoomLevel = 70;
        this.hierarchySize = 12;
        this.isAction = false;
        this.isEdit = false;
        this.isView = false;
        this.contact = null;
    }

}