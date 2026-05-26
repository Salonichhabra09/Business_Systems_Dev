({
	doInit : function (component) {
      var OrdeId=component.get("v.recordId");
       //alert(OrdeId);
      // Create action to Check info on Order Products
      var action = component.get("c.ChkOrderProd");
      action.setParams({"OrdId":OrdeId});
      // Add callback behavior for when response is received
      action.setCallback(this, function(response) {
          var state = response.getState();
          //alert('state is'+state);
          
         if (state === "SUCCESS") {
            // Pass the Order data into the component's OderObj attribute 
            //component.set("v.OderObj", response.getReturnValue());
            //alert('Inside Success'); 
            // Set the Order record (sObject) variable to the value of the component
         }
         else {
            console.log("Failed to Order.");
         }
      });
      
      // Send action to be executed
      $A.enqueueAction(action);
    }
})