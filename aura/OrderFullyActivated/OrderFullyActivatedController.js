({    
    //Handle Order update to FullyActivated
    handleOrderUpdate : function(component, event, helper) {
         var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var recordId = component.get("v.recordId");
        var action = component.get("c.updateOrder");
        action.setParams({
            objOrder : recordId
        });
        action.setCallback(this,function(a){
            var state = a.getState();
            if(state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
               		"message": 'Order is successfully marked as Fully Activated',
               		"type": "Success!"
               })
               toastEvent.fire();
               //return;
               //alert('Order is successfully marked as Fully Activated');
               $A.get('e.force:refreshView').fire();
            } 
            else if(state === "ERROR"){
                $A.util.toggleClass(spinner, "slds-hide");
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
            			toastEvent.setParams({
                		"message": errors[0].message,
                		"type": "Error"
            			})
            			toastEvent.fire();
            			return;
                        //alert(errors[0].message);
                    }
                }
            }else if (status === "INCOMPLETE") {
                $A.util.toggleClass(spinner, "slds-hide");
                alert('No response from server or client is offline.');
            }
        });       
        $A.enqueueAction(action);
    }
})