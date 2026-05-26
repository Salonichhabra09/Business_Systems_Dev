import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ADVOCACY_LEVEL_FIELD from '@salesforce/schema/Contact.Advocacy_Level__c';
import ICON from '@salesforce/resourceUrl/advocacyLevelIcon';

export default class Acr_manageAdvocacyLevel extends LightningElement {

    @api contactData;
    @api advocacyLevel;
    toggleColor;
    @track advocacyLevelOptions = [];
    isDropdownOpen = false;
    selectedOption;
    iconNameToDisplay;
    iconSize = 'x-small';
    weakIcon = ICON;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: ADVOCACY_LEVEL_FIELD })
    wiredcontactRoleValues({ error, data }) {
        // reset values to handle eg data provisioned then error provisioned
        this.advocacyLevelOptions = [];
        console.log('this.advocacyLevelOptions: ', JSON.stringify(data));
        // Map for advocacy levels and their corresponding icons
        const advocacyIconMap = {
            'Advocate': 'utility:favorite',
            'Neutral': 'utility:rating',
            'Weak': '',
            'None': 'utility:favorite_alt',
            'Blocker': 'action:close'
        };
        if (data) {
            const filteredOptions = data.values.filter(item => item.value !== "Champion" && item.value !== "Coach");
            this.advocacyLevelOptions = filteredOptions.map(option => {
                let lisIconsCss;
                if (option.label == 'Blocker') {
                    lisIconsCss = '.option-icon blocker-icon reduce-size';
                } else if (option.label == 'Weak') {
                    lisIconsCss = '.option-icon weak-icon';
                } else {
                    lisIconsCss = '.option-icon';
                }
                return {
                    label: option.label,
                    value: option.value,
                    icon: advocacyIconMap[option.label], // Add icon based on label or default
                    lisIconsCss: lisIconsCss
                };
            });

            console.log('this.advocacyLevelOptions: ', JSON.stringify(this.advocacyLevelOptions));
        } else if (error) {
            console.log(error);
        }
    }

    connectedCallback() {
        this.advocacyLevel != null ? this.toggleColor = 'enlargeIcon' : this.toggleColor = 'enlargeIcon';
        if (this.advocacyLevel != null) {
            this.iconSize = 'medium';
        }
        if (this.advocacyLevel != null)
            this.mapAdvocacyIcon(this.advocacyLevel);
        if (this.advocacyLevel == null ||
            this.advocacyLevel == '' ||
            this.advocacyLevel == undefined) {
            this.advocacyLevel = 'No Advocacy Level found';
        }
        console.log('this.advocacyLevel: ', this.advocacyLevel);
    }

    handleDropDownClose(event) {
        // Check if focus is leaving the dropdown entirely
        const relatedTarget = event.relatedTarget; // Element gaining focus
        if (!this.template.contains(relatedTarget)) {
            this.isDropdownOpen = false;
        }
    }

    mapAdvocacyIcon(advocacyVal) {
        const advocacyIconMap = {
            'Champion': 'utility:favorite',
            'Coach': 'utility:favorite',
            'Advocate': 'utility:favorite',
            'Neutral': 'utility:rating',
            'Weak': '',
            'None': 'utility:favorite_alt',
            'Blocker': 'action:close'
        };

        let persona = this.contactData?.Persona;
        console.log('persona: ', persona);
        let advocacyValue = advocacyVal;

        if (advocacyValue == 'Advocate') {
            if (persona == 'CHRO/ CPO' || persona == 'Chief Talent Officer' || persona == 'Head of TA'
                || persona == 'Head of TM' || persona == 'Head of Asmt COE' || persona == 'Head of Early Careers') {
                advocacyValue = 'Champion';
            } else if (persona == undefined) {
                advocacyValue = advocacyValue;
            } else {
                advocacyValue = 'Coach';
            }
        } else if (advocacyValue == 'Champion') {
            if (persona == 'CHRO/ CPO' || persona == 'Chief Talent Officer' || persona == 'Head of TA'
                || persona == 'Head of TM' || persona == 'Head of Asmt COE' || persona == 'Head of Early Careers') {
                this.toggleColor = 'enlargeIcon champion-icon';
                advocacyValue = 'Champion';
            } else {
                this.toggleColor = 'enlargeIcon coach-icon';
                advocacyValue = 'Coach';
            }
        } else if (advocacyValue == 'Coach') {
            if (persona == 'CHRO/ CPO' || persona == 'Chief Talent Officer' || persona == 'Head of TA'
                || persona == 'Head of TM' || persona == 'Head of Asmt COE' || persona == 'Head of Early Careers') {
                this.toggleColor = 'enlargeIcon champion-icon';
                advocacyValue = 'Champion';
            } else {
                this.toggleColor = 'enlargeIcon coach-icon';
                advocacyValue = 'Coach';
            }
        } else if (advocacyValue == 'Blocker') {
            this.toggleColor = 'enlargeIcon blocker-icon';
        } else {
            this.toggleColor = 'enlargeIcon';
        }
        this.iconNameToDisplay = advocacyIconMap[advocacyValue];
        if (advocacyValue != 'Blocker') {
            this.iconSize = 'medium';
        }
        if (advocacyValue == 'Blocker') {
            this.iconSize = 'x-small';
        }
        this.advocacyLevel = advocacyValue;
    }

    handleManageAdvocacyLevel() {
        this.isDropdownOpen = !this.isDropdownOpen;
    }

    handleOptionClick(event) {
        const selectedValue = event.currentTarget.dataset.value;
        console.log('selectedValue: ', selectedValue);
        const oldValue = this.advocacyLevel;
        console.log('oldValue: ', oldValue);

        this.advocacyLevel = selectedValue;
        // Map for advocacy levels and their corresponding icons
        this.mapAdvocacyIcon(selectedValue);
        this.isDropdownOpen = false; // Close dropdown after selection

        if (oldValue != selectedValue) {
            console.log('inside iffff ');
            const submitEvent = new CustomEvent('updateadvocacylevel', {
                detail: {
                    selectedValue: this.advocacyLevel
                }
            });
            this.dispatchEvent(submitEvent);
        }
    }
}