({
    onStartButtonClick: function(component) {
        //Added by Prabhat for Setting Values from Pre Chat form: section
        var BtId=component.get("v.BtnId");
        var CsCnty=component.get("v.CountryAbrvtd");
        var phn=component.find("PhoneField").get("v.value");
        var cndpg=component.get("v.clntPg");
        var ETy=component.get("v.EnqType");
        var Lng=component.get("v.SlctdLanOnPrCht");
        //alert("This is selected Language on form-"+Lng);
        //alert("This is selected BtnId on form-"+BtId);
        //Added by Prabhat for Setting Values from Pre Chat form
        
        var prechatFieldComponents = component.find("prechatField");
        //alert(prechatFieldComponents);
        var apiNamesMap = this.createAPINamesMap(component.find("prechatAPI").getPrechatFields());
        //alert("this is apiNamesMap-"+JSON.stringify(apiNamesMap));
        var fields;
        //alert('Language helper'+Lng);
        // Make an array of field objects for the library.
        fields = this.createFieldsArray(apiNamesMap, prechatFieldComponents,cndpg,phn,BtId,CsCnty,ETy,Lng);
        //alert("In fields-->"+JSON.stringify(fields));
        if(component.find("prechatAPI").validateFields(fields).valid) {
            component.find("prechatAPI").startChat(fields);
        } else {
            console.warn("Prechat fields did not pass validation!");
        }
    },
    
    createFieldsArray: function(apiNames,fieldcomponents,cndpg,phn,BtId,CsCnty,ETy,Lng) {
        
        if(fieldcomponents.length) {
            return fieldcomponents.map(function(fieldcomponent) {
               	//alert('hi inside array'+fieldcomponent.get("v.label"));
                var label;
                var value;
                var name ;
                if(fieldcomponent.get("v.label")=='Candidate Tel' && cndpg){
                    label = fieldcomponent.get("v.label");
                    value = phn;
                    name = apiNames[fieldcomponent.get("v.label")];
                }
                else if(fieldcomponent.get("v.label")=='Contact Tel' && cndpg==''){
                    label = fieldcomponent.get("v.label");
                    value = phn;
                    name = apiNames[fieldcomponent.get("v.label")];
                }
                    else if(fieldcomponent.get("v.label")=='ButtonId'){
                        label = fieldcomponent.get("v.label");
                        value = BtId;
                        name = apiNames[fieldcomponent.get("v.label")];
                    }else if(fieldcomponent.get("v.label")=='Case Country'){
                        label = fieldcomponent.get("v.label");
                        value = CsCnty;
                        name = apiNames[fieldcomponent.get("v.label")];
                    }else if(fieldcomponent.get("v.label")=='Please select type of enquiry you have'){
                        label = fieldcomponent.get("v.label");
                        value = ETy;
                        name = apiNames[fieldcomponent.get("v.label")];
                    }else if(fieldcomponent.get("v.label")=='Preferred Language'){
                       label = fieldcomponent.get("v.label");
                        value = Lng;
                        name = apiNames[fieldcomponent.get("v.label")];
                        //alert("This is Final Mapped Language on form-"+Lng);
                    }
                        else{
                            //alert("Translation Issue");
                            label = fieldcomponent.get("v.label");
                            value = fieldcomponent.get("v.value");
                            name = apiNames[fieldcomponent.get("v.label")];
                        }
                return {
                    label: label,
                    value: value,
                    name: name
                };
            }.bind(this));
        } else {
            return [];
        }
    },
    createAPINamesMap: function(fields) {
        var values = {};
        fields.forEach(function(field) {
            values[field.label] = field.name;
        });
        return values;
    },
    
    getPrechatFieldAttributesArray: function(prechatFields) {
        var prechatFieldsInfoArray = [];
        // For each field, prepare the type and attributes to pass to $A.createComponents.
        prechatFields.forEach(function(field) {
            var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
            //alert("In component name-->"+componentName);
            var componentInfoArray = ["ui:" + componentName];
            //alert(componentInfoArray);
            var attributes = {
                "aura:id": "prechatField",
                required: field.required,
                label: field.label,
                disabled: field.readOnly,
                maxlength: field.maxLength,
                class: field.className,
                value: field.value
            };
            //alert("In Attributes-->"+JSON.stringify(attributes));
            // Special handling for options for an input:select (picklist) component.
            if(field.type === "inputSelect" && field.picklistOptions)
                attributes.options = field.picklistOptions;
            // Append the attributes Object containing the required attributes to render this prechat field.
            componentInfoArray.push(attributes);
            // Append this componentInfoArray to the fieldAttributesArray.
            prechatFieldsInfoArray.push(componentInfoArray);
        });
        return prechatFieldsInfoArray;
    },
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
        // call the server side function  
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap",StoreResponse);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for lightning:select
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                component.set("v.listControllingValues", ControllerField);
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        
    },
    //Added by Prabhat:To check the required field validations
    ValidationCheck: function(component,event,helper) {
        var prechatFieldComponents = component.find("prechatField");
        var apiNamesMap = this.createAPINamesMap(component.find("prechatAPI").getPrechatFields());
        var fields;
        // Make an array of field objects for the library.
        fields = this.createFieldsArray(apiNamesMap, prechatFieldComponents);
        var f=JSON.stringify(fields);
        //alert(f);
        var j=JSON.parse(f);
        //alert(j);
        if(j[0].value!=''&& j[0].value!=undefined){
            component.set("v.fieldChk1",true);
        }else{
            component.set("v.fieldChk1",false);
        }//alert("inside F1"+component.get("v.fieldChk1"));
        if(j[1].value!=''&& j[1].value!=undefined){
            component.set("v.fieldChk2",true);
        }else{
            component.set("v.fieldChk2",false);
        }//alert("inside F2"+component.get("v.fieldChk2"));
        
        //Added by Prabhat: To check email validation
        var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        
        if (reg.test(j[2].value) == false) 
        {
            component.set("v.fieldChk3",false);
        }else{
            component.set("v.fieldChk3",true);
        }
    },
    //Added by Prabhat: To get the button id return from server call based on parameters sent
    getBtnIdfrmServer: function(component,event,helper) {
        var G=component.find("dependentFld");
        var d=G.get("v.value");
        component.set("v.SlctdLanOnPrCht",d);
        //fetching button id for Pankhuri starts here
        var action = component.get("c.getButtonId");
        action.setParams({ SelctdCountry :component.get("v.PrChtCountry"),
                          Lang:component.get("v.SlctdLanOnPrCht"),
                          Skill:component.get("v.EnqType")                         
                         });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ButtonId=response.getReturnValue();
                component.set("v.BtnId",ButtonId);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    getCountryCode: function(component,event,helper) {
        var action = component.get("c.getCntryAbrvtn_CSet");
        action.setParams({ SelctdCountry :component.get("v.PrChtCountry")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ConAbv=response.getReturnValue();
                component.set("v.CountryAbrvtd",ConAbv);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    //change handler for enquiry type field
    enquiryChangeHelper: function(component,event,helper){
        var ET=component.find("EnqId").get("v.value");
        component.set("v.EnqType",ET);
        helper.getBtnIdfrmServer(component,event,helper);
    },
    //Added by Prabhat:for repeatively disabling the disclaimer text
    DisableDisclaimer: function(component,event,helper){
        component.set("v.dataProtectn", false);
        var cmpTarget = component.find('ProofDisclaimer');
        $A.util.removeClass(cmpTarget, 'ChngCol');
    }
})