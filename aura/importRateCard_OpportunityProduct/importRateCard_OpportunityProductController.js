({
    doInit : function(component, event, helper) {
        //alert("Hello");
        var oid = component.get("v.opportunityId");
        //alert(oid);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/apex/ImportRateCard_VF?oppId=' + oid 
        });
        urlEvent.fire();
        
    }
})