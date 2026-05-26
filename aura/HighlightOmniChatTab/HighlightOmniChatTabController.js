({
    onWorkAssigned : function(component, event, helper) {
        debugger;
        
         var workItemId = event.getParam('workItemId');
         console.log('workItemId' + workItemId);
         component.set('v.recordId' ,workItemId );
        console.log(component.get('v.recordId'));
     
        
    },
    onTabCreated : function(component, event, helper){
        debugger;
        var newTabId = event.getParam('tabId');
        var workItemId = component.get('v.recordId');
        console.log('HEllo' + newTabId);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo({
                tabId: newTabId
            }).then(function(response) {
                console.log('HEllo' + response);
                console.log('1 ' + JSON.stringify(response));
                console.log('HEllo' + response.objectApiName);
                console.log('Line 24 ' + response.recordId);
                if(response.recordId){
                var tabRecId = response.recordId.substring(0, 15);
                console.log('HEllo inside if' +tabRecId );
                if(tabRecId === workItemId && response.isSubtab != 'true') {
                console.log('HEllo Inside IF?ELSE' );
                component.set('v.TabId' ,newTabId );    
                workspaceAPI.setTabHighlighted({   
                tabId: newTabId,
                highlighted: true,
                options: {
                    pulse: true,
                    state: "success"
         }
            })
                }}
            });
    },
    onTabFocused : function(component, event, helper) {
        var focusedTabId = event.getParam('currentTabId');
        var highlightedTabId = component.get('v.TabId');
        if(highlightedTabId == focusedTabId){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.setTabHighlighted({
                tabId: focusedTabId,
                highlighted: false,
        })}
    }
    
})