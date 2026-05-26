({
    validateEndCourse : function(component, event, helper) {
        var action = component.get("c.endCourse");
        action.setParams({
            courseId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("State "+state);
            var result=response.getReturnValue();
            console.log('Data--> '+response.getReturnValue());
            if(state === "SUCCESS"){
                //var result = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if(result=='SUCCESS'){
                    toastEvent.setParams({
                        type: 'success',
                        "title": "Success!",
                        duration:' 5000',
                        "message": "Course status updated successfully."
                    });
                    //component.set("v.message","Course status updated successfully");
                   console.log('response.getReturnValue()-->result '+result);
                }else if(result=='End_Course_cannot_be_Completed'){
                    toastEvent.setParams({
                        type: 'info',
                        "title": "Info",
                        duration:' 5000',
                        "message": "End Course cannot be used as the Course Status is already 'Completed'."
                    });
                    //component.set("v.message","End Course cannot be used as the Course Status is already 'Completed'");
                    console.log('response.getReturnValue()--> else'+result);
                }else if(result=='Course_cannot_be_Ended'){
                    toastEvent.setParams({
                        type: 'info',
                        "title": "Info",
                        duration:' 5000',
                        "message": "Sorry! You are not allowed to end this course."
                    });
                    //component.set("v.message","Sorry! You are not allowed to end this course.");
                } else if(result == 'NO_CONFIRMED_COURSE_BOOKINGS'){
                    toastEvent.setParams({
                        type: 'info',
                        "title": "Info",
                        duration:' 5000',
                        "message": "Sorry! There are no Confirmed Bookings for this course."
                    });
                    //component.set("v.message","Sorry! There are no Confirmed Bookings for this course.");
                }else{
                    toastEvent.setParams({
                        type: 'Error',
                        "title": "Error",
                        duration:' 5000',
                        "message": result
                    });
                    //component.set("v.message",result);
                }
                if(state === "Error"){
                    toastEvent.setParams({
                        type: 'Error',
                        "title": "Error",
                        duration:' 5000',
                        "message": response.getReturnValue()
                    });
                     //component.set("v.message","" + response.getReturnValue());
                }
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
                console.log('response.getReturnValue()-->'+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})