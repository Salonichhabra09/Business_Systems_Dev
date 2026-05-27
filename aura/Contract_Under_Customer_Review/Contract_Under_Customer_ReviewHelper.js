({
	handleInit : function(component, event, helper) {
		var action = component.get("c.contractStatusUpdate");
        action.setParams({"recId": component.get("v.recordId")});
        action.setCallback(component, function(response) {
            var state = response.getReturnValue();
            if (state === 'UPDATED'){
                $A.get('e.force:refreshView').fire();
                component.find('notify').showToast({
                        "variant": "success",
                        "title": "Success",
                        "message": "Contract is marked as 'Under customer Review'."
                });
                
            } else if (state === 'NOT UPDATED'){
                component.find('notify').showToast({
                        "variant": "information",
                        "title": "Information",
                        "message": "Contract is already 'Under Customer Review'."
                });
            } else{
                component.find('notify').showToast({
                        "variant": "error",
                        "title": "Error",
                        "message": state
                });
            }
            $A.get("e.force:closeQuickAction").fire();
        }
        );
        $A.enqueueAction(action);

	}
})