({
    showToast : function(component, event, helper , message ) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": 'Warning!',
            "message": message,
            "type" : 'warning',
            "duration" : 12000
        });
        toastEvent.fire();
    },
    checkCLMContractValue : function(component, event, helper,url,CLMContractStatus){
       /* if(CLMContractStatus != ''){
            var message = 'There is already an order form in progress for this opportunity. Please check the Contracts and Documents tab to review your existing order form before launching another one.';
            helper.showToast(component, event, helper , message );  
            window.setTimeout($A.getCallback(function() {
                window.open(url, '_blank');
            }), 5000); 
        }else{
            window.open(url, '_blank');
        }*/
         window.open(url, '_blank');
        
    },
    closeTab : function(component, event, helper,recId){
        var workspaceAPI = component.find("workspace");
        //var myPageRef = component.get("v.pageReference").state;
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId,
            "slideDevName": "related"
        });
        navEvt.fire();
    },
})