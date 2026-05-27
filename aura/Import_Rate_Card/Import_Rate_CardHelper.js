({
    
    CallServer : function (component,csv){
        //alert('Content of file ' + csv);
        var action;
        //alert("filetype is "+component.get("v.filetype"));
        if(component.get("v.filetype")=="file")
            action = component.get("c.ReadFileOppLineItems");
        else
            action = component.get("c.ReadFileDiscountSum");
        //alert('@@@ Server Action' + action);  
        //alert('Record Id is: '+ component.get("v.recordId"));
        action.setParams({
            "OpptID" : component.get("v.recordId"),"file" : csv
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {  
                //alert("Accounts Inserted Succesfully");  
                //alert(response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                if(response.getReturnValue()=="Pricebook Items imported successfully" || response.getReturnValue()=='Discount Summary Records imported successfully')
                {
                    toastEvent.setParams({
                        "message": response.getReturnValue(),
                        "type": "Success"
                    })
                    toastEvent.fire();
                    return;
                }
                else
                {
                    toastEvent.setParams({
                        "mode": 'dismissible',
                        "message": response.getReturnValue(),
                        "type": "Error"
                    })
                    toastEvent.fire();
                    return;
                }
                
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    alert('Unknown');
                }
            }
        }); 
        
        $A.enqueueAction(action);    
        
    }
})