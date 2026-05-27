({
	doInit : function(component, event, helper) {
        let recordId = component.get("v.recordId");
         var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
        "recordId": recordId,
    });
    navEvt.fire();
	}
})