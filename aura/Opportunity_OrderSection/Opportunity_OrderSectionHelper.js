({
    UpdateSaveOrder : function(component,event,helper) {
        var  recordId=component.get("v.recordId");
        //var recordId=OppId;
        //alert("Inside Helper---"+OppId);
        helper.callServer(component,"c.UpdateSaveOrderNew", recordId,
                          function(response){
                              // alert("Inside Call Server");
                              if(response){
                                  var opp= response;
                                  $A.get('e.force:refreshView').fire();
                                  // component.set("v.showWarning",false);
                              }
                              
                          });
    }
})