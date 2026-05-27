({
    navigateToImportRateCardCmp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Import_Rate_Card" ,
            componentAttributes: {
            recordId : component.get("v.recordId")
            }
        });
        evt.fire();
    } 
})