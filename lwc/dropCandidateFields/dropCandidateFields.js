import { LightningElement, track, api, wire } from 'lwc';
import createFormAttribute from '@salesforce/apex/CustomerRequestController.createFormAttribute';

export default class DropCandidateFields extends LightningElement {

    @track textinput = true;
    @track allvalue = [];
    @api existingvalues;
    @api colamsize = "";
    picklistValue = 'inProgress';
    showTextFieldArea = false;
    fieldLabelValue;
    helpTextValue;
    @api indexVal;
    requiredVal = false;
    showSubmit = false;
    @track candidateSelectedFields = [];
    @api candidateExistingFields;
    showModal = false;
    @api candidateUpdatedValues;
    @api systemUsed;
    @api lastSystemUsed;
    @api candidateAvailableFields;

    connectedCallback() {
        if (this.candidateExistingFields != '' && ((this.systemUsed != this.lastSystemUsed) || this.lastSystemUsed == null)) {
            this.candidateSelectedFields = JSON.parse(JSON.stringify(this.candidateExistingFields));
            this.showSubmit = true;
            this.candidateSelectedFields.forEach(obj => {
                if (obj.Label__c == 'First Name' || obj.Label__c == 'Last Name' || obj.Label__c == 'Email' || obj.Label__c == 'Category') {
                    if (!obj.hasOwnProperty("hideDelete")) {
                        obj["hideDelete"] = true;
                    } else {
                        obj.hideDelete = true;
                    }
                } else {
                    if (!obj.hasOwnProperty("hideDelete")) {
                        obj["hideDelete"] = false;
                    } else {
                        obj.hideDelete = false;
                    }
                }
            });
        }
        else if ((this.candidateUpdatedValues != '')
            && (this.systemUsed == this.lastSystemUsed)) {
            this.candidateSelectedFields = JSON.parse(JSON.stringify(this.candidateUpdatedValues));
            this.candidateSelectedFields.forEach(obj => {
                if (obj.Label__c == 'First Name' || obj.Label__c == 'Last Name' || obj.Label__c == 'Email' || obj.Label__c == 'Category') {
                    if (!obj.hasOwnProperty("hideDelete")) {
                        obj["hideDelete"] = true;
                    } else {
                        obj.hideDelete = true;
                    }
                } else {
                    if (!obj.hasOwnProperty("hideDelete")) {
                        obj["hideDelete"] = false;
                    } else {
                        obj.hideDelete = false;
                    }
                }
            });
            this.showSubmit = true;
        }

        const submitEvent = new CustomEvent('submit', {
            bubbles: true,
            composed: true,
            detail: { candidateValue: this.candidateSelectedFields }
        });
        // Fire the custom event
        this.dispatchEvent(submitEvent);
    }

    disconnectedCallback() {
        //console.log('Updated values ' + this.candidateSelectedFields);
        const submitEvent = new CustomEvent('disconnect', {
            bubbles: true,
            composed: true,
            detail: { candidateValue: this.candidateSelectedFields }
        });
        // Fire the custom event
        this.dispatchEvent(submitEvent);
    }

