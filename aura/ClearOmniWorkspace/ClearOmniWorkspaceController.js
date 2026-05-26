({
    /*onWorkAssigned : function(component, event, helper) {
         var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabHighlighted({
                tabId: focusedTabId,
                highlighted: true,
                options: {
                    pulse: true,
                    state: "success"
         }
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },*/
    onChatEnded: function(cmp, evt, hlp) {
        debugger;
        var recordId = evt.getParam( "recordId" );
        var omniAPI = cmp.find("omniToolkit");
        omniAPI.getAgentWorks().then(function(result) {
            var works = JSON.parse(result.works);  
            //let workIds=[] ;//Added by Prachi SD-114304
            let workIds='' ;//Added by Prachi SD-114304
            var work = works[0];
            var workDataId = [];//Added by Prachi SD-114304
            works.forEach(data => {
                if(recordId === data.workItemId){
                 workIds= data.workId ;
                 workDataId = data;//Added by Prachi SD-114304
            }});
       omniAPI.closeAgentWork({workId: workIds}).then(function(res) {   //Commented by Prachi SD-114304  
                console.log('workIds2' + workIds);
                if (res) {
                    console.log("Closed work successfully");
                } else {
                    console.log("Close work failed");
                }
            }).catch(function(error) {
                console.log(error);
            });
        });        
    }  ,
    
})