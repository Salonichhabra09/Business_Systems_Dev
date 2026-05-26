({
    validateCourse : function(component, event, helper) {
        var action = component.get("c.updateQualifications");
        action.setParams({
            courseId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            var result = response.getReturnValue();
            var toastEvent = $A.get("e.force:showToast");
  			console.log('state', state);
            console.log('state', result);
            if(state === "SUCCESS"){
                if(result==''){
                    toastEvent.setParams({
                        type: 'success',
                        "title": "success",
                        duration:' 5000',
                        "message": "Qualifications have been Updated successfully."
                    });
                } else if(result=="0") {
                    toastEvent.setParams({
                        type: 'info',
                        "title": "Info",
                        duration:' 5000',
                        //"message" : result
                        "message": "Sorry! Qualifications can't be updated as there are no passed Confirmed Bookings for this Course."
                    });
                } else{
                    toastEvent.setParams({
                        type: 'error',
                        "title": "Error",
                        duration:' 5000',
                        "message" : result
                        //"message": "Sorry! Qualifications can't be updated as there are no passed Confirmed Bookings for this Course."
                    });
                }
            } else if(state === "Error"){
                	toastEvent.setParams({
                        type: 'Error',
                        "title": "Error",
                        duration:' 5000',
                        "message": "Qualifications have not been Updated successfully. Error: " + response.getReturnValue()
                    });    
  					
            }

            toastEvent.fire();
          	$A.get("e.force:closeQuickAction").fire();
          	$A.get('e.force:refreshView').fire();
        });
       	$A.enqueueAction(action);
    }
    
})