    dropElement(event) {
        event.stopPropagation();
        let eventObj = event.dataTransfer.getData("divId")?.split(';');
        let eventData = eventObj[0];
        if (eventData == "") {
            this.textinput = event.dataTransfer.getData("");
        }

        if (eventData != "") {
            this.textinput = true;
            let obj = { Label__c: eventData, Data_Type__c: eventObj[1], Values__c: eventObj[2], API_Name__c: eventObj[3], fieldLabel: eventData, fieldtype: eventObj[1], options: eventObj[2], isnormal: true, istextarea: false, isrichtexarea: false, ispicklist: false, ischeckboxgroup: false, isradiogroup: false };
            if (this.indexVal != undefined) {
                this.indexVal = this.indexVal + 1;
            } else {
                this.indexVal = 1;
            }
            if (!obj.hasOwnProperty("index")) {
                obj["index"] = this.indexVal;
            }
            if (obj.fieldtype == 'Textarea') {
                //console.log('xxxx');
                obj.istextarea = true;
                obj.isnormal = false;
            }
            else if (obj.fieldtype == 'rich text') {
                obj.isrichtexarea = true;
                obj.isnormal = false;
            }
            else if (obj.fieldtype == 'DropDown') {
                obj.ispicklist = true;
                obj.isnormal = false;
                obj.showTextFieldArea = true;
            }
            else if (obj.fieldtype == 'checkboxgroup') {
                obj.ischeckboxgroup = true;
                obj.isnormal = false;
                obj.showTextFieldArea = true;
                obj["value"] = [];
            }
            else if (obj.fieldtype == 'radiogroup') {
                obj.isradiogroup = true;
                obj.isnormal = false;
                obj.showTextFieldArea = true;
            }
            if (obj.Label__c == 'First Name' || obj.Label__c == 'Last Name' || obj.Label__c == 'Email' || obj.Label__c == 'Category') {
                obj["hideDelete"] = true;
            } else {
                obj["hideDelete"] = false;
            }

            obj["isReporting"] = true;
            this.candidateSelectedFields.push(obj);
            //console.log('this.candidateSelectedFields: ', JSON.stringify(this.candidateSelectedFields));

            const submitEvent = new CustomEvent('dropevent', {
                bubbles: true,
                composed: true,
                detail: { candidateValue: this.candidateSelectedFields }
            });
            // Fire the custom event
            this.dispatchEvent(submitEvent);
        }
        if (this.textinput != "" && this.textinput != true) {
            let obj = { fieldtype: this.textinput, isnormal: true, istextarea: false, isrichtexarea: false, ispicklist: false, ischeckboxgroup: false, isradiogroup: false };
            if (this.indexVal != undefined) {
                this.indexVal = this.indexVal + 1;
            }
            else {
                this.indexVal = 1;
            }
            if (obj.fieldtype == 'Textarea') {
                //console.log('xxxx');
                obj.istextarea = true;
                obj.isnormal = false;
                //console.log('ooo', obj.istextarea);
            }
            else if (obj.fieldtype == 'rich text') {
                obj.isrichtexarea = true;
                obj.isnormal = false;
            }
            else if (obj.fieldtype == 'dropdown') {
                obj.ispicklist = true;
                obj.isnormal = false;
                obj.showTextFieldArea = true;
            }
            else if (obj.fieldtype == 'checkboxgroup') {
                obj.ischeckboxgroup = true;
                obj.isnormal = false;
                obj.showTextFieldArea = true;
                obj["value"] = [];
            }
            else if (obj.fieldtype == 'radiogroup') {
                obj.isradiogroup = true;
                obj.isnormal = false;
                obj.showTextFieldArea = true;

            }

            if (!obj.hasOwnProperty("index")) {
                obj["index"] = this.indexVal;
            }

            obj["showEditFields"] = true;
            obj["isReporting"] = true;
            this.candidateSelectedFields.push(obj);

        }
        if (this.showSubmit == false) {
            this.showSubmit = true;
        }
    }

    allowDrop(event) {
        event.preventDefault();
    }

    handleEditIcon(event) {
        if (this.candidateSelectedFields.find(element => element.index == event.target.dataset.index) != undefined) {
            this.candidateSelectedFields.forEach(element => {
                if (element.index == event.target.dataset.index) {
                    if (element.ispicklist || element.ischeckboxgroup || element.isradiogroup) {
                        if (element.hasOwnProperty("showTextFieldArea")) {
                            element.showTextFieldArea = true;
                        }
                        else {
                            element["showTextFieldArea"] = true;
                        }
                    }
                    if (element.hasOwnProperty("showEditFieldsFromEdit")) {
                        element.showEditFieldsFromEdit = true;
                    }
                    else {
                        element["showEditFieldsFromEdit"] = true;
                    }
                    element.showEditFields = true;
                }
            })
        }
    }

    handleMoveUp(event) {
        if (event.target.dataset.index != 0) {
            const currentIndex = event.target.dataset.index;
            const newIndex = currentIndex - 1;
            Array.prototype.move = function (from, to) {
                this.splice(to, 0, this.splice(from, 1)[0]);
            };
            this.candidateSelectedFields.move(parseInt(currentIndex), parseInt(newIndex));
        }
    }

