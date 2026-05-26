({
    
    callFlow : function(component, event, helper) {
        component.set("v.disable",true);
        //Find lightning flow from component
        var flow = component.find("NotifyUser");
        //Put input variable values
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
            //Reference flow's Unique Name
        	flow.startFlow("NotifyUserFromCase", inputVariables);
        
    },
    //this function handle close button on modal 
    handleClose : function(component, event, helper) {
        //$A.get("e.force:closeQuickAction").fire();
        component.set("v.disable",false);
    },
    
    
    //Flow Status Change
    statusChange : function (component, event, helper) {
        //Check Flow Status
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "Email has been sent successfully!",
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