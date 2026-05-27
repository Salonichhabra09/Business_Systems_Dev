({
    invoke : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        
        let objtName = component.get("v.objectName");
        let recId = component.get("v.id");
        let accountName = component.get("v.accountName");
        let accountNumber = component.get("v.accountNumber");
        
        // let url = 'https://uatna11.springcm.com/atlas/doclauncher/eos/Opportunity Create Contract?aid=65440&eos[0].Id=' +
        // recId+'&eos[0].System=Salesforce&eos[0].Type=Opportunity&eos[0].Name='+
        // opportuntityName+'&eos[0].ScmPath=/Salesforce/Account/'+
        // accountName+'/Opportunity';
        //
		// Production URL - UnComment before deployment
        /*let url = 'https://na11.springcm.com/atlas/doclauncher/eos/Account Create Contract?aid=26377&eos[0].Id='
        +recId+'&eos[0].System=Salesforce&eos[0].Type=Account&eos[0].Name='+
        accountName+' '+accountNumber+'&eos[0].ScmPath=/Salesforce/Account/';*/
        
        // UAT URL - Comment before deployment
        let url = 'https://uatna11.springcm.com/atlas/doclauncher/eos/Account Create Contract?aid=65440&eos[0].Id='
        +recId+'&eos[0].System=Salesforce&eos[0].Type=Account&eos[0].Name='+
        accountName+' '+accountNumber+'&eos[0].ScmPath=/Salesforce/Account/';
        
        console.log(url);
        window.open(url, '_blank');
  
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
    }
})