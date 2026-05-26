({
    clonepage: function(cmp, event, helper) {
        
        //alert("Product count is "+cmp.get("v.simplerecord.Total_Product_Count__c"));
        if(cmp.get("v.simplerecord.Total_Product_Count__c")==0)
        {
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": 'There are no product(s) added to this opportunity. Please use the "Clone" button if there are no product(s).',
                "type": "Error"
            })
            toastEvent.fire();
            return;
        }
        else{
            helper.getProducts(cmp,helper); 
        }
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
    
})