({
	doInit : function(component, event, helper) {

        var workspaceAPI = component.find("workspace");
        var myPageRef = component.get("v.pageReference").state;
        
        let objtName = myPageRef.c__objectName;
        let opportuntityName = myPageRef.c__opportuntityName;
        let recId = myPageRef.c__id;
        let accountName = myPageRef.c__accountName;
		let profileName = myPageRef.c__profileName;
        let hasEOLProducts = false;
        
        let url = '';
         
        let billingContactStatus = myPageRef.c__billingContactStatus;
        let primaryContactStatus = myPageRef.c__primaryContactStatus;
        
        if((billingContactStatus != null && billingContactStatus != 'Active' && billingContactStatus != '') &&
           (primaryContactStatus!= null && primaryContactStatus != 'Active' && primaryContactStatus != '')){
            
           var toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({
               "title": "Warning!",
               "type": "warning",
               "duration": 15000,
               "message": 'The Primary Contact and the Billing Contact linked to the opportunity are inactive. Please update the Primary and Billing Contact.'
           });
           toastEvent.fire();
            
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
            
        } else if((billingContactStatus != null && billingContactStatus != 'Active' && billingContactStatus != '')&&
                 ((primaryContactStatus!= null && primaryContactStatus == 'Active' && primaryContactStatus!='')||primaryContactStatus=='')){
           var toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({
               "title": "Warning!",
               "type": "warning",
               "duration": 15000,
               "message": 'The Billing Contact linked to the opportunity is inactive. Please update the Billing Contact.'
           });
           toastEvent.fire(); 
            
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
        } else if((primaryContactStatus!= null && primaryContactStatus != 'Active' && primaryContactStatus != '')&&
                ((billingContactStatus != null && billingContactStatus == 'Active' && billingContactStatus != '')||billingContactStatus == '')){
            
           var toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({
               "title": "Warning!",
               "type": "warning",
               "duration": 15000,
               "message": 'The Primary Contact linked to the opportunity are inactive. Please update the Primary Contact.'
           });
           toastEvent.fire();
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
            
        } else {
            
        
            // UAT URL - Comment before deployment
          /* url = 'https://uatna11.springcm.com/atlas/doclauncher/eos/Opportunity Create Contract?aid=65440&eos[0].Id=' +
                	recId+'&eos[0].System=Salesforce&eos[0].Type=Opportunity&eos[0].Name='+
                	opportuntityName+'&eos[0].ScmPath=/Salesforce/Account/'+
                	accountName+'/Opportunity';*/
            
            //Production URL - uncommment before deployment
            
            url = 'https://na11.springcm.com/atlas/doclauncher/eos/Opportunity Create Contract?aid=26377&eos[0].Id='+
                recId+'&eos[0].System=Salesforce&eos[0].Type=Opportunity&eos[0].Name='+
                opportuntityName+'&eos[0].ScmPath=/Salesforce/Account/'+
                accountName+'/Opportunity';
            
            

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
        
            if(profileName == 'System Administrator'){
                window.open(url, '_blank');
            } else{
                var action = component.get("c.existEOFProducts");
                action.setParams({
                    "recordId": recId,
                    "objectName": objtName
                });        
                action.setCallback(component, function(response) {
                    var state = response.getState();
    
                    if (state === "SUCCESS") {
        
                        hasEOLProducts = response.getReturnValue();
                        
                        if(hasEOLProducts){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Warning!",
                                "type": "warning",
                                "duration": 15000,
                                "message": 'Launch CLM is not possible as Opportunity has 1 or more products that have been marked as "End of Life".'
                            });
                            toastEvent.fire();
                        } else {
                            window.open(url, '_blank');
                        }                
                    } else {
                         window.open(url, '_blank');
                    }
                });
                $A.enqueueAction(action);
            }
        }
	}
})