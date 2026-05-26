({
   doInit : function (component) {
      var OrdeId=component.get("v.recordId");
       //alert(OrdeId);
      // Create action to find an Order
      var action = component.get("c.getOrder");
      action.setParams({"OrdId":OrdeId});
      // Add callback behavior for when response is received
      action.setCallback(this, function(response) {
          var state = response.getState();
          //alert('state is'+state);
          
         if (state === "SUCCESS") {
            // Pass the Order data into the component's OderObj attribute 
            component.set("v.OderObj", response.getReturnValue());
            //alert(component.get("v.OderObj")); 
            // Set the Order record (sObject) variable to the value of the component
         }
         else {
            console.log("Failed to Order.");
         }
      });
      
      // Send action to be executed
      $A.enqueueAction(action);
       
      //test Code for Order Product Warning starts here-prabhat
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
      //test Code for Order Product Warning ends here-prabhat
       
      /*var action = component.get("c.CheckInvHeaderWithOrder");
      action.setParams({"OrdId":OrdeId});
      // Add callback behavior for when response is received
      action.setCallback(this, function(response) {
          var state = response.getState();
         if (state === "SUCCESS") {
            // Pass the Order data into the component's OderObj attribute 
            //alert("Returned state is--->"+response.getReturnValue());
             if(response.getReturnValue()){
                component.set("v.InvoiceLinked",true);
             }else{
                 component.set("v.InvoiceLinked",false);
             }
                
            }
         else {
            console.log("Failed to get account date.");
         }
      });
      
      // Send action to be executed
      $A.enqueueAction(action); */
   },
    
    callFlow : function(component, event, helper) {
        //alert("Inside Call Flow");
        var flow = component.find("InvoiceHeaderFlowId");
        var inputVariables = [
             {
                name : "OrderInputVariable",
                type : "SObject",
                value: component.get("v.OderObj")
             }
           ];
        
        flow.startFlow("CreateInvoiceHeaderWithLines", inputVariables);
        let button = event.getSource();
    	button.set('v.disabled',true);

    },
   
   OnStatusChange : function (component, event) {
   	if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
        var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Success",
        "message": "Invoice Header record has been created successfully.",
        mode: 'dismissible',
        type: 'success'
    });
    toastEvent.fire();
    $A.get('e.force:refreshView').fire();
        
    }
   }
})