    handleMoveDown(event) {
        const currentIndex = event.target.dataset.index;
        const newIndex = parseInt(currentIndex) + 1;
        Array.prototype.move = function (from, to) {
            this.splice(to, 0, this.splice(from, 1)[0]);
        };
        this.candidateSelectedFields.move(parseInt(currentIndex), parseInt(newIndex));
    }

    submitForm() {
        const submitEvent = new CustomEvent('submit', {
            detail: { candidateValue: this.candidateSelectedFields }
        });
        // Fire the custom event
        this.dispatchEvent(submitEvent);

        let fieldsToCreate = [];
        this.candidateSelectedFields.forEach(element => {
            if (element.hasOwnProperty("fieldtype")) {
                fieldsToCreate.push(element);
            }
        });

        createFormAttribute({
            jsonData: JSON.stringify(fieldsToCreate)
        })
            .then(Response => {
                //console.log('Response: ', JSON.stringify(Response));

            }).catch(error => {
                //console.log('Error is ' + JSON.stringify(error));
            });
    }

    handleToggle(event) {
        let elementToWorkUpon;
        if (event.target.checked == true) {
            elementToWorkUpon = this.candidateSelectedFields.find(element => element.index == event.target.dataset.index);
            this.requiredVal = true;
            elementToWorkUpon.isRequired = true;
        }
        else {
            elementToWorkUpon = this.candidateSelectedFields.find(element => element.index == event.target.dataset.index);
            this.requiredVal = false;
            elementToWorkUpon.isRequired = false;
        }
    }

