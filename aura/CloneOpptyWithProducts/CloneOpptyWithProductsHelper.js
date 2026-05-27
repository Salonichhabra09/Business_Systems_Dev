({
    getProducts : function(cmp,helper){
        //alert("Inside getProducts");
        let action = cmp.get("c.getOpportunityLineItems");
        action.setParams({
            opportunityId: cmp.get("v.recordId")	
        });
        
        action.setCallback( this, function( response ) { 
            let state = response.getState();
            //alert("State is "+state);
            console.log(state);
            if (state === "SUCCESS") {
                console.log( response.getReturnValue() );
                //alert("Products are taken");
                cmp.set( "v.lstLineItems", response.getReturnValue() );
                helper.addProducts(cmp,helper);
            }
            else if (state === "INCOMPLETE") {
                
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
                    }
                }
        } );
        
        $A.enqueueAction(action);    
    },
    addProducts : function(cmp,helper){
        //alert("Inside AddProducts");
        let action = cmp.get("c.cloneOpportunityWithProducts");
        action.setParams({
            opportunityId: cmp.get("v.recordId"),
            lstLineItems: cmp.get("v.lstLineItems")
        });
        
        action.setCallback( this, function( response ) {
            
            let state = response.getState(); 
            //alert("state is"+state);
            if (state === "SUCCESS") {
                //alert("Inside success"+response.getReturnValue());
                //alert("Products are added");
                helper.navigateToRecord( response.getReturnValue() );
            }
            else if (state === "INCOMPLETE") {
                alert(' ERROR : Unable to create the opportunity.');    
            }
                else if (state === "ERROR") {
                    var errorMsg = action.getError()[0].message;
                    var mySubString = errorMsg.substring(
                        errorMsg.lastIndexOf("first error:")+12, 
                        errorMsg.lastIndexOf(": [")
                    );       
                    alert(mySubString);
                    
                }
            
        } );
        
        $A.enqueueAction(action);
        
    },
    navigateToRecord : function( recordId ) {
        /* var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();*/
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();	
        
    },
})