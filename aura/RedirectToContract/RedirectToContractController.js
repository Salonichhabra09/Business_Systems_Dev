({
	init : function(component, event, helper) {
        
        var objName = component.get("v.objectName");
        if(objName){
            var message = objName + ' has been created.';
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Success',
                message: message,
                duration:' 5000',
                key: 'info_alt',
                type: 'success',
                mode: 'dismissible'
            });
            toastEvent.fire();
            
        }
            
        var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
		  "recordId": component.get("v.recId"),
		  "slideDevName": "related"
		});
		navEvt.fire(); 
		
	}
})