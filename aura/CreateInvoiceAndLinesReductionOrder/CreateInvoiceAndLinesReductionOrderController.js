({
   doInit : function (component) {
      var OrdeId=component.get("v.recordId");
      // Create action to find an Order
      var action = component.get("c.getOrder");
      action.setParams({"OrdId":OrdeId});
      // Add callback behavior for when response is received
      action.setCallback(this, function(response) {
          var state = response.getState();
          
          
         if (state === "SUCCESS") {
            // Pass the Order data into the component's OderObj attribute 
            component.set("v.OderObj", response.getReturnValue()); 
            // Set the Order record (sObject) variable to the value of the component

            //Check order type
            let orderRecord = response.getReturnValue();

            //Reduction Orde for GCSC
            if(orderRecord.Reduction_Order__c){
               component.set("v.isReductionOrderForGCSC", true);
            }
            //Reduction Order
            if(orderRecord.Reduction_Order__c &&
               orderRecord.TotalAmount < 0 &&
               (orderRecord.Status != 'Activated' || orderRecord.Status != 'Cancelled') &&
               !orderRecord.Reduction_Order_Invoice_Created__c
            ) {
               console.log('reduction true');
               component.set("v.isReductionOrder", true);
            }

            //Normal/Variation Order
            if((orderRecord.Status == 'In Approval' || orderRecord.Status == 'Service Activated') &&
               orderRecord.Invoice_Header_Count__c == 0 &&
               orderRecord.Reduction_Order__c == false &&
               (orderRecord.TotalAmount > 0 || (orderRecord.Variation_Opportunity__c =='Yes' && orderRecord.Variation_Reason__c =='Debooking'))  &&
               orderRecord.Opportunity.MS_Opportunity__c==false
            ) {
               component.set("v.isNormalOrVariationOrder", true);
            }
            // component.set("v.isNormalOrVariationOrder", true);

            if(orderRecord.Opportunity.MS_Opportunity__c==true && orderRecord.Status == 'In Approval'){
               component.set("v.isGCSCOrder", true);
            }
         }
         else {
            console.log("Failed to Order.");
         }
      });
      
      // Send action to be executed
      $A.enqueueAction(action);
       
      
   },
    
    callFlow : function(component, event, helper) {
        var flow = component.find("InvoiceHeaderFlowId");
        var inputVariables = [
             {
                name : "OrderInputVariable",
                type : "SObject",
                value: component.get("v.OderObj")
             }
           ];
        
        flow.startFlow("CreateInvoiceHeaderAndLinesForReductionOrder", inputVariables);
        let button = event.getSource();
    	button.set('v.disabled',true);

    },

    callGCSCFlow: function(component, event, helper) {
      console.log('Order '+component.get("v.OderObj"));
      var flow = component.find("GCSCInvoiceHeaderFlowId");
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
         component.set("v.showFlow", false);
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