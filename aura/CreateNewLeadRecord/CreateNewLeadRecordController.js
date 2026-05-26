({
    doInit : function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        var recordId = pageRef.state.c__recordId;
        component.set("v.recordId",recordId);
	    console.log('#myValue '+recordId);    
	},

    onPageReferenceChanged : function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    setFocusedTabLabel : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(response) {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: "New Lead"
            });
            console.log("error");
        })
        .catch(function(error) {
            console.log(error);
        });

        workspaceAPI.getEnclosingTabId().then(function(response) {
                workspaceAPI.setTabIcon({
                tabId: response,
                icon: "standard:lead",
                iconAlt: "Lead"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
,

onRender: function(component) {
    var action = component.get('c.setFocusedTabLabel');
    $A.enqueueAction(action);
}
,

handleEvent: function(component,event){ 
    var action = component.get('c.closeFocusedTab');
    $A.enqueueAction(action);
}
,
handleTabNameEvent: function(component,event){ 
    let myData = event.getParam('data');
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getEnclosingTabId().then(function(response) {
        workspaceAPI.setTabLabel({
            tabId: response,
            label: myData
        });
        console.log("myData"+myData);
    })
    .catch(function(error) {
        console.log(error);
    });
},
closeFocusedTab : function(component, event, helper) {
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function(response) {
        var focusedTabId = response.tabId;
        workspaceAPI.closeTab({tabId: focusedTabId});
    })
    .catch(function(error) {
        console.log(error);
    });
}
    
})