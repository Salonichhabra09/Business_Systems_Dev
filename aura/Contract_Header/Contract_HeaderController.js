({
    callFlow : function(component, event, helper) {
        component.set("v.disable",true);
        //Find lightning flow from component
        var flow = component.find("CreateContractFlow");
        //Put input variable values
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        //Reference flow's Unique Name
        flow.startFlow("Create_Contract_From_Opportunity_Button", inputVariables);
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
                message: "Contract Created successfully!",
                type: "success"
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        } else if (event.getParam('status') === "ERROR") {
            component.set("v.hasError", true);
        }
    }
})