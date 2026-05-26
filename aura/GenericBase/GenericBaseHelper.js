({
    /*
     * This method will call the server side action and will execute callback method
     * it will also show error if generated any
     * @param component (required) - Calling component
     * @param method (required) - Server side methos name
     * @param callback (required) - Callback function to be executed on server response
     * @param params (optional) - parameter values to pass to server
     * @param setStorable(optional) - if true, action response will be stored in cache
     * */
    callServer : function(component, method,recordId, callback) {
        var action = component.get(method);
        //alert("inside Callserver");
        //Set params if any
        if (recordId) {
            //alert("this is new" +recordId);
            
            action.setParams({
                recordId: recordId,
            });
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            //alert("This is new" +state);
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());
                //var opp = response.getReturnValue();
            } else 
                
                if (state=="ERROR") {
                var errorMsg = action.getError()[0].message;
                   // errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': [');
                    var mySubString = errorMsg.substring(
                        errorMsg.lastIndexOf("FIELD_CUSTOM_VALIDATION_EXCEPTION,")+34, 
                        errorMsg.lastIndexOf(": [")
                    );
                    
                alert(errorMsg);
                /*var error = "Error";
                $A.createComponent(
                    "c:ErrorComponent",
                    {
                      "errorMsg": errorMsg,
                        "title" : error
                     },
                    function(errComponent){
                        if (component.isValid()) {
                            var targetComp = component.find("errorDialogPlaceholder");
                            var body = component.get("v.body");
                            body.push(errComponent);
                            component.set("v.body", body);             
                        }
                    }            
                );*/
            }
        });
        
        $A.enqueueAction(action);
    },
    
    /*
     * This function displays toast based on the parameter values passed to it
     * */
    showToast : function(params) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            if(!params){
                toastEvent.setParams({
                    "title": "TOAST ERROR!",
                    "type": "error",
                    "message": "Toast Param not defined"
                });
                toastEvent.fire();
            } else{
                toastEvent.setParams(params);
                toastEvent.fire();
            }
        } else{
            alert(params.message);
        }
    },
})