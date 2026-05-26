({
    
    doInit : function(component, event, helper) {
        
        var action = component.get("c.fetchOrderAndInvoice");    
        var CourseBookingId = component.get("v.recordId");
        
        action.setParams({
            "CourseBookingId":CourseBookingId
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            var response1=response.getReturnValue();
            
            if(state==="SUCCESS")
            {
                component.set("v.OrderRecord",response1);
                if(response1.Invoice_Headers__r !=null){
                    var invoiceData = JSON.stringify(response1.Invoice_Headers__r);
                    var invoiceHeader=JSON.parse(invoiceData);
                    
                    component.set("v.InvoiceHeader",invoiceHeader[0]); 
                }
                
                
            }
        });
        // Queue this action to send to the server
        $A.enqueueAction(action);
        
    }
})