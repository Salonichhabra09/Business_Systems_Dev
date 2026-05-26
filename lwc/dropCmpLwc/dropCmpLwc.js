import { LightningElement, track, api } from 'lwc';
export default class DropCmpLwc extends LightningElement {

    @track textinput = true;
    @track allvalue = [];
    @api existingvalues;
    @api updatedvalues = null;
    @api colamsize = "";
    picklistValue = 'inProgress';
    showTextFieldArea = false;
    @api systemValueChanged;
    fieldLabelValue;
    helpTextValue;
    @api indexVal;
    requiredVal = false;
    showSubmit = false;


    connectedCallback() {
        //console.log("Existing fields in drop cmp " + this.existingvalues);
        //console.log("Updated values " + this.updatedvalues);
        //console.log("System value changed " + this.systemValueChanged);
        if (this.existingvalues != undefined && this.systemValueChanged) {
            //console.log('Inside iF');
            this.allvalue = JSON.parse(JSON.stringify(this.existingvalues));
            this.showSubmit = true;
        }
        else if (this.updatedvalues != null && !this.systemValueChanged) {
            //console.log('Inside elsif ');
            this.allvalue = JSON.parse(JSON.stringify(this.updatedvalues));
            if (this.updatedvalues == '') {
                this.showSubmit = false;
            }
            else {
                this.showSubmit = true;
            }
        }
        //console.log('Connected Callback this.allvalue --> ', JSON.stringify(this.allvalue));

        const submitEvent = new CustomEvent('submit', {
            detail: this.allvalue
        });
        // Fire the custom event
        this.dispatchEvent(submitEvent);
    }

    disconnectedCallback() {
        //console.log('Updated values ' + this.allvalue);
        const submitEvent = new CustomEvent('disconnect', {
            detail: this.allvalue
        });
        // Fire the custom event
        this.dispatchEvent(submitEvent);
    }
    dropElement(event) {
        event.stopPropagation();
        this.textinput = event.dataTransfer.getData("");
        //console.log("Field Drop event " + this.textinput);
        if (this.textinput != "") {
            let obj = { fieldtype: this.textinput, isnormal: true, istextarea: false, isrichtexarea: false, ispicklist: false, ischeckboxgroup: false, isradiogroup: false, issection: false };
            //obj["fieldLabel"] = this.textinput;
            //console.log("Index from parent " + this.indexVal);
            if (this.textinput == 'date') {
                obj["cssClass"] = 'date-overflow';
            }
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
            else if (obj.fieldtype == 'section') {
                obj.issection = true;
                obj.isnormal = false;
                obj.value = 'Section Name';
            }

            if (!obj.hasOwnProperty("index")) {
                obj["index"] = this.indexVal;
            }

            obj.showEditFields = true;

            this.allvalue.push(obj);
            if (this.showSubmit == false) {
                this.showSubmit = true;
            }

            //console.log('getData', event.dataTransfer.getData(""));
            //console.log('this.allvalue  ===', JSON.stringify(this.allvalue));
            //console.log('this.obj  ===', obj.fieldtype);

        }
    }

    allowDrop(event) {
        //console.log('allow', event);
        event.preventDefault();
    }

    submitForm() {
        //console.log('SubmitForm this.allvalue --> ', JSON.stringify(this.allvalue));
        const submitEvent = new CustomEvent('submit', {
            detail: this.allvalue
        });
        // Fire the custom event
        this.dispatchEvent(submitEvent);
        //console.log("Event value " + JSON.stringify(submitEvent.detail));
    }

