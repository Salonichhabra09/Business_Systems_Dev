({
	showMessage : function(component, event, helper, obj, recId) {
		var action = component.get("c.existEOFProducts");
       	action.setParams({
            "recordId": recId,
            "objectName": obj
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                component.set('v.showMessage', response.getReturnValue());
                console.log(response.getReturnValue());
            } else {
                 component.set('v.showMessage', false);
            }
        });
        $A.enqueueAction(action);
	}
})