    handleFieldValues(event) {
        let textAreaName = event.target.name;
        let indexValue = event.target.dataset.index;
        let values;
        let helpTextvalue;
        let fieldLabelValue;
        let flag = false;
        let fieldLabelCmp;

        if (this.template.querySelector(`lightning-textarea[data-name="${textAreaName}"]`) != undefined) {
            let valueCmp = this.template.querySelector(`lightning-textarea[data-name="${textAreaName}"]`);
            values = JSON.stringify(this.template.querySelector(`lightning-textarea[data-name="${textAreaName}"]`).value);
            if (values == undefined) {
                valueCmp.setCustomValidity("Please enter a value");
                flag = true;
            } else {
                valueCmp.setCustomValidity("");
            }
            valueCmp.reportValidity();
        }

        if (this.template.querySelector(`lightning-input[data-helptextname="${textAreaName}"]`) != undefined) {
            helpTextvalue = JSON.stringify(this.template.querySelector(`lightning-input[data-helptextname="${textAreaName}"]`).value);
        }

        if (this.template.querySelector(`lightning-input[data-labelname="${textAreaName}"]`) != undefined) {
            fieldLabelCmp = this.template.querySelector(`lightning-input[data-labelname="${textAreaName}"]`);
            fieldLabelValue = JSON.stringify(this.template.querySelector(`lightning-input[data-labelname="${textAreaName}"]`).value);

            if (JSON.parse(fieldLabelValue) == '') {
                fieldLabelCmp.setCustomValidity("Please enter a value");
                flag = true;
            } else if (JSON.parse(fieldLabelValue) != '' && fieldLabelValue?.match(/^\d/)) {
                fieldLabelCmp.setCustomValidity("First character should be alphabet");
                flag = true;
            }
            else {
                fieldLabelCmp.setCustomValidity("");
            }
            fieldLabelCmp.reportValidity();

            let allCandidateFields = this.candidateAvailableFields.concat(this.candidateExistingFields);
            let fieldLabelWithOutSpaces = fieldLabelValue?.slice(1, -1)?.replace(/\s/g, '');
            allCandidateFields.every(element => {
                if (element.Label__c?.replace(/\s/g, '')?.toUpperCase() == fieldLabelWithOutSpaces?.toUpperCase()) {
                    //Check Duplicate
                    fieldLabelCmp.setCustomValidity("A field already exists with same name");
                    fieldLabelCmp.reportValidity();
                    flag = true;
                    return false;
                } else {
                    fieldLabelCmp.setCustomValidity("");
                }
                return true;
            });
        }

        if (!flag) {
            this.candidateSelectedFields.forEach(element => {
                if (element.index == indexValue) {
                    if (values != undefined) {
                        element.Values = values?.slice(1, -1);
                        let temparray = element.Values?.split(',');
                        element.options = temparray.map(function (eachfield) {
                            return { label: eachfield, value: eachfield }
                        });
                    }
                    if (helpTextvalue != undefined) {
                        element.helpText = helpTextvalue?.slice(1, -1);
                    }
                    if (fieldLabelValue != undefined) {
                        element.fieldLabel = fieldLabelValue?.slice(1, -1);
                        element.Label__c = fieldLabelValue?.slice(1, -1);
                        //element.API_Name__c = fieldLabelValue?.slice(1, -1)?.replace(' ', '_') + '__c';

                        let label = fieldLabelValue;
                        console.log('label: ', label);
                        // Step 1: Replace hyphens and dots with underscore
                        let apiName = label.replace(/[-.]/g, '_');
                        console.log('apiName: ', apiName);
                        // Step 2: Remove all other special characters except underscore and space
                        apiName = apiName.replace(/[^a-zA-Z0-9_ ]/g, '');
                        console.log('apiName: ', apiName);
                        // Step 3: Replace spaces with underscore
                        apiName = apiName.replace(/\s+/g, '_');
                        console.log('apiName: ', apiName);
                        // Step 4: Remove consecutive underscores (optional cleanup)
                        apiName = apiName.replace(/_+/g, '_');
                        console.log('apiName: ', apiName);
                        // Step 5: Trim leading/trailing underscores
                        apiName = apiName.replace(/^_+|_+$/g, '');
                        console.log('apiName: ', apiName);
                        // Step 6: Ensure the name starts with a letter
                        if (!/^[a-zA-Z]/.test(apiName)) {
                            apiName = 'F' + apiName;
                            console.log('apiName: ', apiName);
                        }
                        // Step 7: Truncate to 40 characters max
                        if (apiName.length > 40) {
                            apiName = apiName.substring(0, 40);
                            console.log('apiName: ', apiName);
                        }
                        // Step 8: Append Salesforce custom field suffix
                        element.API_Name__c = apiName + '__c';
                        console.log('element.API_Name__c: ', element.API_Name__c);
                    }
                    //element.fieldInUse = true;
                    element.showTextFieldArea = false;
                    element.showEditFields = false;
                    element.showEditIcon = true;
                    //console.log('After save element --> ', JSON.stringify(element));
                }
            })

            const submitEvent = new CustomEvent('dropevent', {
                bubbles: true,
                composed: true,
                detail: { candidateValue: this.candidateSelectedFields }
            });
            // Fire the custom event
            this.dispatchEvent(submitEvent);
        }
    }

    handleRemoveIcon(event) {
        let indexValue = event.target.dataset.index;
        let deletedItem;
        this.candidateSelectedFields.forEach(element => {
            if (element.index == indexValue) {
                deletedItem = element;
                this.candidateSelectedFields?.splice(this.candidateSelectedFields?.indexOf(element), 1);
            }
        });

        if (this.candidateSelectedFields == "") {
            this.showSubmit = false;
        }
        const submitEvent = new CustomEvent('delete', {
            bubbles: true,
            composed: true,
            detail: { candidateValue: deletedItem }
        });
        // Fire the custom event
        this.dispatchEvent(submitEvent);
    }

    DragOver(event) {
        event.preventDefault();
        return false;
    }

    cancelPreview(event) {
        let indexValue = event.target.dataset.index;
        this.candidateSelectedFields.forEach(element => {
            if (element.index == indexValue) {
                if (element.showEditFieldsFromEdit != true) {
                    this.candidateSelectedFields?.splice(this.candidateSelectedFields?.indexOf(element), 1);
                }
                element.showEditFields = false;
            }
        });
    }

    createField(event) {
        this.handleFieldValues(event);
    }

    handleInputChange(event) {
        let enteredValue = event.target.checked;
        let indexValue = event.target.dataset.index;
        this.candidateSelectedFields.forEach(element => {
            if (element.index == indexValue) {
                element.isReporting = enteredValue;//dekhna hai
            }
        })
    }
}