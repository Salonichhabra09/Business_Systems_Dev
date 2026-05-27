({
	updateOrder : function(c,e,h) {
          var spinner = c.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
		var save_action = c.get("c.updateBillToContact");
    	save_action.setParams({
             OrderId : c.get("v.recordId"),
             SelectedContactId : c.get("v.selectedId")
            });
         save_action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               $A.util.toggleClass(spinner, "slds-hide");
             c.find('notifLib').showToast({
            "title": "Record updated!",
            "message": "The record has been updated successfully.",
            "variant": "success"
        });
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                 $A.util.toggleClass(spinner, "slds-hide");
                alert('No response from server or client is offline.');
            }
            else if (state === "ERROR") {
                $A.util.toggleClass(spinner, "slds-hide");
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
        $A.enqueueAction(save_action);
	}
})