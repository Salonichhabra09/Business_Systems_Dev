({
    createOrderRecord : function (component, event, helper) {
        var OpportunityId = component.get("v.recordId");
        //var recordId=OpportunityId;
        //alert("this is" +recordId);
        helper.callServer(component,"c.CreateOrder",OpportunityId,
                          function(response){
                              //alert("Insideif");
                              var responseString = response;
                              if(responseString.match(/order/gi)){
                                  alert(responseString);
                              }
                              else{
                                  //alert(response);
                                  var orderId=response;
                                  var urlEvent = $A.get("e.force:navigateToURL");
                                  urlEvent.setParams({
                                      "url": "/"+orderId+"/e?retURL=%2F"+orderId});
                                  urlEvent.fire();
                              }
                          });
        $A.get('e.force:refreshView').fire();
    }
    
})