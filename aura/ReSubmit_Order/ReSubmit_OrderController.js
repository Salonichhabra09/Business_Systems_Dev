({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.getOrders");       
        action.setParams({
            recordId: component.get("v.recordId"),
        });
        action.setCallback(this, function(data){
            
            component.set("v.RejectedOrders",data.getReturnValue());
        });       
        
        $A.enqueueAction(action);
        
        var actionforUserVerification = component.get("c.UserVerification");
        actionforUserVerification.setParams({
            recordId: component.get("v.recordId"),
        });
        actionforUserVerification.setCallback(this, function(data){
            
            component.set("v.UserIsValid",data.getReturnValue());
        });       
        
        $A.enqueueAction(actionforUserVerification);
        
    },
    
    callFlow : function(component, event, helper) {
        if(component.get("v.UserIsValid"))
        { 
            if(component.get("v.simplerecord.StageName")=='Verbal')
            {
            component.set("v.disable",true);
            //Find lightning flow from component
            var action = component.get("c.UpdateAllowClosed");       
            action.setParams({
                recordId: component.get("v.recordId"),
            });
            action.setCallback(this, function(data){
                var flow = component.find("ResubmitOrderFlow");
                var RejectedIDs = component.get("v.simplerecord.Rejected_Order_IDs__c");
                var LoopCount=0;
                for(var i=1;i<6;i++)
                {
                    if(RejectedIDs.length==(18*i)+(i-1))
                    {
                        LoopCount=i;
                        break;
                    }
                }
                var start=0;
                var RejectedIdsList = [];
                
                for(var k=1;k<=LoopCount;k++)
                {
                    var ID = RejectedIDs.substring(start, start+18);
                    RejectedIdsList.push(ID);
                    start=start+19; 
                }
                
                
                //Put input variable values
                var inputVariables = [
                    {
                        name : "recordId",
                        type : "String",
                        value : component.get("v.recordId")
                    },
                    {
                        name : "RejectedOrderIDs",
                        type : "String",
                        value : RejectedIdsList
                    }
                ];
                //Reference flow's Unique Name
                //alert('This is list of order ids '+RejectedIdsList);
                if(component.get("v.simplerecord.RecordType.Name") =='GCSC Opportunity')
                {
                   flow.startFlow("Re_Submit_Order_GCSC", inputVariables);  
                }
                else
                {
                  flow.startFlow("Re_Submit_Order_Full_Functionality", inputVariables);   
                }
                
                
            });       
            
            $A.enqueueAction(action);
            
        }
             else{
             var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: "Opportunity should be on Verbal Stage to Resbumit the Order. Please move opportunity to Verbal and Try Again.",
                        type: "error"
                    });
                    toastEvent.fire();
        }
        }
       
    else
    {
    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: "You do not have permission to submit an Order. Only Order Owner, Order Creator, Opps Lead & OATs are allow to submit an Order.",
                        type: "error"
                    });
                    toastEvent.fire();
} 
},
 //this function handle close button on modal 
 handleClose : function(component, event, helper) {
    //$A.get("e.force:closeQuickAction").fire();
    component.set("v.disable",false);
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
        },
            
            //Flow Status Change
            statusChange : function (component, event, helper) {
                //Check Flow Status
                if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        message: "Order Submitted Successfully!",
                        type: "success"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                } else if (event.getParam('status') === "ERROR") {
                    component.set("v.hasError", true);
                }
            }
})