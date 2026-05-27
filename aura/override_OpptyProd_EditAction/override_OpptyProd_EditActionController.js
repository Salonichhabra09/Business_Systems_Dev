({
    save : function(component, event, helper) {   
        try{            
           component.find("recEditId").get("e.recordSave").fire(); 
        }
        catch (e) {
            console.log(e);          
        }
                  
    },
    onSaveSuccess: function(component, event) {     	        
     	var opptyLineId = component.get("v.recordId");
        // Navigate back to the record view
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.recordId') });
        navigateEvent.fire();        
        location.reload();     
	},
    doCancelAction : function(component, event, helper) {
        var OppId = component.get("v.opportunityProductRecord.OpportunityId");
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": OppId });
        navigateEvent.fire();
    },
    
    closeModel : function(component){
        component.find("overlayLib").notifyClose();        
    }
    /*,
    
    doNullCheck: function(component, event, helper) { 
        alert('Iddd ' + component.get("v.recordId"));
        if(component.get("v.recordId") == null){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": 'This record does not exist',
                "type": "Error"
            });
            toastEvent.fire(); 
            return;
            
        }
        else{
           return; 
        }
    }*/
    
})