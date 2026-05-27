({
    navigatetoNewExpense: function(component, event, helper) {
        component.set("v.recordId", component.get("v.pageReference").state.c__id);
        var action = component.get("c.fetchUser");
  
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
         //   alert(response.getState());  
            if (state === "SUCCESS") {
                //set response value in wrapperList attribute on component.
                component.set('v.UserCurrency', response.getReturnValue());
 			

           //   alert(component.get('v.UserCurrency'));
            

                
                var urlEvent = $A.get("e.force:navigateToURL");
                
                urlEvent.setParams({
                    "url":
                    "/lightning/o/Expense__c/new?useRecordTypeCheck=1&defaultFieldValues=Project__c="+component.get("v.recordId")+
                    ",Resource_s_Home_Currency__c="+component.get("v.UserCurrency")
                });
                urlEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
        
        
        
        
    }
    
    
});