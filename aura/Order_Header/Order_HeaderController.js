({
    echo : function(component, event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        if(component.get("v.simplerecord.Billing_Contact__c")==null)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": 'Please enter the billing contact to continue',
                "type": "Error"
            })
            toastEvent.fire();
            return;
        }
        if(component.get("v.simplerecord.Account_Number__c")!=null && component.get("v.simplerecord.Account.Status__c")!='Approved')
        {
           
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": 'Opportunities over First Appointment stage can only be saved if the account has a approved status. Please ensure the account is approved.',
                "type": "Error"
            })
            toastEvent.fire();
            return;
        }
        if(component.get("v.simplerecord.Total_Product_Count__c")==0)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": 'Pricebook entry is required if the Opportunity stage is Information Gathering or beyond.',
                "type": "Error"
            })
            toastEvent.fire();
            return;
        }
        
        else
        {
            component.set("v.disable",true);
            helper.createOrderRecord(component, event, helper);
            
        }
    },
    // this function automatic call by aura:waiting event  
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