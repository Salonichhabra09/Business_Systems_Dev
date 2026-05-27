({
    getAPINamesMap: function(fields) {
        var values = {};
        fields.forEach(function(field) {
            values[field.label] = field.name;
        });
        return values;
    },
    catchDependent: function(component, event, helper){
        helper.getBtnIdfrmServer(component, event, helper);
        helper.DisableDisclaimer(component,event,helper);
    },
    
    onInit: function(component, event, helper) {
        //for Custom Enq type fields
        var Cndlst=[];
        var Clnlst=[];
        var CS=$A.get("$Label.c.Kb_Case_Client_Query_Type_PB");
        var TS=$A.get("$Label.c.Kb_Case_Client_Query_Type_TQ");
        /* Uncomment this to stop Enq Typ Value Transalation & 
         * comment above two lines
         var CS='Product, billing or ordering query';
         var TS='Technology related questions or issue';
       */
        Clnlst.push(CS);
        Clnlst.push(TS);
        Cndlst.push(TS);
        Cndlst.push(CS);
        
        //Logic to Check for Candidate/Client Page
        var url=window.location.href;
        var chkCnd =url.includes("candidate");
        var chkClnt=url.includes("client");
        if(chkCnd==true){
            component.set("v.cndtPg",false);
            component.set("v.EnqTypoptions",Cndlst);
        }else{
            component.set("v.cndtPg",true);
        }
        if(chkClnt==true){
            component.set("v.clntPg",false);
            component.set("v.EnqTypoptions",Clnlst);
        }else{
            component.set("v.clntPg",true);
        }
        
        //logic for dependent fields start here
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);
        //dependent field logic ends here
        
        // Get prechat fields defined in setup using the prechatAPI component.
        var prechatFields = component.find("prechatAPI").getPrechatFields();
        //var prechatstngs = component.find("settingsAPI").getLiveAgentSettings();
        
        // Get prechat field types and attributes to be rendered.
        var prechatFieldComponentsArray = helper.getPrechatFieldAttributesArray(prechatFields);
        // Make asynchronous Aura call to create prechat field components.
        $A.createComponents(
            prechatFieldComponentsArray,
            function(components, status, errorMessage) {
                if(status === "SUCCESS") {
                    component.set("v.prechatFieldComponents", components);
                }
            }
        );
    },
    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
        var cnt=component.find("countryfld").get("v.value");
        component.set("v.PrChtCountry",cnt);
        helper.getCountryCode(component,event,helper);
        helper.getBtnIdfrmServer(component,event,helper);
        helper.DisableDisclaimer(component,event,helper);
    },
    
    handleStartButtonClick: function(component, event, helper) {
        helper.ValidationCheck(component,event,helper);
        var Fn=component.get("v.fieldChk1");
        var Ln=component.get("v.fieldChk2");
        var Em=component.get("v.fieldChk3");
        var AlertLabel2 = $A.get("$Label.c.PreChatAlert_StartChat");
       // alert("Inside start button click");
        if(!(Fn && Ln && Em)){
            //alert("Please Provide all required info. to Start the Chat");
            alert(AlertLabel2);
            helper.DisableDisclaimer(component,event,helper);
            return;
        }
        else{
            //alert("Inside start button click else");
            helper.onStartButtonClick(component);
        }       
    },
    enquiryOnChange: function(component,event,helper){
        helper.enquiryChangeHelper(component,event,helper);
        helper.DisableDisclaimer(component,event,helper);
    },
    catchChkBox: function(component, event, helper) {
        component.set("v.dataProtectn",true);
        var et=component.find("EnqId").get("v.value");
        component.set("v.EnqType",et);
        helper.ValidationCheck(component,event,helper);
        helper.getBtnIdfrmServer(component,event,helper);
        var Fn=component.get("v.fieldChk1");
        var Ln=component.get("v.fieldChk2");
        var Em=component.get("v.fieldChk3");
        var cnt=component.find("countryfld").get("v.value");
        var lng=component.find("dependentFld").get("v.value");
        var dtprt=component.get("v.dataProtectn");
        var AlertLabel1 = $A.get("$Label.c.PreChatAlert_Validation");
        if(!dtprt)
            helper.DisableDisclaimer(component,event,helper);
        else{
            if(!(Fn && Ln && Em) || (cnt=='--- None ---'|| cnt=='')||(lng=='--- None ---'|| lng=='')){
                //alert("Please provide valid First Name, Last Name, E-mail, Country & Preferred Language.");
                alert(AlertLabel1);
                helper.DisableDisclaimer(component,event,helper);
                $A.util.removeClass(cmpTarget, 'ChngCol');
                
            }else{
                var cmpTarget = component.find('ProofDisclaimer');
                $A.util.addClass(cmpTarget, 'ChngCol');
            }
        }
    }
    
})