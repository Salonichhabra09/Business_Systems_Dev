({
    closeModal : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    fetchrec: function(component, event, helper) {
        //var windowRedirect =window.location.href;
        //var windowRedirect= '%2F006%2Fo';
        //component.set("v.locn", windowRedirect); 
        //alert('zx');
        
        var device = $A.get("$Browser.formFactor");
        // alert("You are using a " + device);
        if(device != 'DESKTOP')
        {
            
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "Opportunity"
            });
            homeEvent.fire();                    
            
        }
        else{
            helper.fetchrech(component,event,helper);
        }
        
        
    },
    navigate : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        var rectype = component.find("levels").get("v.value");
        //alert("this is rectype"+ rectype);
        if(rectype === 'Select'){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": 'You did not select any record Type!',
                "type": "Error"
            });
            toastEvent.fire();
            return;
        }
        
        if(component.get("v.sobjecttype") === "Account"){   
            
            helper.accdata(component,event,helper);
            //var action = component.get("c.getAccList");
            
            //action.setParams({
            //   Id : component.get("v.recordId")            
            //}); 
            //action.setCallback(this, function(response) {
            //var state = response.getState();
            //if (state === "SUCCESS") {
            
            
            
            //}
            // });
            //alert("Currency==>"+accName.CurrencyIsoCode);      
            
            
            
            
        }//if
        else if(component.get("v.sobjecttype") === "Contact") {
            
            helper.contdata(component,event,helper);
            
            
            
            
            
        }//ifofcontact  
        
    },
    
    
    
})