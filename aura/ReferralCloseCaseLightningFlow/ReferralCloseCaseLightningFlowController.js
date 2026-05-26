({
    callFlow : function(component, event, helper) {
        component.set("v.disable",true);
        //Find lightning flow from component
        var flow = component.find("Referral_Close_Case_button");
        //Put input variable values
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        //Reference flow's Unique Name
        flow.startFlow("Referral_Close_Case_button", inputVariables);
    },
    //this function handle close button on modal 
    handleClose : function(component, event, helper) {
        //$A.get("e.force:closeQuickAction").fire();
        component.set("v.disable",false);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    //Flow Status Change
    statusChange : function (component, event, helper) {
        //Check Flow Status
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "Referral Case has been closed successfully!",
                type: "success"
            });
            toastEvent.fire();
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
            outputVar = outputVariables[i];
               if(outputVar.name === "ReferralCaseId") {
                   var urlEvent = $A.get("e.force:navigateToSObject");
                    urlEvent.setParams({
                   "recordId": outputVar.value,
                   "isredirect": "true"
                });
                urlEvent.fire();
             }
          } 
                 
        } else if (event.getParam('status') === "ERROR") {
            component.set("v.hasError", true);
        }
    }
})