({
	openTab : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        var recordId = component.get("v.recordId");
        
        workspaceAPI.openTab({
        	url: '/lightning/r/Case/'+recordId+'/clone',
			focus: true
        })
        .then(function(response) { 
            workspaceAPI.getTabInfo({ tabId: response})
        })
        .catch(function(error) {
            console.log( 'Error is ' + error );
        });
         $A.get("e.force:closeQuickAction").fire();
    }
})