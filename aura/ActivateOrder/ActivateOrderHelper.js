({
    ActivateOrder: function(component, event, helper) {
        var record = component.get('v.Order');
        record.Status = 'Activated';
        record.Oats_Status__c = 'Completed';
        component.find("DataLoader").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS") {
                var message = 'Order is Activated Successfully';
                var title = 'Success';
                helper.showToast(component, event, helper , message, title );
            }  
            else if (saveResult.state === "ERROR"){
                debugger;
                console.log(saveResult.error);
                var message = saveResult.error[0].message;
                var title = 'Error';
                helper.showToast(component, event, helper , message, title );
            }
        }));
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    showToast : function(component, event, helper , message, title ) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : title,
            "duration" : 12000
        });
        toastEvent.fire();
    }
})