    handleEditIcon(event) {
        //console.log('event: ', JSON.stringify(event.target));

        //console.log('Button icon name ' + event.target.name);
        //console.log('Button icon index ' + event.target.dataset.index);

        if (this.allvalue.find(element => element.index == event.target.dataset.index) != undefined) {
            this.allvalue.forEach(element => {
                if (element.index == event.target.dataset.index) {
                    if (element.ispicklist || element.ischeckboxgroup || element.isradiogroup) {
                        if (element.hasOwnProperty("showTextFieldArea")) {
                            element.showTextFieldArea = true;
                        }
                        else {
                            element["showTextFieldArea"] = true;
                        }
                    }
                    if (element.hasOwnProperty("showHelpTextArea")) {
                        element.showHelpTextArea = true;
                    }
                    else {
                        element["showHelpTextArea"] = true;
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

        //console.log('After Edit button this.allvalue --> ', JSON.stringify(this.allvalue));
    }

    handleToggle(event) {
        //console.log('Toggle Name ' + event.target.name);
        //console.log('Toggle Value ' + event.target.checked);
        let elementToWorkUpon;
        if (event.target.checked == true) {
            elementToWorkUpon = this.allvalue.find(element => element.index == event.target.dataset.index);
            //elementToWorkUpon["isRequired"] = true;
            this.requiredVal = true;
        }
        else {
            elementToWorkUpon = this.allvalue.find(element => element.index == event.target.dataset.index);
            //elementToWorkUpon.isRequired = false;
            this.requiredVal = false;
        }

        //console.log('After toggle this.allvalue --> ', JSON.stringify(this.allvalue));

    }

    handleFieldValues(event) {
        //console.log('Button icon name ' + event.target.name);
        let textAreaName = event.target.name;
        let indexValue = event.target.dataset.index;
        //console.log('Text area name to search 1 ' + textAreaName);
        let values;
        let helpTextvalue;
        let fieldLabelValue;
        let toggleValue;
        let flag = false;
        if (this.template.querySelector(`lightning-textarea[data-name="${textAreaName}"]`) != undefined) {
            //console.log("Text Area Name " + JSON.stringify(this.template.querySelector(`lightning-textarea[data-name="${textAreaName}"]`).value));
            let valueCmp = this.template.querySelector(`lightning-textarea[data-name="${textAreaName}"]`);
            values = JSON.stringify(this.template.querySelector(`lightning-textarea[data-name="${textAreaName}"]`).value);
            //console.log('values: ', values);
            if (values == undefined || values == JSON.stringify("")) {
                valueCmp.setCustomValidity("Please enter comma seprated values");
                flag = true;
            } else {
                valueCmp.setCustomValidity("");
            }
            valueCmp.reportValidity();
        }
        if (this.template.querySelector(`lightning-input[data-labelname="${textAreaName}"]`).checkValidity() && !flag) {
            //console.log("flag values: " + flag);
            if (this.allvalue.length == 1) {
                const removeEvent = new CustomEvent('remove', {
                    detail: this.allvalue
                });
                this.dispatchEvent(removeEvent);
            }
            //if (this.showTextFieldArea) {
            if (this.template.querySelector(`lightning-textarea[data-name="${textAreaName}"]`) != undefined) {
                //console.log("Text Area Name " + JSON.stringify(this.template.querySelector(`lightning-textarea[data-name="${textAreaName}"]`).value));
                values = JSON.stringify(this.template.querySelector(`lightning-textarea[data-name="${textAreaName}"]`).value);
                //console.log('values: ', values);
            }
            //}

            if (this.template.querySelector(`lightning-input[data-helptextname="${textAreaName}"]`) != undefined) {
                //console.log("Helptext Name " + JSON.stringify(this.template.querySelector(`lightning-input[data-helptextname="${textAreaName}"]`).value));
                helpTextvalue = JSON.stringify(this.template.querySelector(`lightning-input[data-helptextname="${textAreaName}"]`).value);
                //console.log('Helptext Value ' + helpTextvalue);
            }

            if (this.template.querySelector(`lightning-input[data-labelname="${textAreaName}"]`) != undefined) {
                //console.log("Field Label Name " + JSON.stringify(this.template.querySelector(`lightning-input[data-labelname="${textAreaName}"]`).value));
                fieldLabelValue = JSON.stringify(this.template.querySelector(`lightning-input[data-labelname="${textAreaName}"]`).value);
                //console.log('Field Label Value ' + fieldLabelValue);
            }

            if (this.template.querySelector(`lightning-input[data-togglename="${textAreaName}"]`) != undefined) {
                //console.log("Field toggle Name " + JSON.stringify(this.template.querySelector(`lightning-input[data-togglename="${textAreaName}"]`).value));
                toggleValue = JSON.stringify(this.template.querySelector(`lightning-input[data-togglename="${textAreaName}"]`).checked);
                //console.log('Field toggle Value ' + toggleValue);
            }

            this.allvalue.forEach(element => {
                if (element.index == indexValue) {
                    if (values != undefined) {
                        element.Values__c = values.slice(1, -1);
                        let temparray = element.Values__c.split(',');
                        element.options = temparray.map(function (eachfield) {
                            return { label: eachfield, value: eachfield }
                        });
                    }
                    if (helpTextvalue != undefined) {
                        element.helpText = helpTextvalue.slice(1, -1);
                    }
                    if (fieldLabelValue != undefined) {
                        element.fieldLabel = fieldLabelValue.slice(1, -1);
                    }
                    if (toggleValue != undefined) {
                        if (toggleValue == "false") {
                            element.isRequired = false;
                        }
                        else if (toggleValue == "true") {
                            element.isRequired = true;
                        }

                    }
                    //element.isRequired = this.requiredVal;
                    element.showTextFieldArea = false;
                    element.showEditFields = false;
                    //console.log('After save element --> ', JSON.stringify(element));
                }
            })
            //console.log('After save this.allvalue --> ', JSON.stringify(this.allvalue));
        }


    }

    handleInputChange(event) {
        let enteredValue = event.target.value;
        let indexValue = event.target.dataset.index;
        let fieldtype = event.target.type;
        //console.log("Field Type " + fieldtype);
        //console.log("Checked " + event.target.checked);
        //console.log('Before handleInputChange this.allvalue --> ', JSON.stringify(this.allvalue));
        this.allvalue.forEach(element => {
            if (element.index == indexValue) {
                if (fieldtype == "checkbox") {
                    element.value = event.target.checked;
                }
                else {
                    element.value = enteredValue;
                    if (fieldtype == "radio") {
                        element.value1 = enteredValue;
                    }
                }

            }
        })
        //console.log('After handleInputChange this.allvalue --> ', JSON.stringify(this.allvalue));
    }

    handleRemoveIcon(event) {
        let indexValue = event.target.dataset.index;
        this.allvalue.forEach(element => {
            if (element.index == indexValue) {
                this.allvalue.splice(this.allvalue.indexOf(element), 1);
            }
        });
        if (this.allvalue == "") {
            this.showSubmit = false;
            const removeEvent = new CustomEvent('remove', {
                detail: this.allvalue
            });
            // Fire the custom event
            this.dispatchEvent(removeEvent);

        }
    }

    /*DragStart(event) {
        this.dragStart = event.target.title;
        event.target.classList.add("drag");
      }*/

    DragOver(event) {
        event.preventDefault();
        return false;
    }

    /*  Drop(event) {
        event.stopPropagation();
        const DragValName = this.dragStart;
        const DropValName = event.target.title;
        if (DragValName === DropValName) {
          return false;
        }
        const currentIndex = DragValName;
        const newIndex = DropValName;
        //console.log('current index '+currentIndex);
        //console.log('new index '+DropValName);
        Array.prototype.move = function (from, to) {
            this.splice(to, 0, this.splice(from, 1)[0]);
          };
          this.allvalue.move(parseInt(currentIndex),parseInt(newIndex));
    }*/

    handleMoveUp(event) {
        //console.log("Index " + event.target.dataset.index);
        let index = event.target.dataset.index
        //console.log("Label " + this.template.querySelector(`[data-index="${index}"]`).label);
        if (event.target.dataset.index != 0) {
            const currentIndex = event.target.dataset.index;
            const newIndex = currentIndex - 1;
            //console.log('current index ' + currentIndex);
            //console.log('new index ' + newIndex);
            Array.prototype.move = function (from, to) {
                this.splice(to, 0, this.splice(from, 1)[0]);
            };
            this.allvalue.move(parseInt(currentIndex), parseInt(newIndex));
        }
    }

    handleMoveDown(event) {
        //console.log("Index " + event.target.dataset.index);
        const currentIndex = event.target.dataset.index;
        const newIndex = parseInt(currentIndex) + 1;
        //console.log('current index ' + currentIndex);
        //console.log('new index ' + newIndex);
        Array.prototype.move = function (from, to) {
            this.splice(to, 0, this.splice(from, 1)[0]);
        };
        this.allvalue.move(parseInt(currentIndex), parseInt(newIndex));

    }

    cancelPreview(event) {
        let indexValue = event.target.dataset.index;
        this.allvalue.forEach(element => {
            if (element.index == indexValue) {
                element.showEditFields = false;
                if (element.showEditFieldsFromEdit != true) {
                    this.allvalue.splice(this.allvalue.indexOf(element), 1);
                }

            }
        });
    }


}